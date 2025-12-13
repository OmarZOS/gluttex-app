import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/finance/BusinessOperation.dart';

class OperationSummary extends StatelessWidget {
  final BusinessOperation operation;

  const OperationSummary({super.key, required this.operation});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.operationSummary,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _SummaryGrid(operation: operation),
          const SizedBox(height: 16),
          _AdditionalInfo(operation: operation),
        ],
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final BusinessOperation operation;

  const _SummaryGrid({required this.operation});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: [
        _SummaryItem(
          label: localizations.operationId,
          value: _getOperationId(),
          icon: Icons.numbers,
          color: colorScheme.primary,
        ),
        _SummaryItem(
          label: localizations.client,
          value: operation.clientId != null ? '#${operation.clientId}' : 'N/A',
          icon: Icons.person,
          color: colorScheme.secondary,
        ),
        _SummaryItem(
          label: localizations.supplier,
          value:
              operation.supplierId != null ? '#${operation.supplierId}' : 'N/A',
          icon: Icons.business,
          color: Colors.orange,
        ),
        _SummaryItem(
          label: localizations.seller,
          value: operation.sellerId != null ? '#${operation.sellerId}' : 'N/A',
          icon: Icons.person_outline,
          color: Colors.purple,
        ),
      ],
    );
  }

  String _getOperationId() {
    if (operation.orderId != null) return '#${operation.orderId}';
    if (operation.cartId != null) return '#${operation.cartId}';
    return 'N/A';
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdditionalInfo extends StatelessWidget {
  final BusinessOperation operation;

  const _AdditionalInfo({required this.operation});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context)!;

    return Row(
      children: [
        if (operation.invoiceStatus.isNotEmpty &&
            operation.invoiceStatus != 'unknown')
          _InfoChip(
            label: '${localizations.invoice}: ${operation.invoiceStatus}',
            color: Colors.blue,
          ),
        if (operation.sourceTable.isNotEmpty &&
            operation.sourceTable != 'unknown')
          _InfoChip(
            label: operation.sourceTable == 'cart_based'
                ? localizations.cartBased
                : localizations.orderBased,
            color: colorScheme.primary,
          ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
