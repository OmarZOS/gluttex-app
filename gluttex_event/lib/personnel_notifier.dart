import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/app/ManagementRule.dart';
import 'package:gluttex_core/app/Services/UserService.dart';
import 'package:gluttex_core/business/privileges/role_bit_mapper.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:locator/locator.dart';

class PersonnelNotifier with ChangeNotifier {
  final AppUserService _userService = GluttexLocator.get<AppUserService>();
  final StorageService _storageService = GluttexLocator.get<StorageService>();

  // Main data stores - Use final for maps, modify contents only
  final Map<int, AppUser> _userCache = {};
  final Map<int, List<ManagementRule>> _userPrivileges = {};
  final Map<int, List<ManagementRule>> _pendingRules = {};
  final Map<int, List<ManagementRule>> _activeRules = {};
  final Map<int, List<int>> _userSupplierMappings = {};
  final Map<int, List<int>> _supplierPersonnelMappings = {};

  // Search state - make fields private
  List<AppUser> _filteredPersonnel = [];
  List<AppUser> _searchResults = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _error;
  int _currentPage = 0;
  static const int _itemsPerPage = 50;
  bool _hasMore = true;
  Timer? _debounceTimer;
  bool _isRebuildingState = false;

  // Public getters - use getter syntax for consistency
  List<AppUser> get personnel => _filteredPersonnel;
  List<AppUser> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get error => _error;
  bool get hasMore => _hasMore;

  // Computed getter for total count
  int get totalCount {
    final uniqueUserIds = <int>{};
    for (final userIds in _supplierPersonnelMappings.values) {
      uniqueUserIds.addAll(userIds);
    }
    return uniqueUserIds.length;
  }

  // ------------------------------------------------------------------
  // OPTIMIZED HELPER METHODS
  // ------------------------------------------------------------------

  List<AppUser> _getActiveUsersForSupplier(int supplierId) {
    if (supplierId == 0) {
      // Use iterator for better performance
      return _userCache.values
          .where((user) => _activeRules.containsKey(user.id_app_user ?? 0))
          .toList(growable: false);
    }

    final userIds = _supplierPersonnelMappings[supplierId];
    if (userIds == null || userIds.isEmpty) return const [];

    final result = List<AppUser?>.filled(userIds.length, null);
    for (int i = 0; i < userIds.length; i++) {
      result[i] = _userCache[userIds[i]];
    }
    return result.whereType<AppUser>().toList(growable: false);
  }

  List<AppUser> _getPendingUsersForSupplier(int supplierId) {
    final pendingUsers = <AppUser>[];

    for (final entry in _pendingRules.entries) {
      final userId = entry.key;
      final rules = entry.value;

      bool hasSupplierRule = false;
      for (final rule in rules) {
        final providerId = rule.productProvider?.id_product_provider;
        if (providerId == supplierId || supplierId == 0) {
          hasSupplierRule = true;
          break;
        }
      }

      if (hasSupplierRule) {
        final user = _userCache[userId];
        if (user != null) pendingUsers.add(user);
      }
    }

    return pendingUsers;
  }

  // ------------------------------------------------------------------
  // PUBLIC API METHODS
  // ------------------------------------------------------------------

  List<AppUser> getPersonnelForSupplier(int supplierId,
      {bool includePending = false}) {
    final activeUsers = _getActiveUsersForSupplier(supplierId);
    if (!includePending) return activeUsers;

    final pendingUsers = _getPendingUsersForSupplier(supplierId);
    if (pendingUsers.isEmpty) return activeUsers;

    // Use Set for O(1) lookups
    final activeIds = <int>{};
    for (final user in activeUsers) {
      activeIds.add(user.id_app_user ?? 0);
    }

    final allUsers = List<AppUser>.from(activeUsers);
    for (final user in pendingUsers) {
      if (!activeIds.contains(user.id_app_user)) {
        allUsers.add(user);
      }
    }

    return allUsers;
  }

