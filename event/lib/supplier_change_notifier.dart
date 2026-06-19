import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:locator/locator.dart';

import 'package:gluttex_core/app/GluttexException.dart';
import 'package:gluttex_core/business/Organisation.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_core/business/services/SupplierService.dart';
import 'package:gluttex_core/mediation/StorageService.dart';

// ============ CACHE ENTRY WITH TTL ============
class _CacheEntry<T> {
  final T data;
  final DateTime timestamp;
  final int ttlSeconds;

  _CacheEntry(this.data, {this.ttlSeconds = 300}) : timestamp = DateTime.now();

  bool get isExpired =>
      DateTime.now().difference(timestamp).inSeconds > ttlSeconds;
  bool get isValid => !isExpired;
}

// ============ CACHE STATISTICS ============
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

// ============ SUPPLIER CHANGE NOTIFIER ============
class SupplierChangeNotifier extends ChangeNotifier {
  final SupplierService _supplierService = AppLocator.get<SupplierService>();
  final StorageService _storageService = AppLocator.get<StorageService>();

  // ============ CACHE STORAGE ============
  final List<Supplier> _suppliers = [];
  final Map<int, _CacheEntry<Supplier>> _detailedCache = {};
  final Map<int, Organisation> _organisations = {};

  // LRU cache for frequently accessed suppliers
  final LinkedHashMap<int, _CacheEntry<Supplier>> _lruCache = LinkedHashMap();

  // List cache for paginated results (stores IDs, not full objects)
  final Map<String, _CacheEntry<List<int>>> _listCache = {};

  // Cache statistics
  int _cacheHits = 0;
  int _cacheMisses = 0;

  // Cache configuration
  static const int _maxCacheSize = 100;
  static const int _defaultCacheTTLSeconds = 300; // 5 minutes
  static const int _longCacheTTLSeconds = 3600; // 1 hour
  static const int _shortCacheTTLSeconds = 60; // 1 minute

  // Pagination constants
  static const int _itemsPerPage = 50;
  static const int _organisationsPerPage = 30;

  // Pagination state
  int _suppliersPage = 0;
  int _organisationsPage = 0;
  bool _hasMoreSuppliers = true;
  bool _hasMoreOrganisations = true;

  // Filter and location state
  Position? _currentLocation;
  SupplierFilter _filter = const SupplierFilter();
  bool _isLoading = false;
  bool _isDisposed = false;

  // Debouncing
  Timer? _searchTimer;

  // Cache control
  bool _enableCache = true;
  Duration _cacheTTL = const Duration(minutes: 5);

  // Batch request debouncing
  final Map<int, Future<Supplier?>> _pendingRequests = {};
  final Map<String, Future<List<Supplier>>> _pendingBatchRequests = {};

  SupplierChangeNotifier();

  // ============ RESPONSE TRACKING HELPER METHODS ============

  String _generateCallerKey(String operation, {String? id, String? suffix}) {
    final parts = [operation];
    if (id != null) parts.add(id);
    if (suffix != null) parts.add(suffix);
    parts.add(DateTime.now().millisecondsSinceEpoch.toString());
    return parts.join('_');
  }

  void _storeSuccessResponse(String callerKey, dynamic data,
      {int? statusCode, String? responseCode}) {
    _storageService.setSuccessResponse(callerKey, data,
        statusCode: statusCode ?? 200, responseCode: responseCode);
    debugPrint('✅ Stored SUCCESS: $callerKey - $responseCode');
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
    debugPrint('❌ Stored FAILURE: $callerKey - $responseCode');
  }

  // ============ LIFECYCLE ============

  @override
  void dispose() {
    _isDisposed = true;
    _searchTimer?.cancel();
    _clearAllCaches();
    _pendingRequests.clear();
    _pendingBatchRequests.clear();
    super.dispose();
  }

  // ============ CACHE MANAGEMENT ============

  void _clearAllCaches() {
    _detailedCache.clear();
    _lruCache.clear();
    _listCache.clear();
    _cacheHits = 0;
    _cacheMisses = 0;
  }

  void _invalidateCache({int? supplierId, String? listKey}) {
    if (supplierId != null) {
      _detailedCache.remove(supplierId);
      _lruCache.remove(supplierId);
    }

    if (listKey != null) {
      _listCache.remove(listKey);
    }

    if (supplierId == null && listKey == null) {
      _clearAllCaches();
    }
  }

  void _addToLRUCache(int id, Supplier supplier) {
    if (!_enableCache) return;

    if (_lruCache.containsKey(id)) {
      _lruCache.remove(id);
    }

    while (_lruCache.length >= _maxCacheSize) {
      final oldestKey = _lruCache.keys.first;
      _lruCache.remove(oldestKey);
    }

    _lruCache[id] = _CacheEntry(supplier, ttlSeconds: _defaultCacheTTLSeconds);
  }

