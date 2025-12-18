import 'package:flutter/material.dart';
import 'package:gluttex_core/business/finance/Cart.dart';
import 'package:gluttex_core/business/finance/Order.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/finance/ProvidedService.dart';
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
  final bool? showProductsOnly; // NEW: Filter for product items
  final bool? showServicesOnly; // NEW: Filter for service items

  const CartFilter({
    this.status,
    this.hasInvoice,
    this.startDate,
    this.endDate,
    this.showProductsOnly,
    this.showServicesOnly,
  });

  CartFilter copyWith({
    String? status,
    bool? hasInvoice,
    DateTime? startDate,
    DateTime? endDate,
    bool? showProductsOnly,
    bool? showServicesOnly,
  }) {
    return CartFilter(
      status: status ?? this.status,
      hasInvoice: hasInvoice ?? this.hasInvoice,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      showProductsOnly: showProductsOnly ?? this.showProductsOnly,
      showServicesOnly: showServicesOnly ?? this.showServicesOnly,
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
  List<CartItem> get productItems =>
      _localCart.productItems; // NEW: Get only products
  List<CartItem> get serviceItems =>
      _localCart.serviceItems; // NEW: Get only services
  Cart get cart => _localCart;
  int get cartItemCount => _localCart.totalQuantity;
  int get productItemCount =>
      _localCart.productItems.length; // NEW: Product count
  int get serviceItemCount =>
      _localCart.serviceItems.length; // NEW: Service count
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  double get cartSubtotal => _localCart.subtotal; // UPDATED: Use subtotal
  double get cartTotal => _localCart.totalAmount; // UPDATED: Use totalAmount
  List<Cart> get apiCarts => List.unmodifiable(_apiCarts);
  CartFilter get filter => _filter;
  bool get hasCartService => _cartService != null;
  bool get hasProductsInCart => _localCart.productItems.isNotEmpty; // NEW
  bool get hasServicesInCart => _localCart.serviceItems.isNotEmpty; // NEW

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

  void filterProductsOnly() {
    // NEW
    setFilter(
        _filter.copyWith(showProductsOnly: true, showServicesOnly: false));
  }

  void filterServicesOnly() {
    // NEW
    setFilter(
        _filter.copyWith(showProductsOnly: false, showServicesOnly: true));
  }

  void showAllItems() {
    // NEW
    setFilter(_filter.copyWith(showProductsOnly: null, showServicesOnly: null));
  }

  // ============ LOCAL CART METHODS ============
  // UPDATED: Renamed to addProduct for clarity
  void addProduct(Product product, [int quantity = 1]) {
    _localCart.addProduct(product, quantity);
    _clearError();
    notifyListeners();
  }

  // NEW: Add service to cart
  void addService(
    ProvidedService service, {
    int quantity = 1,
    String? scheduledDate,
    String? scheduledTime,
  }) {
    _localCart.addService(
      service,
      quantity: quantity,
      scheduledDate: scheduledDate,
      scheduledTime: scheduledTime,
    );
    _clearError();
    notifyListeners();
  }

  // UPDATED: Generic add item method
  void addItem(dynamic item, [int quantity = 1]) {
    if (item is Product) {
      addProduct(item, quantity);
    } else if (item is ProvidedService) {
      addService(item, quantity: quantity);
    } else {
      throw ArgumentError('Item must be either Product or ProvidedService');
    }
  }

  // UPDATED: Remove item method
  void removeItem({Product? product, ProvidedService? service}) {
    _localCart.removeItem(
      productId: product?.id_product,
      serviceId: service?.id,
    );
    notifyListeners();
  }

  // UPDATED: Update quantity method
  void updateQuantity({
    Product? product,
    ProvidedService? service,
    required int newQuantity,
  }) {
    if (product != null) {
      if (newQuantity > 0) {
        _localCart.updateQuantity(
            productId: product.id_product, quantity: newQuantity);
      } else {
        removeItem(product: product);
      }
    } else if (service != null) {
      if (newQuantity > 0) {
        _localCart.updateQuantity(serviceId: service.id, quantity: newQuantity);
      } else {
        removeItem(service: service);
      }
    }
    notifyListeners();
  }

  // NEW: Update service scheduling
  void updateServiceScheduling({
    required ProvidedService service,
    String? scheduledDate,
    String? scheduledTime,
  }) {
    _localCart.updateServiceScheduling(
      serviceId: service.id,
      scheduledDate: scheduledDate,
      scheduledTime: scheduledTime,
    );
    notifyListeners();
  }

  // UPDATED: Clear cart method
  void clearCart() {
    _localCart.clear();
    notifyListeners();
  }

  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  // NEW: Check if product is in cart
  bool hasProductInCart(Product product) {
    return _localCart.hasProduct(product.id_product ?? 0);
  }

  // NEW: Check if service is in cart
  bool hasServiceInCart(ProvidedService service) {
    return _localCart.hasService(service.id);
  }

  // NEW: Get cart item for a product
  CartItem? getProductCartItem(Product product) {
    return _localCart.getProductItem(product.id_product ?? 0);
  }

  // NEW: Get cart item for a service
  CartItem? getServiceCartItem(ProvidedService service) {
    return _localCart.getServiceItem(service.id);
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

  // UPDATED: Submit order with both products and services
  Future<OrderResult> submitOrder(Map<String, dynamic> orderData) async {
    _setLoading(true);
    try {
      // Add cart items to order data
      final cartItemsJson =
          _localCart.items.map((item) => item.toJson()).toList();
      orderData['items'] = cartItemsJson;
      orderData['item_count'] = _localCart.itemCount;
      orderData['subtotal'] = _localCart.subtotal;
      orderData['total'] = _localCart.totalAmount;
      orderData['product_count'] = _localCart.productItems.length;
      orderData['service_count'] = _localCart.serviceItems.length;

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

      // log("Found the cart: ${cart?.cartId}");
      // log("Found  ${cart?.orderedItems.length} product items.");
      // log("Found  ${cart?.orderedServices.length} service items."); // UPDATED

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

  // UPDATED: Create cart with local cart items
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
      // Prepare cart with local items
      final cartData = _localCart.toJsonForApi();

      final newCart = Cart(
        cartProductProviderId: providerId,
        cartNotes: notes,
        cartPersonRef: personRef,
        cartSellingUser: sellingUserId,
        cartStatus: 'open',
        cartCreatedAt: DateTime.now().toIso8601String(),
        cartUpdatedAt: DateTime.now().toIso8601String(),
        cartTotalAmount: _localCart.totalAmount,
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

  // NEW: Merge local cart with API cart
  void mergeLocalCartWithApiCart(Cart apiCart) {
    // _localCart.mergeWithApiCart(apiCart);
    notifyListeners();
  }

  // NEW: Checkout local cart with items
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

    if (cart != null) {
      _localCart.clear();
      notifyListeners();
    }
    return cart;
  }

  // NEW: Get filtered items for display
  List<CartItem> getFilteredItems() {
    if (_filter.showProductsOnly == true) {
      return _localCart.productItems;
    } else if (_filter.showServicesOnly == true) {
      return _localCart.serviceItems;
    }
    return _localCart.items;
  }

  // NEW: Calculate service duration total
  int get totalServiceDuration {
    return _localCart.serviceItems.fold(0, (total, item) {
      final service = item.service;
      if (service != null) {
        return total + (service.actualDuration * item.quantity);
      }
      return total;
    });
  }

  // NEW: Get service scheduling summary
  Map<String, List<CartItem>> get scheduledServicesByDate {
    final Map<String, List<CartItem>> result = {};

    for (final item in _localCart.serviceItems) {
      if (item.scheduledDate != null) {
        result.putIfAbsent(item.scheduledDate!, () => []).add(item);
      }
    }

    return result;
  }

  // NEW: Check if cart has scheduled services
  bool get hasScheduledServices {
    return _localCart.serviceItems.any((item) => item.scheduledDate != null);
  }

  // UPDATED: Display all carts
  List<Cart> getAllCartsForDisplay() {
    final allCarts = List<Cart>.from(_apiCarts);
    if (_localCart.isNotEmpty) {
      allCarts.insert(
          0,
          Cart(
            cartId: null,
            cartStatus: 'local',
            cartNotes: 'Current shopping cart',
            cartTotalAmount: _localCart.totalAmount,
            cartCreatedAt: DateTime.now().toIso8601String(),
          ));
    }
    return allCarts;
  }
}
