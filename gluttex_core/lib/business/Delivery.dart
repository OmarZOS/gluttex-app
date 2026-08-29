import 'dart:convert';
import 'package:gluttex_core/business/Supplier.dart';

// ============================================================================
// DELIVERY ADDRESS CLASS
// ============================================================================

class DeliveryAddress {
  final int idAddress;
  final String? addressCity;
  final String? addressStreet;
  final String? addressPostalCode;
  final String? addressCountry;

  DeliveryAddress({
    required this.idAddress,
    this.addressCity,
    this.addressStreet,
    this.addressPostalCode,
    this.addressCountry,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      idAddress: json['id_address'] as int? ?? 0,
      addressCity: json['address_city'] as String?,
      addressStreet: json['address_street'] as String?,
      addressPostalCode: json['address_postal_code'] as String?,
      addressCountry: json['address_country'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_address': idAddress,
      if (addressCity != null) 'address_city': addressCity,
      if (addressStreet != null) 'address_street': addressStreet,
      if (addressPostalCode != null) 'address_postal_code': addressPostalCode,
      if (addressCountry != null) 'address_country': addressCountry,
    };
  }

  String get fullAddress {
    final parts = <String>[];
    if (addressStreet != null && addressStreet!.isNotEmpty)
      parts.add(addressStreet!);
    if (addressCity != null && addressCity!.isNotEmpty) parts.add(addressCity!);
    if (addressPostalCode != null && addressPostalCode!.isNotEmpty)
      parts.add(addressPostalCode!);
    if (addressCountry != null && addressCountry!.isNotEmpty)
      parts.add(addressCountry!);
    return parts.join(', ');
  }

  @override
  String toString() => fullAddress;
}

// ============================================================================
// DELIVERY INVOICE CLASS
// ============================================================================

class DeliveryInvoice {
  final int invoiceId;
  final double? invoiceTotalAmount;
  final String? invoiceStatus;
  final String? invoiceDueDate;
  final DateTime? invoiceCreatedAt;
  final String? invoiceType;
  final String? invoiceNumber;
  final String? invoiceIssueDate;
  final String? invoiceNotes;
  final DateTime? invoiceUpdatedAt;
  final int? invoiceTaxApplied;
  final List<dynamic>? cart;
  final List<dynamic>? placedOrder;

  DeliveryInvoice({
    required this.invoiceId,
    this.invoiceTotalAmount,
    this.invoiceStatus,
    this.invoiceDueDate,
    this.invoiceCreatedAt,
    this.invoiceType,
    this.invoiceNumber,
    this.invoiceIssueDate,
    this.invoiceNotes,
    this.invoiceUpdatedAt,
    this.invoiceTaxApplied,
    this.cart,
    this.placedOrder,
  });

  factory DeliveryInvoice.fromJson(Map<String, dynamic> json) {
    return DeliveryInvoice(
      invoiceId: json['invoice_id'] as int? ?? 0,
      invoiceTotalAmount: (json['invoice_total_amount'] as num?)?.toDouble(),
      invoiceStatus: json['invoice_status'] as String?,
      invoiceDueDate: json['invoice_due_date'] as String?,
      invoiceCreatedAt: _safeDateTime(json['invoice_created_at']),
      invoiceType: json['invoice_type'] as String?,
      invoiceNumber: json['invoice_number'] as String?,
      invoiceIssueDate: json['invoice_issue_date'] as String?,
      invoiceNotes: json['invoice_notes'] as String?,
      invoiceUpdatedAt: _safeDateTime(json['invoice_updated_at']),
      invoiceTaxApplied: json['invoice_tax_applied'] as int?,
      cart: json['cart'] as List?,
      placedOrder: json['placed_order'] as List?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invoice_id': invoiceId,
      if (invoiceTotalAmount != null)
        'invoice_total_amount': invoiceTotalAmount,
      if (invoiceStatus != null) 'invoice_status': invoiceStatus,
      if (invoiceDueDate != null) 'invoice_due_date': invoiceDueDate,
      if (invoiceCreatedAt != null)
        'invoice_created_at': invoiceCreatedAt!.toIso8601String(),
      if (invoiceType != null) 'invoice_type': invoiceType,
      if (invoiceNumber != null) 'invoice_number': invoiceNumber,
      if (invoiceIssueDate != null) 'invoice_issue_date': invoiceIssueDate,
      if (invoiceNotes != null) 'invoice_notes': invoiceNotes,
      if (invoiceUpdatedAt != null)
        'invoice_updated_at': invoiceUpdatedAt!.toIso8601String(),
      if (invoiceTaxApplied != null) 'invoice_tax_applied': invoiceTaxApplied,
      if (cart != null) 'cart': cart,
      if (placedOrder != null) 'placed_order': placedOrder,
    };
  }

  String get formattedTotal {
    return 'DA ${(invoiceTotalAmount ?? 0).toStringAsFixed(2)}';
  }

  static DateTime? _safeDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

// ============================================================================
// DELIVERY CLASS
// ============================================================================

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
  Supplier? delivery_provider;
  DeliveryAddress? delivery_address;
  DeliveryInvoice? invoice;
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
    this.delivery_address,
    this.invoice,
    this.delivery_broker,
  });

  // ==================== FACTORY CONSTRUCTORS ====================

  factory Delivery.fromJson(Map<String, dynamic> json) {
    // Parse delivery_provider using existing Supplier.fromJson
    Supplier? provider;
    if (json['delivery_provider'] != null) {
      try {
        final providerData = json['delivery_provider'] as Map<String, dynamic>;
        provider = Supplier.fromJson(providerData);
      } catch (_) {}
    }

    // Parse delivery_address
    DeliveryAddress? address;
    if (json['delivery_address'] != null) {
      try {
        address = DeliveryAddress.fromJson(json['delivery_address']);
      } catch (_) {}
    }

    // Parse invoice
    DeliveryInvoice? invoice;
    if (json['invoice'] != null) {
      try {
        invoice = DeliveryInvoice.fromJson(json['invoice']);
      } catch (_) {}
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
      delivery_address: address,
      invoice: invoice,
      delivery_broker: json['delivery_broker'] as Map<String, dynamic>?,
    );
  }

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
    if (value is String) return DateTime.tryParse(value);
    return null;
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
      if (delivery_address != null)
        'delivery_address': delivery_address!.toJson(),
      if (invoice != null) 'invoice': invoice!.toJson(),
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
    Supplier? delivery_provider,
    DeliveryAddress? delivery_address,
    DeliveryInvoice? invoice,
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
      delivery_address: delivery_address ?? this.delivery_address,
      invoice: invoice ?? this.invoice,
      delivery_broker: delivery_broker ?? this.delivery_broker,
    );
  }

  // ==================== GETTERS ====================

  int? get providerId =>
      delivery_provider?.idProductProvider ?? delivery_provider_id;
  String? get providerName =>
      delivery_provider?.displayName ?? delivery_provider?.providerName;
  int? get providerOrgId => delivery_provider?.idProviderOrganisation;
  String? get providerAddress => delivery_provider?.fullAddress;
  String? get providerOrganisationName =>
      delivery_provider?.providerOrganisationName;

  String get addressFull => delivery_address?.fullAddress ?? 'No address';
  String get invoiceTotal => invoice?.formattedTotal ?? 'DA 0.00';

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
    return 'DA ${fee.toStringAsFixed(2)}';
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
// DELIVERY DATA CLASS (LEGACY SUPPORT)
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
