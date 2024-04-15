import 'Product.dart';

// ProductService.dart
abstract class ProductService {
  Future<List<Product>?> getAllProducts() async {
    return null;
  }

  Future<void> addProduct(Product Product) async {
// ... code to add a new Product
  }

  Future<void> updateProduct(Product updatedProduct) async {
// ... code to update an existing Product
  }

  Future<void> deleteProduct(int productId) async {
// ... code to delete a supplier by id
  }
}
