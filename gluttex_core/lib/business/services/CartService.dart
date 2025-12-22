import 'dart:typed_data';

// import 'package:gluttex_core/business/finance/Order.dart';

import 'package:gluttex_core/business/finance/Order.dart';

import '../finance/Cart.dart';

// CartService.dart
abstract class CartService {
  Future<List<Cart>> getAllCarts(
    offset,
    limit, {
    int providerId = 0,
    int sellerId = 0,
    int cartId = 0,
    int clientId = 0,
    int personId = 0,
  }) async {
    throw UnimplementedError();
  }

  Future<Cart?> getCart(int idCart) async {
    return null;
  }

  Future<Cart?> addCart(dynamic Cart, {params}) async {
    return null;
  }

  Future<Cart?> updateCart(Cart updatedCart) async {
    return null;
  }

  Future<int?> deleteCart(String productId) async {
    return null;
  }

  Future<List<OrderedItem>> getCartDetails(int idCart) async {
    return [];
  }
}
