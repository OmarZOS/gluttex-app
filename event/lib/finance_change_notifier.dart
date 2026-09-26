// finance_change_notifier.dart
import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/finance/BusinessOperation.dart';
import 'package:gluttex_core/business/finance/FinancialDocument.dart';
import 'package:gluttex_core/business/finance/services/InvoiceService.dart';
import 'package:gluttex_core/business/services/BusinessOperationService.dart';
import 'package:event/views/finance_view_model.dart';
import 'package:event/views/pricing_config_view_model.dart';
import 'package:locator/locator.dart';

// ==================== DEBUG LOGGER ====================

void _log(String tag, String message, {Object? error, StackTrace? stack}) {
  // if (!kDebugMode) return;
  final ts = DateTime.now().toIso8601String().substring(11, 23);
  if (error != null) {
    debugPrint('[$ts][FinanceNotifier][$tag] $message\n  error: $error');
    if (stack != null) debugPrint('  stack: $stack');
  } else {
    debugPrint('[$ts][FinanceNotifier][$tag] $message');
  }
}

class FinanceChangeNotifier extends ChangeNotifier {
  // ==================== DEPENDENCIES ====================

  final InvoiceService _invoiceService = AppLocator.get<InvoiceService>();

  // ==================== DELEGATES ====================

  /// Business operations, tabs, date filters, analytics.
  late final FinanceViewModel _operations;

  /// Pricing configuration form state.
  PricingConfigViewModel get pricingConfigViewModel =>
      _operations.pricingConfigViewModel;

  // ==================== DOCUMENT STATE ====================

  /// The provider whose documents this notifier is scoped to.
  int _providerId = 0;
  int get providerId => _providerId;
  bool get hasProvider => _providerId > 0;

  // All documents (raw) for the current provider.
  final List<FinancialDocument> _allDocuments = [];

  // Grouped documents for UI display.
  final List<FinancialDocument> _groupedDocuments = [];

  // Document groups mapping (primary id -> related ids).
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

  // Analytics over documents
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

  // ==================== CONSTRUCTOR ====================

  FinanceChangeNotifier() {
    _operations = FinanceViewModel(
      businessOperationService: AppLocator.get<BusinessOperationService>(),
    );
    _operations.addListener(_onOperationsChanged);
    _log('init', 'FinanceChangeNotifier created');
  }

  void _onOperationsChanged() {
    // Forward the operations view model's notifications through this
    // notifier so a single listener sees both document and operation
    // updates.
    notifyListeners();
  }

  @override
  void dispose() {
    _operations.removeListener(_onOperationsChanged);
    _operations.dispose();
    super.dispose();
  }

  // ==================== DOCUMENT GETTERS ====================

  List<FinancialDocument> get filteredDocuments => _applyFilters();
  List<FinancialDocument> get documents => List.unmodifiable(_groupedDocuments);
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get hasMoreDocuments => _hasMoreDocuments;
  FinanceDocumentFilter get filter => _filter;
  String? get currentSearchQuery => _currentSearchQuery;
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
  double get downloadProgress => _downloadProgress;
  bool get isDownloading => _isDownloading;

  double get totalAmount {
    return filteredDocuments.fold(
        0.0, (sum, doc) => sum + (doc.documentAmount ?? 0));
  }

  // ==================== DELEGATE GETTERS (operations / filters / tabs) ====================

  FinanceTab get selectedTab => _operations.selectedTab;
  void selectTab(FinanceTab tab) => _operations.selectTab(tab);

  DateFilter get dateFilter => _operations.dateFilter;
  DateTimeRange? get dateRangeFilter => _operations.dateRangeFilter;
  void selectDateFilter(DateFilter filter) =>
      _operations.selectDateFilter(filter);
  void setDateRangeFilter(DateTimeRange? range) =>
      _operations.setDateRangeFilter(range);

  BusinessFilter get businessFilter => _operations.businessFilter;
  void setBusinessFilter(BusinessFilter filter) =>
      _operations.setBusinessFilter(filter);
  void clearBusinessFilter() => _operations.clearBusinessFilter();

  List<BusinessOperation> get businessOperations =>
      _operations.businessOperations;
  List<BusinessOperation> get filteredOperations =>
      _operations.filteredOperations;
  List<BusinessSummary> get businessSummaries => _operations.businessSummaries;
  bool get hasBusinessOperations => _operations.hasBusinessOperations;
  bool get hasBusinessSummaries => _operations.hasBusinessSummaries;
  List<BusinessSummary> get topSuppliers => _operations.topSuppliers;
  List<BusinessOperation> get recentOperations => _operations.recentOperations;
  bool get isLoadingMore => _operations.isLoadingMore;
  bool get hasMore => _operations.hasMore;

