library business;

import 'dart:developer';
import 'package:app_constants/app_constants.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/services/ProductService.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:gluttex_core/app/GluttexException.dart';
import 'package:locator/locator.dart';

class ProductServiceImpl extends ProductService {
  final StorageService _storageService = AppLocator.get<StorageService>();
  List<ProductCategory> _categories = [];

  String _getCallerKey(String method, {String? id, String? suffix}) {
    final parts = [method];
    if (id != null) parts.add(id);
    if (suffix != null) parts.add(suffix);
    if (parts.length == 1)
      parts.add(DateTime.now().millisecondsSinceEpoch.toString());
    return parts.join('_');
  }

  void _storeSuccess(String key, dynamic data,
      {int? code, String? responseCode}) {
    _storageService.setSuccessResponse(key, data,
        statusCode: code ?? 200, responseCode: responseCode ?? 'SUCCESS');
  }

  void _storeFailure(String key, dynamic data,
      {int? code, String? errorCode, String? message}) {
    _storageService.setFailureResponse(key,
        data: data,
        statusCode: code ?? 500,
        errorCode: errorCode,
        message: message);
  }

  @override
  Future<Product?> addProduct(Product product, {String? callerKey}) async {
    final key = callerKey ??
        _getCallerKey('addProduct', suffix: product.product_name ?? 'unnamed');
    try {
      final result = await _storageService.insert(
        '${AppConstants.apiBaseUrl}${AppConstants.addProductEndpoint}',
        product.toJson(),
        callerKey: key,
      );

      if (result == null) {
        _storeFailure(key, null, code: 500, errorCode: 'ADD_FAILED');
        return null;
      }

      final newProduct = Product.fromJson(result as Map<String, dynamic>);
      _storeSuccess(key, newProduct);
      return newProduct;
    } catch (e) {
      _storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      return null;
    }
  }

  @override
  Future<int?> deleteProduct(String productId, {String? callerKey}) async {
    final key = callerKey ?? _getCallerKey('deleteProduct', id: productId);
    try {
      final result = await _storageService.delete(
        '${AppConstants.apiBaseUrl}${AppConstants.deleteProductEndpoint}/$productId',
        productId,
        callerKey: key,
      );

      if (result == 200 || result == 204)
        _storeSuccess(key, true);
      else
        _storeFailure(key, false, code: result);
      return result;
    } catch (e) {
      _storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      return null;
    }
  }

  @override
  Future<Product?> updateProduct(Product updatedProduct,
      {String? callerKey}) async {
    final key = callerKey ??
        _getCallerKey('updateProduct',
            id: updatedProduct.id_product?.toString() ?? 'unknown');
    try {
      final result = await _storageService.update(
        '${AppConstants.apiBaseUrl}${AppConstants.updateProductEndpoint ?? AppConstants.productEndpoint}',
        updatedProduct.id_product?.toString() ?? '',
        {"product_id": updatedProduct.id_product?.toString() ?? ''},
        updatedProduct.toJson(),
        callerKey: key,
      );

      if (result == null) {
        _storeFailure(key, null, code: 500, errorCode: 'UPDATE_FAILED');
        return null;
      }

      final product = Product.fromJson(result as Map<String, dynamic>);
      _storeSuccess(key, product);
      return product;
    } catch (e) {
      _storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      return null;
    }
  }

  @override
  Future<Product?> getProduct(String id, {String? callerKey}) async {
    final key = callerKey ?? _getCallerKey('getProduct', id: id);
    try {
      final data = await _storageService.get(
        '${AppConstants.apiBaseUrl}${AppConstants.productEndpoint}',
        id,
        callerKey: key,
      );

      if (data == null) {
        _storeFailure(key, null, code: 404, errorCode: 'NOT_FOUND');
        return null;
      }

      final product = Product.fromJson(data as Map<String, dynamic>);
      _storeSuccess(key, product);
      return product;
    } catch (e) {
      _storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
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
      int limit = 10,
      String? callerKey}) async {
    final key = callerKey ?? _getCallerKey('getAllProducts');
    try {
      // If there's a search query, use search endpoint
      if (query.isNotEmpty) {
        return await _searchProductsByToken(query, page, limit, callerKey: key);
      }

      // Build the route with all parameters
      final route =
          "${AppConstants.apiBaseUrl}${AppConstants.getAllProductsEndpoint}/$userId/$providerId/$category/$page/$limit";

      final responseData = await _storageService.getAll(
        route,
        callerKey: key,
      );

      if (responseData == null) {
        _storeSuccess(key, [], responseCode: 'EMPTY');
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

      _storeSuccess(key, products);
      return products;
    } catch (e) {
      _storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      return [];
    }
  }

  // Helper method for search functionality with traceability
  Future<List<Product>> _searchProductsByToken(
      String token, int offset, int itemsPerPage,
      {String? callerKey}) async {
    final key =
        callerKey ?? _getCallerKey('searchProductsByToken', suffix: token);
    try {
      final data = await _storageService.getAll(
        '${AppConstants.apiBaseUrl}${AppConstants.productSearchEndpoint}/$token/$offset/$itemsPerPage',
        callerKey: key,
      );

      if (data == null || data.isEmpty) {
        _storeSuccess(key, [], responseCode: 'EMPTY');
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
      }

      _storeSuccess(key, products);
      return products;
    } catch (e) {
      _storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      return [];
    }
  }

  @override
  Future<List<ProductCategory>?> getCategories({String? callerKey}) async {
    final key = callerKey ?? _getCallerKey('getCategories');
    if (_categories.isNotEmpty) {
      _storeSuccess(key, _categories, responseCode: 'CACHED');
      return _categories;
    }

    try {
      final route =
          '${AppConstants.apiBaseUrl}${AppConstants.getProductCategoriesEndpoint}';

      final responseData = await _storageService.getAll(
        route,
        callerKey: key,
      );

      if (responseData == null) {
        _storeSuccess(key, [], responseCode: 'EMPTY');
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
      _categories = categoriesList;
      _storeSuccess(key, categoriesList);
      return categoriesList;
    } catch (e) {
      _storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      return [];
    }
  }

  @override
  Future<dynamic> focusOnProduct(String idProduct, {String? callerKey}) async {
    final key = callerKey ?? _getCallerKey('focusOnProduct', id: idProduct);
    try {
      final responseData = await _storageService.get(
        '${AppConstants.apiBaseUrl}${AppConstants.productEndpoint}',
        idProduct,
        callerKey: key,
      );

      if (responseData == null) {
        _storeFailure(key, null, code: 404, errorCode: 'NOT_FOUND');
        return null;
      }

      final product = Product.fromJson(responseData as Map<String, dynamic>);
      _storeSuccess(key, product);
      return product;
    } catch (e) {
      _storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      return null;
    }
  }

  // Helper method to clear cache (useful for testing or refresh scenarios)
  void clearCache() {
    _categories.clear();
    log('Product service cache cleared', name: 'ProductServiceImpl');
  }

  // Refresh categories method similar to AppUserServiceImpl
  Future<List<ProductCategory>> refreshCategories({String? callerKey}) async {
    _categories.clear();
    return await getCategories(callerKey: callerKey) ?? [];
  }
}
