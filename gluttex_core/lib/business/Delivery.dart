import 'dart:convert';

class Delivery {
  int id_delivery;
  int recipient_person;
  int recipient_provider;
  int delivery_package_count;
  double delivery_total_weight;
  String delivery_cargo_dimensions;
  String delivery_goods_description;
  String hs_code;
  String delivery_merchant_name;
  String delivery_shipping_method;
  String delivery_special_instructions;
  String delivery_status;
  int delivery_address_id;
  int delivery_current_address_id;
  double delivery_fee;
  int delivery_placed_order;
  int delivery_provider_id;
  int delivery_broker_id;
  DateTime? delivery_created_at;
  DateTime? delivery_updated_at;

  Delivery({
    this.id_delivery = 0,
    this.recipient_person = 0,
    this.recipient_provider = 0,
    this.delivery_package_count = 0,
    this.delivery_total_weight = 0.0,
    this.delivery_cargo_dimensions = '',
    this.delivery_goods_description = '',
    this.hs_code = '',
    this.delivery_merchant_name = '',
    this.delivery_shipping_method = 'standard',
    this.delivery_special_instructions = '',
    this.delivery_status = 'PENDING',
    this.delivery_address_id = 0,
    this.delivery_current_address_id = 0,
    this.delivery_fee = 0.0,
    this.delivery_placed_order = 0,
    this.delivery_provider_id = 0,
    this.delivery_broker_id = 0,
    this.delivery_created_at,
    this.delivery_updated_at,
  });

