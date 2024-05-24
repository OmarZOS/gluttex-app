// SupplierService.dart
import 'package:locator/locator.dart';

import 'Supplier.dart';

abstract class SupplierService {
  Future<Supplier?> getSupplier(String id) async {
    return null;
  }

  Future<List<Supplier>?>? getAllSuppliers() async {
    return null;
  }

  Future<String?> addSupplier(Supplier supplier) async {
    return null;
  }

  Future<String?> updateSupplier(Supplier updatedSupplier) async {
    return null;
  }

  Future<String?> deleteSupplier(String supplierId) async {
    return null;
  }
}
