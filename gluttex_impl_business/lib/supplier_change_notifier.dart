import 'dart:developer';
import 'dart:typed_data';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_core/business/services/SupplierService.dart';
import 'package:locator/locator.dart';
import 'package:geolocator/geolocator.dart';

class SupplierChangeNotifier extends ChangeNotifier {
  final SupplierService _supplierService =
      GluttexLocator.get<SupplierService>();
  final List<Supplier> _suppliers = [];
  List<Supplier> _filteredSuppliers = [];
  bool isLoading = false;
  int currentPage = 0;
  final int itemsPerPage = 50;
  Position? _currentLocation;
  Position? get currentLocation => _currentLocation;
  bool _isLoading = false;
  List<Supplier> get suppliers => _filteredSuppliers;

  SupplierChangeNotifier() {
    fetchSuppliers();
  }
  // Future<void> fetchSuppliers() async {
  //   var suppliers = await _supplierService.getAllSuppliers();
  //   _suppliers = suppliers ?? [];
  //   notifyListeners();
  // }

  // Future<void> getCategories() async {
  //   var categories = await _supplierService.getCategories();
  //   _categories = categories ?? [];
  //   notifyListeners();
  // }

  Future<int?> getSupplier(Supplier supplier) async {
    int? status = await _supplierService.addSupplier(supplier);
    await fetchSuppliers();
    return status;
  }

  Future<int?> addSupplier(Supplier supplier) async {
    int? status = await _supplierService.addSupplier(supplier);
    await fetchSuppliers();
    return status;
  }

  // Future<void> getSupplierImage(Supplier supplier) async {
  //   Uint8List? image = await _supplierService
  //       .getSupplierImage('${supplier.id_supplier_image}');
  //   // await fetchSuppliers();
  //   // log("Changing supplier image");
  //   // log('${_suppliers.where((element) => element.id_supplier == supplier.id_supplier)}');
  //   _suppliers
  //       .where((element) => element.id_supplier == supplier.id_supplier)
  //       .first
  //       .supplier_image_data = image;
  //   notifyListeners();
  // }

  Future<int?> updateSupplier(Supplier supplier) async {
    int? status = await _supplierService.updateSupplier(supplier);
    await fetchSuppliers(reset: true);
    return status;
  }

  Future<int?> deleteSupplier(String idSupplier) async {
    int? status = await _supplierService.deleteSupplier(idSupplier);
    await fetchSuppliers();
    return status;
  }

  // void startPollingSupplierUpdates(Supplier supplier) async {
  //   // Poll every 5 seconds
  //   log("Polling supplier updates");
  //   _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
  //     await focusOnSupplier(supplier);
  //   });
  // }

  // Future<void> stopPollingSupplierUpdates() async {
  //   _pollingTimer?.cancel();
  // }

  // void updateSupplierById(int supplierId, int updatedvalue) {
  //   int index = _suppliers
  //       .indexWhere((element) => supplierId == element.id_product_provider);
  //   if (index != -1) {
  //     _suppliers[index] = _suppliers[index].copyWith(
  //       supplier_quantity: updatedvalue,
  //     );
  //   }
  //   notifyListeners();
  // }

  Future<void> fetchSuppliers(
      {bool reset = false,
      double latitude = 0.0,
      double longitude = 0.0}) async {
    if (isLoading) return;

    if (reset) {
      currentPage = 0;
      _suppliers.clear();
    }

    isLoading = true;
    notifyListeners();

    final fetchedSuppliers = await _supplierService.getAllSuppliers(
      currentPage * itemsPerPage,
      itemsPerPage,
    );

    _suppliers.addAll(fetchedSuppliers.where((newSupplier) => !_suppliers.any(
        (existing) =>
            existing.id_product_provider == newSupplier.id_product_provider)));

    _filteredSuppliers = List.from(_suppliers);
    currentPage++;
    isLoading = false;
    notifyListeners();
  }

  void searchSuppliers(String query) {
    _filteredSuppliers = _suppliers
        .where((supplier) =>
            supplier.provider_name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    notifyListeners();

    if (_filteredSuppliers.isEmpty) {
      fetchSuppliers();
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      _isLoading = true;
      notifyListeners(); // Notify UI that loading has started

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          _isLoading = false;
          notifyListeners();
          return; // Exit if permission is still denied
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _currentLocation = position;
      _isLoading = false;
      notifyListeners(); // Notify UI that location has been updated
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint("Error getting location: $e");
    }
  }
}
