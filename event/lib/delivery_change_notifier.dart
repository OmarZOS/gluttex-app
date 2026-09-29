// delivery_change_notifier.dart
//
// DeliveryChangeNotifier — single owner of the delivery list, its cache,
// and its in-flight fetch queue.
//
// The notifier talks only to the abstract `DeliveryService`. It never
// casts to an impl, never references `DeliveryServiceImpl`, and never
// holds a concrete class. Whatever the locator registers — real impl,
// fake for tests, decorator for logging — is a DeliveryService.
//
// Ops mirror the router one-for-one: one method per named action, each
// taking an optional `body` (Delivery_API-shaped). Reads go through
// `DeliveryFetch`, which also talks to the abstract.

import 'package:flutter/material.dart';
import 'package:gluttex_core/business/Delivery.dart';
import 'package:gluttex_core/business/services/DeliveryService.dart';
import 'package:locator/locator.dart';
import 'package:collection/collection.dart';

// ============================================================================
// STATE
// ============================================================================

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

  void setLoading(bool v) => isLoading = v;
  void setError(String? v) => lastError = v;
  void clearError() => lastError = null;
  void setSearchQuery(String q) => searchQuery = q;
}

// ============================================================================
// CACHE
// ============================================================================

class DeliveryCache {
  final Map<int, Delivery> _deliveryCache = {};
  final Map<String, List<Delivery>> _listCache = {};
  bool _enabled = true;

  bool get isEnabled => _enabled;
  void enable(bool v) => _enabled = v;

  void cacheDelivery(Delivery d) {
    if (!_enabled) return;
    _deliveryCache[d.id_delivery] = d;
  }

  Delivery? getDelivery(int id) => _deliveryCache[id];

  void cacheDeliveries(String key, List<Delivery> list) {
    if (!_enabled) return;
    _listCache[key] = list;
    for (final d in list) {
      cacheDelivery(d);
    }
  }

  List<Delivery>? getDeliveries(String key) => _listCache[key];

  void invalidateDelivery(int id) => _deliveryCache.remove(id);
  void invalidateList(String key) => _listCache.remove(key);

  void clearAll() {
    _deliveryCache.clear();
    _listCache.clear();
  }

  int get deliveryCacheSize => _deliveryCache.length;
  int get listCacheSize => _listCache.length;
}

// ============================================================================
// FETCH — reads
// ============================================================================

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
        '🚚 Fetching deliveries (providerId: $providerId, orderId: $orderId, '
        'brokerId: $brokerId, query: "$query", reset: $reset, '
        'page: ${_state.currentPage})');

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
        _state.deliveries
          ..clear()
          ..addAll(cached);
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
      debugPrint('📡 Calling deliveries API (offset: $offset, '
          'limit: ${_state.itemsPerPage}, providerId: $providerId, '
          'orderId: $orderId, brokerId: $brokerId)');

      final fetched = await _service.getAllDeliveries(
        offset,
        _state.itemsPerPage,
        providerId: providerId,
        orderId: orderId,
        brokerId: brokerId,
      );

      debugPrint('📡 API returned ${fetched.length} deliveries '
          '(providerId: $providerId, offset: $offset)');

      if (fetched.isEmpty) {
        _state.hasMore = false;
      } else {
        if (_state.currentPage == 0) {
          _state.deliveries.clear();
        }
        _state.deliveries.addAll(fetched);
        _state.currentPage++;
        _state.hasMore = fetched.length == _state.itemsPerPage;
        _cache.cacheDeliveries(cacheKey, fetched);
      }

      _state.clearError();
    } catch (e) {
      _state.setError('Error fetching deliveries: $e');
      debugPrint('❌ Error fetching deliveries: $e');
    } finally {
      _state.setLoading(false);
      debugPrint('📦 Total deliveries: ${_state.deliveries.length} '
          '(hasMore: ${_state.hasMore})');
    }
  }

  Future<Delivery?> getById(int id, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _cache.getDelivery(id);
      if (cached != null) return cached;
    }
    try {
      final d = await _service.getDelivery(id.toString());
      if (d != null) {
        _cache.cacheDelivery(d);
        return d;
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
          int providerId, int orderId, int brokerId, String query) =>
      'deliveries_${providerId}_${orderId}_${brokerId}_$query';
}

// ============================================================================
// NOTIFIER
// ============================================================================

class DeliveryChangeNotifier extends ChangeNotifier {
  /// The abstract contract. Whatever the locator registers is a
  /// DeliveryService — no cast, no impl reference, no `is` check.
  final DeliveryService _service;

  // In-flight fetch queue. A second fetch with different params while
  // one is running gets stashed and replayed when the first finishes.
  bool _fetchInProgress = false;
  Map<String, dynamic>? _activeFetch;
  Map<String, dynamic>? _pendingFetch;

