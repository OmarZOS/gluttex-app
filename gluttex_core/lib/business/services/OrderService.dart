import 'dart:typed_data';

import '../Order.dart';

// OrderService.dart
abstract class OrderService {
  Future<List<Order>> getAllOrders(int idUser) async {
    throw UnimplementedError();
  }

  Future<Order?> getOrder(String idOrder) async {
    return null;
  }

  Future<int?> addOrder(Order Order) async {
    return null;
  }

  Future<int?> updateOrder(Order updatedOrder) async {
    return null;
  }

  Future<int?> deleteOrder(String productId) async {
    return null;
  }
}
