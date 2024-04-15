// SupplierService.dart
import 'Supplier.dart';

abstract class SupplierService {
  Future<List<Supplier>?> getAllSuppliers() async {
    return null;
  }

  Future<void> addSupplier(Supplier supplier) async {
// ... code to add a new supplier
  }

  Future<void> updateSupplier(Supplier updatedSupplier) async {
// ... code to update an existing supplier
  }

  Future<void> deleteSupplier(int supplierId) async {
// ... code to delete a supplier by id
  }
}