  Future<void> loadBusinessOperations({bool forceRefresh = false}) =>
      _operations.loadBusinessOperations(forceRefresh: forceRefresh);
  Future<void> loadMoreBusinessOperations() =>
      _operations.loadMoreBusinessOperations();
  Future<void> refreshBusinessOperations() =>
      _operations.refreshBusinessOperations();

  List<BusinessOperation> getOperationsBySupplier(int supplierId) =>
      _operations.getOperationsBySupplier(supplierId);
  BusinessSummary? getSummaryBySupplier(int supplierId) =>
      _operations.getSummaryBySupplier(supplierId);

  // Pricing actions — delegate to the view model.
  void handleBasePriceChanged(double price) =>
      _operations.handleBasePriceChanged(price);
  void handleTaxPercentageChanged(double tax) =>
      _operations.handleTaxPercentageChanged(tax);
  void handleProfitMarginChanged(double profit) =>
      _operations.handleProfitMarginChanged(profit);
  void handleFinalPriceChanged(double price) =>
      _operations.handleFinalPriceChanged(price);
  void handleModeChanged(PricingMode mode) =>
      _operations.handleModeChanged(mode);
  void handleToggleProductSelection(Product product) =>
      _operations.handleToggleProductSelection(product);
  void handleToggleSelectAll() => _operations.handleToggleSelectAll();
  void handleClearSelection() => _operations.handleClearSelection();
  Future<void> savePricingConfig() => _operations.savePricingConfig();
  Future<void> handleUpdateSelectedProducts() =>
      _operations.handleUpdateSelectedProducts();

  // ==================== PROVIDER SCOPE ====================

  Future<void> setProvider(int newProviderId) async {
    if (newProviderId == _providerId) {
      _log('setProvider', 'no-op (already on provider $_providerId)');
      return;
    }
    if (newProviderId < 0) {
      _log('setProvider', 'rejected (negative id $newProviderId)');
      return;
    }

    _log('setProvider',
        'switching $_providerId → $newProviderId (clearing state)');

    _providerId = newProviderId;

    // Clear document state.
    _allDocuments.clear();
    _groupedDocuments.clear();
    _documentGroups.clear();
    _filterCache.clear();
    _currentPage = 0;
    _hasMoreDocuments = true;
    _resetAnalytics();

    // Notify the operations delegate and clear its state too.
    await _operations.setProvider(newProviderId);

    notifyListeners();

    if (_providerId > 0) {
      _log('setProvider', 'fetching documents for provider $_providerId');
      await _fetchDocuments(reset: true);
    } else {
      _log('setProvider', 'no provider (0) — skipping fetch');
    }
  }

  // ==================== CORE METHODS ====================

