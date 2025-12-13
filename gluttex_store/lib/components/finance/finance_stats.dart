import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/finance/BusinessOperation.dart';
import 'package:gluttex_core/business/finance/Order.dart';

class FinanceStats extends StatelessWidget {
  final List<BusinessOperation> operations;

  const FinanceStats({super.key, required this.operations});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final stats = _calculateStats();

    if (operations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 64,
                color: colorScheme.onSurfaceVariant.withOpacity(0.3),
              ),
              const SizedBox(height: 24),
              Text(
                localizations.noAnalyticsData,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  localizations.generateInvoicesToSeeAnalytics,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  // TODO: Navigate to invoice creation
                },
                icon: Icon(
                  Icons.receipt_long,
                  color: colorScheme.onPrimary,
                ),
                label: Text(
                  localizations.createFirstInvoice,
                  style: TextStyle(color: colorScheme.onPrimary),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSummaryCard(context, stats, localizations),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _buildStatCard(
                context,
                title: localizations.totalRevenue,
                value: _formatCurrency(stats['totalRevenue'], context),
                icon: Icons.euro,
                color: colorScheme.primary,
              ),
              _buildStatCard(
                context,
                title: localizations.totalOrders,
                value: '${stats['totalOrders']}',
                icon: Icons.shopping_cart,
                color: colorScheme.secondary,
              ),
              _buildStatCard(
                context,
                title: localizations.averageOrder,
                value: _formatCurrency(stats['avgOrderValue'], context),
                icon: Icons.analytics,
                color: colorScheme.tertiary,
              ),
              _buildStatCard(
                context,
                title: localizations.taxCollected,
                value: _formatCurrency(stats['taxCollected'], context),
                icon: Icons.account_balance,
                color: colorScheme.inversePrimary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRecentTransactions(context, localizations),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      BuildContext context, Map<String, dynamic> stats, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: colorScheme.onPrimary),
              const SizedBox(width: 8),
              Text(
                l10n.financialOverview,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _formatCurrency(stats['totalRevenue'], context),
            style: theme.textTheme.headlineLarge?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.totalRevenue,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimary.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMiniStat(
                context,
                label: l10n.netProfit,
                value: _formatCurrency(stats['netProfit'], context),
                color: colorScheme.onPrimary,
              ),
              const SizedBox(width: 16),
              _buildMiniStat(
                context,
                label: l10n.growthRate,
                value: '+${stats['growthRate']?.toStringAsFixed(1)}%',
                color: colorScheme.onPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.9),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions(BuildContext context, AppLocalizations l10n) {
    if (operations.isEmpty) return const SizedBox();

    final recentOrders = operations.take(5).toList();
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.recentTransactions,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                l10n.last5Transactions,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...recentOrders.map((operations) {
            return _buildTransactionRow(context, operations);
          }),
          if (operations.length > 5) ...[
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () {
                  // TODO: Navigate to all transactions
                },
                child: Text(
                  l10n.viewAllTransactions,
                  style: TextStyle(color: colorScheme.primary),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTransactionRow(
      BuildContext context, BusinessOperation operation) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final isPaid = operation.paymentStatus.toLowerCase() == 'paid';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPaid
            ? colorScheme.primary.withOpacity(0.05)
            : colorScheme.secondary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isPaid
                  ? colorScheme.primary.withOpacity(0.1)
                  : colorScheme.tertiary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPaid ? Icons.check_circle : Icons.pending,
              size: 16,
              color: isPaid ? colorScheme.primary : colorScheme.tertiary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${operation.sellerId}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  "s",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${operation.balanceDue.toStringAsFixed(2)}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                operation.paymentStatus,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isPaid ? colorScheme.primary : colorScheme.tertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateStats() {
    if (operations.isEmpty) {
      return {
        'totalRevenue': 0.0,
        'totalOrders': 0,
        'avgOrderValue': 0.0,
        'taxCollected': 0.0,
        'netProfit': 0.0,
        'growthRate': 0.0,
      };
    }

    final totalRevenue =
        operations.fold(0.0, (sum, operation) => sum + operation.balanceDue);
    final totalOrders = operations.length;
    final avgOrderValue = totalRevenue / totalOrders;
    final taxCollected = operations.fold(
        0.0, (sum, operation) => sum + (operation.balanceDue * 0.19));
    final netProfit = totalRevenue * 0.8; // Assuming 20% profit margin
    final growthRate = 12.5; // Mock growth rate

    return {
      'totalRevenue': totalRevenue,
      'totalOrders': totalOrders,
      'avgOrderValue': avgOrderValue,
      'taxCollected': taxCollected,
      'netProfit': netProfit,
      'growthRate': growthRate,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatCurrency(double amount, BuildContext context) {
    final localizations = AppLocalizations.of(context);
    // Use your app's currency symbol or get from localizations
    final currencySymbol = localizations?.currencySymbol ?? '\$';

    return '$currencySymbol${amount.toStringAsFixed(2)}';
  }
}
