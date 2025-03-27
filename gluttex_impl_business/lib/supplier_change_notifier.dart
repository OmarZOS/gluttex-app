import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_core/business/services/SupplierService.dart';
import 'package:locator/locator.dart';
import 'package:geolocator/geolocator.dart';

class SupplierChangeNotifier extends ChangeNotifier {
  final SupplierService _supplierService =
      GluttexLocator.get<SupplierService>();
  final List<Supplier> _suppliers = [];
  List<Supplier> _filteredSuppliers = [];
  bool _isLoading = false;
  int _currentPage = 0;
  static const int _itemsPerPage = 50;
  Position? _currentLocation;

  List<Supplier> get suppliers => _filteredSuppliers;
  bool get isLoading => _isLoading;
  Position? get currentLocation => _currentLocation;

  SupplierChangeNotifier() {
    fetchSuppliers();
  }

  Future<void> fetchSuppliers({bool reset = false}) async {
    if (_isLoading) return;

    if (reset) {
      _currentPage = 0;
      _suppliers.clear();
    }

    _isLoading = true;
    notifyListeners();

    try {
      final fetchedSuppliers = await _supplierService.getAllSuppliers(
        _currentPage * _itemsPerPage,
        _itemsPerPage,
      );

      _suppliers.addAll(
        fetchedSuppliers.where((newSupplier) => !_suppliers.any(
              (existing) =>
                  existing.idProductProvider == newSupplier.idProductProvider,
            )),
      );

      _filteredSuppliers = List.from(_suppliers);
      _currentPage++;
    } catch (e) {
      debugPrint("Error fetching suppliers: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  void searchSuppliers(String query) {
    _filteredSuppliers = _suppliers
        .where((supplier) =>
            supplier.providerName.toLowerCase().contains(query.toLowerCase()))
        .toList();
    notifyListeners();
  }

  Future<void> getCurrentLocation() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      _currentLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      debugPrint("Error getting location: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
