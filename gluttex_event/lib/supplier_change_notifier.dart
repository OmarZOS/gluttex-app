import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:gluttex_core/app/GluttexException.dart';
import 'package:gluttex_core/business/Organisation.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_core/business/services/SupplierService.dart';
import 'package:locator/locator.dart';
import 'package:geolocator/geolocator.dart';

class SupplierChangeNotifier extends ChangeNotifier {
  final SupplierService _supplierService =
      GluttexLocator.get<SupplierService>();
  List<Supplier> _suppliers = [];
  List<Supplier> detailed_suppliers = [];
  List<Supplier> _filteredSuppliers = [];
  bool isLoading = false;
  // bool get isLoading => isLoading;
  int _currentPage = 0;
  static const int _itemsPerPage = 50;
  Position? _currentLocation;

  final Map<int, Organisation> _supplierOrganisations = {};

  int currentOrganisationPage = 0;
  bool hasMoreOrganisations = true;

  final int organisationsPerPage = 30;

  List<Supplier> get suppliers => _filteredSuppliers;
  Position? get currentLocation => _currentLocation;

  SupplierChangeNotifier() {
    fetchSuppliers();
  }
  List<Organisation> get supplierOrganisations =>
      _supplierOrganisations.values.toList();

  Future<Supplier?> getSupplierById(int id) async {
    final data =
        detailed_suppliers.where((element) => id == element.idProductProvider);

    if (data.isNotEmpty) {
      return data.firstOrNull;
    }
    isLoading = true;

    notifyListeners();

    try {
      final supplier = await _supplierService.getSupplier(id.toString());
      if (supplier != null) {
        // Find the index of the supplier in the cache
        final index = _suppliers.indexWhere(
          (s) => s.idProductProvider == supplier.idProductProvider,
        );

        if (index != -1) {
          // Update existing supplier
          _suppliers[index] = supplier;
        } else {
          // Insert if it's new
          _suppliers.add(supplier);
        }

        // Keep detailed cache in sync (avoid duplicates)
        if (!detailed_suppliers
            .any((s) => s.idProductProvider == supplier.idProductProvider)) {
          detailed_suppliers.add(supplier);
        }

        // Refresh filtered list
        _filteredSuppliers = List.from(_suppliers);
      }

      return supplier;
    } catch (e) {
      debugPrint("Error fetching supplier by ID ($id): $e");
      return _suppliers
          .where((element) => id == element.idProductProvider)
          .firstOrNull;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Supplier?> addOrUpdateRecipe(Supplier supplier) async {
    try {
      log('Adding/updating supplier: ${supplier.providerName}');
      if (supplier.supplier_image != null) {
        String? imageUrl = await supplier.supplier_image?.uploadImage();
        supplier.supplier_image_url = imageUrl;
        supplier.supplier_image_id = 0; // Reset image ID to ensure new upload
      }

      Supplier? data = (supplier.idProductProvider == 0
          ? await _supplierService.addSupplier(supplier)
          : await _supplierService.updateSupplier(supplier));
      // updateLocalSupplier(supplier);
      await fetchSuppliers(reset: true);
      return data;
    } catch (e) {
      log("Failed to add/update recipe: $e");
      throw GluttexException(e.toString());
    }
  }

  /// Deletes a recipe and updates the local state efficiently
  Future<void> deleteSupplier(int idProductProvider) async {
    int? status =
        await _supplierService.deleteSupplier(idProductProvider.toString());
    if (status != null) {
      _suppliers.removeWhere((s) => s.idProductProvider == idProductProvider);
      _filteredSuppliers = List.from(_suppliers);

      notifyListeners();
    }
  }

  Future<void> fetchSuppliers(
      {bool reset = false, int owner_id = 0, int org_id = 0}) async {
    if (isLoading) return;

    if (reset) {
      _currentPage = 0;
      detailed_suppliers.clear();
      _suppliers.clear();
    }

    isLoading = true;
    notifyListeners();

    try {
      final fetchedSuppliers = await _supplierService.getAllSuppliers(
        owner_id,
        org_id,
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

    isLoading = false;
    notifyListeners();
  }

  Future<void> searchSuppliers(String query) async {
    // Always filter locally first
    _filteredSuppliers = _suppliers
        .where((supplier) =>
            supplier.providerName.toLowerCase().contains(query.toLowerCase()))
        .toList();

    isLoading = true;
    notifyListeners();

    try {
      // Fetch remote results
      final fetchedSuppliers = await _supplierService.searchSuppliersByToken(
        query,
        currentOrganisationPage,
        _currentPage * _itemsPerPage,
      );

      // Merge without duplicates
      for (var newSupplier in fetchedSuppliers) {
        final exists = _suppliers.any(
          (existing) =>
              existing.idProductProvider == newSupplier.idProductProvider,
        );
        if (!exists) {
          _suppliers.add(newSupplier);
        }
      }

      // Re-filter with updated supplier list
      _filteredSuppliers = _suppliers
          .where((supplier) =>
              supplier.providerName.toLowerCase().contains(query.toLowerCase()))
          .toList();

      _currentPage++;
    } catch (e, st) {
      debugPrint("Error fetching suppliers: $e\n$st");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchSuppliersByGeo({
    required double longitude,
    required double latitude,
    required double distance,
    int offset = 0,
    int itemsPerPage = 20,
    bool reset = false,
  }) async {
    if (reset) {
      _currentPage = 0;
      _suppliers.clear();
      _filteredSuppliers.clear();
      notifyListeners();
    }

    isLoading = true;
    notifyListeners();

    try {
      final fetchedSuppliers = await _supplierService.searchSuppliersByGeo(
        longitude,
        latitude,
        offset,
        itemsPerPage,
        distance,
      );

      // Only add non-duplicates
      for (var newSupplier in fetchedSuppliers) {
        final exists = _suppliers.any(
          (existing) =>
              existing.idProductProvider == newSupplier.idProductProvider,
        );
        if (!exists) {
          _suppliers.add(newSupplier);
        }
      }

      // Show only suppliers from the fetched set when filtering by geo
      if (reset) {
        _filteredSuppliers = List.from(fetchedSuppliers);
      } else {
        _filteredSuppliers.addAll(
          fetchedSuppliers.where((s) => !_filteredSuppliers.any(
                (existing) => existing.idProductProvider == s.idProductProvider,
              )),
        );
      }

      if (fetchedSuppliers.isNotEmpty) {
        _currentPage++;
      }
    } catch (e, st) {
      debugPrint("Error fetching suppliers by geo: $e\n$st");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getCurrentLocation() async {
    if (isLoading) return;

    isLoading = true;
    notifyListeners();

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          isLoading = false;
          notifyListeners();
          return;
        }
      }

      _currentLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      debugPrint("Error getting location: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  /// Fetches all ingredients and stores them in a map for fast lookups
  Future<void> fetchOrganisations(
      {bool reset = false, int owner_id = 0, int org_id = 0}) async {
    if (reset) {
      _supplierOrganisations?.clear();
      currentOrganisationPage = 0;
      hasMoreOrganisations = true;
    }

    if (!hasMoreOrganisations || isLoading) return;

    isLoading = true;
    notifyListeners();

    try {
      final fetchedOrganisations = await _supplierService.getAllOrganisations(
          owner_id,
          org_id,
          currentOrganisationPage * organisationsPerPage,
          organisationsPerPage);

      if (fetchedOrganisations != null && fetchedOrganisations.isNotEmpty) {
        for (var organisation in fetchedOrganisations) {
          _supplierOrganisations[organisation.id_provider_organisation] =
              organisation;
        }
        currentOrganisationPage++;
      } else {
        hasMoreOrganisations = false;
      }

      notifyListeners();
    } catch (e) {
      // log("Failed to fetch Organisations: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
