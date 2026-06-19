import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gluttex_core/business/finance/FinancialDocument.dart';
import 'package:gluttex_core/business/finance/services/InvoiceService.dart';
import 'package:locator/locator.dart';
import 'package:gluttex_core/app/GluttexException.dart';

class FinanceChangeNotifier extends ChangeNotifier {
  // Get the invoice service instance
  final InvoiceService _invoiceService = AppLocator.get<InvoiceService>();

  // State management - store ALL documents including duplicates for grouping
  final List<FinancialDocument> _allDocuments = [];
  final List<FinancialDocument> _groupedDocuments = []; // Display these to UI
  final List<FinancialDocument> _detailedCache = [];

  // Filter state
  FinanceDocumentFilter _filter = const FinanceDocumentFilter();
  bool _isLoading = false;

  // Pagination
  int _documentsPage = 0;
  static const int _itemsPerPage = 50;
  bool _hasMoreDocuments = true;

  // Search results
  final List<FinancialDocument> _searchResults = [];
  bool _isSearching = false;
  String? _currentSearchQuery;

  // Filter cache for quick access
  final Map<String, List<FinancialDocument>> _filterCache = {};

  // Grouped document mapping (primary doc ID -> list of related doc IDs)
  final Map<int, List<int>> _documentGroups = {};

  // ============ PUBLIC GETTERS ============

  // Return grouped documents for UI display
  List<FinancialDocument> get documents => List.unmodifiable(_groupedDocuments);
  List<FinancialDocument> get filteredDocuments => _applyFilters();
  List<FinancialDocument> get detailedDocuments =>
      List.unmodifiable(_detailedCache);
  List<FinancialDocument> get searchResults =>
      List.unmodifiable(_searchResults);

  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  bool get hasMoreDocuments => _hasMoreDocuments;
  FinanceDocumentFilter get filter => _filter;
  String? get currentSearchQuery => _currentSearchQuery;

  // Analytics state
  bool _isCalculatingAnalytics = false;
  double _totalRevenue = 0.0;
  double _totalCollected = 0.0;
  double _totalOutstanding = 0.0;
  int _totalTransactions = 0;
  Map<String, double> _revenueBySource = {};
  Map<String, double> _collectionsByStatus = {};
  Map<String, double> _revenueByDocumentType = {};

  // Analytics cache
  AnalyticsCache? _analyticsCache;

  // Add to existing getters
  bool get isCalculatingAnalytics => _isCalculatingAnalytics;
  double get totalRevenue => _totalRevenue;
  double get totalCollected => _totalCollected;
  double get totalOutstanding => _totalOutstanding;
  int get totalTransactions => _totalTransactions;
  Map<String, double> get revenueBySource => Map.unmodifiable(_revenueBySource);
  Map<String, double> get collectionsByStatus =>
      Map.unmodifiable(_collectionsByStatus);
  Map<String, double> get revenueByDocumentType =>
      Map.unmodifiable(_revenueByDocumentType);
  AnalyticsCache? get analyticsCache => _analyticsCache;

  // Collection rate (computed property)
  double get collectionRate {
    return _totalRevenue > 0 ? (_totalCollected / _totalRevenue) * 100 : 0.0;
  }

  // ============ ANALYTICS METHODS ============

  Future<void> refreshAnalytics() async {
    if (_isCalculatingAnalytics || _groupedDocuments.isEmpty) return;

    _isCalculatingAnalytics = true;
    notifyListeners();

    try {
      _calculateAnalytics();
    } finally {
      _isCalculatingAnalytics = false;
      notifyListeners();
    }
  }

  void _calculateAnalytics() {
    if (_groupedDocuments.isEmpty) {
      _resetAnalytics();
      return;
    }

    // Reset analytics
    _totalRevenue = 0.0;
    _totalCollected = 0.0;
    _totalOutstanding = 0.0;
    _totalTransactions = 0;
    _revenueBySource.clear();
    _collectionsByStatus.clear();
    _revenueByDocumentType.clear();

    // Calculate from grouped documents (not all documents)
    for (final doc in _groupedDocuments) {
      final amount = doc.documentAmount ?? 0;
      final paid = doc.totalPaid ?? 0;
      final outstanding = doc.outstandingBalance ?? 0;
      final source = doc.sourceType ?? 'unknown';
      final status = doc.paymentStatus ?? 'unknown';
      final docType = doc.documentType ?? 'unknown';

      _totalRevenue += amount; // Use +=, not =
      _totalCollected += paid;
      _totalOutstanding += outstanding;
      _totalTransactions++;

      // Revenue by source
      _revenueBySource.update(
        source,
        (value) => value + amount,
        ifAbsent: () => amount,
      );

      // Collections by status
      _collectionsByStatus.update(
        status,
        (value) => value + paid,
        ifAbsent: () => paid,
      );

      // Revenue by document type
      _revenueByDocumentType.update(
        docType,
        (value) => value + amount,
        ifAbsent: () => amount,
      );
    }

    // Create analytics cache
    _analyticsCache = AnalyticsCache(
      totalRevenue: _totalRevenue,
      totalCollected: _totalCollected,
      totalOutstanding: _totalOutstanding,
      transactionCount: _totalTransactions,
      revenueBySource: Map.from(_revenueBySource),
      collectionsByStatus: Map.from(_collectionsByStatus),
      collectionRate: collectionRate,
      revenueByDocumentType: Map.from(_revenueByDocumentType),
    );
  }

