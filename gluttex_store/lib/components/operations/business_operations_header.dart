import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/finance/BusinessOperation.dart';
import 'package:provider/provider.dart';
import 'package:gluttex_event/views/finance_view_model.dart';

class BusinessOperationsHeader extends StatelessWidget {
  const BusinessOperationsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final viewModel = context.watch<FinanceViewModel>();
    final summaries = viewModel.businessSummaries;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.businessOperations,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      localizations.viewAllBusinessTransactions,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _handleExport(context, localizations),
                icon: Icon(Icons.download_rounded, size: 20),
                color: colorScheme.primary,
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.primary.withOpacity(0.1),
                  padding: const EdgeInsets.all(8),
                ),
                tooltip: localizations.exportOperations,
              ),
            ],
          ),
          if (summaries.isNotEmpty) ...[
            const SizedBox(height: 16),
            _TopSuppliers(suppliers: summaries),
          ],
        ],
      ),
    );
  }

  void _handleExport(BuildContext context, AppLocalizations localizations) {
    final viewModel = context.read<FinanceViewModel>();
    viewModel.exportAnalyticsData();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localizations.exportingData),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _TopSuppliers extends StatelessWidget {
  final List<BusinessSummary> suppliers;

  const _TopSuppliers({required this.suppliers});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final topSuppliers = suppliers.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Suppliers',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 32,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: topSuppliers.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final supplier = topSuppliers[index];
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: _getColorForIndex(index, colorScheme),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      supplier.supplierName,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '\$${supplier.totalRevenue.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getColorForIndex(int index, ColorScheme colorScheme) {
    final colors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
    ];
    return colors[index % colors.length];
  }
}
