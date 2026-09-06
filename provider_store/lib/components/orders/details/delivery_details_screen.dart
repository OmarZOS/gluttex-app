import 'package:flutter/material.dart';
import 'package:gluttex_core/business/Delivery.dart';
import 'package:event/delivery_change_notifier.dart';
import 'package:provider_store/components/delivery/NewDeliverySheet.dart';

// ============================================================================
// DELIVERY DETAIL SCREEN - ORDER VALIDATION
// ============================================================================

class DeliveryDetailScreen extends StatelessWidget {
  final Delivery delivery;
  final DeliveryChangeNotifier notifier;

  const DeliveryDetailScreen({
    super.key,
    required this.delivery,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    final statusConfig =
        DeliveryStatusConfig.fromStatus(delivery.delivery_status);

    return Scaffold(
      appBar: _buildAppBar(context, notifier),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatusHeader(delivery: delivery, config: statusConfig),
            const SizedBox(height: 20),
            _OrderSummary(delivery: delivery),
            const SizedBox(height: 16),
            _DeliveryDetails(delivery: delivery),
            if (delivery.canBeUpdated) ...[
              const SizedBox(height: 20),
              _ActionButtons(delivery: delivery, notifier: notifier),
            ],
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, DeliveryChangeNotifier notifier) {
    return AppBar(
      title: Text(
          'Order #${delivery.delivery_invoice_ref ?? delivery.id_delivery}'),
      actions: [
        if (delivery.canBeUpdated)
          PopupMenuButton<String>(
            onSelected: (value) => _handleAction(context, value, notifier),
            itemBuilder: (_) => [
              if (delivery.canBeCancelled)
                const PopupMenuItem(
                  value: 'cancel',
                  child: Row(
                    children: [
                      Icon(Icons.cancel_outlined, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Cancel Order'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('Edit Delivery'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('Refresh'),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  void _handleAction(
      BuildContext context, String action, DeliveryChangeNotifier notifier) {
    switch (action) {
      case 'cancel':
        _showCancelDialog(context, notifier);
        break;
      case 'refresh':
        notifier.refreshDelivery(delivery.id_delivery);
        _showSnackBar(context, 'Refreshing...');
        break;
      case 'edit':
        _showEditSheet(context, notifier);
        break;
    }
  }

  void _showEditSheet(BuildContext context, DeliveryChangeNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NewDeliverySheet(
        notifier: notifier,
        providerId: delivery.delivery_provider_id ?? notifier.currentProviderId,
        delivery: delivery,
      ),
    );
  }

  void _showCancelDialog(
      BuildContext context, DeliveryChangeNotifier notifier) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Order'),
        content: Text(
            'Cancel order #${delivery.delivery_invoice_ref ?? delivery.id_delivery}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(_), child: const Text('No')),
          TextButton(
            onPressed: () async {
              Navigator.pop(_);
              final success =
                  await notifier.cancelDelivery(delivery.id_delivery);
              _showSnackBar(
                  context, success ? 'Order cancelled' : 'Failed to cancel',
                  isError: !success);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ============================================================================
// STATUS HEADER
// ============================================================================

class _StatusHeader extends StatelessWidget {
  final Delivery delivery;
  final DeliveryStatusConfig config;

  const _StatusHeader({required this.delivery, required this.config});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: config.color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: config.color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(config.icon, color: config.color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status',
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                Text(
                  config.label,
                  style: TextStyle(
                    color: config.color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (delivery.delivery_fee != null)
            Text(
              '${delivery.formattedFee}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: config.color,
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// ORDER SUMMARY
// ============================================================================

class _OrderSummary extends StatelessWidget {
  final Delivery delivery;

  const _OrderSummary({required this.delivery});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_rounded,
                  size: 20, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              Text(
                'Order Summary',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const Divider(height: 20),
          _SummaryRow(
            label: 'Order ID',
            value: '#${delivery.delivery_invoice_ref ?? delivery.id_delivery}',
          ),
          _SummaryRow(
            label: 'Shipping',
            value: delivery.shippingMethodLabel,
          ),
          if (delivery.delivery_package_count != null)
            _SummaryRow(
              label: 'Packages',
              value: delivery.formattedPackageCount,
            ),
          if (delivery.delivery_total_weight != null)
            _SummaryRow(
              label: 'Weight',
              value: delivery.formattedWeight,
            ),
          if (delivery.delivery_address_id != null)
            _SummaryRow(
              label: 'Address ID',
              value: '#${delivery.delivery_address_id}',
            ),
          const Divider(height: 20),
          _SummaryRow(
            label: 'Total',
            value: delivery.formattedFee,
            isTotal: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 15 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              color: isTotal ? Colors.black : Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isTotal ? Colors.green.shade700 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DELIVERY DETAILS
// ============================================================================

class _DeliveryDetails extends StatelessWidget {
  final Delivery delivery;

  const _DeliveryDetails({required this.delivery});

  @override
  Widget build(BuildContext context) {
    final details = <MapEntry<String, String>>[];

    void add(String label, dynamic value) {
      if (value == null) return;
      final text = value.toString();
      if (text.isNotEmpty) details.add(MapEntry(label, text));
    }

    add('Delivery ID', delivery.id_delivery);
    add('Recipient Person ID', delivery.recipient_person);
    add('Recipient Provider ID', delivery.recipient_provider);
    add('Package Count', delivery.delivery_package_count);
    add('Total Weight', delivery.formattedWeight);
    add('Cargo Dimensions', delivery.delivery_cargo_dimensions);
    add('Goods Description', delivery.delivery_goods_description);
    add('HS Code', delivery.hs_code);
    add('Merchant Name', delivery.delivery_merchant_name);
    add('Shipping Method', delivery.delivery_shipping_method);
    add('Special Instructions', delivery.delivery_special_instructions);
    add('Status', delivery.statusLabel);
    add('Delivery Address ID', delivery.delivery_address_id);
    add('Current Address ID', delivery.delivery_current_address_id);
    add('Delivery Fee', delivery.formattedFee);
    add('Invoice Reference', delivery.delivery_invoice_ref);
    add('Provider ID', delivery.delivery_provider_id);
    add('Broker ID', delivery.delivery_broker_id);
    add('Source Type', delivery.delivery_source_type);
    add('Source ID', delivery.delivery_source_id);
    if (delivery.delivery_created_at != null) {
      add('Created', _formatDate(delivery.delivery_created_at!));
    }
    if (delivery.delivery_updated_at != null) {
      add('Updated', _formatDate(delivery.delivery_updated_at!));
    }

    final provider = delivery.delivery_provider;
    if (provider != null) {
      add('Provider Name', provider.displayName);
      add('Provider Address', provider.fullAddress);
      add('Provider Organisation', provider.providerOrganisationName);
    }

    final address = delivery.delivery_address;
    if (address != null) {
      add('Address', address.fullAddress);
    }

    final invoice = delivery.invoice;
    if (invoice != null) {
      add('Invoice ID', invoice.invoiceId);
      add('Invoice Number', invoice.invoiceNumber);
      add('Invoice Type', invoice.invoiceType);
      add('Invoice Status', invoice.invoiceStatus);
      add('Invoice Total', invoice.formattedTotal);
      add('Invoice Due Date', invoice.invoiceDueDate);
      add('Invoice Issue Date', invoice.invoiceIssueDate);
      add('Invoice Notes', invoice.invoiceNotes);
      if (invoice.invoiceCreatedAt != null) {
        add('Invoice Created', _formatDate(invoice.invoiceCreatedAt!));
      }
      if (invoice.invoiceUpdatedAt != null) {
        add('Invoice Updated', _formatDate(invoice.invoiceUpdatedAt!));
      }
      add('Invoice Tax Applied', invoice.invoiceTaxApplied);
      add('Invoice Cart Items', invoice.cart?.length);
      add('Invoice Order Items', invoice.placedOrder?.length);
    }

    if (delivery.delivery_broker != null) {
      delivery.delivery_broker!.forEach((key, value) {
        add('Broker $key', value);
      });
    }

    if (details.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Details',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          ...details.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(
                        e.key,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        e.value,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ============================================================================
// ACTION BUTTONS
// ============================================================================

class _ActionButtons extends StatelessWidget {
  final Delivery delivery;
  final DeliveryChangeNotifier notifier;

  const _ActionButtons({required this.delivery, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (delivery.canBeCancelled)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _cancel(context),
              icon: const Icon(Icons.close_rounded, size: 18),
              label: const Text('Cancel'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: Colors.red.shade300),
              ),
            ),
          ),
        if (delivery.canBeCancelled) const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _validate(context),
            icon: const Icon(Icons.check_circle_rounded, size: 18),
            label: const Text('Validate Order'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _cancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Order?'),
        content: Text(
            'Cancel order #${delivery.delivery_invoice_ref ?? delivery.id_delivery}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(_), child: const Text('No')),
          TextButton(
            onPressed: () async {
              Navigator.pop(_);
              final success =
                  await notifier.cancelDelivery(delivery.id_delivery);
              _snack(context, success ? 'Order cancelled' : 'Failed to cancel',
                  isError: !success);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _validate(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.green.shade600),
            const SizedBox(width: 8),
            const Text('Validate Order'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Order #${delivery.delivery_invoice_ref ?? delivery.id_delivery}'),
            const SizedBox(height: 8),
            Text('Total: ${delivery.formattedFee}'),
            const SizedBox(height: 8),
            Text('Status: ${delivery.statusLabel}'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(_), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(_);
              _snack(context,
                  'Order #${delivery.delivery_invoice_ref ?? delivery.id_delivery} validated!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Validation'),
          ),
        ],
      ),
    );
  }

  void _snack(BuildContext context, String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ============================================================================
// STATUS CONFIG
// ============================================================================

class DeliveryStatusConfig {
  final IconData icon;
  final Color color;
  final String label;

  const DeliveryStatusConfig({
    required this.icon,
    required this.color,
    required this.label,
  });

  factory DeliveryStatusConfig.fromStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return const DeliveryStatusConfig(
          icon: Icons.pending_outlined,
          color: Colors.orange,
          label: 'Pending',
        );
      case 'PROCESSING':
        return const DeliveryStatusConfig(
          icon: Icons.hourglass_top_rounded,
          color: Colors.blue,
          label: 'Processing',
        );
      case 'READY_FOR_PICKUP':
        return const DeliveryStatusConfig(
          icon: Icons.inventory,
          color: Colors.teal,
          label: 'Ready for Pickup',
        );
      case 'IN_TRANSIT':
        return const DeliveryStatusConfig(
          icon: Icons.local_shipping_outlined,
          color: Colors.purple,
          label: 'In Transit',
        );
      case 'OUT_FOR_DELIVERY':
        return const DeliveryStatusConfig(
          icon: Icons.delivery_dining_outlined,
          color: Colors.deepOrange,
          label: 'Out for Delivery',
        );
      case 'DELIVERED':
        return const DeliveryStatusConfig(
          icon: Icons.check_circle_outline,
          color: Colors.green,
          label: 'Delivered',
        );
      case 'FAILED':
        return const DeliveryStatusConfig(
          icon: Icons.error_outline,
          color: Colors.red,
          label: 'Failed',
        );
      case 'CANCELLED':
        return const DeliveryStatusConfig(
          icon: Icons.cancel_outlined,
          color: Colors.red,
          label: 'Cancelled',
        );
      case 'RETURNED':
        return const DeliveryStatusConfig(
          icon: Icons.assignment_return_outlined,
          color: Colors.amber,
          label: 'Returned',
        );
      default:
        return const DeliveryStatusConfig(
          icon: Icons.help_outline,
          color: Colors.grey,
          label: 'Unknown',
        );
    }
  }
}