  void _resetAnalytics() {
    _totalRevenue = 0.0;
    _totalCollected = 0.0;
    _totalOutstanding = 0.0;
    _totalTransactions = 0;
    _revenueBySource.clear();
    _collectionsByStatus.clear();
    _revenueByDocumentType.clear();
    _analyticsCache = null;
  }

  // Update the fetchDocuments method to auto-calculate analytics
  Future<void> fetchDocuments({
    bool reset = false,
    int supplierId = 0,
    int personId = 0,
    int clientId = 0,
    int sellerId = 0,
    int cartId = 0,
    int orderId = 0,
    int depositId = 0,
    int invoiceId = 0,
    bool calculateAnalytics = true,
  }) async {
    if (_isLoading || (!reset && !_hasMoreDocuments)) return;

    if (reset) {
      _allDocuments.clear();
      _groupedDocuments.clear();
      _documentGroups.clear();
      _documentsPage = 0;
      _hasMoreDocuments = true;
      _clearFilterCache();
      _resetAnalytics();
    }

    _setLoading(true);

    try {
      debugPrint('Fetching documents...');

      final fetched = await _invoiceService.getAllFinanceDocs(
        _documentsPage * _itemsPerPage,
        _itemsPerPage,
        supplierId: supplierId,
        personId: personId,
        clientId: clientId,
        sellerId: sellerId,
        cartId: cartId,
        orderId: orderId,
        depositId: depositId,
        invoiceId: invoiceId,
      );

      if (fetched != null && fetched.isNotEmpty) {
        debugPrint('Fetched ${fetched.length} documents:');
        for (final doc in fetched) {
          debugPrint(
              '  - ${doc.documentType} ${doc.documentId}: \$${doc.documentAmount?.toStringAsFixed(2)} for customer ${doc.customerId}, supplier ${doc.supplierId}');
        }

        _addDocuments(fetched);

        // Auto-group after adding new documents
        _groupDocuments();

        if (fetched.length < _itemsPerPage) {
          _hasMoreDocuments = false;
        } else {
          _documentsPage++;
        }

        if (calculateAnalytics) {
          _calculateAnalytics();
        }
      } else {
        _hasMoreDocuments = false;
        debugPrint('No documents fetched');
      }
    } catch (e, stackTrace) {
      _handleError('Failed to fetch financial documents', e, stackTrace);
    } finally {
      _setLoading(false);
    }
  }

  // Update the refreshAll method
  Future<void> refreshAll(
      {FinanceDocumentFilter? filter, bool calculateAnalytics = true}) async {
    if (filter != null) {
      setFilter(filter);
    }

    await fetchDocuments(reset: true, calculateAnalytics: calculateAnalytics);
  }

  // ============ STATISTICS METHODS (ENHANCED) ============

  // Total amount for filtered documents (existing property - keep as is)
  double get totalAmount {
    return filteredDocuments.fold(
        0.0, (sum, doc) => sum + (doc.documentAmount ?? 0));
  }

  // Additional analytics methods
  Map<String, double> getAmountByStatus() {
    final Map<String, double> amounts = {};

    for (final doc in filteredDocuments) {
      final status = doc.paymentStatus ?? 'Unknown';
      amounts[status] = (amounts[status] ?? 0.0) + (doc.documentAmount ?? 0);
    }

    return amounts;
  }

  Map<String, int> getTransactionCountBySource() {
    final Map<String, int> counts = {};

    for (final doc in filteredDocuments) {
      final source = doc.sourceType ?? 'Unknown';
      counts[source] = (counts[source] ?? 0) + 1;
    }

    return counts;
  }

  Map<String, double> getAverageAmountByDocumentType() {
    final Map<String, List<double>> amountsByType = {};

    for (final doc in filteredDocuments) {
      final type = doc.documentType ?? 'Unknown';
      final amount = doc.documentAmount ?? 0;
      amountsByType.putIfAbsent(type, () => []).add(amount);
    }

    final averages = <String, double>{};
    for (final entry in amountsByType.entries) {
      final total = entry.value.fold(0.0, (sum, amount) => sum + amount);
      averages[entry.key] = total / entry.value.length;
    }

    return averages;
  }

