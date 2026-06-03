// gluttex_impl_business/lib/supplier_service_impl.dart

library gluttex_impl_business;

import 'dart:developer' as developer;
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Organisation.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_core/business/services/SupplierService.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:locator/locator.dart';

class SupplierServiceImpl implements SupplierService {
  List<SupplierCategory> _categories = [];

  @override
  Future<SupplierCategory?> getCategoryById(int categoryId) async {
    try {
      if (_categories.isEmpty) {
        await getCategories();
      }

      if (categoryId <= 0 || categoryId > _categories.length) {
        developer.log('Invalid category ID: $categoryId',
            name: 'SupplierServiceImpl');
        return null;
      }

      return _categories[categoryId - 1];
    } catch (e, stacktrace) {
      developer.log('Error getting category by ID: $e',
          name: 'SupplierServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'SupplierServiceImpl');
      return null;
    }
  }

  @override
  Future<List<SupplierCategory>> getCategories() async {
    if (_categories.isNotEmpty) {
      developer.log('Returning cached categories: ${_categories.length}',
          name: 'SupplierServiceImpl');
      return _categories;
    }

    try {
      final storageService = GluttexLocator.get<StorageService>();

      const url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.getSupplierCategoriesEndpoint}';
      developer.log('Fetching supplier categories from: $url',
          name: 'SupplierServiceImpl');

      final responseData = await storageService.getAll(url);

      if (responseData == null) {
        developer.log('No categories found', name: 'SupplierServiceImpl');
        return [];
      }

      List<SupplierCategory> categories = [];

      if (responseData is List) {
        categories = responseData
            .map((data) =>
                SupplierCategory.fromJson(data as Map<String, dynamic>))
            .toList();
      } else if (responseData is Map && responseData.containsKey('data')) {
        final dataList = responseData['data'];
        if (dataList is List) {
          categories = dataList
              .map((data) =>
                  SupplierCategory.fromJson(data as Map<String, dynamic>))
              .toList();
        }
      }

      _categories = categories;
      developer.log('Found ${_categories.length} categories',
          name: 'SupplierServiceImpl');

      return _categories;
    } catch (e, stacktrace) {
      developer.log('Error getting categories: $e',
          name: 'SupplierServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'SupplierServiceImpl');
      return [];
    }
  }

  @override
  Future<Supplier?> addSupplier(Supplier supplier) async {
    try {
      final storageService = GluttexLocator.get<StorageService>();

      developer.log('Adding supplier: ${supplier.toJson()}',
          name: 'SupplierServiceImpl');

      final result = await storageService.insert(
        '${GluttexConstants.apiBaseUrl}${GluttexConstants.addSupplierEndpoint}',
        supplier.toJson(),
      );

      developer.log('Add supplier result: $result',
          name: 'SupplierServiceImpl');

      if (result == null) {
        developer.log('Failed to add supplier: null response',
            name: 'SupplierServiceImpl');
        return null;
      }

      return Supplier.fromJson(result as Map<String, dynamic>);
    } catch (e, stacktrace) {
      developer.log('Error adding supplier: $e', name: 'SupplierServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'SupplierServiceImpl');
      return null;
    }
  }

  @override
  Future<int?> deleteSupplier(String supplierId) async {
    try {
      final storageService = GluttexLocator.get<StorageService>();

      developer.log('Deleting supplier: $supplierId',
          name: 'SupplierServiceImpl');

      final result = await storageService.delete(
        '${GluttexConstants.apiBaseUrl}${GluttexConstants.deleteSupplierEndpoint}',
        supplierId,
      );

      developer.log('Delete result: $result', name: 'SupplierServiceImpl');
      return result;
    } catch (e, stacktrace) {
      developer.log('Error deleting supplier: $e', name: 'SupplierServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'SupplierServiceImpl');
      return null;
    }
  }

  @override
  Future<Supplier?> updateSupplier(Supplier updatedSupplier) async {
    try {
      final storageService = GluttexLocator.get<StorageService>();

      final url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.updateSupplierEndpoint}/${updatedSupplier.idProductProvider}';

      developer.log('Updating supplier at: $url', name: 'SupplierServiceImpl');
      developer.log('Supplier data: ${updatedSupplier.toJson()}',
          name: 'SupplierServiceImpl');

      final result = await storageService.update(
        url,
        updatedSupplier.idProductProvider.toString(),
        {"supplier_id": updatedSupplier.idProductProvider.toString()},
        updatedSupplier.toJson(),
      );

      developer.log('Update result: $result', name: 'SupplierServiceImpl');

      if (result == null) {
        developer.log('Failed to update supplier: null response',
            name: 'SupplierServiceImpl');
        return null;
      }

      return Supplier.fromJson(result as Map<String, dynamic>);
    } catch (e, stacktrace) {
      developer.log('Error updating supplier: $e', name: 'SupplierServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'SupplierServiceImpl');
      return null;
    }
  }

  @override
  Future<Supplier?> getSupplier(String id) async {
    try {
      final storageService = GluttexLocator.get<StorageService>();

      final url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.supplierEndpoint}/$id';
      developer.log('Getting supplier from: $url', name: 'SupplierServiceImpl');

      final responseData = await storageService.get(
        '${GluttexConstants.apiBaseUrl}${GluttexConstants.supplierEndpoint}',
        id,
      );

      if (responseData == null) {
        developer.log('Supplier not found: $id', name: 'SupplierServiceImpl');
        return null;
      }

      // Handle different response formats
      if (responseData is List && responseData.isNotEmpty) {
        return Supplier.fromJson(responseData[0] as Map<String, dynamic>);
      } else if (responseData is Map) {
        return Supplier.fromJson(responseData as Map<String, dynamic>);
      }

      developer.log('Unexpected response format: ${responseData.runtimeType}',
          name: 'SupplierServiceImpl');
      return null;
    } catch (e, stacktrace) {
      developer.log('Error getting supplier: $e', name: 'SupplierServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'SupplierServiceImpl');
      return null;
    }
  }

  @override
  Future<List<Supplier>> searchSuppliersByToken(
      String token, int offset, int itemsPerPage) async {
    try {
      final storageService = GluttexLocator.get<StorageService>();

      final url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.getSupplierSearchByTokenEndpoint}/$token/$offset/$itemsPerPage';
      developer.log('Searching suppliers with token: $token',
          name: 'SupplierServiceImpl');

      final responseData = await storageService.getAll(url);

      if (responseData == null) {
        developer.log('No suppliers found for search',
            name: 'SupplierServiceImpl');
        return [];
      }

      List<Supplier> suppliers = [];

      if (responseData is List) {
        suppliers = responseData
            .map(
                (data) => Supplier.fromSearchJson(data as Map<String, dynamic>))
            .toList();
      } else if (responseData is Map && responseData.containsKey('data')) {
        final dataList = responseData['data'];
        if (dataList is List) {
          suppliers = dataList
              .map((data) =>
                  Supplier.fromSearchJson(data as Map<String, dynamic>))
              .toList();
        }
      }

      developer.log('Found ${suppliers.length} suppliers',
          name: 'SupplierServiceImpl');
      return suppliers;
    } catch (e, stacktrace) {
      developer.log('Error searching suppliers by token: $e',
          name: 'SupplierServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'SupplierServiceImpl');
      return [];
    }
  }

  @override
  Future<List<Supplier>> searchSuppliersByGeo(double longitude, double latitude,
      int offset, int itemsPerPage, double distance) async {
    try {
      final storageService = GluttexLocator.get<StorageService>();

      final url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.getSupplierSearchByGeoEndpoint}/$longitude/$latitude/$distance/$offset/$itemsPerPage';

      developer.log(
          'Searching suppliers near: ($longitude, $latitude) within ${distance}km',
          name: 'SupplierServiceImpl');

      final responseData = await storageService.getAll(url);

      if (responseData == null) {
        developer.log('No suppliers found for location',
            name: 'SupplierServiceImpl');
        return [];
      }

      List<Supplier> suppliers = [];

      if (responseData is List) {
        suppliers = responseData
            .map(
                (item) => Supplier.fromSearchJson(item as Map<String, dynamic>))
            .toList();
      } else if (responseData is Map && responseData.containsKey('data')) {
        final dataList = responseData['data'];
        if (dataList is List) {
          suppliers = dataList
              .map((item) =>
                  Supplier.fromSearchJson(item as Map<String, dynamic>))
              .toList();
        }
      }

      developer.log('Found ${suppliers.length} suppliers near location',
          name: 'SupplierServiceImpl');
      return suppliers;
    } catch (e, stacktrace) {
      developer.log('Error searching suppliers by geo: $e',
          name: 'SupplierServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'SupplierServiceImpl');
      return [];
    }
  }

  @override
  Future<List<Supplier>> getAllSuppliers(
      int owner_id, int org_id, int offset, int itemsPerPage) async {
    try {
      final storageService = GluttexLocator.get<StorageService>();

      // Build URL with query parameters
      final url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.getAllSuppliersEndpoint}'
          '?owner_id=$owner_id&org_id=$org_id&offset=$offset&limit=$itemsPerPage';

      developer.log('Getting all suppliers from: $url',
          name: 'SupplierServiceImpl');

      final responseData = await storageService.getAll(url);

      if (responseData == null) {
        developer.log('No suppliers found', name: 'SupplierServiceImpl');
        return [];
      }

      List<Supplier> suppliers = [];

      if (responseData is List) {
        suppliers = responseData
            .map((data) => Supplier.fromJson(data as Map<String, dynamic>))
            .toList();
      } else if (responseData is Map && responseData.containsKey('data')) {
        final dataList = responseData['data'];
        if (dataList is List) {
          suppliers = dataList
              .map((data) => Supplier.fromJson(data as Map<String, dynamic>))
              .toList();
        }
      }

      developer.log('Found ${suppliers.length} suppliers',
          name: 'SupplierServiceImpl');
      return suppliers;
    } catch (e, stacktrace) {
      developer.log('Error getting all suppliers: $e',
          name: 'SupplierServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'SupplierServiceImpl');
      return [];
    }
  }

  @override
  Future<List<Organisation>> getAllOrganisations(
      int owner_id, int org_id, int offset, int limit) async {
    try {
      final storageService = GluttexLocator.get<StorageService>();

      // Build URL with query parameters
      final url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.getOrganisationsEndpoint}'
          '?offset=$offset&limit=$limit';

      if (owner_id > 0) {
        // Add owner filter if needed
      }

      developer.log('Getting organisations from: $url',
          name: 'SupplierServiceImpl');

      final responseData = await storageService.getAll(url);

      if (responseData == null) {
        developer.log('No organisations found', name: 'SupplierServiceImpl');
        return [];
      }

      List<Organisation> organisations = [];

      if (responseData is List) {
        organisations = responseData
            .map((data) => Organisation.fromJson(data as Map<String, dynamic>))
            .toList();
      } else if (responseData is Map && responseData.containsKey('data')) {
        final dataList = responseData['data'];
        if (dataList is List) {
          organisations = dataList
              .map(
                  (data) => Organisation.fromJson(data as Map<String, dynamic>))
              .toList();
        }
      }

      developer.log('Found ${organisations.length} organisations',
          name: 'SupplierServiceImpl');
      return organisations;
    } catch (e, stacktrace) {
      developer.log('Error getting organisations: $e',
          name: 'SupplierServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'SupplierServiceImpl');
      return [];
    }
  }

  // Helper method to clear cache
  void clearCache() {
    _categories.clear();
    developer.log('Supplier service cache cleared',
        name: 'SupplierServiceImpl');
  }

  // Helper method to refresh categories
  Future<List<SupplierCategory>> refreshCategories() async {
    _categories.clear();
    return await getCategories();
  }
}
