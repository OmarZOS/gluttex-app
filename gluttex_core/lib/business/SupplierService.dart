// SupplierService.dart
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:locator/locator.dart';

import 'Supplier.dart';

abstract class SupplierService {
  Future<Supplier?> getSupplier(int id) async {
    return null;
  }

  Future<List<Supplier>?> getAllSuppliers() async {
    return null;
  }

  Future<void> addSupplier(Supplier supplier) async {}

  Future<void> updateSupplier(Supplier updatedSupplier) async {
// ... code to update an existing supplier
  }

  Future<void> deleteSupplier(int supplierId) async {
// ... code to delete a supplier by id
  }
}
