import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/finance/FinancialDocument.dart';
import 'package:gluttex_ui/components/finance/StunningFeeSection.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentFormScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final FinancialDocument? sourceDocument; // Add this
  final bool isEditing;

  const PaymentFormScreen({
    Key? key,
    this.initialData,
    this.sourceDocument, // Add this parameter
    this.isEditing = false,
  }) : super(key: key);

  @override
  _PaymentFormScreenState createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Payment Fields
  int _paymentId = 0;
  int _paymentInvoiceId = 0;
  double _paymentAmount = 0.0;
  String _paymentMethod = '';
  String _paymentStatus = '';
  String _paymentReference = '';
  String _paymentNotes = '';

  // Deposit Fields
  int _depositId = 0;
  double _depositAmount = 0.0;
  String _depositMethod = '';
  int _depositCartId = 0;
  int _depositInvoiceId = 0;
  String _depositReference = '';
  String _depositNotes = '';
  int _depositReceiptId = 0;

  // Fee Data
  Map<String, dynamic> _feeData = {};

  bool _isLoading = false;
  bool _showAdvanced = false;
  bool _autoFillEnabled = true;

  final List<String> _paymentMethods = [
    'Cash',
    'Credit Card',
    'Debit Card',
    'Bank Transfer',
    'Check',
    'Mobile Payment',
    'Online Payment',
    'Other'
  ];

  final List<String> _paymentStatuses = [
    'Pending',
    'Completed',
    'Failed',
    'Refunded',
    'Partially Paid',
    'Cancelled'
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    if (widget.sourceDocument != null && _autoFillEnabled) {
      _autoFillFromDocument();
    }
  }

  void _autoFillFromDocument() {
    final doc = widget.sourceDocument!;

    // Auto-fill payment amount with outstanding balance
    _paymentAmount = doc.outstandingBalance;

    // Auto-fill invoice ID from document
    if (doc.documentType == 'invoice') {
      _paymentInvoiceId = doc.documentId;
    }

    // Auto-set payment status based on document
    if (doc.paymentStatus.toLowerCase() == 'pending') {
      _paymentStatus = 'Pending';
    } else if (doc.outstandingBalance <= 0) {
      _paymentStatus = 'Completed';
    } else if (doc.daysOverdue > 0) {
      _paymentStatus = 'Overdue';
    }

    // Auto-generate reference
    _paymentReference = 'PAY-${DateTime.now().millisecondsSinceEpoch}';

    setState(() {});
  }

  void _loadInitialData() {
    if (widget.isEditing && widget.initialData != null) {
      final data = widget.initialData!;

      if (data['payment'] != null) {
        final payment = data['payment'];
        _paymentId = payment['payment_id'] ?? 0;
        _paymentInvoiceId = payment['payment_invoice_id'] ?? 0;
        _paymentAmount = (payment['payment_amount'] ?? 0).toDouble();
        _paymentMethod = payment['payment_method'] ?? '';
        _paymentStatus = payment['payment_status'] ?? '';
        _paymentReference = payment['payment_reference'] ?? '';
        _paymentNotes = payment['payment_notes'] ?? '';
      }

      if (data['deposit'] != null) {
        final deposit = data['deposit'];
        _depositId = deposit['deposit_id'] ?? 0;
        _depositAmount = (deposit['deposit_amount'] ?? 0).toDouble();
        _depositMethod = deposit['deposit_method'] ?? '';
        _depositCartId = deposit['deposit_cart_id'] ?? 0;
        _depositInvoiceId = deposit['deposit_invoice_id'] ?? 0;
        _depositReference = deposit['deposit_reference'] ?? '';
        _depositNotes = deposit['deposit_notes'] ?? '';
        _depositReceiptId = deposit['deposit_receipt_id'] ?? 0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Payment' : 'New Payment'),
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmDelete,
              tooltip: 'Delete Payment',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Form(
                key: _formKey,
                child: Scrollbar(
                  controller: _scrollController,
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Source Document Info (if available)
                              if (widget.sourceDocument != null)
                                _buildSourceDocumentCard(),

                              const SizedBox(height: 20),

                              // Main Payment Section
                              _buildPaymentSection(),

                              const SizedBox(height: 20),

                              // Deposit Section
                              _buildDepositSection(),

                              const SizedBox(height: 20),

                              // Advanced Options Toggle
                              _buildAdvancedToggle(),

                              const SizedBox(height: 20),

                              // Additional Fees Section (Conditional)
                              if (_showAdvanced)
                                StunningFeeSection(
                                  isEditing: widget.isEditing,
                                  initialFeeData: widget.initialData?['fee'],
                                  onFeeChanged: (feeData) {
                                    setState(() => _feeData = feeData);
                                  },
                                ),

                              const SizedBox(height: 30),

                              // Action Buttons
                              _buildActionButtons(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSourceDocumentCard() {
    final doc = widget.sourceDocument!;
    AppLocalizations loc = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.blue.shade100.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getDocumentColor(doc.documentType)
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getDocumentIcon(doc.documentType),
                        color: _getDocumentColor(doc.documentType),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.documentType.toUpperCase(),
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                        ),
                        Text(
                          doc.documentNumber,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(doc.paymentStatus).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          _getStatusColor(doc.paymentStatus).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    doc.paymentStatus.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(doc.paymentStatus),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Document Summary
            Row(
              children: [
                Expanded(
                  child: _buildDocumentStat(
                    label: 'Total Amount',
                    value: loc.price(doc.documentAmount.toStringAsFixed(2)),
                    color: Colors.blue.shade700,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.blue.shade200,
                ),
                Expanded(
                  child: _buildDocumentStat(
                    label: 'Paid',
                    value: loc.price(doc.totalPaid.toStringAsFixed(2)),
                    color: Colors.green.shade700,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.blue.shade200,
                ),
                Expanded(
                  child: _buildDocumentStat(
                    label: 'Balance',
                    value: loc.price(doc.outstandingBalance.toStringAsFixed(2)),
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Auto-fill toggle
            Row(
              children: [
                Switch(
                  value: _autoFillEnabled,
                  onChanged: (value) {
                    setState(() => _autoFillEnabled = value);
                    if (value) {
                      _autoFillFromDocument();
                    }
                  },
                  activeColor: Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  'Auto-fill from document',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.blue.shade700,
                      ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    setState(() => _paymentAmount = doc.outstandingBalance);
                  },
                  icon: const Icon(Icons.attach_money, size: 16),
                  label: const Text('Fill Balance'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentStat({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.blue.shade600,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.payment, color: Colors.blue, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Payment Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.blue.shade800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Payment ID (Read-only if editing)
            if (widget.isEditing)
              _buildReadOnlyField(
                'Payment ID',
                _paymentId.toString(),
                icon: Icons.fingerprint,
              ),

            const SizedBox(height: 16),

            // Invoice ID with document context
            _buildSmartInvoiceField(),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildAmountField(
                    label: 'Payment Amount',
                    value: _paymentAmount,
                    onChanged: (value) =>
                        setState(() => _paymentAmount = value),
                    isRequired: true,
                    maxAmount: widget.sourceDocument?.outstandingBalance,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdownField(
                    label: 'Payment Method',
                    value: _paymentMethod,
                    items: _paymentMethods,
                    onChanged: (value) =>
                        setState(() => _paymentMethod = value!),
                    icon: Icons.credit_card,
                    isRequired: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildDropdownField(
              label: 'Payment Status',
              value: _paymentStatus,
              items: _paymentStatuses,
              onChanged: (value) => setState(() => _paymentStatus = value!),
              icon: Icons.notifications,
              isRequired: true,
            ),

            const SizedBox(height: 16),

            _buildTextField(
              label: 'Reference Number',
              value: _paymentReference,
              onChanged: (value) => setState(() => _paymentReference = value),
              icon: Icons.tag,
              hintText: 'PAY-2024-001',
            ),

            const SizedBox(height: 16),

            _buildTextAreaField(
              label: 'Payment Notes',
              value: _paymentNotes,
              onChanged: (value) => setState(() => _paymentNotes = value),
              icon: Icons.notes,
              hintText: 'Enter any notes about this payment...',
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmartInvoiceField() {
    final doc = widget.sourceDocument;
    final isInvoice = doc?.documentType == 'invoice';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          initialValue:
              _paymentInvoiceId == 0 ? '' : _paymentInvoiceId.toString(),
          decoration: InputDecoration(
            labelText: 'Invoice ID',
            prefixIcon: const Icon(Icons.receipt, color: Colors.blue),
            suffixIcon: isInvoice
                ? IconButton(
                    icon: const Icon(Icons.auto_fix_high, size: 20),
                    onPressed: () {
                      setState(() => _paymentInvoiceId = doc!.documentId);
                    },
                    tooltip: 'Use document ID',
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter Invoice ID';
            }
            return null;
          },
          onSaved: (value) {
            _paymentInvoiceId = int.tryParse(value ?? '0') ?? 0;
          },
          onChanged: (value) {
            setState(() => _paymentInvoiceId = int.tryParse(value) ?? 0);
          },
        ),
        if (isInvoice) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.info, size: 14, color: Colors.blue),
              const SizedBox(width: 4),
              Text(
                'This document is an invoice (ID: ${doc!.documentId})',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDepositSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance_wallet,
                    color: Colors.green, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Deposit Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.green.shade800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (widget.isEditing)
              _buildReadOnlyField(
                'Deposit ID',
                _depositId.toString(),
                icon: Icons.fingerprint,
              ),
            if (widget.isEditing) const SizedBox(height: 16),
            _buildAmountField(
              label: 'Deposit Amount',
              value: _depositAmount,
              onChanged: (value) => setState(() => _depositAmount = value),
              icon: Icons.monetization_on,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDropdownField(
                    label: 'Deposit Method',
                    value: _depositMethod,
                    items: _paymentMethods,
                    onChanged: (value) =>
                        setState(() => _depositMethod = value!),
                    icon: Icons.payment,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildNumberField(
                    label: 'Cart ID',
                    value: _depositCartId,
                    onChanged: (value) =>
                        setState(() => _depositCartId = value),
                    icon: Icons.shopping_cart,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildNumberField(
                    label: 'Invoice ID',
                    value: _depositInvoiceId,
                    onChanged: (value) =>
                        setState(() => _depositInvoiceId = value),
                    icon: Icons.receipt,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildNumberField(
                    label: 'Receipt ID',
                    value: _depositReceiptId,
                    onChanged: (value) =>
                        setState(() => _depositReceiptId = value),
                    icon: Icons.description,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Deposit Reference',
              value: _depositReference,
              onChanged: (value) => setState(() => _depositReference = value),
              icon: Icons.tag,
              hintText: 'DEP-2024-001',
            ),
            const SizedBox(height: 16),
            _buildTextAreaField(
              label: 'Deposit Notes',
              value: _depositNotes,
              onChanged: (value) => setState(() => _depositNotes = value),
              icon: Icons.notes,
              hintText: 'Enter any notes about this deposit...',
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedToggle() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: _showAdvanced ? Colors.blue.shade50 : Colors.grey.shade50,
        border: Border.all(
          color: _showAdvanced ? Colors.blue.shade200 : Colors.grey.shade300,
        ),
      ),
      child: ListTile(
        onTap: () {
          setState(() => _showAdvanced = !_showAdvanced);
        },
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _showAdvanced ? Colors.blue.shade100 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.attach_money,
            color: _showAdvanced ? Colors.blue : Colors.grey.shade700,
          ),
        ),
        title: Text(
          'Additional Fees',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: _showAdvanced ? Colors.blue.shade800 : Colors.grey.shade800,
          ),
        ),
        subtitle: Text(
          _showAdvanced ? 'Hide fee options' : 'Show fee options',
          style: TextStyle(
            color: _showAdvanced ? Colors.blue.shade600 : Colors.grey.shade600,
          ),
        ),
        trailing: Icon(
          _showAdvanced ? Icons.expand_less : Icons.expand_more,
          color: _showAdvanced ? Colors.blue : Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _resetForm,
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text('Reset Form'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitForm,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        widget.isEditing ? Icons.update : Icons.check_circle,
                        size: 20,
                      ),
                label: Text(
                  widget.isEditing ? 'Update Payment' : 'Create Payment',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (widget.sourceDocument != null)
          TextButton(
            onPressed: () {
              // Show document details modal
              _showDocumentDetails();
            },
            child: Text(
              'View Full Document Details',
              style: TextStyle(color: Colors.blue.shade600),
            ),
          ),
      ],
    );
  }

  // Helper Methods for Document UI
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  IconData _getDocumentIcon(String documentType) {
    switch (documentType) {
      case 'invoice':
        return Icons.receipt_long;
      case 'deposit':
        return Icons.account_balance_wallet;
      case 'receipt':
        return Icons.description;
      case 'pending_cart':
        return Icons.shopping_cart;
      default:
        return Icons.document_scanner;
    }
  }

  Color _getDocumentColor(String documentType) {
    switch (documentType) {
      case 'invoice':
        return const Color(0xFF667EEA);
      case 'deposit':
        return const Color(0xFF10B981);
      case 'receipt':
        return const Color(0xFFF59E0B);
      case 'pending_cart':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF6B7280);
    }
  }

  // Reusable Form Field Widgets (updated versions)
  Widget _buildNumberField({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
    IconData? icon,
    bool isRequired = false,
  }) {
    return TextFormField(
      initialValue: value == 0 ? '' : value.toString(),
      decoration: InputDecoration(
        labelText: '$label${isRequired ? ' *' : ''}',
        prefixIcon: icon != null ? Icon(icon, color: Colors.blue) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade600),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'Please enter $label';
        }
        return null;
      },
      onSaved: (value) {
        onChanged(int.tryParse(value ?? '0') ?? 0);
      },
      onChanged: (value) {
        onChanged(int.tryParse(value) ?? 0);
      },
    );
  }

  Widget _buildAmountField({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
    IconData? icon,
    bool isRequired = false,
    double? maxAmount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          initialValue: value == 0 ? '' : value.toStringAsFixed(2),
          decoration: InputDecoration(
            labelText: '$label${isRequired ? ' *' : ''}',
            prefixIcon: icon != null ? Icon(icon, color: Colors.blue) : null,
            suffixText: 'USD',
            suffixStyle: const TextStyle(color: Colors.blue),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade600),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'Please enter $label';
            }
            if (value != null && value.isNotEmpty) {
              final amount = double.tryParse(value);
              if (amount == null) {
                return 'Please enter a valid amount';
              }
              if (amount < 0) {
                return 'Amount cannot be negative';
              }
              if (maxAmount != null && amount > maxAmount) {
                return 'Amount exceeds outstanding balance (DZD$maxAmount)';
              }
            }
            return null;
          },
          onSaved: (value) {
            onChanged(double.tryParse(value ?? '0') ?? 0.0);
          },
          onChanged: (value) {
            onChanged(double.tryParse(value) ?? 0.0);
          },
        ),
        if (maxAmount != null && value > maxAmount) ...[
          const SizedBox(height: 4),
          Text(
            '⚠️ Amount exceeds outstanding balance by DZD${(value - maxAmount).toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.orange, fontSize: 12),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
    IconData? icon,
    String? hintText,
    bool isRequired = false,
  }) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        labelText: '$label${isRequired ? ' *' : ''}',
        hintText: hintText,
        prefixIcon: icon != null ? Icon(icon, color: Colors.blue) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade600),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'Please enter $label';
        }
        return null;
      },
      onSaved: (value) {
        onChanged(value ?? '');
      },
      onChanged: onChanged,
    );
  }

  Widget _buildTextAreaField({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
    IconData? icon,
    String? hintText,
    int maxLines = 3,
    bool isRequired = false,
  }) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        labelText: '$label${isRequired ? ' *' : ''}',
        hintText: hintText,
        prefixIcon: icon != null ? Icon(icon, color: Colors.blue) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade600),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        alignLabelWithHint: true,
      ),
      maxLines: maxLines,
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'Please enter $label';
        }
        return null;
      },
      onSaved: (value) {
        onChanged(value ?? '');
      },
      onChanged: onChanged,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    IconData? icon,
    bool isRequired = false,
  }) {
    return DropdownButtonFormField<String>(
      value: value.isEmpty ? null : value,
      decoration: InputDecoration(
        labelText: '$label${isRequired ? ' *' : ''}',
        prefixIcon: icon != null ? Icon(icon, color: Colors.blue) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
      ),
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('Select...', style: TextStyle(color: Colors.grey)),
        ),
        ...items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
      ],
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'Please select $label';
        }
        return null;
      },
      onChanged: onChanged,
      onSaved: (value) {
        onChanged(value);
      },
      style: const TextStyle(color: Colors.black87),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
    );
  }

  Widget _buildReadOnlyField(String label, String value, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
              ],
              Text(
                value,
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      final requestData = {
        "payment": {
          "payment_id": _paymentId,
          "payment_invoice_id": _paymentInvoiceId,
          "payment_amount": _paymentAmount,
          "payment_method": _paymentMethod,
          "payment_status": _paymentStatus,
          "payment_reference": _paymentReference,
          "payment_notes": _paymentNotes,
        },
        "deposit": {
          "deposit_id": _depositId,
          "deposit_amount": _depositAmount,
          "deposit_method": _depositMethod,
          "deposit_cart_id": _depositCartId,
          "deposit_invoice_id": _depositInvoiceId,
          "deposit_reference": _depositReference,
          "deposit_notes": _depositNotes,
          "deposit_receipt_id": _depositReceiptId,
        },
        "fee": _feeData.isEmpty
            ? {
                "additional_fee_id": 0,
                "additional_fee_payment_id": 0,
                "additional_fee_name": "",
                "additional_fee_amount": 0,
                "additional_fee_description": "",
                "additional_fee_document_url": "",
                "additional_fee_user_id": 0,
                "additional_fee_on_provider_id": 0,
              }
            : _feeData,
      };

      final url = widget.isEditing
          ? 'https://your-api.com/payments/update'
          : 'https://your-api.com/payments/create';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_TOKEN',
        },
        body: json.encode(requestData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessDialog();
      } else {
        _showErrorDialog('Failed to save payment: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 12),
            const Text('Success'),
          ],
        ),
        content: Text(widget.isEditing
            ? 'Payment updated successfully!'
            : 'Payment created successfully!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 12),
            const Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDocumentDetails() {
    final doc = widget.sourceDocument!;
    AppLocalizations loc = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 60,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Document Details',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      _buildDetailRow('Document Type', doc.documentType),
                      _buildDetailRow('Document Number', doc.documentNumber),
                      _buildDetailRow('Document ID', doc.documentId.toString()),
                      _buildDetailRow(
                        'Total Amount',
                        loc.price(doc.documentAmount.toStringAsFixed(2)),
                      ),
                      _buildDetailRow(
                          'Paid', loc.price(doc.totalPaid.toStringAsFixed(2))),
                      _buildDetailRow(
                        'Deposited',
                        loc.price(doc.totalDeposited.toStringAsFixed(2)),
                      ),
                      _buildDetailRow(
                        'Outstanding Balance',
                        loc.price(doc.outstandingBalance.toStringAsFixed(2)),
                      ),
                      _buildDetailRow(
                        'Additional Fees',
                        loc.price(doc.additionalFees.toStringAsFixed(2)),
                      ),
                      _buildDetailRow('Issue Date', _formatDate(doc.issueDate)),
                      if (doc.dueDate != null)
                        _buildDetailRow('Due Date', _formatDate(doc.dueDate!)),
                      _buildDetailRow('Days Issued', doc.daysIssued.toString()),
                      if (doc.daysOverdue > 0)
                        _buildDetailRow(
                            'Days Overdue', doc.daysOverdue.toString()),
                      _buildDetailRow('Payment Status', doc.paymentStatus),
                      _buildDetailRow('Customer ID', doc.customerId.toString()),
                      _buildDetailRow('Supplier ID', doc.supplierId.toString()),
                      _buildDetailRow('Created', _formatDate(doc.createdAt)),
                      _buildDetailRow(
                          'Last Updated', _formatDate(doc.updatedAt)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      _paymentId = 0;
      _paymentInvoiceId = 0;
      _paymentAmount = 0.0;
      _paymentMethod = '';
      _paymentStatus = '';
      _paymentReference = '';
      _paymentNotes = '';

      _depositId = 0;
      _depositAmount = 0.0;
      _depositMethod = '';
      _depositCartId = 0;
      _depositInvoiceId = 0;
      _depositReference = '';
      _depositNotes = '';
      _depositReceiptId = 0;

      _feeData = {};
    });
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this payment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: _deletePayment,
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deletePayment() async {
    try {
      setState(() => _isLoading = true);
      // Your delete logic here
    } catch (e) {
      _showErrorDialog('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
