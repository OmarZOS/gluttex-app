// components/discount_indicator.dart
import 'package:flutter/material.dart';

class DiscountIndicator extends StatelessWidget {
  final double basePrice;
  final double finalPrice;
  final double discountPercentage;
  final bool showWarning;

  const DiscountIndicator({
    super.key,
    required this.basePrice,
    required this.finalPrice,
    required this.discountPercentage,
    this.showWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (basePrice == 0 && finalPrice == 0) {
      return const SizedBox.shrink();
    }

    if (showWarning) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.errorContainer.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.error.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: colors.error, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Final price (DZD $finalPrice) is higher than base price (DZD $basePrice)',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (discountPercentage > 0) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.primaryContainer.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colors.primary.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.discount, color: colors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${discountPercentage.toStringAsFixed(1)}% discount applied',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (basePrice > 0 && finalPrice > 0 && discountPercentage == 0) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.outline.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.price_check, color: colors.onSurfaceVariant, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No discount applied',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
