library business;

import 'dart:developer' as developer;

import 'package:app_constants/app_constants.dart';
import 'package:gluttex_core/business/Delivery.dart';
import 'package:gluttex_core/business/services/DeliveryService.dart';
import 'package:gluttex_core/app/GluttexException.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:locator/locator.dart';

class DeliveryServiceImpl extends DeliveryService {
  final StorageService _storageService = AppLocator.get<StorageService>();

  void _log(String message) {
    developer.log(message, name: 'DeliveryServiceImpl');
  }

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
  Future<Delivery?> addDelivery(dynamic deliveryData,
      {String? callerKey}) async {
    final key = callerKey ?? _getCallerKey('addDelivery');
    try {
      // POST /api/v1/business/deliveries
      final url =
          '${AppConstants.apiBaseUrl}${AppConstants.addDeliveryEndpoint}';
      _log('Adding delivery: $url');
      final result = await _storageService.insert(
        url,
        deliveryData,
        callerKey: key,
      );
      _log('Add delivery result: $result');

      if (result == null) {
        _log('Failed to add delivery: null response');
        _storeFailure(key, null, code: 500, errorCode: 'ADD_FAILED');
        return null;
      }

      final delivery = Delivery.fromJson(result as Map<String, dynamic>);
      _storeSuccess(key, delivery);
      return delivery;
    } catch (e) {
      _log('Error adding delivery: $e');
      _storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      return null;
    }
  }

  // ==================== READ ====================

  @override
  Future<Delivery?> getDelivery(String id, {String? callerKey}) async {
    final key = callerKey ?? _getCallerKey('getDelivery', id: id);
    try {
      // GET /api/v1/business/deliveries/{delivery_id}
      const url =
          '${AppConstants.apiBaseUrl}${AppConstants.getDeliveryDetailsEndpoint}';
      _log('Fetching delivery $id from: $url');
      final data = await _storageService.get(
        url,
        id,
        callerKey: key,
      );
      _log('Get delivery result for $id: $data');

      if (data == null) {
        _log('Delivery not found: $id');
        _storeFailure(key, null, code: 404, errorCode: 'NOT_FOUND');
        return null;
      }

      final delivery = Delivery.fromJson(data as Map<String, dynamic>);
      _storeSuccess(key, delivery);
      return delivery;
    } catch (e) {
      _log('Error getting delivery $id: $e');
      _storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      return null;
    }
  }

  @override
  Future<List<Delivery>> getAllDeliveries(
    int offset,
    int limit, {
    int providerId = 0,
    int orderId = 0,
    int brokerId = 0,
    String? callerKey,
  }) async {
    final key = callerKey ??
        _getCallerKey('getAllDeliveries',
            suffix: 'offset_$offset-limit_$limit');
    try {
      // ✅ FIX: Build query params with proper null checking
      final Map<String, String> queryParams = {};

      // Only add params if they have valid values (> 0)
      if (providerId > 0) {
        queryParams['provider_id'] = providerId.toString();
      }
      if (orderId > 0) queryParams['order_id'] = orderId.toString();
      if (brokerId > 0) queryParams['broker_id'] = brokerId.toString();

      // Always add offset and limit
      queryParams['offset'] = offset.toString();
      queryParams['limit'] = limit.toString();

      // ✅ FIX: Build query string safely
      final queryString = Uri(queryParameters: queryParams).query;
      final url =
          '${AppConstants.apiBaseUrl}${AppConstants.getAllDeliveriesEndpoint}?$queryString';

      _log('Fetching deliveries from: $url');

      final responseData = await _storageService.getAll(
        url,
        callerKey: key,
      );

      if (responseData == null ||
          (responseData is Iterable && responseData.isEmpty) ||
          (responseData is Map && responseData.isEmpty)) {
        _log('No deliveries found');
        _storeSuccess(key, [], responseCode: 'EMPTY');
        return [];
      }

      // Handle response format
      List<dynamic> dataList;
      if (responseData is List) {
        dataList = responseData;
      } else if (responseData is Map && responseData['data'] is List) {
        dataList = responseData['data'] as List;
      } else {
        _log(
            'Unexpected deliveries response format: ${responseData.runtimeType}');
        dataList = [];
      }

      final List<Delivery> deliveries = dataList
          .map((data) => Delivery.fromJson(data as Map<String, dynamic>))
          .toList();

      _log('Found ${deliveries.length} deliveries');
      _storeSuccess(key, deliveries);
      return deliveries;
    } catch (e, stackTrace) {
      _log('Error getting all deliveries: $e');
      _log('Stacktrace: $stackTrace');
      _storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      return [];
    }
  }

