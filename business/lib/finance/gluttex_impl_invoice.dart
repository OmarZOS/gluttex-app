library business;

import 'dart:developer' as developer;
import 'package:app_constants/app_constants.dart';
import 'package:gluttex_core/business/finance/FinancialDocument.dart';
import 'package:gluttex_core/business/finance/services/InvoiceService.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:locator/locator.dart';

class InvoiceServiceImpl implements InvoiceService {
  @override
  Future<FinancialDocument?> addFinancialDocument(
      dynamic financialDocument) async {
    try {
      final storageService = AppLocator.get<StorageService>();

      final url =
          '${AppConstants.apiBaseUrl}${AppConstants.postPaymentEndpoint}';
      developer.log('Adding financial document at: $url',
          name: 'InvoiceServiceImpl');
      developer.log('Financial document data: $financialDocument',
          name: 'InvoiceServiceImpl');

      final result = await storageService.insert(url, financialDocument);

      if (result == null) {
        developer.log('Failed to add financial document: null response',
            name: 'InvoiceServiceImpl');
        return null;
      }

      developer.log('Financial document added successfully',
          name: 'InvoiceServiceImpl');
      return FinancialDocument.fromJson(result as Map<String, dynamic>);
    } catch (e, stacktrace) {
      developer.log('Error adding financial document: $e',
          name: 'InvoiceServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'InvoiceServiceImpl');
      return null;
    }
  }

  @override
  Future<int?> deleteFinancialDocument(String financialDocumentId) async {
    try {
      final storageService = AppLocator.get<StorageService>();

      final url =
          '${AppConstants.apiBaseUrl}${AppConstants.getPaymentsEndpoint}/$financialDocumentId';
      developer.log('Deleting financial document at: $url',
          name: 'InvoiceServiceImpl');

      final result = await storageService.delete(url, financialDocumentId);

      developer.log('Delete result: $result', name: 'InvoiceServiceImpl');
      return result;
    } catch (e, stacktrace) {
      developer.log('Error deleting financial document: $e',
          name: 'InvoiceServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'InvoiceServiceImpl');
      return null;
    }
  }

  @override
  Future<List<FinancialDocument>?> getAllFinanceDocs(
    int offset,
    int limit, {
    int supplierId = 0,
    int personId = 0,
    int clientId = 0,
    int sellerId = 0,
    int cartId = 0,
    int orderId = 0,
    int depositId = 0,
    int invoiceId = 0,
  }) async {
    try {
      final storageService = AppLocator.get<StorageService>();

      // Build URL with query parameters (using GET endpoint)
      final queryParams = <String, dynamic>{
        'offset': offset,
        'limit': limit,
      };

      if (supplierId > 0) queryParams['supplier_id'] = supplierId;
      if (personId > 0) queryParams['person_id'] = personId;
      if (clientId > 0) queryParams['client_id'] = clientId;
      if (sellerId > 0) queryParams['seller_id'] = sellerId;
      if (cartId > 0) queryParams['cart_id'] = cartId;
      if (orderId > 0) queryParams['order_id'] = orderId;
      if (depositId > 0) queryParams['deposit_id'] = depositId;
      if (invoiceId > 0) queryParams['invoice_id'] = invoiceId;

      final url =
          '${AppConstants.apiBaseUrl}${AppConstants.getFinancialDocsEndpoint}';
      developer.log('Getting financial documents from: $url',
          name: 'InvoiceServiceImpl');
      developer.log('Query params: $queryParams', name: 'InvoiceServiceImpl');

      final responseData =
          await storageService.getAll(url, params: queryParams);

      if (responseData == null) {
        developer.log('No financial documents found',
            name: 'InvoiceServiceImpl');
        return [];
      }

      List<FinancialDocument> financialDocuments = [];

      // Handle different response formats
      if (responseData is List) {
        financialDocuments = responseData
            .map((data) {
              try {
                return FinancialDocument.fromJson(data as Map<String, dynamic>);
              } catch (e) {
                developer.log('Error parsing financial document: $e',
                    name: 'InvoiceServiceImpl');
                return null;
              }
            })
            .where((doc) => doc != null)
            .cast<FinancialDocument>()
            .toList();
      } else if (responseData is Map && responseData.containsKey('data')) {
        final dataList = responseData['data'];
        if (dataList is List) {
          financialDocuments = dataList
              .map((data) {
                try {
                  return FinancialDocument.fromJson(
                      data as Map<String, dynamic>);
                } catch (e) {
                  developer.log('Error parsing financial document: $e',
                      name: 'InvoiceServiceImpl');
                  return null;
                }
              })
              .where((doc) => doc != null)
              .cast<FinancialDocument>()
              .toList();
        }
      } else if (responseData is Map) {
        // Single document returned
        try {
          final doc =
              FinancialDocument.fromJson(responseData as Map<String, dynamic>);
          financialDocuments = [doc];
        } catch (e) {
          developer.log('Error parsing financial document: $e',
              name: 'InvoiceServiceImpl');
        }
      }

      developer.log('Found ${financialDocuments.length} financial documents',
          name: 'InvoiceServiceImpl');
      return financialDocuments;
    } catch (e, stacktrace) {
      developer.log('Error getting financial documents: $e',
          name: 'InvoiceServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'InvoiceServiceImpl');
      return [];
    }
  }

  @override
  Future<FinancialDocument?> getFinancialDocument(
      String idFinancialDocument) async {
    try {
      final storageService = AppLocator.get<StorageService>();

      final url =
          '${AppConstants.apiBaseUrl}${AppConstants.getPaymentsEndpoint}/$idFinancialDocument';
      developer.log('Getting financial document from: $url',
          name: 'InvoiceServiceImpl');

      final responseData = await storageService.get(
        '${AppConstants.apiBaseUrl}${AppConstants.getPaymentsEndpoint}',
        idFinancialDocument,
      );

      if (responseData == null) {
        developer.log('Financial document not found: $idFinancialDocument',
            name: 'InvoiceServiceImpl');
        return null;
      }

      // Handle different response formats
      if (responseData is Map) {
        return FinancialDocument.fromJson(responseData as Map<String, dynamic>);
      } else if (responseData is List && responseData.isNotEmpty) {
        return FinancialDocument.fromJson(
            responseData[0] as Map<String, dynamic>);
      }

      developer.log('Unexpected response format: ${responseData.runtimeType}',
          name: 'InvoiceServiceImpl');
      return null;
    } catch (e, stacktrace) {
      developer.log('Error getting financial document: $e',
          name: 'InvoiceServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'InvoiceServiceImpl');
      return null;
    }
  }

  @override
  Future<FinancialDocument?> updateFinancialDocument(
      FinancialDocument updatedFinancialDocument) async {
    try {
      final storageService = AppLocator.get<StorageService>();

      final url =
          '${AppConstants.apiBaseUrl}${AppConstants.getPaymentsEndpoint}/${updatedFinancialDocument.documentId}';
      developer.log('Updating financial document at: $url',
          name: 'InvoiceServiceImpl');
      developer.log('Update data: ${updatedFinancialDocument.toJson()}',
          name: 'InvoiceServiceImpl');

      final result = await storageService.update(
        url,
        updatedFinancialDocument.documentId.toString(),
        {},
        updatedFinancialDocument.toJson(),
      );

      if (result == null) {
        developer.log('Failed to update financial document: null response',
            name: 'InvoiceServiceImpl');
        return null;
      }

      developer.log('Financial document updated successfully',
          name: 'InvoiceServiceImpl');
      return FinancialDocument.fromJson(result as Map<String, dynamic>);
    } catch (e, stacktrace) {
      developer.log('Error updating financial document: $e',
          name: 'InvoiceServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'InvoiceServiceImpl');
      return null;
    }
  }

  // ==================== Additional Helper Methods ====================

  /// Get payments only
  Future<List<FinancialDocument>?> getPayments({
    int offset = 0,
    int limit = 100,
    int? invoiceId,
  }) async {
    try {
      final storageService = AppLocator.get<StorageService>();

      final queryParams = <String, dynamic>{
        'offset': offset,
        'limit': limit,
      };
      if (invoiceId != null) queryParams['invoice_id'] = invoiceId;

      final url =
          '${AppConstants.apiBaseUrl}${AppConstants.getPaymentsEndpoint}';
      developer.log('Getting payments from: $url', name: 'InvoiceServiceImpl');

      final responseData =
          await storageService.getAll(url, params: queryParams);

      if (responseData == null) return [];

      return _parseFinancialDocuments(responseData);
    } catch (e, stacktrace) {
      developer.log('Error getting payments: $e', name: 'InvoiceServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'InvoiceServiceImpl');
      return [];
    }
  }

  /// Get deposits only
  Future<List<FinancialDocument>?> getDeposits({
    int offset = 0,
    int limit = 100,
    int? cartId,
  }) async {
    try {
      final storageService = AppLocator.get<StorageService>();

      final queryParams = <String, dynamic>{
        'offset': offset,
        'limit': limit,
      };
      if (cartId != null) queryParams['cart_id'] = cartId;

      final url =
          '${AppConstants.apiBaseUrl}${AppConstants.getDepositsEndpoint}';
      developer.log('Getting deposits from: $url', name: 'InvoiceServiceImpl');

      final responseData =
          await storageService.getAll(url, params: queryParams);

      if (responseData == null) return [];

      return _parseFinancialDocuments(responseData);
    } catch (e, stacktrace) {
      developer.log('Error getting deposits: $e', name: 'InvoiceServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'InvoiceServiceImpl');
      return [];
    }
  }

  /// Get fees only
  Future<List<FinancialDocument>?> getFees({
    int offset = 0,
    int limit = 100,
    int? providerId,
    int? userId,
  }) async {
    try {
      final storageService = AppLocator.get<StorageService>();

      final queryParams = <String, dynamic>{
        'offset': offset,
        'limit': limit,
      };
      if (providerId != null) queryParams['provider_id'] = providerId;
      if (userId != null) queryParams['user_id'] = userId;

      final url = '${AppConstants.apiBaseUrl}${AppConstants.getFeesEndpoint}';
      developer.log('Getting fees from: $url', name: 'InvoiceServiceImpl');

      final responseData =
          await storageService.getAll(url, params: queryParams);

      if (responseData == null) return [];

      return _parseFinancialDocuments(responseData);
    } catch (e, stacktrace) {
      developer.log('Error getting fees: $e', name: 'InvoiceServiceImpl');
      developer.log('Stacktrace: $stacktrace', name: 'InvoiceServiceImpl');
      return [];
    }
  }

  /// Helper method to parse financial documents from response
  List<FinancialDocument> _parseFinancialDocuments(dynamic responseData) {
    List<FinancialDocument> documents = [];

    if (responseData is List) {
      documents = responseData
          .map((data) {
            try {
              return FinancialDocument.fromJson(data as Map<String, dynamic>);
            } catch (e) {
              developer.log('Error parsing financial document: $e',
                  name: 'InvoiceServiceImpl');
              return null;
            }
          })
          .where((doc) => doc != null)
          .cast<FinancialDocument>()
          .toList();
    } else if (responseData is Map && responseData.containsKey('data')) {
      final dataList = responseData['data'];
      if (dataList is List) {
        documents = dataList
            .map((data) {
              try {
                return FinancialDocument.fromJson(data as Map<String, dynamic>);
              } catch (e) {
                developer.log('Error parsing financial document: $e',
                    name: 'InvoiceServiceImpl');
                return null;
              }
            })
            .where((doc) => doc != null)
            .cast<FinancialDocument>()
            .toList();
      }
    }

    return documents;
  }
}
