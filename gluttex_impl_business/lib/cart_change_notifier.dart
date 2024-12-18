
import 'package:flutter/material.dart';
import 'package:gluttex_core/business/Cart.dart';
import 'package:gluttex_core/business/Product.dart';

class CartChangeNotifier with ChangeNotifier {
  int _cartItemCount = 0;

  final Cart cart = Cart();

  int get cartItemCount => _cartItemCount;

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