  // ==================== UPDATE ====================

  @override
  Future<Delivery?> updateDelivery(Delivery updatedDelivery,
      {String? callerKey}) async {
    final key = callerKey ??
        _getCallerKey('updateDelivery',
            id: updatedDelivery.id_delivery.toString());
    try {
      // PUT /api/v1/business/deliveries/{delivery_id}
      final url =
          '${AppConstants.apiBaseUrl}${AppConstants.updateDeliveryEndpoint}/${updatedDelivery.id_delivery}';
      _log('Updating delivery ${updatedDelivery.id_delivery}: $url');
      final result = await _storageService.update(
        url,
        updatedDelivery.id_delivery.toString(),
        {},
        updatedDelivery.toJson(),
        callerKey: key,
      );

      if (result == null) {
        _log(
            'Failed to update delivery ${updatedDelivery.id_delivery}: null response');
        _storeFailure(key, null, code: 500, errorCode: 'UPDATE_FAILED');
        return null;
      }

      final delivery = Delivery.fromJson(result as Map<String, dynamic>);
      _storeSuccess(key, delivery);
      return delivery;
    } catch (e) {
      _log('Error updating delivery ${updatedDelivery.id_delivery}: $e');
      _storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      return null;
    }
  }

  // ==================== DELETE ====================

  @override
  Future<int?> deleteDelivery(String deliveryId,
      {bool forceDelete = false, String? callerKey}) async {
    final key = callerKey ?? _getCallerKey('deleteDelivery', id: deliveryId);
    try {
      // DELETE /api/v1/business/deliveries/{delivery_id}
      _log('Deleting delivery $deliveryId');
      final queryParams = <String, String>{
        if (forceDelete) 'force_delete': forceDelete.toString(),
      };
      final queryString = Uri(queryParameters: queryParams).query;
      final url = forceDelete
          ? '${AppConstants.apiBaseUrl}${AppConstants.deleteDeliveryEndpoint}/$deliveryId?$queryString'
          : '${AppConstants.apiBaseUrl}${AppConstants.deleteDeliveryEndpoint}/$deliveryId';

      final result = await _storageService.delete(
        url,
        deliveryId,
        callerKey: key,
      );

      // 204 means success
      if (result == 204 || result == 200) {
        _log('Deleted delivery $deliveryId successfully: status $result');
        _storeSuccess(key, true);
        return result;
      } else {
        _log('Failed to delete delivery $deliveryId: status $result');
        _storeFailure(key, false, code: result);
        return result;
      }
    } catch (e) {
      _log('Error deleting delivery $deliveryId: $e');
      _storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      return null;
    }
  }

  // ==================== STATUS MANAGEMENT ====================

