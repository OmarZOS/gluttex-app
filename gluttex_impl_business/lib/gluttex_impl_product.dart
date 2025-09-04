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
    StorageService storageService = GluttexLocator.get<StorageService>();
    final result = await storageService.insert(
        GluttexConstants.apiBaseUrl + GluttexConstants.addProductEndpoint,
        product.toJson());
    // log("At the impl prod");
    // log("${result.toString()}");

    return Product.fromJson(result);
  }

  @override
  Future<int?> deleteProduct(String ProductId) async {
    StorageService storageService = GluttexLocator.get<StorageService>();

    return await storageService.delete(
        GluttexConstants.apiBaseUrl + GluttexConstants.deleteProductEndpoint,
        ProductId);
  }

  Future<List<Product>> searchProductsByToken(
      String token, int offset, int itemsPerPage) async {
    StorageService storageService = GluttexLocator.get<StorageService>();
    List<dynamic> data = await storageService.getAll(
      '${GluttexConstants.apiBaseUrl}${GluttexConstants.getProductSearchByTokenEndpoint}/$token/$offset/$itemsPerPage',
    );

    List<Product> products = data
        .map((data) => Product.fromSearchJson(data as Map<String, dynamic>))
        .toList();
    return products;
  }

  @override
  Future<Product?> updateProduct(Product updatedProduct) async {
    StorageService storageService = GluttexLocator.get<StorageService>();

    final result = await storageService.update(
        '${GluttexConstants.apiBaseUrl}${GluttexConstants.productEndpoint}/${updatedProduct.id_product}',
        "",
        {"product_id": "${updatedProduct.id_product}"},
        updatedProduct.toJson());
    return Product.fromJson(result);
  }

  @override
  Future<Product?> getProduct(String id) async {
    StorageService storageService = GluttexLocator.get<StorageService>();
    Map<String, dynamic> data = storageService.get(
            GluttexConstants.apiBaseUrl + GluttexConstants.productEndpoint, id)
        as Map<String, dynamic>;
    return Product.fromJson(data) as Future<Product?>;
  }

  @override
  Future<List<Product>?>? getAllProducts(
      {int userId = 0,
      int providerId = 0,
      int category = 0,
      String query = "",
      int page = 1,
      int limit = 10}) async {
    try {
      // Get the storage service instance
      StorageService storageService = GluttexLocator.get<StorageService>();

      String route;

      if (query != "")
        // ignore: curly_braces_in_flow_control_structures
        return searchProductsByToken(query, page, limit);
      else
        // ignore: curly_braces_in_flow_control_structures
        route =
            "${GluttexConstants.apiBaseUrl}${GluttexConstants.getAllProductsEndpoint}/$userId/$providerId/$category/$page/$limit";

      // Make a call to get all products
      List<dynamic> responseData = await storageService.getAll(route);
      // Check if the response data is not null and is a list
      // Convert the list of dynamic maps to a list of Product objects
      List dateien = responseData;
      List<Product?> products = dateien
          .map((data) => Product.fromJson(data as Map<String, dynamic>))
          .toList();
      return products as List<Product>?;
    } catch (e, stacktrace) {
      developer.log(e.toString());
      developer.log(stacktrace.toString());
      // Handle exceptions here
      return [];
    }
  }

  @override
  Future<List<ProductCategory>>? getCategories() async {
    if (categories.isNotEmpty) return categories;
    try {
      // Get the storage service instance
      StorageService storageService = GluttexLocator.get<StorageService>();

      // Make a call to get all categories
      List<dynamic> responseData = await storageService.getAll(
          GluttexConstants.apiBaseUrl +
              GluttexConstants.getProductCategoriesEndpoint);

      // Check if the response data is not null and is a list
      // Convert the list of ProductCategory maps to a list of Supplier objects
      List dateien = responseData;
      List<ProductCategory?> categories = dateien
          .map((data) => ProductCategory.fromJson(data as Map<String, dynamic>))
          .toList();
      // developer.//log('${dateien.length}');
      return categories as List<ProductCategory>;
    } catch (e) {
      developer.log(e.toString());
      // Handle exceptions here
      return [];
    }
  }

  @override
  Future<dynamic> focusOnProduct(String idProduct) async {
    StorageService storageService = GluttexLocator.get<StorageService>();
    // developer.log("message: focusOnProduct");
    // Convert the list of dynamic maps to a list of Product objects

    dynamic responseData = await storageService.get(
        GluttexConstants.apiBaseUrl + GluttexConstants.productEndpoint,
        idProduct);

    Product product = Product.fromJson(responseData);

    return product;
  }
}
