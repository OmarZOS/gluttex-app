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
                          label:
                              '${delivery.delivery_package_count ?? 1} packages',
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          icon: Icons.monitor_weight_outlined,
                          label: '${delivery.delivery_total_weight ?? 1} kg',
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
                  status,
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
      case 'DELIVERED':
        return (
          icon: Icons.check_circle_outline,
          color: Colors.green,
        );
      case 'CANCELLED':
        return (
          icon: Icons.cancel_outlined,
          color: Colors.red,
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
      ),
      body: Center(
        child: Text(
          'Delivery details will be displayed here',
          style: theme.textTheme.bodyLarge,
        ),
      ),
    );
  }
}
