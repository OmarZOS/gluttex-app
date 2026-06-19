import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/finance/BusinessOperation.dart';
import 'package:ui/components/business_operations/BusinessOperationsUIManager.dart';
import 'package:ui/components/finance/financial_ui_manager.dart';

/// 状态徽章组件
class PaymentStatusBadge extends StatelessWidget {
  final String status;
  final bool compact;

  const PaymentStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = BusinessOperationsUIManager.getPaymentStatusConfig(status);
    final theme = Theme.of(context);

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: config.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(config.icon, size: 12, color: config.color),
            const SizedBox(width: 4),
            Text(
              config.displayName,
              style: TextStyle(
                color: config.color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: config.color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 16, color: config.color),
          const SizedBox(width: 8),
          Text(
            config.displayName,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: config.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 状态轨道（垂直状态指示器）
class StatusRail extends StatelessWidget {
  final String status;

  const StatusRail({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = BusinessOperationsUIManager.getPaymentStatusConfig(status);

    return Container(
      width: 4,
      height: 110,
      decoration: BoxDecoration(
        color: config.color,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: config.color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}

/// 信息徽章组件（用于文档类型、操作类型等）
class InfoBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData? icon;

  const InfoBadge({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.icon,
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
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          // Text(
          //   '$label: ',
          //   style: theme.textTheme.bodySmall?.copyWith(
          //     color: color,
          //     fontWeight: FontWeight.w600,
          //   ),
          // ),
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

/// 源标签徽章
class SourceBadge extends StatelessWidget {
  final String source;
  final String operationType;
  final bool showIcon;

  const SourceBadge({
    super.key,
    required this.source,
    required this.operationType,
    this.showIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final color = BusinessOperationsUIManager.getSourceBadgeColor(
      operationType,
      theme.colorScheme,
    );
    final config =
        BusinessOperationsUIManager.getOperationTypeConfig(operationType);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon && config.icon != Icons.category) ...[
            Icon(config.icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            config.displayName,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 金额显示组件
class AmountDisplay extends StatelessWidget {
  final String label;
  final double value;
  final Color? color;
  final bool highlight;
  final String? currencySymbol;

  const AmountDisplay({
    super.key,
    required this.label,
    required this.value,
    this.color,
    this.highlight = false,
    this.currencySymbol = 'DZD',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayColor =
        color ?? (highlight ? Colors.red : theme.colorScheme.onSurface);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall),
        const SizedBox(height: 4),
        Text(
          FinancialUIManager.formatCurrency(value, context),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: displayColor,
          ),
        ),
      ],
    );
  }
}

/// 文档信息行（显示文档类型、操作类型、发票状态）
class DocumentInfoRow extends StatelessWidget {
  final BusinessOperation operation;
  final bool showLabels;

  const DocumentInfoRow({
    super.key,
    required this.operation,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final widgets = <Widget>[];

    // 文档类型
    if (operation.documentType.isNotEmpty &&
        operation.documentType != 'unknown') {
      final docConfig = BusinessOperationsUIManager.getDocumentTypeConfig(
          operation.documentType);
      widgets.add(
        InfoBadge(
          label: showLabels ? l10n.documentType : '',
          value: docConfig.displayName,
          color: docConfig.color,
          icon: docConfig.icon,
        ),
      );
    }

    // 操作类型
    if (operation.operationType.isNotEmpty &&
        operation.operationType != 'unknown') {
      // debugPrint(operation.operationType);
      final opConfig = BusinessOperationsUIManager.getOperationTypeConfig(
          operation.operationType);
      widgets.add(
        InfoBadge(
          label: showLabels ? l10n.operationType : '',
          value: opConfig.displayName,
          color: opConfig.color,
          icon: opConfig.icon,
        ),
      );
    }

    // 发票状态
    if (operation.invoiceStatus.isNotEmpty &&
        operation.invoiceStatus != 'unknown') {
      final invConfig = BusinessOperationsUIManager.getInvoiceStatusConfig(
          operation.invoiceStatus);
      widgets.add(
        InfoBadge(
          label: showLabels ? l10n.invoiceStatus : '',
          value: invConfig.displayName,
          color: invConfig.color,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: widgets,
    );
  }
}

/// 财务信息块
class FinancialInfoBlock extends StatelessWidget {
  final BusinessOperation operation;
  final bool showDeposit;

  const FinancialInfoBlock({
    super.key,
    required this.operation,
    this.showDeposit = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AmountDisplay(
                  label: l10n.balance,
                  value: operation.balanceDue,
                  highlight: operation.balanceDue > 0,
                ),
              ),
              Expanded(
                child: AmountDisplay(
                  label: l10n.paid,
                  value: operation.totalPaid,
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: AmountDisplay(
                  label: l10n.totalAmount,
                  value: operation.totalAmount,
                ),
              ),
            ],
          ),
          if (showDeposit && operation.totalDeposited > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Expanded(
                    child: AmountDisplay(
                      label: l10n.deposited,
                      value: operation.totalDeposited,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // static String getLocalizedOperationType(String value, AppLocalizations loc) {
  //   switch (value.toLowerCase()) {
  //     case 'products':
  //     case 'products_only':
  //       return loc.products;

  //     case 'services':
  //     case 'services_only':
  //       return loc.services;

  //     case 'mixed':
  //     case 'mixed_products_services':
  //     case 'products_and_services':
  //       return loc.productsAndServices;

  //     // 订单/购物类型
  //     case 'direct_order':
  //     case 'ecommerce':
  //     case 'online_order':
  //       return loc.eShopping;
  //     default:
  //       return value;
  //   }
  // }
}
