import 'dart:typed_data';

import 'package:gluttex_core/app/TraceableService.dart';
import 'package:gluttex_core/business/Delivery.dart';

// DeliveryService.dart
abstract class DeliveryService extends TraceableService {
  Future<List<Delivery>> getAllDeliveries(int offset, int limit,
      {int providerId = 0,
      int orderId = 0,
      int brokerId = 0,
      String? callerKey}) async {
    throw UnimplementedError();
  }

  Future<Delivery?> getDelivery(String idDelivery, {String? callerKey}) async {
    return null;
  }

  Future<Delivery?> addDelivery(dynamic Delivery, {String? callerKey}) async {
    return null;
  }

  Future<Delivery?> updateDelivery(Delivery updatedDelivery,
      {String? callerKey}) async {
    return null;
  }

  Future<int?> deleteDelivery(String productId, {String? callerKey}) async {
    return null;
  }

  // Future<List<DeliveryItem>> getDeliveryDetails(int idDelivery, {String? callerKey}) async {
  //   return [];
  // }
}