  // Factory constructor for creating Delivery from JSON
  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id_delivery: json['id_delivery'] as int? ?? 0,
      recipient_person: json['recipient_person'] as int? ?? 0,
      recipient_provider: json['recipient_provider'] as int? ?? 0,
      delivery_package_count: json['delivery_package_count'] as int? ?? 0,
      delivery_total_weight:
          (json['delivery_total_weight'] as num?)?.toDouble() ?? 0.0,
      delivery_cargo_dimensions:
          json['delivery_cargo_dimensions'] as String? ?? '',
      delivery_goods_description:
          json['delivery_goods_description'] as String? ?? '',
      hs_code: json['hs_code'] as String? ?? '',
      delivery_merchant_name: json['delivery_merchant_name'] as String? ?? '',
      delivery_shipping_method:
          json['delivery_shipping_method'] as String? ?? 'standard',
      delivery_special_instructions:
          json['delivery_special_instructions'] as String? ?? '',
      delivery_status: json['delivery_status'] as String? ?? 'PENDING',
      delivery_address_id: json['delivery_address_id'] as int? ?? 0,
      delivery_current_address_id:
          json['delivery_current_address_id'] as int? ?? 0,
      delivery_fee: (json['delivery_fee'] as num?)?.toDouble() ?? 0.0,
      delivery_placed_order: json['delivery_placed_order'] as int? ?? 0,
      delivery_provider_id: json['delivery_provider_id'] as int? ?? 0,
      delivery_broker_id: json['delivery_broker_id'] as int? ?? 0,
      delivery_created_at: json['delivery_created_at'] != null
          ? DateTime.tryParse(json['delivery_created_at'].toString())
          : null,
      delivery_updated_at: json['delivery_updated_at'] != null
          ? DateTime.tryParse(json['delivery_updated_at'].toString())
          : null,
    );
  }

  // Factory constructor for creating Delivery from API response
  factory Delivery.fromApiResponse(Map<String, dynamic> response) {
    return Delivery.fromJson(response);
  }

  // Factory constructor for creating Delivery from DeliveryData
  factory Delivery.fromDeliveryData(DeliveryData data) {
    return Delivery(
      id_delivery: data.idDelivery,
      recipient_person: data.recipientPerson,
      recipient_provider: data.recipientProvider,
      delivery_package_count: data.deliveryPackageCount,
      delivery_total_weight: data.deliveryTotalWeight,
      delivery_cargo_dimensions: data.deliveryCargoDimensions,
      delivery_goods_description: data.deliveryGoodsDescription,
      hs_code: data.hsCode,
      delivery_merchant_name: data.deliveryMerchantName,
      delivery_shipping_method: data.deliveryShippingMethod,
      delivery_special_instructions: data.deliverySpecialInstructions,
      delivery_status: data.deliveryStatus,
      delivery_address_id: data.deliveryAddressId,
      delivery_current_address_id: data.deliveryCurrentAddressId,
      delivery_fee: data.deliveryFee,
      delivery_placed_order: data.deliveryPlacedOrder,
      delivery_provider_id: data.deliveryProviderId,
      delivery_broker_id: data.deliveryBrokerId,
    );
  }

  // Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id_delivery': id_delivery,
      'recipient_person': recipient_person,
      'recipient_provider': recipient_provider,
      'delivery_package_count': delivery_package_count,
      'delivery_total_weight': delivery_total_weight,
      'delivery_cargo_dimensions': delivery_cargo_dimensions,
      'delivery_goods_description': delivery_goods_description,
      'hs_code': hs_code,
      'delivery_merchant_name': delivery_merchant_name,
      'delivery_shipping_method': delivery_shipping_method,
      'delivery_special_instructions': delivery_special_instructions,
      'delivery_status': delivery_status,
      'delivery_address_id': delivery_address_id,
      'delivery_current_address_id': delivery_current_address_id,
      'delivery_fee': delivery_fee,
      'delivery_placed_order': delivery_placed_order,
      'delivery_provider_id': delivery_provider_id,
      'delivery_broker_id': delivery_broker_id,
      if (delivery_created_at != null)
        'delivery_created_at': delivery_created_at!.toIso8601String(),
      if (delivery_updated_at != null)
        'delivery_updated_at': delivery_updated_at!.toIso8601String(),
    };
  }

  // Convert to JSON string
  String toJsonString() {
    return json.encode(toJson());
  }

  // Clone method
  Delivery copyWith({
    int? id_delivery,
    int? recipient_person,
    int? recipient_provider,
    int? delivery_package_count,
    double? delivery_total_weight,
    String? delivery_cargo_dimensions,
    String? delivery_goods_description,
    String? hs_code,
    String? delivery_merchant_name,
    String? delivery_shipping_method,
    String? delivery_special_instructions,
    String? delivery_status,
    int? delivery_address_id,
    int? delivery_current_address_id,
    double? delivery_fee,
    int? delivery_placed_order,
    int? delivery_provider_id,
    int? delivery_broker_id,
    DateTime? delivery_created_at,
    DateTime? delivery_updated_at,
  }) {
    return Delivery(
      id_delivery: id_delivery ?? this.id_delivery,
      recipient_person: recipient_person ?? this.recipient_person,
      recipient_provider: recipient_provider ?? this.recipient_provider,
      delivery_package_count:
          delivery_package_count ?? this.delivery_package_count,
      delivery_total_weight:
          delivery_total_weight ?? this.delivery_total_weight,
      delivery_cargo_dimensions:
          delivery_cargo_dimensions ?? this.delivery_cargo_dimensions,
      delivery_goods_description:
          delivery_goods_description ?? this.delivery_goods_description,
      hs_code: hs_code ?? this.hs_code,
      delivery_merchant_name:
          delivery_merchant_name ?? this.delivery_merchant_name,
      delivery_shipping_method:
          delivery_shipping_method ?? this.delivery_shipping_method,
      delivery_special_instructions:
          delivery_special_instructions ?? this.delivery_special_instructions,
      delivery_status: delivery_status ?? this.delivery_status,
      delivery_address_id: delivery_address_id ?? this.delivery_address_id,
      delivery_current_address_id:
          delivery_current_address_id ?? this.delivery_current_address_id,
      delivery_fee: delivery_fee ?? this.delivery_fee,
      delivery_placed_order:
          delivery_placed_order ?? this.delivery_placed_order,
      delivery_provider_id: delivery_provider_id ?? this.delivery_provider_id,
      delivery_broker_id: delivery_broker_id ?? this.delivery_broker_id,
      delivery_created_at: delivery_created_at ?? this.delivery_created_at,
      delivery_updated_at: delivery_updated_at ?? this.delivery_updated_at,
    );
  }

  // Validation methods
  bool get isValidForCreation {
    return delivery_address_id > 0 &&
        (recipient_person > 0 ||
            recipient_provider > 0 ||
            delivery_placed_order > 0) &&
        delivery_package_count > 0 &&
        delivery_total_weight > 0;
  }

  bool get isValidForUpdate {
    return id_delivery > 0;
  }

  List<String> validate() {
    final errors = <String>[];

    if (delivery_address_id <= 0) {
      errors.add('Delivery address is required');
    }

    if (recipient_person <= 0 &&
        recipient_provider <= 0 &&
        delivery_placed_order <= 0) {
      errors.add(
          'Either recipient person, provider, or order reference is required');
    }

    if (delivery_package_count <= 0) {
      errors.add('Package count must be greater than 0');
    }

    if (delivery_total_weight <= 0) {
      errors.add('Total weight must be greater than 0');
    }

    if (delivery_shipping_method.isEmpty) {
      errors.add('Shipping method is required');
    }

    return errors;
  }

  // Status helpers
  bool get isPending => delivery_status == 'PENDING';
  bool get isInTransit => delivery_status == 'IN_TRANSIT';
  bool get isDelivered => delivery_status == 'DELIVERED';
  bool get isCancelled => delivery_status == 'CANCELLED';
  bool get isFailed => delivery_status == 'FAILED';

  bool get canBeCancelled => isPending || isInTransit;
  bool get canBeUpdated => !isDelivered && !isCancelled;

  // Shipping method helpers
  static const List<String> shippingMethods = [
    'standard',
    'express',
    'overnight',
    'freight',
  ];

  static const Map<String, String> shippingMethodLabels = {
    'standard': 'Standard Delivery',
    'express': 'Express Delivery',
    'overnight': 'Overnight Delivery',
    'freight': 'Freight Shipping',
  };

  static const Map<String, String> shippingMethodDescriptions = {
    'standard': '3-5 business days',
    'express': '1-2 business days',
    'overnight': 'Next business day',
    'freight': 'Heavy/bulk items, 5-10 business days',
  };

  String get shippingMethodLabel {
    return shippingMethodLabels[delivery_shipping_method] ??
        'Standard Delivery';
  }

  String get shippingMethodDescription {
    return shippingMethodDescriptions[delivery_shipping_method] ??
        '3-5 business days';
  }

  // Status labels
  static const Map<String, String> statusLabels = {
    'PENDING': 'Pending',
    'PROCESSING': 'Processing',
    'READY_FOR_PICKUP': 'Ready for Pickup',
    'IN_TRANSIT': 'In Transit',
    'OUT_FOR_DELIVERY': 'Out for Delivery',
    'DELIVERED': 'Delivered',
    'FAILED': 'Failed',
    'CANCELLED': 'Cancelled',
    'RETURNED': 'Returned',
  };

  String get statusLabel {
    return statusLabels[delivery_status] ?? 'Pending';
  }

  // Price calculation
  double calculateEstimatedPrice({
    double basePrice = 5.0,
    double perKgRate = 0.5,
    Map<String, double> shippingMultipliers = const {
      'standard': 1.0,
      'express': 1.5,
      'overnight': 2.0,
      'freight': 3.0,
    },
  }) {
    final weightCost = delivery_total_weight * perKgRate;
    final shippingMultiplier =
        shippingMultipliers[delivery_shipping_method] ?? 1.0;
    return (basePrice + weightCost) * shippingMultiplier;
  }

  // Format methods for display
  String get formattedWeight {
    return '${delivery_total_weight.toStringAsFixed(2)} kg';
  }

  String get formattedFee {
    return '\$${delivery_fee.toStringAsFixed(2)}';
  }

  String get formattedPackageCount {
    return '$delivery_package_count ${delivery_package_count == 1 ? 'package' : 'packages'}';
  }

  // Summary for display
  String get summary {
    return '$formattedPackageCount, $formattedWeight, $shippingMethodLabel';
  }

  @override
  String toString() {
    return 'Delivery(id: $id_delivery, status: $delivery_status, packages: $delivery_package_count, weight: $delivery_total_weight, fee: $delivery_fee)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Delivery &&
          runtimeType == other.runtimeType &&
          id_delivery == other.id_delivery;

  @override
  int get hashCode => id_delivery.hashCode;
}

