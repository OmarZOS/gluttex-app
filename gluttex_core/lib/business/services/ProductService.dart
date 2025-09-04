import 'dart:typed_data';

import '../Product.dart';

// ProductService.dart
abstract class ProductService {
  Future<List<ProductCategory>?>? getCategories() async {
    return null;
  }

  Future<List<Product>?>? getAllProducts(
      {int userId = 0,
      int providerId = 0,
      int category = 0,
      String query = "",
      int page = 1,
      int limit = 10}) async {
    return null;
  }

  Future<dynamic> focusOnProduct(String idProduct) async {
    return null;
  }

  Future<Product?> getProduct(String idProduct) async {
    return null;
  }

  Future<Product?> addProduct(Product product) async {
    return null;
  }

  Future<Product?> updateProduct(Product updatedProduct) async {
    return null;
  }

  Future<int?> deleteProduct(String productId) async {
    return null;
  }
}