  Supplier? _getFromLRUCache(int id) {
    if (!_enableCache) return null;

    final entry = _lruCache[id];
    if (entry == null) return null;

    if (entry.isExpired) {
      _lruCache.remove(id);
      _cacheMisses++;
      return null;
    }

    _lruCache.remove(id);
    _lruCache[id] = entry;

    _cacheHits++;
    return entry.data;
  }

  void _cacheList(String key, List<Supplier> suppliers, {int? ttlSeconds}) {
    if (!_enableCache) return;

    final ids = suppliers.map((s) => s.idProductProvider).toList();
    _listCache[key] = _CacheEntry<List<int>>(ids,
        ttlSeconds: ttlSeconds ?? _defaultCacheTTLSeconds);

    for (final supplier in suppliers) {
      _cacheSupplier(supplier);
    }
  }

  List<Supplier>? _getFromListCache(String key) {
    if (!_enableCache) return null;

    final entry = _listCache[key];
    if (entry == null) return null;

    if (entry.isExpired) {
      _listCache.remove(key);
      _cacheMisses++;
      return null;
    }

    final suppliers = <Supplier>[];
    for (final id in entry.data) {
      final cached = _getCachedSupplier(id);
      if (cached != null) {
        suppliers.add(cached);
      } else {
        _listCache.remove(key);
        _cacheMisses++;
        return null;
      }
    }

    _cacheHits++;
    return suppliers;
  }

  void _cacheSupplier(Supplier supplier, {int? ttlSeconds}) {
    if (!_enableCache) return;

    final ttl = ttlSeconds ?? _defaultCacheTTLSeconds;
    _detailedCache[supplier.idProductProvider] =
        _CacheEntry(supplier, ttlSeconds: ttl);
    _addToLRUCache(supplier.idProductProvider, supplier);
  }

  Supplier? _getCachedSupplier(int id) {
    if (!_enableCache) return null;

    final lruCached = _getFromLRUCache(id);
    if (lruCached != null) return lruCached;

    final entry = _detailedCache[id];
    if (entry != null && entry.isValid) {
      _addToLRUCache(id, entry.data);
      _cacheHits++;
      return entry.data;
    }

    if (entry != null && entry.isExpired) {
      _detailedCache.remove(id);
    }

    _cacheMisses++;
    return null;
  }

  // ============ SAFE NOTIFICATION ============

