library gluttex_impl_business;

import 'dart:developer' as developer;
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Organisation.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_core/business/services/SupplierService.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:locator/locator.dart';

class SupplierServiceImpl implements SupplierService {
  List<SupplierCategory> categories = [];
  @override
  Future<SupplierCategory?> getCategoryById(int categoryId) async {
    if (categories.isEmpty) {
      await getCategories();
      // developer.//log('wanted: ${categoryId}');
    }
    SupplierCategory category = categories[categoryId - 1];
    // developer.//log('Category length: ${category}');
    return category;
  }

  @override
  Future<List<SupplierCategory>> getCategories() async {
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
      List<SupplierCategory?> categories = dateien
          .map(
              (data) => SupplierCategory.fromJson(data as Map<String, dynamic>))
          .toList();
      // developer.//log('${dateien.length}');
      return categories as List<SupplierCategory>;
    } catch (e) {
      developer.log(e.toString());
      // Handle exceptions here
      return [];
    }
  }

  @override
  Future<Supplier?> addSupplier(Supplier supplier) async {
    StorageService storageService = GluttexLocator.get<StorageService>();
    final result = await storageService.insert(
        GluttexConstants.apiBaseUrl + GluttexConstants.addSupplierEndpoint,
        supplier.toJson());
    return Supplier.fromJson(result);
  }

  @override
  Future<int?> deleteSupplier(String SupplierId) {
    StorageService storageService = GluttexLocator.get<StorageService>();

    return storageService.delete(
        "${GluttexConstants.apiBaseUrl}${GluttexConstants.deleteSupplierEndpoint}",
        SupplierId);
  }

  @override
  Future<Supplier?> updateSupplier(Supplier updatedSupplier) async {
    StorageService storageService = GluttexLocator.get<StorageService>();
    final result = await storageService.update(
        '${GluttexConstants.apiBaseUrl}${GluttexConstants.updateSupplierEndpoint}/${updatedSupplier.idProductProvider}',
        '',
        {"supplier_id": "${updatedSupplier.idProductProvider}"},
        updatedSupplier.toJson());
    return Supplier.fromJson(result);
  }

  @override
  Future<Supplier?> getSupplier(String id) async {
    StorageService storageService = GluttexLocator.get<StorageService>();
    List<dynamic> data = await storageService.get(
        GluttexConstants.apiBaseUrl + GluttexConstants.supplierEndpoint, id);
    return Supplier.fromJson((data)[0] as Map<String, dynamic>);
  }

  @override
  Future<List<Supplier>> searchSuppliersByToken(
      String token, int offset, int itemsPerPage) async {
    StorageService storageService = GluttexLocator.get<StorageService>();
    List<dynamic> data = await storageService.getAll(
      '${GluttexConstants.apiBaseUrl}${GluttexConstants.getSupplierSearchByTokenEndpoint}/$token/$offset/$itemsPerPage',
    );

    List<Supplier> suppliers = data
        .map((data) => Supplier.fromSearchJson(data as Map<String, dynamic>))
        .toList();
    return suppliers;
  }

  @override
  Future<List<Supplier>> searchSuppliersByGeo(double longitude, double latitude,
      int offset, int itemsPerPage, double distance) async {
    StorageService storageService = GluttexLocator.get<StorageService>();
    List<dynamic> data = await storageService.getAll(
        '${GluttexConstants.apiBaseUrl}${GluttexConstants.getSupplierSearchByGeoEndpoint}/$longitude/$latitude/$offset/$itemsPerPage',
        params: {'distance_km': distance});

    final suppliers = (data)
        .map((item) => Supplier.fromSearchJson(item as Map<String, dynamic>))
        .toList();
    return suppliers;
  }

  @override
  Future<List<Supplier>> getAllSuppliers(
      int owner_id, int org_id, int offset, int itemsPerPage) async {
    try {
      // Get the storage service instance
      StorageService storageService = GluttexLocator.get<StorageService>();

      // Make a call to get all Suppliers
      List<dynamic> responseData = await storageService.getAll(
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.getAllSuppliersEndpoint}/$owner_id/$org_id/$offset/$itemsPerPage');

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

  @override
  Future<List<Organisation>> getAllOrganisations(
      int owner_id, int org_id, int offset, int limit) async {
    try {
      // Get the storage service instance
      StorageService storageService = GluttexLocator.get<StorageService>();

      // Make a call to get all categories
      List<dynamic> responseData = await storageService.getAll(
          "${GluttexConstants.apiBaseUrl}${GluttexConstants.getOrganisations}/$offset/$limit");

      // Check if the response data is not null and is a list
      // Convert the list of RecipeCategory maps to a list of Supplier objects
      List dateien = responseData;
      developer.log(dateien.toString());
      List<Organisation>? mappedIngredients = dateien
          .map((data) => Organisation.fromJson(data as Map<String, dynamic>))
          .toList();
      // developer.//log('${dateien.length}');
      return mappedIngredients;
    } catch (e) {
      developer.log(e.toString());
      // Handle exceptions here
      return [];
    }
  }
}
