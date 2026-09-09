// finance_change_notifier.dart
import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gluttex_core/business/finance/FinancialDocument.dart';
import 'package:gluttex_core/business/finance/services/InvoiceService.dart';
import 'package:locator/locator.dart';

class FinanceChangeNotifier extends ChangeNotifier {
  // ==================== DEPENDENCIES ====================

  final InvoiceService _invoiceService = AppLocator.get<InvoiceService>();

  // ==================== STATE ====================

  // All documents (raw data)
  final List<FinancialDocument> _allDocuments = [];

  // Grouped documents for UI display
  final List<FinancialDocument> _groupedDocuments = [];

  // Document groups mapping
  final Map<int, List<int>> _documentGroups = {};

  // Filter state
  FinanceDocumentFilter _filter = const FinanceDocumentFilter();
  bool _isLoading = false;
  bool _isRefreshing = false;

  // Pagination
  int _currentPage = 0;
  static const int _pageSize = 50;
  bool _hasMoreDocuments = true;

  // Search
  String? _currentSearchQuery;

  // Filter cache
  final Map<String, List<FinancialDocument>> _filterCache = {};

  // Analytics
  bool _isCalculatingAnalytics = false;
  double _totalRevenue = 0.0;
  double _totalCollected = 0.0;
  double _totalOutstanding = 0.0;
  int _totalTransactions = 0;
  Map<String, double> _revenueBySource = {};
  Map<String, double> _collectionsByStatus = {};
  Map<String, double> _revenueByDocumentType = {};
  AnalyticsCache? _analyticsCache;

  // Download state
  double _downloadProgress = 0.0;
  bool _isDownloading = false;

  // ==================== PUBLIC GETTERS ====================

  List<FinancialDocument> get documents => List.unmodifiable(_groupedDocuments);

  List<FinancialDocument> get filteredDocuments => _applyFilters();

  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get hasMoreDocuments => _hasMoreDocuments;
  FinanceDocumentFilter get filter => _filter;
  String? get currentSearchQuery => _currentSearchQuery;

  // Analytics getters
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
  double get collectionRate =>
      _totalRevenue > 0 ? (_totalCollected / _totalRevenue) * 100 : 0.0;

  // Download getters
  double get downloadProgress => _downloadProgress;
  bool get isDownloading => _isDownloading;

  // Total amount for filtered documents
  double get totalAmount {
    return filteredDocuments.fold(
        0.0, (sum, doc) => sum + (doc.documentAmount ?? 0));
  }

  // ==================== CORE METHODS ====================

  /// Refresh all documents (reload from server)
  Future<void> refreshAll({FinanceDocumentFilter? filter}) async {
    if (_isRefreshing) return;

    _isRefreshing = true;
    notifyListeners();

    try {
      if (filter != null) {
        _filter = filter;
      }
      await _fetchDocuments(reset: true);
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Fetch documents with pagination
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
  }) async {
    await _fetchDocuments(
      reset: reset,
      supplierId: supplierId,
      personId: personId,
      clientId: clientId,
      sellerId: sellerId,
      cartId: cartId,
      orderId: orderId,
      depositId: depositId,
      invoiceId: invoiceId,
    );
  }

  Future<void> _fetchDocuments({
    bool reset = false,
    int supplierId = 0,
    int personId = 0,
    int clientId = 0,
    int sellerId = 0,
    int cartId = 0,
    int orderId = 0,
    int depositId = 0,
    int invoiceId = 0,
  }) async {
    if (_isLoading || (!reset && !_hasMoreDocuments)) return;

    if (reset) {
      _allDocuments.clear();
      _groupedDocuments.clear();
      _documentGroups.clear();
      _currentPage = 0;
      _hasMoreDocuments = true;
      _filterCache.clear();
      _resetAnalytics();
    }

    _setLoading(true);

    try {
      final fetched = await _invoiceService.getAllFinanceDocs(
        _currentPage * _pageSize,
        _pageSize,
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
        _addDocuments(fetched);
        _groupDocuments();

        if (fetched.length < _pageSize) {
          _hasMoreDocuments = false;
        } else {
          _currentPage++;
        }

        _calculateAnalytics();
      } else {
        _hasMoreDocuments = false;
      }
    } catch (e, stackTrace) {
      debugPrint('Failed to fetch financial documents: $e');
      debugPrint('Stack trace: $stackTrace');
    } finally {
      _setLoading(false);
    }
  }

