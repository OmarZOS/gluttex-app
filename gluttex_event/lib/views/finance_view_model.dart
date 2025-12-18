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
  int _currentPage = 1;
  int _pageSize = 20;
  bool _hasMore = true;

  // Data
  List<BusinessOperation> _businessOperations = [];
  final List<Order> _orders = [];
  List<BusinessSummary> _businessSummaries = [];

  // Loading states
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isCalculatingAnalytics = false;

  // View Models
  final PricingConfigViewModel _pricingConfigViewModel =
      PricingConfigViewModel();

  // Analytics cache
  AnalyticsCache? _analyticsCache;

  // Getters
  FinanceTab get selectedTab => _selectedTab;
  BusinessFilter get businessFilter => _businessFilter;
  List<Order> get orders => _orders;
  List<BusinessOperation> get businessOperations => _businessOperations;
  List<BusinessSummary> get businessSummaries => _businessSummaries;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isCalculatingAnalytics => _isCalculatingAnalytics;
  bool get hasMore => _hasMore;
  PricingConfigViewModel get pricingConfigViewModel => _pricingConfigViewModel;

  AnalyticsCache? get analyticsCache => _analyticsCache;

  // Navigation
  void selectTab(FinanceTab tab) {
    if (_selectedTab != tab) {
      _selectedTab = tab;

      // Load initial data for tab
      if (tab == FinanceTab.businessOperations && _businessOperations.isEmpty) {
        loadBusinessOperations();
      }

      notifyListeners();
    }
  }

  void setBusinessFilter(BusinessFilter filter) {
    _businessFilter = filter;
    _currentPage = 1;
    _hasMore = true;
    _businessOperations.clear();
    loadBusinessOperations();
  }

  // Business Operations with Pagination
  Future<void> loadBusinessOperations() async {
    if (_isLoading) return;

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
        _businessOperations.addAll(operations);
        _hasMore = operations.length >= _pageSize;
        _currentPage++;

        // Calculate summaries
        _calculateBusinessSummaries();
        // Pre-calculate analytics if on analytics tab
        // if (_selectedTab == FinanceTab.analytics) {
        //   log("calculateAnalytics");
        //   await calculateAnalytics();
        //   log("Done");
        // }
      } else {
        _hasMore = false;
      }
    } catch (e) {
      // Handle error appropriately
      debugPrint('Error loading business operations: $e');
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

        // Update summaries with new data
        _calculateBusinessSummaries();
      } else {
        _hasMore = false;
      }
    } catch (e) {
      debugPrint('Error loading more business operations: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> refreshBusinessOperations() async {
    _currentPage = 1;
    _hasMore = true;
    _businessOperations.clear();
    await loadBusinessOperations();
  }

  // Analytics
  Future<void> calculateAnalytics() async {
    if (_businessOperations.isEmpty || _isCalculatingAnalytics) return;

    _isCalculatingAnalytics = true;
    notifyListeners();

    try {
      _analyticsCache = _calculateAnalyticsFromOperations(_businessOperations);
    } finally {
      _isCalculatingAnalytics = false;
      notifyListeners();
    }
  }

  AnalyticsCache _calculateAnalyticsFromOperations(
      List<BusinessOperation> operations) {
    double totalRevenue = 0.0;
    double totalCollected = 0.0;
    double totalOutstanding = 0.0;
    final revenueBySource = <String, double>{};
    final collectionsByStatus = <String, double>{};

    for (final operation in operations) {
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

    return AnalyticsCache(
      totalRevenue: totalRevenue,
      totalCollected: totalCollected,
      totalOutstanding: totalOutstanding,
      transactionCount: operations.length,
      revenueBySource: revenueBySource,
      collectionsByStatus: collectionsByStatus,
      collectionRate:
          totalRevenue > 0 ? (totalCollected / totalRevenue) * 100 : 0.0,
    );
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

    _businessSummaries = supplierGroups.entries.map((entry) {
      return BusinessSummary.fromOperations(
        entry.key,
        'Supplier ${entry.key}', // Replace with actual supplier name from your data
        entry.value,
      );
    }).toList();

    _businessSummaries.sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));
  }

  // Invoices (simplified)
  Future<void> loadInvoices() async {
    // TODO: Implement invoice loading
  }

  Future<void> createInvoice(
      {required int clientId, List<Product>? products}) async {
    // TODO: Implement invoice creation
    notifyListeners();
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

  Future<void> savePricingConfig() async {
    // TODO: Save pricing configuration
    notifyListeners();
  }

  // Initialization
  Future<void> initialize() async {
    // Load initial data based on selected tab
    switch (_selectedTab) {
      case FinanceTab.businessOperations:
        await loadBusinessOperations();
        break;
      // case FinanceTab.analytics:
      //   await loadBusinessOperations(); // Need operations for analytics
      //   await calculateAnalytics();
      //   break;
      case FinanceTab.invoices:
        await loadInvoices();
        break;
      case FinanceTab.pricingConfig:
        // Pricing config loads products on demand
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void selectDateFilter(String filterType) {
    _businessFilter = _businessFilter.copyWith(dateRangeType: filterType);
    // Apply any date range logic based on filterType
    _applyDateFilter(filterType);
    notifyListeners();
  }

  void _applyDateFilter(String filterType) {
    final now = DateTime.now();
    switch (filterType) {
      case 'today':
        // Set startDate and endDate for today
        break;
      case 'week':
        // Set startDate and endDate for this week
        break;
      case 'month':
        // Set startDate and endDate for this month
        break;
      case 'quarter':
        // Set startDate and endDate for this quarter
        break;
      case 'year':
        // Set startDate and endDate for this year
        break;
      case 'all':
        // Clear date filters
        break;
    }
  }

  // Navigation state
  String _dateFilter = 'today';
  DateTimeRange? _dateRangeFilter;

  // Data state

  // Loading states
  bool _isLoadingInvoices = false;
  bool _isLoadingAnalytics = false;
  bool _isLoadingBusinessOperations = false;
  bool _isLoadingPricing = false;

  // View Models
  int? _currentUserId;

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

  String get dateFilter => _dateFilter;
  DateTimeRange? get dateRangeFilter => _dateRangeFilter;
  List<BusinessOperation> get filteredOperations => _filteredOperations;

  bool get isLoadingInvoices => _isLoadingInvoices;
  bool get isLoadingAnalytics => _isLoadingAnalytics;
  bool get isLoadingBusinessOperations => _isLoadingBusinessOperations;
  bool get isLoadingPricing => _isLoadingPricing;

  int? get currentUserId => _currentUserId;

  // Analytics getters
  double get totalRevenue => _totalRevenue;
  double get totalCollected => _totalCollected;
  double get totalOutstanding => _totalOutstanding;
  int get totalTransactions => _totalTransactions;
  Map<String, double> get revenueBySource => _revenueBySource;
  Map<String, double> get collectionsByStatus => _collectionsByStatus;
  Map<String, double> get collectionsByMonth => _collectionsByMonth;

  double get collectionRate =>
      _totalRevenue > 0 ? (_totalCollected / _totalRevenue) * 100 : 0.0;

  // Computed properties
  bool get canCreateInvoice => _orders.isNotEmpty;
  List<Order> get invoices => _orders;
  bool get hasBusinessOperations => _businessOperations.isNotEmpty;
  bool get hasBusinessSummaries => _businessSummaries.isNotEmpty;

  // Top suppliers (top 5 by revenue)
  List<BusinessSummary> get topSuppliers => _businessSummaries.take(5).toList();

  // Recent operations (last 10)
  List<BusinessOperation> get recentOperations =>
      _businessOperations.take(10).toList();

  // Navigation methods

  void setDateRangeFilter(DateTimeRange? range) {
    _dateRangeFilter = range;
    _applyFilters();
    notifyListeners();
  }

  void clearBusinessFilter() {
    _businessFilter = const BusinessFilter();
    _filteredOperations = List.from(_businessOperations);
    _calculateSummariesFromOperations(_filteredOperations);
    _calculateAnalyticsFromOperations(_filteredOperations);
    notifyListeners();
  }

  // Data loading methods
  Future<void> refreshAllData() async {
    await Future.wait([
      refreshInvoices(),
      refreshBusinessOperations(),
      refreshAnalytics(),
    ]);
  }

  Future<void> refreshInvoices() async {
    _isLoadingInvoices = true;
    notifyListeners();

    try {
      await _loadInvoices();
    } finally {
      _isLoadingInvoices = false;
      notifyListeners();
    }
  }

  Future<void> _loadInvoices() async {
    // TODO: Implement API call to fetch orders
    await Future.delayed(const Duration(seconds: 1));
    // Mock data for orders
    // _orders = await _fetchMockOrders();
  }

  Future<void> _loadBusinessOperations() async {
    _isLoadingBusinessOperations = true;
    notifyListeners();

    try {
      // TODO: Implement API call to fetch business operations from all sources
      // await Future.delayed(const Duration(seconds: 1));

      // Mock data for business operations
      _businessOperations =
          (await businessOperationService.getAllBusinessOperations(0, 30))!;
      log("_calculateBusinessSummaries");
      _filteredOperations = List.from(_businessOperations);
      _calculateBusinessSummaries();
      log("_calculateAnalytics");
      _calculateAnalytics();
    } finally {
      _isLoadingBusinessOperations = false;
      notifyListeners();
    }
  }

  Future<void> refreshAnalytics() async {
    _isLoadingAnalytics = true;
    notifyListeners();

    try {
      if (_businessOperations.isEmpty) {
        await _loadBusinessOperations();
      } else {
        _calculateAnalytics();
      }
    } finally {
      _isLoadingAnalytics = false;
      notifyListeners();
    }
  }

  Future<void> _loadPricingProducts() async {
    _isLoadingPricing = true;
    notifyListeners();

    try {
      // TODO: Load products for pricing configuration
      await Future.delayed(const Duration(seconds: 1));
      // final products = await _fetchMockProducts();
      // _pricingConfigViewModel.products = products;
    } finally {
      _isLoadingPricing = false;
      notifyListeners();
    }
  }

  // Filtering and calculation methods
  void _applyFilters() {
    if (_businessOperations.isEmpty) return;

    List<BusinessOperation> filtered = _businessOperations;

    // Apply supplier filter
    if (_businessFilter.supplierId != null) {
      filtered = filtered
          .where((op) => op.supplierId == _businessFilter.supplierId)
          .toList();
    }

    // Apply payment status filter
    if (_businessFilter.paymentStatus != null) {
      filtered = filtered
          .where((op) => op.paymentStatus == _businessFilter.paymentStatus)
          .toList();
    }

    // Apply invoice status filter
    if (_businessFilter.invoiceStatus != null) {
      filtered = filtered
          .where((op) => op.invoiceStatus == _businessFilter.invoiceStatus)
          .toList();
    }

    // Apply source table filter
    if (_businessFilter.sourceTable != null) {
      filtered = filtered
          .where((op) => op.sourceTable == _businessFilter.sourceTable)
          .toList();
    }

    // Apply date range filter if available
    if (_dateRangeFilter != null) {
      // Note: BusinessOperation doesn't have a date field
      // You'll need to add one or fetch date from related tables
    }

    _filteredOperations = filtered;
    _calculateSummariesFromOperations(filtered);
    _calculateAnalyticsFromOperations(filtered);
  }

  void _calculateSummariesFromOperations(List<BusinessOperation> operations) {
    final supplierGroups = <int, List<BusinessOperation>>{};

    for (final operation in operations) {
      if (operation.supplierId != null) {
        supplierGroups.putIfAbsent(operation.supplierId!, () => []);
        supplierGroups[operation.supplierId]!.add(operation);
      }
    }

    _businessSummaries = supplierGroups.entries.map((entry) {
      final supplierId = entry.key;
      final supplierOps = entry.value;
      final supplierName = 'Supplier $supplierId';

      return BusinessSummary.fromOperations(
        supplierId,
        supplierName,
        supplierOps,
      );
    }).toList();

    _businessSummaries.sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));
  }

  void _calculateAnalytics() {
    if (_businessOperations.isEmpty) return;
    _calculateAnalyticsFromOperations(_businessOperations);
  }

  // Business Operations actions
  Future<void> syncBusinessOperations() async {
    _isLoadingBusinessOperations = true;
    notifyListeners();

    try {
      // TODO: Implement sync with all data sources
      await Future.delayed(const Duration(seconds: 2));
      await refreshBusinessOperations();
    } finally {
      _isLoadingBusinessOperations = false;
      notifyListeners();
    }
  }

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

  void viewInvoiceDetails(Order order) {
    // TODO: Navigate to invoice details
    debugPrint('View invoice details: ${order.idOrder}');
  }

  Future<void> shareInvoice(Order order) async {
    // TODO: Implement share functionality
    debugPrint('Share invoice: ${order.idOrder}');
  }

  Future<void> downloadInvoice(Order order) async {
    // TODO: Implement download functionality
    debugPrint('Download invoice: ${order.idOrder}');
  }

  void createNewInvoice() {
    // TODO: Navigate to create invoice screen
    debugPrint('Create new invoice');
  }

  // Analytics actions
  Future<void> exportAnalyticsData({String format = 'csv'}) async {
    debugPrint('Exporting analytics data in $format format');

    final exportData = {
      'export_date': DateTime.now().toIso8601String(),
      'total_revenue': _totalRevenue,
      'total_collected': _totalCollected,
      'total_outstanding': _totalOutstanding,
      'collection_rate': collectionRate,
      'total_transactions': _totalTransactions,
      // 'supplier_summaries': _businessSummaries.map((s) => s.toJson()).toList(),
      'revenue_by_source': _revenueBySource,
      'collections_by_status': _collectionsByStatus,
      'collections_by_month': _collectionsByMonth,
    };

    // TODO: Implement actual export logic
    debugPrint('Export data: $exportData');
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

  void handleUpdateSelectedProducts() async {
    await savePricingConfig();
  }

  void handleClearSelection() {
    _pricingConfigViewModel.clearSelection();
    notifyListeners();
  }

  // Initialization

  // Helper methods for mock data

  Future<void> _updateProductsPricing(List<Product> products) async {
    // TODO: Update product pricing in database
    debugPrint('Updating pricing for ${products.length} products');

    // Update each product with new pricing based on current config
    for (final product in products) {
      // Calculate new price based on current pricing configuration
      final newPrice = _pricingConfigViewModel.finalPrice;
      debugPrint(
          'Updating product ${product.product_name} to price: $newPrice');
    }

    // Refresh products list
    await _loadPricingProducts();
  }

  // Dispose method to clean up resources
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
