import 'package:gluttex_core/business/finance/BusinessOperation.dart';

// BusinessOperationService.dart
abstract class BusinessOperationService {
  Future<List<BusinessOperation>?>? getAllBusinessOperations(
    int page,
    int limit, {
    int supplierId = 0,
    int orderId = 0,
    int cartId = 0,
    int clientId = 0,
    int sellerId = 0,
  }) async {
    return null;
  }

  Future<BusinessOperation?> getBusinessOperation(
      String idBusinessOperation) async {
    return null;
  }
}
