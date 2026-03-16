import 'dart:typed_data';

import 'package:gluttex_core/business/Delivery.dart';

// DeliveryService.dart
abstract class DeliveryService {
  Future<List<Delivery>> getAllDeliveries(int offset, int limit,
      {int providerId = 0, int orderId = 0, int brokerId = 0}) async {
    throw UnimplementedError();
  }

  Future<Delivery?> getDelivery(String idDelivery) async {
    return null;
  }

  Future<Delivery?> addDelivery(dynamic Delivery) async {
    return null;
  }

  Future<Delivery?> updateDelivery(Delivery updatedDelivery) async {
    return null;
  }

  Future<int?> deleteDelivery(String productId) async {
    return null;
  }

  // Future<List<DeliveryItem>> getDeliveryDetails(int idDelivery) async {
  //   return [];
  // }
}
