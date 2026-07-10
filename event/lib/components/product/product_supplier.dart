import 'dart:async';
import 'dart:developer';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/services/ProductService.dart';
import 'product_cache.dart';
import 'product_state.dart';

class ProductSupplier {
  final ProductService _service;
  final ProductCache _cache;
  final ProductState _state;
  final Map<int, bool> _fetchingState = {};
  final Map<int, List<Function(List<Product>)>> _callbacks = {};

  ProductSupplier({
    required ProductService service,
    required ProductCache cache,
    required ProductState state,
  })  : _service = service,
        _cache = cache,
        _state = state;

  bool isFetching(int supplierId) => _fetchingState[supplierId] == true;

  List<Product>? getCached(int supplierId) {
    return _cache.getSupplierProducts(supplierId);
  }

  Future<List<Product>> fetch(int supplierId,
      {bool forceRefresh = false}) async {
    // Check cache first
    if (!forceRefresh) {
      final cached = _cache.getSupplierProducts(supplierId);
      if (cached != null) {
        log('Returning cached products for supplier $supplierId');
        return cached;
      }
    }

    // If already fetching, wait for it
    if (_fetchingState[supplierId] == true) {
      log('Already fetching supplier $supplierId, waiting...');
      return await _waitForFetch(supplierId);
    }

    // Start fetching
    _fetchingState[supplierId] = true;

    log('Fetching products for supplier $supplierId');

    try {
      final products = await _service.getAllProducts(
        providerId: supplierId,
        page: 0,
        limit: 100,
      );

      final productList = products ?? [];

      // Cache the results
      _cache.cacheSupplierProducts(supplierId, productList);

      // Notify waiting callbacks
      _notifyCallbacks(supplierId, productList);

      return productList;
    } catch (e) {
      log("Failed to fetch supplier products: $e");
      _notifyCallbacks(supplierId, []);
      return [];
    } finally {
      _fetchingState[supplierId] = false;
      _callbacks.remove(supplierId);
    }
  }

  Future<List<Product>> _waitForFetch(int supplierId) async {
    final completer = Completer<List<Product>>();

    _callbacks.putIfAbsent(supplierId, () => []);
    _callbacks[supplierId]!.add((products) {
      if (!completer.isCompleted) {
        completer.complete(products);
      }
    });

    // Timeout fallback
    Future.delayed(const Duration(seconds: 10), () {
      if (!completer.isCompleted) {
        completer.complete([]);
      }
    });

    return completer.future;
  }

  void _notifyCallbacks(int supplierId, List<Product> products) {
    final callbacks = _callbacks[supplierId];
    if (callbacks != null) {
      for (final callback in callbacks) {
        callback(products);
      }
    }
  }

  void invalidateCache(int supplierId) {
    _cache.invalidateSupplierCache(supplierId);
  }

  bool hasValidCache(int supplierId) {
    return _cache.hasValidSupplierCache(supplierId);
  }
}
