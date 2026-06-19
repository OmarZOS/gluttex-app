import 'package:flutter/material.dart';
import 'package:gluttex_core/business/Delivery.dart';
import 'package:gluttex_core/business/services/DeliveryService.dart';
import 'package:collection/collection.dart';
import 'package:locator/locator.dart';

class DeliveryChangeNotifier with ChangeNotifier {
  final DeliveryService _service = AppLocator.get<DeliveryService>();

  // State
  final List<Delivery> _deliveries = [];
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _lastError;

  // Constants
  static const int _pageSize = 10;

  // ============ PUBLIC GETTERS ============
  List<Delivery> get deliveries => List.unmodifiable(_deliveries);
  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;
  String? get lastError => _lastError;

  // ============ STATUS-BASED ACCESSORS ============
  List<Delivery> get pendingDeliveries {
    return _deliveries
        .where((d) => d.delivery_status?.toUpperCase() == 'PENDING')
        .toList();
  }

  List<Delivery> get deliveredDeliveries {
    return _deliveries
        .where((d) => d.delivery_status?.toUpperCase() == 'DELIVERED')
        .toList();
  }

  Map<String, List<Delivery>> get groupedByStatus {
    return groupBy(_deliveries, (Delivery d) => d.delivery_status ?? 'UNKNOWN');
  }

  // ============ STATE MANAGEMENT ============
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _lastError = error;
    notifyListeners();
  }

  void _clearError() {
    _lastError = null;
    notifyListeners();
  }

  // ============ PAGINATION METHODS ============
  Future<void> fetchFirstPage() async {
    if (_isLoading) return;

    _clearError();
    await _fetchPage(0, reset: true);
  }

  Future<void> fetchNextPage() async {
    if (_isLoading || !_hasMore) return;

    _clearError();
    await _fetchPage(_currentPage * _pageSize);
  }

  Future<void> _fetchPage(int startIndex, {bool reset = false}) async {
    _setLoading(true);

    try {
      final fetchedDeliveries =
          await _service.getAllDeliveries(startIndex, startIndex + _pageSize);

      if (reset) {
        _deliveries.clear();
        _currentPage = 0;
      }

      if (fetchedDeliveries.isEmpty) {
        _hasMore = false;
      } else {
        _deliveries.addAll(fetchedDeliveries);
        _currentPage++;
        _hasMore = fetchedDeliveries.length == _pageSize;
      }
    } catch (e) {
      _setError('Error fetching deliveries: $e');
      debugPrint('Error fetching deliveries: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ============ DELIVERY UPDATE METHODS ============
  Future<void> updateDelivery(Delivery updatedDelivery) async {
    if (_isLoading) return;

    _setLoading(true);
    _clearError();

    try {
      // Call service to update
      final result = await _service.updateDelivery(updatedDelivery);

      // Find and replace in local list
      final index = _deliveries
          .indexWhere((d) => d.id_delivery == updatedDelivery.id_delivery);

      if (index != -1) {
        _deliveries[index] = result ?? updatedDelivery;
        notifyListeners();
      }
    } catch (e) {
      _setError('Error updating delivery: $e');
      debugPrint('Error updating delivery: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ============ UTILITY METHODS ============
  Delivery? getDeliveryById(int id) {
    try {
      return _deliveries.firstWhere((d) => d.id_delivery == id);
    } catch (e) {
      return null;
    }
  }

  List<Delivery> getDeliveriesByStatus(String status) {
    return _deliveries
        .where((d) => d.delivery_status?.toUpperCase() == status.toUpperCase())
        .toList();
  }

  void clearDeliveries() {
    _deliveries.clear();
    _currentPage = 0;
    _hasMore = true;
    _clearError();
    notifyListeners();
  }

  // ============ STATISTICS ============
  int get totalDeliveries => _deliveries.length;

  int get pendingCount => pendingDeliveries.length;

  int get deliveredCount => deliveredDeliveries.length;

  double get totalWeight {
    return _deliveries.fold(0.0, (sum, d) => sum + (d.delivery_total_weight));
  }

  int get totalPackages {
    return _deliveries.fold(0, (sum, d) => sum + (d.delivery_package_count));
  }

  // ============ REFRESH METHODS ============
  Future<void> refreshDeliveries() async {
    await fetchFirstPage();
  }

  Future<void> refreshDelivery(int deliveryId) async {
    await refreshDeliveries();
  }
}
