library gluttex_impl_business;

import 'dart:developer' as developer;
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/services/ProductService.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:locator/locator.dart';

class ProductServiceImpl implements ProductService {
  List<ProductCategory> categories = [];

  @override
  Future<Product?> addProduct(Product product) async {
    try {
      StorageService storageService = GluttexLocator.get<StorageService>();

      developer.log('Adding product: ${product.toJson()}',
          name: 'ProductServiceImpl');

      final result = await storageService.insert(
        '${GluttexConstants.apiBaseUrl}${GluttexConstants.addProductEndpoint}',
        product.toJson(),
      );

      developer.log('Add product result: $result', name: 'ProductServiceImpl');

      if (result == null) {
        developer.log('Failed to add product: null response',
            name: 'ProductServiceImpl');
        return null;
      }

      return Product.fromJson(result as Map<String, dynamic>);
    } catch (e, stacktrace) {
      developer.log('Error adding product: $e', name: 'ProductServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'ProductServiceImpl');
      return null;
    }
  }

  @override
  Future<int?> deleteProduct(String productId) async {
    try {
      StorageService storageService = GluttexLocator.get<StorageService>();

      developer.log('Deleting product: $productId', name: 'ProductServiceImpl');

      final result = await storageService.delete(
        '${GluttexConstants.apiBaseUrl}${GluttexConstants.deleteProductEndpoint}',
        productId,
      );

      developer.log('Delete result: $result', name: 'ProductServiceImpl');
      return result;
    } catch (e, stacktrace) {
      developer.log('Error deleting product: $e', name: 'ProductServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'ProductServiceImpl');
      return null;
    }
  }

  Future<List<Product>> searchProductsByToken(
      String token, int offset, int itemsPerPage) async {
    try {
      StorageService storageService = GluttexLocator.get<StorageService>();

      developer.log(
          'Searching products with token: $token, offset: $offset, limit: $itemsPerPage',
          name: 'ProductServiceImpl');

      final data = await storageService.getAll(
        '${GluttexConstants.apiBaseUrl}${GluttexConstants.productSearchEndpoint}/$token/$offset/$itemsPerPage',
      );

      if (data == null || data.isEmpty) {
        developer.log('No products found for search',
            name: 'ProductServiceImpl');
        return [];
      }

      List<Product> products = [];

      // Handle different response formats
      if (data is List) {
        products = data
            .map((item) => Product.fromSearchJson(item as Map<String, dynamic>))
            .toList();
      } else if (data is Map && data.containsKey('data')) {
        products = (data['data'] as List)
            .map((item) => Product.fromSearchJson(item as Map<String, dynamic>))
            .toList();
      } else {
        developer.log('Unexpected search response format: ${data.runtimeType}',
            name: 'ProductServiceImpl');
      }

      developer.log('Found ${products.length} products',
          name: 'ProductServiceImpl');
      return products;
    } catch (e, stacktrace) {
      developer.log('Error searching products: $e', name: 'ProductServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'ProductServiceImpl');
      return [];
    }
  }

  @override
  Future<Product?> updateProduct(Product updatedProduct) async {
    try {
      StorageService storageService = GluttexLocator.get<StorageService>();

      developer.log('Updating product: ${updatedProduct.id_product}',
          name: 'ProductServiceImpl');
      developer.log('Product data: ${updatedProduct.toJson()}',
          name: 'ProductServiceImpl');

      final result = await storageService.update(
        '${GluttexConstants.apiBaseUrl}${GluttexConstants.productEndpoint}/${updatedProduct.id_product}',
        updatedProduct.id_product.toString(),
        {"product_id": updatedProduct.id_product.toString()},
        updatedProduct.toJson(),
      );

      developer.log('Update result: $result', name: 'ProductServiceImpl');

      if (result == null) {
        developer.log('Failed to update product: null response',
            name: 'ProductServiceImpl');
        return null;
      }

      return Product.fromJson(result as Map<String, dynamic>);
    } catch (e, stacktrace) {
      developer.log('Error updating product: $e', name: 'ProductServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'ProductServiceImpl');
      return null;
    }
  }

  @override
  Future<Product?> getProduct(String id) async {
    try {
      StorageService storageService = GluttexLocator.get<StorageService>();

      developer.log('Getting product: $id', name: 'ProductServiceImpl');

      final data = await storageService.get(
        '${GluttexConstants.apiBaseUrl}${GluttexConstants.productEndpoint}',
        id,
      );

      if (data == null) {
        developer.log('Product not found: $id', name: 'ProductServiceImpl');
        return null;
      }

      return Product.fromJson(data as Map<String, dynamic>);
    } catch (e, stacktrace) {
      developer.log('Error getting product: $e', name: 'ProductServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'ProductServiceImpl');
      return null;
    }
  }

  @override
  Future<List<Product>?> getAllProducts(
      {int userId = 0,
      int providerId = 0,
      int category = 0,
      String query = "",
      int page = 1,
      int limit = 10}) async {
    try {
      // If there's a search query, use search endpoint
      if (query.isNotEmpty) {
        return await searchProductsByToken(query, page, limit);
      }

      StorageService storageService = GluttexLocator.get<StorageService>();

      // Build the route with all parameters
      final route =
          "${GluttexConstants.apiBaseUrl}${GluttexConstants.getAllProductsEndpoint}/$userId/$providerId/$category/$page/$limit";

      developer.log('Getting all products from: $route',
          name: 'ProductServiceImpl');

      final responseData = await storageService.getAll(route);

      if (responseData == null) {
        developer.log('No products found', name: 'ProductServiceImpl');
        return [];
      }

      List<Product> products = [];

      // Handle different response formats
      if (responseData is List) {
        products = responseData
            .map((data) => Product.fromJson(data as Map<String, dynamic>))
            .toList();
      } else if (responseData is Map && responseData.containsKey('data')) {
        final dataList = responseData['data'];
        if (dataList is List) {
          products = dataList
              .map((data) => Product.fromJson(data as Map<String, dynamic>))
              .toList();
        }
      } else if (responseData is Map) {
        // Single product returned
        products = [Product.fromJson(responseData)];
      }

      developer.log('Found ${products.length} products',
          name: 'ProductServiceImpl');
      return products;
    } catch (e, stacktrace) {
      developer.log('Error getting all products: $e',
          name: 'ProductServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'ProductServiceImpl');
      return [];
    }
  }

  @override
  Future<List<ProductCategory>>? getCategories() async {
    if (categories.isNotEmpty) {
      developer.log('Returning cached categories: ${categories.length}',
          name: 'ProductServiceImpl');
      return categories;
    }

    try {
      StorageService storageService = GluttexLocator.get<StorageService>();

      final route =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.getProductCategoriesEndpoint}';
      developer.log('Getting categories from: $route',
          name: 'ProductServiceImpl');

      final responseData = await storageService.getAll(route);

      if (responseData == null) {
        developer.log('No categories found', name: 'ProductServiceImpl');
        return [];
      }

      List<ProductCategory> categoriesList = [];

      if (responseData is List) {
        categoriesList = responseData
            .map((data) =>
                ProductCategory.fromJson(data as Map<String, dynamic>))
            .toList();
      } else if (responseData is Map && responseData.containsKey('data')) {
        final dataList = responseData['data'];
        if (dataList is List) {
          categoriesList = dataList
              .map((data) =>
                  ProductCategory.fromJson(data as Map<String, dynamic>))
              .toList();
        }
      }

      // Cache the categories
      categories = categoriesList;
      developer.log('Found ${categories.length} categories',
          name: 'ProductServiceImpl');

      return categoriesList;
    } catch (e, stacktrace) {
      developer.log('Error getting categories: $e', name: 'ProductServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'ProductServiceImpl');
      return [];
    }
  }

  @override
  Future<dynamic> focusOnProduct(String idProduct) async {
    try {
      StorageService storageService = GluttexLocator.get<StorageService>();

      developer.log('Focusing on product: $idProduct',
          name: 'ProductServiceImpl');

      final responseData = await storageService.get(
        '${GluttexConstants.apiBaseUrl}${GluttexConstants.productEndpoint}',
        idProduct,
      );

      if (responseData == null) {
        developer.log('Product not found for focus: $idProduct',
            name: 'ProductServiceImpl');
        return null;
      }

      return Product.fromJson(responseData as Map<String, dynamic>);
    } catch (e, stacktrace) {
      developer.log('Error focusing on product: $e',
          name: 'ProductServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'ProductServiceImpl');
      return null;
    }
  }

  // Helper method to clear cache (useful for testing or refresh scenarios)
  void clearCache() {
    categories.clear();
    developer.log('Product service cache cleared', name: 'ProductServiceImpl');
  }
}
