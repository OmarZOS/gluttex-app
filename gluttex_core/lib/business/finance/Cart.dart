import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/finance/Order.dart';
import 'package:gluttex_core/business/finance/OrderedService.dart';
import 'package:gluttex_core/business/finance/ProvidedService.dart';

// Original CartItem class remains exactly the same
class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => (product.product_price ?? 0) * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }
}

// Class for API ordered items (from API response)

// Enhanced Cart class that can work with both local and API data
class Cart {
  // Original fields for local cart functionality
  final Map<int, CartItem> _items = {};

  // New fields for API cart data
  final int? cartId;
  final String? cartStatus;
  final int? cartProductProviderId;
  final int? cartPersonRef;
  final int? cartSellingUser;
  final int? cartClientUser;
  final String? cartNotes;
  final String? cartCreatedAt;
  final String? cartUpdatedAt;
  final List<Invoice> invoices;
  final List<Receipt> receipts;
  final List<Deposit> deposits;
  final double? cartTotalAmount;

  // NEW: Store API ordered items and services
  final List<OrderedItem> orderedItems;
  final List<OrderedService> orderedServices;

  // User/Person related data from the API
  final Map<String, dynamic>? personData;
  final Map<String, dynamic>? userData;

  Cart({
    // Local cart constructor
    this.cartId,
    this.cartStatus,
    this.cartProductProviderId,
    this.cartPersonRef,
    this.cartSellingUser,
    this.cartClientUser,
    this.cartNotes,
    this.cartCreatedAt,
    this.cartUpdatedAt,
    this.invoices = const [],
    this.receipts = const [],
    this.deposits = const [],
    this.cartTotalAmount,

    // NEW: API ordered items and services
    this.orderedItems = const [],
    this.orderedServices = const [],
    this.personData,
    this.userData,
  });

  // Factory constructor from API JSON (for detailed cart data)
  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      cartId: json['cart_id'] as int?,
      cartStatus: json['cart_status'] as String?,
      cartProductProviderId: json['cart_product_provider_id'] as int?,
      cartPersonRef: json['cart_person_ref'] as int?,
      cartSellingUser: json['cart_selling_user'] as int?,
      cartClientUser: json['cart_client_user'] as int?,
      cartNotes: json['cart_notes'] as String?,
      cartCreatedAt: json['cart_created_at'] as String?,
      cartUpdatedAt: json['cart_updated_at'] as String?,
      cartTotalAmount: (json['cart_total_amount'] as num?)?.toDouble(),

      invoices: (json['invoice'] as List<dynamic>?)
              ?.map((e) => Invoice.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],

      receipts: (json['receipt'] as List<dynamic>?)
              ?.map((e) => Receipt.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],

      deposits: (json['deposit'] as List<dynamic>?)
              ?.map((e) => Deposit.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],

      // NEW: Parse API ordered items and services
      orderedItems: (json['ordered_item'] as List<dynamic>?)
              ?.map((e) => OrderedItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],

      orderedServices: (json['ordered_service'] as List<dynamic>?)
              ?.map((e) => OrderedService.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],

