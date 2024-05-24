import 'Product.dart';

// ProductService.dart
abstract class ProductService {
  Future<List<Product>?>? getAllProducts() async {
    return null;
  }

  Future<Product?> getProduct(String id_product) async {
    return null;
  }

  Future<String?> addProduct(Product Product) async {
    return null;
  }

  Future<String?> updateProduct(Product updatedProduct) async {
    return null;
  }

  Future<String?> deleteProduct(String productId) async {
    return null;
  }
}
