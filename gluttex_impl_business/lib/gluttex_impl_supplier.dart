library gluttex_impl_business;

import 'dart:developer' as developer;
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_core/business/services/SupplierService.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:locator/locator.dart';

class SupplierServiceImpl implements SupplierService {
  List<Category> categories = [];
  @override
  Future<Category?> getCategoryById(int categoryId) async {
    if (categories.isEmpty) {
      await getCategories();
      // developer.//log('wanted: ${categoryId}');
    }
    Category category = categories[categoryId - 1];
    // developer.//log('Category length: ${category}');
    return category ?? null;
  }

  @override
  Future<List<Category>> getCategories() async {
    if (categories.isNotEmpty) return categories;
    try {
      // Get the storage service instance
      StorageService storageService = GluttexLocator.get<StorageService>();

      // Make a call to get all categories
      List<dynamic> responseData = await storageService.getAll(
          GluttexConstants.apiBaseUrl +
              GluttexConstants.getSupplierCategoriesEndpoint);

      // Check if the response data is not null and is a list
      // Convert the list of dynamic maps to a list of Supplier objects
      List dateien = responseData;
      List<Category?> categories = dateien
          .map((data) => Category.fromJson(data as Map<String, dynamic>))
          .toList();
      // developer.//log('${dateien.length}');
      return categories as List<Category>;
    } catch (e) {
      developer.log(e.toString());
      // Handle exceptions here
      return [];
    }
  }

  @override
  Future<int?> addSupplier(Supplier Supplier) async {
    StorageService storageService = GluttexLocator.get<StorageService>();

    return await storageService.insert(
        GluttexConstants.apiBaseUrl + GluttexConstants.addSupplierEndpoint,
        Supplier.toJson());
  }

  @override
  Future<int?> deleteSupplier(String SupplierId) {
    StorageService storageService = GluttexLocator.get<StorageService>();

    return storageService.delete(
        GluttexConstants.apiBaseUrl + GluttexConstants.deleteSupplierEndpoint,
        '${SupplierId}');
  }

  @override
  Future<int?> updateSupplier(Supplier updatedSupplier) {
    StorageService storageService = GluttexLocator.get<StorageService>();
    return storageService.update(
        GluttexConstants.apiBaseUrl + GluttexConstants.addSupplierEndpoint,
        updatedSupplier.id_product_provider as String,
        updatedSupplier.toJson());
  }

  @override
  Future<Supplier?> getSupplier(String id) {
    StorageService storageService = GluttexLocator.get<StorageService>();
    Map<String, dynamic> data = storageService.get(
            GluttexConstants.apiBaseUrl + GluttexConstants.supplierEndpoint, id)
        as Map<String, dynamic>;
    return Supplier.fromJson(data) as Future<Supplier?>;
  }

  @override
  Future<List<Supplier>> getAllSuppliers() async {
    try {
      // Get the storage service instance
      StorageService storageService = GluttexLocator.get<StorageService>();

      // Make a call to get all Suppliers
      List<dynamic> responseData = await storageService.getAll(
          GluttexConstants.apiBaseUrl +
              GluttexConstants.getAllSuppliersEndpoint);

      // Check if the response data is not null and is a list
      // Convert the list of dynamic maps to a list of Supplier objects
      List dateien = responseData;
      List<Supplier?> suppliers = dateien
          .map((data) => Supplier.fromJson(data as Map<String, dynamic>))
          .toList();

      return suppliers as List<Supplier>;
    } catch (e) {
      developer.log(e.toString());
      // Handle exceptions here
      return [];
    }
  }
}
