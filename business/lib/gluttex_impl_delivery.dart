library business;

import 'dart:developer';
import 'dart:typed_data';

import 'package:app_constants/app_constants.dart';
import 'package:gluttex_core/business/Delivery.dart';
import 'package:gluttex_core/business/services/DeliveryService.dart';
import 'package:gluttex_core/app/GluttexException.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:locator/locator.dart';

class DeliveryServiceImpl extends DeliveryService {
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
  Future<Delivery?> addDelivery(dynamic deliveryData,
      {String? callerKey}) async {
    final key = callerKey ?? _getCallerKey('addDelivery');
    try {
      final result = await _storageService.insert(
        '${AppConstants.apiBaseUrl}${AppConstants.addDeliveryEndpoint}',
        deliveryData,
        callerKey: key,
      );

      if (result == null) {
        _storeFailure(key, null, code: 500, errorCode: 'ADD_FAILED');
        return null;
      }

      final delivery = Delivery.fromJson(result as Map<String, dynamic>);
      _storeSuccess(key, delivery);
      return delivery;
    } catch (e) {
      _storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      return null;
    }
  }

  @override
  Future<int?> deleteDelivery(String deliveryId, {String? callerKey}) async {
    final key = callerKey ?? _getCallerKey('deleteDelivery', id: deliveryId);
    try {
      // Note: The original implementation threw UnimplementedError
      // Now properly implemented with traceability
      final result = await _storageService.delete(
        '${AppConstants.apiBaseUrl}${AppConstants.deleteDeliveryEndpoint}/$deliveryId',
        deliveryId,
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
  Future<Delivery?> updateDelivery(Delivery updatedDelivery,
      {String? callerKey}) async {
    final key = callerKey ??
        _getCallerKey('updateDelivery',
            id: updatedDelivery.id_delivery?.toString() ?? 'unknown');
    try {
      // Fixed: Using correct endpoint for delivery update
      final result = await _storageService.update(
        '${AppConstants.apiBaseUrl}${AppConstants.updateDeliveryEndpoint ?? AppConstants.deliveryEndpoint}/${updatedDelivery.id_delivery}',
        updatedDelivery.id_delivery?.toString() ?? '',
        {},
        updatedDelivery.toJson(),
        callerKey: key,
      );

      if (result == null) {
        _storeFailure(key, null, code: 500, errorCode: 'UPDATE_FAILED');
        return null;
      }

      final delivery = Delivery.fromJson(result as Map<String, dynamic>);
      _storeSuccess(key, delivery);
      return delivery;
    } catch (e) {
      _storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      return null;
    }
  }

  @override
  Future<Delivery?> getDelivery(String id, {String? callerKey}) async {
    final key = callerKey ?? _getCallerKey('getDelivery', id: id);
    try {
      final data = await _storageService.get(
        '${AppConstants.apiBaseUrl}${AppConstants.deliveryEndpoint}',
        id,
        callerKey: key,
      );

      if (data == null) {
        _storeFailure(key, null, code: 404, errorCode: 'NOT_FOUND');
        return null;
      }

      final delivery = Delivery.fromJson(data as Map<String, dynamic>);
      _storeSuccess(key, delivery);
      return delivery;
    } catch (e) {
      _storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      return null;
    }
  }

  @override
  Future<List<Delivery>> getAllDeliveries(int offset, int limit,
      {int providerId = 0,
      int orderId = 0,
      int brokerId = 0,
      String? callerKey}) async {
    final key = callerKey ??
        _getCallerKey('getAllDeliveries',
            suffix: 'offset_$offset-limit_$limit');
    try {
      final responseData = await _storageService.getAll(
        "${AppConstants.apiBaseUrl}${AppConstants.getAllDeliveriesEndpoint}/$providerId/$orderId/$brokerId/$offset/$limit",
        callerKey: key,
      );

      if (responseData == null || responseData.isEmpty) {
        _storeSuccess(key, [], responseCode: 'EMPTY');
        return [];
      }

      final List<Delivery> deliveries = (responseData as List)
          .map((data) => Delivery.fromJson(data as Map<String, dynamic>))
          .toList();

      _storeSuccess(key, deliveries);
      return deliveries;
    } catch (e) {
      _storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      return [];
    }
  }

  // Additional useful methods with traceability

  Future<List<Delivery>> getDeliveriesByStatus(String status,
      {String? callerKey}) async {
    final key = callerKey ??
        _getCallerKey('getDeliveriesByStatus', suffix: 'status_$status');
    try {
      final responseData = await _storageService.getAll(
        '${AppConstants.apiBaseUrl}${AppConstants.deliveryEndpoint}/status/$status',
        callerKey: key,
      );

      if (responseData == null || responseData.isEmpty) {
        _storeSuccess(key, [], responseCode: 'EMPTY');
        return [];
      }

      final List<Delivery> deliveries = (responseData as List)
          .map((data) => Delivery.fromJson(data as Map<String, dynamic>))
          .toList();

      _storeSuccess(key, deliveries);
      return deliveries;
    } catch (e) {
      _storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      return [];
    }
  }

  Future<Delivery?> updateDeliveryStatus(String deliveryId, String newStatus,
      {String? callerKey}) async {
    final key = callerKey ??
        _getCallerKey('updateDeliveryStatus',
            id: deliveryId, suffix: 'status_$newStatus');
    try {
      final result = await _storageService.update(
        '${AppConstants.apiBaseUrl}${AppConstants.deliveryEndpoint}/status/$deliveryId',
        deliveryId,
        {},
        {'status': newStatus},
        callerKey: key,
      );

      if (result == null) {
        _storeFailure(key, null, code: 500, errorCode: 'UPDATE_FAILED');
        return null;
      }

      final delivery = Delivery.fromJson(result as Map<String, dynamic>);
      _storeSuccess(key, delivery);
      return delivery;
    } catch (e) {
      _storeFailure(key, e.toString(),
          errorCode: e is GluttexException ? e.message : 'ERROR');
      return null;
    }
  }

  // Helper method to clear any cache if needed
  void clearCache() {
    // If there's any caching mechanism in the future
    log('Delivery service cache cleared', name: 'DeliveryServiceImpl');
  }
}
