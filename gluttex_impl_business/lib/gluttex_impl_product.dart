library gluttex_impl_business;

import 'dart:developer' as developer;

import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/ProductService.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:locator/locator.dart';

class ProductServiceImpl implements ProductService {
  @override
  Future<String?> addProduct(Product Product) {
    StorageService storageService = Locator.get<StorageService>();

    return storageService.insert(
        '$GluttexConstants.apiBaseUrl$GluttexConstants.addProductEndpoint',
        Product.toJson());
  }

  @override
  Future<String?> deleteProduct(String ProductId) {
    StorageService storageService = Locator.get<StorageService>();

    return storageService.delete(
        '$GluttexConstants.apiBaseUrl$GluttexConstants.addProductEndpoint',
        '$ProductId');
  }

  @override
  Future<String?> updateProduct(Product updatedProduct) {
    StorageService storageService = Locator.get<StorageService>();
    return storageService.update(
        '$GluttexConstants.apiBaseUrl$GluttexConstants.addProductEndpoint',
        '$updatedProduct.id_app_Product',
        updatedProduct.toJson());
  }

  @override
  Future<Product?> getProduct(String id) {
    StorageService storageService = Locator.get<StorageService>();
    Map<String, dynamic> data = storageService.get(
        '$GluttexConstants.apiBaseUrl$GluttexConstants.getProductEndpoint',
        id) as Map<String, dynamic>;
    return Product.fromJson(data) as Future<Product?>;
  }

  @override
  Future<List<Product>?>? getAllProducts() async {
    try {
      // Get the storage service instance
      StorageService storageService = Locator.get<StorageService>();

      // Make a call to get all products
      List<dynamic> responseData = await storageService.getAll(
          GluttexConstants.apiBaseUrl +
              GluttexConstants.getAllProductsEndpoint);
      // Check if the response data is not null and is a list
      if (responseData != null) {
        // Convert the list of dynamic maps to a list of Product objects
        List dateien = responseData;
        List<Product?> products = dateien
            .map((data) => Product.fromJson(data as Map<String, dynamic>))
            .toList();
        return products as List<Product>?;
      } else {
        developer.log("Unknown response data format");
        // Return null or throw an exception based on your requirement
        return [] as Future<List<Product>?>?;
      }
    } catch (e) {
      developer.log(e.toString());
      // Handle exceptions here
      return [] as Future<List<Product>?>?;
    }
  }
}
