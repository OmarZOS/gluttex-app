// SupplierService.dart

import '../Supplier.dart';

abstract class SupplierService {
  Future<List<SupplierCategory>> getCategories() async {
    throw UnimplementedError();
  }

  Future<SupplierCategory?> getCategoryById(int categoryId) {
    throw UnimplementedError();
    // throw UnimplementedError();
  }

  Future<Supplier?> getSupplier(String id) async {
    throw UnimplementedError();
  }

  Future<List<Supplier>> getAllSuppliers(int offset, int itemsPerPage) async {
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
