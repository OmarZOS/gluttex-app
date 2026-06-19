library business;

import 'dart:developer' as developer;
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/finance/BusinessOperation.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:locator/locator.dart';
import 'package:gluttex_core/business/services/BusinessOperationService.dart';

class BusinessOperationServiceImpl implements BusinessOperationService {
  @override
  Future<List<BusinessOperation>?>? getAllBusinessOperations(
      int page, int limit,
      {int supplierId = 0,
      int orderId = 0,
      int cartId = 0,
      int clientId = 0,
      int sellerId = 0}) async {
    try {
      // Get the storage service instance
      StorageService storageService = AppLocator.get<StorageService>();
      String route;
      // if (query != "")
      //   // ignore: curly_braces_in_flow_control_structures
      //   return searchServicesByToken(query, page, limit);
      // else
      // ignore: curly_braces_in_flow_control_structures
      route =
          "${GluttexConstants.apiBaseUrl}${GluttexConstants.getBusinessOperationsEndpoint}/$supplierId/$orderId/$cartId/$clientId/$sellerId/$page/$limit";
      // if (category > 0) {
      // } else {
      //   route =
      //       "${GluttexConstants.apiBaseUrl}${GluttexConstants.getAllServicesEndpoint}/$page/$limit";
      // }
      // Make a call to get all Services
      // developer.log("Getting data from: $route");
      List<dynamic> dateien = await storageService.getAll(route);
      // developer.log(responseData.toString());

      // Check if the response data is not null and is a list
      // Convert the list of dynamic maps to a list of Service objects
      final services = dateien
          .map((data) {
            try {
              return BusinessOperation.fromJson(data as Map<String, dynamic>);
            } catch (_) {
              return null;
            }
          })
          .whereType<BusinessOperation>()
          .toList();
      return services;
    } catch (e, stacktrace) {
      developer.log(e.toString());
      developer.log(stacktrace.toString());
      // Handle exceptions here
      return [];
    }
  }

  @override
  Future<BusinessOperation?> getBusinessOperation(String idBusinessOperation) {
    // TODO: implement getBusinessOperation
    throw UnimplementedError();
  }
}
