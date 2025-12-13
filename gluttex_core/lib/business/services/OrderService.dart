import 'dart:typed_data';

import '../finance/Order.dart';

// OrderService.dart
abstract class OrderService {
  Future<List<Order>> getAllOrders(int offset, int limit,
      {int idUser = 0}) async {
    throw UnimplementedError();
  }

  Future<Order?> getOrder(String idOrder) async {
    return null;
  }

  Future<Order?> addOrder(dynamic order) async {
    return null;
  }

  Future<Order?> updateOrder(Order updatedOrder) async {
    return null;
  }

  Future<int?> deleteOrder(String productId) async {
    return null;
  }

  Future<List<OrderedItem>> getOrderDetails(int idOrder) async {
    return [];
  }
}
