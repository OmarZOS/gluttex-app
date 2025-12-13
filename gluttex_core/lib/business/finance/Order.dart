import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

class Order {
  final int idOrder;
  final double totalPrice;
  final DateTime orderedTimestamp;
  final double orderDiscount;
  final String placedOrderState;
  final DateTime placedOrderLastMod;
  final String paymentStatus;
  final String paymentMethod;
  final String paymentRef;
  final String status;
  List<OrderedItem>? items; // Nullable for summary vs detailed views
  final int? orderingUserId;

  Order({
    required this.idOrder,
    required this.totalPrice,
    required this.orderedTimestamp,
    required this.orderDiscount,
    required this.placedOrderState,
    required this.placedOrderLastMod,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.paymentRef,
    required this.status,
    this.items,
    this.orderingUserId,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      idOrder: json['id_placed_order'] as int? ?? 0,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      orderedTimestamp: _parseDateTime(json['ordered_timestamp']),
      orderDiscount: (json['order_discount'] as num?)?.toDouble() ?? 0.0,
      placedOrderState: json['placed_order_state'] as String? ?? '',
      placedOrderLastMod: _parseDateTime(json['placed_order_last_mod']),
      paymentStatus: json['payment_status'] as String? ?? '',
      paymentMethod: json['payment_method'] as String? ?? '',
      paymentRef: json['payment_ref'] as String? ?? '',
      status: json['placed_order_state'] as String? ?? '',
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => OrderedItem.fromJson(item))
              .toList()
          : null,
      orderingUserId: json['ordering_user_id'] as int?,
    );
  }

  static DateTime _parseDateTime(dynamic dateString) {
    if (dateString == null) return DateTime.now();
    try {
      return DateTime.parse(dateString.toString());
    } catch (e) {
      return DateTime.now();
    }
  }

  // For order summary (without items)
  Map<String, dynamic> toSummaryJson() {
    return {
      'id_placed_order': idOrder,
      'total_price': totalPrice,
      'ordered_timestamp': orderedTimestamp.toIso8601String(),
      'order_discount': orderDiscount,
      'placed_order_state': placedOrderState,
      'placed_order_last_mod': placedOrderLastMod.toIso8601String(),
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'payment_ref': paymentRef,
      'placed_order_state': status,
      if (orderingUserId != null) 'ordering_user_id': orderingUserId,
    };
  }

  // For creating a new order submission
  Map<String, dynamic> toSubmissionJson() {
    return {
      "ordered_items": items?.map((item) => item.toJson()).toList() ?? [],
      "submitted_order": {
        "order_discount": orderDiscount,
        "placed_order_state": status,
        "placed_order_last_mod": placedOrderLastMod.toIso8601String(),
        "payment_status": paymentStatus,
        "payment_method": paymentMethod,
        "payment_ref": paymentRef,
        "placed_order_state": placedOrderState,
        if (orderingUserId != null) "ordering_user_id": orderingUserId,
      }
    };
  }

  // For complete order representation
  Map<String, dynamic> toJson() {
    return {
      'id_placed_order': idOrder,
      'total_price': totalPrice,
      'ordered_timestamp': orderedTimestamp.toIso8601String(),
      'order_discount': orderDiscount,
      'placed_order_state': placedOrderState,
      'placed_order_last_mod': placedOrderLastMod.toIso8601String(),
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'payment_ref': paymentRef,
      'placed_order_state': status,
      if (orderingUserId != null) 'ordering_user_id': orderingUserId,
      if (items != null) 'items': items!.map((item) => item.toJson()).toList(),
    };
  }

  Order copyWith({
    int? idOrder,
    double? totalPrice,
    DateTime? orderedTimestamp,
    double? orderDiscount,
    String? placedOrderState,
    DateTime? placedOrderLastMod,
    String? paymentStatus,
    String? paymentMethod,
    String? paymentRef,
    String? status,
    List<OrderedItem>? items,
    int? orderingUserId,
  }) {
    return Order(
      idOrder: idOrder ?? this.idOrder,
      totalPrice: totalPrice ?? this.totalPrice,
      orderedTimestamp: orderedTimestamp ?? this.orderedTimestamp,
      orderDiscount: orderDiscount ?? this.orderDiscount,
      placedOrderState: placedOrderState ?? this.placedOrderState,
      placedOrderLastMod: placedOrderLastMod ?? this.placedOrderLastMod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentRef: paymentRef ?? this.paymentRef,
      status: status ?? this.status,
      items: items ?? this.items,
      orderingUserId: orderingUserId ?? this.orderingUserId,
    );
  }

  // Helper methods
  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isPaid => paymentStatus.toLowerCase() == 'paid';

  double get netPrice => totalPrice - orderDiscount;

  bool hasItems() => items != null && items!.isNotEmpty;

  int get itemCount =>
      items?.fold(0, (sum, item) => (sum ?? 0) + item.orderedQuantity) ?? 0;

  @override
  String toString() {
    return 'Order(id: $idOrder, total: \$$totalPrice, status: $status, items: ${items?.length ?? 0})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Order && idOrder == other.idOrder;
  }

  @override
  int get hashCode => idOrder.hashCode;
}