  void _safeNotifyListeners() {
    if (!_isDisposed && hasListeners) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed && hasListeners) {
          notifyListeners();
        }
      });
    }
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      _safeNotifyListeners();
    }
  }

  // ============ PUBLIC GETTERS ============

  List<Supplier> get suppliers => List.unmodifiable(_suppliers);
  List<Supplier> get filteredSuppliers => _applyFilters();
  List<Supplier> get detailedSuppliers =>
      _detailedCache.values.map((e) => e.data).toList();
  List<Organisation> get organisations =>
      List.unmodifiable(_organisations.values);

  bool get isLoading => _isLoading;
  bool get hasMoreSuppliers => _hasMoreSuppliers;
  bool get hasMoreOrganisations => _hasMoreOrganisations;
  Position? get currentLocation => _currentLocation;
  SupplierFilter get filter => _filter;
  bool get isCacheEnabled => _enableCache;

  // ============ CACHE CONFIGURATION ============

  void enableCaching(bool enable) {
    if (_enableCache != enable) {
      _enableCache = enable;
      if (!enable) {
        _clearAllCaches();
      }
      _safeNotifyListeners();
    }
  }

  void setCacheTTL(Duration duration) {
    _cacheTTL = duration;
  }

  void invalidateCache({int? supplierId, String? listKey}) {
    _invalidateCache(supplierId: supplierId, listKey: listKey);
    _safeNotifyListeners();
  }

  void refreshAllCaches() {
    _clearAllCaches();
    _safeNotifyListeners();
  }

  CacheStats getCacheStats() {
    return CacheStats(
      detailedCacheSize: _detailedCache.length,
      lruCacheSize: _lruCache.length,
      listCacheSize: _listCache.length,
      suppliersCount: _suppliers.length,
      organisationsCount: _organisations.length,
      cacheEnabled: _enableCache,
      cacheTTLSeconds: _cacheTTL.inSeconds,
      hits: _cacheHits,
      misses: _cacheMisses,
    );
  }

  // ============ FILTER MANAGEMENT ============

  void setFilter(SupplierFilter newFilter) {
    if (_filter != newFilter) {
      _filter = newFilter;
      _safeNotifyListeners();
    }
  }

  void clearFilter() {
    if (!_filter.isEmpty) {
      _filter = const SupplierFilter();
      _safeNotifyListeners();
    }
  }

  List<Supplier> _applyFilters() {
    if (_filter.isEmpty) return List.unmodifiable(_suppliers);

    return _suppliers.where((supplier) {
      if (_filter.name != null && !_matchesName(supplier, _filter.name!)) {
        return false;
      }
      if (_filter.organisationId != null &&
          supplier.idProviderOrganisation != _filter.organisationId) {
        return false;
      }
      if (_filter.ownerId != null &&
          supplier.productProviderOwnerId != _filter.ownerId) {
        return false;
      }
      if (_filter.types != null && _filter.types!.isNotEmpty) {
        final supplierType = supplier.productProviderTypeId;
        if (supplierType == null || !_filter.types!.contains(supplierType)) {
          return false;
        }
      }
      if (_filter.hasLocation != null) {
        final hasLoc = supplier.locationLatitude != null &&
            supplier.locationLongitude != null;
        if (hasLoc != _filter.hasLocation) return false;
      }
      return true;
    }).toList();
  }

  bool _matchesName(Supplier supplier, String query) {
    final name = supplier.providerName.toLowerCase();
    final lowerQuery = query.toLowerCase();
    return name.contains(lowerQuery);
  }

  // ============ SUPPLIER MANAGEMENT ============

  Future<void> fetchSuppliers({
    bool reset = false,
    int? ownerId,
    int? organisationId,
    bool notify = true,
    bool forceRefresh = false,
  }) async {
    final operationKey = _generateCallerKey('fetchSuppliers',
        suffix: '${ownerId ?? 0}_${organisationId ?? 0}_$_suppliersPage');

    // Check cache
    if (!forceRefresh && !reset) {
      final cacheKey =
          'suppliers_${ownerId ?? 0}_${organisationId ?? 0}_$_suppliersPage';
      final cached = _getFromListCache(cacheKey);
      if (cached != null && cached.isNotEmpty) {
        _addSuppliers(cached, notify: notify);
        _storeSuccessResponse(operationKey, cached,
            statusCode: 200, responseCode: 'CACHE_HIT');
        return;
      }
    }

    if (_isLoading || (!reset && !_hasMoreSuppliers)) {
      _storeFailureResponse(operationKey, null,
          statusCode: 429,
          errorCode: 'LOADING_OR_END',
          message: 'Already loading or no more suppliers',
          responseCode: 'RATE_LIMITED');
      return;
    }

    if (reset) {
      _suppliers.clear();
      _suppliersPage = 0;
      _hasMoreSuppliers = true;
    }

    _setLoading(true);

    try {
      final fetched = await _supplierService.getAllSuppliers(
        ownerId ?? 0,
        organisationId ?? 0,
        _suppliersPage * _itemsPerPage,
        _itemsPerPage,
      );

      if (!reset) {
        final cacheKey =
            'suppliers_${ownerId ?? 0}_${organisationId ?? 0}_$_suppliersPage';
        _cacheList(cacheKey, fetched);
      }

      _addSuppliers(fetched, notify: false);

      if (fetched.length < _itemsPerPage) {
        _hasMoreSuppliers = false;
      } else {
        _suppliersPage++;
      }

      _storeSuccessResponse(operationKey, fetched,
          statusCode: 200, responseCode: 'SUCCESS');
    } catch (e, stackTrace) {
      _handleError('Failed to fetch suppliers', e, stackTrace);
      _storeFailureResponse(operationKey, e.toString(),
          statusCode: 500,
          errorCode: 'FETCH_ERROR',
          message: e.toString(),
          responseCode: 'ERROR');
      rethrow;
    } finally {
      _setLoading(false);
      if (notify) {
        _safeNotifyListeners();
      }
    }
  }

  Future<Supplier?> getSupplierById(int id,
      {bool forceRefresh = false,
      bool notify = true,
      int? customTTLSeconds}) async {
    final operationKey =
        _generateCallerKey('getSupplierById', id: id.toString());

    // Check cache first
    if (!forceRefresh) {
      final cached = _getCachedSupplier(id);
      if (cached != null && cached.idProductProvider != 0) {
        _storeSuccessResponse(operationKey, cached,
            statusCode: 200, responseCode: 'CACHE_HIT');
        return cached;
      }
    }

    // Prevent duplicate concurrent requests for same ID
    if (_pendingRequests.containsKey(id)) {
      _storeSuccessResponse(operationKey, await _pendingRequests[id],
          statusCode: 200, responseCode: 'PENDING_REQUEST');
      return _pendingRequests[id];
    }

    _setLoading(true);

    final future = _supplierService.getSupplier(id.toString()).then((supplier) {
      if (supplier != null && supplier.idProductProvider != 0) {
        _cacheSupplier(supplier, ttlSeconds: customTTLSeconds);
        _updateSupplierInList(supplier, notify: false);
        _storeSuccessResponse(operationKey, supplier,
            statusCode: 200, responseCode: 'SUCCESS');
      } else {
        _storeFailureResponse(operationKey, null,
            statusCode: 404,
            errorCode: 'NOT_FOUND',
            message: 'Supplier with ID $id not found',
            responseCode: 'NOT_FOUND');
      }
      return supplier;
    }).catchError((e, stackTrace) {
      _handleError('Failed to fetch supplier $id', e, stackTrace);
      _storeFailureResponse(operationKey, e.toString(),
          statusCode: 500,
          errorCode: 'FETCH_ERROR',
          message: e.toString(),
          responseCode: 'ERROR');
      return null;
    }).whenComplete(() {
      _pendingRequests.remove(id);
      _setLoading(false);
      if (notify) {
        _safeNotifyListeners();
      }
    });

    _pendingRequests[id] = future;
    return future;
  }

  Supplier? getCachedSupplierById(int id) {
    return _getCachedSupplier(id);
  }

  Future<List<Supplier>> getSuppliersByIds(List<int> ids,
      {bool forceRefresh = false}) async {
    final operationKey =
        _generateCallerKey('getSuppliersByIds', suffix: ids.join(','));

    if (ids.isEmpty) {
      _storeSuccessResponse(operationKey, [],
          statusCode: 200, responseCode: 'EMPTY_LIST');
      return [];
    }

    // Remove duplicates
    final uniqueIds = ids.toSet().toList();

    final results = <Supplier>[];
    final missingIds = <int>[];

    // Check cache first
    for (final id in uniqueIds) {
      if (!forceRefresh) {
        final cached = _getCachedSupplier(id);
        if (cached != null) {
          results.add(cached);
        } else {
          missingIds.add(id);
        }
      } else {
        missingIds.add(id);
      }
    }

    // Fetch missing ones in batch if possible
    if (missingIds.isNotEmpty) {
      final cacheKey = 'batch_${missingIds.join(',')}';

      if (_pendingBatchRequests.containsKey(cacheKey)) {
        final batchResults = await _pendingBatchRequests[cacheKey]!;
        results.addAll(batchResults);
        _storeSuccessResponse(operationKey, results,
            statusCode: 200, responseCode: 'BATCH_PENDING');
        return results;
      }

      final batchFuture = _fetchSuppliersBatch(missingIds);
      _pendingBatchRequests[cacheKey] = batchFuture;

      try {
        final fetched = await batchFuture;
        results.addAll(fetched);
        _storeSuccessResponse(operationKey, results,
            statusCode: 200, responseCode: 'BATCH_SUCCESS');
      } finally {
        _pendingBatchRequests.remove(cacheKey);
      }
    }

    return results;
  }

  Future<List<Supplier>> _fetchSuppliersBatch(List<int> ids) async {
    final results = <Supplier>[];

    for (final id in ids) {
      try {
        final supplier = await _supplierService.getSupplier(id.toString());
        if (supplier != null && supplier.idProductProvider != 0) {
          _cacheSupplier(supplier);
          results.add(supplier);
        }
      } catch (e) {
        debugPrint('Failed to fetch supplier $id: $e');
      }
    }

    return results;
  }

  // ============ CUD OPERATIONS WITH RESPONSE TRACKING ============

  Future<Supplier> createOrUpdateSupplier(Supplier supplier) async {
    final isCreating = supplier.idProductProvider == 0;
    final operationKey = _generateCallerKey(
        isCreating ? 'createSupplier' : 'updateSupplier',
        id: isCreating ? null : supplier.idProductProvider.toString(),
        suffix: supplier.providerName);

    _setLoading(true);

    try {
      // Handle image upload if present
      if (supplier.supplierImage != null) {
        String? imageUrl = await supplier.supplierImage?.uploadImage();
        supplier = supplier.copyWith(supplierImageUrl: imageUrl);
      }

      final result = isCreating
          ? await _supplierService.addSupplier(supplier)
          : await _supplierService.updateSupplier(supplier);

      if (result == null) {
        _storeFailureResponse(operationKey, null,
            statusCode: 500,
            errorCode: 'SAVE_FAILED',
            message: 'Failed to save supplier',
            responseCode: 'SAVE_FAILED');
        throw GluttexException('Failed to save supplier');
      }

      // Invalidate cache for this supplier
      _invalidateCache(supplierId: result.idProductProvider);
      _cacheSupplier(result, ttlSeconds: _longCacheTTLSeconds);
      _updateSupplierInList(result, notify: false);

      // Refresh list if needed
      if (isCreating) {
        await fetchSuppliers(reset: true, notify: false);
      }

      _storeSuccessResponse(operationKey, result,
          statusCode: 200, responseCode: isCreating ? 'CREATED' : 'UPDATED');

      return result;
    } catch (e, stackTrace) {
      _handleError('Failed to save supplier', e, stackTrace);
      _storeFailureResponse(operationKey, e.toString(),
          statusCode: 500,
          errorCode: 'SAVE_ERROR',
          message: e.toString(),
          responseCode: 'ERROR');
      rethrow;
    } finally {
      _setLoading(false);
      _safeNotifyListeners();
    }
  }

  Future<bool> deleteSupplier(int id) async {
    final operationKey =
        _generateCallerKey('deleteSupplier', id: id.toString());

    _setLoading(true);

    try {
      final status = await _supplierService.deleteSupplier(id.toString());
      final success = status != null && (status == 200 || status == 204);

      if (success) {
        _suppliers.removeWhere((s) => s.idProductProvider == id);
        _invalidateCache(supplierId: id);
        _storeSuccessResponse(operationKey, true,
            statusCode: status ?? 200, responseCode: 'DELETED');
      } else {
        _storeFailureResponse(operationKey, false,
            statusCode: status ?? 500,
            errorCode: 'DELETE_FAILED',
            message: 'Failed to delete supplier',
            responseCode: 'DELETE_FAILED');
      }

      return success;
    } catch (e, stackTrace) {
      _handleError('Failed to delete supplier', e, stackTrace);
      _storeFailureResponse(operationKey, e.toString(),
          statusCode: 500,
          errorCode: 'DELETE_ERROR',
          message: e.toString(),
          responseCode: 'ERROR');
      return false;
    } finally {
      _setLoading(false);
      _safeNotifyListeners();
    }
  }

  // ============ SEARCH FUNCTIONALITY ============

  Future<void> searchSuppliers(String query,
      {Duration delay = const Duration(milliseconds: 500)}) async {
    final operationKey = _generateCallerKey('searchSuppliers', suffix: query);

    _searchTimer?.cancel();

    if (query.isEmpty) {
      clearFilter();
      _storeSuccessResponse(operationKey, null,
          statusCode: 200, responseCode: 'QUERY_CLEARED');
      return;
    }

    final cacheKey = 'search_${query.toLowerCase()}';
    final cached = _getFromListCache(cacheKey);
    if (cached != null) {
      _addSuppliers(cached, notify: true);
      _storeSuccessResponse(operationKey, cached,
          statusCode: 200, responseCode: 'SEARCH_CACHE_HIT');
      return;
    }

    _searchTimer = Timer(delay, () async {
      if (_isDisposed) return;

      setFilter(SupplierFilter(name: query));

      final localResults = _applyFilters();
      if (localResults.isNotEmpty) {
        _safeNotifyListeners();
      }

      _setLoading(true);

      try {
        final remoteResults = await _supplierService.searchSuppliersByToken(
          query,
          0,
          50,
        );

        _cacheList(cacheKey, remoteResults, ttlSeconds: _shortCacheTTLSeconds);
        _addSuppliers(remoteResults, notify: false);

        _storeSuccessResponse(operationKey, remoteResults,
            statusCode: 200,
            responseCode:
                remoteResults.isEmpty ? 'SEARCH_NO_RESULTS' : 'SEARCH_SUCCESS');
      } catch (e, stackTrace) {
        _handleError('Failed to search suppliers', e, stackTrace);
        _storeFailureResponse(operationKey, e.toString(),
            statusCode: 500,
            errorCode: 'SEARCH_ERROR',
            message: e.toString(),
            responseCode: 'SEARCH_ERROR');
      } finally {
        _setLoading(false);
        _safeNotifyListeners();
      }
    });
  }

  Future<void> searchSuppliersByGeo({
    required double longitude,
    required double latitude,
    required double radiusKm,
    bool reset = false,
    bool notify = true,
  }) async {
    final operationKey = _generateCallerKey('searchSuppliersByGeo',
        suffix: '${longitude}_${latitude}_${radiusKm}');

    final cacheKey = 'geo_${longitude}_${latitude}_${radiusKm}_$_suppliersPage';
    if (!reset) {
      final cached = _getFromListCache(cacheKey);
      if (cached != null) {
        _addSuppliers(cached, notify: notify);
        _storeSuccessResponse(operationKey, cached,
            statusCode: 200, responseCode: 'GEO_CACHE_HIT');
        return;
      }
    }

    if (reset) {
      _suppliers.clear();
      _suppliersPage = 0;
      _hasMoreSuppliers = true;
    }

    _setLoading(true);

    try {
      final results = await _supplierService.searchSuppliersByGeo(
        longitude,
        latitude,
        _suppliersPage * _itemsPerPage,
        _itemsPerPage,
        radiusKm,
      );

      _cacheList(cacheKey, results, ttlSeconds: _shortCacheTTLSeconds);
      _addSuppliers(results, notify: false);

      if (results.length < _itemsPerPage) {
        _hasMoreSuppliers = false;
      } else {
        _suppliersPage++;
      }

      _storeSuccessResponse(operationKey, results,
          statusCode: 200,
          responseCode: results.isEmpty ? 'GEO_NO_RESULTS' : 'GEO_SUCCESS');
    } catch (e, stackTrace) {
      _handleError('Failed to search suppliers by location', e, stackTrace);
      _storeFailureResponse(operationKey, e.toString(),
          statusCode: 500,
          errorCode: 'GEO_SEARCH_ERROR',
          message: e.toString(),
          responseCode: 'GEO_ERROR');
      rethrow;
    } finally {
      _setLoading(false);
      if (notify) {
        _safeNotifyListeners();
      }
    }
  }

  // ============ LOCATION MANAGEMENT ============

  Future<void> getCurrentLocation({bool notify = true}) async {
    final operationKey = _generateCallerKey('getCurrentLocation');

    if (_isLoading) {
      _storeFailureResponse(operationKey, null,
          statusCode: 429,
          errorCode: 'LOADING',
          message: 'Location fetch already in progress',
          responseCode: 'LOADING');
      return;
    }

    if (!Platform.isAndroid && !Platform.isIOS) {
      _storeFailureResponse(operationKey, null,
          statusCode: 400,
          errorCode: 'UNSUPPORTED_PLATFORM',
          message: 'Location only available on mobile platforms',
          responseCode: 'UNSUPPORTED');
      return;
    }

    _setLoading(true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _storeFailureResponse(operationKey, null,
            statusCode: 400,
            errorCode: 'SERVICES_DISABLED',
            message: 'Location services are disabled',
            responseCode: 'SERVICES_DISABLED');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          _storeFailureResponse(operationKey, null,
              statusCode: 403,
              errorCode: 'PERMISSION_DENIED',
              message: 'Location permissions are denied',
              responseCode: 'PERMISSION_DENIED');
          return;
        }
      }

      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        _storeFailureResponse(operationKey, null,
            statusCode: 403,
            errorCode: 'INSUFFICIENT_PERMISSION',
            message: 'Insufficient location permission',
            responseCode: 'INSUFFICIENT_PERMISSION');
        return;
      }

      _currentLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 15));

      _storeSuccessResponse(operationKey, _currentLocation,
          statusCode: 200, responseCode: 'SUCCESS');
    } on TimeoutException {
      _storeFailureResponse(operationKey, null,
          statusCode: 408,
          errorCode: 'TIMEOUT',
          message: 'Location request timed out',
          responseCode: 'TIMEOUT');
    } catch (e) {
      _storeFailureResponse(operationKey, e.toString(),
          statusCode: 500,
          errorCode: 'LOCATION_ERROR',
          message: e.toString(),
          responseCode: 'ERROR');
    } finally {
      _setLoading(false);
      if (notify) {
        _safeNotifyListeners();
      }
    }
  }

  // ============ ORGANISATION MANAGEMENT ============

  Future<void> fetchOrganisations({
    bool reset = false,
    int? ownerId,
    int? organisationId,
    bool notify = true,
  }) async {
    final operationKey = _generateCallerKey('fetchOrganisations',
        suffix: '${ownerId ?? 0}_${organisationId ?? 0}_$_organisationsPage');

    if (_isLoading || (!reset && !_hasMoreOrganisations)) {
      _storeFailureResponse(operationKey, null,
          statusCode: 429,
          errorCode: 'LOADING_OR_END',
          message: 'Already loading or no more organisations',
          responseCode: 'RATE_LIMITED');
      return;
    }

    if (reset) {
      _organisations.clear();
      _organisationsPage = 0;
      _hasMoreOrganisations = true;
    }

    _setLoading(true);

    try {
      final results = await _supplierService.getAllOrganisations(
        ownerId ?? 0,
        organisationId ?? 0,
        _organisationsPage * _organisationsPerPage,
        _organisationsPerPage,
      );

      if (results.isNotEmpty) {
        for (final org in results) {
          _organisations[org.id_provider_organisation] = org;
        }
        _organisationsPage++;

        if (results.length < _organisationsPerPage) {
          _hasMoreOrganisations = false;
        }
      } else {
        _hasMoreOrganisations = false;
      }

      _storeSuccessResponse(operationKey, results,
          statusCode: 200,
          responseCode: results.isEmpty ? 'NO_ORGANISATIONS' : 'SUCCESS');
    } catch (e, stackTrace) {
      _handleError('Failed to fetch organisations', e, stackTrace);
      _storeFailureResponse(operationKey, e.toString(),
          statusCode: 500,
          errorCode: 'FETCH_ORGS_ERROR',
          message: e.toString(),
          responseCode: 'ERROR');
      rethrow;
    } finally {
      _setLoading(false);
      if (notify) {
        _safeNotifyListeners();
      }
    }
  }

  Organisation? getOrganisationById(int id) {
    return _organisations[id];
  }

  // ============ HELPER METHODS ============

  void _addSuppliers(List<Supplier> newSuppliers, {bool notify = true}) {
    final existingIds = _suppliers.map((s) => s.idProductProvider).toSet();

    for (final supplier in newSuppliers) {
      if (!existingIds.contains(supplier.idProductProvider)) {
        _suppliers.add(supplier);
        _cacheSupplier(supplier);
      }
    }

    if (notify) {
      _safeNotifyListeners();
    }
  }

  void _updateSupplierInList(Supplier supplier, {bool notify = true}) {
    final index = _suppliers.indexWhere(
      (s) => s.idProductProvider == supplier.idProductProvider,
    );

    if (index != -1) {
      _suppliers[index] = supplier;
    }

    if (notify) {
      _safeNotifyListeners();
    }
  }

  void _handleError(String message, Object error, StackTrace stackTrace) {
    debugPrint('$message: $error');
    debugPrint(stackTrace.toString());
  }

  // ============ BATCH OPERATIONS ============

  Future<void> refreshAll({bool notify = true}) async {
    final operationKey = _generateCallerKey('refreshAll');

    _clearAllCaches();

    await Future.wait([
      fetchSuppliers(reset: true, notify: false, forceRefresh: true),
      fetchOrganisations(reset: true, notify: false),
    ]);

    _storeSuccessResponse(operationKey, true,
        statusCode: 200, responseCode: 'REFRESHED');

    if (notify) {
      _safeNotifyListeners();
    }
  }

  Future<void> prefetchSupplierDetails(List<int> supplierIds) async {
    final operationKey = _generateCallerKey('prefetchSupplierDetails',
        suffix: supplierIds.join(','));

    final missingIds =
        supplierIds.where((id) => _getCachedSupplier(id) == null).toList();

    if (missingIds.isEmpty) {
      _storeSuccessResponse(operationKey, true,
          statusCode: 200, responseCode: 'ALL_CACHED');
      return;
    }

    const batchSize = 10;
    for (var i = 0; i < missingIds.length; i += batchSize) {
      final end = (i + batchSize) < missingIds.length
          ? i + batchSize
          : missingIds.length;
      final batch = missingIds.sublist(i, end);
      await getSuppliersByIds(batch);
    }

    _storeSuccessResponse(operationKey, true,
        statusCode: 200, responseCode: 'PREFETCHED');
  }

  // ============ STATE RESET ============

  void reset() {
    _clearAllCaches();
    _suppliers.clear();
    _organisations.clear();
    _currentLocation = null;
    _filter = const SupplierFilter();
    _suppliersPage = 0;
    _organisationsPage = 0;
    _hasMoreSuppliers = true;
    _hasMoreOrganisations = true;
    _isLoading = false;
    _searchTimer?.cancel();
    _searchTimer = null;
    _pendingRequests.clear();
    _pendingBatchRequests.clear();

    _safeNotifyListeners();
  }

