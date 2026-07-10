import 'dart:developer';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/services/ProductService.dart';
import 'product_cache.dart';
import 'product_state.dart';

class ProductFetch {
  final ProductService _service;
  final ProductCache _cache;
  final ProductState _state;
  final Map<int, Future<Product?>> _pendingRequests = {};

  ProductFetch({
    required ProductService service,
    required ProductCache cache,
    required ProductState state,
  })  : _service = service,
        _cache = cache,
        _state = state;

  Future<Product?> getById(int id, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _cache.getProduct(id);
      if (cached != null) return cached;
    }

    if (_pendingRequests.containsKey(id)) {
      return _pendingRequests[id];
    }

    final future = _fetchProduct(id);
    _pendingRequests[id] = future;
    return future;
  }

  Future<Product?> _fetchProduct(int id) async {
    try {
      final product = await _service.focusOnProduct(id.toString());
      if (product != null && product.id_product != null) {
        _cache.cacheProduct(product);
      }
      return product;
    } catch (e) {
      log("Failed to fetch product $id: $e");
      return null;
    } finally {
      _pendingRequests.remove(id);
    }
  }

  Future<void> fetchProducts({
    int categoryId = 0,
    int userId = 0,
    int providerId = 0,
    String query = "",
    bool reset = false,
  }) async {
    if (_state.isLoading) return;

    final paramsChanged = reset ||
        _state.currentCategory != categoryId ||
        _state.currentUserId != userId ||
        _state.currentProviderId != providerId ||
        _state.currentSearchQuery != query;

    if (paramsChanged) {
      _state.currentCategory = categoryId;
      _state.currentUserId = userId;
      _state.currentProviderId = providerId;
      _state.currentSearchQuery = query;
      _state.resetPagination();
      if (reset) _cache.clearListCache();
    }

    if (!_state.hasMoreProducts) return;

    // Check cache for first page
    if (_state.currentPage == 0 && providerId == 0) {
      final cacheKey = 'p_${categoryId}_${userId}_${providerId}_$query';
      final cached = _cache.getList(cacheKey);
      if (cached != null && cached.isNotEmpty) {
        _state.products.addAll(cached);
        _state.currentPage++;
        return;
      }
    }

    _state.isLoading = true;

    try {
      final fetched = await _service.getAllProducts(
        userId: _state.currentUserId,
        category: _state.currentCategory,
        providerId: _state.currentProviderId,
        query: _state.currentSearchQuery,
        page: _state.currentPage * _state.itemsPerPage,
        limit: _state.itemsPerPage,
      );

      if (fetched != null && fetched.isNotEmpty) {
        if (_state.currentPage == 0 && providerId == 0) {
          final cacheKey = 'p_${categoryId}_${userId}_${providerId}_$query';
          _cache.cacheList(cacheKey, fetched);
        }

        _state.products.addAll(fetched);
        _state.currentPage++;

        if (fetched.length < _state.itemsPerPage) {
          _state.hasMoreProducts = false;
        }
      } else {
        _state.hasMoreProducts = false;
      }
    } catch (e) {
      log("Failed to fetch products: $e");
      rethrow;
    } finally {
      _state.isLoading = false;
    }
  }

  Product? getByIdSync(int id) {
    return _cache.getProduct(id) ??
        _state.products.firstWhere(
          (p) => p.id_product == id,
          orElse: () => null as Product,
        );
  }

  List<Product> filterByCategory(int categoryId) {
    return _state.filterByCategory(categoryId);
  }

  List<Product> filterBySupplier(int supplierId) {
    return _state.filterBySupplier(supplierId);
  }
}
