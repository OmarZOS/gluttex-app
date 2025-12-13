import 'package:flutter/material.dart';
import 'package:gluttex_core/business/finance/Order.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';

class InvoiceList extends StatelessWidget {
  final List<Order> orders;
  final bool isLoading;
  final Function() onRefresh;
  final Function(Order) onViewInvoiceDetails;
  final Function(Order) onShareInvoice;
  final Function(Order) onDownloadInvoice;
  final Function() onCreateFirstInvoice;
  final int? currentUserId;

  const InvoiceList({
    super.key,
    required this.orders,
    required this.isLoading,
    required this.onRefresh,
    required this.onViewInvoiceDetails,
    required this.onShareInvoice,
    required this.onDownloadInvoice,
    required this.onCreateFirstInvoice,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    if (isLoading) {
      return _buildLoadingState(context, localizations);
    }

    if (orders.isEmpty) {
      return _buildEmptyState(context, localizations);
    }

    return RefreshIndicator(
      onRefresh: () => onRefresh(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildInvoiceCard(context, orders[index], localizations);
        },
      ),
    );
  }

  Widget _buildInvoiceCard(
    BuildContext context,
    Order order,
    AppLocalizations localizations,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isPaid = order.paymentStatus.toLowerCase() == 'paid';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: InkWell(
        onTap: () => onViewInvoiceDetails(order),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${localizations.invoice} #${order.idOrder}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPaid
                          ? colorScheme.primaryContainer
                          : colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isPaid ? localizations.paid : localizations.pending,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isPaid
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(order.orderedTimestamp),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.attach_money,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '\$${order.totalPrice.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.shopping_cart,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${order.itemCount} ${localizations.items}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.payment,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatPaymentMethod(order.paymentMethod, localizations),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onShareInvoice(order),
                      icon: Icon(
                        Icons.share,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      label: Text(localizations.share),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        side: BorderSide(color: colorScheme.outline),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => onDownloadInvoice(order),
                      icon: Icon(
                        Icons.download,
                        size: 18,
                        color: colorScheme.onPrimary,
                      ),
                      label: Text(localizations.download),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long,
                size: 48,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              localizations.noInvoicesYet,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              localizations.noInvoicesDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onCreateFirstInvoice,
              icon: Icon(
                Icons.add,
                color: colorScheme.onPrimary,
              ),
              label: Text(localizations.createFirstInvoice),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            localizations.loadingInvoices,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatPaymentMethod(String method, AppLocalizations localizations) {
    switch (method.toLowerCase()) {
      case 'card':
        return localizations.card;
      case 'cash':
        return localizations.cash;
      case 'bank':
        return localizations.bankTransfer;
      case 'mobile':
        return localizations.mobilePayment;
      default:
        return method;
    }
  }
}

class InvoiceDetailsSheet extends StatelessWidget {
  final Order order;
  final AppLocalizations localizations;

  const InvoiceDetailsSheet({
    super.key,
    required this.order,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${localizations.invoiceDetails} #${order.idOrder}',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          // TODO: Add detailed invoice view
        ],
      ),
    );
  }
}
