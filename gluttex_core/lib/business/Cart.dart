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
