import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/finance/BusinessOperation.dart';
import 'package:gluttex_core/business/finance/Order.dart';
import 'package:gluttex_core/business/services/BusinessOperationService.dart';
import 'package:gluttex_event/views/pricing_config_view_model.dart';

enum FinanceTab {
  invoices(0, 'Invoices'),
  businessOperations(1, 'Business Operations'),
  // analytics(2, 'Analytics'),
  pricingConfig(2, 'Pricing Config');

  final String title;
  const FinanceTab(index, this.title);
}

class FinanceViewModel extends ChangeNotifier {
  final BusinessOperationService businessOperationService;

  FinanceViewModel({required this.businessOperationService});

  // Navigation
  FinanceTab _selectedTab = FinanceTab.invoices;
  BusinessFilter _businessFilter = const BusinessFilter();

  // Pagination state
  int _currentPage = 0; // Changed from 1 to 0 (0-based indexing)
  static const int _pageSize = 20;
  bool _hasMore = true;

  // Data
  final List<BusinessOperation> _businessOperations = [];
  final List<Order> _orders = [];
  final List<BusinessSummary> _businessSummaries = [];

  // Loading states (simplified)
  bool _isLoading = false;
  bool _isLoadingMore = false;

  // View Models
  final PricingConfigViewModel _pricingConfigViewModel =
      PricingConfigViewModel();

  // Analytics cache
  AnalyticsCache? _analyticsCache;

  // Navigation state
  String _dateFilter = 'today';
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
  String get dateFilter => _dateFilter;
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
      _businessOperations.take(10).toList();

  // Navigation
  void selectTab(FinanceTab tab) {
    if (_selectedTab != tab) {
      _selectedTab = tab;
      notifyListeners();

      // Load initial data for tab
      if (tab == FinanceTab.businessOperations) {
        if (_businessOperations.isEmpty) {
          loadBusinessOperations();
        } else {
          // Apply current filters to existing data
          _applyFilters();
        }
      }
    }
  }

  // In FinanceViewModel class, update the _applyDateFilter method:
  void _applyDateFilter(String filterType) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate =
        DateTime(now.year, now.month, now.day, 23, 59, 59); // End of day

    switch (filterType) {
      case 'today':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'week':
        startDate = now.subtract(const Duration(days: 7));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'quarter':
        final month = now.month;
        final quarterStartMonth = ((month - 1) ~/ 3) * 3 + 1;
        startDate = DateTime(now.year, quarterStartMonth, 1);
        break;
      case 'year':
        startDate = DateTime(now.year, 1, 1);
        break;
      case 'all':
      default:
        _dateRangeFilter = null;
        _applyFilters();
        return;
    }

    _dateRangeFilter = DateTimeRange(start: startDate, end: endDate);
    _applyFilters();
  }

