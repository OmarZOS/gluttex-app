import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:app_constants/app_constants.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/services/ProductService.dart';
import 'package:locator/locator.dart';

class ProductNotifier extends ChangeNotifier {
  final ProductService _productService = AppLocator.get<ProductService>();

  // Simple cache - no TTL, no LRU complexity
  final Map<int, Product> _productCache = {};
  final Map<String, List<int>> _listCache = {}; // Store only IDs
  final Map<int, Future<Product?>> _pendingRequests = {};

  bool get hasMoreProducts => _hasMoreProducts;
  bool _hasMoreProducts = true;

  // Main data
  final List<Product> _products = [];
  Timer? _pollingTimer;
  bool isLoading = false;

  // Pagination state
  int currentPage = 0;
  int currentCategory = 0;
  int currentUserId = 0;
  int currentProviderId = 0;
  String currentSearchQuery = "";

  // Cart state
  final Map<int, int> _cartQuantities = {};
  final List<Product> _cartItems = [];
  bool _isCartLoading = false;

  // Supplier products cache with loading state
  final Map<int, List<Product>> _supplierProductsCache = {};
  final Map<int, DateTime> _supplierCacheTime = {};
  final Map<int, bool> _supplierFetchingState = {};
  final Map<int, List<Function(List<Product>)>> _supplierCallbacks = {};

  final int itemsPerPage = AppConstants.itemsPerPage;
  List<String> _productCategories = [];

  bool _isDisposed = false;
  bool _enableCache = true;

  // ============ GETTERS ============
  List<String> get categories => _productCategories;
  set productCategories(List<String> value) {
    _productCategories = value;
  }

  bool get supportsSupplierFilter => true;

  List<Product> get products => List.unmodifiable(_products);
  List<Product> get cartItems => _cartItems;
  Map<int, int> get cartQuantities => _cartQuantities;
  bool get isCartLoading => _isCartLoading;

  // Check if supplier products are being fetched
  bool isFetchingSupplierProducts(int supplierId) {
    return _supplierFetchingState[supplierId] == true;
  }

  // Get cached supplier products
  List<Product>? getCachedSupplierProducts(int supplierId) {
    final cached = _supplierProductsCache[supplierId];
    if (cached != null && _supplierCacheTime.containsKey(supplierId)) {
      final cacheAge =
          DateTime.now().difference(_supplierCacheTime[supplierId]!);
      if (cacheAge < const Duration(minutes: 5)) {
        return cached;
      }
    }
    return null;
  }

  ProductNotifier() {
    fetchProducts();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _pollingTimer?.cancel();
    _pendingRequests.clear();
    _productCache.clear();
    _listCache.clear();
    _supplierCallbacks.clear();
    super.dispose();
  }

  void _safeNotify() {
    if (!_isDisposed && hasListeners) {
      notifyListeners();
    }
  }

  // ============ SIMPLE CACHE METHODS ============

  void _cacheProduct(Product product) {
    if (!_enableCache) return;
    _productCache[product.id_product!] = product;
  }

  Product? _getCachedProduct(int id) {
    if (!_enableCache) return null;
    return _productCache[id];
  }

  void _cacheList(String key, List<Product> products) {
    if (!_enableCache) return;
    _listCache[key] = products.map((p) => p.id_product!).toList();
    for (final p in products) {
      _productCache[p.id_product!] = p;
    }
  }

  List<Product>? _getCachedList(String key) {
    if (!_enableCache) return null;
    final ids = _listCache[key];
    if (ids == null) return null;

    final products = <Product>[];
    for (final id in ids) {
      final cached = _productCache[id];
      if (cached == null) return null;
      products.add(cached);
    }
    return products;
  }

  void _clearListCache() {
    _listCache.clear();
  }

  void invalidateProductCache(int? productId) {
    if (productId != null) {
      _productCache.remove(productId);
    } else {
      _productCache.clear();
      _listCache.clear();
    }
  }

  void invalidateSupplierCache(int supplierId) {
    _supplierProductsCache.remove(supplierId);
    _supplierCacheTime.remove(supplierId);
  }

  // ============ CART METHODS ============

