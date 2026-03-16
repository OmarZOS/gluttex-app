// import 'package:flutter/foundation.dart';

class BusinessOperation {
  // Primary identifiers
  final int supplierId;
  final int? orderId;
  final int? cartId;
  final int? clientId; // Renamed from 'client' to match Python model
  final int sellerId;
  final int? invoiceId;
  final int? receiptId;

  // Financial information
  final double totalAmount;
  final double balanceDue;
  final double totalPaid;
  final double totalDeposited;

  // Status and classification
  final String paymentStatus;
  final String invoiceStatus;
  final String documentType;
  final String operationType;
  final String sourceTable;

  // Temporal information
  final DateTime? operationDate;

  const BusinessOperation({
    required this.supplierId,
    this.orderId,
    this.cartId,
    this.clientId,
    required this.sellerId,
    this.invoiceId,
    this.receiptId,
    required this.totalAmount,
    required this.balanceDue,
    required this.totalPaid,
    required this.totalDeposited,
    required this.paymentStatus,
    required this.invoiceStatus,
    required this.documentType,
    required this.operationType,
    required this.sourceTable,
    this.operationDate,
  });

  // Add this method to your BusinessOperation class
  factory BusinessOperation.fromJson(Map<String, dynamic> json) {
    // print('🔍 Parsing BusinessOperation JSON:');
    // print('  Raw JSON: $json');

    // Log each field to see what's coming in
    // json.forEach((key, value) {
    //   print('  $key: $value (type: ${value.runtimeType})');
    // });

    try {
      return BusinessOperation(
        supplierId: json['supplier_id'] as int? ?? 0,
        orderId: json['order_id'] as int?,
        cartId: json['cart_id'] as int?,
        clientId: json['client_id'] as int?, // Updated field name
        sellerId: json['seller_id'] as int? ?? 0,
        invoiceId: json['invoice_id'] as int?,
        receiptId: json['receipt_id'] as int?,
        totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
        balanceDue: (json['balance_due'] as num?)?.toDouble() ?? 0.0,
        totalPaid: (json['total_paid'] as num?)?.toDouble() ?? 0.0,
        totalDeposited: (json['total_deposited'] as num?)?.toDouble() ?? 0.0,
        paymentStatus: json['payment_status'] as String? ?? 'unknown',
        invoiceStatus: json['invoice_status'] as String? ?? 'unknown',
        documentType: json['document_type'] as String? ?? 'unknown',
        operationType: json['operation_type'] as String? ?? 'unknown',
        sourceTable: json['source_table'] as String? ?? 'unknown',
        operationDate: json['operation_date'] != null
            ? DateTime.parse(json['operation_date'] as String)
            : null,
      );
    } catch (e, stackTrace) {
      print('❌ Error parsing BusinessOperation: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'supplier_id': supplierId,
      'order_id': orderId,
      'cart_id': cartId,
      'client_id': clientId,
      'seller_id': sellerId,
      'invoice_id': invoiceId,
      'receipt_id': receiptId,
      'total_amount': totalAmount,
      'balance_due': balanceDue,
      'total_paid': totalPaid,
      'total_deposited': totalDeposited,
      'payment_status': paymentStatus,
      'invoice_status': invoiceStatus,
      'document_type': documentType,
      'operation_type': operationType,
      'source_table': sourceTable,
      'operation_date': operationDate?.toIso8601String(),
    };
  }

  BusinessOperation copyWith({
    int? supplierId,
    int? orderId,
    int? cartId,
    int? clientId,
    int? sellerId,
    int? invoiceId,
    int? receiptId,
    double? totalAmount,
    double? balanceDue,
    double? totalPaid,
    double? totalDeposited,
    String? paymentStatus,
    String? invoiceStatus,
    String? documentType,
    String? operationType,
    String? sourceTable,
    DateTime? operationDate,
  }) {
    return BusinessOperation(
      supplierId: supplierId ?? this.supplierId,
      orderId: orderId ?? this.orderId,
      cartId: cartId ?? this.cartId,
      clientId: clientId ?? this.clientId,
      sellerId: sellerId ?? this.sellerId,
      invoiceId: invoiceId ?? this.invoiceId,
      receiptId: receiptId ?? this.receiptId,
      totalAmount: totalAmount ?? this.totalAmount,
      balanceDue: balanceDue ?? this.balanceDue,
      totalPaid: totalPaid ?? this.totalPaid,
      totalDeposited: totalDeposited ?? this.totalDeposited,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      invoiceStatus: invoiceStatus ?? this.invoiceStatus,
      documentType: documentType ?? this.documentType,
      operationType: operationType ?? this.operationType,
      sourceTable: sourceTable ?? this.sourceTable,
      operationDate: operationDate ?? this.operationDate,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BusinessOperation &&
        other.supplierId == supplierId &&
        other.orderId == orderId &&
        other.cartId == cartId &&
        other.clientId == clientId &&
        other.sellerId == sellerId &&
        other.invoiceId == invoiceId &&
        other.receiptId == receiptId &&
        other.totalAmount == totalAmount &&
        other.balanceDue == balanceDue &&
        other.totalPaid == totalPaid &&
        other.totalDeposited == totalDeposited &&
        other.paymentStatus == paymentStatus &&
        other.invoiceStatus == invoiceStatus &&
        other.documentType == documentType &&
        other.operationType == operationType &&
        other.sourceTable == sourceTable &&
        other.operationDate == operationDate;
  }

  @override
  int get hashCode {
    return Object.hash(
      supplierId,
      orderId,
      cartId,
      clientId,
      sellerId,
      invoiceId,
      receiptId,
      totalAmount,
      balanceDue,
      totalPaid,
      totalDeposited,
      paymentStatus,
      invoiceStatus,
      documentType,
      operationType,
      sourceTable,
      operationDate,
    );
  }

  @override
  String toString() {
    return 'BusinessOperation('
        'supplierId: $supplierId, '
        'orderId: $orderId, '
        'cartId: $cartId, '
        'clientId: $clientId, '
        'sellerId: $sellerId, '
        'invoiceId: $invoiceId, '
        'receiptId: $receiptId, '
        'totalAmount: $totalAmount, '
        'balanceDue: $balanceDue, '
        'totalPaid: $totalPaid, '
        'totalDeposited: $totalDeposited, '
        'paymentStatus: $paymentStatus, '
        'invoiceStatus: $invoiceStatus, '
        'documentType: $documentType, '
        'operationType: $operationType, '
        'sourceTable: $sourceTable, '
        'operationDate: $operationDate'
        ')';
  }

  // Helper methods
  bool get hasInvoice => invoiceId != null;
  bool get hasReceipt => receiptId != null;
  bool get isPaid =>
      paymentStatus.toLowerCase() == 'paid' ||
      paymentStatus.toLowerCase() == 'fully_paid';
  bool get isPartiallyPaid =>
      paymentStatus.toLowerCase() == 'partial' ||
      paymentStatus.toLowerCase() == 'partially_paid';
  bool get isUnpaid => paymentStatus.toLowerCase() == 'unpaid';
  bool get isOverdue => paymentStatus.toLowerCase() == 'overdue';

  // Get operation title based on available IDs
  String getOperationTitle() {
    if (orderId != null) return 'Order #$orderId';
    if (cartId != null) return 'Cart #$cartId';
    if (invoiceId != null) return 'Invoice #$invoiceId';
    return 'Transaction #$supplierId';
  }

  // Get operation type display name
  String getOperationTypeDisplay() {
    switch (operationType.toLowerCase()) {
      case 'products':
        return 'Products';
      case 'services':
        return 'Services';
      case 'mixed':
        return 'Mixed';
      default:
        return operationType;
    }
  }

  // Get document type display name
  String getDocumentTypeDisplay() {
    switch (documentType.toLowerCase()) {
      case 'invoice':
        return 'Invoice';
      case 'receipt':
        return 'Receipt';
      case 'deposit':
        return 'Deposit';
      default:
        return documentType;
    }
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

// Filter options with enhanced date filtering
class BusinessFilter {
  final int? supplierId;
  final String? paymentStatus;
  final String? invoiceStatus;
  final String? documentType;
  final String? operationType;
  final String? sourceTable;
  final DateTime? startDate;
  final DateTime? endDate;
  final String dateRangeType;

  const BusinessFilter({
    this.supplierId,
    this.paymentStatus,
    this.invoiceStatus,
    this.documentType,
    this.operationType,
    this.sourceTable,
    this.startDate,
    this.endDate,
    this.dateRangeType = 'today',
  });

  BusinessFilter copyWith({
    int? supplierId,
    String? paymentStatus,
    String? invoiceStatus,
    String? documentType,
    String? operationType,
    String? sourceTable,
    DateTime? startDate,
    DateTime? endDate,
    String? dateRangeType,
  }) {
    return BusinessFilter(
      supplierId: supplierId ?? this.supplierId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      invoiceStatus: invoiceStatus ?? this.invoiceStatus,
      documentType: documentType ?? this.documentType,
      operationType: operationType ?? this.operationType,
      sourceTable: sourceTable ?? this.sourceTable,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      dateRangeType: dateRangeType ?? this.dateRangeType,
    );
  }

  // Apply filter to list of operations
  List<BusinessOperation> applyFilter(List<BusinessOperation> operations) {
    return operations.where((operation) {
      // Supplier filter
      if (supplierId != null && operation.supplierId != supplierId) {
        return false;
      }

      // Payment status filter
      if (paymentStatus != null && operation.paymentStatus != paymentStatus) {
        return false;
      }

      // Invoice status filter
      if (invoiceStatus != null && operation.invoiceStatus != invoiceStatus) {
        return false;
      }

      // Document type filter
      if (documentType != null && operation.documentType != documentType) {
        return false;
      }

      // Operation type filter
      if (operationType != null && operation.operationType != operationType) {
        return false;
      }

      // Source table filter
      if (sourceTable != null && operation.sourceTable != sourceTable) {
        return false;
      }

      // Date range filter
      if (operation.operationDate != null) {
        if (startDate != null &&
            operation.operationDate!.isBefore(startDate!)) {
          return false;
        }
        if (endDate != null && operation.operationDate!.isAfter(endDate!)) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}

// Operation statistics
class OperationStatistics {
  final int totalOperations;
  final double totalRevenue;
  final double totalCollected;
  final double collectionRate;
  final Map<String, int> operationTypeCount;
  final Map<String, int> paymentStatusCount;

  const OperationStatistics({
    required this.totalOperations,
    required this.totalRevenue,
    required this.totalCollected,
    required this.collectionRate,
    required this.operationTypeCount,
    required this.paymentStatusCount,
  });

  factory OperationStatistics.fromOperations(
      List<BusinessOperation> operations) {
    final totalRevenue =
        operations.fold<double>(0.0, (sum, op) => sum + op.totalAmount);
    final totalCollected =
        operations.fold<double>(0.0, (sum, op) => sum + op.totalPaid);

    final operationTypeCount = <String, int>{};
    final paymentStatusCount = <String, int>{};

    for (final operation in operations) {
      operationTypeCount.update(
        operation.operationType,
        (value) => value + 1,
        ifAbsent: () => 1,
      );

      paymentStatusCount.update(
        operation.paymentStatus,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    return OperationStatistics(
      totalOperations: operations.length,
      totalRevenue: totalRevenue,
      totalCollected: totalCollected,
      collectionRate:
          totalRevenue > 0 ? (totalCollected / totalRevenue) * 100 : 0.0,
      operationTypeCount: operationTypeCount,
      paymentStatusCount: paymentStatusCount,
    );
  }
}