  Future<void> refreshAll({FinanceDocumentFilter? filter}) async {
    if (_isRefreshing) {
      _log('refreshAll', 'skipped (already refreshing)');
      return;
    }

    _log(
        'refreshAll',
        'starting (${filter != null ? "with new filter" : "keeping filter"}, '
            'provider=$_providerId)');

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
      _log('refreshAll', 'done');
    }
  }

  Future<void> fetchDocuments({
    bool reset = false,
    int personId = 0,
    int clientId = 0,
    int sellerId = 0,
    int cartId = 0,
    int orderId = 0,
    int depositId = 0,
    int invoiceId = 0,
  }) async {
    _log('fetchDocuments',
        'reset=$reset CALLER: ${StackTrace.current.toString().split("\n")[1].trim()}');
    await _fetchDocuments(
      reset: reset,
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
    int personId = 0,
    int clientId = 0,
    int sellerId = 0,
    int cartId = 0,
    int orderId = 0,
    int depositId = 0,
    int invoiceId = 0,
  }) async {
    if (_isLoading) {
      _log('_fetchDocuments', 'skipped (already loading)');
      return;
    }
    if (!reset && !_hasMoreDocuments) {
      _log('_fetchDocuments', 'skipped (no more documents)');
      return;
    }
    if (!hasProvider) {
      _log('_fetchDocuments', 'skipped (no provider selected)');
      if (_allDocuments.isNotEmpty || _groupedDocuments.isNotEmpty) {
        _allDocuments.clear();
        _groupedDocuments.clear();
        _documentGroups.clear();
        _filterCache.clear();
        _resetAnalytics();
        notifyListeners();
      }
      return;
    }

    if (reset) {
      _log('_fetchDocuments', 'resetting state before fetch');
      _allDocuments.clear();
      _groupedDocuments.clear();
      _documentGroups.clear();
      _currentPage = 0;
      _hasMoreDocuments = true;
      _filterCache.clear();
      _resetAnalytics();
    }

    _setLoading(true);

    final offset = _currentPage * _pageSize;
    _log('_fetchDocuments',
        'GET provider=$_providerId offset=$offset limit=$_pageSize');

    try {
      final fetched = await _invoiceService.getAllFinanceDocs(
        offset,
        _pageSize,
        supplierId: _providerId,
        personId: personId,
        clientId: clientId,
        sellerId: sellerId,
        cartId: cartId,
        orderId: orderId,
        depositId: depositId,
        invoiceId: invoiceId,
      );

      if (fetched == null) {
        _log('_fetchDocuments', 'response was null');
        _hasMoreDocuments = false;
        return;
      }

      _log('_fetchDocuments',
          'received ${fetched.length} document(s) for provider $_providerId');

      if (fetched.isEmpty) {
        _log('_fetchDocuments', 'empty result → no more documents');
        _hasMoreDocuments = false;
        return;
      }

      // Defensive scope filter — drop anything from another provider.
      final scoped = fetched
          .where((d) => d.supplierId == null || d.supplierId == _providerId)
          .toList();

      if (scoped.length != fetched.length) {
        final sample = fetched.first;
        _log(
            '_fetchDocuments',
            'dropped ${fetched.length - scoped.length} out-of-scope. '
                'Sample: docId=${sample.documentId} '
                'supplierId=${sample.supplierId} '
                'type=${sample.documentType} '
                'sourceId=${sample.sourceId}');
      }

      _addDocuments(scoped);
      _groupDocuments();

      if (fetched.length < _pageSize) {
        _hasMoreDocuments = false;
        _log(
            '_fetchDocuments',
            'partial page → no more documents '
                '(server sent ${fetched.length}/$_pageSize)');
      } else {
        _currentPage++;
        _log('_fetchDocuments',
            'advanced to page $_currentPage (server sent $_pageSize)');
      }

      _calculateAnalytics();
      _log(
          '_fetchDocuments',
          'done: allDocs=${_allDocuments.length} '
              'grouped=${_groupedDocuments.length} '
              'transactions=$_totalTransactions '
              'revenue=${_totalRevenue.toStringAsFixed(2)}');
    } catch (e, stackTrace) {
      _log('_fetchDocuments', 'FAILED', error: e, stack: stackTrace);
    } finally {
      _setLoading(false);
    }
  }

  // ==================== FILTER MANAGEMENT ====================

  void setFilter(FinanceDocumentFilter newFilter) {
    _log(
        'setFilter',
        'applying filter (docType=${newFilter.documentType}, '
            'status=${newFilter.status}, supplier=${newFilter.supplierId}, '
            'search="${newFilter.searchQuery ?? ""}")');
    _filter = newFilter;
    _filterCache.clear();
    notifyListeners();
  }

  void clearFilter() {
    _log('clearFilter', 'clearing all filter fields');
    _filter = const FinanceDocumentFilter();
    _filterCache.clear();
    notifyListeners();
  }

  void setSearchQuery(String? query) {
    _log('setSearchQuery', 'query="${query ?? ""}"');
    _currentSearchQuery = query;
    _filter = _filter.copyWith(searchQuery: query);
    _filterCache.clear();
    notifyListeners();
  }

  void clearSearch() {
    _log('clearSearch', 'clearing search query');
    _currentSearchQuery = null;
    _filter = _filter.copyWith(searchQuery: null);
    _filterCache.clear();
    notifyListeners();
  }

  // ==================== DOCUMENT OPERATIONS ====================

  Future<FinancialDocument?> submitFinancialDocument(
      dynamic financeData) async {
    _log('submitFinancialDocument', 'submitting');
    _setLoading(true);
    try {
      final data = await _invoiceService.addFinancialDocument(financeData);
      if (data != null) {
        _log('submitFinancialDocument',
            'succeeded (docId=${data.documentId}), refreshing');
        await refreshAll();
        return data;
      }
      _log('submitFinancialDocument', 'service returned null');
      return null;
    } catch (e, stack) {
      _log('submitFinancialDocument', 'FAILED', error: e, stack: stack);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<PaymentSubmitResult> submitPayment({
    required int invoiceId,
    required double amount,
    required String method,
    String status = "pending",
    String? notes,
  }) async {
    _log('submitPayment',
        'invoice=$invoiceId amount=$amount method=$method status=$status');

    if (invoiceId <= 0) {
      _log('submitPayment', 'REJECTED: no invoice linked');
      return const PaymentSubmitResult.failure(
          'No invoice linked to this document.');
    }
    if (amount <= 0) {
      _log('submitPayment', 'REJECTED: amount <= 0');
      return const PaymentSubmitResult.failure(
          'Payment amount must be greater than zero.');
    }
    if (method.trim().isEmpty) {
      _log('submitPayment', 'REJECTED: empty method');
      return const PaymentSubmitResult.failure('Payment method is required.');
    }

    _setLoading(true);
    try {
      final payment = await _invoiceService.addFinancialDocument({
        "payment_invoice_id": invoiceId,
        "payment_amount": amount,
        "payment_method": method,
        "payment_status": status,
        "payment_notes": notes ?? '',
      });

      if (payment == null) {
        _log('submitPayment', 'service returned null');
        return const PaymentSubmitResult.failure('Payment was not recorded.');
      }

      _log('submitPayment',
          'recorded (docId=${payment.documentId}), refreshing');
      await refreshAll();

      return PaymentSubmitResult.success(
        'Payment recorded.',
        paymentId: payment.documentId,
      );
    } catch (e, stack) {
      _log('submitPayment', 'FAILED', error: e, stack: stack);
      return PaymentSubmitResult.failure('$e');
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
    if (_isDownloading) {
      _log('download', 'skipped (already downloading)');
      return;
    }

    _log('download', 'starting (docId=${document.documentId} format=$format)');

    _isDownloading = true;
    _downloadProgress = 0.0;
    notifyListeners();

    try {
      for (int i = 0; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        _downloadProgress = i / 10;
        onProgress?.call(_downloadProgress);
        notifyListeners();
      }
      _log('download', 'done (simulated)');
    } finally {
      _isDownloading = false;
      _downloadProgress = 0.0;
      notifyListeners();
    }
  }

  // ==================== ANALYTICS OVER DOCUMENTS ====================

  Future<void> refreshAnalytics() async {
    if (_isCalculatingAnalytics) {
      _log('refreshAnalytics', 'skipped (already calculating)');
      return;
    }
    if (_groupedDocuments.isEmpty) {
      _log('refreshAnalytics', 'skipped (no documents)');
      return;
    }

    _log('refreshAnalytics',
        'recalculating over ${_groupedDocuments.length} docs');

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
      _log('_calculateAnalytics', 'no documents → reset');
      _resetAnalytics();
      return;
    }

    _totalRevenue = 0.0;
    _totalCollected = 0.0;
    _totalOutstanding = 0.0;
    _totalTransactions = 0;
    _revenueBySource = {};
    _collectionsByStatus = {};
    _revenueByDocumentType = {};

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

    _log(
        '_calculateAnalytics',
        'revenue=${_totalRevenue.toStringAsFixed(2)} '
            'collected=${_totalCollected.toStringAsFixed(2)} '
            'outstanding=${_totalOutstanding.toStringAsFixed(2)} '
            'txn=$_totalTransactions '
            'rate=${collectionRate.toStringAsFixed(1)}%');
  }

  void _resetAnalytics() {
    _log('_resetAnalytics', 'zeroing analytics');
    _totalRevenue = 0.0;
    _totalCollected = 0.0;
    _totalOutstanding = 0.0;
    _totalTransactions = 0;
    _revenueBySource = {};
    _collectionsByStatus = {};
    _revenueByDocumentType = {};
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

    int added = 0;
    int skipped = 0;
    for (final document in newDocuments) {
      if (document.documentId != null &&
          !existingIds.contains(document.documentId)) {
        _allDocuments.add(document);
        added++;
      } else {
        skipped++;
      }
    }

    _log('_addDocuments',
        'added=$added skipped=$skipped total=${_allDocuments.length}');

    _filterCache.clear();
    notifyListeners();
  }

  void _groupDocuments() {
    _groupedDocuments.clear();
    _documentGroups.clear();

    final sourceIdToDocuments = <int, List<FinancialDocument>>{};

    for (final doc in _allDocuments) {
      final sourceId = doc.sourceId ?? 0;
      if (sourceId == 0) {
        _log('_groupDocuments',
            'skipping docId=${doc.documentId} (no sourceId)');
        continue;
      }
      sourceIdToDocuments.putIfAbsent(sourceId, () => []);
      sourceIdToDocuments[sourceId]!.add(doc);
    }

    _log(
        '_groupDocuments',
        'grouping ${_allDocuments.length} docs into '
            '${sourceIdToDocuments.length} source group(s)');

    for (final entry in sourceIdToDocuments.entries) {
      final documents = entry.value;
      if (documents.isEmpty) continue;

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

      if (documents.length > 1) {
        _log(
            '_groupDocuments',
            'sourceId=${entry.key}: primary=${primaryDoc.documentId} '
                '(${primaryDoc.documentType}) + ${relatedIds.length} related');
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

      _log(
          '_updatePrimaryDocument',
          'docId=${primaryDoc.documentId} '
              'amount=${maxCartInvoiceAmount.toStringAsFixed(2)} '
              'paid=${totalPaid.toStringAsFixed(2)} '
              'deposited=${totalDeposited.toStringAsFixed(2)} '
              'outstanding=${outstandingBalance.toStringAsFixed(2)} '
              'status=$combinedStatus');
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
    final cacheKey = '$_providerId|${_filter.toCacheKey()}';
    final cached = _filterCache[cacheKey];
    if (cached != null) return cached;

    final filtered = _groupedDocuments.where((doc) {
      // Provider scope
      if (hasProvider &&
          doc.supplierId != null &&
          doc.supplierId != _providerId) {
        return false;
      }

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
            if (!doc.paymentStatus.toLowerCase().contains('partial')) {
              return false;
            }
            break;
          default:
            if (doc.paymentStatus != _filter.status) return false;
        }
      }

      // Date range
      if (_filter.startDate != null &&
          doc.issueDate.isBefore(_filter.startDate!)) {
        return false;
      }
      if (_filter.endDate != null && doc.issueDate.isAfter(_filter.endDate!)) {
        return false;
      }

      // Amount range
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

      // Search
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

    _log(
        '_applyFilters',
        'cache miss → filtered ${_groupedDocuments.length} → '
            '${filtered.length} key=${_shortKey(cacheKey)}');

    return filtered;
  }

  void _setLoading(bool loading) {
    _log('_setLoading', 'isLoading=$loading');
    _isLoading = loading;
    notifyListeners();
  }

  void clearCache() {
    _log('clearCache', 'clearing all state (provider stays $_providerId)');
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

  // ==================== DEBUG HELPERS ====================

  /// Dump the full notifier state to the console. Call when debugging.
  void dumpState() {
    _log('dumpState', '───── FinanceChangeNotifier state ─────');
    _log(
        'dumpState',
        'provider=$_providerId '
            'loading=$_isLoading refreshing=$_isRefreshing');
    _log(
        'dumpState',
        'docs: all=${_allDocuments.length} '
            'grouped=${_groupedDocuments.length} '
            'groups=${_documentGroups.length}');
    _log('dumpState',
        'pagination: page=$_currentPage hasMore=$_hasMoreDocuments');
    _log('dumpState', 'filter: ${_filter.toCacheKey()}');
    _log('dumpState', 'cache entries=${_filterCache.length}');
    _log(
        'dumpState',
        'analytics: txn=$_totalTransactions '
            'revenue=${_totalRevenue.toStringAsFixed(2)} '
            'collected=${_totalCollected.toStringAsFixed(2)} '
            'outstanding=${_totalOutstanding.toStringAsFixed(2)}');
    _log('dumpState', '──────────────────────────────────────');
  }

  String _shortKey(String key) {
    if (key.length <= 24) return key;
    return '${key.substring(0, 12)}…${key.substring(key.length - 8)}';
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

// ==================== PAYMENT RESULT ====================

@immutable
class PaymentSubmitResult {
  final bool isSuccess;
  final String message;
  final int? paymentId;

  const PaymentSubmitResult._({
    required this.isSuccess,
    required this.message,
    this.paymentId,
  });

  const PaymentSubmitResult.success(String message, {int? paymentId})
      : this._(isSuccess: true, message: message, paymentId: paymentId);

  const PaymentSubmitResult.failure(String message)
      : this._(isSuccess: false, message: message);
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
