library gluttex_impl_business;

import 'dart:developer' as developer;
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/finance/FinancialDocument.dart';
import 'package:gluttex_core/business/finance/services/InvoiceService.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:locator/locator.dart';

class InvoiceServiceImpl implements InvoiceService {
  @override
  Future<FinancialDocument?> addFinancialDocument(
      dynamic financialDocument) async {
    StorageService storageService = GluttexLocator.get<StorageService>();

    return FinancialDocument.fromJson(await storageService.insert(
        GluttexConstants.apiBaseUrl + GluttexConstants.postPaymentEndpoint,
        financialDocument));
  }

  @override
  Future<int?> deleteFinancialDocument(String financialDocumentId) {
    // TODO: implement deleteFinancialDocument
    throw UnimplementedError();
  }

  @override
  Future<List<FinancialDocument>?>? getAllFinanceDocs(int offset, int limit,
      {int supplierId = 0,
      int personId = 0,
      int clientId = 0,
      int sellerId = 0,
      int cartId = 0,
      int orderId = 0,
      int depositId = 0,
      int invoiceId = 0}) async {
    try {
      // Get the storage service instance
      StorageService storageService = GluttexLocator.get<StorageService>();
      String route =
          "${GluttexConstants.apiBaseUrl}${GluttexConstants.getAllFinanceDocsEndpoint}/$supplierId/$personId/$clientId/$sellerId/$cartId/$orderId/$depositId/$invoiceId /$offset/$limit";

      // if (category > 0) {
      // } else {
      //   route =
      //       "${GluttexConstants.apiBaseUrl}${GluttexConstants.getAllInvoicesEndpoint}/$page/$limit";
      // }
      // Make a call to get all Invoices
      List<dynamic> responseData = await storageService.getAll(route);
      // Check if the response data is not null and is a list
      // Convert the list of dynamic maps to a list of Invoice objects
      List dateien = responseData;
      List<FinancialDocument> financialDocuments = dateien
          .map((data) {
            try {
              return FinancialDocument.fromJson(data as Map<String, dynamic>);
            } catch (e) {
              // Log error or ignore silently
              // debugPrint('Invalid Invoice data ignored: $e');
              return null;
            }
          })
          .where((Invoice) => Invoice != null)
          .cast<FinancialDocument>()
          .toList();
      return financialDocuments as List<FinancialDocument>?;
    } catch (e, stacktrace) {
      developer.log(e.toString());
      developer.log(stacktrace.toString());
      // Handle exceptions here
      return [];
    }
  }

  @override
  Future<FinancialDocument?> getFinancialDocument(String idFinancialDocument) {
    // TODO: implement getFinancialDocument
    throw UnimplementedError();
  }

  @override
  Future<FinancialDocument?> updateFinancialDocument(
      FinancialDocument updatedFinancialDocument) {
    // TODO: implement updateFinancialDocument
    throw UnimplementedError();
  }
}
