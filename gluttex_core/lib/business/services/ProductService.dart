import 'dart:typed_data';

import 'package:gluttex_core/app/TraceableService.dart';

import '../Product.dart';

// ProductService.dart
abstract class ProductService extends TraceableService {
  Future<List<ProductCategory>?>? getCategories({String? callerKey}) async {
    return null;
  }

  Future<List<Product>?>? getAllProducts(
      {int userId = 0,
      int providerId = 0,
      int category = 0,
      String query = "",
      int page = 1,
      int limit = 10,
      String? callerKey}) async {
    return null;
  }

  Future<dynamic> focusOnProduct(String idProduct, {String? callerKey}) async {
    return null;
  }

  Future<Product?> getProduct(String idProduct, {String? callerKey}) async {
    return null;
  }

  Future<Product?> addProduct(Product product, {String? callerKey}) async {
    return null;
  }

  Future<Product?> updateProduct(Product updatedProduct,
      {String? callerKey}) async {
    return null;
  }

  Future<int?> deleteProduct(String productId, {String? callerKey}) async {
    return null;
  }
}
