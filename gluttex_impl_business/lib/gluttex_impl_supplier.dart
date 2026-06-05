// gluttex_impl_business/lib/supplier_service_impl.dart

library gluttex_impl_business;

import 'dart:developer' as developer;
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Organisation.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_core/business/services/SupplierService.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:locator/locator.dart';

class SupplierServiceImpl extends SupplierService {
  List<SupplierCategory> _categories = [];

  // Helper method to generate caller key
  String _getCallerKey(String method, {String? id, String? suffix}) {
    final parts = [method];
    if (id != null) parts.add(id);
    if (suffix != null) parts.add(suffix);
    if (parts.length == 1)
      parts.add(DateTime.now().millisecondsSinceEpoch.toString());
    return parts.join('_');
  }

  @override
  Future<SupplierCategory?> getCategoryById(int categoryId,
      {String? callerKey}) async {
    final key = callerKey ??
        _getCallerKey('getCategoryById', id: categoryId.toString());

    try {
      if (_categories.isEmpty) {
        await getCategories();
      }

      if (categoryId <= 0 || categoryId > _categories.length) {
        developer.log('Invalid category ID: $categoryId',
            name: 'SupplierServiceImpl');
        setFailureResponse(key, null,
            statusCode: 400, responseCode: 'INVALID_CATEGORY_ID');
        return null;
      }

      final category = _categories[categoryId - 1];
      setSuccessResponse(key, category,
          statusCode: 200, responseCode: 'SUCCESS');
      return category;
    } catch (e, stacktrace) {
      developer.log('Error getting category by ID: $e',
          name: 'SupplierServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'SupplierServiceImpl');
      setFailureResponse(key, e.toString(),
          statusCode: 500, responseCode: 'ERROR_GETTING_CATEGORY');
      return null;
    }
  }

  @override
  Future<List<SupplierCategory>> getCategories({String? callerKey}) async {
    final key = callerKey ?? _getCallerKey('getCategories');

    if (_categories.isNotEmpty) {
      developer.log('Returning cached categories: ${_categories.length}',
          name: 'SupplierServiceImpl');
      setSuccessResponse(key, _categories,
          statusCode: 200, responseCode: 'CACHED');
      return _categories;
    }

    try {
      final storageService = GluttexLocator.get<StorageService>();

      const url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.getSupplierCategoriesEndpoint}';
      developer.log('Fetching supplier categories from: $url',
          name: 'SupplierServiceImpl');

      final responseData = await storageService.getAll(url, callerKey: key);

      // Get status info from storage service
      final statusCode = storageService.getStatusCode(key);
      // final responseCode = storageService.getResponseCode(key);

      if (responseData == null) {
        developer.log('No categories found', name: 'SupplierServiceImpl');
        setFailureResponse(key, null,
            statusCode: statusCode ?? 404, responseCode: 'NO_CATEGORIES');
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

      setSuccessResponse(key, _categories,
          statusCode: statusCode ?? 200, responseCode: 'SUCCESS');
      return _categories;
    } catch (e, stacktrace) {
      developer.log('Error getting categories: $e',
          name: 'SupplierServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'SupplierServiceImpl');
      setFailureResponse(key, e.toString(),
          statusCode: 500, responseCode: 'ERROR_GETTING_CATEGORIES');
      return [];
    }
  }

  @override
  Future<Supplier?> addSupplier(Supplier supplier, {String? callerKey}) async {
    final key = callerKey ??
        _getCallerKey('addSupplier', suffix: supplier.providerName);

    try {
      final storageService = GluttexLocator.get<StorageService>();

      developer.log('Adding supplier: ${supplier.toJson()}',
          name: 'SupplierServiceImpl');

      final result = await storageService.insert(
        '${GluttexConstants.apiBaseUrl}${GluttexConstants.addSupplierEndpoint}',
        supplier.toJson(),
        callerKey: key,
      );

      final statusCode = storageService.getStatusCode(key);
      // final responseCode = storageService.getResponseCode(key);

      developer.log('Add supplier result: $result',
          name: 'SupplierServiceImpl');

      if (result == null) {
        developer.log('Failed to add supplier: null response',
            name: 'SupplierServiceImpl');
        setFailureResponse(key, null,
            statusCode: statusCode ?? 500, responseCode: 'ADD_FAILED');
        return null;
      }

      final createdSupplier = Supplier.fromJson(result as Map<String, dynamic>);
      setSuccessResponse(key, createdSupplier,
          statusCode: statusCode ?? 200, responseCode: 'SUCCESS');
      return createdSupplier;
    } catch (e, stacktrace) {
      developer.log('Error adding supplier: $e', name: 'SupplierServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'SupplierServiceImpl');
      setFailureResponse(key, e.toString(),
          statusCode: 500, responseCode: 'ERROR_ADDING_SUPPLIER');
      return null;
    }
  }

  @override
  Future<int?> deleteSupplier(String supplierId, {String? callerKey}) async {
    final key = callerKey ?? _getCallerKey('deleteSupplier', id: supplierId);

    try {
      final storageService = GluttexLocator.get<StorageService>();

      developer.log('Deleting supplier: $supplierId',
          name: 'SupplierServiceImpl');

      final result = await storageService.delete(
        '${GluttexConstants.apiBaseUrl}${GluttexConstants.deleteSupplierEndpoint}',
        supplierId,
        callerKey: key,
      );

      final statusCode = storageService.getStatusCode(key);
      // final responseCode = storageService.getResponseCode(key);

      developer.log('Delete result: $result', name: 'SupplierServiceImpl');

      if (result == 200 || result == 204) {
        setSuccessResponse(key, true,
            statusCode: result, responseCode: 'SUCCESS');
      } else {
        setFailureResponse(key, false,
            statusCode: result, responseCode: 'DELETE_FAILED');
      }

      return result;
    } catch (e, stacktrace) {
      developer.log('Error deleting supplier: $e', name: 'SupplierServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'SupplierServiceImpl');
      setFailureResponse(key, e.toString(),
          statusCode: 500, responseCode: 'ERROR_DELETING_SUPPLIER');
      return null;
    }
  }

  @override
  Future<Supplier?> updateSupplier(Supplier updatedSupplier,
      {String? callerKey}) async {
    final key = callerKey ??
        _getCallerKey('updateSupplier',
            id: updatedSupplier.idProductProvider.toString());

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
        callerKey: key,
      );

      final statusCode = storageService.getStatusCode(key);
      // final responseCode = storageService.getResponseCode(key);

      developer.log('Update result: $result', name: 'SupplierServiceImpl');

      if (result == null) {
        developer.log('Failed to update supplier: null response',
            name: 'SupplierServiceImpl');
        setFailureResponse(key, null,
            statusCode: statusCode ?? 500, responseCode: 'UPDATE_FAILED');
        return null;
      }

      final updated = Supplier.fromJson(result as Map<String, dynamic>);
      setSuccessResponse(key, updated,
          statusCode: statusCode ?? 200, responseCode: 'SUCCESS');
      return updated;
    } catch (e, stacktrace) {
      developer.log('Error updating supplier: $e', name: 'SupplierServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'SupplierServiceImpl');
      setFailureResponse(key, e.toString(),
          statusCode: 500, responseCode: 'ERROR_UPDATING_SUPPLIER');
      return null;
    }
  }

  @override
  Future<Supplier?> getSupplier(String id, {String? callerKey}) async {
    final key = callerKey ?? _getCallerKey('getSupplier', id: id);

    try {
      final storageService = GluttexLocator.get<StorageService>();

      final url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.supplierEndpoint}/$id';
      developer.log('Getting supplier from: $url', name: 'SupplierServiceImpl');

      final responseData = await storageService.get(
        '${GluttexConstants.apiBaseUrl}${GluttexConstants.supplierEndpoint}',
        id,
        callerKey: key,
      );

      final statusCode = storageService.getStatusCode(key);
      // final responseCode = storageService.getResponseCode(key);

      if (responseData == null) {
        developer.log('Supplier not found: $id', name: 'SupplierServiceImpl');
        setFailureResponse(key, null,
            statusCode: statusCode ?? 404, responseCode: 'NOT_FOUND');
        return null;
      }

      Supplier? supplier;

      // Handle different response formats
      if (responseData is List && responseData.isNotEmpty) {
        supplier = Supplier.fromJson(responseData[0] as Map<String, dynamic>);
      } else if (responseData is Map) {
        supplier = Supplier.fromJson(responseData as Map<String, dynamic>);
      }

      if (supplier != null) {
        setSuccessResponse(key, supplier,
            statusCode: statusCode ?? 200, responseCode: 'SUCCESS');
      } else {
        setFailureResponse(key, responseData,
            statusCode: statusCode ?? 500, responseCode: 'INVALID_FORMAT');
      }

      return supplier;
    } catch (e, stacktrace) {
      developer.log('Error getting supplier: $e', name: 'SupplierServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'SupplierServiceImpl');
      setFailureResponse(key, e.toString(),
          statusCode: 500, responseCode: 'ERROR_GETTING_SUPPLIER');
      return null;
    }
  }

  @override
  Future<List<Supplier>> searchSuppliersByToken(
    String token,
    int offset,
    int itemsPerPage, {
    String? callerKey,
  }) async {
    final key =
        callerKey ?? _getCallerKey('searchSuppliersByToken', suffix: token);

    try {
      final storageService = GluttexLocator.get<StorageService>();

      final url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.getSupplierSearchByTokenEndpoint}/$token/$offset/$itemsPerPage';
      developer.log('Searching suppliers with token: $token',
          name: 'SupplierServiceImpl');

      final responseData = await storageService.getAll(url, callerKey: key);

      final statusCode = storageService.getStatusCode(key);
      // final responseCode = storageService.getResponseCode(key);

      if (responseData == null) {
        developer.log('No suppliers found for search',
            name: 'SupplierServiceImpl');
        setFailureResponse(key, null,
            statusCode: statusCode ?? 404, responseCode: 'NO_RESULTS');
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
      setSuccessResponse(key, suppliers,
          statusCode: statusCode ?? 200, responseCode: 'SUCCESS');
      return suppliers;
    } catch (e, stacktrace) {
      developer.log('Error searching suppliers by token: $e',
          name: 'SupplierServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'SupplierServiceImpl');
      setFailureResponse(key, e.toString(),
          statusCode: 500, responseCode: 'ERROR_SEARCHING_SUPPLIERS');
      return [];
    }
  }

  @override
  Future<List<Supplier>> searchSuppliersByGeo(
    double longitude,
    double latitude,
    int offset,
    int itemsPerPage,
    double distance, {
    String? callerKey,
  }) async {
    final key = callerKey ??
        _getCallerKey('searchSuppliersByGeo',
            suffix: '${longitude}_${latitude}');

    try {
      final storageService = GluttexLocator.get<StorageService>();

      final url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.getSupplierSearchByGeoEndpoint}/$longitude/$latitude/$distance/$offset/$itemsPerPage';

      developer.log(
          'Searching suppliers near: ($longitude, $latitude) within ${distance}km',
          name: 'SupplierServiceImpl');

      final responseData = await storageService.getAll(url, callerKey: key);

      final statusCode = storageService.getStatusCode(key);
      // final responseCode = storageService.getResponseCode(key);

      if (responseData == null) {
        developer.log('No suppliers found for location',
            name: 'SupplierServiceImpl');
        setFailureResponse(key, null,
            statusCode: statusCode ?? 404, responseCode: 'NO_RESULTS');
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
      setSuccessResponse(key, suppliers,
          statusCode: statusCode ?? 200, responseCode: 'SUCCESS');
      return suppliers;
    } catch (e, stacktrace) {
      developer.log('Error searching suppliers by geo: $e',
          name: 'SupplierServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'SupplierServiceImpl');
      setFailureResponse(key, e.toString(),
          statusCode: 500, responseCode: 'ERROR_SEARCHING_BY_GEO');
      return [];
    }
  }

  @override
  Future<List<Supplier>> getAllSuppliers(
    int owner_id,
    int org_id,
    int offset,
    int itemsPerPage, {
    String? callerKey,
  }) async {
    final key = callerKey ??
        _getCallerKey('getAllSuppliers',
            suffix: '${owner_id}_${org_id}_${offset}_$itemsPerPage');

    try {
      final storageService = GluttexLocator.get<StorageService>();

      // Build URL with query parameters
      final url =
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.getAllSuppliersEndpoint}'
          '?owner_id=$owner_id&org_id=$org_id&offset=$offset&limit=$itemsPerPage';

      developer.log('Getting all suppliers from: $url',
          name: 'SupplierServiceImpl');

      final responseData = await storageService.getAll(url, callerKey: key);

      final statusCode = storageService.getStatusCode(key);
      // final responseCode = storageService.getResponseCode(key);

      if (responseData == null) {
        developer.log('No suppliers found', name: 'SupplierServiceImpl');
        setFailureResponse(key, null,
            statusCode: statusCode ?? 404, responseCode: 'NO_SUPPLIERS');
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
      setSuccessResponse(key, suppliers,
          statusCode: statusCode ?? 200, responseCode: 'SUCCESS');
      return suppliers;
    } catch (e, stacktrace) {
      developer.log('Error getting all suppliers: $e',
          name: 'SupplierServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'SupplierServiceImpl');
      setFailureResponse(key, e.toString(),
          statusCode: 500, responseCode: 'ERROR_GETTING_ALL_SUPPLIERS');
      return [];
    }
  }

  @override
  Future<List<Organisation>> getAllOrganisations(
    int owner_id,
    int org_id,
    int offset,
    int limit, {
    String? callerKey,
  }) async {
    final key = callerKey ??
        _getCallerKey('getAllOrganisations',
            suffix: '${owner_id}_${org_id}_${offset}_$limit');

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

      final responseData = await storageService.getAll(url, callerKey: key);

      final statusCode = storageService.getStatusCode(key);
      // final responseCode = storageService.getResponseCode(key);

      if (responseData == null) {
        developer.log('No organisations found', name: 'SupplierServiceImpl');
        setFailureResponse(key, null,
            statusCode: statusCode ?? 404, responseCode: 'NO_ORGANISATIONS');
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
      setSuccessResponse(key, organisations,
          statusCode: statusCode ?? 200, responseCode: 'SUCCESS');
      return organisations;
    } catch (e, stacktrace) {
      developer.log('Error getting organisations: $e',
          name: 'SupplierServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'SupplierServiceImpl');
      setFailureResponse(key, e.toString(),
          statusCode: 500, responseCode: 'ERROR_GETTING_ORGANISATIONS');
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
  Future<List<SupplierCategory>> refreshCategories({String? callerKey}) async {
    _categories.clear();
    return await getCategories(callerKey: callerKey);
  }
}