      personData: json['person'] as Map<String, dynamic>?,
      userData: json['app_user_'] as Map<String, dynamic>?,
    );
  }

  // Named constructor for local shopping cart
  Cart.local()
      : cartId = null,
        cartStatus = 'open',
        cartProductProviderId = null,
        cartPersonRef = null,
        cartSellingUser = null,
        cartClientUser = null,
        cartNotes = null,
        cartCreatedAt = null,
        cartUpdatedAt = null,
        cartTotalAmount = null,
        invoices = const [],
        receipts = const [],
        deposits = const [],
        orderedItems = const [],
        orderedServices = const [],
        personData = null,
        userData = null;

  // ============ ORIGINAL METHODS (unchanged) ============
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

  bool removeProduct(int productId) {
    return _items.remove(productId) != null;
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeProduct(productId);
    } else if (_items.containsKey(productId)) {
      _items[productId] = _items[productId]!.copyWith(quantity: quantity);
    }
  }

  void clear() => _items.clear();

  // ============ NEW METHODS FOR API DATA ============

  // Get all items (local + API ordered items + API ordered services)
  List<dynamic> getAllItems() {
    final List<dynamic> allItems = [];

    // Local cart items
    allItems.addAll(_items.values);

    // API ordered items
    allItems.addAll(orderedItems);

    // API ordered services
    allItems.addAll(orderedServices);

    return allItems;
  }

  // Get total from all sources (local + API)
  double get combinedTotal {
    double total = 0;

    // Local cart total
    total += _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);

    // API ordered items total
    total += orderedItems.fold(
        0.0,
        (sum, item) =>
            sum +
            (item.unitPrice *
                item.orderedQuantity *
                (1 - (item.productDiscount ?? 0.0) / 100)));

    // API ordered services total
    total +=
        orderedServices.fold(0.0, (sum, service) => sum + service.totalPrice);

    return total;
  }

  // Check if has any items (local or API)
  bool get hasAnyItems =>
      _items.isNotEmpty ||
      orderedItems.isNotEmpty ||
      orderedServices.isNotEmpty;

  // ============ ORIGINAL GETTERS (unchanged) ============
  double get totalPrice =>
      _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  List<CartItem> get items => List.unmodifiable(_items.values);
  int get productCount => _items.length;
  int get totalQuantity =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;
  bool containsProduct(int productId) => _items.containsKey(productId);
  int getProductQuantity(int productId) => _items[productId]?.quantity ?? 0;

  // ============ ADDITIONAL GETTERS ============
  bool get isLocalCart => cartId == null;
  bool get isApiCart => cartId != null;

  Invoice? get primaryInvoice => invoices.isNotEmpty ? invoices.first : null;
  bool get hasInvoice => invoices.isNotEmpty;
  bool get hasReceipt => receipts.isNotEmpty;
  bool get hasDeposit => deposits.isNotEmpty;

  String get formattedAmount {
    if (cartTotalAmount != null) {
      return '\$${cartTotalAmount!.toStringAsFixed(2)}';
    }
    return '\$${combinedTotal.toStringAsFixed(2)}';
  }

  String get formattedDate {
    if (cartCreatedAt != null) {
      final date = DateTime.tryParse(cartCreatedAt!);
      if (date != null) return '${date.day}/${date.month}/${date.year}';
    }
    return DateTime.now().toIso8601String().split('T').first;
  }

  // Convert to API JSON format
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (cartId != null) json['cart_id'] = cartId;
    if (cartStatus != null) json['cart_status'] = cartStatus;
    if (cartProductProviderId != null)
      json['cart_product_provider_id'] = cartProductProviderId;
    if (cartPersonRef != null) json['cart_person_ref'] = cartPersonRef;
    if (cartSellingUser != null) json['cart_selling_user'] = cartSellingUser;
    if (cartClientUser != null) json['cart_client_user'] = cartClientUser;
    if (cartNotes != null) json['cart_notes'] = cartNotes;
    if (cartCreatedAt != null) json['cart_created_at'] = cartCreatedAt;
    if (cartUpdatedAt != null) json['cart_updated_at'] = cartUpdatedAt;
    if (cartTotalAmount != null) json['cart_total_amount'] = cartTotalAmount;

    json['invoice'] = invoices.map((e) => e.toJson()).toList();
    json['receipt'] = receipts.map((e) => e.toJson()).toList();
    json['deposit'] = deposits.map((e) => e.toJson()).toList();

    // NEW: Add API ordered items and services
    json['ordered_item'] = orderedItems.map((e) => e.toJson()).toList();
    json['ordered_service'] = orderedServices.map((e) => e.toJson()).toList();

    if (personData != null) json['person'] = personData;
    if (userData != null) json['app_user_'] = userData;

    return json;
  }

  // ============ STATIC METHODS FOR ORDER CREATION ============
  static Map<String, dynamic> buildSingleOrderData({
    required Product product,
    required int quantity,
    required int orderingUserId,
    double discount = 0.0,
    double taxRate = 0.0,
  }) {
    if (quantity <= 0) throw ArgumentError('Quantity must be positive');
    if (product.id_product == null)
      throw ArgumentError('Product ID cannot be null');

    return {
      "ordered_items": [
        {
          "id_ordered_item": 0,
          "ordered_product_id": product.id_product!,
          "order_ref": 0,
          "product_discount": discount.clamp(0.0, 1.0),
          "ordered_quantity": quantity,
          "unit_price": product.product_price ?? 0.0,
          "applied_vat": taxRate.clamp(0.0, 1.0),
        },
      ],
      "submitted_order": {
        "id_placed_order": 0,
        "ordered_timestamp": DateTime.now().toIso8601String(),
        "order_discount": discount.clamp(0.0, 1.0),
        "ordering_user_id": orderingUserId,
      },
    };
  }

  static Map<String, dynamic> buildOrderData(
    List<CartItem> cartItems,
    int orderingUserId,
  ) {
    if (cartItems.isEmpty)
      throw StateError('Cannot build order with empty cart');

    final orderedItems = cartItems.map((item) {
      final product = item.product;
      if (product.id_product == null)
        throw ArgumentError('Product ID cannot be null for order');

      return {
        "id_ordered_item": 0,
        "ordered_product_id": product.id_product!,
        "order_ref": 0,
        "product_discount": 0.0,
        "ordered_quantity": item.quantity,
        "unit_price": product.product_price ?? 0.0,
        "applied_vat": 0.0,
      };
    }).toList();

    return {
      "ordered_items": orderedItems,
      "submitted_order": {
        "id_placed_order": 0,
        "ordered_timestamp": DateTime.now().toIso8601String(),
        "order_discount": 0.0,
        "ordering_user_id": orderingUserId,
      },
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Cart && other.cartId == cartId;
  }

  @override
  int get hashCode => cartId?.hashCode ?? 0;
}

