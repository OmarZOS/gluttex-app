import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/finance/BusinessOperation.dart';
import 'package:gluttex_ui/components/business_operations/BusinessOperationUIElements.dart';
import 'package:gluttex_ui/components/business_operations/BusinessOperationsUIManager.dart';

class BusinessOperationsList extends StatelessWidget {
  const BusinessOperationsList({
    super.key,
    required this.operations,
    required this.isLoadingMore,
    required this.hasMore,
    required this.onLoadMore,
    required this.onTapOperation,
  });

  final List<BusinessOperation> operations;
  final bool isLoadingMore;
  final bool hasMore;
  final VoidCallback onLoadMore;
  final ValueChanged<BusinessOperation> onTapOperation;

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: operations.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == operations.length) {
          onLoadMore();
          return const _LoadingMoreIndicator();
        }

        return BusinessOperationCard(
          operation: operations[index],
          isLast: index == operations.length - 1,
          onTap: () => onTapOperation(operations[index]),
        );
      },
    );
  }
}

class BusinessOperationCard extends StatelessWidget {
  const BusinessOperationCard({
    super.key,
    required this.operation,
    required this.isLast,
    required this.onTap,
  });

  final BusinessOperation operation;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, isLast ? 20 : 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withOpacity(0.5),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusRail(status: operation.paymentStatus),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(operation: operation, l10n: l10n),
                      const SizedBox(height: 14),
                      FinancialInfoBlock(operation: operation),
                      const SizedBox(height: 12),
                      DocumentInfoRow(
                        operation: operation,
                        // showLabels: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.operation, required this.l10n});

  final BusinessOperation operation;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                BusinessOperationsUIManager.getOperationTitle(operation, l10n),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                BusinessOperationsUIManager.getOperationSubtitle(
                    operation, l10n),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (operation.operationDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    BusinessOperationsUIManager.formatDate(
                        operation.operationDate!),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SourceBadge(
          source: operation.sourceTable,
          operationType: operation.operationType,
        ),
      ],
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
