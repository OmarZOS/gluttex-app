import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/app/ManagementRule.dart';
import 'package:gluttex_core/app/Person.dart';
import 'package:gluttex_core/app/Services/UserService.dart';
import 'package:gluttex_core/business/finance/Customer.dart';
import 'package:gluttex_core/business/privileges/role_bit_mapper.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:locator/locator.dart';

class PersonnelNotifier with ChangeNotifier {
  // Dependencies
  final AppUserService _userService;
  final StorageService _storageService;

  // Cache constants
  static const int _itemsPerPage = 50;
  static const int _debounceDelayMs = 50;
  static const int _searchDebounceDelayMs = 300;

  // Main data stores
  final Map<int, AppUser> _userCache = {};
  final Map<int, List<ManagementRule>> _userPrivileges = {};
  final Map<int, List<ManagementRule>> _pendingRules = {};
  final Map<int, List<ManagementRule>> _activeRules = {};
  final Map<int, List<int>> _userSupplierMappings = {};
  final Map<int, List<int>> _supplierPersonnelMappings = {};

  // Search state
  List<AppUser> _filteredPersonnel = [];
  List<AppUser> _searchResults = [];
  List<Person> _personSearchResults = [];
  List<AppUser> _personnel = [];

  // State variables
  bool _isLoading = false;
  String _searchQuery = '';
  String? _error;
  int _currentPage = 0;
  bool _hasMore = true;
  Timer? _debounceTimer;
  bool _isRebuildingState = false;
  bool _isDisposed = false;
  Completer<void>? _currentLoadOperation;

  // Response tracking
  final Map<String, CallerResponse> _operationResponses = {};

  // ==================== Constructor ====================

  PersonnelNotifier({
    AppUserService? userService,
    StorageService? storageService,
  })  : _userService = userService ?? AppLocator.get<AppUserService>(),
        _storageService = storageService ?? AppLocator.get<StorageService>();

  // ==================== Response Tracking Helpers ====================

  String _generateCallerKey(String operation, {String? id, String? suffix}) {
    final parts = [operation];
    if (id != null) parts.add(id);
    if (suffix != null) parts.add(suffix);
    parts.add(DateTime.now().millisecondsSinceEpoch.toString());
    return parts.join('_');
  }

  void _storeSuccessResponse(String callerKey, dynamic data,
      {int? statusCode, String? responseCode, String? message}) {
    _storageService.setSuccessResponse(callerKey, data,
        statusCode: statusCode ?? 200, responseCode: responseCode);
    _operationResponses[callerKey] = CallerResponse.success(
      data,
      statusCode: statusCode ?? 200,
      responseCode: responseCode,
    );
    debugPrint(
        '✅ PersonnelNotifier Stored SUCCESS: $callerKey - $responseCode');
  }

  void _storeFailureResponse(String callerKey, dynamic data,
      {int? statusCode,
      String? errorCode,
      String? message,
      String? responseCode}) {
    _storageService.setFailureResponse(callerKey,
        data: data,
        statusCode: statusCode ?? 500,
        errorCode: errorCode,
        message: message,
        responseCode: responseCode);
    _operationResponses[callerKey] = CallerResponse.failure(
      data: data,
      statusCode: statusCode ?? 500,
      errorCode: errorCode,
      message: message,
      responseCode: responseCode,
    );
    debugPrint(
        '❌ PersonnelNotifier Stored FAILURE: $callerKey - $responseCode');
  }

  // ==================== Response Retrieval Methods ====================

  CallerResponse? getResponse(String callerKey) {
    return _operationResponses[callerKey] ??
        _storageService.getResponse(callerKey);
  }

  bool isSuccess(String callerKey) {
    return _storageService.isCallerSuccess(callerKey);
  }

  dynamic getResponseData(String callerKey) {
    return _storageService.getResponseData(callerKey);
  }

  int? getStatusCode(String callerKey) {
    return _storageService.getStatusCode(callerKey);
  }

  String? getResponseCode(String callerKey) {
    return _storageService.getResponseCode(callerKey);
  }

  String? getErrorMessage(String callerKey) {
    return _storageService.getErrorMessage(callerKey);
  }

  void clearResponse(String callerKey) {
    _operationResponses.remove(callerKey);
    _storageService.clearResponse(callerKey);
  }

  void clearAllResponses() {
    _operationResponses.clear();
    _storageService.clearAllResponses();
  }

  // ==================== Getters ====================

