import 'package:event/TraceableNotifier.dart';
import 'package:event/components/personnel/personnel_cache.dart';
import 'package:event/components/personnel/personnel_crud.dart';
import 'package:event/components/personnel/personnel_persistence.dart';
import 'package:event/components/personnel/personnel_rules.dart';
import 'package:event/components/personnel/personnel_search.dart';
import 'package:event/components/personnel/personnel_state.dart';
import 'package:flutter/material.dart';
import 'package:app_constants/app_constants.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/app/ManagementRule.dart';
import 'package:gluttex_core/app/Person.dart';
import 'package:gluttex_core/app/Services/UserService.dart';
import 'package:gluttex_core/business/finance/Customer.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:locator/locator.dart';

class PersonnelNotifier extends TraceableNotifier {
  final AppUserService _userService;
  final StorageService _storageService;

  // Components
  late final PersonnelState _state;
  late final PersonnelCache _cache;
  late final PersonnelPersistence _persistence;
  late final PersonnelRules _rules;
  late final PersonnelSearch _search;
  late final PersonnelCrud _crud;

  PersonnelNotifier({
    AppUserService? userService,
    StorageService? storageService,
  })  : _userService = userService ?? AppLocator.get<AppUserService>(),
        _storageService = storageService ?? AppLocator.get<StorageService>() {
    _initComponents();
    _loadPersistedData();
  }

  void _initComponents() {
    _state = PersonnelState();
    _cache = PersonnelCache();
    _persistence = PersonnelPersistence();
    _rules = PersonnelRules(
      cache: _cache,
      state: _state,
      persistence: _persistence,
    );
    _search = PersonnelSearch(
      userService: _userService,
      cache: _cache,
      state: _state,
    );
    _crud = PersonnelCrud(
      userService: _userService,
      storageService: _storageService,
      cache: _cache,
      state: _state,
      rules: _rules,
      persistence: _persistence,
    );
  }

