import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/app/ManagementRule.dart';
import 'package:gluttex_core/app/Services/UserService.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:locator/locator.dart';

class PersonnelNotifier with ChangeNotifier {
  final AppUserService _userService = GluttexLocator.get<AppUserService>();
  final StorageService _storageService = GluttexLocator.get<StorageService>();

  // Main data stores
  final Map<int, AppUser> _userCache = {};
  final Map<int, List<ManagementRule>> _userPrivileges = {};

  // Separate stores for pending and active rules
  final Map<int, List<ManagementRule>> _pendingRules = {};
  final Map<int, List<ManagementRule>> _activeRules = {};

  // Dual-direction mappings (only for active rules)
  final Map<int, List<int>> _userSupplierMappings = {};
  final Map<int, List<int>> _supplierPersonnelMappings = {};

  // Search state
  List<AppUser> _filteredPersonnel = [];
  List<AppUser> _searchResults = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _error;
  int _currentPage = 0;
  static const int _itemsPerPage = 50;
  bool _hasMore = true;

  // Public getters
  List<AppUser> get personnel => _filteredPersonnel;
  List<AppUser> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get error => _error;
  bool get hasMore => _hasMore;
  int get totalCount => _getUniqueUserCount();

  // Helper methods
  int _getUniqueUserCount() {
    final uniqueUserIds = <int>{};
    for (final userIds in _supplierPersonnelMappings.values) {
      uniqueUserIds.addAll(userIds);
    }
    return uniqueUserIds.length;
  }

  List<AppUser> _getActiveUsersForSupplier(int supplierId) {
    if (supplierId == 0) {
      return _userCache.values.where((user) {
        final userId = user.id_app_user ?? 0;
        return _activeRules.containsKey(userId) &&
            _activeRules[userId]!.any((rule) =>
                rule.productProvider?.id_product_provider == supplierId ||
                supplierId == 0);
      }).toList();
    }

    final userIds = _supplierPersonnelMappings[supplierId] ?? [];
    return userIds
        .map((userId) => _userCache[userId])
        .whereType<AppUser>()
        .toList();
  }

  List<AppUser> _getPendingUsersForSupplier(int supplierId) {
    final pendingUsers = <AppUser>[];
    for (final entry in _pendingRules.entries) {
      final userId = entry.key;
      final pendingRules = entry.value;

      final supplierRules = pendingRules.where((rule) =>
          supplierId == 0 ||
          rule.productProvider?.id_product_provider == supplierId);

      if (supplierRules.isNotEmpty) {
        final user = _userCache[userId];
        if (user != null) pendingUsers.add(user);
      }
    }
    return pendingUsers;
  }

  // Public API methods
  List<AppUser> getPersonnelForSupplier(int supplierId,
      {bool includePending = false}) {
    final activeUsers = _getActiveUsersForSupplier(supplierId);
    if (!includePending) return activeUsers;

    final pendingUsers = _getPendingUsersForSupplier(supplierId);
    final allUsers = <AppUser>[...activeUsers];
    for (final user in pendingUsers) {
      if (!allUsers.any((u) => u.id_app_user == user.id_app_user)) {
        allUsers.add(user);
      }
    }
    return allUsers;
  }