  List<AppUser> get personnel => _personnel;
  List<AppUser> get searchResults => _searchResults;
  List<Person> get personSearchResults => _personSearchResults;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get error => _error;
  bool get hasMore => _hasMore;

  int get totalCount {
    final uniqueUserIds = <int>{};
    for (final userIds in _supplierPersonnelMappings.values) {
      uniqueUserIds.addAll(userIds);
    }
    return uniqueUserIds.length;
  }

  // ==================== Public Methods ====================

  Future<Customer?> getCustomerDisplayInfo({
    required int customerId,
    required String customerType,
    int? personId,
    String? callerKey,
  }) async {
    final key = callerKey ??
        _generateCallerKey('getCustomerDisplayInfo', id: customerId.toString());

    try {
      if (customerType == 'user') {
        final user = await _userService.getAppUser(customerId.toString());
        if (user != null) {
          _storeSuccessResponse(key, user, responseCode: 'USER_FOUND');
          return Customer.fromUser(user);
        }
      } else if (customerType == 'person' && personId != null) {
        final person = await _userService.getPerson(personId.toString());
        if (person != null) {
          _storeSuccessResponse(key, person, responseCode: 'PERSON_FOUND');
          return Customer.fromPerson(person);
        }
      } else {
        final customer = Customer.fromJson({
          'name': 'Customer #$customerId',
          'type': customerType,
          'email': '',
        });
        _storeSuccessResponse(key, customer, responseCode: 'DEFAULT_CUSTOMER');
        return customer;
      }

      _storeFailureResponse(key, null,
          statusCode: 404, responseCode: 'CUSTOMER_NOT_FOUND');
      return null;
    } catch (e) {
      _storeFailureResponse(key, e.toString(),
          statusCode: 500, responseCode: 'CUSTOMER_FETCH_ERROR');
      debugPrint('Error fetching customer info: $e');
      return null;
    }
  }

  List<AppUser> getPersonnelForSupplier(int supplierId,
      {bool includePending = false}) {
    final activeUsers = _getActiveUsersForSupplier(supplierId);
    if (!includePending) return activeUsers;

    final pendingUsers = _getPendingUsersForSupplier(supplierId);
    if (pendingUsers.isEmpty) return activeUsers;

    final activeIds = activeUsers.map((user) => user.id_app_user ?? 0).toSet();
    final allUsers = List<AppUser>.from(activeUsers);

    for (final user in pendingUsers) {
      if (!activeIds.contains(user.id_app_user)) {
        allUsers.add(user);
      }
    }

    return allUsers;
  }

  List<ManagementRule> getPendingRulesForUser(int userId,
      {int supplierId = 0}) {
    final rules = _pendingRules[userId];
    if (rules == null) return const [];
    if (supplierId == 0) return List.from(rules);

    return rules
        .where(
            (rule) => rule.productProvider?.id_product_provider == supplierId)
        .toList();
  }

  List<ManagementRule> getRulesForUser(int userId, {int supplierId = 0}) {
    final rules = _activeRules[userId];
    if (rules == null) return const [];
    if (supplierId == 0) return List.from(rules);

    return rules
        .where(
            (rule) => rule.productProvider?.id_product_provider == supplierId)
        .toList();
  }

  bool hasPendingRulesForSupplier(int userId, int supplierId) {
    final rules = _pendingRules[userId];
    if (rules == null) return false;

    return rules
        .any((rule) => rule.productProvider?.id_product_provider == supplierId);
  }

  ManagementRule? getRuleForUser({
    required int userId,
    int ruleId = 0,
    int supplierId = 0,
  }) {
    final rules = _userPrivileges[userId];
    if (rules == null) return null;

    return rules.firstWhere(
      (rule) {
        final matchesRuleId = ruleId == 0 || rule.id_management_rule == ruleId;
        final matchesSupplier = supplierId == 0 ||
            rule.productProvider?.id_product_provider == supplierId;
        return matchesRuleId && matchesSupplier;
      },
    );
  }

  bool hasPrivilege(int userId, int supplierId, String privilegeId) {
    final rules = getRulesForUser(userId, supplierId: supplierId);
    return rules.any((rule) => RoleBitMapper.hasPrivilege(
        rule.management_rule_code ?? 0, privilegeId));
  }

  bool hasAnyAccessToSupplier(int userId, int supplierId) {
    final rules = getRulesForUser(userId, supplierId: supplierId);
    return rules.isNotEmpty;
  }

