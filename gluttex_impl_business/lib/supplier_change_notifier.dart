
import 'package:flutter/material.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_core/business/services/SupplierService.dart';
import 'package:locator/locator.dart';

class SupplierChangeNotifier extends ChangeNotifier {
  final SupplierService _SupplierService =
      GluttexLocator.get<SupplierService>();
  List<Supplier> _Suppliers = [];
  List<Supplier> get Suppliers => _Suppliers;

  SupplierChangeNotifier() {
    fetchSuppliers();
    // fetchIngredients();
  }

  Future<void> getSupplierImage(Supplier Supplier) async {
    // Uint8List? image = await _SupplierService.getSupplierImage(
    //     '${Supplier.id_Supplier_image}');
    // // await fetchSuppliers();
    // // log("Changing Supplier image");
    // // log('${_Suppliers.where((element) => element.id_Supplier == Supplier.id_Supplier)}');
    // _Suppliers.where((element) => element.id_Supplier == Supplier.id_Supplier)
    //     .first
    //     .Supplier_image_data = image;
    // notifyListeners();
  }

  Future<void> fetchSuppliers() async {
    var Suppliers = await _SupplierService.getAllSuppliers();

    // log('${Suppliers}');
    _Suppliers = Suppliers ?? [];
    notifyListeners();
  }

  Future<int?> addSupplier(Supplier Supplier) async {
    int? status = await _SupplierService.addSupplier(Supplier);
    await fetchSuppliers();
    return status;
  }

  Future<int?> updateSupplier(Supplier Supplier) async {
    int? status = await _SupplierService.updateSupplier(Supplier);
    await fetchSuppliers();
    return status;
  }

  Future<int?> deleteSupplier(String idSupplier) async {
    int? status = await _SupplierService.deleteSupplier(idSupplier);
    await fetchSuppliers();
    return status;
  }
}
