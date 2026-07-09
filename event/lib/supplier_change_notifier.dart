import 'package:event/components/supplier/supplier_cache.dart';
import 'package:event/components/supplier/supplier_crud.dart';
import 'package:event/components/supplier/supplier_filter.dart';
import 'package:event/components/supplier/supplier_location.dart';
import 'package:event/components/supplier/supplier_organisation.dart';
import 'package:event/components/supplier/supplier_persistence.dart';
import 'package:event/components/supplier/supplier_search.dart';
import 'package:event/components/supplier/supplier_state.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:locator/locator.dart';
import 'package:gluttex_core/business/Organisation.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_core/business/services/SupplierService.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupplierChangeNotifier extends ChangeNotifier {
  // Dependencies
  final SupplierService _service = AppLocator.get<SupplierService>();
  final StorageService _storage = AppLocator.get<StorageService>();

  // Components (initialized in constructor)
  late final SupplierCache _cache;
  late final SupplierState _state;
  late final SupplierPersistence _persistence;
  late final SupplierCrud _crud;
  late final SupplierSearch _search;
  late final SupplierLocation _location;
  late final SupplierOrganisation _organisation;

  SupplierChangeNotifier() {
    _initComponents();
    _loadPersistedData();
  }

  void _initComponents() {
    _state = SupplierState();
    _cache = SupplierCache();
    _persistence = SupplierPersistence();
    _crud = SupplierCrud(
      service: _service,
      storage: _storage,
      cache: _cache,
      state: _state,
      persistence: _persistence,
    );
    _search = SupplierSearch(
      service: _service,
      storage: _storage,
      cache: _cache,
      state: _state,
    );
    _location = SupplierLocation(
      storage: _storage,
      state: _state,
    );
    _organisation = SupplierOrganisation(
      service: _service,
      storage: _storage,
      state: _state,
      persistence: _persistence,
      cache: _cache,
    );
  }

  Future<void> _loadPersistedData() async {
    await _persistence.load();
  }

  // ============ PUBLIC GETTERS (DELEGATED) ============

  List<Supplier> get suppliers => _state.suppliers;
  List<Supplier> get filteredSuppliers => _state.filteredSuppliers;
  List<Organisation> get organisations => _state.organisations.values.toList();
  Position? get currentLocation => _state.currentLocation;
  SupplierFilter get filter => _state.filter;
  bool get isLoading => _state.isLoading;
  bool get hasMoreSuppliers => _state.hasMoreSuppliers;
  bool get hasMoreOrganisations => _state.hasMoreOrganisations;
  bool get isCacheEnabled => _cache.isEnabled;

  // Persistence getters
  List<int> get ownedSupplierIds =>
      _persistence.getOwnedSuppliers(_persistence.currentUserId);
  List<int> get ownedOrganisationIds =>
      _persistence.getOwnedOrganisations(_persistence.currentUserId);

  // ============ USER CONTEXT ============

  void setCurrentUserId(int userId) {
    _persistence.setCurrentUser(userId);
  }

  // ============ SUPPLIER OPERATIONS (DELEGATED) ============

  Future<void> fetchSuppliers({
    bool reset = false,
    int? ownerId,
    int? organisationId,
    bool forceRefresh = false,
  }) async {
    if (_state.isLoading || (!reset && !_state.hasMoreSuppliers)) return;

    final cacheKey =
        'suppliers_${ownerId ?? 0}_${organisationId ?? 0}_${_state.suppliersPage}';

    if (!forceRefresh && !reset) {
      final cached = _cache.getList(cacheKey);
      if (cached != null && cached.isNotEmpty) {
        _addSuppliers(cached);
        return;
      }
    }

    if (reset) {
      _state.suppliers.clear();
      _state.suppliersPage = 0;
      _state.hasMoreSuppliers = true;
    }

    _state.isLoading = true;

    try {
      final results = await _service.getAllSuppliers(
        ownerId ?? 0,
        organisationId ?? 0,
        _state.suppliersPage * SupplierState.itemsPerPage,
        SupplierState.itemsPerPage,
      );

      if (!reset) {
        _cache.cacheList(cacheKey, results);
      }

      _addSuppliers(results);
      _state.hasMoreSuppliers = results.length >= SupplierState.itemsPerPage;
      if (_state.hasMoreSuppliers) _state.suppliersPage++;
    } finally {
      _state.isLoading = false;
      notifyListeners();
    }
  }

  Future<Supplier?> getSupplierById(int id, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _cache.getSupplier(id);
      if (cached != null && cached.idProductProvider != 0) return cached;
    }

    _state.isLoading = true;

    try {
      final supplier = await _service.getSupplier(id.toString());
      if (supplier != null && supplier.idProductProvider != 0) {
        _cache.cacheSupplier(supplier);
        _updateSupplierInList(supplier);
      }
      return supplier;
    } finally {
      _state.isLoading = false;
      notifyListeners();
    }
  }

  Future<Supplier> createOrUpdateSupplier(Supplier supplier, String token) =>
      _crud.createOrUpdate(supplier, token).then((result) {
        notifyListeners();
        return result;
      });

  Future<bool> deleteSupplier(int id, String token) =>
      _crud.delete(id, token).then((result) {
        notifyListeners();
        return result;
      });

  // ============ SEARCH OPERATIONS (DELEGATED) ============

  Future<void> searchSuppliers(String query) =>
      _search.search(query).then((_) => notifyListeners());

  Future<void> searchSuppliersByGeo({
    required double longitude,
    required double latitude,
    required double radiusKm,
    bool reset = false,
  }) =>
      _search
          .searchByGeo(
              longitude: longitude,
              latitude: latitude,
              radiusKm: radiusKm,
              reset: reset)
          .then((_) => notifyListeners());

  void clearSearch() {
    _state.filter = const SupplierFilter();
    notifyListeners();
  }

  // ============ LOCATION OPERATIONS (DELEGATED) ============

  Future<Position?> getCurrentLocation() =>
      _location.getCurrentLocation().then((pos) {
        notifyListeners();
        return pos;
      });

  // ============ ORGANISATION OPERATIONS (DELEGATED) ============

  Future<void> fetchOrganisations({bool reset = false}) =>
      _organisation.fetch(reset: reset).then((_) => notifyListeners());

  Future<Organisation?> getOrganisationById(int id) =>
      _organisation.getById(id).then((org) {
        notifyListeners();
        return org;
      });

  Future<Organisation?> createOrganisation(Organisation org, String token) =>
      _organisation.create(org, token).then((result) {
        notifyListeners();
        return result;
      });

  Future<Organisation?> updateOrganisation(Organisation org, String token) =>
      _organisation.update(org, token).then((result) {
        notifyListeners();
        return result;
      });

  Future<bool> deleteOrganisation(int id, String token) =>
      _organisation.delete(id, token).then((result) {
        notifyListeners();
        return result;
      });

  // ============ CACHE MANAGEMENT (DELEGATED) ============

  void enableCaching(bool enable) {
    _cache.enable(enable);
    notifyListeners();
  }

  void invalidateCache({int? supplierId, String? listKey}) {
    _cache.invalidate(supplierId: supplierId, listKey: listKey);
  }

  void refreshAllCaches() {
    _cache.clearAll();
    notifyListeners();
  }

  // ============ PERSISTENCE OPERATIONS (DELEGATED) ============

  Future<void> clearPersistedData() =>
      _persistence.clearAll().then((_) => notifyListeners());

  Future<void> addOwnedSupplier(int userId, int supplierId) => _persistence
      .addSupplier(userId, supplierId)
      .then((_) => notifyListeners());

  Future<void> removeOwnedSupplier(int userId, int supplierId) => _persistence
      .removeSupplier(userId, supplierId)
      .then((_) => notifyListeners());

  Future<void> addOwnedOrganisation(int userId, int orgId) => _persistence
      .addOrganisation(userId, orgId)
      .then((_) => notifyListeners());

  Future<void> removeOwnedOrganisation(int userId, int orgId) => _persistence
      .removeOrganisation(userId, orgId)
      .then((_) => notifyListeners());

  // ============ HELPERS ============

  void _addSuppliers(List<Supplier> newSuppliers) {
    final existing = _state.suppliers.map((s) => s.idProductProvider).toSet();
    for (final supplier in newSuppliers) {
      if (!existing.contains(supplier.idProductProvider)) {
        _state.suppliers.add(supplier);
        _cache.cacheSupplier(supplier);
      }
    }
  }

  void _updateSupplierInList(Supplier supplier) {
    final index = _state.suppliers
        .indexWhere((s) => s.idProductProvider == supplier.idProductProvider);
    if (index != -1) {
      _state.suppliers[index] = supplier;
    }
  }

  // ============ STATE RESET ============

  void reset() {
    _state.reset();
    _cache.clearAll();
    notifyListeners();
  }

  // ============ CACHE STATS ============

  CacheStats getCacheStats() {
    return CacheStats(
      detailedCacheSize: _cache.detailedCacheSize,
      lruCacheSize: _cache.lruCacheSize,
      listCacheSize: _cache.listCacheSize,
      suppliersCount: _state.suppliers.length,
      organisationsCount: _state.organisations.length,
      cacheEnabled: _cache.isEnabled,
      cacheTTLSeconds: 300,
      hits: _cache.hits,
      misses: _cache.misses,
    );
  }

  // ============ RESPONSE RETRIEVAL ============

  CallerResponse? getResponse(String callerKey) {
    return _storage.getResponse(callerKey);
  }
}

// ============ CACHE STATS ============

class CacheStats {
  final int detailedCacheSize;
  final int lruCacheSize;
  final int listCacheSize;
  final int suppliersCount;
  final int organisationsCount;
  final bool cacheEnabled;
  final int cacheTTLSeconds;
  final int hits;
  final int misses;

  CacheStats({
    required this.detailedCacheSize,
    required this.lruCacheSize,
    required this.listCacheSize,
    required this.suppliersCount,
    required this.organisationsCount,
    required this.cacheEnabled,
    required this.cacheTTLSeconds,
    required this.hits,
    required this.misses,
  });

  double get hitRate => hits + misses > 0 ? hits / (hits + misses) : 0.0;
}