  List<int> getAccessibleSupplierIds(int userId) {
    final rules = getRulesForUser(userId);
    return rules
        .map((rule) => rule.productProvider?.id_product_provider)
        .where((id) => id != null && id > 0)
        .cast<int>()
        .toSet()
        .toList();
  }

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

  // ==================== Rule Management ====================

  Future<bool> answerInvitation({
    required int ruleId,
    required int answer,
    String? callerKey,
  }) async {
    final key = callerKey ??
        _generateCallerKey('answerInvitation', id: ruleId.toString());

    try {
      debugPrint('Answering invitation for ruleId: $ruleId, answer: $answer');

      // Make the API call and capture the response
      final result = await _storageService.update(
        "${GluttexConstants.apiBaseUrl}${GluttexConstants.answerStaffInvitationEndpoint}",
        ruleId.toString(),
        {"accept": answer == 0},
        {},
        callerKey: key,
      );

      final statusCode = _storageService.getStatusCode(key);
      final responseCode = _storageService.getResponseCode(key);
      final errorMessage = _storageService.getErrorMessage(key);

      // Check if the API call failed
      if (statusCode != null && (statusCode < 200 || statusCode >= 300)) {
        debugPrint(
            'API returned error: $statusCode - $responseCode - $errorMessage');
        _storeFailureResponse(key, result,
            statusCode: statusCode,
            responseCode: responseCode ?? 'API_ERROR',
            message: errorMessage ?? 'Failed to answer invitation');
        return false;
      }

      final findResult = _findRuleAndUserId(ruleId);
      if (findResult == null) {
        debugPrint("Rule $ruleId not found in privileges");
        _storeFailureResponse(key, null,
            statusCode: statusCode ?? 404,
            responseCode: responseCode ?? 'RULE_NOT_FOUND',
            message: 'Rule not found');
        return false;
      }

      final (targetRule, targetUserId) = findResult;
      final supplierId = targetRule.productProvider?.id_product_provider;
      final pendingList = _pendingRules[targetUserId];

      if (pendingList == null) {
        _storeFailureResponse(key, null,
            statusCode: statusCode ?? 404,
            responseCode: 'NO_PENDING_RULES',
            message: 'No pending rules found for user');
        return false;
      }

      final index = pendingList.indexWhere((r) =>
          r.id_management_rule == ruleId &&
          r.productProvider?.id_product_provider == supplierId);

      if (index == -1) {
        debugPrint("Rule $ruleId not found in pending list");
        _storeFailureResponse(key, null,
            statusCode: statusCode ?? 404,
            responseCode: 'RULE_NOT_IN_PENDING',
            message: 'Rule not found in pending list');
        return false;
      }

      if (answer == 0) {
        await _acceptInvitation(
            targetUserId, pendingList, index, targetRule, supplierId);
      } else {
        _rejectInvitation(targetUserId, pendingList, index, ruleId);
      }

      _storeSuccessResponse(key, true,
          statusCode: statusCode ?? 200,
          responseCode: responseCode ?? 'INVITATION_ANSWERED',
          message: 'Invitation answered successfully');
      _scheduleNotifyListeners();
      return true;
    } catch (e, st) {
      debugPrint("Error answering invitation: $e");
      final statusCode = _storageService.getStatusCode(key);
      final responseCode = _storageService.getResponseCode(key);
      final errorMessage = _storageService.getErrorMessage(key);

      _storeFailureResponse(key, e.toString(),
          statusCode: statusCode ?? 500,
          errorCode: responseCode ?? 'ANSWER_INVITATION_ERROR',
          message: errorMessage ?? e.toString(),
          responseCode: responseCode ?? 'INVITATION_ERROR');
      return false;
    }
  }