// DeliveryData class (compatible with your existing code)
class DeliveryData {
  int idDelivery = 0;
  int recipientPerson = 0;
  int recipientProvider = 0;
  int deliveryPackageCount = 0;
  double deliveryTotalWeight = 0.0;
  String deliveryCargoDimensions = '';
  String deliveryGoodsDescription = '';
  String hsCode = '';
  String deliveryMerchantName = '';
  String deliveryShippingMethod = 'standard';
  String deliverySpecialInstructions = '';
  String deliveryStatus = 'PENDING';
  int deliveryAddressId = 0;
  int deliveryCurrentAddressId = 0;
  double deliveryFee = 0.0;
  int deliveryPlacedOrder = 0;
  int deliveryProviderId = 0;
  int deliveryBrokerId = 0;

  DeliveryData({
    this.idDelivery = 0,
    this.recipientPerson = 0,
    this.recipientProvider = 0,
    this.deliveryPackageCount = 0,
    this.deliveryTotalWeight = 0.0,
    this.deliveryCargoDimensions = '',
    this.deliveryGoodsDescription = '',
    this.hsCode = '',
    this.deliveryMerchantName = '',
    this.deliveryShippingMethod = 'standard',
    this.deliverySpecialInstructions = '',
    this.deliveryStatus = 'PENDING',
    this.deliveryAddressId = 0,
    this.deliveryCurrentAddressId = 0,
    this.deliveryFee = 0.0,
    this.deliveryPlacedOrder = 0,
    this.deliveryProviderId = 0,
    this.deliveryBrokerId = 0,
  });