  late final DeliveryState _state;
  late final DeliveryCache _cache;
  late final DeliveryFetch _fetch;

  DeliveryChangeNotifier({
    DeliveryService? service,
    bool autoFetch = true,
  }) : _service = service ?? AppLocator.get<DeliveryService>() {
    _state = DeliveryState();
    _cache = DeliveryCache();
    _fetch = DeliveryFetch(service: _service, cache: _cache, state: _state);

    if (autoFetch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        fetchDeliveries(reset: true);
      });
    }
  }

  // ── Notification ───────────────────────────────────────────────

  void _safeNotify() {
    if (!_state.isLoading && hasListeners) notifyListeners();
  }

  void _notify() {
    if (!_state.isLoading) _safeNotify();
  }

  // ── Getters ────────────────────────────────────────────────────

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

  // ── Status shortcuts ───────────────────────────────────────────

  List<Delivery> get pendingDeliveries => _state.deliveries
      .where((d) => d.delivery_status.wireValue.toUpperCase() == 'PENDING')
      .toList();

  List<Delivery> get deliveredDeliveries => _state.deliveries
      .where((d) => d.delivery_status.wireValue.toUpperCase() == 'DELIVERED')
      .toList();

  Map<String, List<Delivery>> get groupedByStatus =>
      groupBy(_state.deliveries, (Delivery d) => d.delivery_status.wireValue);

  // ── Statistics ─────────────────────────────────────────────────

  int get totalDeliveries => _state.deliveries.length;
  int get pendingCount => pendingDeliveries.length;
  int get deliveredCount => deliveredDeliveries.length;

  int get cancelledCount => _state.deliveries
      .where((d) => d.delivery_status.wireValue.toUpperCase() == 'CANCELLED')
      .length;

  double get totalWeight => _state.deliveries
      .fold(0.0, (sum, d) => sum + (d.delivery_total_weight ?? 0));

  int get totalPackages => _state.deliveries
      .fold(0, (sum, d) => sum + (d.delivery_package_count ?? 0));

  // ── Filters ────────────────────────────────────────────────────

  Future<void> setFilters({
    int providerId = 0,
    int orderId = 0,
    int brokerId = 0,
  }) {
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
    fetchDeliveries(reset: true);
  }

  // ── Fetch ──────────────────────────────────────────────────────

  Future<void> fetchDeliveries({
    int providerId = 0,
    int orderId = 0,
    int brokerId = 0,
    String query = '',
    bool reset = false,
  }) async {
    debugPrint('🚚 Delivery fetch requested (providerId: $providerId, '
        'orderId: $orderId, brokerId: $brokerId, query: "$query", '
        'reset: $reset)');

    if (_fetchInProgress) {
      final pending = {
        'providerId': providerId,
        'orderId': orderId,
        'brokerId': brokerId,
        'query': query,
        'reset': reset,
      };
      if (!_requestsMatch(_activeFetch, pending) &&
          !_requestsMatch(_pendingFetch, pending)) {
        _pendingFetch = pending;
      }
      debugPrint('⏳ Queued delivery fetch (providerId: $providerId, '
          'orderId: $orderId, brokerId: $brokerId)');
      return;
    }

    _fetchInProgress = true;
    try {
      do {
        final req = _pendingFetch ??
            {
              'providerId': providerId,
              'orderId': orderId,
              'brokerId': brokerId,
              'query': query,
              'reset': reset,
            };
        _pendingFetch = null;
        _activeFetch = req;

        debugPrint('🔄 Executing delivery fetch '
            '(providerId: ${req['providerId']}, '
            'orderId: ${req['orderId']}, '
            'brokerId: ${req['brokerId']}, reset: ${req['reset']})');

        await _fetch.fetchDeliveries(
          providerId: req['providerId'] as int,
          orderId: req['orderId'] as int,
          brokerId: req['brokerId'] as int,
          query: req['query'] as String,
          reset: req['reset'] as bool,
        );
        _notify();
      } while (_pendingFetch != null);
    } finally {
      _fetchInProgress = false;
      _activeFetch = null;
      debugPrint('✅ Delivery fetch cycle finished');
    }
  }

  bool _requestsMatch(Map<String, dynamic>? a, Map<String, dynamic> b) {
    if (a == null) return false;
    return a['providerId'] == b['providerId'] &&
        a['orderId'] == b['orderId'] &&
        a['brokerId'] == b['brokerId'] &&
        a['query'] == b['query'] &&
        a['reset'] == b['reset'];
  }

  Future<void> fetchFirstPage() => fetchDeliveries(
        providerId: _state.providerId,
        orderId: _state.orderId,
        brokerId: _state.brokerId,
        query: _state.searchQuery,
        reset: true,
      );

  Future<void> fetchNextPage() async {
    if (_state.isLoading || !_state.hasMore) return;
    await fetchDeliveries(
      providerId: _state.providerId,
      orderId: _state.orderId,
      brokerId: _state.brokerId,
    );
  }

  Future<Delivery?> getDeliveryById(int id, {bool forceRefresh = false}) =>
      _fetch.getById(id, forceRefresh: forceRefresh);

  Delivery? getDeliveryByIdSync(int id) => _fetch.getByIdSync(id);

  // ── Search ─────────────────────────────────────────────────────

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

    final term = query.toLowerCase();
    final filtered = _state.deliveries.where((d) {
      return d.id_delivery.toString().contains(term) ||
          (d.delivery_merchant_name?.toLowerCase().contains(term) ?? false) ||
          (d.delivery_goods_description?.toLowerCase().contains(term) ??
              false) ||
          d.delivery_status.wireValue.toLowerCase().contains(term) ||
          (d.delivery_source_type?.toLowerCase().contains(term) ?? false);
    }).toList();

    _state.searchResults
      ..clear()
      ..addAll(filtered);
    _notify();
  }

  void clearSearch() {
    _state.searchQuery = '';
    _state.searchResults.clear();
    _notify();
  }

  // ── CREATE ─────────────────────────────────────────────────────

  Future<bool> createDelivery(Map<String, dynamic> deliveryData) async {
    if (_state.isLoading) return false;
    _state.setLoading(true);
    _state.clearError();
    try {
      final result = await _service.addDelivery(deliveryData);
      if (result == null) return false;

      _cache.cacheDelivery(result);
      _state.deliveries.insert(0, result);
      if (_state.searchQuery.isNotEmpty) {
        _state.searchResults.insert(0, result);
      }
      _notify();
      return true;
    } catch (e) {
      _state.setError('Error creating delivery: $e');
      debugPrint('Error creating delivery: $e');
      return false;
    } finally {
      _state.setLoading(false);
    }
  }

  // ── OPS ────────────────────────────────────────────────────────
  //
  // One private helper does the loading/error/notify dance. Every
  // public op is a one-liner that picks the abstract method. No
  // cast, no impl reference, no `is` check.

  Future<bool> _runOp(
    Future<Delivery?> Function() call,
    String label,
  ) async {
    if (_state.isLoading) return false;
    _state.setLoading(true);
    _state.clearError();
    try {
      final result = await call();
      if (result == null) return false;

      _cache.cacheDelivery(result);
      final i = _state.deliveries
          .indexWhere((d) => d.id_delivery == result.id_delivery);
      if (i != -1) _state.deliveries[i] = result;

      final si = _state.searchResults
          .indexWhere((d) => d.id_delivery == result.id_delivery);
      if (si != -1) _state.searchResults[si] = result;

      _notify();
      return true;
    } catch (e) {
      _state.setError('Error in [$label]: $e');
      debugPrint('Delivery op [$label] failed: $e');
      return false;
    } finally {
      _state.setLoading(false);
    }
  }

  Future<bool> acceptDelivery(int id, {Map<String, dynamic>? body}) =>
      _runOp(() => _service.acceptDelivery(id, body: body), 'accept');

  Future<bool> confirmDelivery(int id, {Map<String, dynamic>? body}) =>
      _runOp(() => _service.confirmDelivery(id, body: body), 'confirm');

  Future<bool> shipDelivery(int id, {Map<String, dynamic>? body}) =>
      _runOp(() => _service.shipDelivery(id, body: body), 'ship');

  Future<bool> markInTransit(int id, {Map<String, dynamic>? body}) =>
      _runOp(() => _service.markInTransit(id, body: body), 'in-transit');

  Future<bool> markOutForDelivery(int id, {Map<String, dynamic>? body}) =>
      _runOp(() => _service.markOutForDelivery(id, body: body),
          'out-for-delivery');

  Future<bool> deliverDelivery(
    int id, {
    bool? proofCaptured,
    Map<String, dynamic>? body,
  }) =>
      _runOp(
        () => _service.deliverDelivery(
          id,
          proofCaptured: proofCaptured,
          body: body,
        ),
        'deliver',
      );

  Future<bool> cancelDelivery(
    int id, {
    String? reason,
    Map<String, dynamic>? body,
  }) =>
      _runOp(
        () => _service.cancelDelivery(id, reason: reason, body: body),
        'cancel',
      );

  Future<bool> failDelivery(
    int id, {
    bool? failureReported,
    String? reason,
    Map<String, dynamic>? body,
  }) =>
      _runOp(
        () => _service.failDelivery(
          id,
          failureReported: failureReported,
          reason: reason,
          body: body,
        ),
        'fail',
      );

  Future<bool> updateDetails(int id, {Map<String, dynamic>? body}) => _runOp(
        () => _service.updateDetails(id, body: body),
        'details',
      );

  Future<bool> returnDelivery(
    int id, {
    bool? returnConfirmed,
    Map<String, dynamic>? body,
  }) =>
      _runOp(
        () => _service.returnDelivery(
          id,
          returnConfirmed: returnConfirmed,
          body: body,
        ),
        'return',
      );

  Future<bool> refundDelivery(
    int id, {
    bool? refundCompleted,
    Map<String, dynamic>? body,
  }) =>
      _runOp(
        () => _service.refundDelivery(
          id,
          refundCompleted: refundCompleted,
          body: body,
        ),
        'refund',
      );

  Future<bool> archiveDelivery(int id) =>
      _runOp(() => _service.archiveDelivery(id), 'archive');

  Future<bool> recordTrackingPing(int id, int addressId) =>
      _runOp(() => _service.recordTrackingPing(id, addressId), 'tracking');

  Future<bool> rerouteDelivery(int id, int addressId) =>
      _runOp(() => _service.rerouteDelivery(id, addressId), 'reroute');

  Future<List<String>?> nextStates(int id) => _service.nextStates(id);

  // ── BULK ───────────────────────────────────────────────────────
  //
  // Iterates the abstract method. No impl cast, no private method
  // access, no bulk endpoint on the router side to call.

  Future<({int ok, List<int> failed})> bulkRun(
    Future<Delivery?> Function(int id) call,
    String label,
    List<int> ids,
  ) async {
    if (_state.isLoading || ids.isEmpty) {
      return (ok: 0, failed: List<int>.from(ids));
    }
    _state.setLoading(true);
    _state.clearError();

    var ok = 0;
    final failed = <int>[];

    try {
      for (final id in ids) {
        try {
          final result = await call(id);
          if (result == null) {
            failed.add(id);
            continue;
          }
          _cache.cacheDelivery(result);
          final i = _state.deliveries
              .indexWhere((d) => d.id_delivery == result.id_delivery);
          if (i != -1) _state.deliveries[i] = result;
          final si = _state.searchResults
              .indexWhere((d) => d.id_delivery == result.id_delivery);
          if (si != -1) _state.searchResults[si] = result;
          ok++;
        } catch (e) {
          debugPrint('Bulk [$label] failed for $id: $e');
          failed.add(id);
        }
      }
      _notify();
      return (ok: ok, failed: failed);
    } finally {
      _state.setLoading(false);
    }
  }

  Future<({int ok, List<int> failed})> bulkCancel(List<int> ids) =>
      bulkRun((id) => _service.cancelDelivery(id), 'cancel', ids);

  Future<({int ok, List<int> failed})> bulkDeliver(List<int> ids) => bulkRun(
        (id) => _service.deliverDelivery(id, proofCaptured: true),
        'deliver',
        ids,
      );

  Future<({int ok, List<int> failed})> bulkFail(List<int> ids) => bulkRun(
        (id) => _service.failDelivery(id, failureReported: true),
        'fail',
        ids,
      );

  // ── Status helpers ─────────────────────────────────────────────

  List<Delivery> getDeliveriesByStatus(String status) {
    final source = _state.searchQuery.isNotEmpty
        ? _state.searchResults
        : _state.deliveries;
    if (status.toUpperCase() == 'ALL' || status.isEmpty) return source;
    return source
        .where((d) =>
            d.delivery_status.wireValue.toUpperCase() == status.toUpperCase())
        .toList();
  }

  void clearDeliveries() {
    _state.reset();
    _cache.clearAll();
    _notify();
  }

  // ── Refresh ────────────────────────────────────────────────────

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

  Future<void> refreshDelivery(int id) =>
      getDeliveryById(id, forceRefresh: true);

  // ── Filter shortcuts ───────────────────────────────────────────

  Future<void> fetchDeliveriesByProvider(int pid) {
    _state.providerId = pid;
    return fetchDeliveries(reset: true);
  }

  Future<void> fetchDeliveriesByOrder(int oid) {
    _state.orderId = oid;
    return fetchDeliveries(reset: true);
  }

  Future<void> fetchDeliveriesByBroker(int bid) {
    _state.brokerId = bid;
    return fetchDeliveries(reset: true);
  }

  // ── Cache ──────────────────────────────────────────────────────

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

  void reset() {
    _state.reset();
    _cache.clearAll();
    _notify();
  }

  Map<String, int> getCacheStats() => {
        'deliveryCache': _cache.deliveryCacheSize,
        'listCache': _cache.listCacheSize,
      };
}
