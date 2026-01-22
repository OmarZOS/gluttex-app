library gluttex_impl_business;

import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/finance/Order.dart';
import 'package:gluttex_core/business/services/OrderService.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:locator/locator.dart';

class OrderServiceImpl implements OrderService {
  @override
  Future<Order?> addOrder(dynamic order) async {
    //     "Already using another implementation in the change notifier.");
    StorageService storageService = GluttexLocator.get<StorageService>();

    return Order.fromJson(await storageService.insert(
        GluttexConstants.apiBaseUrl + GluttexConstants.addOrderEndpoint,
        order));
  }

  @override
  Future<int?> deleteOrder(String OrderId) async {
    throw UnimplementedError();
    StorageService storageService = GluttexLocator.get<StorageService>();
    // return await storageService.delete(
    //     GluttexConstants.apiBaseUrl + GluttexConstants.deleteOrderEndpoint,
    //     OrderId);
  }

  @override
  Future<Order?> updateOrder(Order updatedOrder) async {
    StorageService storageService = GluttexLocator.get<StorageService>();
    final result = await storageService.update(
        GluttexConstants.apiBaseUrl + GluttexConstants.productEndpoint,
        '${updatedOrder.idPlacedOrder}',
        {},
        updatedOrder.toJson());
    return Order.fromJson(result);
  }

  @override
  Future<Order?> getOrder(String id) async {
    StorageService storageService = GluttexLocator.get<StorageService>();
    Map<String, dynamic> data = storageService.get(
            GluttexConstants.apiBaseUrl + GluttexConstants.productEndpoint, id)
        as Map<String, dynamic>;
    return Order.fromJson(data) as Future<Order?>;
  }

  @override
  Future<List<Order>> getAllOrders(int offset, int limit,
      {int idUser = 0}) async {
    try {
      // Get the storage service instance
      StorageService storageService = GluttexLocator.get<StorageService>();

      // Make a call to get all products
      List<dynamic> responseData = await storageService.getAll(
          "${GluttexConstants.apiBaseUrl}${GluttexConstants.getAllOrdersEndpoint}/$idUser/$offset/$limit");
      // Check if the response data is not null and is a list
      // Convert the list of dynamic maps to a list of Order objects
      List dateien = responseData;
      List<Order> products = dateien
          .map((data) => Order.fromJson(data as Map<String, dynamic>))
          .toList();
      return products;
    } catch (e, stacktrace) {
      developer.log(e.toString());
      developer.log(stacktrace.toString());
      // Handle exceptions here
      return [];
    }
  }

  @override
  Future<List<OrderedItem>> getOrderDetails(int idOrder) async {
    try {
      // Get the storage service instance
      StorageService storageService = GluttexLocator.get<StorageService>();

      // Make a call to get all products
      List<dynamic> responseData = await storageService.getAll(
          "${GluttexConstants.apiBaseUrl}${GluttexConstants.getOrderDetailsEndpoint}/$idOrder");
      // Check if the response data is not null and is a list
      // Convert the list of dynamic maps to a list of Order objects
      List dateien = responseData;
      List<OrderedItem> orderedItems = dateien
          .map((data) => OrderedItem.fromJson(data as Map<String, dynamic>))
          .toList();
      return orderedItems;
    } catch (e, stacktrace) {
      developer.log(e.toString());
      developer.log(stacktrace.toString());
      // Handle exceptions here
      return [];
    }
  }
}