  // Top customers by revenue
  Map<int, double> getTopCustomersByRevenue({int limit = 10}) {
    final customerRevenue = <int, double>{};

    for (final doc in filteredDocuments) {
      final customerId = doc.customerId ?? 0;
      final amount = doc.documentAmount ?? 0;
      customerRevenue.update(
        customerId,
        (value) => value + amount,
        ifAbsent: () => amount,
      );
    }

    // Sort by revenue descending and limit results
    final sortedEntries = customerRevenue.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries.take(limit));
  }

  Future<dynamic> submitPayment(Payment payment, int? sourceDocumentId) async {
    final Map<String, dynamic> financeData = {
      'payment': payment.toJson(),
    };

    return await submitFinancialDocument(financeData);
  }

  Future<dynamic> submitDeposit(Deposit deposit, int? sourceDocumentId) async {
    final Map<String, dynamic> financeData = {
      'deposit': deposit.toJson(),
    };

    return await submitFinancialDocument(financeData);
  }

  Future<dynamic> submitAdditionalFee(
      AdditionalFee fee, int? sourceDocumentId) async {
    final Map<String, dynamic> financeData = {
      'type': 'additional_fee',
      'data': fee.toJson(),
      'source_document_id': sourceDocumentId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    return await submitFinancialDocument(financeData);
  }

// // Helper method to format financial data
//   Map<String, dynamic> createFinancialRequest({
//     required String type,
//     required Map<String, dynamic> data,
//     int? sourceDocumentId,
//     String? notes,
//   }) {
//     return {
//       'type': type,
//       'data': data,
//       'source_document_id': sourceDocumentId,
//       'notes': notes,
//       'timestamp': DateTime.now().toIso8601String(),
//       'user_id': 0, // You might want to get this from auth
//       'device_info': {
//         'platform': 'flutter',
//         'timestamp': DateTime.now().toIso8601String(),
//       },
//     };
//   }

  Future<FinancialDocument?> submitFinancialDocument(
      dynamic financeData) async {
    _setLoading(true);
    // _clearError();

    try {
      final data = await _invoiceService.addFinancialDocument(financeData);
      if (data != null) {
        // _orders[data.idPlacedOrder ?? 0] = data;
        notifyListeners();
        return data;
      }
      return data;
    } catch (e, stackTrace) {
      debugPrint('Submission error: $e\n$stackTrace');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Daily revenue trend (last 30 days)
  Map<DateTime, double> getDailyRevenueTrend({int days = 30}) {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days - 1));

    final dailyRevenue = <DateTime, double>{};

    // Initialize all days with 0
    for (var i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));
      final dateOnly = DateTime(date.year, date.month, date.day);
      dailyRevenue[dateOnly] = 0.0;
    }

    // Add revenue from documents
    for (final doc in filteredDocuments) {
      if (doc.issueDate != null &&
          !doc.issueDate!.isBefore(startDate) &&
          !doc.issueDate!.isAfter(endDate)) {
        final dateOnly = DateTime(
            doc.issueDate!.year, doc.issueDate!.month, doc.issueDate!.day);
        final amount = doc.documentAmount ?? 0;
        dailyRevenue.update(
          dateOnly,
          (value) => value + amount,
          ifAbsent: () => amount,
        );
      }
    }

    return dailyRevenue;
  }

  // Export analytics data
  Future<Map<String, dynamic>> exportAnalyticsData(
      {String format = 'json'}) async {
    final data = {
      'export_date': DateTime.now().toIso8601String(),
      'period': {
        'start_date': filter.startDate?.toIso8601String(),
        'end_date': filter.endDate?.toIso8601String(),
      },
      'summary': {
        'total_revenue': _totalRevenue,
        'total_collected': _totalCollected,
        'total_outstanding': _totalOutstanding,
        'collection_rate': collectionRate,
        'total_transactions': _totalTransactions,
        'average_transaction_value':
            _totalTransactions > 0 ? _totalRevenue / _totalTransactions : 0,
      },
      'breakdown': {
        'revenue_by_source': _revenueBySource,
        'collections_by_status': _collectionsByStatus,
        'revenue_by_document_type': _revenueByDocumentType,
        'transaction_count_by_source': getTransactionCountBySource(),
        'average_amount_by_document_type': getAverageAmountByDocumentType(),
      },
      'top_customers': getTopCustomersByRevenue(limit: 5),
      'daily_trend': getDailyRevenueTrend(days: 30),
    };

    // Format-specific processing could go here
    if (format == 'csv') {
      // Convert to CSV format
    } else if (format == 'pdf') {
      // Prepare for PDF generation
    }

    return data;
  }

  // Get related documents for a primary document
  // List<FinancialDocument>? getRelatedDocuments(int primaryDocumentId) {
  //   final relatedIds = _documentGroups[primaryDocumentId];
  //   if (relatedIds == null) return null;

  //   return _allDocuments
  //       .where((doc) => relatedIds.contains(doc.documentId))
  //       .toList();
  // }

  // Check if a document is a primary (grouped) document
  bool isPrimaryDocument(FinancialDocument doc) {
    return _documentGroups.containsKey(doc.documentId);
  }

  // ============ GROUPING LOGIC ============

  void _groupDocuments() {
    _groupedDocuments.clear();
    _documentGroups.clear();

    // First, create a map to track documents by source_id
    final sourceIdToDocuments = <int, List<FinancialDocument>>{};

    for (final doc in _allDocuments) {
      final sourceId = doc.sourceId ?? 0;
      if (sourceId == 0) continue; // Skip documents without source_id

      sourceIdToDocuments.putIfAbsent(sourceId, () => []);
      sourceIdToDocuments[sourceId]!.add(doc);
    }

    // debugPrint('\n=== DOCUMENTS BY SOURCE_ID ===');
    // for (final entry in sourceIdToDocuments.entries) {
    //   debugPrint('Source ID ${entry.key}: ${entry.value.length} documents');
    //   for (final doc in entry.value) {
    //     debugPrint(
    //         '  - ${doc.documentType} ${doc.documentId}: \$${doc.documentAmount?.toStringAsFixed(2)} (${doc.paymentStatus})');
    //   }
    // }

    // Process each source_id group
    for (final entry in sourceIdToDocuments.entries) {
      final documents = entry.value;
      if (documents.isEmpty) continue;

      // Sort by document strength: invoice > cart_with_payments > receipt > deposit
      documents.sort((a, b) {
        final order = {
          'invoice': 1,
          'cart_with_payments': 2,
          'cart_with_receipt': 2,
          'receipt': 3,
          'deposit': 4,
          'pending_cart': 5,
        };
        final aOrder = order[a.documentType?.toLowerCase() ?? ''] ?? 99;
        final bOrder = order[b.documentType?.toLowerCase() ?? ''] ?? 99;
        return aOrder.compareTo(bOrder);
      });

      // The first document is the strongest (primary)
      final primaryDoc = documents.first;

      // debugPrint('\nProcessing source_id ${entry.key}:');
      // debugPrint(
      //     '  Primary: ${primaryDoc.documentType} ${primaryDoc.documentId}');

      // Add to grouped documents list
      _groupedDocuments.add(primaryDoc);

      // Store mapping of related documents (excluding the primary)
      final relatedIds = documents
          .where((d) => d.documentId != primaryDoc.documentId)
          .map((d) => d.documentId ?? 0)
          .where((id) => id > 0)
          .toList();

      if (relatedIds.isNotEmpty) {
        _documentGroups[primaryDoc.documentId ?? 0] = relatedIds;
        // debugPrint('  Related document IDs: $relatedIds');
      }

      // Update primary document with aggregated information
      _updatePrimaryDocumentWithAggregatedInfo(primaryDoc, documents);
    }

    // Sort grouped documents by date (newest first)
    _groupedDocuments.sort((a, b) {
      final dateA = a.issueDate ?? DateTime(1970);
      final dateB = b.issueDate ?? DateTime(1970);
      return dateB.compareTo(dateA);
    });

    // debugPrint('\n=== FINAL GROUPING SUMMARY ===');
    // debugPrint(
    //     'Grouped ${_allDocuments.length} documents into ${_groupedDocuments.length} primary documents');

    // for (final doc in _groupedDocuments) {
    //   debugPrint('Primary: ${doc.documentType} ${doc.documentId}: '
    //       '\$${doc.documentAmount?.toStringAsFixed(2)} '
    //       '(${doc.paymentStatus})');

    //   final related = getRelatedDocuments(doc.documentId ?? 0);
    //   if (related != null && related.isNotEmpty) {
    //     debugPrint('  Has ${related.length} related documents');
    //     for (final relatedDoc in related) {
    //       debugPrint(
    //           '    - ${relatedDoc.documentType} ${relatedDoc.documentId}: '
    //           '\$${relatedDoc.documentAmount?.toStringAsFixed(2)}');
    //     }
    //   }
    // }

    _clearFilterCache();
    notifyListeners();
  }

  void _updatePrimaryDocumentWithAggregatedInfo(
      FinancialDocument primaryDoc, List<FinancialDocument> group) {
    if (group.length <= 1) {
      // debugPrint('  Single document group, no aggregation needed');
      return;
    }

    // debugPrint(
    //     '\n=== AGGREGATING GROUP (Source ID: ${primaryDoc.sourceId}) ===');
    // debugPrint('Primary: ${primaryDoc.documentType} ${primaryDoc.documentId}');
    // debugPrint('Group size: ${group.length} documents');

    // Track the highest amount from cart/invoice documents
    double maxCartInvoiceAmount = 0.0;
    FinancialDocument? maxAmountDoc;

    // Track payments and deposits
    double totalPaid = 0.0;
    double totalDeposited = 0.0;

    // Track which amounts we've already counted
    final Set<String> countedPaymentIds = {};
    final Set<String> countedDepositIds = {};

    // First pass: Find the main cart/invoice document and its amounts
    for (final doc in group) {
      final docType = doc.documentType?.toLowerCase() ?? '';

      if (docType.contains('cart') || docType == 'invoice') {
        final docAmount = doc.documentAmount ?? 0.0;
        if (docAmount > maxCartInvoiceAmount) {
          maxCartInvoiceAmount = docAmount;
          maxAmountDoc = doc;
        }

        // Add payments and deposits from cart/invoice document
        totalPaid += doc.totalPaid ?? 0.0;
        totalDeposited += doc.totalDeposited ?? 0.0;

        // debugPrint('  ${doc.documentType} ${doc.documentId}: '
        //     'Amount=\$${docAmount.toStringAsFixed(2)}, '
        //     'PaidInDoc=\$${(doc.totalPaid ?? 0).toStringAsFixed(2)}, '
        //     'DepositedInDoc=\$${(doc.totalDeposited ?? 0).toStringAsFixed(2)}');
      }
    }

    // Second pass: Add receipts and deposits, but avoid double-counting
    for (final doc in group) {
      final docType = doc.documentType?.toLowerCase() ?? '';
      final docId = '${doc.documentType}_${doc.documentId}';

      if (docType == 'receipt') {
        // Check if this receipt amount is already counted in the cart's totalPaid
        final receiptAmount = doc.documentAmount ?? 0.0;
        final isAlreadyCounted = countedPaymentIds.contains(docId) ||
            (maxAmountDoc?.totalPaid ?? 0) >= receiptAmount;

        if (!isAlreadyCounted) {
          totalPaid += receiptAmount;
          countedPaymentIds.add(docId);
          // debugPrint('  ${doc.documentType} ${doc.documentId}: '
          //     'Adds \$${receiptAmount.toStringAsFixed(2)} to paid '
          //     '(not already counted)');
        } else {
          // debugPrint('  ${doc.documentType} ${doc.documentId}: '
          //     'SKIPPED - already counted in cart total');
        }
      } else if (docType == 'deposit') {
        // Check if this deposit amount is already counted in the cart's totalDeposited
        final depositAmount = doc.documentAmount ?? 0.0;
        final isAlreadyCounted = countedDepositIds.contains(docId) ||
            (maxAmountDoc?.totalDeposited ?? 0) >= depositAmount;

        if (!isAlreadyCounted) {
          totalDeposited += depositAmount;
          countedDepositIds.add(docId);
          // debugPrint('  ${doc.documentType} ${doc.documentId}: '
          //     'Adds \$${depositAmount.toStringAsFixed(2)} to deposited '
          //     '(not already counted)');
        } else {
          // debugPrint('  ${doc.documentType} ${doc.documentId}: '
          //     'SKIPPED - already counted in cart total');
        }
      }
    }

    // Calculate outstanding balance
    double outstandingBalance =
        maxCartInvoiceAmount - totalPaid - totalDeposited;
    outstandingBalance = outstandingBalance.clamp(0.0, maxCartInvoiceAmount);

    // Determine combined payment status
    final combinedStatus = _determineCombinedPaymentStatus(
        group, maxCartInvoiceAmount, totalPaid, totalDeposited);

    // debugPrint('\n=== GROUP SUMMARY ===');
    // debugPrint(
    //     'Max Cart/Invoice Amount: \$${maxCartInvoiceAmount.toStringAsFixed(2)}');
    // debugPrint('Total Paid: \$${totalPaid.toStringAsFixed(2)}');
    // debugPrint('Total Deposited: \$${totalDeposited.toStringAsFixed(2)}');
    // debugPrint(
    //     'Total Payments: \$${(totalPaid + totalDeposited).toStringAsFixed(2)}');
    // debugPrint(
    //     'Outstanding Balance: \$${outstandingBalance.toStringAsFixed(2)}');
    // debugPrint('Payment Status: $combinedStatus');

    // Update the primary document
    final index = _groupedDocuments.indexOf(primaryDoc);
    if (index != -1) {
      final updatedDoc = FinancialDocument(
        documentType: primaryDoc.documentType,
        documentId: primaryDoc.documentId,
        documentNumber: primaryDoc.documentNumber,
        sourceId: primaryDoc.sourceId,
        sourceType: primaryDoc.sourceType,
        supplierId: primaryDoc.supplierId,
        customerId: primaryDoc.customerId,
        customerType: primaryDoc.customerType,
        customerPersonId: primaryDoc.customerPersonId,
        sellerId: primaryDoc.sellerId,

        // Use aggregated financial data
        documentAmount: maxCartInvoiceAmount,
        issueDate: primaryDoc.issueDate,
        dueDate: primaryDoc.dueDate,
        totalPaid: totalPaid,
        totalDeposited: totalDeposited,
        additionalFees: 0.0,
        outstandingBalance: outstandingBalance,

        // Combined status
        documentStatus: primaryDoc.documentStatus,
        paymentStatus: combinedStatus,

        daysIssued: primaryDoc.daysIssued,
        createdAt: primaryDoc.createdAt,
        updatedAt: primaryDoc.updatedAt,
      );

      _groupedDocuments[index] = updatedDoc;

      // Also update in _allDocuments for consistency
      final allIndex = _allDocuments.indexWhere(
        (d) => d.documentId == primaryDoc.documentId,
      );
      if (allIndex != -1) {
        _allDocuments[allIndex] = updatedDoc;
      }

      // debugPrint('  Updated primary document ${primaryDoc.documentId}');
    }
  }

  String _determineCombinedPaymentStatus(List<FinancialDocument> group,
      double baseAmount, double totalPaid, double totalDeposited) {
    final totalPayments = totalPaid + totalDeposited;

    // debugPrint('\n=== STATUS CALCULATION ===');
    // debugPrint('Base Amount: \$${baseAmount.toStringAsFixed(2)}');
    // debugPrint('Total Paid: \$${totalPaid.toStringAsFixed(2)}');
    // debugPrint('Total Deposited: \$${totalDeposited.toStringAsFixed(2)}');
    // debugPrint('Total Payments: \$${totalPayments.toStringAsFixed(2)}');

    if (baseAmount == 0) {
      return 'unknown';
    }

    // Fully paid
    if (totalPayments >= baseAmount) {
      return 'paid';
    }

    // Check document types for more specific status
    final hasDepositDoc =
        group.any((d) => d.documentType?.toLowerCase() == 'deposit');
    final hasReceiptDoc =
        group.any((d) => d.documentType?.toLowerCase() == 'receipt');
    final hasPartialStatus = group.any((d) =>
        d.paymentStatus?.toLowerCase().contains('partial') == true ||
        d.paymentStatus?.toLowerCase().contains('deposit') == true);

    // Partially paid with deposits only
    if (hasDepositDoc && !hasReceiptDoc && totalDeposited > 0) {
      return 'deposited';
    }

    // Partially paid with receipts only
    if (!hasDepositDoc && hasReceiptDoc && totalPaid > 0) {
      return 'partially_paid';
    }

    // Mixed or general partial payment
    if (totalPayments > 0) {
      return 'partially_paid';
    }

    // Check for pending status
    final hasPending = group.any((d) =>
        d.paymentStatus?.toLowerCase().contains('pending') == true ||
        d.documentStatus?.toLowerCase().contains('pending') == true);

    if (hasPending) {
      return 'pending';
    }

    return 'unpaid';
  }

