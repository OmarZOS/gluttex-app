// financial_document.dart
class FinancialDocument {
  final String documentType; // 'invoice', 'deposit', 'pending_cart', 'receipt'
  final int documentId;
  final String documentNumber;
  final int sourceId;
  final String
      sourceType; // 'cart_based', 'order_based', 'invoice_based', 'direct_invoice'
  final int supplierId;
  final int customerId;
  final String customerType; // 'user', 'person', 'unknown'
  final int customerPersonId;
  final int sellerId;
  final double documentAmount;
  final DateTime issueDate;
  final DateTime? dueDate;
  final double totalPaid;
  final double totalDeposited;
  final double additionalFees;
  final double outstandingBalance;
  final String documentStatus;
  final String paymentStatus;
  final int daysIssued;
  final int daysOverdue;
  final DateTime createdAt;
  final DateTime updatedAt;

  FinancialDocument({
    required this.documentType,
    required this.documentId,
    required this.documentNumber,
    required this.sourceId,
    required this.sourceType,
    required this.supplierId,
    required this.customerId,
    required this.customerType,
    required this.customerPersonId,
    required this.sellerId,
    required this.documentAmount,
    required this.issueDate,
    this.dueDate,
    required this.totalPaid,
    required this.totalDeposited,
    required this.additionalFees,
    required this.outstandingBalance,
    required this.documentStatus,
    required this.paymentStatus,
    required this.daysIssued,
    required this.daysOverdue,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor from JSON
  factory FinancialDocument.fromJson(Map<String, dynamic> json) {
    return FinancialDocument(
      documentType: json['document_type'] ?? '',
      documentId: (json['document_id'] ?? 0).toInt(),
      documentNumber: json['document_number'] ?? '',
      sourceId: (json['source_id'] ?? 0).toInt(),
      sourceType: json['source_type'] ?? '',
      supplierId: (json['supplier_id'] ?? 0).toInt(),
      customerId: (json['customer_id'] ?? 0).toInt(),
      customerType: json['customer_type'] ?? 'unknown',
      customerPersonId: (json['customer_person_id'] ?? 0).toInt(),
      sellerId: (json['seller_id'] ?? 0).toInt(),
      documentAmount: (json['document_amount'] ?? 0.0).toDouble(),
      issueDate:
          DateTime.parse(json['issue_date'] ?? DateTime.now().toString()),
      dueDate:
          json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      totalPaid: (json['total_paid'] ?? 0.0).toDouble(),
      totalDeposited: (json['total_deposited'] ?? 0.0).toDouble(),
      additionalFees: (json['additional_fees'] ?? 0.0).toDouble(),
      outstandingBalance: (json['outstanding_balance'] ?? 0.0).toDouble(),
      documentStatus: json['document_status'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      daysIssued: (json['days_issued'] ?? 0).toInt(),
      daysOverdue: (json['days_overdue'] ?? 0).toInt(),
      createdAt: DateTime.parse(
          json['invoice_created_at'] ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(
          json['invoice_updated_at'] ?? DateTime.now().toString()),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'document_type': documentType,
      'document_id': documentId,
      'document_number': documentNumber,
      'source_id': sourceId,
      'source_type': sourceType,
      'supplier_id': supplierId,
      'customer_id': customerId,
      'customer_type': customerType,
      'customer_person_id': customerPersonId,
      'seller_id': sellerId,
      'document_amount': documentAmount,
      'issue_date': issueDate.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'total_paid': totalPaid,
      'total_deposited': totalDeposited,
      'additional_fees': additionalFees,
      'outstanding_balance': outstandingBalance,
      'document_status': documentStatus,
      'payment_status': paymentStatus,
      'days_issued': daysIssued,
      'days_overdue': daysOverdue,
      'invoice_created_at': createdAt.toIso8601String(),
      'invoice_updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper getters
  bool get isInvoice => documentType == 'invoice';
  bool get isDeposit => documentType == 'deposit';
  bool get isPendingCart => documentType == 'pending_cart';
  bool get isReceipt => documentType == 'receipt';

  bool get isCartBased => sourceType == 'cart_based';
  bool get isOrderBased => sourceType == 'order_based';

  bool get isCustomerUser => customerType == 'user';
  bool get isCustomerPerson => customerType == 'person';

  bool get isPaid => paymentStatus.contains('paid');
  bool get isUnpaid => paymentStatus.contains('unpaid');
  bool get isPartiallyPaid => paymentStatus.contains('partially_paid');
  bool get isFullyPaid => paymentStatus.contains('fully_paid');
  bool get isCanceled => documentStatus == 'canceled';

  bool get isOverdue => daysOverdue > 0;

  // Calculate total received amount
  double get totalReceived => totalPaid + totalDeposited;

  // Calculate payment percentage
  double get paymentPercentage {
    if (documentAmount == 0) return 0;
    return (totalReceived / documentAmount * 100).clamp(0, 100);
  }

  // Get formatted amount with currency symbol
  // String get formattedAmount => 'DZD${documentAmount.toStringAsFixed(2)}';
  // String get formattedOutstanding =>
  // 'DZD${outstandingBalance.toStringAsFixed(2)}';
  // String get formattedReceived => 'DZD${totalReceived.toStringAsFixed(2)}';

  // Get due date formatted
  String get formattedDueDate {
    if (dueDate == null) return 'No due date';
    final now = DateTime.now();
    if (dueDate!.isBefore(now)) {
      return 'Overdue ${daysOverdue} days';
    }
    return 'Due in ${dueDate!.difference(now).inDays} days';
  }

  // Get document type display name
  String get displayType {
    switch (documentType) {
      case 'invoice':
        return 'Invoice';
      case 'deposit':
        return 'Deposit';
      case 'pending_cart':
        return 'Pending Cart';
      case 'receipt':
        return 'Receipt';
      default:
        return documentType;
    }
  }

  // Get payment status display name
  String get displayPaymentStatus {
    switch (paymentStatus) {
      case 'fully_paid':
        return 'Paid';
      case 'partially_paid':
        return 'Partial';
      case 'unpaid':
        return 'Unpaid';
      case 'canceled':
        return 'Canceled';
      case 'deposit_received':
        return 'Deposit';
      case 'deposit_covers_full':
        return 'Deposit Covers';
      case 'deposit_partial':
        return 'Partial Deposit';
      default:
        return paymentStatus;
    }
  }
}
