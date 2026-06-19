import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/finance/BusinessOperation.dart';
import 'package:event/personnel_notifier.dart';
import 'package:event/supplier_change_notifier.dart';
import 'package:ui/components/supplier/SupplierUIProvider.dart';

/// 业务操作UI管理器 - 集中管理所有UI元素和配置
class BusinessOperationsUIManager {
  /// 付款状态枚举和配置
  static final Map<String, PaymentStatusConfig> _paymentStatusConfig = {
    'paid': PaymentStatusConfig(
      displayName: 'Paid',
      color: Colors.green,
      icon: Icons.check_circle,
      priority: 1,
    ),
    'fully_paid': PaymentStatusConfig(
      displayName: 'Fully Paid',
      color: Colors.green,
      icon: Icons.check_circle,
      priority: 1,
    ),
    'partial': PaymentStatusConfig(
      displayName: 'Partial',
      color: Colors.orange,
      icon: Icons.pending,
      priority: 2,
    ),
    'partially_paid': PaymentStatusConfig(
      displayName: 'Partially Paid',
      color: Colors.orange,
      icon: Icons.pending,
      priority: 2,
    ),
    'unpaid': PaymentStatusConfig(
      displayName: 'Unpaid',
      color: Colors.red,
      icon: Icons.error_outline,
      priority: 3,
    ),
    'overdue': PaymentStatusConfig(
      displayName: 'Overdue',
      color: Colors.deepOrange,
      icon: Icons.warning,
      priority: 4,
    ),
  };

  /// 发票状态配置
  static final Map<String, InvoiceStatusConfig> _invoiceStatusConfig = {
    'issued': InvoiceStatusConfig(
      displayName: 'Issued',
      color: Colors.blue,
      priority: 1,
    ),
    'paid': InvoiceStatusConfig(
      displayName: 'Paid',
      color: Colors.green,
      priority: 2,
    ),
    'pending': InvoiceStatusConfig(
      displayName: 'Pending',
      color: Colors.orange,
      priority: 3,
    ),
    'partial': InvoiceStatusConfig(
      displayName: 'Partial',
      color: Colors.amber,
      priority: 4,
    ),
    'unpaid': InvoiceStatusConfig(
      displayName: 'Overdue',
      color: Colors.red,
      priority: 5,
    ),
    'cancelled': InvoiceStatusConfig(
      displayName: 'Cancelled',
      color: Colors.grey,
      priority: 6,
    ),
  };

  /// 操作类型配置
  static final Map<String, OperationTypeConfig> _operationTypeConfig = {
    'products_only': OperationTypeConfig(
      displayName: 'Products',
      color: Colors.blue,
      icon: Icons.shopping_bag,
    ),
    'services_only': OperationTypeConfig(
      displayName: 'Services',
      color: Colors.purple,
      icon: Icons.handyman,
    ),
    'mixed_products_services': OperationTypeConfig(
      displayName: 'Mixed',
      color: Colors.teal,
      icon: Icons.blender,
    ),
    'direct_order': OperationTypeConfig(
      displayName: 'e-Shopping',
      color: Colors.yellow,
      icon: Icons.blender,
    ),
  };

  /// 文档类型配置
  static final Map<String, DocumentTypeConfig> _documentTypeConfig = {
    'invoice': DocumentTypeConfig(
      displayName: 'Invoice',
      color: Colors.indigo,
      icon: Icons.receipt_long,
    ),
    'receipt': DocumentTypeConfig(
      displayName: 'Receipt',
      color: Colors.green,
      icon: Icons.receipt,
    ),
    'deposit': DocumentTypeConfig(
      displayName: 'Deposit',
      color: Colors.cyan,
      icon: Icons.account_balance,
    ),
  };

  /// 获取付款状态配置
  static PaymentStatusConfig getPaymentStatusConfig(String status) {
    return _paymentStatusConfig[status.toLowerCase()] ??
        PaymentStatusConfig(
          displayName: status,
          color: Colors.grey,
          icon: Icons.help_outline,
          priority: 99,
        );
  }

  /// 获取发票状态配置
  static InvoiceStatusConfig getInvoiceStatusConfig(String status) {
    return _invoiceStatusConfig[status.toLowerCase()] ??
        InvoiceStatusConfig(
          displayName: status,
          color: Colors.grey,
          priority: 99,
        );
  }

  /// 获取操作类型配置
  static OperationTypeConfig getOperationTypeConfig(String type) {
    // debugPrint("Comparing between $type");
    // debugPrint("if in ${_operationTypeConfig.keys.toString()}");

    return _operationTypeConfig[type.toLowerCase()] ??
        OperationTypeConfig(
          displayName: type,
          color: Colors.grey,
          icon: Icons.category,
        );
  }

