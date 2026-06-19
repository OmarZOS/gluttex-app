import 'package:gluttex_core/app/TraceableService.dart';
import 'package:gluttex_core/business/finance/ProvidedService.dart';

// ServiceManagementService.dart
abstract class ProvidedServiceManagementService extends TraceableService {
  Future<List<ProvidedService>?>? getAllProvidedServices(int offset, int limit,
      {int serviceId = 0,
      int categoryId = 0,
      int providerId = 0,
      int userId = 0,
      String query = "",
      String? callerKey}) async {
    return null;
  }

  Future<ProvidedService?> getProvidedService(String idService,
      {String? callerKey}) async {
    return null;
  }

  Future<ProvidedService?> addProvidedService(ProvidedService Service,
      {String? callerKey}) async {
    return null;
  }

  Future<ProvidedService?> updateProvidedService(ProvidedService updatedService,
      {String? callerKey}) async {
    return null;
  }

  Future<int?> deleteProvidedService(String serviceId,
      {String? callerKey}) async {
    return null;
  }
}
