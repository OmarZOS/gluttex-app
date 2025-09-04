// SupplierService.dart

import 'package:gluttex_core/business/Organisation.dart';

import '../Supplier.dart';

abstract class SupplierService {
  Future<List<SupplierCategory>> getCategories() async {
    throw UnimplementedError();
  }

  Future<List<Supplier>> searchSuppliersByToken(
      String token, int offset, int itemsPerPage) {
    throw UnimplementedError();
  }

  Future<List<Supplier>> searchSuppliersByGeo(double longitude, double latitude,
      int offset, int itemsPerPage, double distance) {
    throw UnimplementedError();
  }

  Future<SupplierCategory?> getCategoryById(int categoryId) {
    throw UnimplementedError();
    // throw UnimplementedError();
  }

  Future<Supplier?> getSupplier(String id) async {
    throw UnimplementedError();
  }

  Future<List<Supplier>> getAllSuppliers(
      int owner_id, int org_id, int offset, int itemsPerPage) async {
    throw UnimplementedError();
  }

  Future<List<Organisation>> getAllOrganisations(
      int owner_id, int org_id, int offset, int itemsPerPage) async {
    throw UnimplementedError();
  }

  Future<Supplier?> addSupplier(Supplier supplier) async {
    throw UnimplementedError();
  }

  Future<Supplier?> updateSupplier(Supplier updatedSupplier) async {
    throw UnimplementedError();
  }

  Future<int?> deleteSupplier(String supplierId) async {
    throw UnimplementedError();
  }
}
