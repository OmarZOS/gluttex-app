import 'package:flutter/material.dart';

class PricingCard extends StatelessWidget {
  final String title;
  final double amount;
  final bool isPercentage;
  final Color color;
  final Color textColor;
  final IconData icon;

  const PricingCard({
    super.key,
    required this.title,
    required this.amount,
    this.isPercentage = false,
    required this.color,
    required this.textColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: textColor, size: 20),
              if (isPercentage && amount >= 0)
                Icon(
                  Icons.trending_up,
                  color: textColor,
                  size: 16,
                )
              else if (isPercentage)
                Icon(
                  Icons.trending_down,
                  color: textColor,
                  size: 16,
                ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: textColor.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isPercentage
                ? '${amount.toStringAsFixed(1)}%'
                : '\$${amount.toStringAsFixed(2)}',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w800,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }
}
