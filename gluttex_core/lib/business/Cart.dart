import 'package:gluttex_core/business/Product.dart';

class CartItem {
  final Product product; // Product details
  int quantity; // Ordered quantity

  CartItem({required this.product, this.quantity = 1});
}

class Cart {
  final Map<int, CartItem> _items = {}; // Key: Product ID, Value: CartItem

  // Add a product to the cart
  void addProduct(Product product, [int quantity = 1]) {
    if (_items.containsKey(product.id_product)) {
      _items[product.id_product]!.quantity += quantity;
    } else {
      _items[product.id_product ?? 0] =
          CartItem(product: product, quantity: quantity);
    }
  }

  // Remove a product from the cart
  void removeProduct(int productId) {
    _items.remove(productId);
  }

  static Map<String, dynamic> buildSingleOrderData({
    required Product product,
    required int quantity,
    required int orderingUserId,
    double discount = 0.0,
    double taxRate = 0.0,
  }) {
    return {
      "ordered_items": [
        {
          "id_ordered_item": 0,
          "ordered_product_id": product.id_product ?? 0,
          "order_ref": 0,
          "product_discount": discount,
          "ordered_quantity": quantity,
          "unit_price": product.product_price ?? 0.0,
          "applied_vat": taxRate
        }
      ],
      "submitted_order": {
        "id_placed_order": 0,
        "ordered_timestamp": "",
        "order_discount": 0,
        "ordering_user_id": orderingUserId
      }
    };
  }

  static Map<String, dynamic> buildOrderData(
      List<CartItem> cartItems, int orderingUserId) {
    List<Map<String, dynamic>> orderedItems = [];

    for (CartItem item in cartItems) {
      orderedItems.add({
        "id_ordered_item": 0,
        "ordered_product_id": item.product.id_product ?? 0,
        "order_ref": 0,
        "product_discount": 0,
        "ordered_quantity": item.quantity,
        "unit_price": item.product.product_price ?? 0.0,
        "applied_vat": 0.0
      });
    }

    return {
      "ordered_items": orderedItems,
      "submitted_order": {"ordering_user_id": orderingUserId}
    };
  }

  // Update product quantity
  void updateQuantity(int productId, int quantity) {
    if (_items.containsKey(productId)) {
      _items[productId]!.quantity = quantity;
      if (_items[productId]!.quantity <= 0) {
        _items.remove(productId); // Remove item if quantity is zero
      }
    }
  }

  // Get total price of the cart
  double getTotalPrice() {
    return _items.values
        .map((item) => item.product.product_price ?? 0 * item.quantity)
        .fold(0, (prev, next) => prev + next);
  }

  // Get cart items as a list
  List<CartItem> get items => _items.values.toList();

  // Check if the cart is empty
  bool get isEmpty => _items.isEmpty;
}
