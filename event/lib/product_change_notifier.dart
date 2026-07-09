import 'package:event/components/product/product_cache.dart';
import 'package:event/components/product/product_cart.dart';
import 'package:event/components/product/product_crud.dart';
import 'package:event/components/product/product_fetch.dart';
import 'package:event/components/product/product_polling.dart';
import 'package:event/components/product/product_state.dart';
import 'package:event/components/product/product_supplier.dart';
import 'package:flutter/material.dart';
import 'package:app_constants/app_constants.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/services/ProductService.dart';
import 'package:locator/locator.dart';

// Import all components

class ProductNotifier extends ChangeNotifier {
  final ProductService _service = AppLocator.get<ProductService>();

  // Components
  late final ProductState _state;
  late final ProductCache _cache;
  late final ProductCrud _crud;
  late final ProductFetch _fetch;
  late final ProductCart _cart;
  late final ProductSupplier _supplier;
  late final ProductPolling _polling;

  ProductNotifier() {
    _initComponents();
    _fetch.fetchProducts();
  }

  String get currentSearchQuery => _state.currentSearchQuery;
  int get currentProviderId => _state.currentProviderId;
  int get currentCategory => _state.currentCategory;
  int get currentUserId => _state.currentUserId;
  int get itemsPerPage => _state.itemsPerPage;

  set productCategories(List<String> value) {
    _state.categories = value;
    notifyListeners();
  }

  void _initComponents() {
    _state = ProductState();
    _cache = ProductCache();
    _crud = ProductCrud(
      service: _service,
      cache: _cache,
      state: _state,
    );
    _fetch = ProductFetch(
      service: _service,
      cache: _cache,
      state: _state,
    );
    _cart = ProductCart(_state);
    _supplier = ProductSupplier(
      service: _service,
      cache: _cache,
      state: _state,
    );
    _polling = ProductPolling(
      service: _service,
      cache: _cache,
      state: _state,
    );
  }

  @override
  void dispose() {
    _polling.dispose();
    super.dispose();
  }

  void _notify() {
    if (!_state.isLoading) {
      notifyListeners();
    }
  }

  // ============ PUBLIC GETTERS ============

  List<Product> get products => _state.products;
  List<Product> get cartItems => _cart.items;
  Map<int, int> get cartQuantities => _cart.quantities;
  bool get isLoading => _state.isLoading;
  bool get isCartLoading => _cart.isLoading;
  bool get hasMoreProducts => _state.hasMoreProducts;
  List<String> get categories => _state.categories;
  bool get supportsSupplierFilter => _state.supportsSupplierFilter;
  bool get isCacheEnabled => _cache.isEnabled;

  // ============ CART OPERATIONS ============

  void addToCart(Product product, {int quantity = 1}) {
    _cart.add(product, quantity: quantity);
    _notify();
  }

  void removeFromCart(int productId) {
    _cart.remove(productId);
    _notify();
  }

  void updateCartQuantity(int productId, int quantity) {
    _cart.updateQuantity(productId, quantity);
    _notify();
  }

  void clearCart() {
    _cart.clear();
    _notify();
  }

  int getCartQuantity(int productId) => _cart.getQuantity(productId);
  bool isInCart(int productId) => _cart.contains(productId);
  int get totalCartItems => _cart.totalItems;
  double get totalCartPrice => _cart.totalPrice;

  // ============ CRUD OPERATIONS ============

  Future<Product?> addOrUpdateProduct(Product product) async {
    final result = await _crud.createOrUpdate(product);
    if (result != null) {
      await _fetch.fetchProducts(reset: true);
      _notify();
    }
    return result;
  }

  Future<int?> deleteProduct(String idProduct) async {
    final result = await _crud.delete(idProduct);
    _notify();
    return result;
  }

  // ============ FETCH OPERATIONS ============

  Future<void> fetchProducts({
    int categoryId = 0,
    int userId = 0,
    int providerId = 0,
    String query = "",
    bool reset = false,
  }) async {
    await _fetch.fetchProducts(
      categoryId: categoryId,
      userId: userId,
      providerId: providerId,
      query: query,
      reset: reset,
    );
    _notify();
  }

  Future<Product?> getProductById(int id, {bool forceRefresh = false}) async {
    return _fetch.getById(id, forceRefresh: forceRefresh);
  }

  Product? getProductByIdSync(int id) => _fetch.getByIdSync(id);

  List<Product> filterProductsByCategory(int categoryId) =>
      _fetch.filterByCategory(categoryId);

  List<Product> filterProductsBySupplier(int supplierId) =>
      _fetch.filterBySupplier(supplierId);

  Future<void> searchProducts(String query, {bool reset = true}) async {
    await _fetch.fetchProducts(
      categoryId: _state.currentCategory,
      userId: _state.currentUserId,
      providerId: _state.currentProviderId,
      query: query,
      reset: reset,
    );
    _notify();
  }

  // ============ SUPPLIER PRODUCTS ============

  bool isFetchingSupplierProducts(int supplierId) =>
      _supplier.isFetching(supplierId);

  List<Product>? getCachedSupplierProducts(int supplierId) =>
      _supplier.getCached(supplierId);

  Future<List<Product>> fetchSupplierProducts(int supplierId,
      {bool forceRefresh = false}) async {
    final results =
        await _supplier.fetch(supplierId, forceRefresh: forceRefresh);
    _notify();
    return results;
  }

  void invalidateSupplierCache(int supplierId) {
    _supplier.invalidateCache(supplierId);
    _notify();
  }

  bool hasValidSupplierCache(int supplierId) =>
      _supplier.hasValidCache(supplierId);

  // ============ POLLING ============

  void startPollingProductUpdates(Product product) {
    _polling.start(product);
  }

  void stopPollingProductUpdates() {
    _polling.stop();
  }

  // ============ CACHE MANAGEMENT ============

  void enableCaching(bool enable) {
    _cache.enable(enable);
    _notify();
  }

  void invalidateProductCache({int? productId}) {
    _cache.invalidateProduct(productId);
    _notify();
  }

  void refreshAllCaches() {
    _cache.clearAll();
    _notify();
  }

  // ============ ORDER SUCCESS ============

  Future<void> onOrderSuccess({
    List<int>? orderedProductIds,
    bool refreshProducts = true,
    bool clearCart = true,
  }) async {
    if (clearCart) {
      _cart.clear();
    }

    if (refreshProducts) {
      if (orderedProductIds != null && orderedProductIds.isNotEmpty) {
        for (final id in orderedProductIds) {
          _cache.invalidateProduct(id);
        }
      }
      await _fetch.fetchProducts(reset: true);
    }

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
      'productCache': _cache.productCacheSize,
      'listCache': _cache.listCacheSize,
    };
  }
}