// Also fix the getRelatedDocuments method to avoid duplicates
  List<FinancialDocument>? getRelatedDocuments(int primaryDocumentId) {
    final relatedIds = _documentGroups[primaryDocumentId];
    if (relatedIds == null) return null;

    // Use a Set to avoid duplicates
    final Set<int> uniqueIds = Set.from(relatedIds);

    return _allDocuments
        .where((doc) =>
            uniqueIds.contains(doc.documentId) &&
            doc.documentId != primaryDocumentId) // Exclude primary
        .toList();
  }
  // ============ FILTER MANAGEMENT ============

  void setFilter(FinanceDocumentFilter newFilter) {
    _filter = newFilter;
    _clearFilterCache();
    notifyListeners();
  }

  void clearFilter() {
    _filter = const FinanceDocumentFilter();
    _clearFilterCache();
    notifyListeners();
  }

  void updateFilterWithId({
    int? supplierId,
    int? personId,
    int? clientId,
    int? sellerId,
    int? cartId,
    int? orderId,
    int? depositId,
    int? invoiceId,
  }) {
    _filter = _filter.copyWith(
      supplierId: supplierId,
      personId: personId,
      clientId: clientId,
      sellerId: sellerId,
      cartId: cartId,
      orderId: orderId,
      depositId: depositId,
      invoiceId: invoiceId,
    );
    _clearFilterCache();
    notifyListeners();
  }

  void _clearFilterCache() {
    _filterCache.clear();
  }

  List<FinancialDocument> _applyFilters() {
    final cacheKey = _filter.toCacheKey();
    if (_filterCache.containsKey(cacheKey)) {
      return _filterCache[cacheKey]!;
    }

    final filtered = _groupedDocuments.where((doc) {
      // ... existing filter logic (same as before) ...
      // Filter by document type
      if (_filter.documentType != null &&
          _filter.documentType!.isNotEmpty &&
          doc.documentType != _filter.documentType) {
        return false;
      }

      // Filter by status
      if (_filter.status != null && _filter.status!.isNotEmpty) {
        switch (_filter.status!.toLowerCase()) {
          case 'paid':
            if (!doc.isPaid) return false;
            break;
          case 'unpaid':
            if (doc.isPaid || !doc.isUnpaid) return false;
            break;
          case 'overdue':
            if (!doc.isOverdue) return false;
            break;
          case 'partially_paid':
            final isPartiallyPaid =
                doc.paymentStatus.toLowerCase().contains('partially_paid') ==
                        true ||
                    doc.paymentStatus.toLowerCase().contains('partial') == true;
            if (!isPartiallyPaid) return false;
            break;
          default:
            if (doc.paymentStatus != _filter.status) return false;
        }
      }

      // Filter by date range
      if (_filter.startDate != null) {
        if (doc.issueDate.isBefore(_filter.startDate!)) {
          return false;
        }
      }

      if (_filter.endDate != null) {
        if (doc.issueDate.isAfter(_filter.endDate!)) {
          return false;
        }
      }

      // Filter by amount range
      if (_filter.minAmount != null &&
          doc.documentAmount < _filter.minAmount!) {
        return false;
      }

      if (_filter.maxAmount != null &&
          doc.documentAmount > _filter.maxAmount!) {
        return false;
      }

      // Filter by entity IDs
      if (_filter.supplierId != null && doc.supplierId != _filter.supplierId) {
        return false;
      }

      if (_filter.clientId != null && doc.customerId != _filter.clientId) {
        return false;
      }

      if (_filter.personId != null &&
          doc.customerPersonId != _filter.personId) {
        return false;
      }

      if (_filter.sellerId != null && doc.sellerId != _filter.sellerId) {
        return false;
      }

      // Filter by search query
      if (_filter.searchQuery != null && _filter.searchQuery!.isNotEmpty) {
        final query = _filter.searchQuery!.toLowerCase();
        final matches =
            doc.documentNumber?.toLowerCase().contains(query) == true ||
                (doc.documentNumber != null &&
                    doc.documentNumber!.toLowerCase().contains(query));

        if (!matches) {
          return false;
        }
      }

      // Filter by payment status (isPaid)
      if (_filter.isPaid != null) {
        if (_filter.isPaid! != doc.isPaid) {
          return false;
        }
      }

      return true;
    }).toList();

    _filterCache[cacheKey] = filtered;
    return filtered;
  }

  // ============ DOCUMENT MANAGEMENT ============

  void _handleError(String message, Object error, StackTrace stackTrace) {
    log('$message: $error', error: error, stackTrace: stackTrace);
  }

  void _addDocuments(List<FinancialDocument> newDocuments) {
    final existingIds =
        _allDocuments.map((d) => d.documentId).whereType<int>().toSet();

    for (final document in newDocuments) {
      if (document.documentId != null &&
          !existingIds.contains(document.documentId)) {
        _allDocuments.add(document);
      }
    }

    _clearFilterCache();
    notifyListeners();
  }

  // Clear cache should clear both lists
  void clearCache() {
    _allDocuments.clear();
    _groupedDocuments.clear();
    _documentGroups.clear();
    _detailedCache.clear();
    _searchResults.clear();
    _filterCache.clear();
    _documentsPage = 0;
    _hasMoreDocuments = true;
    _currentSearchQuery = null;
    _isSearching = false;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  double _downloadProgress = 0;
  double get downloadProgress => _downloadProgress;
  bool _isDownloading = false;
  bool get isDownloading => _isDownloading;

  Future<void> downloadDocumentWithProgress({
    required FinancialDocument document,
    required BuildContext context,
    String? format,
    Function(double)? onProgress,
  }) async {
    try {
      _isDownloading = true;
      _downloadProgress = 0;
      notifyListeners();

      // Simulate progress updates (replace with actual progress callbacks)
      for (int i = 0; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        _downloadProgress = i / 10;
        onProgress?.call(_downloadProgress);
        notifyListeners();
      }

      // Actual download logic...
      // await downloadDocument(document: document, context: context, format: format);
    } finally {
      _isDownloading = false;
      _downloadProgress = 0;
      notifyListeners();
    }
  }
}

