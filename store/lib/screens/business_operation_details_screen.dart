import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/finance/BusinessOperation.dart';
import 'package:gluttex_core/business/finance/Order.dart';
import 'package:store/components/operations/business_operations_list.dart';
import 'package:store/components/operations/details/operation_body.dart';
import 'package:ui/components/finance/financial_ui_manager.dart';

class OperationDetailsScreen extends StatelessWidget {
  final BusinessOperation operation;

  const OperationDetailsScreen({super.key, required this.operation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              flexibleSpace: _OperationHeader(operation: operation),
              pinned: true,
              actions: [
                IconButton(
                  onPressed: () => _shareOperation(context),
                  icon: const Icon(Icons.share),
                  tooltip: AppLocalizations.of(context)!.share,
                ),
                IconButton(
                  onPressed: () => _printOperation(context),
                  icon: const Icon(Icons.print),
                  tooltip: AppLocalizations.of(context)!.print,
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: OperationBody(operation: operation),
            ),
          ],
        ),
      ),
    );
  }

  void _shareOperation(BuildContext context) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.sharingOperation)),
    );
  }

  void _printOperation(BuildContext context) {
    // TODO: Implement print functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.printingOperation)),
    );
  }
}

class _OperationHeader extends StatelessWidget {
  final BusinessOperation operation;

  const _OperationHeader({required this.operation});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCollapsed = constraints.biggest.height <= kToolbarHeight + 20;

        return FlexibleSpaceBar(
          collapseMode: CollapseMode.pin,
          titlePadding: const EdgeInsetsDirectional.only(
            start: 56,
            bottom: 16,
            end: 16,
          ),

          // ✅ Title only when collapsed
          title: isCollapsed
              ? Text(
                  _getOperationTitle(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : null,

          background: _HeaderBackground(
            operation: operation,
            colorScheme: colorScheme,
          ),
        );
      },
    );
  }

  String _getOperationTitle(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    if (operation.orderId != null) {
      return '${localizations.order} #${operation.orderId}';
    } else if (operation.cartId != null) {
      return '${localizations.cart} #${operation.cartId}';
    }
    return localizations.transactionDetails;
  }

  Color _getHeaderColor(ColorScheme colorScheme) {
    switch (operation.paymentStatus) {
      case 'paid':
      case 'fully_paid':
        return colorScheme.primary;
      case 'partial':
      case 'partially_paid':
        return colorScheme.secondary;
      case 'unpaid':
        return colorScheme.tertiary;
      default:
        return colorScheme.onSurface;
    }
  }
}

class _HeaderIcon extends StatelessWidget {
  final BusinessOperation operation;
  final ColorScheme colorScheme;

  const _HeaderIcon({required this.operation, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final isPaid = operation.paymentStatus.toLowerCase().contains('paid');

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: colorScheme.onPrimary.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isPaid ? Icons.check_circle : Icons.receipt_long,
        size: 32,
        color: colorScheme.onPrimary,
      ),
    );
  }
}

class _HeaderDetails extends StatelessWidget {
  final BusinessOperation operation;

  const _HeaderDetails({required this.operation});

  String _formatCurrency(double amount, BuildContext context) {
    return FinancialUIManager.formatCurrency(amount, context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _formatCurrency(operation.totalAmount, context),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.headlineLarge?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 34, // ⬅️ reduce slightly
          ),
        ),
        const SizedBox(height: 4),
        _PaymentStatusBadge(operation: operation),
        const SizedBox(height: 8),
        if (operation.sourceTable.isNotEmpty)
          Text(
            operation.sourceTable == 'cart_based'
                ? localizations.cartBasedTransaction
                : localizations.orderBasedTransaction,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimary.withOpacity(0.9),
            ),
          ),
      ],
    );
  }
}

class _PaymentStatusBadge extends StatelessWidget {
  final BusinessOperation operation;

  const _PaymentStatusBadge({required this.operation});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = getStatusColor(operation.paymentStatus, colorScheme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            getStatusIcon(operation.paymentStatus),
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            formatStatus(operation.paymentStatus),
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'fully_paid':
        return Icons.check_circle;
      case 'partial':
      case 'partially_paid':
        return Icons.pending;
      case 'unpaid':
      case 'overdue':
        return Icons.error_outline;
      default:
        return Icons.help_outline;
    }
  }

  Color getStatusColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'fully_paid':
        return colorScheme.primary;
      case 'partial':
      case 'partially_paid':
        return colorScheme.secondary;
      case 'unpaid':
        return colorScheme.tertiary;
      case 'overdue':
        return colorScheme.onSurfaceVariant;
      default:
        return colorScheme.primary;
    }
  }

  String formatStatus(String status) {
    return status.replaceAll('_', ' ').split(' ').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}

class _HeaderBackground extends StatelessWidget {
  final BusinessOperation operation;
  final ColorScheme colorScheme;

  const _HeaderBackground({
    required this.operation,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getHeaderColor(colorScheme, operation),
            colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, kToolbarHeight + 12, 20, 16),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _HeaderIcon(
                  operation: operation,
                  colorScheme: colorScheme,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _HeaderDetails(operation: operation),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Color _getHeaderColor(
      ColorScheme colorScheme, BusinessOperation operation) {
    switch (operation.paymentStatus) {
      case 'paid':
      case 'fully_paid':
        return colorScheme.primary;
      case 'partial':
      case 'partially_paid':
        return colorScheme.secondary;
      case 'unpaid':
        return colorScheme.tertiary;
      default:
        return colorScheme.onSurface;
    }
  }
}