// Supporting Invoice class (unchanged)
class Invoice {
  final int invoiceId;
  final int? invoiceCartId;
  final String invoiceIssueDate;
  final String? invoiceNotes;
  final String invoiceUpdatedAt;
  final String invoiceNumber;
  final double invoiceTotalAmount;
  final String invoiceStatus;
  final String? invoiceDueDate;
  final String invoiceCreatedAt;

  const Invoice({
    required this.invoiceId,
    required this.invoiceCartId,
    required this.invoiceIssueDate,
    this.invoiceNotes,
    required this.invoiceUpdatedAt,
    required this.invoiceNumber,
    required this.invoiceTotalAmount,
    required this.invoiceStatus,
    this.invoiceDueDate,
    required this.invoiceCreatedAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      invoiceId: json['invoice_id'] as int,
      invoiceCartId: json['invoice_cart_id'] as int?,
      invoiceIssueDate: json['invoice_issue_date'] as String,
      invoiceNotes: json['invoice_notes'] as String?,
      invoiceUpdatedAt: json['invoice_updated_at'] as String,
      invoiceNumber: json['invoice_number'] as String,
      invoiceTotalAmount: (json['invoice_total_amount'] as num).toDouble(),
      invoiceStatus: json['invoice_status'] as String,
      invoiceDueDate: json['invoice_due_date'] as String?,
      invoiceCreatedAt: json['invoice_created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'invoice_id': invoiceId,
        'invoice_cart_id': invoiceCartId,
        'invoice_issue_date': invoiceIssueDate,
        'invoice_notes': invoiceNotes,
        'invoice_updated_at': invoiceUpdatedAt,
        'invoice_number': invoiceNumber,
        'invoice_total_amount': invoiceTotalAmount,
        'invoice_status': invoiceStatus,
        'invoice_due_date': invoiceDueDate,
        'invoice_created_at': invoiceCreatedAt,
      };
}

// Extended Receipt model based on database schema
class Receipt {
  final int receiptId;
  final int? receiptPaymentId;
  final String? receiptNumber;
  final double receiptAmount;
  final String? receiptNotes;
  final String receiptCreatedAt;
  final int? receiptCartRef;

  Receipt({
    required this.receiptId,
    this.receiptPaymentId,
    this.receiptNumber,
    required this.receiptAmount,
    this.receiptNotes,
    required this.receiptCreatedAt,
    this.receiptCartRef,
  });

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      receiptId: json['receipt_id'] as int,
      receiptPaymentId: json['receipt_payment_id'] as int?,
      receiptNumber: json['receipt_number'] as String?,
      receiptAmount: (json['receipt_amount'] as num).toDouble(),
      receiptNotes: json['receipt_notes'] as String?,
      receiptCreatedAt: json['receipt_created_at'] as String,
      receiptCartRef: json['receipt_cart_ref'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'receipt_id': receiptId,
        'receipt_payment_id': receiptPaymentId,
        'receipt_number': receiptNumber,
        'receipt_amount': receiptAmount,
        'receipt_notes': receiptNotes,
        'receipt_created_at': receiptCreatedAt,
        'receipt_cart_ref': receiptCartRef,
      };
}

// Extended Deposit model based on database schema
class Deposit {
  final int depositId;
  final int? depositCartId;
  final int? depositInvoiceId;
  final double depositAmount;
  final String depositMethod;
  final String? depositReference;
  final String? depositNotes;
  final String depositCreatedAt;
  final String depositUpdatedAt;
  final int? depositReceiptId;

  Deposit({
    required this.depositId,
    this.depositCartId,
    this.depositInvoiceId,
    required this.depositAmount,
    required this.depositMethod,
    this.depositReference,
    this.depositNotes,
    required this.depositCreatedAt,
    required this.depositUpdatedAt,
    this.depositReceiptId,
  });

  factory Deposit.fromJson(Map<String, dynamic> json) {
    return Deposit(
      depositId: json['deposit_id'] as int,
      depositCartId: json['deposit_cart_id'] as int?,
      depositInvoiceId: json['deposit_invoice_id'] as int?,
      depositAmount: (json['deposit_amount'] as num).toDouble(),
      depositMethod: json['deposit_method'] as String,
      depositReference: json['deposit_reference'] as String?,
      depositNotes: json['deposit_notes'] as String?,
      depositCreatedAt: json['deposit_created_at'] as String,
      depositUpdatedAt: json['deposit_updated_at'] as String,
      depositReceiptId: json['deposit_receipt_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'deposit_id': depositId,
        'deposit_cart_id': depositCartId,
        'deposit_invoice_id': depositInvoiceId,
        'deposit_amount': depositAmount,
        'deposit_method': depositMethod,
        'deposit_reference': depositReference,
        'deposit_notes': depositNotes,
        'deposit_created_at': depositCreatedAt,
        'deposit_updated_at': depositUpdatedAt,
        'deposit_receipt_id': depositReceiptId,
      };
}