  void _updateUserRule(int userId, ManagementRule updatedRule) {
    final ruleId = updatedRule.id_management_rule;
    if (ruleId == null) return;

    // 1. Update central cache - use efficient lookup
    final privileges = _userPrivileges[userId];
    if (privileges == null) {
      _userPrivileges[userId] = [updatedRule];
    } else {
      int existingIndex = -1;
      for (int i = 0; i < privileges.length; i++) {
        if (privileges[i].id_management_rule == ruleId) {
          existingIndex = i;
          break;
        }
      }

      if (existingIndex >= 0) {
        privileges[existingIndex] = updatedRule;
      } else {
        privileges.add(updatedRule);
      }
    }

    // 2. Remove from pending/active (more efficient removal)
    _pendingRules[userId]?.removeWhere((r) => r.id_management_rule == ruleId);
    _activeRules[userId]?.removeWhere((r) => r.id_management_rule == ruleId);

    // 3. Categorize updated rule
    final isPending =
        updatedRule.ruleStatus?.toUpperCase() == RuleStates.pending;

    if (isPending) {
      (_pendingRules[userId] ??= []).add(updatedRule);
    } else {
      (_activeRules[userId] ??= []).add(updatedRule);

      // 4. Update dual mappings for active rules
      final supplierId = updatedRule.productProvider?.id_product_provider ?? 0;
      if (supplierId > 0) {
        _rebuildUserState(userId);
      }
    }

    // 5. Notify listeners with debounce
    _scheduleNotifyListeners();
  }

  void _cleanupUserFromSupplier(int userId, int supplierId) {
    // Batch cleanup for better performance
    void cleanupRuleList(Map<int, List<ManagementRule>> ruleMap) {
      final rules = ruleMap[userId];
      if (rules == null) return;

      rules.removeWhere((rule) {
        final providerId = rule.productProvider?.id_product_provider;
        return providerId == supplierId ||
            (supplierId == 0 && providerId != null);
      });

      if (rules.isEmpty) {
        ruleMap.remove(userId);
      }
    }

    cleanupRuleList(_pendingRules);
    cleanupRuleList(_activeRules);

    // Clean up mappings
    if (supplierId != 0) {
      _cleanupSupplierMapping(userId, supplierId);
    } else {
      final userSuppliers = _userSupplierMappings[userId];
      if (userSuppliers != null) {
        for (final providerId in List<int>.from(userSuppliers)) {
          _cleanupSupplierMapping(userId, providerId);
        }
      }
    }
  }

  void _cleanupSupplierMapping(int userId, int supplierId) {
    final hasActiveRules = _activeRules[userId]?.any((rule) {
          final providerId = rule.productProvider?.id_product_provider;
          return providerId == supplierId;
        }) ??
        false;

    if (!hasActiveRules) {
      _userSupplierMappings[userId]?.remove(supplierId);
      if (_userSupplierMappings[userId]?.isEmpty == true) {
        _userSupplierMappings.remove(userId);
      }

      _supplierPersonnelMappings[supplierId]?.remove(userId);
      if (_supplierPersonnelMappings[supplierId]?.isEmpty == true) {
        _supplierPersonnelMappings.remove(supplierId);
      }
    }
  }

  // ------------------------------------------------------------------
  // RULE MANAGEMENT METHODS
  // ------------------------------------------------------------------

  List<ManagementRule> getPendingRulesForUser(int userId,
      {int supplierId = 0}) {
    final rules = _pendingRules[userId];
    if (rules == null) return const [];
    if (supplierId == 0) return List<ManagementRule>.from(rules);

    return rules
        .where(
            (rule) => rule.productProvider?.id_product_provider == supplierId)
        .toList(growable: false);
  }

  List<ManagementRule> getRulesForUser(int userId, {int supplierId = 0}) {
    final rules = _activeRules[userId];
    if (rules == null) return const [];
    if (supplierId == 0) return List<ManagementRule>.from(rules);

    return rules
        .where(
            (rule) => rule.productProvider?.id_product_provider == supplierId)
        .toList(growable: false);
  }

  bool hasPendingRulesForSupplier(int userId, int supplierId) {
    final rules = _pendingRules[userId];
    if (rules == null) return false;

    for (final rule in rules) {
      if (rule.productProvider?.id_product_provider == supplierId) {
        return true;
      }
    }
    return false;
  }

