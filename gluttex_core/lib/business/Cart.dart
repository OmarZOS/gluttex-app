import 'package:gluttex_core/business/Product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  }) : assert(quantity > 0, 'Quantity must be positive');

  double get totalPrice => (product.product_price ?? 0) * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }
}

class Cart {
  final Map<int, CartItem> _items = {};

  /// Adds a product to the cart or updates its quantity if already present
  void addProduct(Product product, [int quantity = 1]) {
    if (quantity <= 0) throw ArgumentError('Quantity must be positive');
    if (product.id_product == null)
      throw ArgumentError('Product ID cannot be null');

    final productId = product.id_product!;
    _items.update(
      productId,
      (existing) => existing.copyWith(quantity: existing.quantity + quantity),
      ifAbsent: () => CartItem(product: product, quantity: quantity),
    );
  }

  /// Removes a product from the cart
  bool removeProduct(int productId) {
    return _items.remove(productId) != null;
  }

  /// Updates product quantity (removes if quantity <= 0)
  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeProduct(productId);
    } else if (_items.containsKey(productId)) {
      _items[productId] = _items[productId]!.copyWith(quantity: quantity);
    }
  }

  /// Clears all items from the cart
  void clear() => _items.clear();

  /// Builds order data for a single product
  static Map<String, dynamic> buildSingleOrderData({
    required Product product,
    required int quantity,
    required int orderingUserId,
    double discount = 0.0,
    double taxRate = 0.0,
  }) {
    assert(quantity > 0, 'Quantity must be positive');
    assert(product.id_product != null, 'Product ID cannot be null');

    return {
      "ordered_items": [
        {
          "id_ordered_item": 0,
          "ordered_product_id": product.id_product,
          "order_ref": 0,
          "product_discount": discount.clamp(0.0, 1.0),
          "ordered_quantity": quantity,
          "unit_price": product.product_price ?? 0.0,
          "applied_vat": taxRate.clamp(0.0, 1.0),
        }
      ],
      "submitted_order": {
        "id_placed_order": 0,
        "ordered_timestamp": DateTime.now().toIso8601String(),
        "order_discount": discount.clamp(0.0, 1.0),
        "ordering_user_id": orderingUserId,
      }
    };
  }

  /// Builds order data for all cart items
  static Map<String, dynamic> buildOrderData(
    List<CartItem> cartItems,
    int orderingUserId,
  ) {
    if (cartItems.isEmpty)
      throw StateError('Cannot build order with empty cart');

    final orderedItems = cartItems.map((item) {
      if (item.product.id_product == null) {
        throw StateError('Product ID cannot be null for order');
      }

      return {
        "id_ordered_item": 0,
        "ordered_product_id": item.product.id_product,
        "order_ref": 0,
        "product_discount": 0.0,
        "ordered_quantity": item.quantity,
        "unit_price": item.product.product_price ?? 0.0,
        "applied_vat": 0.0,
      };
    }).toList();

    return {
      "ordered_items": orderedItems,
      "submitted_order": {
        "ordering_user_id": orderingUserId,
        "ordered_timestamp": DateTime.now().toIso8601String(),
      }
    };
  }

  /// Gets the total price of all items in the cart
  double get totalPrice =>
      _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);

  /// Gets all cart items as an unmodifiable list
  List<CartItem> get items => List.unmodifiable(_items.values);

  /// Gets the number of unique products in the cart
  int get productCount => _items.length;

  /// Gets the total quantity of all items in the cart
  int get totalQuantity =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  /// Checks if a specific product exists in the cart
  bool containsProduct(int productId) => _items.containsKey(productId);

  /// Gets the quantity of a specific product in the cart
  int getProductQuantity(int productId) => _items[productId]?.quantity ?? 0;
}
