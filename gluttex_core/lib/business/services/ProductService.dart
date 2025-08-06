import 'dart:typed_data';

import '../Product.dart';

// ProductService.dart
abstract class ProductService {
  Future<List<ProductCategory>?>? getCategories() async {
    return null;
  }

  Future<List<Product>?>? getAllProducts(
      int category, int page, int limit) async {
    return null;
  }

  Future<dynamic> focusOnProduct(String idProduct) async {
    return null;
  }

  Future<Product?> getProduct(String idProduct) async {
    return null;
  }

  Future<int?> addProduct(Product product) async {
    return null;
  }

  Future<int?> updateProduct(Product updatedProduct) async {
    return null;
  }

  Future<int?> deleteProduct(String productId) async {
    return null;
  }
}