// ============ DATA CLASSES ============

@immutable
class FinanceDocumentFilter {
  final String? documentType;
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minAmount;
  final double? maxAmount;
  final int? supplierId;
  final int? personId;
  final int? clientId;
  final int? sellerId;
  final int? cartId;
  final int? orderId;
  final int? depositId;
  final int? invoiceId;
  final String? searchQuery;
  final bool? hasAttachments;
  final bool? isPaid;

  const FinanceDocumentFilter({
    this.documentType,
    this.status,
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
    this.supplierId,
    this.personId,
    this.clientId,
    this.sellerId,
    this.cartId,
    this.orderId,
    this.depositId,
    this.invoiceId,
    this.searchQuery,
    this.hasAttachments,
    this.isPaid,
  });

  FinanceDocumentFilter copyWith({
    String? documentType,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    int? supplierId,
    int? personId,
    int? clientId,
    int? sellerId,
    int? cartId,
    int? orderId,
    int? depositId,
    int? invoiceId,
    String? searchQuery,
    bool? hasAttachments,
    bool? isPaid,
  }) {
    return FinanceDocumentFilter(
      documentType: documentType ?? this.documentType,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      supplierId: supplierId ?? this.supplierId,
      personId: personId ?? this.personId,
      clientId: clientId ?? this.clientId,
      sellerId: sellerId ?? this.sellerId,
      cartId: cartId ?? this.cartId,
      orderId: orderId ?? this.orderId,
      depositId: depositId ?? this.depositId,
      invoiceId: invoiceId ?? this.invoiceId,
      searchQuery: searchQuery ?? this.searchQuery,
      hasAttachments: hasAttachments ?? this.hasAttachments,
      isPaid: isPaid ?? this.isPaid,
    );
  }