  Future<void> _loadPersistedData() async {
    await _persistence.load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _notify() {
    if (!_state.isLoading) {
      notifyListeners();
    }
  }

  // ============ PUBLIC GETTERS ============

  List<AppUser> get personnel => _state.personnel;
  List<AppUser> get searchResults => _state.searchResults;
  List<Person> get personSearchResults => _state.personSearchResults;
  bool get isLoading => _state.isLoading;
  String get searchQuery => _state.searchQuery;
  String? get error => _state.error;
  bool get hasMore => _state.hasMore;
  Map<int, List<int>> get accessibleSuppliers => _persistence.all;

  int get totalCount {
    final uniqueUserIds = <int>{};
    for (final userIds in _cache.supplierPersonnelMappings.values) {
      uniqueUserIds.addAll(userIds);
    }
    return uniqueUserIds.length;
  }

  // ============ USER CONTEXT ============

  void setCurrentUserId(int userId) {
    _persistence.setCurrentUser(userId);
  }

  Future<void> clearPersistedData() async {
    await _persistence.clear();
    _cache.clearAll();
    _notify();
  }

  // ============ ACCESSIBLE SUPPLIERS ============

  List<int> getAccessibleSupplierIds(int userId) {
    final persisted = _persistence.getAccessibleSuppliers(userId);
    if (persisted.isNotEmpty) return persisted;

    final rules = _rules.getRulesForUser(userId);
    final supplierIds = rules
        .map((rule) => rule.productProvider?.id_product_provider)
        .where((id) => id != null && id > 0)
        .cast<int>()
        .toSet()
        .toList();

    if (supplierIds.isNotEmpty) {
      _persistence.addSupplier(userId, supplierIds.first);
      for (int i = 1; i < supplierIds.length; i++) {
        _persistence.addSupplier(userId, supplierIds[i]);
      }
    }

    return supplierIds;
  }

  List<int> getPersistedAccessibleSuppliers(int userId) {
    return _persistence.getAccessibleSuppliers(userId);
  }

  // ============ RULES & PRIVILEGES ============

  List<ManagementRule> getRulesForUser(int userId, {int supplierId = 0}) {
    return _rules.getRulesForUser(userId, supplierId: supplierId);
  }

  List<ManagementRule> getPendingRulesForUser(int userId,
      {int supplierId = 0}) {
    return _rules.getPendingRulesForUser(userId, supplierId: supplierId);
  }

  bool hasPrivilege(int userId, int supplierId, String privilegeId) {
    return _rules.hasPrivilege(userId, supplierId, privilegeId);
  }

  bool hasAnyAccessToSupplier(int userId, int supplierId) {
    return _rules.hasAnyAccessToSupplier(userId, supplierId);
  }

  bool hasPendingRulesForSupplier(int userId, int supplierId) {
    return _rules.hasPendingRulesForSupplier(userId, supplierId);
  }

  ManagementRule? getRuleForUser({
    required int userId,
    int ruleId = 0,
    int supplierId = 0,
  }) {
    return _rules.getRuleForUser(
      userId: userId,
      ruleId: ruleId,
      supplierId: supplierId,
    );
  }

  Map<String, int> getSupplierStats(int supplierId) {
    return _rules.getSupplierStats(supplierId);
  }

  void syncRuleState(ManagementRule updatedRule) {
    _rules.syncRuleState(updatedRule);
    _notify();
  }

  // ============ PERSONNEL ============

  List<AppUser> getPersonnelForSupplier(int supplierId,
      {bool includePending = false}) {
    final activeUsers = _getActiveUsersForSupplier(supplierId);
    if (!includePending) return activeUsers;

    final pendingUsers = _getPendingUsersForSupplier(supplierId);
    if (pendingUsers.isEmpty) return activeUsers;

    final activeIds = activeUsers.map((user) => user.idAppUser ?? 0).toSet();
    final allUsers = List<AppUser>.from(activeUsers);

    for (final user in pendingUsers) {
      if (!activeIds.contains(user.idAppUser)) {
        allUsers.add(user);
      }
    }

    return allUsers;
  }

  List<AppUser> _getActiveUsersForSupplier(int supplierId) {
    if (supplierId == 0) {
      return _cache.activeRules.keys
          .map((userId) => _cache.getUser(userId))
          .whereType<AppUser>()
          .toList();
    }

    final userIds = _cache.getActiveUserIdsForSupplier(supplierId);
    return userIds
        .map((id) => _cache.getUser(id))
        .whereType<AppUser>()
        .toList();
  }

  List<AppUser> _getPendingUsersForSupplier(int supplierId) {
    final pendingUsers = <AppUser>[];

    for (final entry in _cache.pendingRules.entries) {
      final userId = entry.key;
      final rules = entry.value;

      final hasSupplierRule = rules.any((rule) {
        final providerId = rule.productProvider?.id_product_provider;
        return providerId == supplierId || supplierId == 0;
      });

      if (hasSupplierRule) {
        final user = _cache.getUser(userId);
        if (user != null) pendingUsers.add(user);
      }
    }

    return pendingUsers;
  }

  // ============ CUSTOMER ============

  Future<Customer?> getCustomerDisplayInfo({
    required int customerId,
    required String customerType,
    int? personId,
    String? callerKey,
  }) async {
    final key = callerKey ??
        _generateKey('getCustomerDisplayInfo', id: customerId.toString());

    try {
      if (customerType == 'user') {
        final user = await _userService.getAppUser(customerId.toString());
        if (user != null) {
          _storeSuccess(key, user, responseCode: 'USER_FOUND');
          return Customer.fromUser(user);
        }
      } else if (customerType == 'person' && personId != null) {
        final person = await _userService.getPerson(personId.toString());
        if (person != null) {
          _storeSuccess(key, person, responseCode: 'PERSON_FOUND');
          return Customer.fromPerson(person);
        }
      } else {
        final customer = Customer.fromJson({
          'name': 'Customer #$customerId',
          'type': customerType,
          'email': '',
        });
        _storeSuccess(key, customer, responseCode: 'DEFAULT_CUSTOMER');
        return customer;
      }

      _storeFailure(key, null,
          statusCode: 404, responseCode: 'CUSTOMER_NOT_FOUND');
      return null;
    } catch (e) {
      _storeFailure(key, e.toString(), responseCode: 'CUSTOMER_FETCH_ERROR');
      debugPrint('Error fetching customer info: $e');
      return null;
    }
  }

  // ============ TEAM MANAGEMENT ============

  Future<bool> addTeamMember(
    int userId, {
    int supplierId = 0,
    int orgId = 0,
    int privilege = 0,
    bool fromQR = false,
    String? callerKey,
  }) async {
    final result = await _crud.addTeamMember(
      userId,
      supplierId: supplierId,
      orgId: orgId,
      privilege: privilege,
      fromQR: fromQR,
      callerKey: callerKey,
    );
    _notify();
    return result;
  }

  Future<bool> updateTeamMemberPrivileges({
    required int ruleId,
    required int userId,
    required int supplierId,
    required int orgId,
    required int privilege,
    String? callerKey,
  }) async {
    final result = await _crud.updatePrivileges(
      ruleId: ruleId,
      userId: userId,
      supplierId: supplierId,
      orgId: orgId,
      privilege: privilege,
      callerKey: callerKey,
    );
    _notify();
    return result;
  }

  Future<bool> removeUserFromSupplier(
    int ruleId,
    int userId,
    int supplierId, {
    String? callerKey,
  }) async {
    final result = await _crud.removeUserFromSupplier(
      ruleId,
      userId,
      supplierId,
      callerKey: callerKey,
    );
    _notify();
    return result;
  }

  // ============ SEARCH ============

  void clearSearch({int supplierId = 0}) {
    _search.clear(supplierId: supplierId);
    _notify();
  }

  Future<void> searchPersonnel(String query, {int supplierId = 0}) async {
    await _search.search(query, supplierId: supplierId);
    _notify();
  }

  // ============ LOADING ============

  Future<void> loadPersonnel({
    int userId = 0,
    bool reset = false,
    int supplierId = 0,
    bool includePending = false,
    String? callerKey,
  }) async {
    final key = callerKey ?? _generateKey('loadPersonnel');

    if (_state.isLoading && !reset) return;

    if (reset) {
      _state.resetPagination();
    }

    _state.setLoading(true);

    try {
      final rules = await _userService.getManagementRules(
        0,
        supplierId,
        userId,
        _state.currentPage * 50,
        50,
      );

      if (rules == null || rules.isEmpty) {
        _state.hasMore = false;
      } else {
        for (final rule in rules) {
          final ruleUserId = rule.appUser?.idAppUser;
          if (ruleUserId == null) continue;
          _rules.syncRuleState(rule);
        }
        _state.currentPage++;
      }

      _state.setError(null);
      _storeSuccess(key, _state.personnel, responseCode: 'PERSONNEL_LOADED');
    } catch (e) {
      _state.setError('Failed to load personnel: ${e.toString()}');
      _storeFailure(key, e.toString(), responseCode: 'LOAD_PERSONNEL_ERROR');
    } finally {
      _state.setLoading(false);
      _notify();
    }
  }

  // ============ CACHE MANAGEMENT ============

  void clearAllCache() {
    _cache.clearAll();
    _state.reset();
    _notify();
  }

  void logCacheStats() {
    final stats = _cache.getStats();
    debugPrint('''
    PersonnelNotifier Cache Stats:
    - Users: ${stats['users']}
    - Privileges: ${stats['privileges']}
    - Pending Rules: ${stats['pendingRules']}
    - Active Rules: ${stats['activeRules']}
    - Supplier Mappings: ${stats['supplierMappings']}
    - Personnel: ${_state.personnel.length}
    - Persisted Suppliers: ${_persistence.all.length}
    ''');
  }

  // ============ HELPERS ============

  String _generateKey(String operation, {String? id, String? suffix}) {
    final parts = [operation];
    if (id != null) parts.add(id);
    if (suffix != null) parts.add(suffix);
    parts.add(DateTime.now().millisecondsSinceEpoch.toString());
    return parts.join('_');
  }

  void _storeSuccess(String key, data,
      {int? statusCode, String? responseCode}) {
    _storageService.setSuccessResponse(key, data,
        statusCode: statusCode ?? 200, responseCode: responseCode);
  }

  void _storeFailure(String key, data,
      {int? statusCode, String? responseCode}) {
    _storageService.setFailureResponse(key,
        data: data,
        statusCode: statusCode ?? 500,
        errorCode: responseCode,
        message: data.toString());
  }

  // ============ RESET ============

  void reset() {
    _state.reset();
    _cache.clearAll();
    _notify();
  }
  // ============ INVITATION MANAGEMENT ============

  Future<bool> answerInvitation({
    required int ruleId,
    required int answer,
    String? callerKey,
  }) async {
    final key =
        callerKey ?? _generateKey('answerInvitation', id: ruleId.toString());

    try {
      // Delegate to crud
      final result = await _crud.answerInvitation(
        ruleId: ruleId,
        answer: answer,
        callerKey: key,
      );
      _notify();
      return result;
    } catch (e) {
      _storeFailure(key, e.toString(), responseCode: 'ANSWER_INVITATION_ERROR');
      return false;
    }
  }
}