  ManagementRule? getRuleForUser({
    required int userId,
    int ruleId = 0,
    int supplierId = 0,
  }) {
    final rules = _userPrivileges[userId];
    if (rules == null) return null;

    for (final rule in rules) {
      final matchesRuleId = ruleId == 0 || rule.id_management_rule == ruleId;
      final matchesSupplier = supplierId == 0 ||
          rule.productProvider?.id_product_provider == supplierId;

      if (matchesRuleId && matchesSupplier) {
        return rule;
      }
    }

    return null;
  }

  Future<bool> answerInvitation({
    required int ruleId,
    required int answer, // 0 = accept, 1 = reject
  }) async {
    try {
      debugPrint('Answering invitation for ruleId: $ruleId, answer: $answer');

      final response = await _storageService.update(
        "${GluttexConstants.apiBaseUrl}${GluttexConstants.putRuleAnswerEndpoint}/$ruleId",
        "",
        {"answer": answer},
        {},
      );

      // Find rule efficiently
      late ManagementRule? targetRule;
      late int? targetUserId;

      for (final entry in _userPrivileges.entries) {
        for (final rule in entry.value) {
          if (rule.id_management_rule == ruleId) {
            targetRule = rule;
            targetUserId = entry.key;
            break;
          }
        }
        if (targetRule != null) break;
      }

      if (targetRule == null || targetUserId == null) {
        debugPrint("Rule $ruleId not found in privileges");
        return false;
      }

      final supplierId = targetRule.productProvider?.id_product_provider;
      final pendingList = _pendingRules[targetUserId];

      if (pendingList == null) return false;

      final index = pendingList.indexWhere((r) =>
          r.id_management_rule == ruleId &&
          r.productProvider?.id_product_provider == supplierId);

      if (index == -1) {
        debugPrint("Rule $ruleId not found in pending list");
        return false;
      }

      if (answer == 0) {
        // ACCEPT
        final updatedRule = pendingList[index].copyWith(
          ruleStatus: RuleStates.active,
        );

        pendingList.removeAt(index);
        if (pendingList.isEmpty) _pendingRules.remove(targetUserId);

        (_activeRules[targetUserId] ??= []).add(updatedRule);

        // Update master list
        final allRules = _userPrivileges[targetUserId]!;
        final allIndex =
            allRules.indexWhere((r) => r.id_management_rule == ruleId);
        if (allIndex != -1) {
          allRules[allIndex] = updatedRule;
        }

        // Update mappings
        if (supplierId != null && supplierId > 0) {
          (_userSupplierMappings[targetUserId] ??= []).add(supplierId);
          (_supplierPersonnelMappings[supplierId] ??= []).add(targetUserId);
        }

        debugPrint("Rule $ruleId ACCEPTED → moved to ACTIVE");
      } else {
        // REJECT
        pendingList.removeAt(index);
        if (pendingList.isEmpty) _pendingRules.remove(targetUserId);

        _userPrivileges[targetUserId]!
            .removeWhere((r) => r.id_management_rule == ruleId);

        if (_userPrivileges[targetUserId]!.isEmpty) {
          _userPrivileges.remove(targetUserId);
        }

        debugPrint("Rule $ruleId REJECTED → removed");
      }

      _scheduleNotifyListeners();
      return true;
    } catch (e, st) {
      debugPrint("Error answering invitation: $e");
      return false;
    }
  }

  Future<List<ManagementRule>?> getUserPrivileges({
    required int ruleId,
    required int userId,
    int supplierId = 0,
  }) async {
    // Check cache first
    final cachedRules = _userPrivileges[userId];
    if (cachedRules != null && cachedRules.isNotEmpty) {
      return _filterRules(cachedRules, ruleId, supplierId);
    }

    // Fetch from API
    try {
      final jsonResponse = await _storageService.getAll(
        "${GluttexConstants.apiBaseUrl}"
        "${GluttexConstants.getAppUserStaffEndpoint}/0/$supplierId/$userId/$ruleId/0/1",
      );

      if (jsonResponse == null || jsonResponse.isEmpty) return null;

      final allRules = (jsonResponse as List)
          .map<ManagementRule?>((json) {
            try {
              return ManagementRule.fromJson(json as Map<String, dynamic>);
            } catch (e) {
              debugPrint('Error parsing rule: $e');
              return null;
            }
          })
          .whereType<ManagementRule>()
          .toList();

      if (allRules.isEmpty) return null;

      _userPrivileges[userId] = allRules;
      _rebuildUserState(userId);

      return _filterRules(allRules, ruleId, supplierId);
    } catch (e) {
      debugPrint('Error fetching user privileges: $e');
      return null;
    }
  }

