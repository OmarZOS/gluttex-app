import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/services/ProductService.dart';
import 'package:locator/locator.dart';

class ProductNotifier extends ChangeNotifier {
  final ProductService _productService = GluttexLocator.get<ProductService>();
  List<Product> _products = [];

  List<Product> get products => _products;

  ProductNotifier() {
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    var products = await _productService.getAllProducts();
    _products = products ?? [];
    notifyListeners();
  }

  Future<int?> getProduct(Product product) async {
    int? status = await _productService.addProduct(product);
    await fetchProducts();
    return status;
  }

  Future<int?> addProduct(Product product) async {
    int? status = await _productService.addProduct(product);
    await fetchProducts();
    return status;
  }

  Future<void> getProductImage(Product product) async {
    Uint8List? image =
        await _productService.getProductImage('${product.id_product_image}');
    // await fetchProducts();
    log("Changing product image");
    log('${_products.where((element) => element.id_product == product.id_product)}');
    _products
        .where((element) => element.id_product == product.id_product)
        .first
        .product_image_data = image;
    notifyListeners();
  }

  Future<int?> updateProduct(Product product) async {
    int? status = await _productService.updateProduct(product);
    await fetchProducts();
    return status;
  }

  Future<int?> deleteProduct(String id_product) async {
    int? status = await _productService.deleteProduct(id_product);
    await fetchProducts();
    return status;
  }
}
