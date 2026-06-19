import 'package:flutter/material.dart';
import 'package:event/delivery_change_notifier.dart';
import 'package:provider_store/components/delivery/DeliveryCard.dart';
import 'package:provider/provider.dart';

class DeliveryListView extends StatefulWidget {
  final String status;

  const DeliveryListView({
    super.key,
    required this.status,
  });

  @override
  State<DeliveryListView> createState() => _DeliveryListViewState();
}

class _DeliveryListViewState extends State<DeliveryListView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier =
          Provider.of<DeliveryChangeNotifier>(context, listen: false);

      if (notifier.deliveries.isEmpty) {
        notifier.fetchFirstPage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<DeliveryChangeNotifier>();
    final deliveries = notifier.getDeliveriesByStatus(widget.status);

    if (notifier.isLoading && deliveries.isEmpty) {
      return const _LoadingShimmer();
    }

    if (deliveries.isEmpty) {
      return _EmptyState(status: widget.status);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: deliveries.length,
      itemBuilder: (context, index) {
        final delivery = deliveries[index];

        return DeliveryCard(
          delivery: delivery,
          status: widget.status,
        );
      },
    );
  }
}

class _LoadingShimmer extends StatelessWidget {
  const _LoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          height: 100,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String status;

  const _EmptyState({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, message, color) = _getEmptyStateConfig(status, theme);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.1),
              ),
              child: Icon(
                icon,
                size: 48,
                color: color,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'No deliveries found in this category.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  (IconData, String, Color) _getEmptyStateConfig(
    String status,
    ThemeData theme,
  ) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return (
          Icons.pending_outlined,
          'No Pending Deliveries',
          Colors.orange,
        );
      case 'DELIVERED':
        return (
          Icons.check_circle_outline,
          'No Delivered Deliveries',
          Colors.green,
        );
      case 'CANCELLED':
        return (
          Icons.cancel_outlined,
          'No Cancelled Deliveries',
          Colors.red,
        );
      default:
        return (
          Icons.local_shipping_outlined,
          'No deliveries found',
          Colors.grey,
        );
    }
  }
}
