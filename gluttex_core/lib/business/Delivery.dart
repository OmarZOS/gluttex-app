import 'dart:convert';

class Delivery {
  int id_delivery;
  int recipient_person;
  int recipient_provider;
  int? delivery_package_count;
  double? delivery_total_weight;
  String? delivery_cargo_dimensions;
  String? delivery_goods_description;
  String? hs_code;
  String? delivery_merchant_name;
  String delivery_shipping_method;
  String? delivery_special_instructions;
  String delivery_status;
  int? delivery_address_id;
  int? delivery_current_address_id;
  double? delivery_fee;
  int? delivery_invoice_ref;
  int? delivery_provider_id;
  int? delivery_broker_id;
  String? delivery_source_type;
  int? delivery_source_id;
  DateTime? delivery_created_at;
  DateTime? delivery_updated_at;
  ProductProvider? delivery_provider; // Changed to typed ProductProvider
  Map<String, dynamic>? delivery_broker;

  Delivery({
    this.id_delivery = 0,
    this.recipient_person = 0,
    this.recipient_provider = 0,
    this.delivery_package_count,
    this.delivery_total_weight,
    this.delivery_cargo_dimensions,
    this.delivery_goods_description,
    this.hs_code,
    this.delivery_merchant_name,
    this.delivery_shipping_method = 'standard',
    this.delivery_special_instructions,
    this.delivery_status = 'pending',
    this.delivery_address_id,
    this.delivery_current_address_id,
    this.delivery_fee,
    this.delivery_invoice_ref,
    this.delivery_provider_id,
    this.delivery_broker_id,
    this.delivery_source_type,
    this.delivery_source_id,
    this.delivery_created_at,
    this.delivery_updated_at,
    this.delivery_provider,
    this.delivery_broker,
  });

  // ==================== FACTORY CONSTRUCTORS ====================

  /// Parse from API response
  factory Delivery.fromJson(Map<String, dynamic> json) {
    // Parse delivery_provider if present - it's already a ProductProvider object
    ProductProvider? provider;
    if (json['delivery_provider'] != null) {
      try {
        final providerData = json['delivery_provider'] as Map<String, dynamic>;
        provider = ProductProvider.fromJson(providerData);
      } catch (e) {
        // If parsing fails, try to create from available fields
        try {
          final providerData =
              json['delivery_provider'] as Map<String, dynamic>;
          provider = ProductProvider(
            idProductProvider: providerData['id_product_provider'] as int?,
            productProviderOwner:
                providerData['product_provider_owner'] as int?,
            productProviderLocationId:
                providerData['product_provider_location_id'] as int?,
            productProviderDetailsId:
                providerData['product_provider_details_id'] as int?,
            productProviderTypeId:
                providerData['product_provider_type_id'] as int?,
            productProviderOrgId:
                providerData['product_provider_org_id'] as int?,
            displayName: providerData['provider_organisation_name'] as String?,
          );
        } catch (_) {
          // Failed to parse, keep null
        }
      }
    }

    // Get provider ID from the provider object if available
    int? providerId = _safeIntNull(json['delivery_provider_id']);
    if (providerId == null && provider != null) {
      providerId = provider.idProductProvider;
    }

    return Delivery(
      id_delivery: _safeInt(json['id_delivery']),
      recipient_person: _safeInt(json['recipient_person']),
      recipient_provider: _safeInt(json['recipient_provider']),
      delivery_package_count: _safeIntNull(json['delivery_package_count']),
      delivery_total_weight: _safeDoubleNull(json['delivery_total_weight']),
      delivery_cargo_dimensions: json['delivery_cargo_dimensions'] as String?,
      delivery_goods_description: json['delivery_goods_description'] as String?,
      hs_code: json['hs_code'] as String?,
      delivery_merchant_name: json['delivery_merchant_name'] as String?,
      delivery_shipping_method:
          json['delivery_shipping_method'] as String? ?? 'standard',
      delivery_special_instructions:
          json['delivery_special_instructions'] as String?,
      delivery_status: json['delivery_status'] as String? ?? 'pending',
      delivery_address_id: _safeIntNull(json['delivery_address_id']),
      delivery_current_address_id:
          _safeIntNull(json['delivery_current_address_id']),
      delivery_fee: _safeDoubleNull(json['delivery_fee']),
      delivery_invoice_ref: _safeIntNull(json['delivery_invoice_ref']),
      delivery_provider_id: providerId,
      delivery_broker_id: _safeIntNull(json['delivery_broker_id']),
      delivery_source_type: json['delivery_source_type'] as String?,
      delivery_source_id: _safeIntNull(json['delivery_source_id']),
      delivery_created_at: _safeDateTime(json['delivery_created_at']),
      delivery_updated_at: _safeDateTime(json['delivery_updated_at']),
      delivery_provider: provider,
      delivery_broker: json['delivery_broker'] as Map<String, dynamic>?,
    );
  }