  List<ManagementRule>? _filterRules(
    List<ManagementRule> rules,
    int ruleId,
    int supplierId,
  ) {
    List<ManagementRule> filtered = rules;

    if (ruleId != 0) {
      filtered = filtered.where((r) => r.id_management_rule == ruleId).toList();
    }

    if (supplierId != 0) {
      filtered = filtered
          .where((r) => r.productProvider?.id_product_provider == supplierId)
          .toList();
    }

    return filtered.isNotEmpty ? filtered : null;
  }

  Future<bool> addTeamMember(
    int userId, {
    int supplierId = 0,
    int orgId = 0,
    int privilege = 0,
    bool fromQR = false,
  }) async {
    if (_isLoading) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await _userService.addUserToSupplier(
        userId,
        supplierId,
        orgId,
        privilege,
        fromQR: fromQR,
      );
      return true;
    } catch (e) {
      _error = 'Failed to add team member: ${e.toString()}';
      debugPrint('Error adding team member: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void syncRuleState(ManagementRule updatedRule) {
    final ruleId = updatedRule.id_management_rule;
    final userId = updatedRule.appUser?.id_app_user;

    if (ruleId == null || userId == null) return;

    // Avoid rebuilding if already in progress
    if (_isRebuildingState) return;
    _isRebuildingState = true;

    try {
      // 1) Update central source
      final privileges = _userPrivileges[userId] ??= [];
      int existingIndex = -1;

      for (int i = 0; i < privileges.length; i++) {
        if (privileges[i].id_management_rule == ruleId) {
          existingIndex = i;
          break;
        }
      }

      if (existingIndex >= 0) {
        privileges[existingIndex] = updatedRule;
      } else {
        privileges.add(updatedRule);
      }

      // 2) Rebuild state for this user
      _rebuildUserState(userId);

      // 3) Schedule notification
      _scheduleNotifyListeners();
    } finally {
      _isRebuildingState = false;
    }
  }

  void _rebuildUserState(int userId) {
    final rules = _userPrivileges[userId];
    if (rules == null) {
      _pendingRules.remove(userId);
      _activeRules.remove(userId);
      _userSupplierMappings.remove(userId);
      return;
    }

    final pending = <ManagementRule>[];
    final active = <ManagementRule>[];
    final userSuppliers = <int>{};

    for (final rule in rules) {
      final providerId = rule.productProvider?.id_product_provider;
      final isPending =
          (rule.ruleStatus ?? "").toUpperCase() == RuleStates.pending;

      if (isPending) {
        pending.add(rule);
      } else {
        active.add(rule);

        if (providerId != null && providerId > 0) {
          userSuppliers.add(providerId);

          final personnelList = _supplierPersonnelMappings[providerId] ??= [];
          if (!personnelList.contains(userId)) {
            personnelList.add(userId);
          }
        }
      }
    }

    _pendingRules[userId] = pending;
    _activeRules[userId] = active;
    _userSupplierMappings[userId] = userSuppliers.toList();
  }

  Future<bool> updateTeamMemberPrivileges({
    required int ruleId,
    required int userId,
    required int supplierId,
    required int orgId,
    required int privilege,
  }) async {
    if (_isLoading) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final updatedRule = await _userService.updateManagementRule(
        ruleId,
        userId,
        supplierId,
        orgId,
        privilege,
      );

      if (updatedRule == null) {
        debugPrint("updateManagementRule returned null");
        return false;
      }

      syncRuleState(updatedRule);
      return true;
    } catch (e) {
      _error = 'Failed to update team member privileges: ${e.toString()}';
      debugPrint('Error updating team member privileges: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> removeUserFromSupplier(
      int ruleId, int userId, int supplierId) async {
    // Remove rule from master list
    final privileges = _userPrivileges[userId];
    if (privileges != null) {
      privileges.removeWhere((r) => r.id_management_rule == ruleId);
      if (privileges.isEmpty) {
        _userPrivileges.remove(userId);
      }
    }

    // Rebuild state
    _rebuildUserState(userId);
    _scheduleNotifyListeners();

    // Call API
    try {
      await _userService.deleteManagementRule(ruleId);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ------------------------------------------------------------------
  // SEARCH METHODS WITH DEBOUNCE
  // ------------------------------------------------------------------

  void clearSearch({int supplierId = 0}) {
    _searchQuery = '';
    _searchResults = const [];
    _filteredPersonnel = _getActiveUsersForSupplier(supplierId);
    _error = null;
    notifyListeners();
  }

  Future<void> searchPersonnel(String query, {int supplierId = 0}) async {
    final trimmedQuery = query.trim();
    _searchQuery = trimmedQuery;

    // Cancel previous debounce timer
    _debounceTimer?.cancel();

    if (trimmedQuery.isEmpty) {
      _searchResults = const [];
      notifyListeners();
      return;
    }

    // Debounce search to avoid excessive API calls
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      _performSearch(trimmedQuery, supplierId);
    });
  }

  Future<void> _performSearch(String query, int supplierId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final searchResults = await _userService.searchAppUsers(
        query,
        0,
        _itemsPerPage,
      );

      _searchResults = searchResults ?? const [];
      _error = null;
    } catch (e) {
      _error = 'Search failed: ${e.toString()}';
      debugPrint('Error searching personnel: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ------------------------------------------------------------------
  // STATISTICS METHODS
  // ------------------------------------------------------------------

  Map<String, int> getSupplierStats(int supplierId) {
    final activeUsers = _getActiveUsersForSupplier(supplierId);
    final pendingUsers = _getPendingUsersForSupplier(supplierId);

    int admins = 0;
    int managers = 0;

    for (final user in activeUsers) {
      if (user.isAdmin) {
        admins++;
      } else if (user.app_user_type_desc?.toLowerCase().contains('manager') ??
          false) {
        managers++;
      }
    }

    return {
      'active': activeUsers.length,
      'pending': pendingUsers.length,
      'admins': admins,
      'managers': managers,
      'total': activeUsers.length + pendingUsers.length,
    };
  }

  // ------------------------------------------------------------------
  // OPTIMIZATION HELPERS
  // ------------------------------------------------------------------

  void _scheduleNotifyListeners() {
    // Debounce notifications to avoid excessive rebuilds
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 50), () {
      notifyListeners();
    });
  }

  // ------------------------------------------------------------------
  // DEBUG/PERFORMANCE METHODS
  // ------------------------------------------------------------------

  void logCacheStats() {
    debugPrint('''
    PersonnelNotifier Cache Stats:
    - Users: ${_userCache.length}
    - Privileges: ${_userPrivileges.length}
    - Pending Rules: ${_pendingRules.length}
    - Active Rules: ${_activeRules.length}
    - Supplier Mappings: ${_supplierPersonnelMappings.length}
    - Filtered Personnel: ${_filteredPersonnel.length}
    ''');
  }

  void clearAllCache() {
    _userCache.clear();
    _userPrivileges.clear();
    _pendingRules.clear();
    _activeRules.clear();
    _userSupplierMappings.clear();
    _supplierPersonnelMappings.clear();
    _filteredPersonnel = const [];
    _searchResults = const [];
    _currentPage = 0;
    _hasMore = true;
    notifyListeners();
  }

// In your PersonnelNotifier class
  bool hasPrivilege(int userId, int supplierId, String privilegeId) {
    final rules = getRulesForUser(userId, supplierId: supplierId);
    if (rules.isEmpty) return false;

    for (final rule in rules) {
      if (RoleBitMapper.hasPrivilege(
        rule.management_rule_code ?? 0,
        privilegeId,
      )) {
        return true;
      }
    }
    return false;
  }

  /// Check if user has ANY access to a supplier
  bool hasAnyAccessToSupplier(int userId, int supplierId) {
    final rules = getRulesForUser(userId, supplierId: supplierId);
    return rules.isNotEmpty;
  }

  /// Get all suppliers user has access to
  List<int> getAccessibleSupplierIds(int userId) {
    final rules = getRulesForUser(userId);
    final supplierIds = <int>{};

    for (final rule in rules) {
      final supplierId = rule.productProvider?.id_product_provider;
      if (supplierId != null && supplierId > 0) {
        supplierIds.add(supplierId);
      }
    }

    return supplierIds.toList();
  }

  bool _isDisposed = false;
  Completer<void>? _currentLoadOperation;

  Future<void> loadPersonnel({
    int userId = 0,
    bool reset = false,
    int supplierId = 0,
    bool includePending = false,
  }) async {
    // Prevent overlapping operations
    if (_currentLoadOperation != null && !reset) {
      return _currentLoadOperation!.future;
    }

    _currentLoadOperation = Completer();

    try {
      await _loadPersonnelInternal(
        userId: userId,
        reset: reset,
        supplierId: supplierId,
        includePending: includePending,
      );
      _currentLoadOperation!.complete();
    } catch (e) {
      _currentLoadOperation!.completeError(e);
      rethrow;
    } finally {
      _currentLoadOperation = null;
    }
  }

  Future<void> _loadPersonnelInternal({
    int userId = 0,
    bool reset = false,
    int supplierId = 0,
    bool includePending = false,
  }) async {
    if (_isLoading && !reset) return;
    if (!_hasMore && !reset) {
      _rebuildUserState(userId);
      return;
    }

    if (reset) {
      _currentPage = 0;
      _filteredPersonnel = const [];
      _searchResults = const [];
      _hasMore = true;
      _error = null;
    }

    _isLoading = true;
    if (!_isDisposed) notifyListeners();

    try {
      final rules = await _userService.getManagementRules(
        0,
        supplierId,
        userId,
        _currentPage * _itemsPerPage,
        _itemsPerPage,
      );

      if (rules == null || rules.isEmpty) {
        _hasMore = false;
      } else {
        final updatedUserIds = <int>{};
        final newRules = <ManagementRule>[];

        // Process all rules first
        for (final rule in rules) {
          final user = rule.appUser;
          if (user == null) continue;

          final userIdKey = user.id_app_user ?? 0;
          updatedUserIds.add(userIdKey);
          newRules.add(rule);
        }

        // Update caches in a batch
        _updateUserRulesBatch(newRules);

        if (reset && updatedUserIds.isNotEmpty) {
          _cleanupRemovedUsers(updatedUserIds, supplierId);
        }

        _currentPage++;
      }

      _rebuildUserState(userId);
      _error = null;
    } catch (e) {
      _error = 'Failed to load personnel: ${e.toString()}';
      log('Error loading personnel: $e',
          error: e, stackTrace: StackTrace.current);
    } finally {
      _isLoading = false;
      if (!_isDisposed) notifyListeners();
    }
  }

  void _updateUserRulesBatch(List<ManagementRule> rules) {
    for (final rule in rules) {
      final userId = rule.appUser?.id_app_user;
      if (userId == null) continue;

      _updateUserRule(userId, rule);
    }
  }

  void _cleanupRemovedUsers(Set<int> updatedUserIds, int supplierId) {
    // Create copy to avoid modification during iteration
    final userPrivilegesCopy =
        Map<int, List<ManagementRule>>.from(_userPrivileges);
    final usersToRemove = <int>[];

    for (final entry in userPrivilegesCopy.entries) {
      final userId = entry.key;
      if (updatedUserIds.contains(userId)) continue;

      final rules = entry.value;
      bool hasSupplierRules = false;

      for (final rule in rules) {
        final providerId = rule.productProvider?.id_product_provider;
        if (providerId == supplierId ||
            (supplierId == 0 && providerId != null)) {
          hasSupplierRules = true;
          break;
        }
      }

      if (!hasSupplierRules) {
        usersToRemove.add(userId);
      }
    }

    for (final userId in usersToRemove) {
      _cleanupUserFromSupplier(userId, supplierId);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _debounceTimer?.cancel();
    _currentLoadOperation?.complete(); // Complete any pending operations
    super.dispose();
  }
}