class OrderedItem {
  final int idOrderedItem;
  final double appliedVat;
  final int orderedProductId;
  final int orderedQuantity;
  final int orderRef;
  final double unitPrice;
  final double? productDiscount;
  final OrderedProduct? orderedProduct;

  OrderedItem({
    required this.idOrderedItem,
    required this.appliedVat,
    required this.orderedProductId,
    required this.orderedQuantity,
    required this.orderRef,
    required this.unitPrice,
    this.productDiscount,
    required this.orderedProduct,
  });

  // Factory constructor to create OrderedItem from JSON
  factory OrderedItem.fromJson(Map<String, dynamic> json) {
    OrderedProduct? attachedProduct;
    if (json['ordered_product'] != null) {
      attachedProduct = OrderedProduct.fromJson(
          json['ordered_product'] as Map<String, dynamic>);
    }

    log("Setting this up");
    log(json.toString());
    return OrderedItem(
      idOrderedItem: json['id_ordered_item'] ?? 0,
      appliedVat: (json['applied_vat'] as num).toDouble(),
      orderedProductId: json['ordered_product_id'] ?? 0,
      orderedQuantity:
          int.tryParse(json['ordered_quantity']?.toString() ?? '0') ?? 0,
      orderRef: json['order_ref'] ?? 0,
      unitPrice: (json['unit_price'] as num).toDouble(),
      productDiscount: json['product_discount'] != null
          ? (json['product_discount'] as num).toDouble()
          : null,
      orderedProduct: attachedProduct,
    );
  }

  // Convert OrderedItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'id_ordered_item': idOrderedItem,
      'applied_vat': appliedVat,
      'ordered_product_id': orderedProductId,
      'ordered_quantity': orderedQuantity.toString(),
      'order_ref': orderRef,
      'unit_price': unitPrice,
      'product_discount': productDiscount,
      'ordered_product': orderedProduct,
    };
  }

  // Helper method to calculate total price for this item
  double get totalPrice {
    final basePrice = unitPrice * orderedQuantity;
    final discount = productDiscount ?? 0.0;
    final priceAfterDiscount = basePrice - discount;
    final vatAmount = priceAfterDiscount * appliedVat;
    return priceAfterDiscount + vatAmount;
  }

  // Helper method to calculate VAT amount for this item
  double get vatAmount {
    final basePrice = unitPrice * orderedQuantity;
    final discount = productDiscount ?? 0.0;
    final priceAfterDiscount = basePrice - discount;
    return priceAfterDiscount * appliedVat;
  }

  // Helper method to calculate price before VAT
  double get priceBeforeVat {
    final basePrice = unitPrice * orderedQuantity;
    final discount = productDiscount ?? 0.0;
    return basePrice - discount;
  }

  // Copy with method for immutability
  OrderedItem copyWith({
    int? idOrderedItem,
    double? appliedVat,
    int? orderedProductId,
    int? orderedQuantity,
    int? orderRef,
    double? unitPrice,
    double? productDiscount,
    OrderedProduct? orderedProduct,
  }) {
    return OrderedItem(
      idOrderedItem: idOrderedItem ?? this.idOrderedItem,
      appliedVat: appliedVat ?? this.appliedVat,
      orderedProductId: orderedProductId ?? this.orderedProductId,
      orderedQuantity: orderedQuantity ?? this.orderedQuantity,
      orderRef: orderRef ?? this.orderRef,
      unitPrice: unitPrice ?? this.unitPrice,
      productDiscount: productDiscount ?? this.productDiscount,
      orderedProduct: orderedProduct ?? this.orderedProduct,
    );
  }

  @override
  String toString() {
    return 'OrderedItem(idOrderedItem: $idOrderedItem, orderedProduct: ${orderedProduct?.productName}, quantity: $orderedQuantity, total: \$${totalPrice.toStringAsFixed(2)})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderedItem && other.idOrderedItem == idOrderedItem;
  }

  @override
  int get hashCode {
    return idOrderedItem.hashCode;
  }
}

