import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/finance/BusinessOperation.dart';

class BusinessOperationsStats extends StatelessWidget {
  final List<BusinessOperation> operations;

  const BusinessOperationsStats({super.key, required this.operations});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final stats = _calculateStats();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Quick Stats
          _QuickStats(stats: stats, localizations: localizations),
          const SizedBox(height: 16),

          // Distribution Charts
          _DistributionCharts(operations: operations),
        ],
      ),
    );
  }

  // Helper Functions

  Map<String, dynamic> _calculateStats() {
    final totalAmount = operations.fold(0.0, (sum, op) => sum + op.totalAmount);
    final totalPaid = operations.fold(0.0, (sum, op) => sum + op.totalPaid);
    final balanceDue = operations.fold(0.0, (sum, op) => sum + op.balanceDue);

    return {
      'totalAmount': totalAmount,
      'totalPaid': totalPaid,
      'balanceDue': balanceDue,
    };
  }
}

class _QuickStats extends StatelessWidget {
  final Map<String, dynamic> stats;
  final AppLocalizations localizations;

  const _QuickStats({
    required this.stats,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          _StatItem(
            label: localizations.totalAmount,
            value: _formatCurrency(stats['totalAmount']),
            color: colorScheme.primary,
          ),
          const SizedBox(width: 16),
          _StatItem(
            label: localizations.totalPaid,
            value: _formatCurrency(stats['totalPaid']),
            color: Colors.green,
          ),
          const SizedBox(width: 16),
          _StatItem(
            label: localizations.outstanding,
            value: _formatCurrency(stats['balanceDue']),
            color: colorScheme.inverseSurface,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DistributionCharts extends StatelessWidget {
  final List<BusinessOperation> operations;

  const _DistributionCharts({required this.operations});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final statusDistribution = _calculateStatusDistribution();
    final sourceDistribution = _calculateSourceDistribution();

    return Row(
      children: [
        // Status Distribution
        Expanded(
          child: _DistributionChart(
            title: localizations.byStatus,
            distribution: statusDistribution,
          ),
        ),
        const SizedBox(width: 12),

        // Source Distribution
        Expanded(
          child: _DistributionChart(
            title: localizations.bySource,
            distribution: sourceDistribution,
          ),
        ),
      ],
    );
  }

  Map<String, double> _calculateStatusDistribution() {
    final distribution = <String, double>{};
    for (final operation in operations) {
      distribution.update(
        operation.paymentStatus,
        (value) => value + operation.totalAmount,
        ifAbsent: () => operation.totalAmount,
      );
    }
    return distribution;
  }

  Map<String, double> _calculateSourceDistribution() {
    final distribution = <String, double>{};
    for (final operation in operations) {
      final source = operation.sourceTable == 'cart_based' ? 'Cart' : 'Order';
      distribution.update(
        source,
        (value) => value + operation.totalAmount,
        ifAbsent: () => operation.totalAmount,
      );
    }
    return distribution;
  }
}

class _DistributionChart extends StatelessWidget {
  final String title;
  final Map<String, double> distribution;

  const _DistributionChart({
    required this.title,
    required this.distribution,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final total = distribution.values.fold(0.0, (sum, value) => sum + value);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ...distribution.entries.map((entry) {
            final percentage = total > 0 ? (entry.value / total * 100) : 0;
            return _DistributionItem(
              label: entry.key,
              percentage: percentage.toDouble(),
              amount: entry.value,
            );
          }),
        ],
      ),
    );
  }
}

class _DistributionItem extends StatelessWidget {
  final String label;
  final double percentage;
  final double amount;

  const _DistributionItem({
    required this.label,
    required this.percentage,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _formatLabel(label),
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: colorScheme.outline.withOpacity(0.1),
            color: _getStatusColor(label, colorScheme),
            borderRadius: BorderRadius.circular(4),
            minHeight: 4,
          ),
        ],
      ),
    );
  }
}

String _formatLabel(String label) {
  return label[0].toUpperCase() + label.substring(1);
}

Color _getStatusColor(String status, ColorScheme colorScheme) {
  switch (status.toLowerCase()) {
    case 'paid':
    case 'fully_paid':
      return colorScheme.primary;
    case 'partial':
    case 'partially_paid':
      return colorScheme.tertiary;
    case 'unpaid':
      return colorScheme.onSurface;
    case 'cart':
      return colorScheme.primary;
    case 'order':
      return colorScheme.secondary;
    default:
      return colorScheme.primary;
  }
}

String _formatCurrency(double amount) {
  return '\$${amount.toStringAsFixed(2)}';
}
