import 'package:flutter/material.dart';
import 'package:gluttex_core/business/Delivery.dart';
import 'package:gluttex_core/business/services/DeliveryService.dart';
import 'package:collection/collection.dart';

// ============================================================================
// COMPONENT IMPORTS (would be in separate files)
// ============================================================================

// delivery_state.dart
class DeliveryState {
  final List<Delivery> deliveries = [];
  final List<Delivery> searchResults = [];
  int currentPage = 0;
  bool isLoading = false;
  bool hasMore = true;
  String? lastError;
  String searchQuery = '';
  int providerId = 0;
  int orderId = 0;
  int brokerId = 0;
  int itemsPerPage = 10;
  bool isInitialized = false;

  void reset() {
    deliveries.clear();
    searchResults.clear();
    currentPage = 0;
    isLoading = false;
    hasMore = true;
    lastError = null;
    searchQuery = '';
    providerId = 0;
    orderId = 0;
    brokerId = 0;
    isInitialized = false;
  }

  void resetPagination() {
    currentPage = 0;
    hasMore = true;
    deliveries.clear();
  }

  void setLoading(bool loading) => isLoading = loading;
  void setError(String? error) => lastError = error;
  void clearError() => lastError = null;
  void setSearchQuery(String query) => searchQuery = query;
}

// delivery_cache.dart
class DeliveryCache {
  final Map<int, Delivery> _deliveryCache = {};
  final Map<String, List<Delivery>> _listCache = {};
  bool _enabled = true;

  bool get isEnabled => _enabled;

  void enable(bool enable) => _enabled = enable;

  void cacheDelivery(Delivery delivery) {
    if (!_enabled) return;
    _deliveryCache[delivery.id_delivery] = delivery;
  }

  Delivery? getDelivery(int id) => _deliveryCache[id];

  void cacheDeliveries(String key, List<Delivery> deliveries) {
    if (!_enabled) return;
    _listCache[key] = deliveries;
    for (final delivery in deliveries) {
      cacheDelivery(delivery);
    }
  }

  List<Delivery>? getDeliveries(String key) => _listCache[key];

  void invalidateDelivery(int id) {
    _deliveryCache.remove(id);
  }

  void invalidateList(String key) {
    _listCache.remove(key);
  }

  void clearAll() {
    _deliveryCache.clear();
    _listCache.clear();
  }

  int get deliveryCacheSize => _deliveryCache.length;
  int get listCacheSize => _listCache.length;
}

// delivery_crud.dart
class DeliveryCrud {
  final DeliveryService _service;
  final DeliveryCache _cache;
  final DeliveryState _state;

  DeliveryCrud({
    required DeliveryService service,
    required DeliveryCache cache,
    required DeliveryState state,
  })  : _service = service,
        _cache = cache,
        _state = state;

  Future<Delivery?> create(Map<String, dynamic> deliveryData) async {
    try {
      final result = await _service.addDelivery(deliveryData);
      if (result != null) {
        _cache.cacheDelivery(result);
        return result;
      }
      return null;
    } catch (e) {
      _state.setError('Error creating delivery: $e');
      debugPrint('Error creating delivery: $e');
      return null;
    }
  }

  Future<Delivery?> update(Delivery delivery) async {
    try {
      final result = await _service.updateDelivery(delivery);
      if (result != null) {
        _cache.cacheDelivery(result);
        return result;
      }
      return null;
    } catch (e) {
      _state.setError('Error updating delivery: $e');
      debugPrint('Error updating delivery: $e');
      return null;
    }
  }

  Future<int?> delete(String deliveryId) async {
    try {
      final result = await _service.deleteDelivery(deliveryId);
      if (result != null && result >= 200 && result < 300) {
        _cache.invalidateDelivery(int.parse(deliveryId));
        return result;
      }
      return null;
    } catch (e) {
      _state.setError('Error deleting delivery: $e');
      debugPrint('Error deleting delivery: $e');
      return null;
    }
  }
}

// delivery_fetch.dart
class DeliveryFetch {
  final DeliveryService _service;
  final DeliveryCache _cache;
  final DeliveryState _state;

  DeliveryFetch({
    required DeliveryService service,
    required DeliveryCache cache,
    required DeliveryState state,
  })  : _service = service,
        _cache = cache,
        _state = state;

