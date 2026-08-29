import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gluttex_core/business/Delivery.dart';
import 'package:event/delivery_change_notifier.dart';
import 'package:provider/provider.dart';
import 'package:provider_store/components/orders/details/delivery_details_screen.dart';

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

  Future<void> _navigateToDetails(BuildContext context) async {
    final actualNotifier = notifier ?? context.read<DeliveryChangeNotifier>();

    final fetchedDelivery = await actualNotifier.getDeliveryById(
      delivery.id_delivery,
      forceRefresh: true,
    );

    if (!context.mounted) return;

    if (fetchedDelivery == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to load delivery details'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeliveryDetailScreen(
          delivery: fetchedDelivery,
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
