import 'package:flutter/material.dart';
import 'package:gluttex_core/business/Cart.dart';
import 'package:gluttex_core/business/Order.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/services/OrderService.dart';
import 'package:locator/locator.dart';

class CartChangeNotifier with ChangeNotifier {
  final OrderService _orderService = GluttexLocator.get<OrderService>();
  final List<Order> _orders = [];
  bool isLoading = false;
  int _cartItemCount = 0;
  final Cart cart = Cart();

  int get cartItemCount => _cartItemCount;
  List<Order> get orders => _orders;

  Future<void> fetchOrders({bool reset = false, required int appUserId}) async {
    if (isLoading) return;

    if (reset) {
      _orders.clear();
    }

    isLoading = true;
    notifyListeners();

    try {
      final fetchedOrders = await _orderService.getAllOrders(appUserId);
      _orders.clear();
      _orders.addAll(fetchedOrders);
    } catch (e) {
      print("Error fetching orders: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<int?> addOrder(Order order, int appUserId) async {
    int? status = await _orderService.addOrder(order);
    if (status != null) {
      await fetchOrders(appUserId: appUserId);
    }
    return status;
  }

  void addItem(Product product, [int quantity = 1]) {
    cart.addProduct(product, quantity);
    _cartItemCount = cart.items.length;
    notifyListeners();
  }

  void removeItem(Product product) {
    cart.removeProduct(product.id_product ?? 0);
    _cartItemCount = cart.items.length;
    notifyListeners();
  }
}
