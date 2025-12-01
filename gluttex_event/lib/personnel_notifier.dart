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

  List<AppUser> _personnel = [];
  List<AppUser> _filteredPersonnel = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _error;
  int _currentPage = 0;
  static const int _itemsPerPage = 50;
  bool _hasMore = true;

  // Cache for user-supplier mappings and privileges
  final Map<int, List<int>> _userSupplierMappings = {}; // userId -> supplierIds
  final Map<int, List<ManagementRule>> _userPrivileges =
      {}; // userId -> privileges

  List<AppUser> get personnel => _filteredPersonnel;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get error => _error;
  bool get hasMore => _hasMore;
  int get totalCount => _personnel.length;

  /// Load personnel with pagination support, including privilege mappings
  Future<void> loadPersonnel(int userId,
      {bool reset = false, int supplierId = 0}) async {
    if (_isLoading && !reset) return;

    if (reset) {
      _currentPage = 0;
      _personnel.clear();
      _filteredPersonnel.clear();
      _userSupplierMappings.clear();
      _userPrivileges.clear();
      _hasMore = true;
      _error = null;
    }

    if (!_hasMore && !reset) {
      _filteredPersonnel = _getUsersForSupplier(supplierId);
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

          // Check if user already exists
          final existingIndex = _personnel.indexWhere(
            (u) => u.id_app_user == user.id_app_user,
          );

          if (existingIndex != -1) {
            // Update existing user's privileges
            _personnel[existingIndex] = user;
          } else {
            // Add new user
            _personnel.add(user);
          }

          // Store privilege
          final userIdKey = user.id_app_user ?? 0;
          _userPrivileges[userIdKey] ??= [];
          if (!_userPrivileges[userIdKey]!.contains(rule)) {
            _userPrivileges[userIdKey]!.add(rule);
          }

          // Update supplier mappings
          final providerId = rule.productProvider?.id_product_provider;
          if (providerId != null) {
            _userSupplierMappings[userIdKey] ??= [];
            if (!_userSupplierMappings[userIdKey]!.contains(providerId)) {
              _userSupplierMappings[userIdKey]!.add(providerId);
            }
          }
        }

        _currentPage++;
      }

      // Filter personnel by supplier
      _filteredPersonnel = _getUsersForSupplier(supplierId);
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

  /// Search personnel with privilege-aware filtering
  Future<void> searchPersonnel(String query, int userId,
      {int supplierId = 0}) async {
    _searchQuery = query.trim();

    // First filter locally for immediate response
    if (_searchQuery.isEmpty) {
      _filteredPersonnel = _getUsersForSupplier(supplierId);
      notifyListeners();
      return;
    }

    // Local filtering
    _filteredPersonnel = _getUsersForSupplier(supplierId).where((user) {
      final fullName =
          '${user.personFirstName ?? ''} ${user.personLastName ?? ''}'
              .toLowerCase();
      final userName = user.app_user_name?.toLowerCase() ?? '';
      final location = user.locationName?.toLowerCase() ?? '';
      final role = user.app_user_type_desc?.toLowerCase() ?? '';

      final searchLower = _searchQuery.toLowerCase();
      return fullName.contains(searchLower) ||
          userName.contains(searchLower) ||
          location.contains(searchLower) ||
          role.contains(searchLower);
    }).toList();

    notifyListeners();

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
        // Fetch privileges for new search results
        for (final user in searchResults) {
          if (user.id_app_user == null) continue;

          try {
            // Fetch management rules for this user
            final userRules = await _userService.getManagementRules(
              0, // org
              supplierId,
              userId,
              0, // page start
              _itemsPerPage,
            );

            if (userRules != null) {
              // Store privileges
              _userPrivileges[user.id_app_user!] ??= [];
              for (final rule in userRules) {
                if (!_userPrivileges[user.id_app_user!]!.contains(rule)) {
                  _userPrivileges[user.id_app_user!]!.add(rule);
                }

                // Update supplier mappings
                final providerId = rule.productProvider?.id_product_provider;
                if (providerId != null) {
                  _userSupplierMappings[user.id_app_user!] ??= [];
                  if (!_userSupplierMappings[user.id_app_user!]!
                      .contains(providerId)) {
                    _userSupplierMappings[user.id_app_user!]!.add(providerId);
                  }
                }
              }
            }

            // Update or add user to personnel list
            final existingIndex = _personnel.indexWhere(
              (existing) => existing.id_app_user == user.id_app_user,
            );

            if (existingIndex != -1) {
              _personnel[existingIndex] = user;
            } else {
              _personnel.add(user);
            }
          } catch (e) {
            if (kDebugMode) {
              log('Error processing user ${user.id_app_user}: $e', error: e);
            }
          }
        }

        // Re-filter with updated data
        _filteredPersonnel = _getUsersForSupplier(supplierId).where((user) {
          final fullName =
              '${user.personFirstName ?? ''} ${user.personLastName ?? ''}'
                  .toLowerCase();
          final userName = user.app_user_name?.toLowerCase() ?? '';
          final location = user.locationName?.toLowerCase() ?? '';
          final role = user.app_user_type_desc?.toLowerCase() ?? '';

          final searchLower = _searchQuery.toLowerCase();
          return fullName.contains(searchLower) ||
              userName.contains(searchLower) ||
              location.contains(searchLower) ||
              role.contains(searchLower);
        }).toList();
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

  /// Get users that have access to the specified supplier
  List<AppUser> _getUsersForSupplier(int supplierId) {
    if (supplierId == 0) {
      return List.from(_personnel); // Return copy of all users
    }

    return _personnel.where((user) {
      final userSupplierIds = _userSupplierMappings[user.id_app_user];
      return userSupplierIds?.contains(supplierId) == true;
    }).toList();
  }

  /// Clear search and show all personnel for current supplier
  void clearSearch({int supplierId = 0}) {
    _searchQuery = '';
    _filteredPersonnel = _getUsersForSupplier(supplierId);
    _error = null;
    notifyListeners();
  }

  /// Add team member with privileges
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

      // Check if user already exists
      final existingIndex = _personnel.indexWhere(
        (existing) => existing.id_app_user == addedUser.id_app_user,
      );

      if (existingIndex != -1) {
        _personnel[existingIndex] = addedUser;
      } else {
        _personnel.insert(0, addedUser);
      }

      // Store privilege
      _userPrivileges[userIdKey] ??= [];
      if (!_userPrivileges[userIdKey]!.contains(managementRule)) {
        _userPrivileges[userIdKey]!.add(managementRule);
      }

      // Update supplier mappings
      if (supplierId != 0) {
        _userSupplierMappings[userIdKey] ??= [];
        if (!_userSupplierMappings[userIdKey]!.contains(supplierId)) {
          _userSupplierMappings[userIdKey]!.add(supplierId);
        }
      }

      // Update filtered list
      _filteredPersonnel = _getUsersForSupplier(supplierId);

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

        // Cache the results
        _userPrivileges[userId] = allRules;
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

    return filteredRules.isNotEmpty
        ? filteredRules
        : null; // FIXED: Added return statement
  }

  /// Returns (userId, supplierId) for a given ruleId.
  /// If ruleId = 0 OR rule not found → return null.
  Map<String, int>? getRuleUserAndSupplier(int ruleId) {
    if (ruleId == 0) return null;

    // Iterate through each user's list of rules
    for (final entry in _userPrivileges.entries) {
      final userId = entry.key;
      final rules = entry.value;

      for (final rule in rules) {
        if (rule.id_management_rule == ruleId) {
          final supplierId = rule.productProvider?.id_product_provider ?? 0;

          return {
            "userId": userId,
            "supplierId": supplierId,
          };
        }
      }
    }

    // If no match
    return null;
  }

  /// Answer invitation (accept/reject) and update local state accordingly
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

      // Find the rule in user's privileges
      final data = getRuleUserAndSupplier(ruleId);
      if (data == null) {
        log('Could not find rule $ruleId in cache');
        return false;
      }

      final userId = data["userId"];
      final supplierId = data["supplierId"];

      final userRules = _userPrivileges[userId];
      if (userRules != null && userRules.isNotEmpty) {
        final ruleIndex = userRules.indexWhere((rule) =>
            rule.id_management_rule == ruleId &&
            rule.productProvider?.id_product_provider == supplierId);

        if (ruleIndex != -1) {
          final rule = userRules[ruleIndex];

          if (answer == 0) {
            // ACCEPT
            // Update rule status to active
            final updatedRule = rule.copyWith(
              ruleStatus: RuleStates.active,
            );

            userRules[ruleIndex] = updatedRule;
            log('Updated rule $ruleId to ACTIVE for user $userId');

            // Update in personnel list if this user exists there
            if (userId != null && supplierId != null)
              _updateUserRuleInPersonnel(userId!, supplierId!, updatedRule);
          } else {
            // REJECT
            // Remove the rule from privileges
            userRules.removeAt(ruleIndex);
            log('Removed rule $ruleId for user $userId (rejected)');

            // Remove supplier mapping if this was the only rule for this supplier
            if (userId != null && supplierId != null)
              _cleanupSupplierMapping(userId!, supplierId!);

            // Also remove from personnel list for this supplier
            if (userId != null && supplierId != null)
              _removeUserFromSupplierPersonnel(userId!, supplierId!);
          }

          // Notify listeners about the change
          notifyListeners();
          return true;
        } else {
          log('Rule $ruleId not found in user $userId privileges');
        }
      } else {
        log('No privileges found for user $userId');
      }

      return false;
    } catch (e, stacktrace) {
      log('Error answering invitation: $e');
      log('Stack trace: $stacktrace');
      return false;
    }
  }

  /// Helper: Update rule in personnel list
  void _updateUserRuleInPersonnel(
      int userId, int supplierId, ManagementRule updatedRule) {
    // Find the user in personnel list
    final userIndex =
        _personnel.indexWhere((user) => user.id_app_user == userId);

    if (userIndex != -1) {
      final user = _personnel[userIndex];

      // Update user's role based on new privileges
      final userPrivileges = _userPrivileges[userId] ?? [];
      if (userPrivileges.isNotEmpty) {
        // Update user properties if needed
      }

      // Update filtered personnel if needed
      _filteredPersonnel = _getUsersForSupplier(supplierId);
    }
  }

  /// Helper: Clean up supplier mapping when rule is removed
  void _cleanupSupplierMapping(int userId, int supplierId) {
    final userSupplierIds = _userSupplierMappings[userId];
    if (userSupplierIds != null) {
      // Check if user has any other rules for this supplier
      final userRules = _userPrivileges[userId] ?? [];
      final hasOtherRulesForSupplier = userRules.any(
          (rule) => rule.productProvider?.id_product_provider == supplierId);

      // If no other rules for this supplier, remove the mapping
      if (!hasOtherRulesForSupplier) {
        userSupplierIds.remove(supplierId);
        log('Removed supplier $supplierId mapping for user $userId');

        // If no suppliers left, remove user entry entirely
        if (userSupplierIds.isEmpty) {
          _userSupplierMappings.remove(userId);
        }
      }
    }
  }

  /// Helper: Remove user from filtered personnel for specific supplier
  void _removeUserFromSupplierPersonnel(int userId, int supplierId) {
    // Remove from filtered personnel for this supplier
    _filteredPersonnel =
        _filteredPersonnel.where((user) => user.id_app_user != userId).toList();
  }

  /// Get all suppliers a user has access to
  List<int> getUserSuppliers(int userId) {
    return List.from(_userSupplierMappings[userId] ?? []);
  }

  /// Get personnel for specific supplier
  List<AppUser> getPersonnelForSupplier(int supplierId) {
    return _getUsersForSupplier(supplierId);
  }

  /// Refresh all data for specific supplier context
  Future<void> refresh(int userId, {int supplierId = 0}) async {
    await loadPersonnel(userId, reset: true, supplierId: supplierId);
  }

  /// Clear any error messages
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Get statistics for current supplier context
  Map<String, int> getPersonnelStats({int supplierId = 0}) {
    final supplierUsers = _getUsersForSupplier(supplierId);

    final admins = supplierUsers.where((user) => user.isAdmin).length;
    final managers = supplierUsers
        .where((user) =>
            user.app_user_type_desc?.toLowerCase().contains('manager') ?? false)
        .length;

    return {
      'total': supplierUsers.length,
      'admins': admins,
      'managers': managers,
      'active': supplierUsers.length,
    };
  }

  /// Check if invitation is pending for notification actions
  bool isInvitationPending({
    required int userId,
    required int ruleId,
    int supplierId = 0,
  }) {
    final userRules = _userPrivileges[userId];
    if (userRules == null) return false;

    final rule = userRules.firstWhere(
      (rule) {
        final matchesRuleId = rule.id_management_rule == ruleId;
        if (supplierId == 0) return matchesRuleId;

        final providerId = rule.productProvider?.id_product_provider;
        return matchesRuleId && providerId == supplierId;
      },
      // orElse: () => null,
    );

    return rule?.ruleStatus?.toUpperCase() == RuleStates.pending;
  }

  /// Check if rule is active
  bool isRuleActive({
    required int userId,
    required int ruleId,
    int supplierId = 0,
  }) {
    final userRules = _userPrivileges[userId];
    if (userRules == null) return false;

    final rule = userRules.firstWhere(
      (rule) {
        final matchesRuleId = rule.id_management_rule == ruleId;
        if (supplierId == 0) return matchesRuleId;

        final providerId = rule.productProvider?.id_product_provider;
        return matchesRuleId && providerId == supplierId;
      },
      // orElse: () => null,
    );

    return rule?.ruleStatus?.toUpperCase() == RuleStates.active;
  }

  /// Get specific rule for user
  ManagementRule? getRuleForUser({
    required int userId,
    required int ruleId,
    int supplierId = 0,
  }) {
    final userRules = _userPrivileges[userId];
    if (userRules == null) return null;

    return userRules.firstWhere(
      (rule) {
        final matchesRuleId = rule.id_management_rule == ruleId;
        if (supplierId == 0) return matchesRuleId;

        final providerId = rule.productProvider?.id_product_provider;
        return matchesRuleId && providerId == supplierId;
      },
      // orElse: () => null,
    );
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
