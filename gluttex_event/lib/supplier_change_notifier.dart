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
  final SupplierService _supplierService =
      GluttexLocator.get<SupplierService>();

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

    // Remove if already exists
    if (_lruCache.containsKey(id)) {
      _lruCache.remove(id);
    }

    // Check size limit and remove oldest if needed
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

    // Move to end (most recently used)
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

    // Also cache individual suppliers
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

    // Retrieve full suppliers from cache
    final suppliers = <Supplier>[];
    for (final id in entry.data) {
      final cached = _getCachedSupplier(id);
      if (cached != null) {
        suppliers.add(cached);
      } else {
        // Cache incomplete, invalidate and return null
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

    // Check LRU cache first (fastest)
    final lruCached = _getFromLRUCache(id);
    if (lruCached != null) return lruCached;

    // Check detailed cache
    final entry = _detailedCache[id];
    if (entry != null && entry.isValid) {
      // Add to LRU for future quick access
      _addToLRUCache(id, entry.data);
      _cacheHits++;
      return entry.data;
    }

    // Expired or not found
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
      // if (_filter.minRating != null &&
      //     (supplier.averageRating ?? 0) < _filter.minRating!) {
      //   return false;
      // }
      // if (_filter.status != null && supplier.status != _filter.status) {
      //   return false;
      // }
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
    // Check cache
    if (!forceRefresh && !reset) {
      final cacheKey =
          'suppliers_${ownerId ?? 0}_${organisationId ?? 0}_$_suppliersPage';
      final cached = _getFromListCache(cacheKey);
      if (cached != null && cached.isNotEmpty) {
        _addSuppliers(cached, notify: notify);
        return;
      }
    }

    if (_isLoading || (!reset && !_hasMoreSuppliers)) return;

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

      // Cache the results
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
    } catch (e, stackTrace) {
      _handleError('Failed to fetch suppliers', e, stackTrace);
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
    // Check cache first
    if (!forceRefresh) {
      final cached = _getCachedSupplier(id);
      if (cached != null && cached.idProductProvider != 0) {
        return cached;
      }
    }

    // Prevent duplicate concurrent requests for same ID
    if (_pendingRequests.containsKey(id)) {
      return _pendingRequests[id];
    }

    _setLoading(true);

    final future = _supplierService.getSupplier(id.toString()).then((supplier) {
      if (supplier != null && supplier.idProductProvider != 0) {
        _cacheSupplier(supplier, ttlSeconds: customTTLSeconds);
        _updateSupplierInList(supplier, notify: false);
      }
      return supplier;
    }).catchError((e, stackTrace) {
      _handleError('Failed to fetch supplier $id', e, stackTrace);
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
    if (ids.isEmpty) return [];

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

      // Check if we already have a pending batch request
      if (_pendingBatchRequests.containsKey(cacheKey)) {
        // Safe because containsKey guarantees the value exists
        final batchResults = await _pendingBatchRequests[cacheKey]!;
        results.addAll(batchResults);
        return results;
      }

      final batchFuture = _fetchSuppliersBatch(missingIds);
      _pendingBatchRequests[cacheKey] = batchFuture;

      try {
        final fetched = await batchFuture;
        results.addAll(fetched);
      } finally {
        _pendingBatchRequests.remove(cacheKey);
      }
    }

    return results;
  }

  Future<List<Supplier>> _fetchSuppliersBatch(List<int> ids) async {
    final results = <Supplier>[];

    // Fetch sequentially to avoid overwhelming the API
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

  Future<Supplier> createOrUpdateSupplier(Supplier supplier) async {
    _setLoading(true);

    try {
      // Handle image upload if present
      if (supplier.supplierImage != null) {
        String? imageUrl = await supplier.supplierImage?.uploadImage();
        supplier = supplier.copyWith(supplierImageUrl: imageUrl);
      }

      final result = supplier.idProductProvider == 0
          ? await _supplierService.addSupplier(supplier)
          : await _supplierService.updateSupplier(supplier);

      if (result == null) {
        throw GluttexException('Failed to save supplier');
      }

      // Invalidate cache for this supplier
      _invalidateCache(supplierId: result.idProductProvider);
      _cacheSupplier(result, ttlSeconds: _longCacheTTLSeconds);
      _updateSupplierInList(result, notify: false);

      // Refresh list if needed
      if (supplier.idProductProvider == 0) {
        await fetchSuppliers(reset: true, notify: false);
      }

      return result;
    } catch (e, stackTrace) {
      _handleError('Failed to save supplier', e, stackTrace);
      rethrow;
    } finally {
      _setLoading(false);
      _safeNotifyListeners();
    }
  }

  Future<bool> deleteSupplier(int id) async {
    _setLoading(true);

    try {
      final status = await _supplierService.deleteSupplier(id.toString());
      final success = status != null;

      if (success) {
        _suppliers.removeWhere((s) => s.idProductProvider == id);
        _invalidateCache(supplierId: id);
      }

      return success;
    } catch (e, stackTrace) {
      _handleError('Failed to delete supplier', e, stackTrace);
      return false;
    } finally {
      _setLoading(false);
      _safeNotifyListeners();
    }
  }

  // ============ SEARCH FUNCTIONALITY ============

  Future<void> searchSuppliers(String query,
      {Duration delay = const Duration(milliseconds: 500)}) async {
    // Cancel previous timer
    _searchTimer?.cancel();

    if (query.isEmpty) {
      clearFilter();
      return;
    }

    // Check search cache
    final cacheKey = 'search_${query.toLowerCase()}';
    final cached = _getFromListCache(cacheKey);
    if (cached != null) {
      _addSuppliers(cached, notify: true);
      return;
    }

    // Debounce search
    _searchTimer = Timer(delay, () async {
      if (_isDisposed) return;

      setFilter(SupplierFilter(name: query));

      // Local search first
      final localResults = _applyFilters();
      if (localResults.isNotEmpty) {
        _safeNotifyListeners();
      }

      _setLoading(true);

      try {
        final remoteResults = await _supplierService.searchSuppliersByToken(
          query,
          0,
          50, // Limit search results
        );

        _cacheList(cacheKey, remoteResults, ttlSeconds: _shortCacheTTLSeconds);
        _addSuppliers(remoteResults, notify: false);
      } catch (e, stackTrace) {
        _handleError('Failed to search suppliers', e, stackTrace);
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
    // Check cache
    final cacheKey = 'geo_${longitude}_${latitude}_${radiusKm}_$_suppliersPage';
    if (!reset) {
      final cached = _getFromListCache(cacheKey);
      if (cached != null) {
        _addSuppliers(cached, notify: notify);
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
    } catch (e, stackTrace) {
      _handleError('Failed to search suppliers by location', e, stackTrace);
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
    if (_isLoading) return;

    // Only allow on mobile platforms
    if (!Platform.isAndroid && !Platform.isIOS) {
      return;
    }

    _setLoading(true);

    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled');
        return;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          debugPrint('Location permissions are denied');
          return;
        }
      }

      // Verify we have proper permission
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }

      // Get location with timeout
      _currentLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 15));

      debugPrint(
          'Location obtained: ${_currentLocation?.latitude}, ${_currentLocation?.longitude}');
    } on TimeoutException {
      debugPrint('Location request timed out');
    } catch (e) {
      debugPrint('Location error: $e');
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
    if (_isLoading || (!reset && !_hasMoreOrganisations)) return;

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

      if (results != null && results.isNotEmpty) {
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
    } catch (e, stackTrace) {
      _handleError('Failed to fetch organisations', e, stackTrace);
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
    // Invalidate all caches
    _clearAllCaches();

    await Future.wait([
      fetchSuppliers(reset: true, notify: false, forceRefresh: true),
      fetchOrganisations(reset: true, notify: false),
    ]);

    if (notify) {
      _safeNotifyListeners();
    }
  }

  Future<void> prefetchSupplierDetails(List<int> supplierIds) async {
    final missingIds =
        supplierIds.where((id) => _getCachedSupplier(id) == null).toList();

    if (missingIds.isEmpty) return;

    // Prefetch in batches of 10 to avoid overwhelming
    const batchSize = 10;
    for (var i = 0; i < missingIds.length; i += batchSize) {
      final end = (i + batchSize) < missingIds.length
          ? i + batchSize
          : missingIds.length;
      final batch = missingIds.sublist(i, end);
      await getSuppliersByIds(batch);
    }
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

// ============ USAGE EXAMPLE ============

/*
// How to use in your app:

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SupplierChangeNotifier>(
      builder: (context, notifier, child) {
        return Column(
          children: [
            // Display cache stats for debugging
            if (kDebugMode)
              Text('Cache hit rate: ${(notifier.getCacheStats().hitRate * 100).toStringAsFixed(1)}%'),
            
            Expanded(
              child: ListView.builder(
                itemCount: notifier.filteredSuppliers.length,
                itemBuilder: (context, index) {
                  final supplier = notifier.filteredSuppliers[index];
                  return ListTile(
                    title: Text(supplier.providerName),
                    onTap: () async {
                      // This will use cache if available
                      final detailed = await notifier.getSupplierById(supplier.idProductProvider);
                      // Navigate to detail screen
                    },
                  );
                },
              ),
            ),
            
            // Load more button
            if (notifier.hasMoreSuppliers && !notifier.isLoading)
              ElevatedButton(
                onPressed: () => notifier.fetchSuppliers(),
                child: Text('Load More'),
              ),
          ],
        );
      },
    );
  }
}

// Prefetch data for a list of IDs
await notifier.prefetchSupplierDetails([1, 2, 3, 4, 5]);

// Force refresh a specific supplier
final freshSupplier = await notifier.getSupplierById(123, forceRefresh: true);

// Clear cache for a specific supplier after update
notifier.invalidateCache(supplierId: 123);

// Get cache statistics for debugging
final stats = notifier.getCacheStats();
print('Cache stats: ${stats.hits} hits, ${stats.misses} misses');
*/