  String toCacheKey() {
    return [
      documentType,
      status,
      startDate?.toIso8601String(),
      endDate?.toIso8601String(),
      minAmount,
      maxAmount,
      supplierId,
      personId,
      clientId,
      sellerId,
      cartId,
      orderId,
      depositId,
      invoiceId,
      searchQuery,
      hasAttachments,
      isPaid,
    ].map((v) => v?.toString() ?? '').join('|');
  }

  bool get isEmpty =>
      documentType == null &&
      status == null &&
      startDate == null &&
      endDate == null &&
      minAmount == null &&
      maxAmount == null &&
      supplierId == null &&
      personId == null &&
      clientId == null &&
      sellerId == null &&
      cartId == null &&
      orderId == null &&
      depositId == null &&
      invoiceId == null &&
      searchQuery == null &&
      hasAttachments == null &&
      isPaid == null;
}

// Extension for sorting
extension ListExtensions<T> on List<T> {
  List<T> sortedBy(Comparable Function(T) selector) {
    return [...this]..sort((a, b) => selector(a).compareTo(selector(b)));
  }
}

// Extension for FinancialDocument model
// In your finance_change_notifier.dart or a separate extensions file
extension FinancialDocumentExtensions on FinancialDocument {
  bool get isPaid {
    final status = paymentStatus?.toLowerCase() ?? '';
    return status.contains('paid') ||
        status.contains('fully_paid') ||
        status.contains('deposit_fully_covered');
  }

