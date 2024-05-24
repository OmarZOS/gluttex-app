library gluttex_impl_business;

import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_core/business/SupplierService.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:locator/locator.dart';

class SupplierServiceImpl implements SupplierService {
  @override
  Future<String?> addSupplier(Supplier Supplier) {
    StorageService storageService = Locator.get<StorageService>();

    return storageService.insert(
        '$GluttexConstants.apiBaseUrl$GluttexConstants.addSupplierEndpoint',
        Supplier.toJson());
  }

  @override
  Future<String?> deleteSupplier(String SupplierId) {
    StorageService storageService = Locator.get<StorageService>();

    return storageService.delete(
        '$GluttexConstants.apiBaseUrl$GluttexConstants.deleteSupplierEndpoint',
        '$SupplierId');
  }

  @override
  Future<String?> updateSupplier(Supplier updatedSupplier) {
    StorageService storageService = Locator.get<StorageService>();
    return storageService.update(
        '$GluttexConstants.apiBaseUrl$GluttexConstants.addSupplierEndpoint',
        '$updatedSupplier.id_app_Supplier',
        updatedSupplier.toJson());
  }

  @override
  Future<Supplier?> getSupplier(String id) {
    StorageService storageService = Locator.get<StorageService>();
    Map<String, dynamic> data = storageService.get(
        '$GluttexConstants.apiBaseUrl$GluttexConstants.getSupplierEndpoint',
        id) as Map<String, dynamic>;
    return Supplier.fromJson(data) as Future<Supplier?>;
  }

  @override
  Future<List<Supplier>?>? getAllSuppliers() {
    try {
      // Get the storage service instance
      StorageService storageService = Locator.get<StorageService>();

      // Make a call to get all Suppliers
      List<Map<String, dynamic>> responseData = storageService.getAll(
              '$GluttexConstants.apiBaseUrl$GluttexConstants.getSupplierEndpoint')
          as List<Map<String, dynamic>>;

      // Check if the response data is not null and is a list
      if (responseData != null && responseData is List) {
        // Convert the list of dynamic maps to a list of Supplier objects
        List<Supplier?> Suppliers =
            responseData.map((data) => Supplier.fromJson(data)).toList();
        return Suppliers as Future<List<Supplier>?>;
      } else {
        // Return null or throw an exception based on your requirement
        return null;
      }
    } catch (e) {
      // Handle exceptions here
      return null;
    }
  }
}
