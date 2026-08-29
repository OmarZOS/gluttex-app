import 'package:flutter/material.dart';
import 'package:event/delivery_change_notifier.dart';
import 'package:provider_store/components/delivery/DeliveryCard.dart';
import 'package:provider/provider.dart';

class DeliveryListView extends StatefulWidget {
  final String status;
  final int selectedSupplierId;
  final DeliveryChangeNotifier? notifier;
  final bool isLoading;
  final Future<void> Function()? onRefresh;

  const DeliveryListView({
    super.key,
    required this.status,
    this.selectedSupplierId = 0,
    this.notifier,
    this.isLoading = false,
    this.onRefresh,
  });

  @override
  State<DeliveryListView> createState() => _DeliveryListViewState();
}

class _DeliveryListViewState extends State<DeliveryListView> {
  late DeliveryChangeNotifier _notifier;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _notifier = widget.notifier ?? context.read<DeliveryChangeNotifier>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.notifier == null) {
      _notifier = context.read<DeliveryChangeNotifier>();
    }

    // ✅ Only load if not initialized and deliveries are empty
    if (!_initialized && _notifier.deliveries.isEmpty) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.selectedSupplierId > 0) {
          _notifier.fetchDeliveries(
              providerId: widget.selectedSupplierId, reset: true);
        } else {
          _notifier.fetchFirstPage();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = widget.notifier != null
        ? _notifier
        : context.watch<DeliveryChangeNotifier>();

    final deliveries = notifier.getDeliveriesByStatus(widget.status);
    final isLoading = widget.isLoading || notifier.isLoading;

    // Show loading only if we're loading AND have no data
    if (isLoading && deliveries.isEmpty) {
      return const _LoadingShimmer();
    }

    if (deliveries.isEmpty) {
      return _EmptyState(status: widget.status);
    }

    return RefreshIndicator.adaptive(
      onRefresh: () async {
        if (widget.onRefresh != null) {
          await widget.onRefresh!();
        } else {
          await notifier.refreshDeliveries();
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: deliveries.length,
        itemBuilder: (context, index) {
          final delivery = deliveries[index];
          return DeliveryCard(
            delivery: delivery,
            // status: widget.status,
            notifier: notifier,
          );
        },
      ),
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
