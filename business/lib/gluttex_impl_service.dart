library business;

import 'dart:developer';
import 'dart:typed_data';
import 'package:gluttex_constants/gluttex_constants.dart';
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

  @override
  Future<ProvidedService?> addProvidedService(ProvidedService service,
      {String? callerKey}) async {
    final key = callerKey ??
        _getCallerKey('addProvidedService', suffix: service.name ?? 'unnamed');
    try {
      final result = await _storageService.insert(
        '${GluttexConstants.apiBaseUrl}${GluttexConstants.addServiceEndpoint}',
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

  @override
  Future<int?> deleteProvidedService(String serviceId,
      {String? callerKey}) async {
    final key =
        callerKey ?? _getCallerKey('deleteProvidedService', id: serviceId);
    try {
      final result = await _storageService.delete(
        '${GluttexConstants.apiBaseUrl}${GluttexConstants.deleteServiceEndpoint}/$serviceId',
        serviceId,
        callerKey: key,
      );

      if (result == 200 || result == 204) {
        _storeSuccess(key, true);
      } else {
        _storeFailure(key, false, code: result);
      }
      return result as int?;
    } catch (e) {
      _storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      return null;
    }
  }

  @override
  Future<ProvidedService?> updateProvidedService(ProvidedService updatedService,
      {String? callerKey}) async {
    final key = callerKey ??
        _getCallerKey('updateProvidedService',
            id: updatedService.id?.toString() ?? 'unknown');
    try {
      final result = await _storageService.update(
        '${GluttexConstants.apiBaseUrl}${GluttexConstants.serviceEndpoint}/${updatedService.id}',
        updatedService.id?.toString() ?? '',
        {"service_id": updatedService.id?.toString() ?? ''},
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

  @override
  Future<ProvidedService?> getProvidedService(String idService,
      {String? callerKey}) async {
    final key = callerKey ?? _getCallerKey('getProvidedService', id: idService);
    try {
      final services = await getAllProvidedServices(0, 1,
          serviceId: int.parse(idService),
          categoryId: 0,
          providerId: 0,
          userId: 0,
          callerKey: key);

      if (services == null || services.isEmpty) {
        _storeFailure(key, null, code: 404, errorCode: 'NOT_FOUND');
        return null;
      }

      final service = services[0];
      _storeSuccess(key, service);
      return service;
    } catch (e) {
      _storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      return null;
    }
  }

  @override
  Future<List<ProvidedService>?> getAllProvidedServices(int page, int limit,
      {int serviceId = 0,
      int categoryId = 0,
      int providerId = 0,
      int userId = 0,
      String query = "",
      String? callerKey}) async {
    final key = callerKey ??
        _getCallerKey('getAllProvidedServices',
            suffix: 'page_$page-limit_$limit');
    try {
      String route;

      // If there's a search query, use search endpoint (commented out in original)
      // if (query.isNotEmpty) {
      //   return await _searchServicesByToken(query, page, limit, callerKey: key);
      // }

      route =
          "${GluttexConstants.apiBaseUrl}${GluttexConstants.serviceEndpoint}/$serviceId/$categoryId/$providerId/$page/$limit";

      final responseData = await _storageService.getAll(
        route,
        callerKey: key,
      );

      if (responseData == null || responseData.isEmpty) {
        _storeSuccess(key, [], responseCode: 'EMPTY');
        return [];
      }

      // Convert the list of dynamic maps to a list of Service objects
      final List<ProvidedService> services = (responseData as List)
          .map((data) {
            try {
              return ProvidedService.fromJson(data as Map<String, dynamic>);
            } catch (e) {
              // Skip invalid entries but log the failure
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

  // Helper method for search functionality (if needed in the future)
  Future<List<ProvidedService>?> _searchServicesByToken(
      String token, int page, int limit,
      {String? callerKey}) async {
    final key =
        callerKey ?? _getCallerKey('searchServicesByToken', suffix: token);
    try {
      final data = await _storageService.getAll(
        '${GluttexConstants.apiBaseUrl}${GluttexConstants.searchServiceEndpoint}/$token/$page/$limit',
        callerKey: key,
      );

      if (data == null || data.isEmpty) {
        _storeSuccess(key, [], responseCode: 'EMPTY');
        return [];
      }

      List<ProvidedService> services = [];

      if (data is List) {
        services = data
            .map((item) =>
                ProvidedService.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (data is Map && data.containsKey('data')) {
        services = (data['data'] as List)
            .map((item) =>
                ProvidedService.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      _storeSuccess(key, services);
      return services;
    } catch (e) {
      _storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      return [];
    }
  }

  // Helper method to clear any cache if needed
  void clearCache() {
    // If there's any caching mechanism in the future
    log('Provided service cache cleared',
        name: 'ProvidedServiceManagementImpl');
  }
}