// ============ ORGANISATION CRUD OPERATIONS ============

  /// Fetch a single organisation by ID
  Future<Organisation?> getOrganisationByIdDetailed(int id,
      {bool forceRefresh = false, bool notify = true}) async {
    final operationKey =
        _generateCallerKey('getOrganisationByIdDetailed', id: id.toString());

    // Check cache first if not forcing refresh
    if (!forceRefresh) {
      final cached = _organisations[id];
      if (cached != null) {
        _storeSuccessResponse(operationKey, cached,
            statusCode: 200, responseCode: 'CACHE_HIT');
        return cached;
      }
    }

    _setLoading(true);

    try {
      final organisation =
          await _supplierService.getOrganisation(id.toString());

      if (organisation != null) {
        // Cache the organisation
        _organisations[organisation.id_provider_organisation] = organisation;
        _storeSuccessResponse(operationKey, organisation,
            statusCode: 200, responseCode: 'SUCCESS');
        return organisation;
      } else {
        _storeFailureResponse(operationKey, null,
            statusCode: 404,
            errorCode: 'NOT_FOUND',
            message: 'Organisation with ID $id not found',
            responseCode: 'NOT_FOUND');
        return null;
      }
    } catch (e, stackTrace) {
      _handleError('Failed to fetch organisation $id', e, stackTrace);
      _storeFailureResponse(operationKey, e.toString(),
          statusCode: 500,
          errorCode: 'FETCH_ORG_ERROR',
          message: e.toString(),
          responseCode: 'ERROR');
      return null;
    } finally {
      _setLoading(false);
      if (notify) {
        _safeNotifyListeners();
      }
    }
  }

  /// Create a new organisation
  Future<Organisation?> createOrganisation(Organisation organisation,
      {String? callerKey}) async {
    final operationKey = callerKey ??
        _generateCallerKey('createOrganisation',
            suffix: organisation.provider_organisation_name);

    _setLoading(true);

    try {
      final result = await _supplierService.addOrganisation(organisation);

      if (result == null) {
        _storeFailureResponse(operationKey, null,
            statusCode: 500,
            errorCode: 'CREATE_FAILED',
            message: 'Failed to create organisation',
            responseCode: 'CREATE_FAILED');
        return null;
      }

      // Cache the new organisation
      _organisations[result.id_provider_organisation] = result;

      _storeSuccessResponse(operationKey, result,
          statusCode: 200, responseCode: 'CREATED');

      _safeNotifyListeners();
      return result;
    } catch (e, stackTrace) {
      _handleError('Failed to create organisation', e, stackTrace);
      _storeFailureResponse(operationKey, e.toString(),
          statusCode: 500,
          errorCode: 'CREATE_ORG_ERROR',
          message: e.toString(),
          responseCode: 'ERROR');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing organisation
  Future<Organisation?> updateOrganisation(Organisation organisation,
      {String? callerKey}) async {
    final operationKey = callerKey ??
        _generateCallerKey('updateOrganisation',
            id: organisation.id_provider_organisation.toString());

    _setLoading(true);

    try {
      final result = await _supplierService.updateOrganisation(organisation);

      if (result == null) {
        _storeFailureResponse(operationKey, null,
            statusCode: 500,
            errorCode: 'UPDATE_FAILED',
            message: 'Failed to update organisation',
            responseCode: 'UPDATE_FAILED');
        return null;
      }

      // Update cache
      _organisations[result.id_provider_organisation] = result;

      _storeSuccessResponse(operationKey, result,
          statusCode: 200, responseCode: 'UPDATED');

      _safeNotifyListeners();
      return result;
    } catch (e, stackTrace) {
      _handleError('Failed to update organisation', e, stackTrace);
      _storeFailureResponse(operationKey, e.toString(),
          statusCode: 500,
          errorCode: 'UPDATE_ORG_ERROR',
          message: e.toString(),
          responseCode: 'ERROR');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete an organisation by ID
  Future<bool> deleteOrganisation(int id, {String? callerKey}) async {
    final operationKey = callerKey ??
        _generateCallerKey('deleteOrganisation', id: id.toString());

    _setLoading(true);

    try {
      final status = await _supplierService.deleteOrganisation(id.toString());
      final success = status != null && (status == 200 || status == 204);

      if (success) {
        // Remove from cache
        _organisations.remove(id);
        _storeSuccessResponse(operationKey, true,
            statusCode: status ?? 200, responseCode: 'DELETED');
      } else {
        _storeFailureResponse(operationKey, false,
            statusCode: status ?? 500,
            errorCode: 'DELETE_FAILED',
            message: 'Failed to delete organisation',
            responseCode: 'DELETE_FAILED');
      }

      _safeNotifyListeners();
      return success;
    } catch (e, stackTrace) {
      _handleError('Failed to delete organisation', e, stackTrace);
      _storeFailureResponse(operationKey, e.toString(),
          statusCode: 500,
          errorCode: 'DELETE_ORG_ERROR',
          message: e.toString(),
          responseCode: 'ERROR');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh organisations list (clear cache and fetch fresh)
  Future<List<Organisation>> refreshOrganisations(
      {bool clearCache = true}) async {
    final operationKey = _generateCallerKey('refreshOrganisations');

    if (clearCache) {
      _organisations.clear();
    }

    // Reset pagination and fetch fresh
    _organisationsPage = 0;
    _hasMoreOrganisations = true;

    await fetchOrganisations(reset: true, notify: true);

    _storeSuccessResponse(operationKey, _organisations.values.toList(),
        statusCode: 200, responseCode: 'REFRESHED');

    return _organisations.values.toList();
  }

  /// Get organisation by ID from cache (synchronous)
  Organisation? getCachedOrganisationById(int id) {
    return _organisations[id];
  }

  /// Check if organisation exists in cache
  bool hasOrganisationInCache(int id) {
    return _organisations.containsKey(id);
  }

  /// Clear a specific organisation from cache
  void clearOrganisationCache(int id) {
    _organisations.remove(id);
    debugPrint('Cleared organisation cache for ID: $id');
    _safeNotifyListeners();
  }

  /// Get all organisations with optional filtering
  List<Organisation> getAllOrganisationsList() {
    return _organisations.values.toList();
  }

  CallerResponse? getResponse(String callerKey) {
    return _storageService.getResponse(callerKey);
  }
}

// ============ SUPPLIER FILTER DATA CLASS ============

@immutable
class SupplierFilter {
  final String? name;
  final int? organisationId;
  final int? ownerId;
  final double? minRating;
  final List<int>? types;
  final String? status;
  final bool? hasLocation;
  final bool? isActive;

  const SupplierFilter({
    this.name,
    this.organisationId,
    this.ownerId,
    this.minRating,
    this.types,
    this.status,
    this.hasLocation,
    this.isActive,
  });

  SupplierFilter copyWith({
    String? name,
    int? organisationId,
    int? ownerId,
    double? minRating,
    List<int>? types,
    String? status,
    bool? hasLocation,
    bool? isActive,
  }) {
    return SupplierFilter(
      name: name ?? this.name,
      organisationId: organisationId ?? this.organisationId,
      ownerId: ownerId ?? this.ownerId,
      minRating: minRating ?? this.minRating,
      types: types ?? this.types,
      status: status ?? this.status,
      hasLocation: hasLocation ?? this.hasLocation,
      isActive: isActive ?? this.isActive,
    );
  }

  bool get isEmpty =>
      name == null &&
      organisationId == null &&
      ownerId == null &&
      minRating == null &&
      (types == null || types!.isEmpty) &&
      status == null &&
      hasLocation == null &&
      isActive == null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SupplierFilter &&
        other.name == name &&
        other.organisationId == organisationId &&
        other.ownerId == ownerId &&
        other.minRating == minRating &&
        other.types == types &&
        other.status == status &&
        other.hasLocation == hasLocation &&
        other.isActive == isActive;
  }

  @override
  int get hashCode => Object.hash(
        name,
        organisationId,
        ownerId,
        minRating,
        types,
        status,
        hasLocation,
        isActive,
      );
}
