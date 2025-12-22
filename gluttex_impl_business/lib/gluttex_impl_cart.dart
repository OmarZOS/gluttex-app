library gluttex_impl_cart;

import 'dart:developer' as developer;

import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/finance/Cart.dart';
import 'package:gluttex_core/business/finance/Order.dart';

import 'package:gluttex_core/business/services/CartService.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:locator/locator.dart';

class CartServiceImpl implements CartService {
  CartServiceImpl();

  StorageService _storageService = GluttexLocator.get<StorageService>();
  @override
  Future<List<Cart>> getAllCarts(
    offset,
    limit, {
    int providerId = 0,
    int sellerId = 0,
    int cartId = 0,
    int clientId = 0,
    int personId = 0,
  }) async {
    try {
      final responseData = await _storageService.getAll(
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.getCartsEndpoint}/$providerId/$sellerId/$cartId/$clientId/$personId/$offset/$limit');

      final List<dynamic> data = responseData;
      return data
          .map((item) => Cart.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e, stacktrace) {
      developer.log('Failed to get all carts: $e');
      developer.log(stacktrace.toString());
      return [];
    }
  }

  @override
  Future<Cart?> getCart(int idCart) async {
    try {
      final data = await getAllCarts(0, 1, cartId: idCart);
      developer.log("Invoices: ${data[0].invoices.length}");
      developer.log("Items: ${data[0].orderedItems.length}");
      developer.log("Receipts: ${data[0].receipts.length}");
      developer.log("Deposits: ${data[0].deposits.length}");
      return data[0];
    } catch (e) {
      developer.log('Failed to get cart $idCart: $e');
      return null;
    }
  }

  @override
  Future<Cart?> addCart(dynamic cartData, {params}) async {
    try {
      final result = await _storageService.insert(
          '${GluttexConstants.apiBaseUrl}${GluttexConstants.postCartEndpoint}',
          cartData,
          params: params);

      return Cart.fromResponseJson(result);
    } catch (e) {
      developer.log('Failed to add cart: $e');
      return null;
    }
  }

  @override
  Future<Cart?> updateCart(Cart updatedCart) async {
    try {
      final result = await _storageService.update(
        '${GluttexConstants.apiBaseUrl}${GluttexConstants.cartEndpoint}',
        '${updatedCart.cartId}',
        {},
        updatedCart.toJson(),
      );

      return Cart.fromJson(result);
    } catch (e) {
      developer.log('Failed to update cart: $e');
      return null;
    }
  }

  @override
  Future<int?> deleteCart(String cartId) async {
    try {
      final result = await _storageService.delete(
        '${GluttexConstants.apiBaseUrl}${GluttexConstants.cartEndpoint}',
        cartId,
      );

      return result as int?;
    } catch (e) {
      developer.log('Failed to delete cart $cartId: $e');
      return null;
    }
  }

  @override
  Future<List<OrderedItem>> getCartDetails(int idCart) async {
    try {
      final responseData = await _storageService.getAll(
        '${GluttexConstants.apiBaseUrl}${GluttexConstants.getCartDetailsEndpoint}/$idCart',
      );

      final List<dynamic> data = responseData;
      return data
          .map((item) => OrderedItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e, stacktrace) {
      developer.log('Failed to get cart details: $e');
      developer.log(stacktrace.toString());
      return [];
    }
  }

  // Additional useful methods (optional)

  Future<List<Cart>> getCartsByStatus(int userId, String status) async {
    try {
      final responseData = await _storageService.getAll(
        '${GluttexConstants.apiBaseUrl}${GluttexConstants.cartEndpoint}/status/$userId/$status',
      );

      final List<dynamic> data = responseData;
      return data
          .map((item) => Cart.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      developer.log('Failed to get carts by status: $e');
      return [];
    }
  }

  Future<List<Cart>> getCartsByProvider(int userId, int providerId) async {
    try {
      final responseData = await _storageService.getAll(
        '${GluttexConstants.apiBaseUrl}${GluttexConstants.cartEndpoint}/provider/$userId/$providerId',
      );

      final List<dynamic> data = responseData;
      return data
          .map((item) => Cart.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      developer.log('Failed to get carts by provider: $e');
      return [];
    }
  }

  Future<Cart?> updateCartStatus(String cartId, String newStatus) async {
    try {
      final result = await _storageService.update(
        '${GluttexConstants.apiBaseUrl}${GluttexConstants.cartEndpoint}/status/$cartId',
        '',
        {},
        {'status': newStatus},
      );

      return Cart.fromJson(result);
    } catch (e) {
      developer.log('Failed to update cart status: $e');
      return null;
    }
  }
}