  /// Update only the delivery status
  /// PATCH /api/v1/business/deliveries/{delivery_id}/status
  Future<Delivery?> updateDeliveryStatus(String deliveryId, String newStatus,
      {String? callerKey}) async {
    final key = callerKey ??
        _getCallerKey('updateDeliveryStatus',
            id: deliveryId, suffix: 'status_$newStatus');
    try {
      _log('Updating delivery status: $deliveryId -> $newStatus');
      final result = await _storageService.update(
        '${AppConstants.apiBaseUrl}${AppConstants.updateDeliveryStatusEndpoint}/$deliveryId',
        deliveryId,
        {'status': newStatus},
        {}, // No body needed
        callerKey: key,
      );

      if (result == null) {
        _log('Failed to update delivery status: null response');
        _storeFailure(key, null, code: 500, errorCode: 'UPDATE_FAILED');
        return null;
      }

      final delivery = Delivery.fromJson(result as Map<String, dynamic>);
      _storeSuccess(key, delivery);
      return delivery;
    } catch (e) {
      _log('Error updating delivery status $deliveryId: $e');
      _storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      return null;
    }
  }

  /// Update only the delivery address
  /// PATCH /api/v1/business/deliveries/{delivery_id}/address
  Future<Delivery?> updateDeliveryAddress(String deliveryId, int addressId,
      {String? callerKey}) async {
    final key = callerKey ??
        _getCallerKey('updateDeliveryAddress',
            id: deliveryId, suffix: 'address_$addressId');
    try {
      _log('Updating delivery address: $deliveryId -> $addressId');
      final result = await _storageService.update(
        '${AppConstants.apiBaseUrl}${AppConstants.updateDeliveryAddressEndpoint}/$deliveryId',
        deliveryId,
        {'address_id': addressId},
        {}, // No body needed
        callerKey: key,
      );

      if (result == null) {
        _log('Failed to update delivery address: null response');
        _storeFailure(key, null, code: 500, errorCode: 'UPDATE_FAILED');
        return null;
      }

      final delivery = Delivery.fromJson(result as Map<String, dynamic>);
      _storeSuccess(key, delivery);
      return delivery;
    } catch (e) {
      _log('Error updating delivery address $deliveryId: $e');
      _storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      return null;
    }
  }

  /// Update delivery tracking location
  /// PATCH /api/v1/business/deliveries/{delivery_id}/tracking
  Future<Delivery?> updateDeliveryTracking(
      String deliveryId, int currentAddressId,
      {String? callerKey}) async {
    final key = callerKey ??
        _getCallerKey('updateDeliveryTracking',
            id: deliveryId, suffix: 'tracking_$currentAddressId');
    try {
      _log('Updating delivery tracking: $deliveryId -> $currentAddressId');
      final result = await _storageService.update(
        '${AppConstants.apiBaseUrl}${AppConstants.updateDeliveryTrackingEndpoint}/$deliveryId',
        deliveryId,
        {'current_address_id': currentAddressId},
        {}, // No body needed
        callerKey: key,
      );

      if (result == null) {
        _log('Failed to update delivery tracking: null response');
        _storeFailure(key, null, code: 500, errorCode: 'UPDATE_FAILED');
        return null;
      }

      final delivery = Delivery.fromJson(result as Map<String, dynamic>);
      _storeSuccess(key, delivery);
      return delivery;
    } catch (e) {
      _log('Error updating delivery tracking $deliveryId: $e');
      _storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      return null;
    }
  }

  // ==================== BULK OPERATIONS ====================

  /// Bulk delete deliveries matching criteria
  /// POST /api/v1/business/deliveries/bulk/delete
  Future<Map<String, dynamic>?> bulkDeleteDeliveries({
    int providerId = 0,
    int orderId = 0,
    String? status,
    bool forceDelete = false,
    String? callerKey,
  }) async {
    final key = callerKey ?? _getCallerKey('bulkDeleteDeliveries');
    try {
      _log(
          'Bulk deleting deliveries (providerId: $providerId, orderId: $orderId, status: $status)');
      final queryParams = <String, String>{
        if (providerId > 0) 'provider_id': providerId.toString(),
        if (orderId > 0) 'order_id': orderId.toString(),
        if (status != null && status.isNotEmpty) 'status': status,
        if (forceDelete) 'force_delete': forceDelete.toString(),
      };
      final queryString = Uri(queryParameters: queryParams).query;

      final result = await _storageService.insert(
        '${AppConstants.apiBaseUrl}${AppConstants.bulkDeleteDeliveriesEndpoint}?$queryString',
        {}, // Empty body
        callerKey: key,
      );

      if (result == null) {
        _log('Failed to bulk delete deliveries: null response');
        _storeFailure(key, null, code: 500, errorCode: 'BULK_DELETE_FAILED');
        return null;
      }

      _storeSuccess(key, result);
      return result as Map<String, dynamic>;
    } catch (e) {
      _log('Error bulk deleting deliveries: $e');
      _storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      return null;
    }
  }

