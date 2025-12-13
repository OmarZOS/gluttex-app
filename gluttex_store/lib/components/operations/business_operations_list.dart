import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/finance/BusinessOperation.dart';

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
                _StatusRail(status: operation.paymentStatus),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(operation: operation),
                      const SizedBox(height: 14),
                      _FinancialBlock(operation: operation),
                      const SizedBox(height: 12),
                      _DocumentInfo(operation: operation),
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

class _StatusRail extends StatelessWidget {
  const _StatusRail({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(status);

    return Container(
      width: 4,
      height: 110,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Color _colorFor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'fully_paid':
        return Colors.green;
      case 'partial':
        return Colors.orange;
      case 'overdue':
      case 'unpaid':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.operation});
  final BusinessOperation operation;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final l = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _title(l),
                style: t.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _subtitle(l),
                style: t.textTheme.bodySmall?.copyWith(
                  color: t.colorScheme.onSurfaceVariant,
                ),
              ),
              if (operation.operationDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    _formatDate(operation.operationDate!),
                    style: t.textTheme.labelSmall?.copyWith(
                      color: t.colorScheme.outline,
                    ),
                  ),
                ),
            ],
          ),
        ),
        _SourceBadge(
          source: operation.sourceTable,
          operationType: operation.operationType,
        ),
      ],
    );
  }

  String _title(AppLocalizations l) {
    if (operation.invoiceId != null) {
      return '${l.invoice} #${operation.invoiceId}';
    } else if (operation.orderId != null) {
      return '${l.order} #${operation.orderId}';
    } else if (operation.cartId != null) {
      return '${l.cart} #${operation.cartId}';
    }
    return '${l.transaction}';
  }

  String _subtitle(AppLocalizations l) {
    final parts = <String>[];
    if (operation.clientId != null)
      parts.add('${l.client} #${operation.clientId}');
    if (operation.supplierId != 0)
      parts.add('${l.supplier} #${operation.supplierId}');
    if (operation.sellerId != 0)
      parts.add('${l.seller} #${operation.sellerId}');
    return parts.join(' • ');
  }

  String _formatDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
}

class _FinancialBlock extends StatelessWidget {
  const _FinancialBlock({required this.operation});
  final BusinessOperation operation;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final l = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: t.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _Amount(l.balance, operation.balanceDue,
              highlight: operation.balanceDue > 0),
          _Amount(l.paid, operation.totalPaid, color: Colors.green),
          _Amount(l.totalAmount, operation.totalAmount),
        ],
      ),
    );
  }
}

class _Amount extends StatelessWidget {
  const _Amount(this.label, this.value, {this.color, this.highlight = false});

  final String label;
  final double value;
  final Color? color;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final c = color ?? (highlight ? Colors.red : t.colorScheme.onSurface);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: t.textTheme.labelSmall),
          const SizedBox(height: 4),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: t.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: c,
            ),
          ),
        ],
      ),
    );
  }
}

// class BusinessOperationItem extends StatelessWidget {
//   final BusinessOperation operation;
//   final bool isLast;
//   final VoidCallback onTap;

//   const BusinessOperationItem({
//     super.key,
//     required this.operation,
//     required this.isLast,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;

//     return Padding(
//       padding: EdgeInsets.fromLTRB(16, 8, 16, isLast ? 16 : 8),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: colorScheme.surface,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _Header(operation: operation),
//               const SizedBox(height: 12),
//               _DocumentInfo(operation: operation),
//               const SizedBox(height: 12),
//               _FinancialDetails(operation: operation),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _Header extends StatelessWidget {
//   final BusinessOperation operation;

//   const _Header({required this.operation});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final localizations = AppLocalizations.of(context)!;

//     return Row(
//       children: [
//         _StatusBadge(status: operation.paymentStatus),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 _getOperationTitle(operation, localizations),
//                 style: theme.textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.w600,
//                   color: theme.colorScheme.onSurface,
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 _getOperationSubtitle(operation, localizations),
//                 style: theme.textTheme.bodySmall?.copyWith(
//                   color: theme.colorScheme.onSurfaceVariant,
//                 ),
//               ),
//               if (operation.operationDate != null)
//                 Text(
//                   _formatDate(operation.operationDate!),
//                   style: theme.textTheme.bodySmall?.copyWith(
//                     color: theme.colorScheme.onSurfaceVariant,
//                     fontSize: 11,
//                   ),
//                 ),
//             ],
//           ),
//         ),
//         _SourceBadge(
//           source: operation.sourceTable,
//           operationType: operation.operationType,
//         ),
//       ],
//     );
//   }

//   String _getOperationTitle(
//       BusinessOperation operation, AppLocalizations localizations) {
//     if (operation.invoiceId != null) {
//       return '${localizations.invoice} #${operation.invoiceId}';
//     } else if (operation.orderId != null) {
//       return '${localizations.order} #${operation.orderId}';
//     } else if (operation.cartId != null) {
//       return '${localizations.cart} #${operation.cartId}';
//     }
//     return '${localizations.transaction} #${operation.supplierId}';
//   }

//   String _getOperationSubtitle(
//       BusinessOperation operation, AppLocalizations localizations) {
//     final parts = <String>[];
//     if (operation.clientId != null)
//       parts.add('${localizations.client} #${operation.clientId}');
//     if (operation.supplierId != 0)
//       parts.add('${localizations.supplier} #${operation.supplierId}');
//     if (operation.sellerId != 0)
//       parts.add('${localizations.seller} #${operation.sellerId}');
//     return parts.join(' • ');
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
//   }
// }

