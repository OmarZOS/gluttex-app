import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gluttex_core/business/Delivery.dart';
import 'package:provider/provider.dart';

class DeliveryCard extends StatelessWidget {
  final Delivery delivery;
  final String status;

  const DeliveryCard({
    super.key,
    required this.delivery,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusConfig = _getStatusConfig(status, theme);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showDeliveryDetails(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Status Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusConfig.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  statusConfig.icon,
                  color: statusConfig.color,
                ),
              ),
              const SizedBox(width: 16),
              // Delivery Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery #${delivery.id_delivery}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildInfoChip(
                          icon: Icons.inventory_2_outlined,
                          label: delivery.formattedPackageCount,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          icon: Icons.monitor_weight_outlined,
                          label: delivery.formattedWeight,
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusConfig.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: statusConfig.color.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  delivery.statusLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusConfig.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  ({IconData icon, Color color}) _getStatusConfig(
    String status,
    ThemeData theme,
  ) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return (
          icon: Icons.pending_outlined,
          color: Colors.orange,
        );
      case 'PROCESSING':
        return (
          icon: Icons.hourglass_top_rounded,
          color: Colors.blue,
        );
      case 'READY_FOR_PICKUP':
        return (
          icon: Icons.inventory,
          color: Colors.teal,
        );
      case 'IN_TRANSIT':
        return (
          icon: Icons.local_shipping_outlined,
          color: Colors.purple,
        );
      case 'OUT_FOR_DELIVERY':
        return (
          icon: Icons.delivery_dining_outlined,
          color: Colors.deepOrange,
        );
      case 'DELIVERED':
        return (
          icon: Icons.check_circle_outline,
          color: Colors.green,
        );
      case 'FAILED':
        return (
          icon: Icons.error_outline,
          color: Colors.red,
        );
      case 'CANCELLED':
        return (
          icon: Icons.cancel_outlined,
          color: Colors.red,
        );
      case 'RETURNED':
        return (
          icon: Icons.assignment_return_outlined,
          color: Colors.amber,
        );
      default:
        return (
          icon: Icons.help_outline,
          color: Colors.grey,
        );
    }
  }

  void _showDeliveryDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeliveryDetailScreen(delivery: delivery),
      ),
    );
  }
}

class DeliveryDetailScreen extends StatelessWidget {
  final Delivery delivery;

