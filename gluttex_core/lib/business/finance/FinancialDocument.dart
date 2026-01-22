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
  // final int daysOverdue;
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
    // required this.daysOverdue,
    required this.createdAt,
    required this.updatedAt,
  });

  int get daysUntilDue {
    if (dueDate == null) return 0;
    final now = DateTime.now();
    final difference = dueDate!.difference(now);
    return difference.inDays;
  }

// Getter for days overdue (0 if not overdue, positive if overdue)
  int get daysOverdue {
    if (dueDate == null) return 0;
    final now = DateTime.now();
    if (dueDate!.isBefore(now)) {
      return now.difference(dueDate!).inDays;
    }
    return 0;
  }

  // Factory constructor from JSON
  factory FinancialDocument.fromJson(Map<String, dynamic> json) {
    // Your data appears to be in array format, so we need to map indices to fields
    // Based on your data: 'receipt', '1', 'RCPT-20251229-0001', '1', 'cart_based', '2', '1', 'user', '1', '4', '17.9700', '2025-12-29 11:51:33', '2025-12-29 11:51:33', '17.9700', '0.0000', '0.0000', '0.0000', 'completed', 'paid', 'cash', '0', '0', '2025-12-29 11:51:33', '0'

    // Let's assume the fields are in order, we need to map them properly
    final issueDateStr =
        json['issue_date'] ?? json[11] ?? DateTime.now().toString();
    final createdAtStr =
        json['invoice_created_at'] ?? json[13] ?? DateTime.now().toString();
    final updatedAtStr =
        json['invoice_updated_at'] ?? json[22] ?? DateTime.now().toString();

    // Parse amounts safely
    final documentAmount = double.tryParse(
            (json['document_amount'] ?? json[10] ?? '0').toString()) ??
        0.0;
    final totalDeposited = double.tryParse(
            (json['total_deposited'] ?? json[14] ?? '0').toString()) ??
        0.0;
    final totalPaid =
        double.tryParse((json['total_paid'] ?? json[13] ?? '0').toString()) ??
            0.0;
    final additionalFees = double.tryParse(
            (json['additional_fees'] ?? json[15] ?? '0').toString()) ??
        0.0;

    final outstanding = documentAmount - totalDeposited - totalPaid;

    return FinancialDocument(
      documentType:
          json['document_type']?.toString() ?? json[0]?.toString() ?? '',
      documentId:
          int.tryParse((json['document_id'] ?? json[1] ?? '0').toString()) ?? 0,
      documentNumber:
          json['document_number']?.toString() ?? json[2]?.toString() ?? '',
      sourceId:
          int.tryParse((json['source_id'] ?? json[3] ?? '0').toString()) ?? 0,
      sourceType: json['source_type']?.toString() ?? json[4]?.toString() ?? '',
      supplierId:
          int.tryParse((json['supplier_id'] ?? json[5] ?? '0').toString()) ?? 0,
      customerId:
          int.tryParse((json['customer_id'] ?? json[6] ?? '0').toString()) ?? 0,
      customerType: (json['customer_type'] ?? json[7] ?? 'unknown')
          .toString()
          .toLowerCase(),
      customerPersonId: int.tryParse(
              (json['customer_person_id'] ?? json[8] ?? '0').toString()) ??
          0,
      sellerId:
          int.tryParse((json['seller_id'] ?? json[9] ?? '0').toString()) ?? 0,
      documentAmount: documentAmount,
      issueDate: DateTime.tryParse(issueDateStr.toString()) ?? DateTime.now(),
      dueDate: json['due_date'] != null
          ? DateTime.tryParse(json['due_date'].toString())
          : null,
      totalPaid: totalPaid,
      totalDeposited: totalDeposited,
      additionalFees: additionalFees,
      outstandingBalance: outstanding,
      documentStatus:
          json['document_status']?.toString() ?? json[18]?.toString() ?? '',
      paymentStatus:
          json['payment_status']?.toString() ?? json[19]?.toString() ?? '',
      daysIssued:
          int.tryParse((json['days_issued'] ?? json[21] ?? '0').toString()) ??
              0,
      createdAt: DateTime.tryParse(createdAtStr.toString()) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(updatedAtStr.toString()) ?? DateTime.now(),
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

  bool get isPaid => paymentStatus.contains('paid') || outstandingBalance <= 0;
  bool get isUnpaid => paymentStatus.contains('unpaid');
  bool get isPartiallyPaid => paymentStatus.contains('partially_paid');
  bool get isFullyPaid => paymentStatus.contains('fully_paid');
  bool get isCanceled => documentStatus == 'canceled';

  bool get isOverdue => daysOverdue > 0 && totalReceived < documentAmount;

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

// Payment Class
class Payment {
  int paymentId;
  int paymentInvoiceId;
  double paymentAmount;
  String paymentMethod;
  String paymentStatus;
  String paymentReference;
  String paymentNotes;

  Payment({
    required this.paymentId,
    required this.paymentInvoiceId,
    required this.paymentAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.paymentReference,
    required this.paymentNotes,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      paymentId: json['payment_id'] ?? 0,
      paymentInvoiceId: json['payment_invoice_id'] ?? 0,
      paymentAmount: (json['payment_amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['payment_method'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      paymentReference: json['payment_reference'] ?? '',
      paymentNotes: json['payment_notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_id': paymentId,
      'payment_invoice_id': paymentInvoiceId,
      'payment_amount': paymentAmount,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'payment_reference': paymentReference,
      'payment_notes': paymentNotes,
    };
  }

  factory Payment.create({
    required double amount,
    required String method,
    int invoiceId = 0,
    String status = 'pending',
    String reference = '',
    String notes = '',
  }) {
    return Payment(
      paymentId: 0, // Will be set by server
      paymentInvoiceId: invoiceId,
      paymentAmount: amount,
      paymentMethod: method,
      paymentStatus: status,
      paymentReference: reference,
      paymentNotes: notes,
    );
  }
}

// Deposit Class
class Deposit {
  int depositId;
  double depositAmount;
  String depositMethod;
  int depositCartId;
  int depositInvoiceId;
  String depositReference;
  String depositNotes;
  int depositReceiptId;

  Deposit({
    required this.depositId,
    required this.depositAmount,
    required this.depositMethod,
    required this.depositCartId,
    required this.depositInvoiceId,
    required this.depositReference,
    required this.depositNotes,
    required this.depositReceiptId,
  });

  factory Deposit.fromJson(Map<String, dynamic> json) {
    return Deposit(
      depositId: json['deposit_id'] ?? 0,
      depositAmount: (json['deposit_amount'] as num?)?.toDouble() ?? 0.0,
      depositMethod: json['deposit_method'] ?? '',
      depositCartId: json['deposit_cart_id'] ?? 0,
      depositInvoiceId: json['deposit_invoice_id'] ?? 0,
      depositReference: json['deposit_reference'] ?? '',
      depositNotes: json['deposit_notes'] ?? '',
      depositReceiptId: json['deposit_receipt_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deposit_id': depositId,
      'deposit_amount': depositAmount,
      'deposit_method': depositMethod,
      'deposit_cart_id': depositCartId,
      'deposit_invoice_id': depositInvoiceId,
      'deposit_reference': depositReference,
      'deposit_notes': depositNotes,
      'deposit_receipt_id': depositReceiptId,
    };
  }

  factory Deposit.create({
    required double amount,
    required String method,
    int cartId = 0,
    int invoiceId = 0,
    String reference = '',
    String notes = '',
    int receiptId = 0,
  }) {
    return Deposit(
      depositId: 0, // Will be set by server
      depositAmount: amount,
      depositMethod: method,
      depositCartId: cartId,
      depositInvoiceId: invoiceId,
      depositReference: reference,
      depositNotes: notes,
      depositReceiptId: receiptId,
    );
  }
}

// Additional Fee Class
class AdditionalFee {
  int additionalFeeId;
  int additionalFeePaymentId;
  String additionalFeeName;
  double additionalFeeAmount;
  String additionalFeeDescription;
  String additionalFeeDocumentUrl;
  int additionalFeeUserId;
  int additionalFeeOnProviderId;

  AdditionalFee({
    required this.additionalFeeId,
    required this.additionalFeePaymentId,
    required this.additionalFeeName,
    required this.additionalFeeAmount,
    required this.additionalFeeDescription,
    required this.additionalFeeDocumentUrl,
    required this.additionalFeeUserId,
    required this.additionalFeeOnProviderId,
  });

  factory AdditionalFee.fromJson(Map<String, dynamic> json) {
    return AdditionalFee(
      additionalFeeId: json['additional_fee_id'] ?? 0,
      additionalFeePaymentId: json['additional_fee_payment_id'] ?? 0,
      additionalFeeName: json['additional_fee_name'] ?? '',
      additionalFeeAmount:
          (json['additional_fee_amount'] as num?)?.toDouble() ?? 0.0,
      additionalFeeDescription: json['additional_fee_description'] ?? '',
      additionalFeeDocumentUrl: json['additional_fee_document_url'] ?? '',
      additionalFeeUserId: json['additional_fee_user_id'] ?? 0,
      additionalFeeOnProviderId: json['additional_fee_on_provider_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'additional_fee_id': additionalFeeId,
      'additional_fee_payment_id': additionalFeePaymentId,
      'additional_fee_name': additionalFeeName,
      'additional_fee_amount': additionalFeeAmount,
      'additional_fee_description': additionalFeeDescription,
      'additional_fee_document_url': additionalFeeDocumentUrl,
      'additional_fee_user_id': additionalFeeUserId,
      'additional_fee_on_provider_id': additionalFeeOnProviderId,
    };
  }

  factory AdditionalFee.create({
    required int paymentId,
    required String name,
    required double amount,
    String description = '',
    String documentUrl = '',
    int userId = 0,
    int onProviderId = 0,
  }) {
    return AdditionalFee(
      additionalFeeId: 0, // Will be set by server
      additionalFeePaymentId: paymentId,
      additionalFeeName: name,
      additionalFeeAmount: amount,
      additionalFeeDescription: description,
      additionalFeeDocumentUrl: documentUrl,
      additionalFeeUserId: userId,
      additionalFeeOnProviderId: onProviderId,
    );
  }
}

// Payment Request Wrapper (to match your existing code)
class PaymentRequest {
  final String type;
  final double amount;
  final String notes;
  final int? documentId;
  final String? date;

  PaymentRequest({
    required this.type,
    required this.amount,
    required this.notes,
    this.documentId,
    this.date,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'type': type,
      'amount': amount,
      'notes': notes,
    };

    if (documentId != null) {
      data['document_id'] = documentId;
    }

    if (date != null) {
      data['date'] = date;
    }

    return data;
  }
}
