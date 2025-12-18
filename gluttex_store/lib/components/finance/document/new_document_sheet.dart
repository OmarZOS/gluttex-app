// lib/views/finance/widgets/new_document_sheet.dart
import 'package:flutter/material.dart';

class NewDocumentSheet extends StatelessWidget {
  final Function(String type) onCreate;

  const NewDocumentSheet({super.key, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Create New Document',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Invoice'),
            subtitle: const Text('Create a new invoice'),
            onTap: () => onCreate('invoice'),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text('Deposit'),
            subtitle: const Text('Record a deposit'),
            onTap: () => onCreate('deposit'),
          ),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text('Receipt'),
            subtitle: const Text('Issue a receipt'),
            onTap: () => onCreate('receipt'),
          ),
        ],
      ),
    );
  }
}
