import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:locator/locator.dart';

import 'package:gluttex_core/app/GluttexException.dart';
import 'package:gluttex_core/business/Organisation.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_core/business/services/SupplierService.dart';

class SupplierChangeNotifier extends ChangeNotifier {
  final SupplierService _supplierService =
      GluttexLocator.get<SupplierService>();

  // State management
  final List<Supplier> _suppliers = [];
  final List<Supplier> _detailedCache = [];
  final Map<int, Organisation> _organisations = {};

  Position? _currentLocation;
  SupplierFilter _filter = const SupplierFilter();
  bool _isLoading = false;
  bool _isDisposed = false;

  // Pagination
  int _suppliersPage = 0;
  int _organisationsPage = 0;
  static const int _itemsPerPage = 50;
  static const int _organisationsPerPage = 30;
  bool _hasMoreSuppliers = true;
  bool _hasMoreOrganisations = true;

  // Debouncing for search
  Timer? _searchTimer;

  // ============ LIFECYCLE ============

  @override
  void dispose() {
    _isDisposed = true;
    _searchTimer?.cancel();
    super.dispose();
  }

  // ============ SAFE NOTIFICATION ============

  void _safeNotifyListeners() {
    if (!_isDisposed && hasListeners) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed && hasListeners) {
          notifyListeners();
        }
      });
    }
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      _safeNotifyListeners();
    }
  }

  // ============ PUBLIC GETTERS ============

  List<Supplier> get suppliers => List.unmodifiable(_suppliers);
  List<Supplier> get filteredSuppliers => _applyFilters();
  List<Supplier> get detailedSuppliers => List.unmodifiable(_detailedCache);
  List<Organisation> get organisations =>
      List.unmodifiable(_organisations.values);

  bool get isLoading => _isLoading;
  bool get hasMoreSuppliers => _hasMoreSuppliers;
  bool get hasMoreOrganisations => _hasMoreOrganisations;
  Position? get currentLocation => _currentLocation;
  SupplierFilter get filter => _filter;

  // ============ FILTER MANAGEMENT ============

  void setFilter(SupplierFilter newFilter) {
    _filter = newFilter;
    _safeNotifyListeners();
  }

  void clearFilter() {
    _filter = const SupplierFilter();
    _safeNotifyListeners();
  }

  List<Supplier> _applyFilters() {
    return _suppliers.where((supplier) {
      if (_filter.name != null && !_matchesName(supplier, _filter.name!)) {
        return false;
      }
      if (_filter.organisationId != null &&
          supplier.idProviderOrganisation != _filter.organisationId) {
        return false;
      }
      if (_filter.ownerId != null &&
          supplier.productProviderOwnerId != _filter.ownerId) {
        return false;
      }
      // if (_filter.minRating != null &&
      //     (supplier.averageRating ?? 0) < _filter.minRating!) {
      //   return false;
      // }
      if (_filter.types != null && _filter.types!.isNotEmpty) {
        final supplierType = supplier.productProviderTypeId;
        if (supplierType == null || !_filter.types!.contains(supplierType)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  bool _matchesName(Supplier supplier, String query) {
    final name = supplier.providerName.toLowerCase();
    final lowerQuery = query.toLowerCase();
    return name.contains(lowerQuery);
  }

  // ============ SUPPLIER MANAGEMENT ============

  Future<void> fetchSuppliers({
    bool reset = false,
    int? ownerId,
    int? organisationId,
    bool notify = true,
  }) async {
    if (_isLoading || (!reset && !_hasMoreSuppliers)) return;

    if (reset) {
      _suppliers.clear();
      _suppliersPage = 0;
      _hasMoreSuppliers = true;
    }

    _setLoading(true);

    try {
      final fetched = await _supplierService.getAllSuppliers(
        ownerId ?? 0,
        organisationId ?? 0,
        _suppliersPage * _itemsPerPage,
        _itemsPerPage,
      );

      _addSuppliers(fetched, notify: false);

      if (fetched.length < _itemsPerPage) {
        _hasMoreSuppliers = false;
      } else {
        _suppliersPage++;
      }
    } catch (e, stackTrace) {
      _handleError('Failed to fetch suppliers', e, stackTrace);
    } finally {
      _setLoading(false);
      if (notify) {
        _safeNotifyListeners();
      }
    }
  }

  Future<Supplier?> getSupplierById(int id,
      {bool forceRefresh = false, bool notify = true}) async {
    // Check cache first
    if (!forceRefresh) {
      final cached = _detailedCache.firstWhere(
        (s) => s.idProductProvider == id,
        orElse: () => Supplier.empty(),
      );

      if (cached.idProductProvider != 0) {
        return cached;
      }
    }

    _setLoading(true);

    try {
      final supplier = await _supplierService.getSupplier(id.toString());
      if (supplier != null) {
        _cacheSupplier(supplier);
        _updateSupplierInList(supplier, notify: false);
      }
      return supplier;
    } catch (e, stackTrace) {
      _handleError('Failed to fetch supplier $id', e, stackTrace);
      return null;
    } finally {
      _setLoading(false);
      if (notify) {
        _safeNotifyListeners();
      }
    }
  }

  Future<Supplier> createOrUpdateSupplier(Supplier supplier) async {
    _setLoading(true);

    try {
      // Handle image upload if present
      if (supplier.supplierImage != null) {
        String? imageUrl = await supplier.supplierImage?.uploadImage();
        supplier = supplier.copyWith(supplierImageUrl: imageUrl);
      }

      final result = supplier.idProductProvider == 0
          ? await _supplierService.addSupplier(supplier)
          : await _supplierService.updateSupplier(supplier);

      if (result == null) {
        throw GluttexException('Failed to save supplier');
      }

      _cacheSupplier(result);
      _updateSupplierInList(result, notify: false);

      // Refresh list if needed
      if (supplier.idProductProvider == 0) {
        await fetchSuppliers(reset: true, notify: false);
      }

      return result;
    } catch (e, stackTrace) {
      _handleError('Failed to save supplier', e, stackTrace);
      rethrow;
    } finally {
      _setLoading(false);
      _safeNotifyListeners();
    }
  }

  Future<bool> deleteSupplier(int id) async {
    _setLoading(true);

    try {
      final status = await _supplierService.deleteSupplier(id.toString());
      final success = status != null;

      if (success) {
        _suppliers.removeWhere((s) => s.idProductProvider == id);
        _detailedCache.removeWhere((s) => s.idProductProvider == id);
      }

      return success;
    } catch (e, stackTrace) {
      _handleError('Failed to delete supplier', e, stackTrace);
      return false;
    } finally {
      _setLoading(false);
      _safeNotifyListeners();
    }
  }

  // ============ SEARCH FUNCTIONALITY ============

  Future<void> searchSuppliers(String query,
      {Duration delay = const Duration(milliseconds: 500)}) async {
    // Cancel previous timer
    _searchTimer?.cancel();

    if (query.isEmpty) {
      clearFilter();
      return;
    }

    // Debounce search
    _searchTimer = Timer(delay, () async {
      if (_isDisposed) return;

      setFilter(SupplierFilter(name: query));

      // Local search first
      final localResults = _applyFilters();
      if (localResults.isNotEmpty) {
        _safeNotifyListeners();
      }

      _setLoading(true);

      try {
        final remoteResults = await _supplierService.searchSuppliersByToken(
          query,
          0,
          _suppliersPage * _itemsPerPage,
        );

        _addSuppliers(remoteResults, notify: false);
      } catch (e, stackTrace) {
        _handleError('Failed to search suppliers', e, stackTrace);
      } finally {
        _setLoading(false);
        _safeNotifyListeners();
      }
    });
  }

  Future<void> searchSuppliersByGeo({
    required double longitude,
    required double latitude,
    required double radiusKm,
    bool reset = false,
    bool notify = true,
  }) async {
    if (reset) {
      _suppliers.clear();
      _suppliersPage = 0;
    }

    _setLoading(true);

    try {
      final results = await _supplierService.searchSuppliersByGeo(
        longitude,
        latitude,
        _suppliersPage * _itemsPerPage,
        _itemsPerPage,
        radiusKm,
      );

      _addSuppliers(results, notify: false);

      if (results.length < _itemsPerPage) {
        _hasMoreSuppliers = false;
      } else {
        _suppliersPage++;
      }
    } catch (e, stackTrace) {
      _handleError('Failed to search suppliers by location', e, stackTrace);
    } finally {
      _setLoading(false);
      if (notify) {
        _safeNotifyListeners();
      }
    }
  }

  // ============ LOCATION MANAGEMENT ============

  Future<void> getCurrentLocation({bool notify = true}) async {
    if (_isLoading) return;

    // Only allow on mobile platforms
    if (!Platform.isAndroid && !Platform.isIOS) {
      return;
    }

    _setLoading(true);

    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return;
        }
      }

      // Verify we have proper permission
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }

      // Get location with timeout
      _currentLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 15));
    } on TimeoutException {
      // Silent fail on timeout
    } catch (e) {
      debugPrint('Location error: $e');
    } finally {
      _setLoading(false);
      if (notify) {
        _safeNotifyListeners();
      }
    }
  }

  // ============ ORGANISATION MANAGEMENT ============

  Future<void> fetchOrganisations({
    bool reset = false,
    int? ownerId,
    int? organisationId,
    bool notify = true,
  }) async {
    if (_isLoading || (!reset && !_hasMoreOrganisations)) return;

    if (reset) {
      _organisations.clear();
      _organisationsPage = 0;
      _hasMoreOrganisations = true;
    }

    _setLoading(true);

    try {
      final results = await _supplierService.getAllOrganisations(
        ownerId ?? 0,
        organisationId ?? 0,
        _organisationsPage * _organisationsPerPage,
        _organisationsPerPage,
      );

      if (results != null && results.isNotEmpty) {
        for (final org in results) {
          _organisations[org.id_provider_organisation] = org;
        }
        _organisationsPage++;
      } else {
        _hasMoreOrganisations = false;
      }
    } catch (e, stackTrace) {
      _handleError('Failed to fetch organisations', e, stackTrace);
    } finally {
      _setLoading(false);
      if (notify) {
        _safeNotifyListeners();
      }
    }
  }

  Organisation? getOrganisationById(int id) {
    return _organisations[id];
  }

  // ============ HELPER METHODS ============

  void _addSuppliers(List<Supplier> newSuppliers, {bool notify = true}) {
    final existingIds = _suppliers.map((s) => s.idProductProvider).toSet();

    for (final supplier in newSuppliers) {
      if (!existingIds.contains(supplier.idProductProvider)) {
        _suppliers.add(supplier);
      }
    }

    if (notify) {
      _safeNotifyListeners();
    }
  }

  void _cacheSupplier(Supplier supplier) {
    final index = _detailedCache.indexWhere(
      (s) => s.idProductProvider == supplier.idProductProvider,
    );

    if (index != -1) {
      _detailedCache[index] = supplier;
    } else {
      _detailedCache.add(supplier);
    }
  }

  void _updateSupplierInList(Supplier supplier, {bool notify = true}) {
    final index = _suppliers.indexWhere(
      (s) => s.idProductProvider == supplier.idProductProvider,
    );

    if (index != -1) {
      _suppliers[index] = supplier;
    }

    if (notify) {
      _safeNotifyListeners();
    }
  }

  void _handleError(String message, Object error, StackTrace stackTrace) {
    debugPrint('$message: $error');
  }

  // ============ BATCH OPERATIONS ============

  Future<void> refreshAll({bool notify = true}) async {
    await Future.wait([
      fetchSuppliers(reset: true, notify: false),
      fetchOrganisations(reset: true, notify: false),
    ]);

    if (notify) {
      _safeNotifyListeners();
    }
  }

  Future<void> prefetchSupplierDetails(List<int> supplierIds) async {
    final missingIds = supplierIds
        .where(
          (id) => !_detailedCache.any((s) => s.idProductProvider == id),
        )
        .toList();

    if (missingIds.isEmpty) return;

    await Future.wait(
      missingIds.map((id) => getSupplierById(id, notify: false)),
    );
  }

  // ============ STATE RESET ============

  void reset() {
    _suppliers.clear();
    _detailedCache.clear();
    _organisations.clear();
    _currentLocation = null;
    _filter = const SupplierFilter();
    _suppliersPage = 0;
    _organisationsPage = 0;
    _hasMoreSuppliers = true;
    _hasMoreOrganisations = true;
    _isLoading = false;
    _searchTimer?.cancel();
    _searchTimer = null;

    // Don't notify here - let the caller decide when to notify
  }
}

