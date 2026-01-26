import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/GluttexException.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/services/ProductService.dart';
import 'package:locator/locator.dart';

class ProductNotifier extends ChangeNotifier {
  final ProductService _productService = GluttexLocator.get<ProductService>();
  final Map<int, Product> _products = {}; // Optimized for fast lookups
  Timer? _pollingTimer;
  bool isLoading = false;
  int currentPage = 0;
  int currentCategory = 0;
  int currentUserId = 0;
  int currentProviderId = 0;
  String currentSearchQuery = "";

  // Add cart-specific state
  final Map<int, int> _cartQuantities = {};
  final List<Product> _cartItems = [];
  bool _isCartLoading = false;

  final int itemsPerPage = GluttexConstants.itemsPerPage;
  List<String> get categories => _productCategories;
  List<String> _productCategories = [];
  set productCategories(List<String> value) {
    _productCategories = value;
  }

  List<Product> get products => _products.values.toList();

  // Cart getters
  List<Product> get cartItems => _cartItems;
  Map<int, int> get cartQuantities => _cartQuantities;
  bool get isCartLoading => _isCartLoading;

  ProductNotifier() {
    fetchProducts();
  }

  // Call this method when cart/order is successful
  Future<void> onOrderSuccess({
    List<int>? orderedProductIds,
    bool refreshProducts = true,
    bool clearCart = true,
  }) async {
    log('Order successful, updating product data...');

    // Clear cart if needed
    if (clearCart) {
      _cartItems.clear();
      _cartQuantities.clear();
    }

    // Refresh products to get updated quantities
    if (refreshProducts) {
      await refreshProductsAfterOrder(orderedProductIds);
    }

    notifyListeners();
  }

  // Refresh specific products that were ordered
  Future<void> refreshProductsAfterOrder(List<int>? orderedProductIds) async {
    if (orderedProductIds == null || orderedProductIds.isEmpty) {
      // If no specific IDs, refresh all products
      await fetchProducts(reset: true);
      return;
    }

    try {
      // Refresh only the products that were ordered
      for (int productId in orderedProductIds) {
        try {
          // You might need to add a method to your ProductService to fetch a single product
          // or use the focusOnProduct method if it returns full product data
          Product updatedProduct =
              await _productService.focusOnProduct(productId.toString());

          if (_products.containsKey(productId)) {
            _products[productId] = updatedProduct;
            log('Updated product ${productId} quantity from ${_products[productId]?.product_quantity} to ${updatedProduct.product_quantity}');
          }
        } catch (e) {
          log("Failed to refresh product $productId: $e");
        }
      }

      // Also refresh the current page to ensure consistency
      await fetchCurrentPage();

      notifyListeners();
    } catch (e) {
      log("Failed to refresh products after order: $e");
    }
  }

  // Refresh current page without resetting
  Future<void> fetchCurrentPage({bool notify = true}) async {
    if (isLoading) return;

    isLoading = true;
    if (notify) notifyListeners();

    try {
      final fetchedProducts = await _productService.getAllProducts(
        userId: currentUserId,
        category: currentCategory,
        providerId: currentProviderId,
        query: currentSearchQuery,
        page: (currentPage - 1).clamp(0, currentPage) * itemsPerPage,
        limit: itemsPerPage,
      );

      if (fetchedProducts != null && fetchedProducts.isNotEmpty) {
        // Update existing products with fresh data
        for (var product in fetchedProducts) {
          _products[product.id_product!] = product;
        }
      }
    } catch (e) {
      log("Failed to fetch current page: $e");
    } finally {
      isLoading = false;
      if (notify) notifyListeners();
    }
  }

  // Cart management methods
  Future<void> addToCart(Product product, {int quantity = 1}) async {
    if (_cartQuantities.containsKey(product.id_product)) {
      _cartQuantities[product.id_product!] =
          _cartQuantities[product.id_product]! + quantity;
    } else {
      _cartQuantities[product.id_product!] = quantity;
      _cartItems.add(product);
    }
    notifyListeners();
  }

  Future<void> removeFromCart(int productId) async {
    _cartQuantities.remove(productId);
    _cartItems.removeWhere((product) => product.id_product == productId);
    notifyListeners();
  }

  Future<void> updateCartQuantity(int productId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(productId);
    } else {
      _cartQuantities[productId] = quantity;
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    _cartItems.clear();
    _cartQuantities.clear();
    notifyListeners();
  }

