import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/finance/BusinessOperation.dart';
import 'package:gluttex_core/business/finance/FinancialDocument.dart';
import 'package:gluttex_core/business/finance/Order.dart';
import 'package:gluttex_core/business/services/BusinessOperationService.dart';
import 'package:event/views/pricing_config_view_model.dart';

enum FinanceTab {
  invoices(0, 'Invoices'),
  businessOperations(1, 'Business Operations'),
  pricingConfig(2, 'Pricing Config');

  final int indexs;
  final String title;
  const FinanceTab(this.indexs, this.title);
}

class FinanceViewModel extends ChangeNotifier {
  final BusinessOperationService businessOperationService;

  /// The provider currently being viewed.
  ///
  /// `0` means "no provider selected" — no fetches are made, lists stay
  /// empty, and the UI is expected to show a "select a supplier" state.
  int _providerId;

  FinanceViewModel({
    required this.businessOperationService,
    int providerId = 0,
  }) : _providerId = providerId {
    // Apply the initial date filter so the state (data) matches the UI
    // (the "Today" chip rendered as selected).
    _applyDateFilter(_dateFilter);
  }

  int get providerId => _providerId;

  Future<void> setProvider(int newProviderId) async {
    if (newProviderId == _providerId) return;
    if (newProviderId < 0) return;

    _providerId = newProviderId;
    _resetPagination();
    _resetAnalytics();
    _pricingConfigViewModel.clearSelection();
    notifyListeners();

    if (_providerId > 0) {
      await loadBusinessOperations(forceRefresh: true);
    }
  }

  // Navigation
  FinanceTab _selectedTab = FinanceTab.invoices;
  BusinessFilter _businessFilter = const BusinessFilter();

  // Pagination state
  int _currentPage = 0;
  static const int _pageSize = 20;
  bool _hasMore = true;

  // Data
  final List<BusinessOperation> _businessOperations = [];
  final List<Order> _orders = [];
  final List<BusinessSummary> _businessSummaries = [];

  // Loading states
  bool _isLoading = false;
  bool _isLoadingMore = false;

  // View Models
  final PricingConfigViewModel _pricingConfigViewModel =
      PricingConfigViewModel();

  // Analytics cache
  AnalyticsCache? _analyticsCache;

  // Navigation state
  DateFilter _dateFilter = DateFilter.today;
  DateTimeRange? _dateRangeFilter;

  // Analytics state
  double _totalRevenue = 0.0;
  double _totalCollected = 0.0;
  double _totalOutstanding = 0.0;
  int _totalTransactions = 0;
  Map<String, double> _revenueBySource = {};
  Map<String, double> _collectionsByStatus = {};
  Map<String, double> _collectionsByMonth = {};

  // Cache for filtered operations
  List<BusinessOperation> _filteredOperations = [];

  // Getters
  FinanceTab get selectedTab => _selectedTab;
  BusinessFilter get businessFilter => _businessFilter;
  List<Order> get orders => _orders;
  List<BusinessOperation> get businessOperations => _businessOperations;
  List<BusinessSummary> get businessSummaries => _businessSummaries;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  PricingConfigViewModel get pricingConfigViewModel => _pricingConfigViewModel;
  AnalyticsCache? get analyticsCache => _analyticsCache;
  DateFilter get dateFilter => _dateFilter;
  DateTimeRange? get dateRangeFilter => _dateRangeFilter;
  List<BusinessOperation> get filteredOperations => _filteredOperations;

  // Computed properties
  double get collectionRate =>
      _totalRevenue > 0 ? (_totalCollected / _totalRevenue) * 100 : 0.0;
  bool get canCreateInvoice => _orders.isNotEmpty;
  List<Order> get invoices => _orders;
  bool get hasBusinessOperations => _businessOperations.isNotEmpty;
  bool get hasBusinessSummaries => _businessSummaries.isNotEmpty;
  List<BusinessSummary> get topSuppliers => _businessSummaries.take(5).toList();
  List<BusinessOperation> get recentOperations =>
      _filteredOperations.take(10).toList();

  bool get hasProvider => _providerId > 0;

  // ==================== NAVIGATION ====================

  void selectTab(FinanceTab tab) {
    if (_selectedTab == tab) return;

    _selectedTab = tab;
    notifyListeners();

    if (tab == FinanceTab.businessOperations && hasProvider) {
      if (_businessOperations.isEmpty) {
        loadBusinessOperations();
      } else {
        _applyFilters();
      }
    }
  }

