// payment_list_screen.dart
import 'package:flutter/material.dart';
import 'package:gluttex_ui/components/finance/payment_list_item.dart';
import 'package:gluttex_ui/screens/payment_form_screen.dart';

class PaymentListScreen extends StatefulWidget {
  const PaymentListScreen({Key? key}) : super(key: key);

  @override
  _PaymentListScreenState createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends State<PaymentListScreen> {
  List<Map<String, dynamic>> _payments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    // TODO: Load payments from API
    setState(() => _isLoading = true);

    // Mock data for demonstration
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _payments = [
        {
          'payment': {
            'payment_id': 1,
            'payment_invoice_id': 1001,
            'payment_amount': 1500.00,
            'payment_method': 'Credit Card',
            'payment_status': 'Completed',
            'payment_reference': 'REF-001',
            'payment_notes': 'First payment',
          },
          'deposit': {
            'deposit_id': 1,
            'deposit_amount': 500.00,
            'deposit_method': 'Bank Transfer',
            'deposit_reference': 'DEP-001',
          },
        },
        {
          'payment': {
            'payment_id': 2,
            'payment_invoice_id': 1002,
            'payment_amount': 750.50,
            'payment_method': 'Cash',
            'payment_status': 'Pending',
            'payment_reference': 'REF-002',
          },
        },
      ];
      _isLoading = false;
    });
  }

  void _addNewPayment() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PaymentFormScreen(),
      ),
    );

    if (result == true) {
      _loadPayments(); // Refresh list
    }
  }

  void _editPayment(Map<String, dynamic> payment) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentFormScreen(
          initialData: payment,
          isEditing: true,
        ),
      ),
    );

    if (result == true) {
      _loadPayments(); // Refresh list
    }
  }

  void _deletePayment(int paymentId) async {
    // TODO: Implement delete API call
    setState(() {
      _payments.removeWhere((p) => p['payment']['payment_id'] == paymentId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPayments,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _payments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.payment, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No Payments Found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Add your first payment',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _addNewPayment,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Payment'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPayments,
                  child: ListView.builder(
                    itemCount: _payments.length,
                    itemBuilder: (context, index) {
                      final payment = _payments[index];
                      return PaymentListItem(
                        payment: payment,
                        onTap: () => _editPayment(payment),
                        onEdit: () => _editPayment(payment),
                        onDelete: () => _deletePayment(
                          payment['payment']['payment_id'],
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewPayment,
        tooltip: 'Add Payment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
