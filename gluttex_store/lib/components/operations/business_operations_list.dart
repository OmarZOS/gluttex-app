import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/finance/BusinessOperation.dart';

class BusinessOperationsList extends StatelessWidget {
  final List<BusinessOperation> operations;
  final bool isLoadingMore;
  final bool hasMore;
  final VoidCallback onLoadMore;
  final ValueChanged<BusinessOperation> onTapOperation;

  const BusinessOperationsList({
    super.key,
    required this.operations,
    required this.isLoadingMore,
    required this.hasMore,
    required this.onLoadMore,
    required this.onTapOperation,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index < operations.length) {
            return BusinessOperationItem(
              operation: operations[index],
              isLast: index == operations.length - 1,
              onTap: () => onTapOperation(operations[index]),
            );
          } else if (hasMore) {
            onLoadMore();
            return const _LoadingMoreIndicator();
          }
          return null;
        },
        childCount: operations.length + (hasMore ? 1 : 0),
      ),
    );
  }
}

class BusinessOperationItem extends StatelessWidget {
  final BusinessOperation operation;
  final bool isLast;
  final VoidCallback onTap;

  const BusinessOperationItem({
    super.key,
    required this.operation,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, isLast ? 16 : 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              _Header(operation: operation),
              const SizedBox(height: 12),
              _FinancialDetails(operation: operation),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final BusinessOperation operation;

  const _Header({required this.operation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        _StatusBadge(status: operation.paymentStatus),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getOperationTitle(operation),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _getOperationSubtitle(operation),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        _SourceBadge(source: operation.sourceTable),
      ],
    );
  }

  String _getOperationTitle(BusinessOperation operation) {
    if (operation.orderId != null) {
      return 'Order #${operation.orderId}';
    } else if (operation.cartId != null) {
      return 'Cart #${operation.cartId}';
    }
    return 'Transaction #${operation.supplierId ?? 0}';
  }

  String _getOperationSubtitle(BusinessOperation operation) {
    final parts = <String>[];
    if (operation.client != null) parts.add('Client #${operation.client}');
    if (operation.supplierId != null)
      parts.add('Supplier #${operation.supplierId}');
    return parts.join(' • ');
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = getStatusColor(status, colorScheme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStatusIcon(status), size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            _formatStatus(status),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'fully_paid':
        return Icons.check_circle;
      case 'partial':
      case 'partially_paid':
        return Icons.pending;
      case 'unpaid':
      case 'overdue':
        return Icons.error_outline;
      default:
        return Icons.help_outline;
    }
  }

  String _formatStatus(String status) {
    return status.replaceAll('_', ' ').split(' ').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  Color getStatusColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'fully_paid':
        return colorScheme.primary;
      case 'partial':
      case 'partially_paid':
        return colorScheme.secondary;
      case 'unpaid':
        return colorScheme.tertiary;
      case 'overdue':
        return colorScheme.onSurfaceVariant;
      default:
        return colorScheme.primary;
    }
  }
}

class _SourceBadge extends StatelessWidget {
  final String source;

  const _SourceBadge({required this.source});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCart = source == 'cart_based';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isCart ? colorScheme.primary : colorScheme.secondary)
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isCart ? 'Cart' : 'Order',
        style: TextStyle(
          color: isCart ? colorScheme.primary : colorScheme.secondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FinancialDetails extends StatelessWidget {
  final BusinessOperation operation;

  const _FinancialDetails({required this.operation});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context)!;

    return Row(
      children: [
        _FinancialColumn(
          label: localizations.totalAmount,
          value: _formatCurrency(operation.totalAmount),
          color: colorScheme.onSurface,
        ),
        const SizedBox(width: 16),
        _FinancialColumn(
          label: localizations.paid,
          value: _formatCurrency(operation.totalPaid),
          color: Colors.green,
        ),
        const SizedBox(width: 16),
        _FinancialColumn(
          label: localizations.balance,
          value: _formatCurrency(operation.balanceDue),
          color: operation.balanceDue > 0
              ? colorScheme.inverseSurface
              : colorScheme.onSurface,
        ),
      ],
    );
  }

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }
}

class _FinancialColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _FinancialColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingMoreIndicator extends StatelessWidget {
  const _LoadingMoreIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
