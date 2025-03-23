import 'dart:convert';
import 'dart:typed_data';

class Order {
  final int? id_order;
  final double? total_price;
  final String? ordered_timestamp;
  final double? order_discount;

  Order({
    required this.id_order,
    required this.total_price,
    required this.ordered_timestamp,
    required this.order_discount,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id_order: json['id_placed_order'] ?? 0,
      total_price: json['total_price'] ?? 0,
      ordered_timestamp: json['ordered_timestamp'] ?? "",
      order_discount: json['order_discount'],
    );
  }

  Map<String, dynamic> toJson() {
    throw UnimplementedError(
        "toJson is not implemented, check an implementation inside the cart change notifier.");
    return {
      "ordered_items": [
        {
          "id_ordered_item": 0,
          "ordered_product_id": 1,
          "product_discount": 0,
          "ordered_quantity": 20,
          "unit_price": 32,
          "applied_vat": 0
        }
      ],
      "submitted_order": {
        "order_discount": 0,
        // "ordering_user_id": order_owner_id ?? 0
      }
    };
  }
}