  /// 获取文档类型配置
  static DocumentTypeConfig getDocumentTypeConfig(String type) {
    return _documentTypeConfig[type.toLowerCase()] ??
        DocumentTypeConfig(
          displayName: type,
          color: Colors.grey,
          icon: Icons.description,
        );
  }

  /// 获取源显示文本
  // static String getSourceDisplayText(String source, AppLocalizations l10n) {
  //   switch (source) {
  //     case 'cart_based':
  //       return l10n.cart;
  //     case 'order_based':
  //       return l10n.order;
  //     default:
  //       return source;
  //   }
  // }

  /// 获取操作标题
  static String getOperationTitle(
      BusinessOperation operation, AppLocalizations l10n) {
    if (operation.invoiceId != null) {
      return '${l10n.invoice} #${operation.invoiceId}';
    } else if (operation.orderId != null) {
      return '${l10n.order} #${operation.orderId}';
    } else if (operation.cartId != null) {
      return '${l10n.cart} #${operation.cartId}';
    }
    return '${l10n.transaction}';
  }

  /// 获取操作副标题

  static Future<String> getOperationSubtitle(
      BusinessOperation operation,
      AppLocalizations l10n,
      PersonnelNotifier? personnelNotifier,
      SupplierChangeNotifier supplierNotifier) async {
    final parts = <String>[];

    // Client
    if (operation.clientId != null && personnelNotifier != null) {
      final clientText = await _getClientText(operation.clientId!,
          operation.operationType ?? 'user', l10n.client, personnelNotifier);
      if (clientText.isNotEmpty) parts.add(clientText);
    }

    // Supplier
    if (operation.supplierId != 0) {
      final supplierText = await SupplierUIProvider.getSupplierText(
        operation.supplierId,
        l10n.supplier,
        supplierNotifier,
      );
      if (supplierText.isNotEmpty) parts.add(supplierText);
    }

    // Seller
    if (operation.sellerId != 0 && personnelNotifier != null) {
      final sellerText = await _getSellerText(
          operation.sellerId, l10n.seller, personnelNotifier);
      if (sellerText.isNotEmpty) parts.add(sellerText);
    }

    return parts.isNotEmpty ? parts.join(' • ') : '';
  }

  static Future<String> _getClientText(
    int clientId,
    String clientType,
    String clientLabel,
    PersonnelNotifier personnelNotifier,
  ) async {
    try {
      final client = await personnelNotifier.getCustomerDisplayInfo(
        customerId: clientId,
        customerType: clientType,
        personId: clientId,
      );

      final clientName = client?.displayName?.trim() ?? '';

      return clientName.isNotEmpty ? '$clientLabel: $clientName' : clientLabel;
    } catch (e) {
      debugPrint('Error getting client name: $e');
      return clientLabel;
    }
  }

  static Future<String> _getSellerText(
    int sellerId,
    String sellerLabel,
    PersonnelNotifier personnelNotifier,
  ) async {
    try {
      final customer = await personnelNotifier.getCustomerDisplayInfo(
        customerId: sellerId,
        customerType: 'user',
        personId: null,
      );

      final sellerName = customer?.displayName?.trim() ?? '';

      return sellerName.isNotEmpty ? '$sellerLabel: $sellerName' : sellerLabel;
    } catch (e) {
      debugPrint('Error getting seller name: $e');
      return sellerLabel;
    }
  }

  /// 格式化日期
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// 格式化货币
  // static String formatCurrency(double amount) {
  //   return '${amount.toStringAsFixed(2)}';
  // }

  /// 获取源标签颜色
  static Color getSourceBadgeColor(
      String operationType, ColorScheme colorScheme) {
    switch (operationType.toLowerCase()) {
      case 'products_only':
        return colorScheme.primary;
      case 'mixed_products_services':
        return colorScheme.secondary;
      case 'services_only':
        return colorScheme.tertiary;
      case 'direct_order':
        return colorScheme.onInverseSurface;
      default:
        return colorScheme.primary;
    }
  }
}

/// 付款状态配置模型
class PaymentStatusConfig {
  final String displayName;
  final Color color;
  final IconData icon;
  final int priority;

  const PaymentStatusConfig({
    required this.displayName,
    required this.color,
    required this.icon,
    required this.priority,
  });
}

/// 发票状态配置模型
class InvoiceStatusConfig {
  final String displayName;
  final Color color;
  final int priority;

  const InvoiceStatusConfig({
    required this.displayName,
    required this.color,
    required this.priority,
  });
}

/// 操作类型配置模型
class OperationTypeConfig {
  final String displayName;
  final Color color;
  final IconData icon;

  const OperationTypeConfig({
    required this.displayName,
    required this.color,
    required this.icon,
  });
}

/// 文档类型配置模型
class DocumentTypeConfig {
  final String displayName;
  final Color color;
  final IconData icon;

  const DocumentTypeConfig({
    required this.displayName,
    required this.color,
    required this.icon,
  });
}