  Future<bool> addTeamMember(
    int userId, {
    int supplierId = 0,
    int orgId = 0,
    int privilege = 0,
    bool fromQR = false,
    String? callerKey,
  }) async {
    final key =
        callerKey ?? _generateCallerKey('addTeamMember', id: userId.toString());

    if (_isLoading) {
      _storeFailureResponse(key, null,
          statusCode: 429, responseCode: 'ALREADY_LOADING');
      return false;
    }

    _setLoading(true);

    try {
      await _userService.addUserToSupplier(
        userId,
        supplierId,
        orgId,
        privilege,
        fromQR: fromQR,
        callerKey: key,
      );

      final statusCode = _storageService.getStatusCode(key);
      final responseCode = _storageService.getResponseCode(key);

      _storeSuccessResponse(key, true,
          statusCode: statusCode ?? 200,
          responseCode: responseCode ?? 'TEAM_MEMBER_ADDED');
      return true;
    } catch (e) {
      _setError('Failed to add team member: ${e.toString()}');
      _storeFailureResponse(key, e.toString(),
          statusCode: 500,
          errorCode: 'ADD_TEAM_MEMBER_ERROR',
          responseCode: 'ADD_TEAM_MEMBER_FAILED');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateTeamMemberPrivileges({
    required int ruleId,
    required int userId,
    required int supplierId,
    required int orgId,
    required int privilege,
    String? callerKey,
  }) async {
    final key = callerKey ??
        _generateCallerKey('updateTeamMemberPrivileges', id: ruleId.toString());

    if (_isLoading) {
      _storeFailureResponse(key, null,
          statusCode: 429, responseCode: 'ALREADY_LOADING');
      return false;
    }

    _setLoading(true);

    try {
      final updatedRule = await _userService.updateManagementRule(
        ruleId,
        userId,
        supplierId,
        orgId,
        privilege,
        callerKey: key,
      );

      final statusCode = _storageService.getStatusCode(key);
      final responseCode = _storageService.getResponseCode(key);

      if (updatedRule == null) {
        debugPrint("updateManagementRule returned null");
        _storeFailureResponse(key, null,
            statusCode: statusCode ?? 500,
            responseCode: responseCode ?? 'UPDATE_RULE_NULL');
        return false;
      }

      syncRuleState(updatedRule);
      _storeSuccessResponse(key, updatedRule,
          statusCode: statusCode ?? 200,
          responseCode: responseCode ?? 'PRIVILEGES_UPDATED');
      return true;
    } catch (e) {
      _setError('Failed to update team member privileges: ${e.toString()}');
      _storeFailureResponse(key, e.toString(),
          statusCode: 500,
          errorCode: 'UPDATE_PRIVILEGES_ERROR',
          responseCode: 'UPDATE_PRIVILEGES_FAILED');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> removeUserFromSupplier(
    int ruleId,
    int userId,
    int supplierId, {
    String? callerKey,
  }) async {
    final key = callerKey ??
        _generateCallerKey('removeUserFromSupplier', id: ruleId.toString());

    // Remove rule from master list
    final privileges = _userPrivileges[userId];
    if (privileges != null) {
      privileges.removeWhere((r) => r.id_management_rule == ruleId);
      if (privileges.isEmpty) {
        _userPrivileges.remove(userId);
      }
    }

    _rebuildUserState(userId);
    _scheduleNotifyListeners();

    try {
      await _userService.deleteManagementRule(ruleId, callerKey: key);
      final statusCode = _storageService.getStatusCode(key);
      final responseCode = _storageService.getResponseCode(key);

      _storeSuccessResponse(key, true,
          statusCode: statusCode ?? 200,
          responseCode: responseCode ?? 'USER_REMOVED');
      return true;
    } catch (e) {
      _storeFailureResponse(key, e.toString(),
          statusCode: 500,
          errorCode: 'REMOVE_USER_ERROR',
          responseCode: 'REMOVE_USER_FAILED');
      return false;
    }
  }

  void syncRuleState(ManagementRule updatedRule) {
    final ruleId = updatedRule.id_management_rule;
    final userId = updatedRule.appUser?.id_app_user;

    if (ruleId == null || userId == null) return;
    if (_isRebuildingState) return;

    _isRebuildingState = true;

    try {
      // Update central source
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

      _rebuildUserState(userId);
      _scheduleNotifyListeners();
    } finally {
      _isRebuildingState = false;
    }
  }

  // ==================== Search Methods ====================

  void clearSearch({int supplierId = 0}) {
    _searchQuery = '';
    _searchResults = [];
    _personnel = _getActiveUsersForSupplier(supplierId);
    _personSearchResults = [];
    _error = null;
    notifyListeners();
  }

  Future<void> searchPersonnel(String query, {int supplierId = 0}) async {
    final trimmedQuery = query.trim();
    _searchQuery = trimmedQuery;

    _debounceTimer?.cancel();

    if (trimmedQuery.isEmpty) {
      _searchResults = [];
      _personSearchResults = [];
      notifyListeners();
      return;
    }

    _debounceTimer =
        Timer(const Duration(milliseconds: _searchDebounceDelayMs), () async {
      await _performSearch(trimmedQuery, supplierId);
    });
  }

  // ==================== Loading Methods ====================

  Future<void> loadPersonnel({
    int userId = 0,
    bool reset = false,
    int supplierId = 0,
    bool includePending = false,
    String? callerKey,
  }) async {
    final key = callerKey ?? _generateCallerKey('loadPersonnel');

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
      _storeSuccessResponse(key, _personnel, responseCode: 'PERSONNEL_LOADED');
      _currentLoadOperation!.complete();
    } catch (e) {
      _storeFailureResponse(key, e.toString(),
          statusCode: 500, responseCode: 'LOAD_PERSONNEL_ERROR');
      _currentLoadOperation!.completeError(e);
      rethrow;
    } finally {
      _currentLoadOperation = null;
    }
  }

  // ==================== Cache Management ====================

  void logCacheStats() {
    debugPrint('''
    PersonnelNotifier Cache Stats:
    - Users: ${_userCache.length}
    - Privileges: ${_userPrivileges.length}
    - Pending Rules: ${_pendingRules.length}
    - Active Rules: ${_activeRules.length}
    - Supplier Mappings: ${_supplierPersonnelMappings.length}
    - Personnel: ${_personnel.length}
    ''');
  }

  void clearAllCache() {
    _userCache.clear();
    _userPrivileges.clear();
    _pendingRules.clear();
    _activeRules.clear();
    _userSupplierMappings.clear();
    _supplierPersonnelMappings.clear();
    _personnel = [];
    _searchResults = [];
    _currentPage = 0;
    _hasMore = true;
    clearAllResponses();
    notifyListeners();
  }

  // ==================== Lifecycle ====================

  @override
  void dispose() {
    _isDisposed = true;
    _debounceTimer?.cancel();
    _currentLoadOperation?.complete();
    super.dispose();
  }

  // ==================== Private Methods ====================

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    debugPrint('Error: $error');
    notifyListeners();
  }

  List<AppUser> _getActiveUsersForSupplier(int supplierId) {
    if (supplierId == 0) {
      return _activeRules.keys
          .map((userId) => _userCache[userId])
          .whereType<AppUser>()
          .toList();
    }

    final userIds = _supplierPersonnelMappings[supplierId];
    if (userIds == null || userIds.isEmpty) return [];

    return userIds.map((id) => _userCache[id]).whereType<AppUser>().toList();
  }

  List<AppUser> _getPendingUsersForSupplier(int supplierId) {
    final pendingUsers = <AppUser>[];

    for (final entry in _pendingRules.entries) {
      final userId = entry.key;
      final rules = entry.value;

      final hasSupplierRule = rules.any((rule) {
        final providerId = rule.productProvider?.id_product_provider;
        return providerId == supplierId || supplierId == 0;
      });

      if (hasSupplierRule) {
        final user = _userCache[userId];
        if (user != null) pendingUsers.add(user);
      }
    }

    return pendingUsers;
  }

  void _updateUserRule(int userId, ManagementRule updatedRule) {
    final ruleId = updatedRule.id_management_rule;
    if (ruleId == null) return;

    // Update central cache
    final privileges = _userPrivileges[userId] ??= [];
    final existingIndex =
        privileges.indexWhere((r) => r.id_management_rule == ruleId);

    if (existingIndex >= 0) {
      privileges[existingIndex] = updatedRule;
    } else {
      privileges.add(updatedRule);
    }

    // Remove from pending/active
    _pendingRules[userId]?.removeWhere((r) => r.id_management_rule == ruleId);
    _activeRules[userId]?.removeWhere((r) => r.id_management_rule == ruleId);

    // Categorize updated rule
    final isPending =
        updatedRule.ruleStatus?.toUpperCase() == RuleStates.pending;

    if (isPending) {
      (_pendingRules[userId] ??= []).add(updatedRule);
    } else {
      (_activeRules[userId] ??= []).add(updatedRule);

      // Update dual mappings for active rules
      final supplierId = updatedRule.productProvider?.id_product_provider ?? 0;
      if (supplierId > 0) {
        _rebuildUserState(userId);
      }
    }

    _scheduleNotifyListeners();
  }

  void _updateUserRulesBatch(List<ManagementRule> rules) {
    for (final rule in rules) {
      final userId = rule.appUser?.id_app_user;
      if (userId == null) continue;
      _updateUserRule(userId, rule);
    }
  }

  (ManagementRule, int)? _findRuleAndUserId(int ruleId) {
    for (final entry in _userPrivileges.entries) {
      for (final rule in entry.value) {
        if (rule.id_management_rule == ruleId) {
          return (rule, entry.key);
        }
      }
    }
    return null;
  }

  Future<void> _acceptInvitation(
    int targetUserId,
    List<ManagementRule> pendingList,
    int index,
    ManagementRule targetRule,
    int? supplierId,
  ) async {
    final updatedRule =
        pendingList[index].copyWith(ruleStatus: RuleStates.active);

    pendingList.removeAt(index);
    if (pendingList.isEmpty) _pendingRules.remove(targetUserId);

    (_activeRules[targetUserId] ??= []).add(updatedRule);

    // Update master list
    final allRules = _userPrivileges[targetUserId]!;
    final allIndex = allRules.indexWhere(
        (r) => r.id_management_rule == targetRule.id_management_rule);
    if (allIndex != -1) {
      allRules[allIndex] = updatedRule;
    }

    // Update mappings
    if (supplierId != null && supplierId > 0) {
      (_userSupplierMappings[targetUserId] ??= []).add(supplierId);
      (_supplierPersonnelMappings[supplierId] ??= []).add(targetUserId);
    }

    debugPrint(
        "Rule ${targetRule.id_management_rule} ACCEPTED → moved to ACTIVE");
  }

  void _rejectInvitation(int targetUserId, List<ManagementRule> pendingList,
      int index, int ruleId) {
    pendingList.removeAt(index);
    if (pendingList.isEmpty) _pendingRules.remove(targetUserId);

    _userPrivileges[targetUserId]!
        .removeWhere((r) => r.id_management_rule == ruleId);

    if (_userPrivileges[targetUserId]!.isEmpty) {
      _userPrivileges.remove(targetUserId);
    }

    debugPrint("Rule $ruleId REJECTED → removed");
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

  void _cleanupRemovedUsers(Set<int> updatedUserIds, int supplierId) {
    final usersToRemove = <int>[];

    for (final entry in _userPrivileges.entries) {
      final userId = entry.key;
      if (updatedUserIds.contains(userId)) continue;

      final hasSupplierRules = entry.value.any((rule) {
        final providerId = rule.productProvider?.id_product_provider;
        return providerId == supplierId ||
            (supplierId == 0 && providerId != null);
      });

      if (!hasSupplierRules) {
        usersToRemove.add(userId);
      }
    }

    for (final userId in usersToRemove) {
      _cleanupUserFromSupplier(userId, supplierId);
    }
  }

  void _cleanupUserFromSupplier(int userId, int supplierId) {
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

  Future<void> _performSearch(String query, int supplierId) async {
    _setLoading(true);
    _searchResults = [];
    _personSearchResults = [];

    try {
      await Future.wait([
        _searchAppUsers(query, supplierId),
        _searchPeople(query, supplierId),
      ]);
      _error = null;
    } catch (e) {
      _setError('Search failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _searchAppUsers(String query, int supplierId) async {
    try {
      final searchResults =
          await _userService.searchAppUsers(query, 0, _itemsPerPage);
      if (searchResults != null) {
        _searchResults = searchResults;
      }
    } catch (e) {
      debugPrint('Error searching app users: $e');
    }
  }

  Future<void> _searchPeople(String query, int supplierId) async {
    try {
      final peopleResults =
          await _userService.searchPeople(query, 0, _itemsPerPage);
      if (peopleResults != null) {
        _personSearchResults = peopleResults;
      }
    } catch (e) {
      debugPrint('Error searching people: $e');
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
      _resetPagination();
    }

    _setLoading(true);

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
        final updatedUserIds = rules
            .map((rule) => rule.appUser?.id_app_user)
            .where((id) => id != null)
            .cast<int>()
            .toSet();

        _updateUserRulesBatch(rules);

        if (reset && updatedUserIds.isNotEmpty) {
          _cleanupRemovedUsers(updatedUserIds, supplierId);
        }

        _currentPage++;
      }

      _rebuildUserState(userId);
      _error = null;
    } catch (e) {
      _setError('Failed to load personnel: ${e.toString()}');
      log('Error loading personnel: $e',
          error: e, stackTrace: StackTrace.current);
    } finally {
      _setLoading(false);
    }
  }

  void _resetPagination() {
    _currentPage = 0;
    _personnel = [];
    _searchResults = [];
    _hasMore = true;
    _error = null;
  }

  void _scheduleNotifyListeners() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: _debounceDelayMs), () {
      if (!_isDisposed) {
        notifyListeners();
      }
    });
  }
}