  // ==================== DATE FILTER ====================

  void _applyDateFilter(DateFilter filterType) {
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    DateTime startDate;

    switch (filterType) {
      case DateFilter.today:
        startDate = DateTime(now.year, now.month, now.day);
        break;

      case DateFilter.week:
        // "This week" = since Monday (ISO 8601).
        final weekday = now.weekday; // Monday = 1, Sunday = 7
        startDate = DateTime(
          now.year,
          now.month,
          now.day - (weekday - 1),
        );
        break;

      case DateFilter.month:
        startDate = DateTime(now.year, now.month, 1);
        break;

      case DateFilter.quarter:
        final quarterStartMonth = ((now.month - 1) ~/ 3) * 3 + 1;
        startDate = DateTime(now.year, quarterStartMonth, 1);
        break;

      case DateFilter.year:
        startDate = DateTime(now.year, 1, 1);
        break;

      case DateFilter.all:
        _dateRangeFilter = null;
        _applyFilters();
        return;

      default:
        // Unknown filter → treat as "all". Log so we notice in dev.
        log(
          'FinanceViewModel._applyDateFilter: unknown filter "$filterType"',
          name: 'FinanceViewModel',
        );
        _dateRangeFilter = null;
        _applyFilters();
        return;
    }

    _dateRangeFilter = DateTimeRange(start: startDate, end: endOfDay);
    _applyFilters();
  }

  // ==================== FILTERING ====================

  /// Recompute `_filteredOperations`, `_businessSummaries`, and analytics
  /// from the current filters. Does NOT fetch from the network.
  ///
  /// Callers are responsible for `notifyListeners()` if they want a rebuild.
  void _applyFilters({bool notify = true}) {
    if (_businessOperations.isEmpty) {
      _filteredOperations = [];
      _businessSummaries.clear();
      _resetAnalytics();
      if (notify) notifyListeners();
      return;
    }

    List<BusinessOperation> filtered = _businessOperations;

    // 1. Client-side business filter (status, source, etc.).
    filtered = _businessFilter.applyFilter(filtered);

    // 2. Date range.
    if (_dateRangeFilter != null) {
      final start = _dateRangeFilter!.start;
      final end = _dateRangeFilter!.end;
      filtered = filtered.where((op) {
        final d = op.operationDate;
        if (d == null) return false;
        return !d.isBefore(start) && !d.isAfter(end);
      }).toList();
    }

    _filteredOperations = filtered;

    // Summaries are derived from the *filtered* set so any summary UI
    // matches what the list shows.
    _calculateBusinessSummaries(_filteredOperations);

    _calculateAnalytics();

    if (notify) notifyListeners();
  }

  // ==================== FILTER SETTERS ====================

  /// Apply a business filter and refetch.
  ///
  /// NOTE: If `filter.supplierId` narrows the *fetch* (rather than being a
  /// client-side refinement), it should be passed into
  /// `loadBusinessOperations`. Currently it is treated as a client-side
  /// refinement on top of the provider scope.
  void setBusinessFilter(BusinessFilter filter) {
    _businessFilter = filter;
    _resetPagination();

    if (hasProvider) {
      // `forceRefresh: true` already resets pagination internally, so
      // we don't need to reset it above — but doing both is harmless.
      loadBusinessOperations(forceRefresh: true);
    } else {
      _applyFilters();
    }
  }

  void setDateRangeFilter(DateTimeRange? range) {
    _dateRangeFilter = range;
    _applyFilters();
  }

  void selectDateFilter(DateFilter filterType) {
    _dateFilter = DateFilter.values.firstWhere((f) => f.name == filterType);
    _applyDateFilter(_dateFilter);
    // _applyDateFilter → _applyFilters → notifyListeners (once).
  }

  void clearBusinessFilter() {
    _businessFilter = const BusinessFilter();
    _dateRangeFilter = null;
    _dateFilter = DateFilter.today;

    if (hasProvider) {
      loadBusinessOperations(forceRefresh: true);
    } else {
      _applyFilters();
    }
  }

  // ==================== FETCHING ====================

