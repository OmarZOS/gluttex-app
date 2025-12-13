import 'package:flutter/foundation.dart';

@immutable
class BusinessOperation {
  final int? sellerId;
  final String invoiceStatus;
  final double totalPaid;
  final double balanceDue;
  final String paymentStatus;
  final int? cartId;
  final int? client;
  final int? supplierId;
  final int? orderId;
  final double totalAmount;
  final double totalDeposited;
  final String sourceTable;

  const BusinessOperation({
    required this.sellerId,
    required this.invoiceStatus,
    required this.totalPaid,
    required this.balanceDue,
    required this.paymentStatus,
    required this.cartId,
    required this.client,
    required this.supplierId,
    required this.orderId,
    required this.totalAmount,
    required this.totalDeposited,
    required this.sourceTable,
  });

  factory BusinessOperation.fromJson(Map<String, dynamic> json) {
    return BusinessOperation(
      sellerId: json['seller_id'] as int?,
      invoiceStatus: json['invoice_status'] as String? ?? 'unknown',
      totalPaid: (json['total_paid'] as num?)?.toDouble() ?? 0.0,
      balanceDue: (json['balance_due'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: json['payment_status'] as String? ?? 'unknown',
      cartId: json['cart_id'] as int?,
      client: json['client'] as int?,
      supplierId: json['supplier_id'] as int?,
      orderId: json['order_id'] as int?,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      totalDeposited: (json['total_deposited'] as num?)?.toDouble() ?? 0.0,
      sourceTable: json['source_table'] as String? ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'seller_id': sellerId,
      'invoice_status': invoiceStatus,
      'total_paid': totalPaid,
      'balance_due': balanceDue,
      'payment_status': paymentStatus,
      'cart_id': cartId,
      'client': client,
      'supplier_id': supplierId,
      'order_id': orderId,
      'total_amount': totalAmount,
      'total_deposited': totalDeposited,
      'source_table': sourceTable,
    };
  }

  BusinessOperation copyWith({
    int? sellerId,
    String? invoiceStatus,
    double? totalPaid,
    double? balanceDue,
    String? paymentStatus,
    int? cartId,
    int? client,
    int? supplierId,
    int? orderId,
    double? totalAmount,
    double? totalDeposited,
    String? sourceTable,
  }) {
    return BusinessOperation(
      sellerId: sellerId ?? this.sellerId,
      invoiceStatus: invoiceStatus ?? this.invoiceStatus,
      totalPaid: totalPaid ?? this.totalPaid,
      balanceDue: balanceDue ?? this.balanceDue,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      cartId: cartId ?? this.cartId,
      client: client ?? this.client,
      supplierId: supplierId ?? this.supplierId,
      orderId: orderId ?? this.orderId,
      totalAmount: totalAmount ?? this.totalAmount,
      totalDeposited: totalDeposited ?? this.totalDeposited,
      sourceTable: sourceTable ?? this.sourceTable,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BusinessOperation &&
        other.sellerId == sellerId &&
        other.invoiceStatus == invoiceStatus &&
        other.totalPaid == totalPaid &&
        other.balanceDue == balanceDue &&
        other.paymentStatus == paymentStatus &&
        other.cartId == cartId &&
        other.client == client &&
        other.supplierId == supplierId &&
        other.orderId == orderId &&
        other.totalAmount == totalAmount &&
        other.totalDeposited == totalDeposited &&
        other.sourceTable == sourceTable;
  }

  @override
  int get hashCode {
    return Object.hash(
      sellerId,
      invoiceStatus,
      totalPaid,
      balanceDue,
      paymentStatus,
      cartId,
      client,
      supplierId,
      orderId,
      totalAmount,
      totalDeposited,
      sourceTable,
    );
  }

  @override
  String toString() {
    return 'BusinessOperation('
        'sellerId: $sellerId, '
        'invoiceStatus: $invoiceStatus, '
        'totalPaid: $totalPaid, '
        'balanceDue: $balanceDue, '
        'paymentStatus: $paymentStatus, '
        'cartId: $cartId, '
        'client: $client, '
        'supplierId: $supplierId, '
        'orderId: $orderId, '
        'totalAmount: $totalAmount, '
        'totalDeposited: $totalDeposited, '
        'sourceTable: $sourceTable'
        ')';
  }
}

// Summary model for aggregated data
class BusinessSummary {
  final int supplierId;
  final String supplierName;
  final double totalRevenue;
  final double totalCollected;
  final double totalOutstanding;
  final int transactionCount;
  final double averageTransaction;
  final double collectionRate;

  const BusinessSummary({
    required this.supplierId,
    required this.supplierName,
    required this.totalRevenue,
    required this.totalCollected,
    required this.totalOutstanding,
    required this.transactionCount,
    required this.averageTransaction,
    required this.collectionRate,
  });

  factory BusinessSummary.fromOperations(
    int supplierId,
    String supplierName,
    List<BusinessOperation> operations,
  ) {
    final totalRevenue =
        operations.fold<double>(0.0, (sum, op) => sum + op.totalAmount);
    final totalCollected =
        operations.fold<double>(0.0, (sum, op) => sum + op.totalPaid);
    final totalOutstanding =
        operations.fold<double>(0.0, (sum, op) => sum + op.balanceDue);

    return BusinessSummary(
      supplierId: supplierId,
      supplierName: supplierName,
      totalRevenue: totalRevenue,
      totalCollected: totalCollected,
      totalOutstanding: totalOutstanding,
      transactionCount: operations.length,
      averageTransaction:
          operations.isEmpty ? 0.0 : totalRevenue / operations.length,
      collectionRate:
          totalRevenue > 0 ? (totalCollected / totalRevenue) * 100 : 0.0,
    );
  }
}

// Filter options
class BusinessFilter {
  final int? supplierId;
  final String? paymentStatus;
  final String? invoiceStatus;
  final String? sourceTable;
  final DateTime? startDate;
  final DateTime? endDate;
  final String dateRangeType; // Add this field

  const BusinessFilter({
    this.supplierId,
    this.paymentStatus,
    this.invoiceStatus,
    this.sourceTable,
    this.startDate,
    this.endDate,
    this.dateRangeType = 'today', // Default to 'today'
  });

  BusinessFilter copyWith({
    int? supplierId,
    String? paymentStatus,
    String? invoiceStatus,
    String? sourceTable,
    DateTime? startDate,
    DateTime? endDate,
    String? dateRangeType,
  }) {
    return BusinessFilter(
      supplierId: supplierId ?? this.supplierId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      invoiceStatus: invoiceStatus ?? this.invoiceStatus,
      sourceTable: sourceTable ?? this.sourceTable,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      dateRangeType: dateRangeType ?? this.dateRangeType,
    );
  }
}
