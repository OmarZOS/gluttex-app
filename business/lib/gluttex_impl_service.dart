library business;

import 'dart:developer';
import 'dart:typed_data';
import 'package:app_constants/app_constants.dart';
import 'package:gluttex_core/business/finance/ProvidedService.dart';
import 'package:gluttex_core/business/services/ProvidedServiceManagementService.dart';
import 'package:gluttex_core/app/GluttexException.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:locator/locator.dart';

class ProvidedServiceManagementImpl extends ProvidedServiceManagementService {
  final StorageService _storageService = AppLocator.get<StorageService>();

  String _getCallerKey(String method, {String? id, String? suffix}) {
    final parts = [method];
    if (id != null) parts.add(id);
    if (suffix != null) parts.add(suffix);
    if (parts.length == 1)
      parts.add(DateTime.now().millisecondsSinceEpoch.toString());
    return parts.join('_');
  }

  void _storeSuccess(String key, dynamic data,
      {int? code, String? responseCode}) {
    _storageService.setSuccessResponse(key, data,
        statusCode: code ?? 200, responseCode: responseCode ?? 'SUCCESS');
  }

  void _storeFailure(String key, dynamic data,
      {int? code, String? errorCode, String? message}) {
    _storageService.setFailureResponse(key,
        data: data,
        statusCode: code ?? 500,
        errorCode: errorCode,
        message: message);
  }

  // ==================== CREATE ====================

  @override
  Future<ProvidedService?> addProvidedService(ProvidedService service,
      {String? callerKey}) async {
    final key = callerKey ??
        _getCallerKey('addProvidedService', suffix: service.name ?? 'unnamed');
    try {
      // POST /api/v1/business/services
      final result = await _storageService.insert(
        '${AppConstants.apiBaseUrl}/api/v1/business/services',
        service.toJson(),
        callerKey: key,
      );

      if (result == null) {
        _storeFailure(key, null, code: 500, errorCode: 'ADD_FAILED');
        return null;
      }

      final newService =
          ProvidedService.fromJson(result as Map<String, dynamic>);
      _storeSuccess(key, newService);
      return newService;
    } catch (e) {
      _storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      return null;
    }
  }

  // ==================== READ ====================

  @override
  Future<ProvidedService?> getProvidedService(String idService,
      {String? callerKey}) async {
    final key = callerKey ?? _getCallerKey('getProvidedService', id: idService);
    try {
      // GET /api/v1/business/services/{service_id}
      final data = await _storageService.get(
        '${AppConstants.apiBaseUrl}/api/v1/business/services/$idService',
        idService,
        callerKey: key,
      );

      if (data == null) {
        _storeFailure(key, null, code: 404, errorCode: 'NOT_FOUND');
        return null;
      }

      final service = ProvidedService.fromJson(data as Map<String, dynamic>);
      _storeSuccess(key, service);
      return service;
    } catch (e) {
      _storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      return null;
    }
  }

  @override
  Future<List<ProvidedService>?> getAllProvidedServices(
    int offset,
    int limit, {
    int serviceId = 0,
    int categoryId = 0,
    int providerId = 0,
    int userId = 0,
    String query = "",
    String? callerKey,
  }) async {
    final key = callerKey ??
        _getCallerKey('getAllProvidedServices',
            suffix: 'offset_$offset-limit_$limit');
    try {
      // GET /api/v1/business/services
      // Query params: category_id, provider_id, active_only, offset, limit

      // If there's a search query, use search endpoint
      if (query.isNotEmpty && query.length >= 2) {
        return await _searchServicesByToken(query, offset, limit,
            callerKey: key);
      }

      // Build query parameters
      final queryParams = <String, dynamic>{
        'offset': offset,
        'limit': limit,
      };

      if (categoryId > 0) queryParams['category_id'] = categoryId;
      if (providerId > 0) queryParams['provider_id'] = providerId;
      if (serviceId > 0) queryParams['service_id'] = serviceId;
      // active_only is optional - defaults to false in API

      final queryString = Uri(queryParameters: queryParams).query;

      final responseData = await _storageService.getAll(
        '${AppConstants.apiBaseUrl}/api/v1/business/services?$queryString',
        callerKey: key,
      );

      if (responseData == null || responseData.isEmpty) {
        _storeSuccess(key, [], responseCode: 'EMPTY');
        return [];
      }

      // Handle response format - could be list or object with data field
      List<dynamic> dataList;
      if (responseData is List) {
        dataList = responseData;
      } else if (responseData is Map && responseData['data'] is List) {
        dataList = responseData['data'] as List;
      } else {
        dataList = [];
      }

      final List<ProvidedService> services = dataList
          .map((data) {
            try {
              return ProvidedService.fromJson(data as Map<String, dynamic>);
            } catch (e) {
              log('Invalid service data ignored: $e',
                  name: 'ProvidedServiceManagementImpl');
              return null;
            }
          })
          .where((service) => service != null)
          .cast<ProvidedService>()
          .toList();

      _storeSuccess(key, services);
      return services;
    } catch (e) {
      _storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      return [];
    }
  }