  // ==================== FILTER MANAGEMENT ====================

  void setFilter(FinanceDocumentFilter newFilter) {
    _filter = newFilter;
    _filterCache.clear();
    notifyListeners();
  }

  void clearFilter() {
    _filter = const FinanceDocumentFilter();
    _filterCache.clear();
    notifyListeners();
  }

  void setSearchQuery(String? query) {
    _currentSearchQuery = query;
    _filter = _filter.copyWith(searchQuery: query);
    _filterCache.clear();
    notifyListeners();
  }

  void clearSearch() {
    _currentSearchQuery = null;
    _filter = _filter.copyWith(searchQuery: null);
    _filterCache.clear();
    notifyListeners();
  }

  // ==================== DOCUMENT OPERATIONS ====================

  Future<FinancialDocument?> submitFinancialDocument(
      dynamic financeData) async {
    _setLoading(true);
    try {
      final data = await _invoiceService.addFinancialDocument(financeData);
      if (data != null) {
        await refreshAll();
        return data;
      }
      return null;
    } catch (e) {
      debugPrint('Submission error: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> downloadDocumentWithProgress({
    required FinancialDocument document,
    required BuildContext context,
    String? format,
    Function(double)? onProgress,
  }) async {
    if (_isDownloading) return;

    _isDownloading = true;
    _downloadProgress = 0.0;
    notifyListeners();

    try {
      // Simulate progress updates
      for (int i = 0; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        _downloadProgress = i / 10;
        onProgress?.call(_downloadProgress);
        notifyListeners();
      }
      // Actual download logic here
    } finally {
      _isDownloading = false;
      _downloadProgress = 0.0;
      notifyListeners();
    }
  }

  // ==================== ANALYTICS ====================

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

    _totalRevenue = 0.0;
    _totalCollected = 0.0;
    _totalOutstanding = 0.0;
    _totalTransactions = 0;
    _revenueBySource.clear();
    _collectionsByStatus.clear();
    _revenueByDocumentType.clear();

    for (final doc in _groupedDocuments) {
      final amount = doc.documentAmount ?? 0;
      final paid = doc.totalPaid ?? 0;
      final outstanding = doc.outstandingBalance ?? 0;
      final source = doc.sourceType ?? 'unknown';
      final status = doc.paymentStatus ?? 'unknown';
      final docType = doc.documentType ?? 'unknown';

      _totalRevenue += amount;
      _totalCollected += paid;
      _totalOutstanding += outstanding;
      _totalTransactions++;

      _revenueBySource[source] = (_revenueBySource[source] ?? 0) + amount;
      _collectionsByStatus[status] = (_collectionsByStatus[status] ?? 0) + paid;
      _revenueByDocumentType[docType] =
          (_revenueByDocumentType[docType] ?? 0) + amount;
    }

    _analyticsCache = AnalyticsCache(
      totalRevenue: _totalRevenue,
      totalCollected: _totalCollected,
      totalOutstanding: _totalOutstanding,
      transactionCount: _totalTransactions,
      revenueBySource: Map.from(_revenueBySource),
      collectionsByStatus: Map.from(_collectionsByStatus),
      revenueByDocumentType: Map.from(_revenueByDocumentType),
      collectionRate: collectionRate,
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

  // ==================== STATISTICS HELPERS ====================

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

  Map<int, double> getTopCustomersByRevenue({int limit = 10}) {
    final customerRevenue = <int, double>{};
    for (final doc in filteredDocuments) {
      final customerId = doc.customerId ?? 0;
      final amount = doc.documentAmount ?? 0;
      customerRevenue[customerId] = (customerRevenue[customerId] ?? 0) + amount;
    }

    final sortedEntries = customerRevenue.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sortedEntries.take(limit));
  }

  Map<DateTime, double> getDailyRevenueTrend({int days = 30}) {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days - 1));

