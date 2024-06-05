import '../Product.dart';

// ProductService.dart
abstract class ProductService {
  Future<List<ProductCategory>?>? getCategories() async {
    return null;
  }

  Future<List<Product>?>? getAllProducts() async {
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
