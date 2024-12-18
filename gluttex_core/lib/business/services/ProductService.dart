import 'dart:typed_data';

import '../Product.dart';

// ProductService.dart
abstract class ProductService {
  Future<Uint8List?> getProductImage(String id) async {
    return null;
  }

  Future<List<ProductCategory>?>? getCategories() async {
    return null;
  }

  Future<List<Product>?>? getAllProducts() async {
    return null;
  }

  Future<dynamic> focusOnProduct(String idProduct) async {
    return null;
  }

  Future<Product?> getProduct(String idProduct) async {
    return null;
  }

  Future<int?> addProduct(Product Product) async {
    return null;
  }

  Future<int?> updateProduct(Product updatedProduct) async {
    return null;
  }

  Future<int?> deleteProduct(String productId) async {
    return null;
  }
}
