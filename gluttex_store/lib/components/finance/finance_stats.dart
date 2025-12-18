import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/finance/BusinessOperation.dart';
import 'package:gluttex_event/views/finance_view_model.dart';
import 'package:provider/provider.dart';

class FinanceStats extends StatelessWidget {
  final VoidCallback? onCreateInvoice;
  final VoidCallback? onViewAllTransactions;

  const FinanceStats({
    super.key,
    this.onCreateInvoice,
    this.onViewAllTransactions,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceViewModel>(
      builder: (context, viewModel, child) {
        final operations = viewModel.businessOperations;
        final analytics = viewModel.analyticsCache;

        if (operations.isEmpty || analytics == null) {
          return _buildEmptyState(context, viewModel);
        }

        return _buildContent(context, viewModel, analytics);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, FinanceViewModel viewModel) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

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
            if (viewModel.isCalculatingAnalytics)
              const CircularProgressIndicator()
            else
              FilledButton.icon(
                onPressed: () {
                  viewModel.refreshAnalytics();
                },
                icon: Icon(
                  Icons.refresh,
                  color: colorScheme.onPrimary,
                ),
                label: Text(
                  "localizations.loadAnalyticsData",
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

  Widget _buildContent(
    BuildContext context,
    FinanceViewModel viewModel,
    AnalyticsCache analytics,
  ) {
    final localizations = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Summary Card
          _buildSummaryCard(context, viewModel, analytics, localizations),
          const SizedBox(height: 16),

          // Stats Grid
          _buildStatsGrid(context, analytics, localizations),
          const SizedBox(height: 16),

          // Recent Transactions
          _buildRecentTransactions(context, viewModel, localizations),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    FinanceViewModel viewModel,
    AnalyticsCache analytics,
    AppLocalizations localizations,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    // Calculate growth (simplified - compare with previous period)
    final recentOperations = viewModel.recentOperations;
    final growth =
        recentOperations.length > 5 ? 12.5 : 0.0; // Simplified growth

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
              Icon(
                growth >= 0 ? Icons.trending_up : Icons.trending_down,
                color: colorScheme.onPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                localizations.financialOverview,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _formatCurrency(analytics.totalRevenue, context),
            style: theme.textTheme.headlineLarge?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            localizations.totalRevenue,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimary.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMiniStat(
                context,
                label: "localizations.collectionRate",
                value: '${analytics.collectionRate.toStringAsFixed(1)}%',
                color: colorScheme.onPrimary,
              ),
              const SizedBox(width: 16),
              _buildMiniStat(
                context,
                label: "localizations.totalTransactions",
                value: '${analytics.transactionCount}',
                color: colorScheme.onPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(
    BuildContext context,
    AnalyticsCache analytics,
    AppLocalizations localizations,
  ) {
    final averageTransaction = analytics.transactionCount > 0
        ? analytics.totalRevenue / analytics.transactionCount
        : 0.0;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        // Total Collected Card
        _buildStatCard(
          context,
          title: "localizations.totalCollected",
          value: _formatCurrency(analytics.totalCollected, context),
          icon: Icons.money,
          color: Colors.green,
        ),
        // Total Outstanding Card
        _buildStatCard(
          context,
          title: "localizations.totalOutstanding",
          value: _formatCurrency(analytics.totalOutstanding, context),
          icon: Icons.pending_actions,
          color: Colors.orange,
        ),
        // Average Transaction Card
        _buildStatCard(
          context,
          title: localizations.averageTransaction,
          value: _formatCurrency(averageTransaction, context),
          icon: Icons.analytics,
          color: Theme.of(context).colorScheme.tertiary,
        ),
        // Transactions Count Card
        _buildStatCard(
          context,
          title: localizations.transactions,
          value: '${analytics.transactionCount}',
          icon: Icons.receipt,
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ],
    );
  }

  Widget _buildRecentTransactions(
    BuildContext context,
    FinanceViewModel viewModel,
    AppLocalizations localizations,
  ) {
    final recentOperations = viewModel.recentOperations;
    if (recentOperations.isEmpty) return const SizedBox();

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
                localizations.recentTransactions,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                '${localizations.last} 10 ${localizations.businessOperations}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: recentOperations.map((operation) {
              return _buildOperationRow(context, operation);
            }).toList(),
          ),
          const SizedBox(height: 12),
          if (viewModel.businessOperations.length > 10)
            Center(
              child: TextButton(
                onPressed: onViewAllTransactions,
                child: Text(
                  localizations.viewAllTransactions,
                  style: TextStyle(color: colorScheme.primary),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOperationRow(BuildContext context, BusinessOperation operation) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final isPaid = operation.balanceDue <= 0;
    final sourceName = operation.sourceTable;
    final loc = AppLocalizations.of(context)!;
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
                  '$sourceName #${operation.cartId}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Supplier: ${operation.supplierId ?? 'N/A'}',
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
                loc.price(operation.totalAmount.toStringAsFixed(2)),
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

  String _formatCurrency(double amount, BuildContext context) {
    return AppLocalizations.of(context)!.price(amount.toStringAsFixed(2));
  }
}