  // ==================== UPDATE ====================

  @override
  Future<ProvidedService?> updateProvidedService(ProvidedService updatedService,
      {String? callerKey}) async {
    final key = callerKey ??
        _getCallerKey('updateProvidedService',
            id: updatedService.id?.toString() ?? 'unknown');
    try {
      // PUT /api/v1/business/services/{service_id}
      final result = await _storageService.update(
        '${AppConstants.apiBaseUrl}/api/v1/business/services/${updatedService.id}',
        updatedService.id?.toString() ?? '',
        {}, // No query params needed
        updatedService.toJson(),
        callerKey: key,
      );

      if (result == null) {
        _storeFailure(key, null, code: 500, errorCode: 'UPDATE_FAILED');
        return null;
      }

      final service = ProvidedService.fromJson(result as Map<String, dynamic>);
      _storeSuccess(key, service);
      return service;
    } catch (e) {
      _storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      return null;
    }
  }

  // ==================== DELETE ====================

  @override
  Future<int?> deleteProvidedService(String serviceId,
      {bool forceDelete = false, String? callerKey}) async {
    final key =
        callerKey ?? _getCallerKey('deleteProvidedService', id: serviceId);
    try {
      // DELETE /api/v1/business/services/{service_id}
      final queryParams = <String, dynamic>{
        if (forceDelete) 'force_delete': forceDelete,
      };
      final queryString = Uri(queryParameters: queryParams).query;
      final url = forceDelete
          ? '${AppConstants.apiBaseUrl}/api/v1/business/services/$serviceId?$queryString'
          : '${AppConstants.apiBaseUrl}/api/v1/business/services/$serviceId';

      final result = await _storageService.delete(
        url,
        serviceId,
        callerKey: key,
      );

      // 204 means success
      if (result == 204 || result == 200) {
        _storeSuccess(key, true);
        return result as int?;
      } else {
        _storeFailure(key, false, code: result);
        return result as int?;
      }
    } catch (e) {
      _storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      return null;
    }
  }

  // ==================== TOGGLE STATUS ====================

  /// Toggle service active status
  /// PATCH /api/v1/business/services/{service_id}/toggle
  Future<ProvidedService?> toggleServiceStatus(String serviceId, bool isActive,
      {String? callerKey}) async {
    final key = callerKey ??
        _getCallerKey('toggleServiceStatus',
            id: serviceId, suffix: 'active_$isActive');
    try {
      final result = await _storageService.update(
        '${AppConstants.apiBaseUrl}/api/v1/business/services/$serviceId/toggle',
        serviceId,
        {'is_active': isActive},
        {}, // No body needed
        callerKey: key,
      );

      if (result == null) {
        _storeFailure(key, null, code: 500, errorCode: 'TOGGLE_FAILED');
        return null;
      }

      final service = ProvidedService.fromJson(result as Map<String, dynamic>);
      _storeSuccess(key, service);
      return service;
    } catch (e) {
      _storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      return null;
    }
  }

  // ==================== SEARCH ====================

  Future<List<ProvidedService>?> _searchServicesByToken(
      String token, int offset, int limit,
      {String? callerKey}) async {
    final key =
        callerKey ?? _getCallerKey('searchServicesByToken', suffix: token);
    try {
      // Search endpoint would be: /api/v1/search/service/{token}/{offset}/{limit}
      // If not available, fallback to filtering from all services
      final allServices = await getAllProvidedServices(
        0, 100, // Get a reasonable amount for search
        callerKey: key,
      );

      if (allServices == null || allServices.isEmpty) {
        return [];
      }

      // Filter locally
      final filtered = allServices.where((service) {
        final searchTerm = token.toLowerCase();
        return service.name?.toLowerCase().contains(searchTerm) == true ||
            service.description?.toLowerCase().contains(searchTerm) == true;
      }).toList();

      // Apply pagination
      final start = offset;
      final end = (offset + limit).clamp(0, filtered.length);

      return filtered.sublist(start, end);
    } catch (e) {
      _storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      return [];
    }
  }

  // ==================== CATEGORY & PROVIDER FILTERS ====================