  /// Bulk update status for multiple deliveries
  /// POST /api/v1/business/deliveries/bulk/update-status
  Future<Map<String, dynamic>?> bulkUpdateStatus({
    required String status,
    required List<int> deliveryIds,
    String? callerKey,
  }) async {
    final key = callerKey ??
        _getCallerKey('bulkUpdateStatus', suffix: 'status_$status');
    try {
      _log(
          'Bulk updating delivery status: $status (${deliveryIds.length} deliveries)');
      final result = await _storageService.insert(
        '${AppConstants.apiBaseUrl}${AppConstants.bulkUpdateDeliveryStatusEndpoint}',
        {
          'status': status,
          'delivery_ids': deliveryIds,
        },
        callerKey: key,
      );

      if (result == null) {
        _log('Failed to bulk update delivery status: null response');
        _storeFailure(key, null, code: 500, errorCode: 'BULK_UPDATE_FAILED');
        return null;
      }

      _storeSuccess(key, result);
      return result as Map<String, dynamic>;
    } catch (e) {
      _log('Error bulk updating delivery status: $e');
      _storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      return null;
    }
  }

  // ==================== STATISTICS ====================

  /// Get delivery statistics
  /// GET /api/v1/business/deliveries/stats
  Future<Map<String, dynamic>?> getDeliveryStats({String? callerKey}) async {
    final key = callerKey ?? _getCallerKey('getDeliveryStats');
    try {
      _log('Fetching delivery statistics');
      final result = await _storageService.getAll(
        '${AppConstants.apiBaseUrl}${AppConstants.getDeliveryStatsEndpoint}',
        callerKey: key,
      );

      if (result == null) {
        _log('No delivery statistics found');
        _storeFailure(key, null, code: 404, errorCode: 'NOT_FOUND');
        return null;
      }

      _storeSuccess(key, result);
      return result as Map<String, dynamic>;
    } catch (e) {
      _log('Error getting delivery statistics: $e');
      _storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      return null;
    }
  }

  // ==================== LEGACY / CONVENIENCE ====================

  /// Get deliveries by status (legacy - uses the status endpoint)
  Future<List<Delivery>> getDeliveriesByStatus(String status,
      {String? callerKey}) async {
    final key = callerKey ??
        _getCallerKey('getDeliveriesByStatus', suffix: 'status_$status');
    try {
      _log('Fetching deliveries by status: $status');
      // GET /api/v1/business/deliveries/status/{status}
      final responseData = await _storageService.getAll(
        '${AppConstants.apiBaseUrl}${AppConstants.getDeliveriesByStatusEndpoint}/$status',
        callerKey: key,
      );

      if (responseData == null || responseData.isEmpty) {
        _log('No deliveries found for status: $status');
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

      final List<Delivery> deliveries = dataList
          .map((data) => Delivery.fromJson(data as Map<String, dynamic>))
          .toList();

      _log('Found ${deliveries.length} deliveries for status: $status');
      _storeSuccess(key, deliveries);
      return deliveries;
    } catch (e) {
      _log('Error getting deliveries by status $status: $e');
      _storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      return [];
    }
  }

  // ==================== CACHE MANAGEMENT ====================

  void clearCache() {
    _log('Delivery service cache cleared');
  }
}