  const DeliveryDetailScreen({
    super.key,
    required this.delivery,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery #${delivery.id_delivery}'),
        actions: [
          if (delivery.canBeUpdated)
            PopupMenuButton<String>(
              onSelected: (value) => _handleAction(context, value),
              itemBuilder: (context) => [
                if (delivery.canBeCancelled)
                  const PopupMenuItem(
                    value: 'cancel',
                    child: Row(
                      children: [
                        Icon(Icons.cancel_outlined, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Cancel Delivery'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share_outlined),
                      SizedBox(width: 8),
                      Text('Share Details'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            _buildStatusCard(theme),
            const SizedBox(height: 16),

            // Order Information
            _buildSection(
              title: 'Order Information',
              icon: Icons.receipt_outlined,
              children: [
                _buildInfoRow('Delivery ID', '#${delivery.id_delivery}'),
                if (delivery.delivery_placed_order > 0)
                  _buildInfoRow(
                      'Order Reference', '#${delivery.delivery_placed_order}'),
                _buildInfoRow('Shipping Method', delivery.shippingMethodLabel),
                _buildInfoRow(
                    'Estimated Delivery', delivery.shippingMethodDescription),
              ],
            ),
            const SizedBox(height: 16),

            // Package Details
            _buildSection(
              title: 'Package Details',
              icon: Icons.inventory_2_outlined,
              children: [
                _buildInfoRow('Package Count', delivery.formattedPackageCount),
                _buildInfoRow('Total Weight', delivery.formattedWeight),
                if (delivery.delivery_cargo_dimensions.isNotEmpty)
                  _buildInfoRow(
                      'Dimensions', delivery.delivery_cargo_dimensions),
                if (delivery.delivery_goods_description.isNotEmpty)
                  _buildInfoRow(
                      'Description', delivery.delivery_goods_description),
                if (delivery.hs_code.isNotEmpty)
                  _buildInfoRow('HS Code', delivery.hs_code),
              ],
            ),
            const SizedBox(height: 16),

            // Merchant Information
            if (delivery.delivery_merchant_name.isNotEmpty)
              _buildSection(
                title: 'Merchant Information',
                icon: Icons.store_outlined,
                children: [
                  _buildInfoRow(
                      'Merchant Name', delivery.delivery_merchant_name),
                ],
              ),
            const SizedBox(height: 16),

            // Special Instructions
            if (delivery.delivery_special_instructions.isNotEmpty)
              _buildSection(
                title: 'Special Instructions',
                icon: Icons.note_outlined,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      delivery.delivery_special_instructions,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),

            // Recipient Information
            if (delivery.recipient_person > 0 ||
                delivery.recipient_provider > 0)
              _buildSection(
                title: 'Recipient Information',
                icon: Icons.person_outlined,
                children: [
                  if (delivery.recipient_person > 0)
                    _buildInfoRow(
                        'Person ID', delivery.recipient_person.toString()),
                  if (delivery.recipient_provider > 0)
                    _buildInfoRow(
                        'Provider ID', delivery.recipient_provider.toString()),
                ],
              ),
            const SizedBox(height: 16),

            // Address Information
            _buildSection(
              title: 'Address Information',
              icon: Icons.location_on_outlined,
              children: [
                _buildInfoRow('Delivery Address ID',
                    delivery.delivery_address_id.toString()),
                if (delivery.delivery_current_address_id > 0)
                  _buildInfoRow('Current Address ID',
                      delivery.delivery_current_address_id.toString()),
              ],
            ),
            const SizedBox(height: 16),

            // Financial Information
            if (delivery.delivery_fee > 0)
              _buildSection(
                title: 'Financial Information',
                icon: Icons.attach_money_outlined,
                children: [
                  _buildInfoRow('Delivery Fee', delivery.formattedFee),
                  _buildInfoRow('Estimated Price',
                      _formatCurrency(delivery.calculateEstimatedPrice())),
                ],
              ),
            const SizedBox(height: 16),

            // Provider & Broker Information
            if (delivery.delivery_provider_id > 0 ||
                delivery.delivery_broker_id > 0)
              _buildSection(
                title: 'Service Information',
                icon: Icons.business_outlined,
                children: [
                  if (delivery.delivery_provider_id > 0)
                    _buildInfoRow('Provider ID',
                        delivery.delivery_provider_id.toString()),
                  if (delivery.delivery_broker_id > 0)
                    _buildInfoRow(
                        'Broker ID', delivery.delivery_broker_id.toString()),
                ],
              ),
            const SizedBox(height: 16),

            // Timestamps
            if (delivery.delivery_created_at != null ||
                delivery.delivery_updated_at != null)
              _buildSection(
                title: 'Timeline',
                icon: Icons.schedule_outlined,
                children: [
                  if (delivery.delivery_created_at != null)
                    _buildInfoRow('Created',
                        _formatDateTime(delivery.delivery_created_at!)),
                  if (delivery.delivery_updated_at != null)
                    _buildInfoRow('Last Updated',
                        _formatDateTime(delivery.delivery_updated_at!)),
                ],
              ),

            const SizedBox(height: 24),

            // Action Buttons
            if (delivery.canBeUpdated) ...[
              _buildActionButtons(context, theme),
              const SizedBox(height: 16),
            ],

            // Validation Status
            if (!delivery.isValidForCreation && delivery.id_delivery == 0)
              _buildValidationWarning(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(ThemeData theme) {
    Color statusColor;
    IconData statusIcon;

    if (delivery.isPending) {
      statusColor = Colors.orange;
      statusIcon = Icons.pending_outlined;
    } else if (delivery.isInTransit) {
      statusColor = Colors.purple;
      statusIcon = Icons.local_shipping_outlined;
    } else if (delivery.isDelivered) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle_outline;
    } else if (delivery.isCancelled) {
      statusColor = Colors.red;
      statusIcon = Icons.cancel_outlined;
    } else if (delivery.isFailed) {
      statusColor = Colors.red;
      statusIcon = Icons.error_outline;
    } else {
      statusColor = Colors.grey;
      statusIcon = Icons.help_outline;
    }

    return Card(
      elevation: 0,
      color: statusColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(statusIcon, color: statusColor, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Status',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    delivery.statusLabel,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        if (delivery.canBeCancelled)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _handleAction(context, 'cancel'),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Cancel Delivery'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        if (delivery.canBeCancelled) const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _handleAction(context, 'track'),
            icon: const Icon(Icons.track_changes),
            label: const Text('Track Delivery'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildValidationWarning(ThemeData theme) {
    final errors = delivery.validate();
    if (errors.isEmpty) return const SizedBox.shrink();

    return Card(
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_outlined, color: Colors.red.shade700),
                const SizedBox(width: 8),
                Text(
                  'Validation Issues',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...errors.map((error) => Padding(
                  padding: const EdgeInsets.only(left: 32, bottom: 4),
                  child: Text(
                    '• $error',
                    style: TextStyle(fontSize: 12, color: Colors.red.shade700),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  void _handleAction(BuildContext context, String action) {
    switch (action) {
      case 'cancel':
        _showCancelDialog(context);
        break;
      case 'share':
        _shareDeliveryDetails(context);
        break;
      case 'track':
        _showTrackingInfo(context);
        break;
    }
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Delivery'),
        content: Text(
            'Are you sure you want to cancel delivery #${delivery.id_delivery}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Add your cancel logic here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cancellation requested')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _shareDeliveryDetails(BuildContext context) {
    final details = '''
Delivery #${delivery.id_delivery}
Status: ${delivery.statusLabel}
Packages: ${delivery.formattedPackageCount}
Weight: ${delivery.formattedWeight}
Shipping Method: ${delivery.shippingMethodLabel}
Total Fee: ${delivery.formattedFee}
''';
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing: $details')),
    );
  }

  void _showTrackingInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tracking Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Delivery ID: #${delivery.id_delivery}'),
            const SizedBox(height: 8),
            Text('Status: ${delivery.statusLabel}'),
            const SizedBox(height: 8),
            Text('Shipping Method: ${delivery.shippingMethodLabel}'),
            const SizedBox(height: 8),
            Text('Estimated: ${delivery.shippingMethodDescription}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
