library gluttex_impl_business;

import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/finance/ProvidedService.dart';
import 'package:gluttex_core/business/services/ProvidedServiceManagementService.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:locator/locator.dart';

class ProvidedServiceManagementImpl
    implements ProvidedServiceManagementService {
  @override
  Future<ProvidedService?> addProvidedService(ProvidedService service) async {
    StorageService storageService = GluttexLocator.get<StorageService>();
    final result = await storageService.insert(
        GluttexConstants.apiBaseUrl + GluttexConstants.addServiceEndpoint,
        service.toJson());
    return ProvidedService.fromJson(result);
  }

  @override
  Future<int?> deleteProvidedService(String serviceId) async {
    StorageService storageService = GluttexLocator.get<StorageService>();

    return await storageService.delete(
        GluttexConstants.apiBaseUrl + GluttexConstants.deleteServiceEndpoint,
        serviceId);
  }

  @override
  Future<ProvidedService?> updateProvidedService(
      ProvidedService updatedService) async {
    StorageService storageService = GluttexLocator.get<StorageService>();
    final result = await storageService.update(
        '${GluttexConstants.apiBaseUrl}${GluttexConstants.serviceEndpoint}/${updatedService.id}',
        '',
        {"service_id": "${updatedService.id}"},
        updatedService.toJson());
    return ProvidedService.fromJson(result);
  }

  @override
  Future<ProvidedService?> getProvidedService(String idService) async {
    return (await getAllProvidedServices(0, 1,
        serviceId: int.parse(idService),
        categoryId: 0,
        providerId: 0,
        userId: 0))?[0];
  }

  @override
  Future<List<ProvidedService>?>? getAllProvidedServices(
    int page,
    int limit, {
    int serviceId = 0,
    int categoryId = 0,
    int providerId = 0,
    int userId = 0,
    String query = "",
  }) async {
    try {
      // Get the storage service instance
      StorageService storageService = GluttexLocator.get<StorageService>();
      String route;
      // if (query != "")
      //   // ignore: curly_braces_in_flow_control_structures
      //   return searchServicesByToken(query, page, limit);
      // else
      // ignore: curly_braces_in_flow_control_structures
      route =
          "${GluttexConstants.apiBaseUrl}${GluttexConstants.serviceEndpoint}/$serviceId/$categoryId/$providerId/$page/$limit";
      // if (category > 0) {
      // } else {
      //   route =
      //       "${GluttexConstants.apiBaseUrl}${GluttexConstants.getAllServicesEndpoint}/$page/$limit";
      // }
      // Make a call to get all Services
      List<dynamic> responseData = await storageService.getAll(route);

      // Check if the response data is not null and is a list
      // Convert the list of dynamic maps to a list of Service objects
      List dateien = responseData;
      List<ProvidedService> Services = dateien
          .map((data) {
            try {
              return ProvidedService.fromJson(data as Map<String, dynamic>);
            } catch (e) {
              // Log error or ignore silently
              // debugPrint('Invalid Service data ignored: $e');
              return null;
            }
          })
          .where((Service) => Service != null)
          .cast<ProvidedService>()
          .toList();
      developer.log(Services.length.toString());
      return Services as List<ProvidedService>?;
    } catch (e, stacktrace) {
      developer.log(e.toString());
      developer.log(stacktrace.toString());
      // Handle exceptions here
      return [];
    }
  }
}