  Future<void> fetchDeliveries({
    int providerId = 0,
    int orderId = 0,
    int brokerId = 0,
    String query = '',
    bool reset = false,
  }) async {
    debugPrint(
        '🚚 Fetching deliveries (providerId: $providerId, orderId: $orderId, brokerId: $brokerId, query: "$query", reset: $reset, page: ${_state.currentPage})');

    if (_state.isLoading) {
      debugPrint('⏳ Delivery fetch already in progress, skipping request');
      return;
    }

    final paramsChanged = reset ||
        _state.providerId != providerId ||
        _state.orderId != orderId ||
        _state.brokerId != brokerId ||
        _state.searchQuery != query;

    if (paramsChanged) {
      _state.providerId = providerId;
      _state.orderId = orderId;
      _state.brokerId = brokerId;
      _state.searchQuery = query;
      _state.resetPagination();
    }

    final cacheKey = _generateCacheKey(providerId, orderId, brokerId, query);

    if (query.isEmpty && !reset && _state.currentPage == 0) {
      final cached = _cache.getDeliveries(cacheKey);
      if (cached != null && cached.isNotEmpty) {
        debugPrint(
            '📦 Using cached deliveries: ${cached.length} (key: $cacheKey)');
        _state.deliveries.clear();
        _state.deliveries.addAll(cached);
        _state.currentPage = 1;
        _state.hasMore = cached.length >= _state.itemsPerPage;
        _state.clearError();
        return;
      }
    }

    _state.setLoading(true);
    _state.clearError();

    try {
      final offset = _state.currentPage * _state.itemsPerPage;
      debugPrint(
          '📡 Calling deliveries API (offset: $offset, limit: ${_state.itemsPerPage}, providerId: $providerId, orderId: $orderId, brokerId: $brokerId)');
      final fetchedDeliveries = await _service.getAllDeliveries(
        offset,
        _state.itemsPerPage,
        providerId: providerId,
        orderId: orderId,
        brokerId: brokerId,
      );
      debugPrint(
          '📡 API returned ${fetchedDeliveries.length} deliveries (providerId: $providerId, offset: $offset)');

      if (fetchedDeliveries.isEmpty) {
        _state.hasMore = false;
      } else {
        if (_state.currentPage == 0) {
          _state.deliveries.clear();
        }
        _state.deliveries.addAll(fetchedDeliveries);
        _state.currentPage++;
        _state.hasMore = fetchedDeliveries.length == _state.itemsPerPage;
        _cache.cacheDeliveries(cacheKey, fetchedDeliveries);
      }

      _state.clearError();
    } catch (e) {
      _state.setError('Error fetching deliveries: $e');
      debugPrint('❌ Error fetching deliveries: $e');
    } finally {
      _state.setLoading(false);
      debugPrint(
          '📦 Total deliveries: ${_state.deliveries.length} (hasMore: ${_state.hasMore})');
    }
  }

  Future<Delivery?> getById(int id, {bool forceRefresh = false}) async {
    // Check cache first
    if (!forceRefresh) {
      final cached = _cache.getDelivery(id);
      if (cached != null) return cached;
    }

    try {
      final delivery = await _service.getDelivery(id.toString());
      if (delivery != null) {
        _cache.cacheDelivery(delivery);
        return delivery;
      }
      return null;
    } catch (e) {
      _state.setError('Error fetching delivery: $e');
      debugPrint('Error fetching delivery: $e');
      return null;
    }
  }

  Delivery? getByIdSync(int id) => _cache.getDelivery(id);

  String _generateCacheKey(
      int providerId, int orderId, int brokerId, String query) {
    return 'deliveries_${providerId}_${orderId}_${brokerId}_$query';
  }
}

// ============================================================================
// MAIN NOTIFIER
// ============================================================================

class DeliveryChangeNotifier extends ChangeNotifier {
  final DeliveryService _service;
  bool _fetchInProgress = false;
  Map<String, dynamic>? _activeFetch;
  Map<String, dynamic>? _pendingFetch;

  // Components
  late final DeliveryState _state;
  late final DeliveryCache _cache;
  late final DeliveryCrud _crud;
  late final DeliveryFetch _fetch;

