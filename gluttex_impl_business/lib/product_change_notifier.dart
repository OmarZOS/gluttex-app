import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
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

  final int itemsPerPage = GluttexConstants.itemsPerPage;
  List<String> get categories => _productCategories;
  List<String> _productCategories = [];
  set productCategories(List<String> value) {
    _productCategories = value;
  }

  List<Product> get products => _products.values.toList();

  ProductNotifier() {
    fetchProducts();
  }

  Future<int?> addOrUpdateProduct(Product product) async {
    try {
      log('Adding/updating product: ${product.product_name}');
      if (product.productImage != null) {
        String? imageUrl = await product.productImage?.uploadImage();
        product.product_image_url = imageUrl;
      }

      int? status = (product.id_product == 0
          ? await _productService.addProduct(product)
          : await _productService.updateProduct(product));
      if (status != null) {
        await fetchProducts(
            categoryId: currentCategory, userId: currentUserId, reset: true);
      }
      return status;
    } catch (e) {
      log("Failed to add/update product: $e");
      return null;
    }
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
    _pollingTimer?.cancel(); // Ensure only one timer runs at a time
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

  Future<void> fetchProducts(
      {int categoryId = 0,
      int userId = 0,
      int providerId = 0,
      bool reset = false}) async {
    if (isLoading) return;

    if (reset ||
        currentCategory != categoryId ||
        currentUserId != userId ||
        currentProviderId != providerId) {
      currentCategory = categoryId;
      currentUserId = userId;
      currentProviderId = providerId;
      currentPage = 0;

      _products.clear();
    }

    isLoading = true;
    notifyListeners();

    try {
      final fetchedProducts = await _productService.getAllProducts(
        userId: currentUserId,
        category: categoryId,
        providerId: providerId,
        page: currentPage * itemsPerPage,
        limit: itemsPerPage,
      );

      if (fetchedProducts != null && fetchedProducts.isNotEmpty) {
        for (var product in fetchedProducts) {
          _products[product.id_product!] = product;
        }
        currentPage++;
        notifyListeners();
      }
    } catch (e) {
      log("Failed to fetch products: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to filter products by category
  List<Product> filterProductsByCategory(int categoryId) {
    if (categoryId == 0) {
      return _products.values
          .toList(); // Return all products for "All" category
    }
    return _products.values
        .where((product) => product.product_category_id == categoryId)
        .toList();
  }
}