  bool get isUnpaid {
    return !isPaid && paymentStatus?.toLowerCase().contains('unpaid') == true;
  }

  bool get isOverdue {
    if (dueDate == null) return false;
    if (isPaid) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  int get daysOverdue {
    if (!isOverdue || dueDate == null) return 0;
    return DateTime.now().difference(dueDate!).inDays;
  }

  double get remainingAmount {
    return documentAmount - (totalPaid + totalDeposited);
  }

  double get paymentPercentage {
    if (documentAmount == 0) return 0;
    return ((totalPaid + totalDeposited) / documentAmount * 100).clamp(0, 100);
  }
}

class FinanceChangeNotifierProvider extends InheritedWidget {
  final FinanceChangeNotifier financeChangeNotifier;

  const FinanceChangeNotifierProvider({
    super.key,
    required super.child,
    required this.financeChangeNotifier,
  });

  static FinanceChangeNotifierProvider? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<FinanceChangeNotifierProvider>();
  }

  @override
  bool updateShouldNotify(FinanceChangeNotifierProvider oldWidget) {
    return financeChangeNotifier != oldWidget.financeChangeNotifier;
  }
}

class AnalyticsCache {
  final double totalRevenue;
  final double totalCollected;
  final double totalOutstanding;
  final int transactionCount;
  final Map<String, double> revenueBySource;
  final Map<String, double> collectionsByStatus;
  final Map<String, double> revenueByDocumentType;
  final double collectionRate;

  AnalyticsCache({
    required this.totalRevenue,
    required this.totalCollected,
    required this.totalOutstanding,
    required this.transactionCount,
    required this.revenueBySource,
    required this.collectionsByStatus,
    required this.collectionRate,
    this.revenueByDocumentType = const {},
  });
}