    final dailyRevenue = <DateTime, double>{};
    for (var i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));
      final dateOnly = DateTime(date.year, date.month, date.day);
      dailyRevenue[dateOnly] = 0.0;
    }

    for (final doc in filteredDocuments) {
      if (doc.issueDate != null &&
          !doc.issueDate!.isBefore(startDate) &&
          !doc.issueDate!.isAfter(endDate)) {
        final dateOnly = DateTime(
          doc.issueDate!.year,
          doc.issueDate!.month,
          doc.issueDate!.day,
        );
        final amount = doc.documentAmount ?? 0;
        dailyRevenue[dateOnly] = (dailyRevenue[dateOnly] ?? 0) + amount;
      }
    }

    return dailyRevenue;
  }

  // ==================== PRIVATE HELPERS ====================

  void _addDocuments(List<FinancialDocument> newDocuments) {
    final existingIds =
        _allDocuments.map((d) => d.documentId).whereType<int>().toSet();

    for (final document in newDocuments) {
      if (document.documentId != null &&
          !existingIds.contains(document.documentId)) {
        _allDocuments.add(document);
      }
    }
    _filterCache.clear();
    notifyListeners();
  }

  void _groupDocuments() {
    _groupedDocuments.clear();
    _documentGroups.clear();

    final sourceIdToDocuments = <int, List<FinancialDocument>>{};

    for (final doc in _allDocuments) {
      final sourceId = doc.sourceId ?? 0;
      if (sourceId == 0) continue;
      sourceIdToDocuments.putIfAbsent(sourceId, () => []);
      sourceIdToDocuments[sourceId]!.add(doc);
    }

    for (final entry in sourceIdToDocuments.entries) {
      final documents = entry.value;
      if (documents.isEmpty) continue;

      // Sort by document strength
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

      final primaryDoc = documents.first;
      _groupedDocuments.add(primaryDoc);

      final relatedIds = documents
          .where((d) => d.documentId != primaryDoc.documentId)
          .map((d) => d.documentId ?? 0)
          .where((id) => id > 0)
          .toList();

      if (relatedIds.isNotEmpty) {
        _documentGroups[primaryDoc.documentId ?? 0] = relatedIds;
      }

      _updatePrimaryDocument(primaryDoc, documents);
    }

    _groupedDocuments.sort((a, b) {
      final dateA = a.issueDate ?? DateTime(1970);
      final dateB = b.issueDate ?? DateTime(1970);
      return dateB.compareTo(dateA);
    });

    _filterCache.clear();
    notifyListeners();
  }

  void _updatePrimaryDocument(
      FinancialDocument primaryDoc, List<FinancialDocument> group) {
    if (group.length <= 1) return;

    double maxCartInvoiceAmount = 0.0;
    double totalPaid = 0.0;
    double totalDeposited = 0.0;
    final Set<String> countedPaymentIds = {};
    final Set<String> countedDepositIds = {};

    // First pass: Find main cart/invoice
    for (final doc in group) {
      final docType = doc.documentType?.toLowerCase() ?? '';
      if (docType.contains('cart') || docType == 'invoice') {
        final docAmount = doc.documentAmount ?? 0.0;
        if (docAmount > maxCartInvoiceAmount) {
          maxCartInvoiceAmount = docAmount;
        }
        totalPaid += doc.totalPaid ?? 0.0;
        totalDeposited += doc.totalDeposited ?? 0.0;
      }
    }

    // Second pass: Add receipts and deposits
    for (final doc in group) {
      final docType = doc.documentType?.toLowerCase() ?? '';
      final docId = '${doc.documentType}_${doc.documentId}';

      if (docType == 'receipt') {
        final receiptAmount = doc.documentAmount ?? 0.0;
        if (!countedPaymentIds.contains(docId)) {
          totalPaid += receiptAmount;
          countedPaymentIds.add(docId);
        }
      } else if (docType == 'deposit') {
        final depositAmount = doc.documentAmount ?? 0.0;
        if (!countedDepositIds.contains(docId)) {
          totalDeposited += depositAmount;
          countedDepositIds.add(docId);
        }
      }
    }

    final outstandingBalance =
        (maxCartInvoiceAmount - totalPaid - totalDeposited)
            .clamp(0.0, maxCartInvoiceAmount);
    final combinedStatus = _determineCombinedStatus(
        group, maxCartInvoiceAmount, totalPaid, totalDeposited);

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
        documentAmount: maxCartInvoiceAmount,
        issueDate: primaryDoc.issueDate,
        dueDate: primaryDoc.dueDate,
        totalPaid: totalPaid,
        totalDeposited: totalDeposited,
        additionalFees: 0.0,
        outstandingBalance: outstandingBalance,
        documentStatus: primaryDoc.documentStatus,
        paymentStatus: combinedStatus,
        daysIssued: primaryDoc.daysIssued,
        createdAt: primaryDoc.createdAt,
        updatedAt: primaryDoc.updatedAt,
      );
      _groupedDocuments[index] = updatedDoc;
    }
  }

  String _determineCombinedStatus(
    List<FinancialDocument> group,
    double baseAmount,
    double totalPaid,
    double totalDeposited,
  ) {
    final totalPayments = totalPaid + totalDeposited;

    if (baseAmount == 0) return 'unknown';
    if (totalPayments >= baseAmount) return 'paid';

    final hasDepositDoc =
        group.any((d) => d.documentType?.toLowerCase() == 'deposit');
    final hasReceiptDoc =
        group.any((d) => d.documentType?.toLowerCase() == 'receipt');

    if (hasDepositDoc && !hasReceiptDoc && totalDeposited > 0) {
      return 'deposited';
    }
    if (!hasDepositDoc && hasReceiptDoc && totalPaid > 0) {
      return 'partially_paid';
    }
    if (totalPayments > 0) return 'partially_paid';

    return 'unpaid';
  }

  List<FinancialDocument> _applyFilters() {
    final cacheKey = _filter.toCacheKey();
    if (_filterCache.containsKey(cacheKey)) {
      return _filterCache[cacheKey]!;
    }

    final filtered = _groupedDocuments.where((doc) {
      // Document type filter
      if (_filter.documentType != null && _filter.documentType!.isNotEmpty) {
        if (doc.documentType != _filter.documentType) return false;
      }

      // Status filter
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
            if (!doc.paymentStatus.toLowerCase().contains('partial'))
              return false;
            break;
          default:
            if (doc.paymentStatus != _filter.status) return false;
        }
      }

      // Date range filter
      if (_filter.startDate != null &&
          doc.issueDate.isBefore(_filter.startDate!)) {
        return false;
      }
      if (_filter.endDate != null && doc.issueDate.isAfter(_filter.endDate!)) {
        return false;
      }

      // Amount range filter
      if (_filter.minAmount != null &&
          doc.documentAmount < _filter.minAmount!) {
        return false;
      }
      if (_filter.maxAmount != null &&
          doc.documentAmount > _filter.maxAmount!) {
        return false;
      }

      // Entity filters
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

      // Search query
      if (_filter.searchQuery != null && _filter.searchQuery!.isNotEmpty) {
        final query = _filter.searchQuery!.toLowerCase();
        final matches =
            doc.documentNumber?.toLowerCase().contains(query) ?? false;
        if (!matches) return false;
      }

      // Paid status
      if (_filter.isPaid != null && _filter.isPaid! != doc.isPaid) {
        return false;
      }

      return true;
    }).toList();

    _filterCache[cacheKey] = filtered;
    return filtered;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearCache() {
    _allDocuments.clear();
    _groupedDocuments.clear();
    _documentGroups.clear();
    _filterCache.clear();
    _currentPage = 0;
    _hasMoreDocuments = true;
    _currentSearchQuery = null;
    _resetAnalytics();
    notifyListeners();
  }

  // ==================== DOCUMENT HELPERS ====================

  bool isPrimaryDocument(FinancialDocument doc) {
    return _documentGroups.containsKey(doc.documentId);
  }

  List<FinancialDocument>? getRelatedDocuments(int primaryDocumentId) {
    final relatedIds = _documentGroups[primaryDocumentId];
    if (relatedIds == null) return null;

    final uniqueIds = Set.from(relatedIds);
    return _allDocuments
        .where((doc) =>
            uniqueIds.contains(doc.documentId) &&
            doc.documentId != primaryDocumentId)
        .toList();
  }
}

// ==================== FILTER CLASS ====================

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
}

// ==================== ANALYTICS CACHE ====================

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

// ==================== EXTENSIONS ====================

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
