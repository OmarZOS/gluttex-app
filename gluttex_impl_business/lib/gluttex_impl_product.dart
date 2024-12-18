library gluttex_impl_business;

import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/services/ProductService.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:locator/locator.dart';

class ProductServiceImpl implements ProductService {
  List<ProductCategory> categories = [];
  @override
  Future<int?> addProduct(Product Product) async {
    StorageService storageService = GluttexLocator.get<StorageService>();

    return await storageService.insert(
        GluttexConstants.apiBaseUrl + GluttexConstants.addProductEndpoint,
        Product.toJson());
  }

  @override
  Future<int?> deleteProduct(String ProductId) async {
    StorageService storageService = GluttexLocator.get<StorageService>();

    return await storageService.delete(
        GluttexConstants.apiBaseUrl + GluttexConstants.deleteProductEndpoint,
        ProductId);
  }

  @override
  Future<int?> updateProduct(Product updatedProduct) async {
    StorageService storageService = GluttexLocator.get<StorageService>();
    return await storageService.update(
        GluttexConstants.apiBaseUrl + GluttexConstants.productEndpoint,
        '${updatedProduct.id_product}',
        updatedProduct.toJson());
  }

  @override
  Future<Uint8List?> getProductImage(String id) async {
    StorageService storageService = GluttexLocator.get<StorageService>();
    List<dynamic> data = await storageService.get(
        GluttexConstants.apiBaseUrl + GluttexConstants.getProductImageEndpoint,
        id) as List<dynamic>;
    return Product.imageFromJson(data);
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
  Future<List<Product>?>? getAllProducts() async {
    try {
      // Get the storage service instance
      StorageService storageService = GluttexLocator.get<StorageService>();

      // Make a call to get all products
      List<dynamic> responseData = await storageService.getAll(
          GluttexConstants.apiBaseUrl +
              GluttexConstants.getAllProductsEndpoint);
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

    developer.log("Getting product");
    dynamic responseData = await storageService.get(
        GluttexConstants.apiBaseUrl + GluttexConstants.productEndpoint,
        idProduct);

    developer.log("Building product");
    developer.log(responseData.toString());

    // developer.log(responseData["id_product"]);
    Product product = Product.fromJson(responseData);
    developer.log("Got product");
    developer.log(product.product_name ?? "No product");

    return product;
  }
}
