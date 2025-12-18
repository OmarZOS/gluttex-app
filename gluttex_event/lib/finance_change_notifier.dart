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
  final InvoiceService _invoiceService = GluttexLocator.get<InvoiceService>();
  // State management
  final List<FinancialDocument> _documents = [];
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

  // ============ PUBLIC GETTERS ============

  List<FinancialDocument> get documents => List.unmodifiable(_documents);
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

    final filtered = _documents.where((doc) {
      // Filter by document type
      if (_filter.documentType != null &&
          _filter.documentType!.isNotEmpty &&
          doc.documentType != _filter.documentType) {
        return false;
      }

      // Filter by status - FIXED: Handle multiple status types
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
            final isPartiallyPaid = doc.paymentStatus
                        ?.toLowerCase()
                        .contains('partially_paid') ==
                    true ||
                doc.paymentStatus?.toLowerCase().contains('partial') == true;
            if (!isPartiallyPaid) return false;
            break;
          default:
            // Check exact match
            if (doc.paymentStatus != _filter.status) return false;
        }
      }

      // Filter by date range - FIXED: Use issueDate instead of createdAt
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

      // Filter by entity IDs - FIXED: Handle int comparisons properly
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
                    doc.documentNumber!.toLowerCase().contains(query)) ||
                (doc.customerType != null &&
                    doc.customerType!.toLowerCase().contains(query));

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
    if (_isLoading || (!reset && !_hasMoreDocuments)) return;

    if (reset) {
      _documents.clear();
      _documentsPage = 0;
      _hasMoreDocuments = true;
      _clearFilterCache();
    }

    _setLoading(true);

    try {
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
        _addDocuments(fetched);

        if (fetched.length < _itemsPerPage) {
          _hasMoreDocuments = false;
        } else {
          _documentsPage++;
        }
      } else {
        _hasMoreDocuments = false;
      }
    } catch (e, stackTrace) {
      _handleError('Failed to fetch financial documents', e, stackTrace);
    } finally {
      _setLoading(false);
    }
  }

  Future<FinancialDocument?> getDocumentById(String id,
      {bool forceRefresh = false}) async {
    // Check cache first
    if (!forceRefresh) {
      final cached = _detailedCache.firstWhere(
        (d) => d.documentId == id,
        // orElse: () => FinancialDocument.empty(),
      );

      if (cached.documentId != null) {
        return cached;
      }
    }

    _setLoading(true);

    try {
      final document = await _invoiceService.getFinancialDocument(id);
      if (document != null) {
        _cacheDocument(document);
        _updateDocumentInList(document);
      }
      return document;
    } catch (e, stackTrace) {
      _handleError('Failed to fetch document $id', e, stackTrace);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<FinancialDocument> createOrUpdateDocument(
      FinancialDocument document) async {
    _setLoading(true);

    try {
      final result = document.documentId == null
          ? await _invoiceService.addFinancialDocument(document)
          : await _invoiceService.updateFinancialDocument(document);

      if (result == null) {
        throw GluttexException('Failed to save financial document');
      }

      _cacheDocument(result);
      _updateDocumentInList(result);
      _clearFilterCache();

      // Refresh list if new document
      if (document.documentId == null) {
        await fetchDocuments(reset: true);
      }

      return result;
    } catch (e, stackTrace) {
      _handleError('Failed to save financial document', e, stackTrace);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteDocument(String id) async {
    _setLoading(true);

    try {
      final status = await _invoiceService.deleteFinancialDocument(id);
      final success = status != null && status > 0;

      if (success) {
        _documents.removeWhere((d) => d.documentId == id);
        _detailedCache.removeWhere((d) => d.documentId == id);
        _searchResults.removeWhere((d) => d.documentId == id);
        _clearFilterCache();
        notifyListeners();
      }

      return success;
    } catch (e, stackTrace) {
      _handleError('Failed to delete document $id', e, stackTrace);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ============ SEARCH FUNCTIONALITY ============

  Future<void> searchDocuments(String query, {bool reset = false}) async {
    if (query.isEmpty) {
      _clearSearch();
      return;
    }

    if (reset) {
      _searchResults.clear();
      _documentsPage = 0;
      _hasMoreDocuments = true;
    }

    _currentSearchQuery = query;
    _setSearching(true);
    _setLoading(true);

    try {
      // First search in cached documents
      final localResults = _documents.where((doc) {
        return doc.documentNumber
                    ?.toLowerCase()
                    .contains(query.toLowerCase()) ==
                true ||
            doc.documentNumber?.toLowerCase().contains(query.toLowerCase()) ==
                true;
        //     ||
        // doc.notes?.toLowerCase().contains(query.toLowerCase()) == true ||
        // doc.idSupplierName?.toLowerCase().contains(query.toLowerCase()) ==
        //     true ||
        // doc.idClientName?.toLowerCase().contains(query.toLowerCase()) ==
        //     true;
      }).toList();

      _searchResults.addAll(localResults);
      notifyListeners();

      // If we need more results, fetch from server
      if (_searchResults.length < _itemsPerPage) {
        // Note: This assumes your service has search capability
        // If not, you might need to implement a search endpoint
        await _performServerSearch(query);
      }
    } catch (e, stackTrace) {
      _handleError('Failed to search documents', e, stackTrace);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _performServerSearch(String query) async {
    try {
      // This is a placeholder - you might need to implement
      // a search method in your InvoiceService
      final results = await fetchDocuments(reset: true);
      // Filter results by query
      final filtered = _documents.where((doc) {
        return doc.documentNumber
                    ?.toLowerCase()
                    .contains(query.toLowerCase()) ==
                true ||
            doc.documentNumber?.toLowerCase().contains(query.toLowerCase()) ==
                true;
      }).toList();

      _searchResults.addAll(filtered);
      notifyListeners();
    } catch (e) {
      _handleError('Server search failed', e, StackTrace.current);
    }
  }

  void _clearSearch() {
    _searchResults.clear();
    _currentSearchQuery = null;
    _isSearching = false;
    notifyListeners();
  }

  // ============ STATISTICS & ANALYTICS ============

  double get totalAmount {
    return filteredDocuments.fold(0.0, (sum, doc) => sum + doc.documentAmount);
  }

  Map<String, double> getAmountByType() {
    final Map<String, double> amounts = {};

    for (final doc in filteredDocuments) {
      final type = doc.documentType ?? 'Unknown';
      amounts[type] = (amounts[type] ?? 0.0) + doc.documentAmount;
    }

    return amounts;
  }

  Map<String, int> getCountByStatus() {
    final Map<String, int> counts = {};

    for (final doc in filteredDocuments) {
      final status = doc.documentStatus ?? 'Unknown';
      counts[status] = (counts[status] ?? 0) + 1;
    }

    return counts;
  }

  List<FinancialDocument> getRecentDocuments({int count = 10}) {
    return filteredDocuments
        .where((doc) => doc.createdAt != null)
        .toList()
        .sortedBy((doc) => doc.createdAt!)
        .reversed
        .take(count)
        .toList();
  }

  List<FinancialDocument> getHighValueDocuments({double threshold = 1000}) {
    return filteredDocuments
        .where((doc) => doc.documentAmount >= threshold)
        .toList()
        .sortedBy((doc) => doc.documentAmount)
        .reversed
        .toList();
  }

  // ============ HELPER METHODS ============

  void _addDocuments(List<FinancialDocument> newDocuments) {
    final existingIds =
        _documents.map((d) => d.documentId).whereType<String>().toSet();

    for (final document in newDocuments) {
      if (document.documentId != null &&
          !existingIds.contains(document.documentId)) {
        _documents.add(document);
      }
    }

    _clearFilterCache();
    notifyListeners();
  }

  void _cacheDocument(FinancialDocument document) {
    if (document.documentId == null) return;

    final index = _detailedCache.indexWhere(
      (d) => d.documentId == document.documentId,
    );

    if (index != -1) {
      _detailedCache[index] = document;
    } else {
      _detailedCache.add(document);
    }
  }

  void _updateDocumentInList(FinancialDocument document) {
    if (document.documentId == null) return;

    final index = _documents.indexWhere(
      (d) => d.documentId == document.documentId,
    );

    if (index != -1) {
      _documents[index] = document;
    }

    _clearFilterCache();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setSearching(bool searching) {
    _isSearching = searching;
    notifyListeners();
  }

  void _handleError(String message, Object error, StackTrace stackTrace) {
    log('$message: $error', error: error, stackTrace: stackTrace);
    // You could add error state handling here
  }

  // ============ BATCH OPERATIONS ============

  Future<void> refreshAll({FinanceDocumentFilter? filter}) async {
    if (filter != null) {
      setFilter(filter);
    }

    await fetchDocuments(reset: true);
  }

  Future<void> prefetchDocumentDetails(List<String> documentIds) async {
    final missingIds = documentIds
        .where(
          (id) => !_detailedCache.any((d) => d.documentId == id),
        )
        .toList();

    if (missingIds.isEmpty) return;

    await Future.wait(
      missingIds.map((id) => getDocumentById(id)),
    );
  }

  Future<void> exportFilteredDocuments() async {
    final filtered = filteredDocuments;
    // Implement export logic here
    // Could generate CSV, PDF, or send to printer
  }

  // ============ CACHE MANAGEMENT ============

  void clearCache() {
    _documents.clear();
    _detailedCache.clear();
    _searchResults.clear();
    _filterCache.clear();
    _documentsPage = 0;
    _hasMoreDocuments = true;
    _currentSearchQuery = null;
    _isSearching = false;
    notifyListeners();
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