class _DocumentInfo extends StatelessWidget {
  final BusinessOperation operation;

  const _DocumentInfo({required this.operation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        if (operation.documentType.isNotEmpty &&
            operation.documentType != 'unknown')
          _InfoBadge(
            label: localizations.documentType,
            value: operation.getDocumentTypeDisplay(),
            color: Theme.of(context).colorScheme.primary,
          ),
        if (operation.operationType.isNotEmpty &&
            operation.operationType != 'unknown')
          _InfoBadge(
            label: localizations.operationType,
            value: operation.getOperationTypeDisplay(),
            color: Theme.of(context).colorScheme.secondary,
          ),
        if (operation.invoiceStatus.isNotEmpty &&
            operation.invoiceStatus != 'unknown')
          _InfoBadge(
            label: localizations.invoiceStatus,
            value: operation.invoiceStatus,
            color: _getInvoiceStatusColor(operation.invoiceStatus),
          ),
      ],
    );
  }

  Color _getInvoiceStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'issued':
      case 'paid':
        return Colors.green;
      case 'pending':
      case 'partial':
        return Colors.orange;
      case 'overdue':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _InfoBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// class _StatusBadge extends StatelessWidget {
//   final String status;

//   const _StatusBadge({required this.status});

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final color = getStatusColor(status, colorScheme);

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(_getStatusIcon(status), size: 12, color: color),
//           const SizedBox(width: 4),
//           Text(
//             _formatStatus(status),
//             style: TextStyle(
//               color: color,
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   IconData _getStatusIcon(String status) {
//     switch (status.toLowerCase()) {
//       case 'paid':
//       case 'fully_paid':
//         return Icons.check_circle;
//       case 'partial':
//       case 'partially_paid':
//         return Icons.pending;
//       case 'unpaid':
//       case 'overdue':
//         return Icons.error_outline;
//       default:
//         return Icons.help_outline;
//     }
//   }

//   String _formatStatus(String status) {
//     return status.replaceAll('_', ' ').split(' ').map((word) {
//       return word[0].toUpperCase() + word.substring(1);
//     }).join(' ');
//   }

//   Color getStatusColor(String status, ColorScheme colorScheme) {
//     switch (status.toLowerCase()) {
//       case 'paid':
//       case 'fully_paid':
//         return Colors.green;
//       case 'partial':
//       case 'partially_paid':
//         return Colors.orange;
//       case 'unpaid':
//         return Colors.red;
//       case 'overdue':
//         return Colors.deepOrange;
//       default:
//         return colorScheme.primary;
//     }
//   }
// }

class _SourceBadge extends StatelessWidget {
  final String source;
  final String operationType;

  const _SourceBadge({
    required this.source,
    required this.operationType,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context)!;

    String getBadgeText() {
      if (source == 'cart_based') return localizations.cart;
      if (source == 'order_based') return localizations.order;
      return source;
    }

    Color getBadgeColor() {
      switch (operationType.toLowerCase()) {
        case 'products':
          return colorScheme.primary;
        case 'services':
          return colorScheme.secondary;
        case 'mixed':
          return colorScheme.tertiary;
        default:
          return colorScheme.primary;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: getBadgeColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        getBadgeText(),
        style: TextStyle(
          color: getBadgeColor(),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// class _FinancialDetails extends StatelessWidget {
//   final BusinessOperation operation;

//   const _FinancialDetails({required this.operation});

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final localizations = AppLocalizations.of(context)!;

//     return Column(
//       children: [
//         Row(
//           children: [
//             _FinancialColumn(
//               label: localizations.totalAmount,
//               value: _formatCurrency(operation.totalAmount),
//               color: colorScheme.onSurface,
//             ),
//             const SizedBox(width: 16),
//             _FinancialColumn(
//               label: localizations.paid,
//               value: _formatCurrency(operation.totalPaid),
//               color: Colors.green,
//             ),
//             const SizedBox(width: 16),
//             _FinancialColumn(
//               label: localizations.balance,
//               value: _formatCurrency(operation.balanceDue),
//               color: operation.balanceDue > 0
//                   ? colorScheme.inverseSurface
//                   : colorScheme.onSurface,
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         if (operation.totalDeposited > 0)
//           Row(
//             children: [
//               _FinancialColumn(
//                 label: localizations.deposited,
//                 value: _formatCurrency(operation.totalDeposited),
//                 color: Colors.blue,
//               ),
//             ],
//           ),
//       ],
//     );
//   }

//   String _formatCurrency(double amount) {
//     return '\$${amount.toStringAsFixed(2)}';
//   }
// }

// class _FinancialColumn extends StatelessWidget {
//   final String label;
//   final String value;
//   final Color color;

//   const _FinancialColumn({
//     required this.label,
//     required this.value,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Expanded(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: theme.textTheme.bodySmall?.copyWith(
//               color: theme.colorScheme.onSurfaceVariant,
//             ),
//           ),
//           const SizedBox(height: 2),
//           Text(
//             value,
//             style: theme.textTheme.bodyLarge?.copyWith(
//               fontWeight: FontWeight.w600,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

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
