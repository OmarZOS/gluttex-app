import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gluttex_core/business/Delivery.dart';
import 'package:event/delivery_change_notifier.dart';
import 'package:provider/provider.dart';

// ============================================================================
// DELIVERY CARD
// ============================================================================

class DeliveryCard extends StatelessWidget {
  final Delivery delivery;
  final DeliveryChangeNotifier? notifier;
  final VoidCallback? onTap;

  const DeliveryCard({
    super.key,
    required this.delivery,
    this.notifier,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusConfig =
        DeliveryStatusConfig.fromStatus(delivery.delivery_status);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap ?? () => _navigateToDetails(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _StatusIcon(statusConfig: statusConfig),
              const SizedBox(width: 16),
              Expanded(child: _DeliveryInfo(delivery: delivery, theme: theme)),
              _StatusBadge(statusConfig: statusConfig, theme: theme),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetails(BuildContext context) {
    final actualNotifier = notifier ?? context.read<DeliveryChangeNotifier>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeliveryDetailScreen(
          delivery: delivery,
          notifier: actualNotifier,
        ),
      ),
    );
  }
}

// ============================================================================
// DELIVERY STATUS CONFIG
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

// ============================================================================
// WIDGETS
// ============================================================================

class _StatusIcon extends StatelessWidget {
  final DeliveryStatusConfig statusConfig;

  const _StatusIcon({required this.statusConfig});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: statusConfig.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(statusConfig.icon, color: statusConfig.color),
    );
  }
}

class _DeliveryInfo extends StatelessWidget {
  final Delivery delivery;
  final ThemeData theme;

