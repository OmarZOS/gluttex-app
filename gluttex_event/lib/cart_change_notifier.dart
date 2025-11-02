import 'package:flutter/material.dart';
import 'package:gluttex_core/business/Cart.dart';
import 'package:gluttex_core/business/Order.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/services/OrderService.dart';
import 'package:locator/locator.dart';

class CartChangeNotifier with ChangeNotifier {
  final OrderService _orderService = GluttexLocator.get<OrderService>();
  final Cart _cart = Cart();
  bool _isLoading = false;
  String? _lastError;
  final Map<int, Order> _orders = {}; // Use Map for efficient lookup by ID
  // Public getters
  List<Order> get orders => List.unmodifiable(_orders.values);
  List<CartItem> get cartItems => List.unmodifiable(_cart.items);
  Cart get cart => _cart;

  int get cartItemCount =>
      _cart.items.fold(0, (sum, item) => sum + item.quantity);
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  double get cartTotal => _cart.items.fold(
      0,
      (total, item) =>
          total + (item.product.product_price ?? 0) * item.quantity);

  Future<void> fetchOrders({bool reset = false, required int appUserId}) async {
    if (_isLoading) return;

    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      if (reset) _orders.clear();

      final fetchedOrders = await _orderService.getAllOrders(appUserId);

      if (fetchedOrders.isNotEmpty) {
        for (final order in fetchedOrders) {
          // Preserve existing order details if we have them
          final existingOrder = _orders[order.idOrder];
          if (existingOrder != null && existingOrder.hasItems()) {
            _orders[order.idOrder] = order.copyWith(items: existingOrder.items);
          } else {
            _orders[order.idOrder] = order;
          }
        }
      }
    } catch (e, stackTrace) {
      _lastError = 'Failed to fetch orders: ${e.toString()}';
      debugPrint('Error fetching orders: $e\n$stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrderDetails({required int orderId}) async {
    if (_isLoading) return;

    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final orderDetails = await _orderService.getOrderDetails(orderId);

      if (orderDetails.isNotEmpty) {
        for (final detailedOrder in orderDetails) {
          _orders[detailedOrder.idOrderedItem]?.items = [detailedOrder];
        }
      }
    } catch (e, stackTrace) {
      _lastError = 'Failed to fetch order details: ${e.toString()}';
      debugPrint('Error fetching order details: $e\n$stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshOrderDetails(int orderId) async {
    // Force refresh of order details
    await fetchOrderDetails(orderId: orderId);
  }

  // Get orders by status
  List<Order> getOrdersByStatus(String status) {
    return _orders.values.where((order) => order.status == status).toList();
  }

  // Get order with details if available
  Order? getOrderWithDetails(int orderId) {
    final order = _orders[orderId];
    // Check if order exists AND has items loaded (not null and not empty)
    if (order != null && order.items != null) {
      return order;
    }
    return null;
  }

  Future<OrderResult> submitOrder(Map<String, dynamic> orderData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _orderService.addOrder(orderData);

      if (data != null) {
        _cart.clear();
        await fetchOrders(appUserId: data.idOrder ?? 0);
        return OrderResult.success('Order placed successfully');
      } else {
        return OrderResult.failure('Failed to place order');
      }
    } catch (e, stackTrace) {
      debugPrint('Order submission error: $e\n$stackTrace');
      return OrderResult.failure('Order failed: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addItem(Product product, [int quantity = 1]) {
    _cart.addProduct(product, quantity);
    _lastError = null;
    notifyListeners();
  }

  void removeItem(Product product) {
    _cart.removeProduct(product.id_product ?? 0);
    notifyListeners();
  }

  void updateQuantity(Product product, int newQuantity) {
    if (newQuantity > 0) {
      _cart.updateQuantity(product.id_product ?? 0, newQuantity);
    } else {
      removeItem(product);
    }
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  void clearError() {
    _lastError = null;
    notifyListeners();
  }
}

class OrderResult {
  final bool isSuccess;
  final String message;

  OrderResult._(this.isSuccess, this.message);

  factory OrderResult.success(String message) => OrderResult._(true, message);
  factory OrderResult.failure(String message) => OrderResult._(false, message);
}
