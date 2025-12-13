import 'package:gluttex_core/business/finance/ProvidedService.dart';

// ServiceManagementService.dart
abstract class ProvidedServiceManagementService {
  Future<List<ProvidedService>?>? getAllProvidedServices(
    int offset,
    int limit, {
    int serviceId = 0,
    int categoryId = 0,
    int providerId = 0,
    int userId = 0,
    String query = "",
  }) async {
    return null;
  }

  Future<ProvidedService?> getProvidedService(String idService) async {
    return null;
  }

  Future<ProvidedService?> addProvidedService(ProvidedService Service) async {
    return null;
  }

  Future<ProvidedService?> updateProvidedService(
      ProvidedService updatedService) async {
    return null;
  }

  Future<int?> deleteProvidedService(String serviceId) async {
    return null;
  }
}