  const _DeliveryInfo({required this.delivery, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
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
            _InfoChip(
              icon: Icons.inventory_2_outlined,
              label: delivery.formattedPackageCount,
              color: Colors.blue,
            ),
            const SizedBox(width: 8),
            _InfoChip(
              icon: Icons.monitor_weight_outlined,
              label: delivery.formattedWeight,
              color: Colors.orange,
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
}

class _StatusBadge extends StatelessWidget {
  final DeliveryStatusConfig statusConfig;
  final ThemeData theme;

  const _StatusBadge({required this.statusConfig, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusConfig.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusConfig.color.withOpacity(0.3)),
      ),
      child: Text(
        statusConfig.label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: statusConfig.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ============================================================================
// DELIVERY DETAIL SCREEN
// ============================================================================

class DeliveryDetailScreen extends StatelessWidget {
  final Delivery delivery;
  final DeliveryChangeNotifier? notifier;

  const DeliveryDetailScreen({
    super.key,
    required this.delivery,
    this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actualNotifier = notifier ?? context.watch<DeliveryChangeNotifier>();
    final statusConfig =
        DeliveryStatusConfig.fromStatus(delivery.delivery_status);

    return Scaffold(
      appBar: _buildAppBar(context, actualNotifier),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatusCard(delivery: delivery, statusConfig: statusConfig),
            const SizedBox(height: 16),
            _InfoSection(
              title: 'Order Information',
              icon: Icons.receipt_outlined,
              children: _buildOrderInfo(),
            ),
            const SizedBox(height: 16),
            _InfoSection(
              title: 'Package Details',
              icon: Icons.inventory_2_outlined,
              children: _buildPackageInfo(),
            ),
            if (_hasMerchantInfo()) ...[
              const SizedBox(height: 16),
              _InfoSection(
                title: 'Merchant Information',
                icon: Icons.store_outlined,
                children: _buildMerchantInfo(),
              ),
            ],
            if (_hasSpecialInstructions()) ...[
              const SizedBox(height: 16),
              _InfoSection(
                title: 'Special Instructions',
                icon: Icons.note_outlined,
                children: _buildSpecialInstructions(theme),
              ),
            ],
            if (_hasRecipientInfo()) ...[
              const SizedBox(height: 16),
              _InfoSection(
                title: 'Recipient Information',
                icon: Icons.person_outlined,
                children: _buildRecipientInfo(),
              ),
            ],
            const SizedBox(height: 16),
            _InfoSection(
              title: 'Address Information',
              icon: Icons.location_on_outlined,
              children: _buildAddressInfo(),
            ),
            if (_hasFinancialInfo()) ...[
              const SizedBox(height: 16),
              _InfoSection(
                title: 'Financial Information',
                icon: Icons.attach_money_outlined,
                children: _buildFinancialInfo(),
              ),
            ],
            if (_hasServiceInfo()) ...[
              const SizedBox(height: 16),
              _InfoSection(
                title: 'Service Information',
                icon: Icons.business_outlined,
                children: _buildServiceInfo(),
              ),
            ],
            if (_hasTimestamps()) ...[
              const SizedBox(height: 16),
              _InfoSection(
                title: 'Timeline',
                icon: Icons.schedule_outlined,
                children: _buildTimelineInfo(),
              ),
            ],
            const SizedBox(height: 24),
            if (delivery.canBeUpdated) ...[
              _ActionButtons(
                delivery: delivery,
                notifier: actualNotifier,
              ),
              const SizedBox(height: 16),
            ],
            // if (!delivery.isValidForCreation && delivery.id_delivery == 0)
            //   _ValidationWarning(delivery: delivery),
          ],
        ),
      ),
    );
  }

  // ==================== APP BAR ====================

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    DeliveryChangeNotifier notifier,
  ) {
    return AppBar(
      title: Text('Delivery #${delivery.id_delivery}'),
      actions: [
        if (delivery.canBeUpdated)
          PopupMenuButton<String>(
            onSelected: (value) => _handleAction(context, value, notifier),
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
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh_outlined),
                    SizedBox(width: 8),
                    Text('Refresh Status'),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  // ==================== INFO BUILDERS ====================

  List<Widget> _buildOrderInfo() => [
        _InfoRow(label: 'Delivery ID', value: '#${delivery.id_delivery}'),
        if ((delivery.delivery_invoice_ref ?? 0) > 0)
          _InfoRow(
              label: 'Order Reference',
              value: '#${delivery.delivery_invoice_ref}'),
        _InfoRow(label: 'Shipping Method', value: delivery.shippingMethodLabel),
        _InfoRow(
            label: 'Estimated Delivery',
            value: delivery.delivery_shipping_method),
        if (delivery.delivery_source_type != null)
          _InfoRow(label: 'Source Type', value: delivery.delivery_source_type!),
      ];

  List<Widget> _buildPackageInfo() => [
        _InfoRow(label: 'Package Count', value: delivery.formattedPackageCount),
        _InfoRow(label: 'Total Weight', value: delivery.formattedWeight),
        if (delivery.delivery_cargo_dimensions?.isNotEmpty == true)
          _InfoRow(
              label: 'Dimensions', value: delivery.delivery_cargo_dimensions!),
        if (delivery.delivery_goods_description?.isNotEmpty == true)
          _InfoRow(
              label: 'Description',
              value: delivery.delivery_goods_description!),
        if (delivery.hs_code?.isNotEmpty == true)
          _InfoRow(label: 'HS Code', value: delivery.hs_code!),
      ];

  List<Widget> _buildMerchantInfo() => [
        _InfoRow(
            label: 'Merchant Name', value: delivery.delivery_merchant_name!),
      ];

  List<Widget> _buildSpecialInstructions(ThemeData theme) => [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            delivery.delivery_special_instructions ?? '',
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ];

  List<Widget> _buildRecipientInfo() => [
        if (delivery.recipient_person > 0)
          _InfoRow(
              label: 'Person ID', value: delivery.recipient_person.toString()),
        if (delivery.recipient_provider > 0)
          _InfoRow(
              label: 'Provider ID',
              value: delivery.recipient_provider.toString()),
      ];

  List<Widget> _buildAddressInfo() => [
        _InfoRow(
            label: 'Delivery Address ID',
            value: (delivery.delivery_address_id ?? 0).toString()),
        if ((delivery.delivery_current_address_id ?? 0) > 0)
          _InfoRow(
              label: 'Current Address ID',
              value: (delivery.delivery_current_address_id ?? 0).toString()),
      ];

  List<Widget> _buildFinancialInfo() => [
        _InfoRow(label: 'Delivery Fee', value: delivery.formattedFee),
        _InfoRow(label: 'Estimated Price', value: _formatCurrency(0)),
      ];

  List<Widget> _buildServiceInfo() => [
        if ((delivery.delivery_provider_id ?? 0) > 0)
          _InfoRow(
              label: 'Provider ID',
              value: (delivery.delivery_provider_id ?? 0).toString()),
        if ((delivery.delivery_broker_id ?? 0) > 0)
          _InfoRow(
              label: 'Broker ID',
              value: (delivery.delivery_broker_id ?? 0).toString()),
      ];

  List<Widget> _buildTimelineInfo() => [
        if (delivery.delivery_created_at != null)
          _InfoRow(
              label: 'Created',
              value: _formatDateTime(delivery.delivery_created_at!)),
        if (delivery.delivery_updated_at != null)
          _InfoRow(
              label: 'Last Updated',
              value: _formatDateTime(delivery.delivery_updated_at!)),
      ];

  // ==================== HELPERS ====================

  bool _hasMerchantInfo() =>
      delivery.delivery_merchant_name?.isNotEmpty == true;

  bool _hasSpecialInstructions() =>
      delivery.delivery_special_instructions?.isNotEmpty == true;

  bool _hasRecipientInfo() =>
      delivery.recipient_person > 0 || delivery.recipient_provider > 0;

  bool _hasFinancialInfo() => (delivery.delivery_fee ?? 0) > 0;

  bool _hasServiceInfo() =>
      (delivery.delivery_provider_id ?? 0) > 0 ||
      (delivery.delivery_broker_id ?? 0) > 0;

  bool _hasTimestamps() =>
      delivery.delivery_created_at != null ||
      delivery.delivery_updated_at != null;

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatCurrency(double amount) {
    return 'DA ${amount.toStringAsFixed(2)}';
  }

  // ==================== ACTIONS ====================

  void _handleAction(
    BuildContext context,
    String action,
    DeliveryChangeNotifier notifier,
  ) {
    switch (action) {
      case 'cancel':
        _showCancelDialog(context, notifier);
        break;
      case 'share':
        _shareDeliveryDetails(context);
        break;
      case 'track':
        _showTrackingInfo(context);
        break;
      case 'refresh':
        _refreshDelivery(context, notifier);
        break;
    }
  }

  void _refreshDelivery(BuildContext context, DeliveryChangeNotifier notifier) {
    notifier.refreshDelivery(delivery.id_delivery);
    _showSnackBar(context, 'Refreshing delivery status...');
  }

  void _showCancelDialog(
      BuildContext context, DeliveryChangeNotifier notifier) {
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
            onPressed: () async {
              Navigator.pop(context);
              final success =
                  await notifier.cancelDelivery(delivery.id_delivery);
              _showSnackBar(
                context,
                success
                    ? 'Delivery #${delivery.id_delivery} cancelled successfully'
                    : 'Failed to cancel delivery',
                isError: !success,
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
    _showSnackBar(context, 'Sharing delivery details...');
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
            Text('Estimated: ${delivery.delivery_shipping_method}'),
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

  void _showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ============================================================================
// REUSABLE WIDGETS
// ============================================================================

class _StatusCard extends StatelessWidget {
  final Delivery delivery;
  final DeliveryStatusConfig statusConfig;

  const _StatusCard({
    required this.delivery,
    required this.statusConfig,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: statusConfig.color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusConfig.color.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusConfig.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  Icon(statusConfig.icon, color: statusConfig.color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Status',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: statusConfig.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusConfig.label,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: statusConfig.color,
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
}

class _InfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _InfoSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
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
}

class _ActionButtons extends StatelessWidget {
  final Delivery delivery;
  final DeliveryChangeNotifier notifier;

  const _ActionButtons({
    required this.delivery,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (delivery.canBeCancelled)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _handleCancel(context),
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
            onPressed: () => _handleTrack(context),
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

  void _handleCancel(BuildContext context) {
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
            onPressed: () async {
              Navigator.pop(context);
              final success =
                  await notifier.cancelDelivery(delivery.id_delivery);
              _showSnackBar(
                context,
                success
                    ? 'Delivery #${delivery.id_delivery} cancelled'
                    : 'Failed to cancel delivery',
                isError: !success,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _handleTrack(BuildContext context) {
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
            // const SizedBox(height: 8),
            // Text('Estimated: ${delivery.shippingMethodDescription}'),
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

  void _showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// class _ValidationWarning extends StatelessWidget {
//   final Delivery delivery;

//   const _ValidationWarning({required this.delivery});

//   @override
//   Widget build(BuildContext context) {
//     final errors = delivery.validate();
//     if (errors.isEmpty) return const SizedBox.shrink();

//     return Card(
//       color: Colors.red.shade50,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: BorderSide(color: Colors.red.shade200),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.warning_amber_outlined, color: Colors.red.shade700),
//                 const SizedBox(width: 8),
//                 Text(
//                   'Validation Issues',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.red.shade700,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             ...errors.map((error) => Padding(
//                   padding: const EdgeInsets.only(left: 32, bottom: 4),
//                   child: Text(
//                     '• $error',
//                     style: TextStyle(fontSize: 12, color: Colors.red.shade700),
//                   ),
//                 )),
//           ],
//         ),
//       ),
//     );
//   }
// }