  Future<void> onOrderSuccess({
    List<int>? orderedProductIds,
    bool refreshProducts = true,
    bool clearCart = true,
  }) async {
    if (clearCart) {
      _cartItems.clear();
      _cartQuantities.clear();
    }

    if (refreshProducts) {
      if (orderedProductIds != null && orderedProductIds.isNotEmpty) {
        for (int id in orderedProductIds) {
          _productCache.remove(id);
        }
      }
      await fetchProducts(reset: true);
    }

    _safeNotify();
  }

  void addToCart(Product product, {int quantity = 1}) {
    if (_cartQuantities.containsKey(product.id_product)) {
      _cartQuantities[product.id_product!] =
          _cartQuantities[product.id_product]! + quantity;
    } else {
      _cartQuantities[product.id_product!] = quantity;
      _cartItems.add(product);
    }
    _safeNotify();
  }

  void removeFromCart(int productId) {
    _cartQuantities.remove(productId);
    _cartItems.removeWhere((product) => product.id_product == productId);
    _safeNotify();
  }

  void updateCartQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
    } else {
      _cartQuantities[productId] = quantity;
      _safeNotify();
    }
  }

  void clearCart() {
    _cartItems.clear();
    _cartQuantities.clear();
    _safeNotify();
  }

  // ============ PRODUCT CRUD ============

  Future<Product?> addOrUpdateProduct(Product product) async {
    if (product.productImage != null) {
      String? imageUrl = await product.productImage?.uploadImage();
      product.product_image_url = imageUrl;
    }

    Product? result = (product.id_product == 0
        ? await _productService.addProduct(product)
        : await _productService.updateProduct(product));

    if (result != null) {
      invalidateProductCache(result.id_product);
      await fetchProducts(reset: true);
    }

    return result;
  }

  Future<int?> deleteProduct(String idProduct) async {
    try {
      int? status = await _productService.deleteProduct(idProduct);
      if (status != null) {
        final id = int.parse(idProduct);
        _productCache.remove(id);
        _products.removeWhere((p) => p.id_product == id);
        _safeNotify();
      }
      return status;
    } catch (e) {
      log("Failed to delete product: $e");
      return null;
    }
  }

  // ============ PRODUCT FETCHING ============

  Future<Product?> getProductById(int id, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _getCachedProduct(id);
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
      final product = await _productService.focusOnProduct(id.toString());
      if (product != null && product.id_product != null) {
        _cacheProduct(product);
      }
      return product;
    } catch (e) {
      log("Failed to fetch product $id: $e");
      return null;
    } finally {
      _pendingRequests.remove(id);
    }
  }

  // Efficient supplier products fetch - doesn't reset main products list
  Future<List<Product>> fetchSupplierProducts(int supplierId,
      {bool forceRefresh = false}) async {
    // Check cache first
    if (!forceRefresh) {
      final cached = getCachedSupplierProducts(supplierId);
      if (cached != null) {
        log('Returning cached products for supplier $supplierId');
        return cached;
      }
    }

    // If already fetching, wait for it to complete
    if (_supplierFetchingState[supplierId] == true) {
      log('Already fetching supplier $supplierId, waiting...');
      return await _waitForSupplierFetch(supplierId);
    }

    // Start fetching
    _supplierFetchingState[supplierId] = true;
    _safeNotify(); // Notify UI that loading started

    log('Fetching products for supplier $supplierId');

    try {
      final products = await _productService.getAllProducts(
        providerId: supplierId,
        page: 0,
        limit: 100, // Fetch all products for this supplier
      );

      final productList = products ?? [];

      // Cache the results
      _supplierProductsCache[supplierId] = productList;
      _supplierCacheTime[supplierId] = DateTime.now();

      // Also cache individual products
      for (final product in productList) {
        _cacheProduct(product);
      }

      // Notify waiting callbacks
      _notifySupplierCallbacks(supplierId, productList);

      return productList;
    } catch (e) {
      log("Failed to fetch supplier products: $e");
      _notifySupplierCallbacks(supplierId, []);
      return [];
    } finally {
      _supplierFetchingState[supplierId] = false;
      _supplierCallbacks.remove(supplierId);
      _safeNotify();
    }
  }

  // Wait for an ongoing supplier fetch to complete
  Future<List<Product>> _waitForSupplierFetch(int supplierId) async {
    final completer = Completer<List<Product>>();

    _supplierCallbacks.putIfAbsent(supplierId, () => []);
    _supplierCallbacks[supplierId]!.add((products) {
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

  void _notifySupplierCallbacks(int supplierId, List<Product> products) {
    final callbacks = _supplierCallbacks[supplierId];
    if (callbacks != null) {
      for (final callback in callbacks) {
        callback(products);
      }
    }
  }

  // Main fetch products - doesn't get affected by supplier fetches
  Future<void> fetchProducts({
    int categoryId = 0,
    int userId = 0,
    int providerId = 0,
    String query = "",
    bool reset = false,
  }) async {
    // Don't let supplier fetches block main catalog
    if (isLoading) return;

    final paramsChanged = reset ||
        currentCategory != categoryId ||
        currentUserId != userId ||
        currentProviderId != providerId ||
        currentSearchQuery != query;

    if (paramsChanged) {
      currentCategory = categoryId;
      currentUserId = userId;
      currentProviderId = providerId;
      currentSearchQuery = query;
      currentPage = 0;
      _products.clear();
      _hasMoreProducts = true;
      if (reset) {
        _clearListCache();
      }
    }

    if (!_hasMoreProducts) return;

    // Check cache for first page
    if (currentPage == 0 && _enableCache && providerId == 0) {
      final cacheKey = 'p_${categoryId}_${userId}_${providerId}_$query';
      final cached = _getCachedList(cacheKey);
      if (cached != null && cached.isNotEmpty) {
        _products.addAll(cached);
        currentPage++;
        _safeNotify();
        return;
      }
    }

    isLoading = true;
    _safeNotify();

    try {
      final fetched = await _productService.getAllProducts(
        userId: currentUserId,
        category: currentCategory,
        providerId: currentProviderId,
        query: currentSearchQuery,
        page: currentPage * itemsPerPage,
        limit: itemsPerPage,
      );

      if (fetched != null && fetched.isNotEmpty) {
        if (currentPage == 0 && providerId == 0) {
          final cacheKey = 'p_${categoryId}_${userId}_${providerId}_$query';
          _cacheList(cacheKey, fetched);
        }

        _products.addAll(fetched);
        currentPage++;

        if (fetched.length < itemsPerPage) {
          _hasMoreProducts = false;
        }
      } else {
        _hasMoreProducts = false;
      }
    } catch (e) {
      log("Failed to fetch products: $e");
      rethrow;
    } finally {
      isLoading = false;
      _safeNotify();
    }
  }

  Future<void> searchProducts(String query, {bool reset = true}) async {
    await fetchProducts(
      categoryId: currentCategory,
      userId: currentUserId,
      providerId: currentProviderId,
      query: query,
      reset: reset,
    );
  }

  // ============ POLLING ============

  void startPollingProductUpdates(Product product) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await _pollProductUpdate(product);
    });
  }

  void stopPollingProductUpdates() {
    _pollingTimer?.cancel();
  }

  Future<void> _pollProductUpdate(Product product) async {
    try {
      final updated =
          await _productService.focusOnProduct(product.id_product.toString());
      if (updated != null &&
          updated.product_quantity != product.product_quantity) {
        _cacheProduct(updated);

        final index =
            _products.indexWhere((p) => p.id_product == updated.id_product);
        if (index != -1) {
          _products[index] = updated;
          _safeNotify();
        }
      }
    } catch (e) {
      // Silent fail for polling
    }
  }

  // ============ HELPER METHODS ============

  List<Product> filterProductsByCategory(int categoryId) {
    if (categoryId == 0) return List.unmodifiable(_products);
    return _products
        .where((product) => product.product_category_id == categoryId)
        .toList();
  }

  // Filter products by supplier from existing cache
  List<Product> filterProductsBySupplier(int supplierId) {
    final cached = getCachedSupplierProducts(supplierId);
    if (cached != null) {
      return cached;
    }

    // Fallback to filtering main products list
    return _products
        .where((product) => product.product_provider_id == supplierId)
        .toList();
  }

  Product? getProductByIdSync(int id) {
    return _getCachedProduct(id) ??
        _products.firstWhere(
          (p) => p.id_product == id,
          orElse: () => null as Product,
        );
  }

  void reset() {
    _products.clear();
    _productCache.clear();
    _listCache.clear();
    _cartItems.clear();
    _cartQuantities.clear();
    _supplierProductsCache.clear();
    _supplierCacheTime.clear();
    _supplierFetchingState.clear();
    currentPage = 0;
    _hasMoreProducts = true;
    isLoading = false;
    _safeNotify();
  }
}