  // ==================== HELPER METHODS ====================

  static int _safeInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  static int? _safeIntNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  static double? _safeDoubleNull(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static DateTime? _safeDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.tryParse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Convert DeliveryData to Delivery
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
      delivery_invoice_ref: data.deliveryInvoiceRef,
      delivery_provider_id: data.deliveryProviderId,
      delivery_broker_id: data.deliveryBrokerId,
      delivery_source_type: data.deliverySourceType,
      delivery_source_id: data.deliverySourceId,
      // Note: delivery_provider (ProductProvider) and delivery_broker are not in DeliveryData
      // They would need to be set separately if needed
    );
  }

  // ==================== TO JSON ====================

  Map<String, dynamic> toJson() {
    return {
      'id_delivery': id_delivery,
      'recipient_person': recipient_person,
      'recipient_provider': recipient_provider,
      if (delivery_package_count != null)
        'delivery_package_count': delivery_package_count,
      if (delivery_total_weight != null)
        'delivery_total_weight': delivery_total_weight,
      if (delivery_cargo_dimensions != null)
        'delivery_cargo_dimensions': delivery_cargo_dimensions,
      if (delivery_goods_description != null)
        'delivery_goods_description': delivery_goods_description,
      if (hs_code != null) 'hs_code': hs_code,
      if (delivery_merchant_name != null)
        'delivery_merchant_name': delivery_merchant_name,
      'delivery_shipping_method': delivery_shipping_method,
      if (delivery_special_instructions != null)
        'delivery_special_instructions': delivery_special_instructions,
      'delivery_status': delivery_status,
      if (delivery_address_id != null)
        'delivery_address_id': delivery_address_id,
      if (delivery_current_address_id != null)
        'delivery_current_address_id': delivery_current_address_id,
      if (delivery_fee != null) 'delivery_fee': delivery_fee,
      if (delivery_invoice_ref != null)
        'delivery_invoice_ref': delivery_invoice_ref,
      if (delivery_provider_id != null)
        'delivery_provider_id': delivery_provider_id,
      if (delivery_broker_id != null) 'delivery_broker_id': delivery_broker_id,
      if (delivery_source_type != null)
        'delivery_source_type': delivery_source_type,
      if (delivery_source_id != null) 'delivery_source_id': delivery_source_id,
      if (delivery_created_at != null)
        'delivery_created_at': delivery_created_at!.toIso8601String(),
      if (delivery_updated_at != null)
        'delivery_updated_at': delivery_updated_at!.toIso8601String(),
      if (delivery_provider != null)
        'delivery_provider': delivery_provider!.toJson(),
      if (delivery_broker != null) 'delivery_broker': delivery_broker,
    };
  }

  // ==================== COPY WITH ====================

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
    int? delivery_invoice_ref,
    int? delivery_provider_id,
    int? delivery_broker_id,
    String? delivery_source_type,
    int? delivery_source_id,
    DateTime? delivery_created_at,
    DateTime? delivery_updated_at,
    ProductProvider? delivery_provider,
    Map<String, dynamic>? delivery_broker,
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
      delivery_invoice_ref: delivery_invoice_ref ?? this.delivery_invoice_ref,
      delivery_provider_id: delivery_provider_id ?? this.delivery_provider_id,
      delivery_broker_id: delivery_broker_id ?? this.delivery_broker_id,
      delivery_source_type: delivery_source_type ?? this.delivery_source_type,
      delivery_source_id: delivery_source_id ?? this.delivery_source_id,
      delivery_created_at: delivery_created_at ?? this.delivery_created_at,
      delivery_updated_at: delivery_updated_at ?? this.delivery_updated_at,
      delivery_provider: delivery_provider ?? this.delivery_provider,
      delivery_broker: delivery_broker ?? this.delivery_broker,
    );
  }

  // ==================== PROVIDER HELPERS ====================

  int? get providerId {
    if (delivery_provider_id != null && delivery_provider_id! > 0) {
      return delivery_provider_id;
    }
    return delivery_provider?.idProductProvider;
  }

  String? get providerName {
    return delivery_provider?.displayName;
  }

  int? get providerOrgId {
    return delivery_provider?.productProviderOrgId;
  }

  // ==================== STATUS HELPERS ====================

  bool get isPending => delivery_status.toUpperCase() == 'PENDING';
  bool get isProcessing => delivery_status.toUpperCase() == 'PROCESSING';
  bool get isReadyForPickup =>
      delivery_status.toUpperCase() == 'READY_FOR_PICKUP';
  bool get isInTransit => delivery_status.toUpperCase() == 'IN_TRANSIT';
  bool get isOutForDelivery =>
      delivery_status.toUpperCase() == 'OUT_FOR_DELIVERY';
  bool get isDelivered => delivery_status.toUpperCase() == 'DELIVERED';
  bool get isCancelled => delivery_status.toUpperCase() == 'CANCELLED';
  bool get isFailed => delivery_status.toUpperCase() == 'FAILED';
  bool get isReturned => delivery_status.toUpperCase() == 'RETURNED';

  bool get canBeCancelled => isPending || isInTransit || isProcessing;
  bool get canBeUpdated => !isDelivered && !isCancelled;

  // ==================== STATUS LABELS ====================

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
    return statusLabels[delivery_status.toUpperCase()] ?? delivery_status;
  }

  // ==================== SHIPPING METHODS ====================

  static const Map<String, String> shippingMethodLabels = {
    'standard': 'Standard Delivery',
    'express': 'Express Delivery',
    'overnight': 'Overnight Delivery',
    'freight': 'Freight Shipping',
    'pickup': 'Pickup',
    'courier': 'Courier',
    'same_day': 'Same Day',
    'international': 'International',
  };

  String get shippingMethodLabel {
    return shippingMethodLabels[delivery_shipping_method] ??
        'Standard Delivery';
  }

  // ==================== FORMATTED DISPLAY ====================

  String get formattedWeight {
    final weight = delivery_total_weight ?? 0.0;
    return '${weight.toStringAsFixed(2)} kg';
  }

  String get formattedFee {
    final fee = delivery_fee ?? 0.0;
    return '${fee.toStringAsFixed(2)} DA';
  }

  String get formattedPackageCount {
    final count = delivery_package_count ?? 0;
    return '$count ${count == 1 ? 'package' : 'packages'}';
  }

  // ==================== VALIDATION ====================

  bool get isValidForCreation {
    return (delivery_address_id ?? 0) > 0 &&
        (recipient_person > 0 ||
            recipient_provider > 0 ||
            (delivery_invoice_ref ?? 0) > 0) &&
        (delivery_package_count ?? 0) > 0 &&
        (delivery_total_weight ?? 0) > 0;
  }

  // ==================== TO STRING ====================

  @override
  String toString() {
    return 'Delivery(id: $id_delivery, status: $delivery_status, provider: ${providerName ?? delivery_provider_id})';
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
// ============================================================================
// PRODUCT PROVIDER CLASS (if not already defined)
// ============================================================================

class ProductProvider {
  final int? idProductProvider;
  final int? productProviderOwner;
  final int? productProviderLocationId;
  final int? productProviderDetailsId;
  final int? productProviderTypeId;
  final int? productProviderOrgId;
  final String? displayName;

  ProductProvider({
    this.idProductProvider,
    this.productProviderOwner,
    this.productProviderLocationId,
    this.productProviderDetailsId,
    this.productProviderTypeId,
    this.productProviderOrgId,
    this.displayName,
  });

  factory ProductProvider.fromJson(Map<String, dynamic> json) {
    return ProductProvider(
      idProductProvider: json['id_product_provider'] as int?,
      productProviderOwner: json['product_provider_owner'] as int?,
      productProviderLocationId: json['product_provider_location_id'] as int?,
      productProviderDetailsId: json['product_provider_details_id'] as int?,
      productProviderTypeId: json['product_provider_type_id'] as int?,
      productProviderOrgId: json['product_provider_org_id'] as int?,
      displayName: json['provider_organisation_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_product_provider': idProductProvider,
      'product_provider_owner': productProviderOwner,
      'product_provider_location_id': productProviderLocationId,
      'product_provider_details_id': productProviderDetailsId,
      'product_provider_type_id': productProviderTypeId,
      'product_provider_org_id': productProviderOrgId,
      'provider_organisation_name': displayName,
    };
  }
}

// ============================================================================
// LEGACY DELIVERY DATA CLASS (RETROCOMPATIBILITY)
// ============================================================================

class DeliveryData {
  int idDelivery;
  int recipientPerson;
  int recipientProvider;
  int? deliveryPackageCount;
  double? deliveryTotalWeight;
  String? deliveryCargoDimensions;
  String? deliveryGoodsDescription;
  String? hsCode;
  String? deliveryMerchantName;
  String deliveryShippingMethod;
  String? deliverySpecialInstructions;
  String deliveryStatus;
  int? deliveryAddressId;
  int? deliveryCurrentAddressId;
  double? deliveryFee;
  int? deliveryInvoiceRef;
  int? deliveryProviderId;
  int? deliveryBrokerId;
  String? deliverySourceType;
  int? deliverySourceId;

  DeliveryData({
    this.idDelivery = 0,
    this.recipientPerson = 0,
    this.recipientProvider = 0,
    this.deliveryPackageCount,
    this.deliveryTotalWeight,
    this.deliveryCargoDimensions,
    this.deliveryGoodsDescription,
    this.hsCode,
    this.deliveryMerchantName,
    this.deliveryShippingMethod = 'standard',
    this.deliverySpecialInstructions,
    this.deliveryStatus = 'pending',
    this.deliveryAddressId,
    this.deliveryCurrentAddressId,
    this.deliveryFee,
    this.deliveryInvoiceRef,
    this.deliveryProviderId,
    this.deliveryBrokerId,
    this.deliverySourceType,
    this.deliverySourceId,
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
      deliveryInvoiceRef: delivery.delivery_invoice_ref,
      deliveryProviderId: delivery.delivery_provider_id,
      deliveryBrokerId: delivery.delivery_broker_id,
      deliverySourceType: delivery.delivery_source_type,
      deliverySourceId: delivery.delivery_source_id,
    );
  }

  factory DeliveryData.fromJson(Map<String, dynamic> json) {
    return DeliveryData(
      idDelivery: json['id_delivery'] as int? ?? 0,
      recipientPerson: json['recipient_person'] as int? ?? 0,
      recipientProvider: json['recipient_provider'] as int? ?? 0,
      deliveryPackageCount: json['delivery_package_count'] as int?,
      deliveryTotalWeight: (json['delivery_total_weight'] as num?)?.toDouble(),
      deliveryCargoDimensions: json['delivery_cargo_dimensions'] as String?,
      deliveryGoodsDescription: json['delivery_goods_description'] as String?,
      hsCode: json['hs_code'] as String?,
      deliveryMerchantName: json['delivery_merchant_name'] as String?,
      deliveryShippingMethod:
          json['delivery_shipping_method'] as String? ?? 'standard',
      deliverySpecialInstructions:
          json['delivery_special_instructions'] as String?,
      deliveryStatus: json['delivery_status'] as String? ?? 'pending',
      deliveryAddressId: json['delivery_address_id'] as int?,
      deliveryCurrentAddressId: json['delivery_current_address_id'] as int?,
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble(),
      deliveryInvoiceRef: json['delivery_invoice_ref'] as int?,
      deliveryProviderId: json['delivery_provider_id'] as int?,
      deliveryBrokerId: json['delivery_broker_id'] as int?,
      deliverySourceType: json['delivery_source_type'] as String?,
      deliverySourceId: json['delivery_source_id'] as int?,
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
    int? deliveryInvoiceRef,
    int? deliveryProviderId,
    int? deliveryBrokerId,
    String? deliverySourceType,
    int? deliverySourceId,
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
      deliveryInvoiceRef: deliveryInvoiceRef ?? this.deliveryInvoiceRef,
      deliveryProviderId: deliveryProviderId ?? this.deliveryProviderId,
      deliveryBrokerId: deliveryBrokerId ?? this.deliveryBrokerId,
      deliverySourceType: deliverySourceType ?? this.deliverySourceType,
      deliverySourceId: deliverySourceId ?? this.deliverySourceId,
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
      if (deliveryPackageCount != null)
        'delivery_package_count': deliveryPackageCount,
      if (deliveryTotalWeight != null)
        'delivery_total_weight': deliveryTotalWeight,
      if (deliveryCargoDimensions != null)
        'delivery_cargo_dimensions': deliveryCargoDimensions,
      if (deliveryGoodsDescription != null)
        'delivery_goods_description': deliveryGoodsDescription,
      if (hsCode != null) 'hs_code': hsCode,
      if (deliveryMerchantName != null)
        'delivery_merchant_name': deliveryMerchantName,
      'delivery_shipping_method': deliveryShippingMethod,
      if (deliverySpecialInstructions != null)
        'delivery_special_instructions': deliverySpecialInstructions,
      'delivery_status': deliveryStatus,
      if (deliveryAddressId != null) 'delivery_address_id': deliveryAddressId,
      if (deliveryCurrentAddressId != null)
        'delivery_current_address_id': deliveryCurrentAddressId,
      if (deliveryFee != null) 'delivery_fee': deliveryFee,
      if (deliveryInvoiceRef != null)
        'delivery_invoice_ref': deliveryInvoiceRef,
      if (deliveryProviderId != null)
        'delivery_provider_id': deliveryProviderId,
      if (deliveryBrokerId != null) 'delivery_broker_id': deliveryBrokerId,
      if (deliverySourceType != null)
        'delivery_source_type': deliverySourceType,
      if (deliverySourceId != null) 'delivery_source_id': deliverySourceId,
    };
  }
}

// ============================================================================
// EXTENSIONS
// ============================================================================

extension DeliveryConversion on DeliveryData {
  Delivery toDeliveryModel() => Delivery.fromDeliveryData(this);
}

extension DeliveryDataConversion on Delivery {
  DeliveryData toDeliveryData() => DeliveryData.fromDelivery(this);
}