// Also update the _applyFilters method to properly handle date ranges:
  void _applyFilters() {
    if (_businessOperations.isEmpty) return;

    List<BusinessOperation> filtered = _businessOperations;

    // Apply business filter
    filtered = _businessFilter.applyFilter(filtered);

    // Apply date range filter
    if (_dateRangeFilter != null) {
      filtered = filtered.where((op) {
        if (op.operationDate == null) return false;
        final operationDate = op.operationDate!;

        // Important: Include operations on the start date (>= start) and before or on end date (<= end)
        return !operationDate.isBefore(_dateRangeFilter!.start) &&
            !operationDate.isAfter(_dateRangeFilter!.end);
      }).toList();
    }

    _filteredOperations = filtered;
    _calculateAnalytics();
    notifyListeners();
  }

  void setBusinessFilter(BusinessFilter filter) {
    _businessFilter = filter;
    _resetPagination();
    _applyFilters();
  }

  void setDateRangeFilter(DateTimeRange? range) {
    _dateRangeFilter = range;
    _applyFilters();
    notifyListeners();
  }

  void selectDateFilter(String filterType) {
    _dateFilter = filterType;
    _applyDateFilter(filterType);
    notifyListeners();
  }

  void clearBusinessFilter() {
    _businessFilter = const BusinessFilter();
    _dateRangeFilter = null;
    _dateFilter = 'today';
    _filteredOperations = List.from(_businessOperations);
    _calculateBusinessSummaries();
    _calculateAnalytics();
    notifyListeners();
  }

  // Business Operations with Pagination
  Future<void> loadBusinessOperations({bool forceRefresh = false}) async {
    if (_isLoading) return;

    if (forceRefresh) {
      _resetPagination();
    }

    _isLoading = true;
    notifyListeners();

    try {
      final operations =
          await businessOperationService.getAllBusinessOperations(
        _currentPage,
        _pageSize,
        supplierId: _businessFilter.supplierId ?? 0,
      );

      if (operations != null && operations.isNotEmpty) {
        if (_currentPage == 0) {
          _businessOperations.clear();
        }

        _businessOperations.addAll(operations);
        _hasMore = operations.length >= _pageSize;
        _currentPage++;

        _calculateBusinessSummaries();
        _applyFilters(); // Apply current filters to newly loaded data
      } else {
        _hasMore = false;
      }
    } catch (e) {
      log('Error loading business operations: $e', name: 'FinanceViewModel');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreBusinessOperations() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final operations =
          await businessOperationService.getAllBusinessOperations(
        _currentPage,
        _pageSize,
        supplierId: _businessFilter.supplierId ?? 0,
      );

      if (operations != null && operations.isNotEmpty) {
        _businessOperations.addAll(operations);
        _hasMore = operations.length >= _pageSize;
        _currentPage++;

        _calculateBusinessSummaries();
        _applyFilters(); // Apply current filters to newly loaded data
      } else {
        _hasMore = false;
      }
    } catch (e) {
      log('Error loading more business operations: $e',
          name: 'FinanceViewModel');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> refreshBusinessOperations() async {
    await loadBusinessOperations(forceRefresh: true);
  }

  // Analytics
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

    for (final operation in _filteredOperations) {
      totalRevenue += operation.totalAmount;
      totalCollected += operation.totalPaid;
      totalOutstanding += operation.balanceDue;

      revenueBySource.update(
        operation.sourceTable,
        (value) => value + operation.totalAmount,
        ifAbsent: () => operation.totalAmount,
      );

      collectionsByStatus.update(
        operation.paymentStatus,
        (value) => value + operation.totalPaid,
        ifAbsent: () => operation.totalPaid,
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

    // Update UI state for backwards compatibility
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
    _revenueBySource.clear();
    _collectionsByStatus.clear();
    _collectionsByMonth.clear();
    _analyticsCache = null;
  }

  // Summaries
  void _calculateBusinessSummaries() {
    final supplierGroups = <int, List<BusinessOperation>>{};

    for (final operation in _businessOperations) {
      if (operation.supplierId != null) {
        supplierGroups.putIfAbsent(operation.supplierId!, () => []);
        supplierGroups[operation.supplierId]!.add(operation);
      }
    }

    _businessSummaries.clear();
    _businessSummaries.addAll(supplierGroups.entries.map((entry) {
      return BusinessSummary.fromOperations(
        entry.key,
        'Supplier ${entry.key}', // TODO: Fetch actual supplier name
        entry.value,
      );
    }));

    _businessSummaries.sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));
  }

  // Filtering

  // Helper Methods
  void _resetPagination() {
    _currentPage = 0;
    _hasMore = true;
    _businessOperations.clear();
    _businessSummaries.clear();
    _filteredOperations.clear();
    _resetAnalytics();
  }

  // Business Operations actions
  List<BusinessOperation> getOperationsBySupplier(int supplierId) {
    return _businessOperations
        .where((op) => op.supplierId == supplierId)
        .toList();
  }

  BusinessSummary? getSummaryBySupplier(int supplierId) {
    try {
      return _businessSummaries
          .firstWhere((summary) => summary.supplierId == supplierId);
    } catch (e) {
      return null;
    }
  }

  // Invoices (placeholder methods)
  Future<void> loadInvoices() async {
    // TODO: Implement invoice loading
    log('loadInvoices called - implement me', name: 'FinanceViewModel');
  }

  Future<void> createInvoice({
    required int clientId,
    List<Product>? products,
  }) async {
    // TODO: Implement invoice creation
    log('createInvoice called - implement me', name: 'FinanceViewModel');
    notifyListeners();
  }

  void viewInvoiceDetails(Order order) {
    log('View invoice details: ${order.idPlacedOrder}',
        name: 'FinanceViewModel');
    // TODO: Navigate to invoice details
  }

  Future<void> shareInvoice(Order order) async {
    log('Share invoice: ${order.idPlacedOrder}', name: 'FinanceViewModel');
    // TODO: Implement share functionality
  }

  Future<void> downloadInvoice(Order order) async {
    log('Download invoice: ${order.idPlacedOrder}', name: 'FinanceViewModel');
    // TODO: Implement download functionality
  }

  void createNewInvoice() {
    log('Create new invoice', name: 'FinanceViewModel');
    // TODO: Navigate to create invoice screen
  }

  // Analytics actions
  Future<void> exportAnalyticsData({String format = 'csv'}) async {
    log('Exporting analytics data in $format format', name: 'FinanceViewModel');

    final exportData = {
      'export_date': DateTime.now().toIso8601String(),
      'total_revenue': _totalRevenue,
      'total_collected': _totalCollected,
      'total_outstanding': _totalOutstanding,
      'collection_rate': collectionRate,
      'total_transactions': _totalTransactions,
      'revenue_by_source': _revenueBySource,
      'collections_by_status': _collectionsByStatus,
    };

    log('Export data: $exportData', name: 'FinanceViewModel');
    // TODO: Implement actual export logic
  }

  // Pricing delegation
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
    // TODO: Save pricing configuration
    notifyListeners();
  }

  Future<void> handleUpdateSelectedProducts() async {
    await savePricingConfig();
  }

  // Initialization
  Future<void> initialize() async {
    await loadBusinessOperations();
  }

  // Refresh all data
  Future<void> refreshAllData() async {
    await loadBusinessOperations(forceRefresh: true);
    // Add other refresh calls as needed
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// Analytics Cache Model
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
