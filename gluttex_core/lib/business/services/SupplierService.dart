// SupplierService.dart

import '../Supplier.dart';

abstract class SupplierService {
  Future<List<Category>> getCategories() async {
    throw UnimplementedError();
  }

  Future<Category?> getCategoryById(int categoryId) {
    throw UnimplementedError();
    // throw UnimplementedError();
  }

  Future<Supplier?> getSupplier(String id) async {
    throw UnimplementedError();
  }

  Future<List<Supplier>> getAllSuppliers() async {
    throw UnimplementedError();
  }

  Future<int?> addSupplier(Supplier supplier) async {
    throw UnimplementedError();
  }

  Future<int?> updateSupplier(Supplier updatedSupplier) async {
    throw UnimplementedError();
  }

  Future<int?> deleteSupplier(String supplierId) async {
    throw UnimplementedError();
  }
}