  /// Get services by category
  /// GET /api/v1/business/services/category/{category_id}
  Future<List<ProvidedService>?> getServicesByCategory(
      int categoryId, int offset, int limit,
      {String? callerKey}) async {
    final key = callerKey ??
        _getCallerKey('getServicesByCategory', id: categoryId.toString());
    try {
      final queryParams = <String, dynamic>{
        'offset': offset,
        'limit': limit,
      };
      final queryString = Uri(queryParameters: queryParams).query;

      final responseData = await _storageService.getAll(
        '${AppConstants.apiBaseUrl}/api/v1/business/services/category/$categoryId?$queryString',
        callerKey: key,
      );

      if (responseData == null || responseData.isEmpty) {
        _storeSuccess(key, [], responseCode: 'EMPTY');
        return [];
      }

      List<dynamic> dataList;
      if (responseData is List) {
        dataList = responseData;
      } else if (responseData is Map && responseData['data'] is List) {
        dataList = responseData['data'] as List;
      } else {
        dataList = [];
      }

      final services = dataList
          .map((data) => ProvidedService.fromJson(data as Map<String, dynamic>))
          .toList();

      _storeSuccess(key, services);
      return services;
    } catch (e) {
      _storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      return [];
    }
  }

  /// Get services by provider
  /// GET /api/v1/business/services/provider/{provider_id}
  Future<List<ProvidedService>?> getServicesByProvider(
      int providerId, bool activeOnly, int offset, int limit,
      {String? callerKey}) async {
    final key = callerKey ??
        _getCallerKey('getServicesByProvider', id: providerId.toString());
    try {
      final queryParams = <String, dynamic>{
        'offset': offset,
        'limit': limit,
        if (activeOnly) 'active_only': true,
      };
      final queryString = Uri(queryParameters: queryParams).query;

      final responseData = await _storageService.getAll(
        '${AppConstants.apiBaseUrl}/api/v1/business/services/provider/$providerId?$queryString',
        callerKey: key,
      );

      if (responseData == null || responseData.isEmpty) {
        _storeSuccess(key, [], responseCode: 'EMPTY');
        return [];
      }

      List<dynamic> dataList;
      if (responseData is List) {
        dataList = responseData;
      } else if (responseData is Map && responseData['data'] is List) {
        dataList = responseData['data'] as List;
      } else {
        dataList = [];
      }

      final services = dataList
          .map((data) => ProvidedService.fromJson(data as Map<String, dynamic>))
          .toList();

      _storeSuccess(key, services);
      return services;
    } catch (e) {
      _storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      return [];
    }
  }

  // ==================== BULK OPERATIONS ====================

  /// Bulk delete services
  Future<Map<String, dynamic>?> bulkDeleteServices(List<int> serviceIds,
      {bool forceDelete = false, String? callerKey}) async {
    final key = callerKey ?? _getCallerKey('bulkDeleteServices');
    try {
      final result = await _storageService.insert(
        '${AppConstants.apiBaseUrl}/api/v1/business/services/bulk/delete',
        {
          'service_ids': serviceIds,
          'force_delete': forceDelete,
        },
        callerKey: key,
      );

      if (result == null) {
        _storeFailure(key, null, code: 500, errorCode: 'BULK_DELETE_FAILED');
        return null;
      }

      _storeSuccess(key, result);
      return result as Map<String, dynamic>;
    } catch (e) {
      _storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      return null;
    }
  }

  // ==================== REQUIREMENTS ====================

  /// Get service resource requirements
  /// GET /api/v1/business/services/{service_id}/requirements
  Future<List<Map<String, dynamic>>?> getServiceRequirements(int serviceId,
      {String? callerKey}) async {
    final key = callerKey ??
        _getCallerKey('getServiceRequirements', id: serviceId.toString());
    try {
      final responseData = await _storageService.getAll(
        '${AppConstants.apiBaseUrl}/api/v1/business/services/$serviceId/requirements',
        callerKey: key,
      );

      if (responseData == null || responseData.isEmpty) {
        _storeSuccess(key, [], responseCode: 'EMPTY');
        return [];
      }

      List<Map<String, dynamic>> requirements;
      if (responseData is List) {
        requirements = responseData.cast<Map<String, dynamic>>();
      } else if (responseData is Map && responseData['data'] is List) {
        requirements =
            (responseData['data'] as List).cast<Map<String, dynamic>>();
      } else {
        requirements = [];
      }

      _storeSuccess(key, requirements);
      return requirements;
    } catch (e) {
      _storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      return [];
    }
  }

  // ==================== CACHE MANAGEMENT ====================

  void clearCache() {
    log('Provided service cache cleared',
        name: 'ProvidedServiceManagementImpl');
  }
}