  DeliveryChangeNotifier(
      {required DeliveryService service, bool autoFetch = true})
      : _service = service {
    _initComponents();
    if (autoFetch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetch.fetchDeliveries(reset: true);
      });
    }
  }

  void _initComponents() {
    _state = DeliveryState();
    _cache = DeliveryCache();
    _crud = DeliveryCrud(
      service: _service,
      cache: _cache,
      state: _state,
    );
    _fetch = DeliveryFetch(
      service: _service,
      cache: _cache,
      state: _state,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ============ SAFE NOTIFICATION ============
  void _safeNotify() {
    if (!_state.isLoading && hasListeners) {
      notifyListeners();
    }
  }

  void _notify() {
    if (!_state.isLoading) {
      _safeNotify();
    }
  }

  // ============ PUBLIC GETTERS ============
  List<Delivery> get deliveries => _state.deliveries;
  List<Delivery> get searchResults => _state.searchResults;
  bool get isLoading => _state.isLoading;
  bool get hasMore => _state.hasMore;
  int get currentPage => _state.currentPage;
  String? get lastError => _state.lastError;
  String get searchQuery => _state.searchQuery;
  int get providerId => _state.providerId;
  int get currentProviderId => _state.providerId;
  int get orderId => _state.orderId;
  int get brokerId => _state.brokerId;

  // ============ STATUS-BASED ACCESSORS ============
  List<Delivery> get pendingDeliveries {
    return _state.deliveries
        .where((d) => d.delivery_status.toUpperCase() == 'PENDING')
        .toList();
  }

  List<Delivery> get deliveredDeliveries {
    return _state.deliveries
        .where((d) => d.delivery_status.toUpperCase() == 'DELIVERED')
        .toList();
  }

  Map<String, List<Delivery>> get groupedByStatus {
    return groupBy(_state.deliveries, (Delivery d) => d.delivery_status);
  }

  // ============ STATISTICS ============
  int get totalDeliveries => _state.deliveries.length;
  int get pendingCount => pendingDeliveries.length;
  int get deliveredCount => deliveredDeliveries.length;

  int get cancelledCount {
    return _state.deliveries
        .where((d) => d.delivery_status.toUpperCase() == 'CANCELLED')
        .length;
  }

  double get totalWeight {
    return _state.deliveries
        .fold(0.0, (sum, d) => sum + (d.delivery_total_weight ?? 0));
  }

  int get totalPackages {
    return _state.deliveries
        .fold(0, (sum, d) => sum + (d.delivery_package_count ?? 0));
  }

  // ============ FILTER OPERATIONS ============
  Future<void> setFilters(
      {int providerId = 0, int orderId = 0, int brokerId = 0}) {
    _state.providerId = providerId;
    _state.orderId = orderId;
    _state.brokerId = brokerId;
    return fetchDeliveries(
      providerId: providerId,
      orderId: orderId,
      brokerId: brokerId,
      reset: true,
    );
  }

  void clearFilters() {
    _state.providerId = 0;
    _state.orderId = 0;
    _state.brokerId = 0;
    fetchDeliveries(
      providerId: 0,
      orderId: 0,
      brokerId: 0,
      reset: true,
    );
  }

  // ============ FETCH OPERATIONS ============
  Future<void> fetchDeliveries({
    int providerId = 0,
    int orderId = 0,
    int brokerId = 0,
    String query = '',
    bool reset = false,
  }) async {
    debugPrint(
        '🚚 Delivery fetch requested (providerId: $providerId, orderId: $orderId, brokerId: $brokerId, query: "$query", reset: $reset)');

    if (_fetchInProgress) {
      final pendingFetch = {
        'providerId': providerId,
        'orderId': orderId,
        'brokerId': brokerId,
        'query': query,
        'reset': reset,
      };
      if (!_requestsMatch(_activeFetch, pendingFetch) &&
          !_requestsMatch(_pendingFetch, pendingFetch)) {
        _pendingFetch = pendingFetch;
      }
      debugPrint(
          '⏳ Queued delivery fetch (providerId: $providerId, orderId: $orderId, brokerId: $brokerId)');
      return;
    }

    _fetchInProgress = true;
    try {
      do {
        final request = _pendingFetch ??
            {
              'providerId': providerId,
              'orderId': orderId,
              'brokerId': brokerId,
              'query': query,
              'reset': reset,
            };
        _pendingFetch = null;
        _activeFetch = request;

        debugPrint(
            '🔄 Executing delivery fetch (providerId: ${request['providerId']}, orderId: ${request['orderId']}, brokerId: ${request['brokerId']}, reset: ${request['reset']})');

        await _fetch.fetchDeliveries(
          providerId: request['providerId'] as int,
          orderId: request['orderId'] as int,
          brokerId: request['brokerId'] as int,
          query: request['query'] as String,
          reset: request['reset'] as bool,
        );
        _notify();
      } while (_pendingFetch != null);
    } finally {
      _fetchInProgress = false;
      _activeFetch = null;
      debugPrint('✅ Delivery fetch cycle finished');
    }
  }

  bool _requestsMatch(
      Map<String, dynamic>? first, Map<String, dynamic> second) {
    if (first == null) return false;
    return first['providerId'] == second['providerId'] &&
        first['orderId'] == second['orderId'] &&
        first['brokerId'] == second['brokerId'] &&
        first['query'] == second['query'] &&
        first['reset'] == second['reset'];
  }

  Future<void> fetchFirstPage() async {
    await fetchDeliveries(
      providerId: _state.providerId,
      orderId: _state.orderId,
      brokerId: _state.brokerId,
      query: _state.searchQuery,
      reset: true,
    );
  }

  Future<void> fetchNextPage() async {
    if (_state.isLoading || !_state.hasMore) return;
    await fetchDeliveries(
      providerId: _state.providerId,
      orderId: _state.orderId,
      brokerId: _state.brokerId,
    );
  }

  Future<Delivery?> getDeliveryById(int id, {bool forceRefresh = false}) async {
    return _fetch.getById(id, forceRefresh: forceRefresh);
  }

  Delivery? getDeliveryByIdSync(int id) => _fetch.getByIdSync(id);

  // ============ SEARCH OPERATIONS ============
  Future<void> searchDeliveries(String query) async {
    _state.setSearchQuery(query);
    if (query.isEmpty) {
      _state.searchResults.clear();
      await fetchDeliveries(
        providerId: _state.providerId,
        orderId: _state.orderId,
        brokerId: _state.brokerId,
        reset: true,
      );
      return;
    }

    // Filter existing deliveries by search query
    final filtered = _state.deliveries.where((d) {
      final searchTerm = query.toLowerCase();
      return d.id_delivery.toString().contains(searchTerm) ||
          (d.delivery_merchant_name?.toLowerCase().contains(searchTerm) ??
              false) ||
          (d.delivery_goods_description?.toLowerCase().contains(searchTerm) ??
              false) ||
          d.delivery_status.toLowerCase().contains(searchTerm) ||
          (d.delivery_source_type?.toLowerCase().contains(searchTerm) ?? false);
    }).toList();

    _state.searchResults.clear();
    _state.searchResults.addAll(filtered);
    _notify();
  }

  void clearSearch() {
    _state.searchQuery = '';
    _state.searchResults.clear();
    _notify();
  }

  // ============ CRUD OPERATIONS ============
  Future<bool> createDelivery(Map<String, dynamic> deliveryData) async {
    if (_state.isLoading) return false;

    _state.setLoading(true);
    _state.clearError();

    try {
      final result = await _crud.create(deliveryData);
      if (result != null) {
        _state.deliveries.insert(0, result);
        if (_state.searchQuery.isNotEmpty) {
          _state.searchResults.insert(0, result);
        }
        _notify();
        return true;
      }
      return false;
    } catch (e) {
      _state.setError('Error creating delivery: $e');
      debugPrint('Error creating delivery: $e');
      return false;
    } finally {
      _state.setLoading(false);
    }
  }

  Future<bool> updateDelivery(Delivery updatedDelivery) async {
    if (_state.isLoading) return false;

    _state.setLoading(true);
    _state.clearError();

    try {
      final result = await _crud.update(updatedDelivery);
      if (result != null) {
        final index = _state.deliveries
            .indexWhere((d) => d.id_delivery == updatedDelivery.id_delivery);
        if (index != -1) {
          _state.deliveries[index] = result;
          final searchIndex = _state.searchResults
              .indexWhere((d) => d.id_delivery == updatedDelivery.id_delivery);
          if (searchIndex != -1) {
            _state.searchResults[searchIndex] = result;
          }
          _notify();
          return true;
        }
      }
      return false;
    } catch (e) {
      _state.setError('Error updating delivery: $e');
      debugPrint('Error updating delivery: $e');
      return false;
    } finally {
      _state.setLoading(false);
    }
  }

  Future<bool> updateDeliveryStatus(int deliveryId, String newStatus) async {
    if (_state.isLoading) return false;

    _state.setLoading(true);
    _state.clearError();

    try {
      final delivery = getDeliveryByIdSync(deliveryId);
      if (delivery == null) {
        _state.setError('Delivery not found');
        return false;
      }

      final updatedDelivery = delivery.copyWith(
        delivery_status: newStatus,
        delivery_updated_at: DateTime.now(),
      );

      final result = await _crud.update(updatedDelivery);
      if (result != null) {
        final index =
            _state.deliveries.indexWhere((d) => d.id_delivery == deliveryId);
        if (index != -1) {
          _state.deliveries[index] = result;
          final searchIndex = _state.searchResults
              .indexWhere((d) => d.id_delivery == deliveryId);
          if (searchIndex != -1) {
            _state.searchResults[searchIndex] = result;
          }
          _notify();
          return true;
        }
      }
      return false;
    } catch (e) {
      _state.setError('Error updating delivery status: $e');
      debugPrint('Error updating delivery status: $e');
      return false;
    } finally {
      _state.setLoading(false);
    }
  }

  Future<bool> cancelDelivery(int deliveryId) async {
    return updateDeliveryStatus(deliveryId, 'CANCELLED');
  }

  Future<bool> deleteDelivery(int deliveryId,
      {bool forceDelete = false}) async {
    if (_state.isLoading) return false;

    _state.setLoading(true);
    _state.clearError();

    try {
      final result = await _crud.delete(deliveryId.toString());
      if (result != null) {
        _state.deliveries.removeWhere((d) => d.id_delivery == deliveryId);
        _state.searchResults.removeWhere((d) => d.id_delivery == deliveryId);
        _notify();
        return true;
      }
      return false;
    } catch (e) {
      _state.setError('Error deleting delivery: $e');
      debugPrint('Error deleting delivery: $e');
      return false;
    } finally {
      _state.setLoading(false);
    }
  }

  // ============ UTILITY METHODS ============
  List<Delivery> getDeliveriesByStatus(String status) {
    final source = _state.searchQuery.isNotEmpty
        ? _state.searchResults
        : _state.deliveries;

    if (status.toUpperCase() == 'ALL' || status.isEmpty) {
      return source;
    }

    return source
        .where((d) => d.delivery_status.toUpperCase() == status.toUpperCase())
        .toList();
  }

  void clearDeliveries() {
    _state.reset();
    _cache.clearAll();
    _notify();
  }

  // ============ REFRESH METHODS ============
  Future<void> refreshDeliveries() async {
    await fetchDeliveries(
      providerId: _state.providerId,
      orderId: _state.orderId,
      brokerId: _state.brokerId,
      reset: true,
    );
    if (_state.searchQuery.isNotEmpty) {
      await searchDeliveries(_state.searchQuery);
    }
  }

  Future<void> refreshDelivery(int deliveryId) async {
    await getDeliveryById(deliveryId, forceRefresh: true);
  }

  // ============ BULK OPERATIONS ============
  Future<bool> bulkUpdateStatus(List<int> deliveryIds, String status) async {
    if (_state.isLoading || deliveryIds.isEmpty) return false;

    _state.setLoading(true);
    _state.clearError();

    try {
      int successCount = 0;
      for (final id in deliveryIds) {
        final delivery = getDeliveryByIdSync(id);
        if (delivery != null) {
          final updated = delivery.copyWith(
            delivery_status: status,
            delivery_updated_at: DateTime.now(),
          );
          final result = await _crud.update(updated);
          if (result != null) {
            final index =
                _state.deliveries.indexWhere((d) => d.id_delivery == id);
            if (index != -1) {
              _state.deliveries[index] = result;
              final searchIndex =
                  _state.searchResults.indexWhere((d) => d.id_delivery == id);
              if (searchIndex != -1) {
                _state.searchResults[searchIndex] = result;
              }
              successCount++;
            }
          }
        }
      }

      _notify();
      return successCount == deliveryIds.length;
    } catch (e) {
      _state.setError('Error updating delivery statuses: $e');
      debugPrint('Error updating delivery statuses: $e');
      return false;
    } finally {
      _state.setLoading(false);
    }
  }

  // ============ FILTER METHODS ============
  Future<void> fetchDeliveriesByProvider(int providerId) async {
    _state.providerId = providerId;
    await fetchDeliveries(reset: true);
  }

  Future<void> fetchDeliveriesByOrder(int orderId) async {
    _state.orderId = orderId;
    await fetchDeliveries(reset: true);
  }

  Future<void> fetchDeliveriesByBroker(int brokerId) async {
    _state.brokerId = brokerId;
    await fetchDeliveries(reset: true);
  }

  // ============ CACHE MANAGEMENT ============
  void enableCaching(bool enable) {
    _cache.enable(enable);
    _notify();
  }

  void invalidateDeliveryCache({int? deliveryId}) {
    if (deliveryId != null) {
      _cache.invalidateDelivery(deliveryId);
    } else {
      _cache.clearAll();
    }
    _notify();
  }

  void refreshAllCaches() {
    _cache.clearAll();
    _notify();
  }

  // ============ STATE RESET ============
  void reset() {
    _state.reset();
    _cache.clearAll();
    _notify();
  }

  // ============ CACHE STATS ============
  Map<String, int> getCacheStats() {
    return {
      'deliveryCache': _cache.deliveryCacheSize,
      'listCache': _cache.listCacheSize,
    };
  }
}