  Future<void> loadBusinessOperations({bool forceRefresh = false}) async {
    if (!hasProvider) {
      log(
        'FinanceViewModel.loadBusinessOperations: skipped (no provider)',
        name: 'FinanceViewModel',
      );
      return;
    }
    if (_isLoading) return;

    if (forceRefresh) {
      _resetPagination();
    }

    _isLoading = true;
    notifyListeners();

    try {
      log(
        'FinanceViewModel.loadBusinessOperations: '
        'providerId=$_providerId page=$_currentPage pageSize=$_pageSize',
        name: 'FinanceViewModel',
      );

      final operations =
          await businessOperationService.getAllBusinessOperations(
        _currentPage,
        _pageSize,
        supplierId: _providerId,
      );

      if (operations != null && operations.isNotEmpty) {
        if (_currentPage == 0) {
          _businessOperations.clear();
        }

        _businessOperations.addAll(operations);
        _hasMore = operations.length >= _pageSize;
        _currentPage++;

        // _applyFilters recomputes summaries + analytics; pass notify:false
        // because the `finally` block will fire notifyListeners once.
        _applyFilters(notify: false);
      } else {
        _hasMore = false;
        // Even with no new data, recompute from whatever we have.
        _applyFilters(notify: false);
      }
    } catch (e, st) {
      log(
        'Error loading business operations: $e',
        name: 'FinanceViewModel',
        error: e,
        stackTrace: st,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreBusinessOperations() async {
    if (!hasProvider) return;
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final operations =
          await businessOperationService.getAllBusinessOperations(
        _currentPage,
        _pageSize,
        supplierId: _providerId,
      );

      if (operations != null && operations.isNotEmpty) {
        _businessOperations.addAll(operations);
        _hasMore = operations.length >= _pageSize;
        _currentPage++;
        _applyFilters(notify: false);
      } else {
        _hasMore = false;
      }
    } catch (e, st) {
      log(
        'Error loading more business operations: $e',
        name: 'FinanceViewModel',
        error: e,
        stackTrace: st,
      );
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> refreshBusinessOperations() async {
    await loadBusinessOperations(forceRefresh: true);
  }

  // ==================== ANALYTICS ====================

  void _calculateAnalytics() {
    if (_filteredOperations.isEmpty) {
      _resetAnalytics();
      return;
    }

    double totalRevenue = 0.0;
    double totalCollected = 0.0;
    double totalOutstanding = 0.0;
    final revenueBySource = <String, double>{};
    final collectionsByStatus = <String, double>{};

    for (final op in _filteredOperations) {
      totalRevenue += op.totalAmount;
      totalCollected += op.totalPaid;
      totalOutstanding += op.balanceDue;

      revenueBySource.update(
        op.sourceTable,
        (v) => v + op.totalAmount,
        ifAbsent: () => op.totalAmount,
      );
      collectionsByStatus.update(
        op.paymentStatus,
        (v) => v + op.totalPaid,
        ifAbsent: () => op.totalPaid,
      );
    }

    _analyticsCache = AnalyticsCache(
      totalRevenue: totalRevenue,
      totalCollected: totalCollected,
      totalOutstanding: totalOutstanding,
      transactionCount: _filteredOperations.length,
      revenueBySource: revenueBySource,
      collectionsByStatus: collectionsByStatus,
      collectionRate:
          totalRevenue > 0 ? (totalCollected / totalRevenue) * 100 : 0.0,
    );

    _totalRevenue = totalRevenue;
    _totalCollected = totalCollected;
    _totalOutstanding = totalOutstanding;
    _totalTransactions = _filteredOperations.length;
    _revenueBySource = revenueBySource;
    _collectionsByStatus = collectionsByStatus;
  }

  void _resetAnalytics() {
    _totalRevenue = 0.0;
    _totalCollected = 0.0;
    _totalOutstanding = 0.0;
    _totalTransactions = 0;
    _revenueBySource = {};
    _collectionsByStatus = {};
    _collectionsByMonth = {};
    _analyticsCache = null;
  }

  // ==================== SUMMARIES ====================

  /// Group a list of operations by supplier into summaries.
  void _calculateBusinessSummaries(List<BusinessOperation> source) {
    if (source.isEmpty) {
      _businessSummaries.clear();
      return;
    }

    final groups = <int, List<BusinessOperation>>{};
    for (final op in source) {
      final sid = op.supplierId;
      if (sid == null || sid <= 0) continue;
      groups.putIfAbsent(sid, () => []).add(op);
    }

    _businessSummaries
      ..clear()
      ..addAll(groups.entries.map(
        (e) => BusinessSummary.fromOperations(
          e.key,
          'Supplier ${e.key}',
          e.value,
        ),
      ));

    _businessSummaries.sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));
  }

  // ==================== RESET ====================

  void _resetPagination() {
    _currentPage = 0;
    _hasMore = true;
    _businessOperations.clear();
    _businessSummaries.clear();
    _filteredOperations.clear();
    _resetAnalytics();
  }

  // ==================== LOOKUPS ====================

  List<BusinessOperation> getOperationsBySupplier(int supplierId) {
    return _businessOperations
        .where((op) => op.supplierId == supplierId)
        .toList();
  }

  BusinessSummary? getSummaryBySupplier(int supplierId) {
    for (final s in _businessSummaries) {
      if (s.supplierId == supplierId) return s;
    }
    return null;
  }

  // ==================== INVOICES (placeholders) ====================

  Future<void> loadInvoices() async {
    log('loadInvoices called - implement me', name: 'FinanceViewModel');
  }

  Future<void> createInvoice({
    required int clientId,
    List<Product>? products,
  }) async {
    log('createInvoice called - implement me', name: 'FinanceViewModel');
    notifyListeners();
  }

  void viewInvoiceDetails(Order order) {
    log('View invoice details: ${order.idPlacedOrder}',
        name: 'FinanceViewModel');
  }

  Future<void> shareInvoice(Order order) async {
    log('Share invoice: ${order.idPlacedOrder}', name: 'FinanceViewModel');
  }

  Future<void> downloadInvoice(Order order) async {
    log('Download invoice: ${order.idPlacedOrder}', name: 'FinanceViewModel');
  }

  void createNewInvoice() {
    log('Create new invoice', name: 'FinanceViewModel');
  }

  // ==================== EXPORT ====================

  Future<void> exportAnalyticsData({String format = 'csv'}) async {
    log('Exporting analytics data in $format format', name: 'FinanceViewModel');

    final exportData = {
      'export_date': DateTime.now().toIso8601String(),
      'provider_id': _providerId,
      'date_filter': _dateFilter,
      'total_revenue': _totalRevenue,
      'total_collected': _totalCollected,
      'total_outstanding': _totalOutstanding,
      'collection_rate': collectionRate,
      'total_transactions': _totalTransactions,
      'revenue_by_source': _revenueBySource,
      'collections_by_status': _collectionsByStatus,
    };

    log('Export data: $exportData', name: 'FinanceViewModel');
  }

  // ==================== PRICING DELEGATION ====================

  void handleBasePriceChanged(double price) {
    _pricingConfigViewModel.basePrice = price;
    notifyListeners();
  }

  void handleTaxPercentageChanged(double tax) {
    _pricingConfigViewModel.taxPercentage = tax;
    notifyListeners();
  }

  void handleProfitMarginChanged(double profit) {
    _pricingConfigViewModel.profitMargin = profit;
    notifyListeners();
  }

  void handleModeChanged(PricingMode mode) {
    _pricingConfigViewModel.mode = mode;
    notifyListeners();
  }

  void handleFinalPriceChanged(double price) {
    _pricingConfigViewModel.finalPrice = price;
    notifyListeners();
  }

  void handleToggleProductSelection(Product product) {
    _pricingConfigViewModel.toggleProductSelection(product);
    notifyListeners();
  }

  void handleToggleSelectAll() {
    _pricingConfigViewModel.toggleSelectAll();
    notifyListeners();
  }

  void handleClearSelection() {
    _pricingConfigViewModel.clearSelection();
    notifyListeners();
  }

  Future<void> savePricingConfig() async {
    log('savePricingConfig called - implement me', name: 'FinanceViewModel');
    notifyListeners();
  }

  Future<void> handleUpdateSelectedProducts() async {
    await savePricingConfig();
  }

  // ==================== INITIALIZATION ====================

  Future<void> initialize() async {
    if (!hasProvider) return;
    await loadBusinessOperations();
  }

  Future<void> refreshAllData() async {
    if (!hasProvider) return;
    await loadBusinessOperations(forceRefresh: true);
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class AnalyticsCache {
  final double totalRevenue;
  final double totalCollected;
  final double totalOutstanding;
  final int transactionCount;
  final Map<String, double> revenueBySource;
  final Map<String, double> collectionsByStatus;
  final double collectionRate;

  AnalyticsCache({
    required this.totalRevenue,
    required this.totalCollected,
    required this.totalOutstanding,
    required this.transactionCount,
    required this.revenueBySource,
    required this.collectionsByStatus,
    required this.collectionRate,
  });
}
