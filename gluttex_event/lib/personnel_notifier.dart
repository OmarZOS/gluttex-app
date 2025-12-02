import 'dart:collection';
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
  final Map<int, AppUser> _userCache = {}; // userId -> AppUser
  final Map<int, List<ManagementRule>> _userPrivileges =
      {}; // userId -> all privileges (pending + active)

  // Separate stores for pending and active rules
  final Map<int, List<ManagementRule>> _pendingRules =
      {}; // userId -> pending rules
  final Map<int, List<ManagementRule>> _activeRules =
      {}; // userId -> active rules

  // Dual-direction mappings (only for active rules)
  final Map<int, List<int>> _userSupplierMappings =
      {}; // userId -> supplierIds (active only)
  final Map<int, List<int>> _supplierPersonnelMappings =
      {}; // supplierId -> userIds (active only)

  // Search state
  List<AppUser> _filteredPersonnel = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _error;
  int _currentPage = 0;
  static const int _itemsPerPage = 50;
  bool _hasMore = true;

// Add this new variable in the class
  List<AppUser> _searchResults = []; // Separate list for search results

// Update the getter
  List<AppUser> get searchResults =>
      _searchResults; // New getter for search results only

  List<AppUser> get personnel => _filteredPersonnel;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get error => _error;
  bool get hasMore => _hasMore;
  int get totalCount => _getUniqueUserCount();

  // New getters for pending rules
  List<ManagementRule> get allPendingRules {
    final allRules = <ManagementRule>[];
    for (final rules in _pendingRules.values) {
      allRules.addAll(rules);
    }
    return allRules;
  }

  List<ManagementRule> get allActiveRules {
    final allRules = <ManagementRule>[];
    for (final rules in _activeRules.values) {
      allRules.addAll(rules);
    }
    return allRules;
  }

  /// Get total unique users across all suppliers (no duplicates) - active only
  int _getUniqueUserCount() {
    final uniqueUserIds = <int>{};
    for (final userIds in _supplierPersonnelMappings.values) {
      uniqueUserIds.addAll(userIds);
    }
    return uniqueUserIds.length;
  }

  /// Get active users for supplier
  List<AppUser> _getActiveUsersForSupplier(int supplierId) {
    if (supplierId == 0) {
      // Return all unique active users
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

  /// Get pending users for supplier
  List<AppUser> _getPendingUsersForSupplier(int supplierId) {
    final pendingUsers = <AppUser>[];
    for (final entry in _pendingRules.entries) {
      final userId = entry.key;
      final pendingRules = entry.value;

      // Filter rules for the specific supplier
      final supplierRules = pendingRules.where((rule) =>
          supplierId == 0 ||
          rule.productProvider?.id_product_provider == supplierId);

      if (supplierRules.isNotEmpty) {
        final user = _userCache[userId];
        if (user != null) {
          pendingUsers.add(user);
        }
      }
    }
    return pendingUsers;
  }

  /// Get all users (active + pending) for supplier
  List<AppUser> getPersonnelForSupplier(int supplierId,
      {bool includePending = false}) {
    final activeUsers = _getActiveUsersForSupplier(supplierId);
    if (!includePending) return activeUsers;

    final pendingUsers = _getPendingUsersForSupplier(supplierId);
    // Remove duplicates (users can have both pending and active rules)
    final allUsers = <AppUser>[...activeUsers];
    for (final user in pendingUsers) {
      if (!allUsers.any((u) => u.id_app_user == user.id_app_user)) {
        allUsers.add(user);
      }
    }
    return allUsers;
  }

  /// Load personnel with pagination support
  Future<void> loadPersonnel(int userId,
      {bool reset = false,
      int supplierId = 0,
      bool includePending = false}) async {
    if (_isLoading && !reset) return;

    if (reset) {
      _currentPage = 0;
      _userCache.clear();
      _userPrivileges.clear();
      _pendingRules.clear();
      _activeRules.clear();
      _userSupplierMappings.clear();
      _supplierPersonnelMappings.clear();
      _filteredPersonnel.clear();
      _hasMore = true;
      _error = null;
    }

    if (!_hasMore && !reset) {
      _filteredPersonnel = _getActiveUsersForSupplier(supplierId);
      if (includePending) {
        final pending = _getPendingUsersForSupplier(supplierId);
        _filteredPersonnel.addAll(pending.where((user) =>
            !_filteredPersonnel.any((u) => u.id_app_user == user.id_app_user)));
      }
      notifyListeners();
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
        for (final rule in rules) {
          if (rule.appUser == null) continue;

          final AppUser user = rule.appUser!;
          final userIdKey = user.id_app_user ?? 0;

          // Store user in cache
          _userCache[userIdKey] = user;

          // Store in all privileges
          _userPrivileges[userIdKey] ??= [];
          if (!_userPrivileges[userIdKey]!.contains(rule)) {
            _userPrivileges[userIdKey]!.add(rule);
          }

          // Categorize as pending or active
          final isPending =
              rule.ruleStatus?.toUpperCase() == RuleStates.pending;
          if (isPending) {
            _pendingRules[userIdKey] ??= [];
            if (!_pendingRules[userIdKey]!.contains(rule)) {
              _pendingRules[userIdKey]!.add(rule);
            }
          } else {
            _activeRules[userIdKey] ??= [];
            if (!_activeRules[userIdKey]!.contains(rule)) {
              _activeRules[userIdKey]!.add(rule);
            }

            // Update dual-direction mappings for active rules only
            final providerId = rule.productProvider?.id_product_provider;
            if (providerId != null && providerId > 0) {
              // User -> Supplier mapping
              _userSupplierMappings[userIdKey] ??= [];
              if (!_userSupplierMappings[userIdKey]!.contains(providerId)) {
                _userSupplierMappings[userIdKey]!.add(providerId);
              }

              // Supplier -> User mapping
              _supplierPersonnelMappings[providerId] ??= [];
              if (!_supplierPersonnelMappings[providerId]!
                  .contains(userIdKey)) {
                _supplierPersonnelMappings[providerId]!.add(userIdKey);
              }
            }
          }
        }

        _currentPage++;
      }

      // Filter personnel by supplier
      _filteredPersonnel = _getActiveUsersForSupplier(supplierId);
      if (includePending) {
        final pending = _getPendingUsersForSupplier(supplierId);
        _filteredPersonnel.addAll(pending.where((user) =>
            !_filteredPersonnel.any((u) => u.id_app_user == user.id_app_user)));
      }

      _error = null;
    } catch (e) {
      _error = 'Failed to load personnel: ${e.toString()}';
      if (kDebugMode) {
        log('Error loading personnel: $e', error: e);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get pending rules for a specific user
  List<ManagementRule> getPendingRulesForUser(int userId,
      {int supplierId = 0}) {
    final rules = _pendingRules[userId] ?? [];
    if (supplierId == 0) return List.from(rules);

    return rules
        .where(
            (rule) => rule.productProvider?.id_product_provider == supplierId)
        .toList();
  }

  /// Get active rules for a specific user
  List<ManagementRule> getActiveRulesForUser(int userId, {int supplierId = 0}) {
    final rules = _activeRules[userId] ?? [];
    if (supplierId == 0) return List.from(rules);

    return rules
        .where(
            (rule) => rule.productProvider?.id_product_provider == supplierId)
        .toList();
  }

  /// Check if user has any pending rules for supplier
  bool hasPendingRulesForSupplier(int userId, int supplierId) {
    final rules = _pendingRules[userId] ?? [];
    return rules
        .any((rule) => rule.productProvider?.id_product_provider == supplierId);
  }

  /// Check if user has any active rules for supplier
  bool hasActiveRulesForSupplier(int userId, int supplierId) {
    final rules = _activeRules[userId] ?? [];
    return rules
        .any((rule) => rule.productProvider?.id_product_provider == supplierId);
  }

  /// Get user's rule status for a supplier
  String? getUserRuleStatusForSupplier(int userId, int supplierId) {
    // Check pending first
    final pendingRule = _pendingRules[userId]?.firstWhere(
      (rule) => rule.productProvider?.id_product_provider == supplierId,
      // orElse: () => null,
    );

    if (pendingRule != null) return RuleStates.pending;

    // Check active
    final activeRule = _activeRules[userId]?.firstWhere(
      (rule) => rule.productProvider?.id_product_provider == supplierId,
      // orElse: () => null,
    );

    return activeRule?.ruleStatus;
  }

  /// Add team member with privileges - always creates pending rule initially
  Future<bool> addTeamMember(
    int userId, {
    int supplierId = 0,
    int orgId = 0,
    int privilege = 0,
    bool fromQR = false,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final managementRule = await _userService.addUserToSupplier(
        userId,
        supplierId,
        orgId,
        privilege,
      );

      if (managementRule == null || managementRule.appUser == null) {
        _error = 'Failed to add user: No data returned';
        return false;
      }

      final AppUser addedUser = managementRule.appUser!;
      final userIdKey = addedUser.id_app_user ?? 0;

      // Store user in cache
      _userCache[userIdKey] = addedUser;

      // Store in all privileges
      _userPrivileges[userIdKey] ??= [];
      if (!_userPrivileges[userIdKey]!.contains(managementRule)) {
        _userPrivileges[userIdKey]!.add(managementRule);
      }

      // Add to pending rules (new invites are always pending)
      _pendingRules[userIdKey] ??= [];
      if (!_pendingRules[userIdKey]!.contains(managementRule)) {
        _pendingRules[userIdKey]!.add(managementRule);
      }

      // DO NOT update _filteredPersonnel - let the next refresh handle it
      // Remove user from search results if they were there
      _searchResults.removeWhere((user) => user.id_app_user == userIdKey);

      _error = null;
      return true;
    } catch (e) {
      _error = 'Failed to add team member: ${e.toString()}';
      if (kDebugMode) {
        log('Error adding team member: $e', error: e);
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Answer invitation (accept/reject) and update local state
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

      final data = getRuleUserAndSupplier(ruleId);
      if (data == null) {
        log('Could not find rule $ruleId in cache');
        return false;
      }

      final userId = data["userId"];
      final supplierId = data["supplierId"];

      // Find the rule in pending rules
      final pendingRules = _pendingRules[userId];
      if (pendingRules != null) {
        final ruleIndex = pendingRules.indexWhere((rule) =>
            rule.id_management_rule == ruleId &&
            rule.productProvider?.id_product_provider == supplierId);

        if (ruleIndex != -1) {
          final rule = pendingRules[ruleIndex];

          if (answer == 0) {
            // ACCEPT - Move from pending to active
            final updatedRule = rule.copyWith(ruleStatus: RuleStates.active);

            // Remove from pending
            pendingRules.removeAt(ruleIndex);
            if (pendingRules.isEmpty) {
              _pendingRules.remove(userId);
            }

            // Add to active
            _activeRules[userId ?? 0] ??= [];
            _activeRules[userId]!.add(updatedRule);

            // Update all privileges list
            final allPrivileges = _userPrivileges[userId];
            if (allPrivileges != null) {
              final allIndex = allPrivileges
                  .indexWhere((r) => r.id_management_rule == ruleId);
              if (allIndex != -1) {
                allPrivileges[allIndex] = updatedRule;
              }
            }

            // Update dual-direction mappings
            final providerId = updatedRule.productProvider?.id_product_provider;
            if (providerId != null && providerId > 0) {
              _userSupplierMappings[userId ?? 0] ??= [];
              if (!_userSupplierMappings[userId]!.contains(providerId)) {
                _userSupplierMappings[userId]!.add(providerId);
              }

              _supplierPersonnelMappings[providerId] ??= [];
              if (!_supplierPersonnelMappings[providerId]!.contains(userId)) {
                _supplierPersonnelMappings[providerId]!.add(userId ?? 0);
              }
            }

            log('Moved rule $ruleId from PENDING to ACTIVE for user $userId');
          } else {
            // REJECT - Remove from pending
            pendingRules.removeAt(ruleIndex);
            if (pendingRules.isEmpty) {
              _pendingRules.remove(userId);
            }

            // Remove from all privileges
            final allPrivileges = _userPrivileges[userId];
            if (allPrivileges != null) {
              allPrivileges.removeWhere((r) => r.id_management_rule == ruleId);
              if (allPrivileges.isEmpty) {
                _userPrivileges.remove(userId);
              }
            }

            log('Removed rule $ruleId for user $userId (rejected)');
          }

          notifyListeners();
          return true;
        }
      }

      return false;
    } catch (e, stacktrace) {
      log('Error answering invitation: $e');
      log('Stack trace: $stacktrace');
      return false;
    }
  }

  /// Update an existing active rule's privileges
  Future<bool> updateTeamMemberPrivileges({
    required int ruleId,
    required int userId,
    required int supplierId,
    required int orgId,
    required int privilege,
  }) async {
    try {
      // Call API to update privilege
      // final updatedRule = await _userService.update(
      //   ruleId: ruleId,
      //   userId: userId,
      //   supplierId: supplierId,
      //   orgId: orgId,
      //   privilege: privilege,
      // );

      // if (updatedRule == null) return false;

      // // Update in active rules
      // final activeRules = _activeRules[userId];
      // if (activeRules != null) {
      //   final index = activeRules.indexWhere((rule) =>
      //       rule.id_management_rule == ruleId &&
      //       rule.productProvider?.id_product_provider == supplierId);

      //   if (index != -1) {
      //     activeRules[index] = updatedRule;
      //   }
      // }

      // // Update in all privileges
      // final allPrivileges = _userPrivileges[userId];
      // if (allPrivileges != null) {
      //   final index = allPrivileges
      //       .indexWhere((rule) => rule.id_management_rule == ruleId);

      //   if (index != -1) {
      //     allPrivileges[index] = updatedRule;
      //   }
      // }

      notifyListeners();
      return true;
    } catch (e) {
      log('Error updating team member privileges: $e');
      return false;
    }
  }

  /// Get all suppliers for a specific user (active only)
  List<int> getSuppliersForUser(int userId) {
    return List.from(_userSupplierMappings[userId] ?? []);
  }

  /// Get all unique suppliers (with at least one active user)
  List<int> getAllSuppliers() {
    return _supplierPersonnelMappings.keys.toList();
  }

  /// Get user from cache
  AppUser? getUserFromCache(int userId) {
    return _userCache[userId];
  }

  /// Get user privileges with caching
  Future<List<ManagementRule>?> getUserPrivileges({
    required int ruleId,
    required int userId,
    int supplierId = 0,
  }) async {
    log('Fetching privileges for userId: $userId, ruleId: $ruleId, supplierId: $supplierId');

    // 1) Try cache first
    final cachedRules = _userPrivileges[userId];

    List<ManagementRule> allRules;

    // 2) If cache is empty, fetch from storage service
    if (cachedRules == null || cachedRules.isEmpty) {
      log('Cache miss - fetching from storage service');
      final jsonResponse = await _storageService.getAll(
        "${GluttexConstants.apiBaseUrl}${GluttexConstants.getAppUserStaffEndpoint}/0/$supplierId/$userId/$ruleId/0/1",
      );

      if (jsonResponse == null || jsonResponse.isEmpty) {
        log('No data from storage service');
        return null;
      }

      try {
        allRules = (jsonResponse as List)
            .map(
                (json) => ManagementRule.fromJson(json as Map<String, dynamic>))
            .toList();

        // Cache the results and categorize
        _userPrivileges[userId] = allRules;

        // Clear existing pending/active for this user before re-categorizing
        _pendingRules.remove(userId);
        _activeRules.remove(userId);

        for (final rule in allRules) {
          final isPending =
              rule.ruleStatus?.toUpperCase() == RuleStates.pending;
          if (isPending) {
            _pendingRules[userId] ??= [];
            _pendingRules[userId]!.add(rule);
          } else {
            _activeRules[userId] ??= [];
            _activeRules[userId]!.add(rule);

            // Update dual-direction mappings for active rules
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

        log('Fetched ${allRules.length} rules from storage');
      } catch (e) {
        log('Error parsing rules: $e');
        return null;
      }
    } else {
      log('Cache hit - using ${cachedRules.length} cached rules');
      allRules = List.from(cachedRules);
    }

    // 3) Filter by ruleId if specified
    List<ManagementRule> filteredRules = allRules;
    if (ruleId != 0) {
      filteredRules =
          allRules.where((rule) => rule.id_management_rule == ruleId).toList();
      log('After ruleId filter: ${filteredRules.length} rules');
    }

    // 4) Filter by supplierId if specified
    if (supplierId != 0) {
      filteredRules = filteredRules.where((rule) {
        final providerId = rule.productProvider?.id_product_provider;
        return providerId == supplierId;
      }).toList();
      log('After supplierId filter: ${filteredRules.length} rules');
    }

    return filteredRules.isNotEmpty ? filteredRules : null;
  }

  /// Returns (userId, supplierId) for a given ruleId.
  Map<String, int>? getRuleUserAndSupplier(int ruleId) {
    if (ruleId == 0) return null;

    for (final entry in _userPrivileges.entries) {
      final userId = entry.key;
      final rules = entry.value;

      for (final rule in rules) {
        if (rule.id_management_rule == ruleId) {
          final supplierId = rule.productProvider?.id_product_provider ?? 0;
          return {"userId": userId, "supplierId": supplierId};
        }
      }
    }

    return null;
  }

  /// Clean up supplier mapping when rule is removed
  void _cleanupSupplierMapping(int userId, int supplierId) {
    final userRules = _activeRules[userId] ?? [];
    final hasOtherRules = userRules
        .any((rule) => rule.productProvider?.id_product_provider == supplierId);

    if (!hasOtherRules) {
      // Remove from user -> supplier mapping
      _userSupplierMappings[userId]?.remove(supplierId);
      if (_userSupplierMappings[userId]?.isEmpty == true) {
        _userSupplierMappings.remove(userId);
      }

      // Remove from supplier -> user mapping
      _supplierPersonnelMappings[supplierId]?.remove(userId);
      if (_supplierPersonnelMappings[supplierId]?.isEmpty == true) {
        _supplierPersonnelMappings.remove(supplierId);
      }
    }
  }

  /// Clear search and show all personnel for current supplier
  void clearSearch({int supplierId = 0}) {
    _searchQuery = '';
    _searchResults = []; // Clear search results
    _filteredPersonnel = _getActiveUsersForSupplier(supplierId);
    _error = null;
    notifyListeners();
  }

  /// Refresh all data for specific supplier context
  Future<void> refresh(int userId,
      {int supplierId = 0, bool includePending = false}) async {
    await loadPersonnel(
      userId,
      reset: true,
      supplierId: supplierId,
      includePending: includePending,
    );
  }

  /// Clear any error messages
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Check if invitation is pending
  bool isInvitationPending({
    required int userId,
    required int ruleId,
    int supplierId = 0,
  }) {
    final pendingRules = _pendingRules[userId];
    if (pendingRules == null) return false;

    return pendingRules.any((rule) {
      final matchesRuleId = rule.id_management_rule == ruleId;
      if (supplierId == 0) return matchesRuleId;
      final providerId = rule.productProvider?.id_product_provider;
      return matchesRuleId && providerId == supplierId;
    });
  }

  /// Check if rule is active
  bool isRuleActive({
    required int userId,
    required int ruleId,
    int supplierId = 0,
  }) {
    final activeRules = _activeRules[userId];
    if (activeRules == null) return false;

    return activeRules.any((rule) {
      final matchesRuleId = rule.id_management_rule == ruleId;
      if (supplierId == 0) return matchesRuleId;
      final providerId = rule.productProvider?.id_product_provider;
      return matchesRuleId && providerId == supplierId;
    });
  }

  /// Get specific rule for user
  ManagementRule? getRuleForUser({
    required int userId,
    required int ruleId,
    int supplierId = 0,
  }) {
    // Check pending first
    final pendingRules = _pendingRules[userId];
    if (pendingRules != null) {
      final pendingRule = pendingRules.firstWhere(
        (rule) {
          final matchesRuleId = rule.id_management_rule == ruleId;
          if (supplierId == 0) return matchesRuleId;
          final providerId = rule.productProvider?.id_product_provider;
          return matchesRuleId && providerId == supplierId;
        },
        // orElse: () => null,
      );

      if (pendingRule != null) return pendingRule;
    }

    // Check active
    final activeRules = _activeRules[userId];
    if (activeRules != null) {
      return activeRules.firstWhere(
        (rule) {
          final matchesRuleId = rule.id_management_rule == ruleId;
          if (supplierId == 0) return matchesRuleId;
          final providerId = rule.productProvider?.id_product_provider;
          return matchesRuleId && providerId == supplierId;
        },
        // orElse: () => null,
      );
    }

    return null;
  }

  /// Remove user from a specific supplier
  Future<bool> removeUserFromSupplier(int userId, int supplierId) async {
    try {
      // Remove from active rules and mappings
      final activeRules = _activeRules[userId];
      if (activeRules != null) {
        activeRules.removeWhere(
            (rule) => rule.productProvider?.id_product_provider == supplierId);

        if (activeRules.isEmpty) {
          _activeRules.remove(userId);
        }
      }

      // Remove from pending rules
      final pendingRules = _pendingRules[userId];
      if (pendingRules != null) {
        pendingRules.removeWhere(
            (rule) => rule.productProvider?.id_product_provider == supplierId);

        if (pendingRules.isEmpty) {
          _pendingRules.remove(userId);
        }
      }

      // Remove from all privileges
      final allPrivileges = _userPrivileges[userId];
      if (allPrivileges != null) {
        allPrivileges.removeWhere(
            (rule) => rule.productProvider?.id_product_provider == supplierId);

        if (allPrivileges.isEmpty) {
          _userPrivileges.remove(userId);
        }
      }

      // Clean up dual-direction mappings
      _cleanupSupplierMapping(userId, supplierId);

      // Update filtered list
      _filteredPersonnel = _getActiveUsersForSupplier(supplierId);
      final pending = _getPendingUsersForSupplier(supplierId);
      _filteredPersonnel.addAll(pending.where((user) =>
          !_filteredPersonnel.any((u) => u.id_app_user == user.id_app_user)));

      notifyListeners();
      return true;
    } catch (e) {
      log('Error removing user from supplier: $e');
      return false;
    }
  }

  /// Search personnel with privilege-aware filtering
  Future<void> searchPersonnel(String query, int userId,
      {int supplierId = 0}) async {
    _searchQuery = query.trim();
    _searchResults = []; // Clear previous search results

    // Don't modify _filteredPersonnel at all
    if (_searchQuery.isEmpty) {
      notifyListeners();
      return;
    }

    // Server-side search for more comprehensive results
    _isLoading = true;
    notifyListeners();

    try {
      final searchResults = await _userService.searchAppUsers(
        _searchQuery,
        0,
        _itemsPerPage,
      );

      if (searchResults != null && searchResults.isNotEmpty) {
        _searchResults = searchResults; // Store only in search results

        // Optionally: fetch privileges for search results without storing in main cache
        for (final user in searchResults) {
          if (user.id_app_user == null) continue;

          // Only fetch to check if user is already in the team
          try {
            final userRules = await _userService.getManagementRules(
              0, // org
              supplierId,
              userId,
              0, // page start
              _itemsPerPage,
            );

            // Store user in cache temporarily (optional)
            _userCache[user.id_app_user!] = user;
          } catch (e) {
            if (kDebugMode) {
              log('Error checking user ${user.id_app_user}: $e', error: e);
            }
          }
        }
      }

      _error = null;
    } catch (e) {
      _error = 'Search failed: ${e.toString()}';
      if (kDebugMode) {
        log('Error searching personnel: $e', error: e);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get statistics for specific supplier
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

  /// Get global statistics (across all suppliers, no duplicates)
  Map<String, int> getGlobalStats() {
    final activeUserIds = <int>{};
    final pendingUserIds = <int>{};

    for (final userIds in _supplierPersonnelMappings.values) {
      activeUserIds.addAll(userIds);
    }

    for (final entry in _pendingRules.entries) {
      pendingUserIds.add(entry.key);
    }

    final activeUsers = activeUserIds
        .map((userId) => _userCache[userId])
        .whereType<AppUser>()
        .toList();

    final pendingUsers = pendingUserIds
        .where((userId) => !activeUserIds.contains(userId))
        .map((userId) => _userCache[userId])
        .whereType<AppUser>()
        .toList();

    final admins = activeUsers.where((user) => user.isAdmin).length;
    final managers = activeUsers
        .where((user) =>
            user.app_user_type_desc?.toLowerCase().contains('manager') ?? false)
        .length;

    return {
      'totalActiveUsers': activeUsers.length,
      'totalPendingUsers': pendingUsers.length,
      'totalSuppliers': _supplierPersonnelMappings.length,
      'admins': admins,
      'managers': managers,
    };
  }

  // Unimplemented methods (stubs for future implementation)
  Future<bool> updateUserPrivileges(
    AppUser user,
    List<ManagementRule> newPrivileges, {
    int supplierId = 0,
  }) async {
    throw UnimplementedError('updateUserPrivileges not implemented');
  }

  Future<bool> removeTeamMember(AppUser user, {int supplierId = 0}) async {
    throw UnimplementedError('removeTeamMember not implemented');
  }

  Future<bool> inviteUser(String email, String role,
      {int supplierId = 0}) async {
    throw UnimplementedError('inviteUser not implemented');
  }

  Future<AppUser?> getUserById(int userId, {bool forceRefresh = false}) async {
    throw UnimplementedError('getUserById not implemented');
  }

  Future<bool> updateUserProfile(AppUser user) async {
    throw UnimplementedError('updateUserProfile not implemented');
  }
}