  Future<void> loadPersonnel({
    int userId = 0,
    bool reset = false,
    int supplierId = 0,
    bool includePending = false,
  }) async {
    if (_isLoading && !reset) return;

    if (reset) {
      _currentPage = 0;
      _filteredPersonnel.clear();
      _searchResults.clear();
      _hasMore = true;
      _error = null;
    }

    if (!_hasMore && !reset) {
      _rebuildFilteredPersonnel(supplierId, includePending);
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final rules = await _userService.getManagementRules(
        0, // org
        supplierId,
        userId,
        _currentPage * _itemsPerPage,
        _itemsPerPage,
      );

      if (rules == null || rules.isEmpty) {
        _hasMore = false;
      } else {
        final updatedUserIds = <int>{};
        for (final rule in rules) {
          if (rule.appUser == null) continue;

          final user = rule.appUser!;
          final userIdKey = user.id_app_user ?? 0;
          updatedUserIds.add(userIdKey);

          _userCache[userIdKey] = user;
          _updateUserRule(userIdKey, rule);
        }

        if (reset) _cleanupRemovedUsers(updatedUserIds, supplierId);
        _currentPage++;
      }

      _rebuildFilteredPersonnel(supplierId, includePending);
      _error = null;
    } catch (e) {
      _error = 'Failed to load personnel: ${e.toString()}';
      log('Error loading personnel: $e', error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _rebuildFilteredPersonnel(int supplierId, bool includePending) {
    _filteredPersonnel = _getActiveUsersForSupplier(supplierId);
    if (includePending) {
      final pending = _getPendingUsersForSupplier(supplierId);
      _filteredPersonnel.addAll(pending.where((user) =>
          !_filteredPersonnel.any((u) => u.id_app_user == user.id_app_user)));
    }
  }

  void _updateUserRule(int userId, ManagementRule rule) {
    // Get existing privileges
    final existingPrivileges = _userPrivileges[userId] ?? [];
    final existingIndex = existingPrivileges.indexWhere((existingRule) =>
        existingRule.id_management_rule == rule.id_management_rule);

    if (existingIndex == -1) {
      // New rule
      _userPrivileges[userId] ??= [];
      _userPrivileges[userId]!.add(rule);
      _categorizeRule(userId, rule, isNew: true);
    } else {
      // Update existing rule
      final existingRule = existingPrivileges[existingIndex];
      final wasPending =
          existingRule.ruleStatus?.toUpperCase() == RuleStates.pending;
      final isPending = rule.ruleStatus?.toUpperCase() == RuleStates.pending;

      existingPrivileges[existingIndex] = rule;

      if (wasPending != isPending) {
        _moveRuleBetweenCategories(userId, rule, wasPending, isPending);
      }
    }
  }

  void _categorizeRule(int userId, ManagementRule rule, {bool isNew = true}) {
    final isPending = rule.ruleStatus?.toUpperCase() == RuleStates.pending;

    if (isPending) {
      _pendingRules[userId] ??= [];
      if (!_pendingRules[userId]!
          .any((r) => r.id_management_rule == rule.id_management_rule)) {
        _pendingRules[userId]!.add(rule);
      }
    } else {
      _activeRules[userId] ??= [];
      if (!_activeRules[userId]!
          .any((r) => r.id_management_rule == rule.id_management_rule)) {
        _activeRules[userId]!.add(rule);
      }

      // Update dual-direction mappings
      final providerId = rule.productProvider?.id_product_provider;
      if (providerId != null && providerId > 0) {
        _userSupplierMappings[userId] ??= [];
        if (!_userSupplierMappings[userId]!.contains(providerId)) {
          _userSupplierMappings[userId]!.add(providerId);
        }

        _supplierPersonnelMappings[providerId] ??= [];
        if (!_supplierPersonnelMappings[providerId]!.contains(userId)) {
          _supplierPersonnelMappings[providerId]!.add(userId);
        }
      }
    }
  }

  void _moveRuleBetweenCategories(
    int userId,
    ManagementRule rule,
    bool wasPending,
    bool isPending,
  ) {
    final ruleId = rule.id_management_rule;

    if (wasPending && !isPending) {
      // Moved from pending to active
      _pendingRules[userId]?.removeWhere((r) => r.id_management_rule == ruleId);
      if (_pendingRules[userId]?.isEmpty == true) {
        _pendingRules.remove(userId);
      }

      _activeRules[userId] ??= [];
      _activeRules[userId]!.add(rule);

      // Add to dual-direction mappings
      final providerId = rule.productProvider?.id_product_provider;
      if (providerId != null && providerId > 0) {
        _userSupplierMappings[userId] ??= [];
        if (!_userSupplierMappings[userId]!.contains(providerId)) {
          _userSupplierMappings[userId]!.add(providerId);
        }

        _supplierPersonnelMappings[providerId] ??= [];
        if (!_supplierPersonnelMappings[providerId]!.contains(userId)) {
          _supplierPersonnelMappings[providerId]!.add(userId);
        }
      }
    } else if (!wasPending && isPending) {
      // Moved from active to pending
      _activeRules[userId]?.removeWhere((r) => r.id_management_rule == ruleId);
      if (_activeRules[userId]?.isEmpty == true) {
        _activeRules.remove(userId);
      }

      _pendingRules[userId] ??= [];
      _pendingRules[userId]!.add(rule);

      // Clean up dual-direction mappings
      final providerId = rule.productProvider?.id_product_provider;
      if (providerId != null && providerId > 0) {
        _cleanupSupplierMapping(userId, providerId);
      }
    }
  }

  void _cleanupRemovedUsers(Set<int> updatedUserIds, int supplierId) {
    for (final entry in _userPrivileges.entries.toList()) {
      final userId = entry.key;
      final rules = entry.value;

      final supplierRules = rules.where((rule) {
        final providerId = rule.productProvider?.id_product_provider;
        return providerId == supplierId ||
            (supplierId == 0 && providerId != null);
      }).toList();

      if (supplierRules.isEmpty && !updatedUserIds.contains(userId)) {
        _cleanupUserFromSupplier(userId, supplierId);
      }
    }
  }

  void _cleanupUserFromSupplier(int userId, int supplierId) {
    // Remove from pending rules
    _pendingRules[userId]?.removeWhere((rule) {
      final providerId = rule.productProvider?.id_product_provider;
      return providerId == supplierId ||
          (supplierId == 0 && providerId != null);
    });
    if (_pendingRules[userId]?.isEmpty == true) {
      _pendingRules.remove(userId);
    }

    // Remove from active rules
    _activeRules[userId]?.removeWhere((rule) {
      final providerId = rule.productProvider?.id_product_provider;
      return providerId == supplierId ||
          (supplierId == 0 && providerId != null);
    });
    if (_activeRules[userId]?.isEmpty == true) {
      _activeRules.remove(userId);
    }

    // Clean up mappings
    if (supplierId != 0) {
      _cleanupSupplierMapping(userId, supplierId);
    } else {
      final userSuppliers = _userSupplierMappings[userId] ?? [];
      for (final providerId in userSuppliers) {
        _cleanupSupplierMapping(userId, providerId);
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

  // Rule management methods
  List<ManagementRule> getPendingRulesForUser(int userId,
      {int supplierId = 0}) {
    final rules = _pendingRules[userId] ?? [];
    if (supplierId == 0) return List.from(rules);

    return rules
        .where(
            (rule) => rule.productProvider?.id_product_provider == supplierId)
        .toList();
  }

  List<ManagementRule> getRulesForUser(int userId, {int supplierId = 0}) {
    final rules = _activeRules[userId] ?? [];
    if (supplierId == 0) return List.from(rules);

    return rules
        .where(
            (rule) => rule.productProvider?.id_product_provider == supplierId)
        .toList();
  }

  bool hasPendingRulesForSupplier(int userId, int supplierId) {
    final rules = _pendingRules[userId] ?? [];
    return rules
        .any((rule) => rule.productProvider?.id_product_provider == supplierId);
  }

  ManagementRule? getRuleForUser({
    required int userId,
    int ruleId = 0,
    int supplierId = 0,
  }) {
    // Check all privileges first
    final allRules = _userPrivileges[userId];
    if (allRules == null) return null;

    return allRules.firstWhere(
      (rule) {
        final matchesRuleId = ruleId == 0 || rule.id_management_rule == ruleId;
        final matchesSupplier = supplierId == 0 ||
            rule.productProvider?.id_product_provider == supplierId;
        return matchesRuleId && matchesSupplier;
      },
      // orElse: () => null,
    );
  }

  Future<bool> answerInvitation({
    required int ruleId,
    required int answer, // 0 = accept, 1 = reject
  }) async {
    try {
      log('Answering invitation for ruleId: $ruleId, answer: $answer');

      final response = await _storageService.update(
        "${GluttexConstants.apiBaseUrl}${GluttexConstants.putRuleAnswerEndpoint}/$ruleId",
        "",
        {"answer": answer},
        {},
      );

      log('Invitation response: $response');

      // Find rule in ANY user privileges
      ManagementRule? targetRule;
      int? userId;

      for (final entry in _userPrivileges.entries) {
        final found = entry.value.firstWhere(
          (r) => r.id_management_rule == ruleId,
          orElse: () => null as ManagementRule,
        );
        if (found != null) {
          targetRule = found;
          userId = entry.key;
          break;
        }
      }

      if (targetRule == null || userId == null) {
        log("Rule $ruleId not found in privileges");
        return false;
      }

      final supplierId = targetRule.productProvider?.id_product_provider;

      // Find pending rule for this user/supplier
      final pendingList = _pendingRules[userId];
      if (pendingList == null) return false;

      final index = pendingList.indexWhere((r) =>
          r.id_management_rule == ruleId &&
          r.productProvider?.id_product_provider == supplierId);

      if (index == -1) {
        log("Rule $ruleId not found in pending list");
        return false;
      }

      final pendingRule = pendingList[index];

      if (answer == 0) {
        // -------------------- ACCEPT --------------------
        final updatedRule = pendingRule.copyWith(
          ruleStatus: RuleStates.active,
        );

        // Remove from pending
        pendingList.removeAt(index);
        if (pendingList.isEmpty) _pendingRules.remove(userId);

        // Add to active
        _activeRules[userId] ??= [];
        _activeRules[userId]!.add(updatedRule);

        // Update master privileges list
        final all = _userPrivileges[userId]!;
        final allIndex = all.indexWhere((r) => r.id_management_rule == ruleId);
        if (allIndex != -1) {
          all[allIndex] = updatedRule;
        }

        // Update mappings
        if (supplierId != null && supplierId > 0) {
          _userSupplierMappings[userId] ??= [];
          if (!_userSupplierMappings[userId]!.contains(supplierId)) {
            _userSupplierMappings[userId]!.add(supplierId);
          }

          _supplierPersonnelMappings[supplierId] ??= [];
          if (!_supplierPersonnelMappings[supplierId]!.contains(userId)) {
            _supplierPersonnelMappings[supplierId]!.add(userId);
          }
        }

        log("Rule $ruleId ACCEPTED → moved to ACTIVE");
      } else {
        // -------------------- REJECT --------------------
        pendingList.removeAt(index);
        if (pendingList.isEmpty) _pendingRules.remove(userId);

        // Remove from privileges
        _userPrivileges[userId]!
            .removeWhere((r) => r.id_management_rule == ruleId);
        if (_userPrivileges[userId]!.isEmpty) {
          _userPrivileges.remove(userId);
        }

        log("Rule $ruleId REJECTED → removed");
      }

      notifyListeners();
      return true;
    } catch (e, st) {
      log("Error answering invitation: $e");
      log("STACK: $st");
      return false;
    }
  }

  Future<List<ManagementRule>?> getUserPrivileges({
    required int ruleId,
    required int userId,
    int supplierId = 0,
  }) async {
    final cachedRules = _userPrivileges[userId];
    List<ManagementRule> allRules;

    if (cachedRules == null || cachedRules.isEmpty) {
      final jsonResponse = await _storageService.getAll(
        "${GluttexConstants.apiBaseUrl}"
        "${GluttexConstants.getAppUserStaffEndpoint}/0/$supplierId/$userId/$ruleId/0/1",
      );

      if (jsonResponse == null || jsonResponse.isEmpty) return null;

      try {
        allRules = (jsonResponse as List)
            .map(
                (json) => ManagementRule.fromJson(json as Map<String, dynamic>))
            .toList();
        _userPrivileges[userId] = allRules;
        _rebuildUserRuleMaps(userId, allRules);
      } catch (e) {
        log('Error parsing rules: $e');
        return null;
      }
    } else {
      allRules = List.from(cachedRules);
    }

    // Apply filters
    var filteredRules = allRules;
    if (ruleId != 0) {
      filteredRules = filteredRules
          .where((rule) => rule.id_management_rule == ruleId)
          .toList();
    }
    if (supplierId != 0) {
      filteredRules = filteredRules.where((rule) {
        final providerId = rule.productProvider?.id_product_provider;
        return providerId == supplierId;
      }).toList();
    }

    return filteredRules.isNotEmpty ? filteredRules : null;
  }

  void _rebuildUserRuleMaps(int userId, List<ManagementRule> rules) {
    _pendingRules[userId] = [];
    _activeRules[userId] = [];

    for (final rule in rules) {
      final providerId = rule.productProvider?.id_product_provider;

      if (rule.ruleStatus?.toUpperCase() == RuleStates.pending) {
        _pendingRules[userId]!.add(rule);
      } else {
        _activeRules[userId]!.add(rule);

        // Maintain user <-> supplier maps
        if (providerId != null && providerId > 0) {
          _userSupplierMappings[userId] ??= [];
          if (!_userSupplierMappings[userId]!.contains(providerId)) {
            _userSupplierMappings[userId]!.add(providerId);
          }

          _supplierPersonnelMappings[providerId] ??= [];
          if (!_supplierPersonnelMappings[providerId]!.contains(userId)) {
            _supplierPersonnelMappings[providerId]!.add(userId);
          }
        }
      }
    }
  }

  Future<bool> addTeamMember(int userId,
      {int supplierId = 0,
      int orgId = 0,
      int privilege = 0,
      bool fromQR = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _userService.addUserToSupplier(userId, supplierId, orgId, privilege,
          fromQR: fromQR);
      return true;
    } catch (e) {
      _error = 'Failed to add team member: ${e.toString()}';
      log('Error adding team member: $e', error: e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateTeamMemberPrivileges({
    required int ruleId,
    required int userId,
    required int supplierId,
    required int orgId,
    required int privilege,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final ManagementRule? rule = await _userService.updateManagementRule(
        ruleId,
        userId,
        supplierId,
        orgId,
        privilege,
      );

      _updateUserRule(userId, rule!);
      return true;
    } catch (e) {
      _error = 'Failed to add team member: ${e.toString()}';
      log('Error adding team member: $e', error: e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> removeUserFromSupplier(
      int ruleId, int userId, int supplierId) async {
    try {
      // Remove from active rules and mappings
      _activeRules[userId]?.removeWhere(
          (rule) => rule.productProvider?.id_product_provider == supplierId);
      if (_activeRules[userId]?.isEmpty == true) {
        _activeRules.remove(userId);
      }

      // Remove from pending rules
      _pendingRules[userId]?.removeWhere(
          (rule) => rule.productProvider?.id_product_provider == supplierId);
      if (_pendingRules[userId]?.isEmpty == true) {
        _pendingRules.remove(userId);
      }

      // Remove from all privileges
      _userPrivileges[userId]?.removeWhere(
          (rule) => rule.productProvider?.id_product_provider == supplierId);
      if (_userPrivileges[userId]?.isEmpty == true) {
        _userPrivileges.remove(userId);
      }

      // Clean up mappings
      _cleanupSupplierMapping(userId, supplierId);

      // Update filtered list
      _rebuildFilteredPersonnel(supplierId, true);

      _isLoading = true;
      notifyListeners();

      try {
        await _userService.deleteManagementRule(
          ruleId,
        );
        // return true;
      } catch (e) {
        _error = 'Failed to add team member: ${e.toString()}';
        log('Error adding team member: $e', error: e);
        return false;
      } finally {
        _isLoading = false;
      }

      notifyListeners();
      return true;
    } catch (e) {
      log('Error removing user from supplier: $e');
      return false;
    }
  }

  // Search methods
  void clearSearch({int supplierId = 0}) {
    _searchQuery = '';
    _searchResults.clear();
    _filteredPersonnel = _getActiveUsersForSupplier(supplierId);
    _error = null;
    notifyListeners();
  }

  Future<void> searchPersonnel(String query, {int supplierId = 0}) async {
    _searchQuery = query.trim();
    _searchResults.clear();

    if (_searchQuery.isEmpty) {
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final searchResults = await _userService.searchAppUsers(
        _searchQuery,
        0,
        _itemsPerPage,
      );

      if (searchResults != null && searchResults.isNotEmpty) {
        _searchResults = searchResults;
      }

      _error = null;
    } catch (e) {
      _error = 'Search failed: ${e.toString()}';
      log('Error searching personnel: $e', error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Statistics methods
  Map<String, int> getSupplierStats(int supplierId) {
    final activeUsers = _getActiveUsersForSupplier(supplierId);
    final pendingUsers = _getPendingUsersForSupplier(supplierId);

    final admins = activeUsers.where((user) => user.isAdmin).length;
    final managers = activeUsers
        .where((user) =>
            user.app_user_type_desc?.toLowerCase().contains('manager') ?? false)
        .length;

    return {
      'active': activeUsers.length,
      'pending': pendingUsers.length,
      'admins': admins,
      'managers': managers,
      'total': activeUsers.length + pendingUsers.length,
    };
  }
}
