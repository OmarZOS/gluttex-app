import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gluttex_core/business/finance/Cart.dart';
import 'package:gluttex_core/business/finance/Order.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/services/OrderService.dart';
import 'package:gluttex_core/business/services/CartService.dart';
import 'package:locator/locator.dart';

// ============ SUPPORTING CLASSES ============
class OrderResult {
  final bool isSuccess;
  final String message;

  const OrderResult._(this.isSuccess, this.message);

  factory OrderResult.success(String message) => OrderResult._(true, message);
  factory OrderResult.failure(String message) => OrderResult._(false, message);
}

class CartFilter {
  final String? status;
  final bool? hasInvoice;
  final DateTime? startDate;
  final DateTime? endDate;

  const CartFilter({
    this.status,
    this.hasInvoice,
    this.startDate,
    this.endDate,
  });

  CartFilter copyWith({
    String? status,
    bool? hasInvoice,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return CartFilter(
      status: status ?? this.status,
      hasInvoice: hasInvoice ?? this.hasInvoice,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  bool matches(Cart cart) {
    if (status != null && cart.cartStatus != status) return false;
    if (hasInvoice != null && cart.hasInvoice != hasInvoice) return false;
    if (startDate != null) {
      final cartDate = DateTime.tryParse(cart.cartCreatedAt ?? '');
      if (cartDate != null && cartDate.isBefore(startDate!)) return false;
    }
    if (endDate != null) {
      final cartDate = DateTime.tryParse(cart.cartCreatedAt ?? '');
      if (cartDate != null && cartDate.isAfter(endDate!)) return false;
    }
    return true;
  }
}

// ============ CART CHANGE NOTIFIER ============
class CartChangeNotifier with ChangeNotifier {
  final OrderService _orderService = GluttexLocator.get<OrderService>();
  final CartService? _cartService = GluttexLocator.get<CartService>();

  // State
  final Cart _localCart = Cart.local();
  final List<Cart> _apiCarts = [];
  final Map<int, Order> _orders = {};
  bool _isLoading = false;
  String? _lastError;
  CartFilter _filter = const CartFilter();

  // ============ PUBLIC GETTERS ============
  List<Order> get orders => List.unmodifiable(_orders.values);
  List<CartItem> get cartItems => _localCart.items;
  Cart get cart => _localCart;
  int get cartItemCount => _localCart.totalQuantity;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  double get cartTotal => _localCart.totalPrice;
  List<Cart> get apiCarts => List.unmodifiable(_apiCarts);
  CartFilter get filter => _filter;
  bool get hasCartService => _cartService != null;

  List<Cart> get filteredCarts => _apiCarts.where(_filter.matches).toList();

  double get totalApiCartAmount {
    return _apiCarts.fold(
        0.0, (sum, cart) => sum + (cart.cartTotalAmount ?? 0));
  }

  int get totalApiCarts => _apiCarts.length;

  int get completedApiCarts {
    return _apiCarts
        .where((c) => c.cartStatus?.toLowerCase() == 'completed')
        .length;
  }

  // ============ STATE MANAGEMENT HELPERS ============
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

  Future<int> _getCurrentUserId() async {
    // Implement actual user ID retrieval
    return 1;
  }

  void _updateCartInList(Cart cart) {
    final index = _apiCarts.indexWhere((c) => c.cartId == cart.cartId);
    if (index != -1) {
      _apiCarts[index] = cart;
    } else {
      _apiCarts.add(cart);
    }
    notifyListeners();
  }

  // ============ FILTER METHODS ============
  void setFilter(CartFilter newFilter) {
    _filter = newFilter;
    notifyListeners();
  }

  void clearFilter() {
    _filter = const CartFilter();
    notifyListeners();
  }

  // ============ LOCAL CART METHODS ============
  void addItem(Product product, [int quantity = 1]) {
    _localCart.addProduct(product, quantity);
    _clearError();
  }

  void removeItem(Product product) {
    _localCart.removeProduct(product.id_product ?? 0);
    notifyListeners();
  }

  void updateQuantity(Product product, int newQuantity) {
    if (newQuantity > 0) {
      _localCart.updateQuantity(product.id_product ?? 0, newQuantity);
    } else {
      removeItem(product);
    }
    notifyListeners();
  }

  void clearCart() {
    _localCart.clear();
    notifyListeners();
  }

  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  // ============ ORDER METHODS ============
  Future<void> fetchOrders({bool reset = false, required int appUserId}) async {
    if (_isLoading) return;
    _setLoading(true);
    _clearError();

    try {
      if (reset) _orders.clear();
      final fetchedOrders =
          await _orderService.getAllOrders(0, 30, idUser: appUserId);

      for (final order in fetchedOrders) {
        final existingOrder = _orders[order.idOrder];
        _orders[order.idOrder] =
            existingOrder != null && existingOrder.hasItems()
                ? order.copyWith(items: existingOrder.items)
                : order;
      }
    } catch (e, stackTrace) {
      _setError('Failed to fetch orders: ${e.toString()}');
      debugPrint('Error fetching orders: $e\n$stackTrace');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchOrderDetails({required int orderId}) async {
    if (_isLoading) return;
    _setLoading(true);
    _clearError();

    try {
      final orderDetails = await _orderService.getOrderDetails(orderId);
      for (final detailedOrder in orderDetails) {
        _orders[detailedOrder.idOrderedItem]?.items = [detailedOrder];
      }
    } catch (e, stackTrace) {
      _setError('Failed to fetch order details: ${e.toString()}');
      debugPrint('Error fetching order details: $e\n$stackTrace');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshOrderDetails(int orderId) async {
    await fetchOrderDetails(orderId: orderId);
  }

  List<Order> getOrdersByStatus(String status) {
    return _orders.values.where((order) => order.status == status).toList();
  }

  Order? getOrderWithDetails(int orderId) {
    final order = _orders[orderId];
    return order != null && order.items != null ? order : null;
  }

  Future<OrderResult> submitOrder(Map<String, dynamic> orderData) async {
    _setLoading(true);
    try {
      final data = await _orderService.addOrder(orderData);
      if (data != null) {
        _localCart.clear();
        await fetchOrders(appUserId: data.idOrder ?? 0);
        return OrderResult.success('Order placed successfully');
      }
      return OrderResult.failure('Failed to place order');
    } catch (e, stackTrace) {
      debugPrint('Order submission error: $e\n$stackTrace');
      return OrderResult.failure('Order failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // ============ API CART METHODS ============
  Future<void> fetchCarts({int? userId, bool reset = false}) async {
    if (_cartService == null) {
      _setError('CartService not available');
      return;
    }
    if (_isLoading) return;

    _setLoading(true);
    _clearError();

    try {
      if (reset) _apiCarts.clear();
      final userIdToUse = userId ?? await _getCurrentUserId();
      final carts =
          await _cartService.getAllCarts(0, 30, sellerId: userIdToUse);
      if (carts.isNotEmpty) _apiCarts.addAll(carts);
    } catch (e, stackTrace) {
      _setError('Failed to fetch carts: ${e.toString()}');
      debugPrint('Error fetching carts: $e\n$stackTrace');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchCartDetails(int cartId) async {
    if (_cartService == null) return;
    _setLoading(true);
    _clearError();

    try {
      final cart = await _cartService.getCart(cartId);

      log("Found the cart: ${cart?.cartId}");
      log("Found  ${cart?.orderedItems.length} items.");

      if (cart != null) _updateCartInList(cart);
    } catch (e, stackTrace) {
      _setError('Failed to fetch cart details: ${e.toString()}');
      debugPrint('Error fetching cart details: $e\n$stackTrace');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchCartItems(int cartId) async {
    if (_cartService == null) return;
    try {
      final items = await _cartService!.getCart(cartId);
      final index = _apiCarts.indexWhere((c) => c.cartId == cartId);
      if (index != -1) {
        debugPrint('Fetched items for cart $cartId');
      }
    } catch (e) {
      debugPrint('Error fetching cart items: $e');
    }
  }

  Future<Cart?> createCart({
    required int providerId,
    String? notes,
    int? personRef,
    int? sellingUserId,
  }) async {
    if (_cartService == null) {
      _setError('CartService not available');
      return null;
    }

    _setLoading(true);
    try {
      final newCart = Cart(
        cartProductProviderId: providerId,
        cartNotes: notes,
        cartPersonRef: personRef,
        cartSellingUser: sellingUserId,
        cartStatus: 'open',
        cartCreatedAt: DateTime.now().toIso8601String(),
        cartUpdatedAt: DateTime.now().toIso8601String(),
      );

      final createdCart = await _cartService!.addCart(newCart);
      if (createdCart != null) {
        _apiCarts.insert(0, createdCart);
        return createdCart;
      }
      return null;
    } catch (e, stackTrace) {
      _setError('Failed to create cart: ${e.toString()}');
      debugPrint('Error creating cart: $e\n$stackTrace');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateCartStatus(int cartId, String newStatus) async {
    if (_cartService == null) return false;
    final index = _apiCarts.indexWhere((c) => c.cartId == cartId);
    if (index == -1) return false;

    try {
      final updatedCart = _apiCarts[index];
      final result = await _cartService!.updateCart(updatedCart);
      if (result != null) {
        _apiCarts[index] = result;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating cart status: $e');
      return false;
    }
  }

  Future<bool> deleteCart(int cartId) async {
    if (_cartService == null) return false;
    _setLoading(true);
    try {
      final success = await _cartService!.deleteCart(cartId.toString());
      return success == 0;
    } catch (e) {
      _setError('Failed to delete cart: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ============ DISPLAY & UTILITY METHODS ============
  List<Cart> getAllCartsForDisplay() {
    final allCarts = List<Cart>.from(_apiCarts);
    if (_localCart.isNotEmpty) {
      allCarts.insert(
          0,
          Cart(
            cartId: null,
            cartStatus: 'local',
            cartNotes: 'Current shopping cart',
            cartTotalAmount: _localCart.totalPrice,
            cartCreatedAt: DateTime.now().toIso8601String(),
          ));
    }
    return allCarts;
  }

  Future<Cart?> checkoutLocalCart({
    required int providerId,
    String? notes,
    int? personRef,
    int? sellingUserId,
  }) async {
    if (_localCart.isEmpty) {
      _setError('Cannot checkout empty cart');
      return null;
    }

    final cart = await createCart(
      providerId: providerId,
      notes: notes ?? 'Checkout from local cart',
      personRef: personRef,
      sellingUserId: sellingUserId,
    );

    if (cart != null) _localCart.clear();
    return cart;
  }
}