class OrderedProduct {
  final String productName;
  final int productProviderId;
  final String? productQuantifier;
  final int productOwner;
  final String productBrand;
  final int productCategoryId;
  final int idProduct;
  final DateTime lastUpdated;
  final String productBarcode;
  final DateTime created;
  final String productDescription;
  final double productPrice;
  final int productQuantity;

  OrderedProduct({
    required this.productName,
    required this.productProviderId,
    this.productQuantifier,
    required this.productOwner,
    required this.productBrand,
    required this.productCategoryId,
    required this.idProduct,
    required this.lastUpdated,
    required this.productBarcode,
    required this.created,
    required this.productDescription,
    required this.productPrice,
    required this.productQuantity,
  });

  // Factory constructor to create OrderedProduct from JSON
  factory OrderedProduct.fromJson(Map<String, dynamic> json) {
    return OrderedProduct(
      productName: json['product_name'] as String,
      productProviderId: json['product_provider_id'] as int,
      productQuantifier: json['product_quantifier'] as String?,
      productOwner: json['product_owner'] as int,
      productBrand: json['product_brand'] as String,
      productCategoryId: json['product_category_id'] as int,
      idProduct: json['id_product'] as int,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      productBarcode: json['product_barcode'] as String,
      created: DateTime.parse(json['created'] as String),
      productDescription: json['product_description'] as String,
      productPrice: (json['product_price'] as num).toDouble(),
      productQuantity: json['product_quantity'] as int,
    );
  }

  // Convert OrderedProduct to JSON
  Map<String, dynamic> toJson() {
    return {
      'product_name': productName,
      'product_provider_id': productProviderId,
      'product_quantifier': productQuantifier,
      'product_owner': productOwner,
      'product_brand': productBrand,
      'product_category_id': productCategoryId,
      'id_product': idProduct,
      'last_updated': lastUpdated.toIso8601String(),
      'product_barcode': productBarcode,
      'created': created.toIso8601String(),
      'product_description': productDescription,
      'product_price': productPrice,
      'product_quantity': productQuantity,
    };
  }

  // Copy with method for immutability
  OrderedProduct copyWith({
    String? productName,
    int? productProviderId,
    String? productQuantifier,
    int? productOwner,
    String? productBrand,
    int? productCategoryId,
    int? idProduct,
    DateTime? lastUpdated,
    String? productBarcode,
    DateTime? created,
    String? productDescription,
    double? productPrice,
    int? productQuantity,
  }) {
    return OrderedProduct(
      productName: productName ?? this.productName,
      productProviderId: productProviderId ?? this.productProviderId,
      productQuantifier: productQuantifier ?? this.productQuantifier,
      productOwner: productOwner ?? this.productOwner,
      productBrand: productBrand ?? this.productBrand,
      productCategoryId: productCategoryId ?? this.productCategoryId,
      idProduct: idProduct ?? this.idProduct,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      productBarcode: productBarcode ?? this.productBarcode,
      created: created ?? this.created,
      productDescription: productDescription ?? this.productDescription,
      productPrice: productPrice ?? this.productPrice,
      productQuantity: productQuantity ?? this.productQuantity,
    );
  }

  @override
  String toString() {
    return 'OrderedProduct(idProduct: $idProduct, productName: $productName, price: \$$productPrice)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderedProduct && other.idProduct == idProduct;
  }

  @override
  int get hashCode {
    return idProduct.hashCode;
  }
}

// Helper function to parse a list of OrderedItems from JSON
List<OrderedItem> parseOrderedItems(List<dynamic> jsonList) {
  return jsonList
      .map((item) => OrderedItem.fromJson(item as Map<String, dynamic>))
      .toList();
}

// Helper function to convert a list of OrderedItems to JSON
List<Map<String, dynamic>> orderedItemsToJson(List<OrderedItem> items) {
  return items.map((item) => item.toJson()).toList();
}