  // Simulate order process (you'll integrate with your actual order service)
  Future<bool> placeOrder() async {
    _isCartLoading = true;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(Duration(seconds: 2));

      // Get list of ordered product IDs for refreshing
      List<int> orderedProductIds = _cartItems
          .where((product) => _cartQuantities.containsKey(product.id_product))
          .map((product) => product.id_product!)
          .toList();

      // Call your actual order API here
      // bool success = await _orderService.placeOrder(_cartItems, _cartQuantities);
      bool success = true; // Replace with actual API call

      if (success) {
        await onOrderSuccess(
          orderedProductIds: orderedProductIds,
          refreshProducts: true,
          clearCart: true,
        );
        return true;
      }
      return false;
    } catch (e) {
      log("Failed to place order: $e");
      return false;
    } finally {
      _isCartLoading = false;
      notifyListeners();
    }
  }

  Future<Product?> addOrUpdateProduct(Product product) async {
    log('Adding/updating product: ${product.product_name}');
    if (product.productImage != null) {
      String? imageUrl = await product.productImage?.uploadImage();
      product.product_image_url = imageUrl;
    }

    Product? res_product = (product.id_product == 0
        ? await _productService.addProduct(product)
        : await _productService.updateProduct(product));

    await fetchProducts(reset: true);
    return res_product;
  }

  Future<int?> deleteProduct(String idProduct) async {
    try {
      int? status = await _productService.deleteProduct(idProduct);
      if (status != null) {
        _products.remove(int.parse(idProduct));
        notifyListeners();
      }
      return status;
    } catch (e) {
      log("Failed to delete product: $e");
      return null;
    }
  }

  void startPollingProductUpdates(Product product) {
    _pollingTimer?.cancel();
    log("Polling product updates...");
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await focusOnProduct(product);
    });
  }

  void stopPollingProductUpdates() {
    _pollingTimer?.cancel();
  }

  Future<void> focusOnProduct(Product product) async {
    try {
      Product updatedProduct =
          await _productService.focusOnProduct(product.id_product.toString());
      if (_products.containsKey(updatedProduct.id_product)) {
        if (_products[updatedProduct.id_product]?.product_quantity !=
            updatedProduct.product_quantity) {
          _products[updatedProduct.id_product!] = updatedProduct;
          notifyListeners();
        }
      }
    } catch (e) {
      log("Failed to focus on product: $e");
    }
  }

  Future<void> fetchProducts({
    int categoryId = 0,
    int userId = 0,
    int providerId = 0,
    String query = "",
    bool reset = false,
  }) async {
    if (isLoading) return;

    if (reset ||
        currentCategory != categoryId ||
        currentUserId != userId ||
        currentProviderId != providerId ||
        currentSearchQuery != query) {
      currentCategory = categoryId;
      currentUserId = userId;
      currentProviderId = providerId;
      currentSearchQuery = query;
      currentPage = 0;
      _products.clear();
    }

    isLoading = true;
    notifyListeners();

    try {
      final fetchedProducts = await _productService.getAllProducts(
        userId: currentUserId,
        category: currentCategory,
        providerId: currentProviderId,
        query: currentSearchQuery,
        page: currentPage * itemsPerPage,
        limit: itemsPerPage,
      );

      if (fetchedProducts != null && fetchedProducts.isNotEmpty) {
        for (var product in fetchedProducts) {
          _products[product.id_product!] = product;
        }
        currentPage++;
      }
    } catch (e) {
      log("Failed to fetch products: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Also update your ProductNotifier to add a method for targeted refresh
// Add this to your ProductNotifier class:
  Future<void> refreshAfterOrder(List<int> orderedProductIds) async {
    // Store current state
    final currentCategory = this.currentCategory;
    final currentUserId = this.currentUserId;
    final currentProviderId = this.currentProviderId;
    final currentSearchQuery = this.currentSearchQuery;

    // Clear and fetch fresh data
    await fetchProducts(
      categoryId: currentCategory,
      userId: currentUserId,
      providerId: currentProviderId,
      query: currentSearchQuery,
      reset: true, // This will clear cache and start fresh
    );

    log('Products refreshed after order for IDs: $orderedProductIds');
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

  List<Product> filterProductsByCategory(int categoryId) {
    if (categoryId == 0) {
      return _products.values.toList();
    }
    return _products.values
        .where((product) => product.product_category_id == categoryId)
        .toList();
  }

  // Helper to get product by ID
  Product? getProductById(int id) {
    return _products[id];
  }
}