// ============ DATA CLASSES ============

@immutable
class SupplierFilter {
  final String? name;
  final int? organisationId;
  final int? ownerId;
  final double? minRating;
  final List<int>? types;
  final String? status;
  final bool? hasLocation;
  final bool? isActive;

  const SupplierFilter({
    this.name,
    this.organisationId,
    this.ownerId,
    this.minRating,
    this.types,
    this.status,
    this.hasLocation,
    this.isActive,
  });

  SupplierFilter copyWith({
    String? name,
    int? organisationId,
    int? ownerId,
    double? minRating,
    List<int>? types,
    String? status,
    bool? hasLocation,
    bool? isActive,
  }) {
    return SupplierFilter(
      name: name ?? this.name,
      organisationId: organisationId ?? this.organisationId,
      ownerId: ownerId ?? this.ownerId,
      minRating: minRating ?? this.minRating,
      types: types ?? this.types,
      status: status ?? this.status,
      hasLocation: hasLocation ?? this.hasLocation,
      isActive: isActive ?? this.isActive,
    );
  }

  bool get isEmpty =>
      name == null &&
      organisationId == null &&
      ownerId == null &&
      minRating == null &&
      (types == null || types!.isEmpty) &&
      status == null &&
      hasLocation == null &&
      isActive == null;
}
