// components/cost_summary_card.dart
import 'package:flutter/material.dart';

class CostSummaryCard extends StatelessWidget {
  final double resourceCost;
  final double staffCost;
  final double totalCost;
  final double finalPrice;
  final double profitMargin;
  final bool showWarning;

  const CostSummaryCard({
    super.key,
    required this.resourceCost,
    required this.staffCost,
    required this.totalCost,
    required this.finalPrice,
    required this.profitMargin,
    this.showWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildCostRow(
            context,
            label: 'Resource Cost',
            value: resourceCost,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          _buildCostRow(
            context,
            label: 'Staff Cost',
            value: staffCost,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Divider(color: colors.outline.withOpacity(0.3)),
          const SizedBox(height: 8),
          _buildCostRow(
            context,
            label: 'Total Cost',
            value: totalCost,
            color: colors.onSurface,
            isBold: true,
          ),
          if (finalPrice > 0) ...[
            const SizedBox(height: 16),
            _buildCostRow(
              context,
              label: 'Final Price',
              value: finalPrice,
              color: colors.primary,
              isBold: true,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: showWarning
                    ? colors.errorContainer.withOpacity(0.2)
                    : profitMargin >= 20
                        ? colors.primaryContainer.withOpacity(0.2)
                        : profitMargin >= 10
                            ? colors.secondaryContainer.withOpacity(0.2)
                            : colors.errorContainer.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profit Margin',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  Row(
                    children: [
                      if (showWarning)
                        Icon(
                          Icons.warning_amber_rounded,
                          color: colors.error,
                          size: 18,
                        ),
                      const SizedBox(width: 8),
                      Text(
                        '${profitMargin.toStringAsFixed(1)}%',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: showWarning
                              ? colors.error
                              : profitMargin >= 20
                                  ? colors.primary
                                  : profitMargin >= 10
                                      ? colors.secondary
                                      : colors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (showWarning)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Warning: Service is being sold below cost',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildCostRow(
    BuildContext context, {
    required String label,
    required double value,
    required Color color,
    bool isBold = false,
  }) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            color: color,
          ),
        ),
        Text(
          'DZD ${value.toStringAsFixed(2)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
