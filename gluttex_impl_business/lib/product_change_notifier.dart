import 'dart:developer';
import 'dart:typed_data';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/services/ProductService.dart';
import 'package:locator/locator.dart';

class ProductNotifier extends ChangeNotifier {
  final ProductService _productService = GluttexLocator.get<ProductService>();
  final List<Product> _products = [];
  late List<ProductCategory> _categories = [];
  List<ProductCategory> get categories => _categories;
  Timer? _pollingTimer; // Timer for polling updates
  List<Product> get products => _products;

  bool isLoading = false;
  int currentPage = 0;
  int currentCategory = 0;
  final int itemsPerPage =
      GluttexConstants.itemsPerPage; // Number of items per page

  ProductNotifier() {
    getCategories();
    fetchProducts(0);
  }

  // Future<void> fetchProducts() async {
  //   var products = await _productService.getAllProducts();
  //   _products = products ?? [];
  //   notifyListeners();
  // }

  Future<void> getCategories() async {
    var categories = await _productService.getCategories();
    _categories = categories ?? [];
    notifyListeners();
  }

  Future<int?> getProduct(Product product) async {
    int? status = await _productService.addProduct(product);
    await fetchProducts(0);
    return status;
  }

  Future<int?> addProduct(Product product) async {
    int? status = await _productService.addProduct(product);
    await fetchProducts(0);
    return status;
  }

  // Future<void> getProductImage(Product product) async {
  //   Uint8List? image =
  //       await _productService.getProductImage('${product.id_product_image}');
  //   // await fetchProducts();
  //   // log("Changing product image");
  //   // log('${_products.where((element) => element.id_product == product.id_product)}');
  //   _products
  //       .where((element) => element.id_product == product.id_product)
  //       .first
  //       .product_image_data = image;
  //   notifyListeners();
  // }

  Future<int?> updateProduct(Product product) async {
    int? status = await _productService.updateProduct(product);
    await fetchProducts(0, reset: true);
    return status;
  }

  Future<int?> deleteProduct(String idProduct) async {
    int? status = await _productService.deleteProduct(idProduct);
    await fetchProducts(0);
    return status;
  }

  void startPollingProductUpdates(Product product) async {
    // Poll every 5 seconds
    log("Polling product updates");
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await focusOnProduct(product);
    });
  }

  Future<void> stopPollingProductUpdates() async {
    _pollingTimer?.cancel();
  }

  void updateProductById(int productId, int updatedvalue) {
    int index =
        _products.indexWhere((element) => productId == element.id_product);
    if (index != -1) {
      _products[index] = _products[index].copyWith(
        product_quantity: updatedvalue,
      );
    }
    notifyListeners();
  }

  Future<void> focusOnProduct(Product product) async {
    Product updatedvalue =
        await _productService.focusOnProduct(product.id_product.toString());
    // log(updatedvalue);
    int index = _products
        .indexWhere((element) => product.id_product == element.id_product);
    if (index != -1) {
      _products[index] = _products[index].copyWith(
        product_quantity: updatedvalue.product_quantity,
      );
    }
    notifyListeners();
  }

  Future<void> fetchProducts(int categoryId, {bool reset = false}) async {
    if (isLoading) return;

    if (reset) {
      currentPage = 0;
      products.clear();
    }

    if (currentCategory != categoryId) {
      currentCategory = categoryId;
      currentPage = 0;
    }

    isLoading = true;
    notifyListeners();

    // Example API call for paginated products
    final fetchedProducts = await _productService.getAllProducts(
      categoryId,
      currentPage * itemsPerPage,
      itemsPerPage,
    );

    products.addAll(fetchedProducts!.where((newProduct) => !products.any(
        (existingProduct) =>
            existingProduct.id_product == newProduct.id_product)));

    currentPage++;
    isLoading = false;
    notifyListeners();
  }
}
