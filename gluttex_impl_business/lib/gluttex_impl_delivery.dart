library gluttex_impl_business;

import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Delivery.dart';
import 'package:gluttex_core/business/services/DeliveryService.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:locator/locator.dart';

class DeliveryServiceImpl implements DeliveryService {
  @override
  Future<Delivery?> addDelivery(dynamic Delivery) async {
    //     "Already using another implementation in the change notifier.");
    StorageService storageService = GluttexLocator.get<StorageService>();

    return Delivery.fromJson(await storageService.insert(
        GluttexConstants.apiBaseUrl + GluttexConstants.addDeliveryEndpoint,
        Delivery));
  }

  @override
  Future<int?> deleteDelivery(String DeliveryId) async {
    throw UnimplementedError();
    // StorageService storageService = GluttexLocator.get<StorageService>();
    // return await storageService.delete(
    //     GluttexConstants.apiBaseUrl + GluttexConstants.deleteDeliveryEndpoint,
    //     DeliveryId);
  }

  @override
  Future<Delivery?> updateDelivery(Delivery updatedDelivery) async {
    StorageService storageService = GluttexLocator.get<StorageService>();
    final result = await storageService.update(
        GluttexConstants.apiBaseUrl + GluttexConstants.productEndpoint,
        '${updatedDelivery.id_delivery}',
        {},
        updatedDelivery.toJson());
    return Delivery.fromJson(result);
  }

  @override
  Future<Delivery?> getDelivery(String id) async {
    StorageService storageService = GluttexLocator.get<StorageService>();
    Map<String, dynamic> data = storageService.get(
            GluttexConstants.apiBaseUrl + GluttexConstants.productEndpoint, id)
        as Map<String, dynamic>;
    return Delivery.fromJson(data) as Future<Delivery?>;
  }

  @override
  Future<List<Delivery>> getAllDeliveries(int offset, int limit,
      {int providerId = 0, int orderId = 0, int brokerId = 0}) async {
    try {
      // Get the storage service instance
      StorageService storageService = GluttexLocator.get<StorageService>();

      // Make a call to get all products
      List<dynamic> responseData = await storageService.getAll(
          "${GluttexConstants.apiBaseUrl}${GluttexConstants.getAllDeliveriesEndpoint}/$providerId/$orderId/$brokerId/$offset/$limit");
      // Check if the response data is not null and is a list
      // Convert the list of dynamic maps to a list of Delivery objects
      List dateien = responseData;
      List<Delivery> products = dateien
          .map((data) => Delivery.fromJson(data as Map<String, dynamic>))
          .toList();
      return products;
    } catch (e, stacktrace) {
      developer.log(e.toString());
      developer.log(stacktrace.toString());
      // Handle exceptions here
      return [];
    }
  }
}