  factory DeliveryData.fromDelivery(Delivery delivery) {
    return DeliveryData(
      idDelivery: delivery.id_delivery,
      recipientPerson: delivery.recipient_person,
      recipientProvider: delivery.recipient_provider,
      deliveryPackageCount: delivery.delivery_package_count,
      deliveryTotalWeight: delivery.delivery_total_weight,
      deliveryCargoDimensions: delivery.delivery_cargo_dimensions,
      deliveryGoodsDescription: delivery.delivery_goods_description,
      hsCode: delivery.hs_code,
      deliveryMerchantName: delivery.delivery_merchant_name,
      deliveryShippingMethod: delivery.delivery_shipping_method,
      deliverySpecialInstructions: delivery.delivery_special_instructions,
      deliveryStatus: delivery.delivery_status,
      deliveryAddressId: delivery.delivery_address_id,
      deliveryCurrentAddressId: delivery.delivery_current_address_id,
      deliveryFee: delivery.delivery_fee,
      deliveryPlacedOrder: delivery.delivery_placed_order,
      deliveryProviderId: delivery.delivery_provider_id,
      deliveryBrokerId: delivery.delivery_broker_id,
    );
  }
  DeliveryData copyWith({
    int? idDelivery,
    int? recipientPerson,
    int? recipientProvider,
    int? deliveryPackageCount,
    double? deliveryTotalWeight,
    String? deliveryCargoDimensions,
    String? deliveryGoodsDescription,
    String? hsCode,
    String? deliveryMerchantName,
    String? deliveryShippingMethod,
    String? deliverySpecialInstructions,
    String? deliveryStatus,
    int? deliveryAddressId,
    int? deliveryCurrentAddressId,
    double? deliveryFee,
    int? deliveryPlacedOrder,
    int? deliveryProviderId,
    int? deliveryBrokerId,
  }) {
    return DeliveryData(
      idDelivery: idDelivery ?? this.idDelivery,
      recipientPerson: recipientPerson ?? this.recipientPerson,
      recipientProvider: recipientProvider ?? this.recipientProvider,
      deliveryPackageCount: deliveryPackageCount ?? this.deliveryPackageCount,
      deliveryTotalWeight: deliveryTotalWeight ?? this.deliveryTotalWeight,
      deliveryCargoDimensions:
          deliveryCargoDimensions ?? this.deliveryCargoDimensions,
      deliveryGoodsDescription:
          deliveryGoodsDescription ?? this.deliveryGoodsDescription,
      hsCode: hsCode ?? this.hsCode,
      deliveryMerchantName: deliveryMerchantName ?? this.deliveryMerchantName,
      deliveryShippingMethod:
          deliveryShippingMethod ?? this.deliveryShippingMethod,
      deliverySpecialInstructions:
          deliverySpecialInstructions ?? this.deliverySpecialInstructions,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      deliveryAddressId: deliveryAddressId ?? this.deliveryAddressId,
      deliveryCurrentAddressId:
          deliveryCurrentAddressId ?? this.deliveryCurrentAddressId,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      deliveryPlacedOrder: deliveryPlacedOrder ?? this.deliveryPlacedOrder,
      deliveryProviderId: deliveryProviderId ?? this.deliveryProviderId,
      deliveryBrokerId: deliveryBrokerId ?? this.deliveryBrokerId,
    );
  }

  Delivery toDelivery() {
    return Delivery.fromDeliveryData(this);
  }

  Map<String, dynamic> toJson() {
    return {
      'id_delivery': idDelivery,
      'recipient_person': recipientPerson,
      'recipient_provider': recipientProvider,
      'delivery_package_count': deliveryPackageCount,
      'delivery_total_weight': deliveryTotalWeight,
      'delivery_cargo_dimensions': deliveryCargoDimensions,
      'delivery_goods_description': deliveryGoodsDescription,
      'hs_code': hsCode,
      'delivery_merchant_name': deliveryMerchantName,
      'delivery_shipping_method': deliveryShippingMethod,
      'delivery_special_instructions': deliverySpecialInstructions,
      'delivery_status': deliveryStatus,
      'delivery_address_id': deliveryAddressId,
      'delivery_current_address_id': deliveryCurrentAddressId,
      'delivery_fee': deliveryFee,
      'delivery_placed_order': deliveryPlacedOrder,
      'delivery_provider_id': deliveryProviderId,
      'delivery_broker_id': deliveryBrokerId,
    };
  }
}

// Extension for easy conversion
extension DeliveryConversion on DeliveryData {
  Delivery toDeliveryModel() => Delivery.fromDeliveryData(this);
}

extension DeliveryDataConversion on Delivery {
  DeliveryData toDeliveryData() => DeliveryData.fromDelivery(this);
}
