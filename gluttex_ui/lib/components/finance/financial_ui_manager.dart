// financial_ui_manager.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/finance/FinancialDocument.dart';
import 'package:gluttex_event/finance_change_notifier.dart';

class FinancialUIManager {
  // Colors
  static const Color paidColor = Color(0xFF10B981); // Green
  static const Color partialColor = Color(0xFFF59E0B); // Amber
  static const Color unpaidColor = Color(0xFFEF4444); // Red
  static const Color pendingColor = Color(0xFF6B7280); // Gray
  static const Color canceledColor = Color(0xFF374151); // Dark Gray
  static const Color depositColor = Color(0xFF8B5CF6); // Violet
  static const Color infoColor = Color(0xFF3B82F6); // Blue

  // Icons
  static const IconData invoiceIcon = Icons.receipt_long;
  static const IconData depositIcon = Icons.account_balance_wallet;
  static const IconData cartIcon = Icons.shopping_cart;
  static const IconData receiptIcon = Icons.description;
  static const IconData userIcon = Icons.person;
  static const IconData personIcon = Icons.person_outline;
  static const IconData paymentIcon = Icons.payment;
  static const IconData calendarIcon = Icons.calendar_today;
  static const IconData moneyIcon = Icons.attach_money;
  static const IconData supplierIcon = Icons.store;
  static const IconData statusIcon = Icons.circle;

  // Text Styles
  static TextStyle titleStyle(BuildContext context) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle subtitleStyle(BuildContext context) => TextStyle(
        fontSize: 12,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      );

  static TextStyle amountStyle(BuildContext context) => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle smallAmountStyle(BuildContext context) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface,
      );

  // Document Type Methods
  static String getDocumentTypeDisplay(String documentType,
      [AppLocalizations? localizations]) {
    switch (documentType) {
      case 'invoice':
        return localizations?.invoice ?? 'Invoice';
      case 'deposit':
        return localizations?.deposit ?? 'Deposit';
      case 'pending_cart':
        return localizations?.pendingCart ?? 'Pending Cart';
      case 'cart_with_payments':
        return localizations?.paidCart ?? 'Paid Cart';
      case 'receipt':
        return localizations?.receipt ?? 'Receipt';
      case 'quote':
        return localizations?.quote ?? 'Quote';
      case 'order':
        return localizations?.order ?? 'Order';
      default:
        return documentType.replaceAll('_', ' ').capitalize();
    }
  }

  static IconData getDocumentIcon(String documentType) {
    switch (documentType) {
      case 'invoice':
        return invoiceIcon;
      case 'deposit':
        return depositIcon;
      case 'pending_cart':
      case 'cart_with_payments':
        return cartIcon;
      case 'receipt':
        return receiptIcon;
      case 'quote':
        return Icons.description;
      case 'order':
        return Icons.shopping_bag;
      default:
        return Icons.description;
    }
  }

  static Color getDocumentColor(String documentType, ThemeData theme) {
    switch (documentType) {
      case 'invoice':
        return theme.colorScheme.primary;
      case 'deposit':
        return depositColor;
      case 'pending_cart':
        return partialColor;
      case 'receipt':
        return paidColor;
      case 'quote':
        return Colors.orange;
      case 'order':
        return Colors.purple;
      default:
        return infoColor;
    }
  }

  // Payment Status Methods
  static String getPaymentStatusDisplay(String paymentStatus,
      [AppLocalizations? localizations]) {
    final status = paymentStatus.toLowerCase();

    switch (status) {
      // 3-STATE MODEL
      case 'paid':
        return localizations?.paid ?? 'Paid';
      case 'deposited':
        return localizations?.depositReceived ?? 'Deposit Received';
      case 'unpaid':
        return localizations?.unpaid ?? 'Unpaid';

      // Special states (outside the 3-state flow)
      case 'canceled':
      case 'cancelled':
        return localizations?.cancelled ?? 'Cancelled';
      case 'overdue':
        return localizations?.overdue ?? 'Overdue';
      case 'pending':
        return localizations?.pending ?? 'Pending';
      case 'draft':
        return localizations?.draft ?? 'Draft';

      // Legacy statuses for backward compatibility (map to 3-state)
      case 'fully_paid':
      case 'deposit_covers_full':
      case 'deposit_fully_covered':
      case 'fully_paid_invoice':
      case 'fully_paid_deposit_only':
      case 'fully_paid_receipt':
        return localizations?.paid ?? 'Paid';

      case 'partially_paid':
      case 'deposit_partial':
      case 'deposit_received':
      case 'cart_deposit':
      case 'partially_paid_invoice':
      case 'partially_paid_deposit_only':
        return localizations?.depositReceived ?? 'Deposit Received';

      case 'no_deposit':
      case 'pending_payment':
      case 'unpaid_invoice':
        return localizations?.unpaid ?? 'Unpaid';

      default:
        // Try to map unknown statuses to our 3-state model
        if (status.contains('paid')) return localizations?.paid ?? 'Paid';
        if (status.contains('deposit'))
          return localizations?.depositReceived ?? 'Deposit Received';
        return paymentStatus.replaceAll('_', ' ').capitalize();
    }
  }

  static Color getPaymentStatusColor(String paymentStatus, ThemeData theme) {
    final status = paymentStatus.toLowerCase();

    // Canceled state (special)
    if (status.contains('cancel')) return canceledColor;

    // Overdue state (special)
    if (status.contains('overdue')) return theme.colorScheme.error;

    // Draft state (special)
    if (status.contains('draft')) return theme.colorScheme.secondary;

    // Pending state (special)
    if (status.contains('pending')) return pendingColor;

    // Map to 3-state model
    if (status == 'paid' ||
        status.contains('fully_paid') ||
        status.contains('covers_full') ||
        status.contains('fully_covered')) {
      return paidColor;
    }

    if (status == 'deposited' ||
        status.contains('partial') ||
        status.contains('deposit_') ||
        status.contains('received')) {
      // Gradient between deposit and partial colors
      return Color.lerp(depositColor, partialColor, 0.5)!;
    }

    if (status == 'unpaid' ||
        status.contains('no_deposit') ||
        status.contains('pending_payment')) {
      return unpaidColor;
    }

    // Default for unmapped statuses
    return infoColor;
  }

  static IconData getPaymentStatusIcon(String paymentStatus) {
    final status = paymentStatus.toLowerCase();

    // Special states
    if (status.contains('cancel')) return Icons.cancel;
    if (status.contains('overdue')) return Icons.warning;
    if (status.contains('draft')) return Icons.edit_note;
    if (status.contains('pending')) return Icons.schedule;

    // Map to 3-state model
    if (status.contains('paid') ||
        status.contains('fully_paid') ||
        status.contains('covers_full') ||
        status.contains('fully_covered')) {
      return Icons.check_circle;
    }

    if (status == 'deposited' ||
        status.contains('partial') ||
        status.contains('deposit_') ||
        status.contains('received')) {
      return Icons.account_balance_wallet;
    }

    if (status == 'unpaid' ||
        status.contains('no_deposit') ||
        status.contains('pending_payment')) {
      return Icons.pending_actions;
    }

    // Default
    return Icons.circle;
  }

  // Customer Type Methods
  static String getCustomerTypeDisplay(String customerType,
      [AppLocalizations? localizations]) {
    switch (customerType) {
      case 'user':
        return localizations?.user ?? 'User';
      case 'person':
        return localizations?.person ?? 'Person';
      case 'unknown':
        return localizations?.guest ?? 'Guest';
      case 'client':
        return localizations?.client ?? 'Client';
      case 'supplier':
        return localizations?.supplier ?? 'Supplier';
      case 'seller':
        return localizations?.seller ?? 'Seller';
      default:
        return customerType.capitalize();
    }
  }

  static IconData getCustomerTypeIcon(String customerType) {
    switch (customerType) {
      case 'user':
        return userIcon;
      case 'person':
        return personIcon;
      case 'client':
        return Icons.business;
      case 'supplier':
        return supplierIcon;
      case 'seller':
        return Icons.sell;
      default:
        return Icons.person_outline;
    }
  }

  // Source Type Methods
  static String getSourceTypeDisplay(String sourceType,
      [AppLocalizations? localizations]) {
    switch (sourceType) {
      case 'cart_based':
        return localizations?.cart ?? 'Cart';
      case 'order_based':
        return localizations?.order ?? 'Order';
      case 'invoice_based':
        return localizations?.invoice ?? 'Invoice';
      case 'carts_with_payments':
        return localizations?.cart ?? 'Invoice';
      case 'direct_invoice':
        return localizations?.directInvoice ?? 'Direct Invoice';
      case 'service_based':
        return localizations?.serviceBased ?? 'Service Based';
      case 'direct_deposit':
        return localizations?.directDeposit ?? 'Direct Deposit';
      default:
        return sourceType.replaceAll('_', ' ').capitalize();
    }
  }

  // Formatting Methods
  static String formatCurrency(double amount, BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;

    return loc.price(amount.toStringAsFixed(2));
  }

  static String formatDate(DateTime? date, [BuildContext? context]) {
    if (date == null) return '-';

    if (context != null) {
      final localizations = AppLocalizations.of(context);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return localizations?.today ?? 'Today';
      } else if (difference.inDays == 1) {
        return localizations?.yesterday ?? 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} ${localizations?.daysAgo ?? 'days ago'}';
      }
    }

    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDateTime(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('MMM dd, yyyy HH:mm').format(date);
  }

  static String formatDays(int days, [BuildContext? context]) {
    if (days == 0) return AppLocalizations.of(context!)?.today ?? 'Today';
    if (days == 1)
      return AppLocalizations.of(context!)?.yesterday ?? 'Yesterday';
    if (days > 0)
      return '$days ${AppLocalizations.of(context!)?.daysAgo ?? 'days ago'}';
    return '${days.abs()} ${AppLocalizations.of(context!)?.daysFromNow ?? 'days from now'}';
  }

  // UI Components
  static Widget buildStatusBadge({
    required String status,
    required BuildContext context,
    double fontSize = 12,
    AppLocalizations? localizations,
  }) {
    final theme = Theme.of(context);
    final loc = localizations ?? AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: getPaymentStatusColor(status, theme).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: getPaymentStatusColor(status, theme)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            getPaymentStatusIcon(status),
            size: fontSize,
            color: getPaymentStatusColor(status, theme),
          ),
          const SizedBox(width: 4),
          Text(
            getPaymentStatusDisplay(status, loc),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: getPaymentStatusColor(status, theme),
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildAmountChip({
    required double amount,
    required BuildContext context,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.primary;

    return Chip(
      label: Text(
        formatCurrency(amount, context),
        style: TextStyle(
          color: chipColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: chipColor.withOpacity(0.2),
      side: BorderSide(color: chipColor),
    );
  }

  static Widget buildDocumentHeader({
    required BuildContext context,
    required String documentType,
    required String documentNumber,
    required String paymentStatus,
    required VoidCallback? onTap,
    AppLocalizations? localizations,
  }) {
    final theme = Theme.of(context);
    final loc = localizations ?? AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: getDocumentColor(documentType, theme).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  getDocumentIcon(documentType),
                  color: getDocumentColor(documentType, theme),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${getDocumentTypeDisplay(documentType, loc)} • $documentNumber',
                      style: titleStyle(context),
                    ),
                    const SizedBox(height: 4),
                    buildStatusBadge(
                      status: paymentStatus,
                      context: context,
                      localizations: loc,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  static Widget buildFinancialSummaryCard({
    required BuildContext context,
    required double totalAmount,
    required double totalPaid,
    required double totalOutstanding,
    required int totalDocuments,
    bool showTitle = true,
    AppLocalizations? localizations,
  }) {
    final theme = Theme.of(context);
    final loc = localizations ?? AppLocalizations.of(context);

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showTitle) ...[
              Text(
                loc?.financialSummary ?? 'Financial Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem(
                  context: context,
                  label: loc?.total ?? 'Total',
                  value: totalAmount,
                  color: infoColor,
                ),
                _buildSummaryItem(
                  context: context,
                  label: loc?.paid ?? 'Paid',
                  value: totalPaid,
                  color: paidColor,
                ),
                _buildSummaryItem(
                  context: context,
                  label: loc?.due ?? 'Due',
                  value: totalOutstanding,
                  color: unpaidColor,
                ),
                _buildSummaryItem(
                  context: context,
                  label: loc?.count ?? 'Count',
                  value: totalDocuments.toDouble(),
                  color: pendingColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildSummaryItem({
    required BuildContext context,
    required String label,
    required double value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          formatCurrency(value, context),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: subtitleStyle(context),
        ),
      ],
    );
  }

  static Widget buildDetailRow({
    required BuildContext context,
    required String label,
    required String value,
    Color? valueColor,
    IconData? icon,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: subtitleStyle(context),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildPaymentProgress({
    required BuildContext context,
    required double amount,
    required double paid,
    required double deposited,
    AppLocalizations? localizations,
    double height = 8,
  }) {
    final loc = localizations ?? AppLocalizations.of(context);
    final totalReceived = deposited + paid;
    final percentage = amount > 0 ? (totalReceived / amount) : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              loc?.paymentProgress ?? 'Payment Progress',
              style: subtitleStyle(context),
            ),
            Text(
              '${formatCurrency(totalReceived, context)} / ${formatCurrency(amount, context)}',
              style: subtitleStyle(context),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Single progress bar
        LinearProgressIndicator(
          value: percentage.toDouble(),
          minHeight: height,
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(
            percentage >= 1 ? paidColor : depositColor,
          ),
        ),

        const SizedBox(height: 4),

        // Simple percentage text
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${(percentage * 100).toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  static Widget buildCustomerInfo({
    required BuildContext context,
    required String customerType,
    required int customerId,
    int? personId,
    AppLocalizations? localizations,
  }) {
    final loc = localizations ?? AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(getCustomerTypeIcon(customerType),
            size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          '${getCustomerTypeDisplay(customerType, loc)} #${customerType == 'person' ? (personId ?? customerId) : customerId}',
          style: subtitleStyle(context),
        ),
      ],
    );
  }

  static Widget buildFilterChips({
    required BuildContext context,
    required Map<String, bool> selectedFilters,
    required ValueChanged<String> onFilterChanged,
    AppLocalizations? localizations,
  }) {
    final loc = localizations ?? AppLocalizations.of(context);
    final theme = Theme.of(context);

    final filterOptions = {
      'invoice': loc?.invoice ?? 'Invoices',
      'deposit': loc?.deposit ?? 'Deposits',
      'pending_cart': loc?.pendingCart ?? 'Pending Carts',
      'user': loc?.user ?? 'Users',
      'person': loc?.person ?? 'Persons',
      'unpaid': loc?.unpaid ?? 'Unpaid',
      'partially_paid': loc?.partiallyPaid ?? 'Partial',
      'fully_paid': loc?.paid ?? 'Paid',
      'canceled': loc?.cancelled ?? 'Canceled',
      'quote': loc?.quote ?? 'Quotes',
      'receipt': loc?.receipt ?? 'Receipts',
    };

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: filterOptions.entries.map((entry) {
        final isSelected = selectedFilters[entry.key] ?? false;
        final chipColor = getPaymentStatusColor(entry.key, theme);

        return FilterChip(
          label: Text(entry.value),
          selected: isSelected,
          onSelected: (selected) => onFilterChanged(entry.key),
          backgroundColor: isSelected
              ? chipColor.withOpacity(0.1)
              : theme.colorScheme.surfaceVariant,
          selectedColor: chipColor.withOpacity(0.2),
          checkmarkColor: chipColor,
          labelStyle: TextStyle(
            color: isSelected ? chipColor : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  // Empty State Widget
  static Widget buildEmptyState({
    required BuildContext context,
    String? message,
    IconData? icon,
    VoidCallback? onRetry,
    AppLocalizations? localizations,
  }) {
    final theme = Theme.of(context);
    final loc = localizations ?? AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              message ?? loc?.noDocumentsFound ?? 'No documents found',
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(loc?.retry ?? 'Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Loading State Widget
  static Widget buildLoadingState({
    required BuildContext context,
    String? message,
    AppLocalizations? localizations,
  }) {
    final loc = localizations ?? AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            message ?? loc?.loadingDocuments ?? 'Loading documents...',
            style: subtitleStyle(context),
          ),
        ],
      ),
    );
  }

  // Error State Widget
  static Widget buildErrorState({
    required BuildContext context,
    required String message,
    required VoidCallback onRetry,
    AppLocalizations? localizations,
  }) {
    final theme = Theme.of(context);
    final loc = localizations ?? AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              loc?.errorLoadingDocuments ?? 'Error Loading Documents',
              style: titleStyle(context),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: subtitleStyle(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(loc?.again ?? 'Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // Document Card Widget
  static Widget buildDocumentCard({
    required BuildContext context,
    required FinancialDocument document,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
    AppLocalizations? localizations,
  }) {
    final theme = Theme.of(context);
    final loc = localizations ?? AppLocalizations.of(context);
    final documentType = document.documentType ?? 'invoice';
    final status = document.documentStatus ?? 'pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: getDocumentColor(documentType, theme),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            getDocumentIcon(documentType),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                document.documentNumber ?? 'Unknown',
                style: titleStyle(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (document.isOverdue)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${document.daysOverdue}d',
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              (document.supplierId ?? document.customerId) as String,
              style: subtitleStyle(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  formatDate(document.createdAt, context),
                  style: subtitleStyle(context),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: getPaymentStatusColor(status, theme),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    getPaymentStatusDisplay(status, loc).toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatCurrency(document.documentAmount, context),
              style: amountStyle(context),
            ),
            if ((document.documentAmount - document.remainingAmount) > 0)
              Text(
                '${document.paymentPercentage.toStringAsFixed(0)}% ${loc?.partiallyPaid?.toLowerCase() ?? 'paid'}',
                style: smallAmountStyle(context),
              ),
          ],
        ),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }

  // Quick Actions Menu
  static Widget buildQuickActionsMenu({
    required BuildContext context,
    required FinancialDocument document,
    required VoidCallback onViewDetails,
    required VoidCallback onEdit,
    required VoidCallback onShare,
    required VoidCallback onDownload,
    required VoidCallback onMarkAsPaid,
    required VoidCallback onDelete,
    AppLocalizations? localizations,
  }) {
    final loc = localizations ?? AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(Icons.visibility, color: theme.colorScheme.primary),
          title: Text(loc?.viewDetails ?? 'View Details'),
          onTap: onViewDetails,
        ),
        ListTile(
          leading: Icon(Icons.edit, color: theme.colorScheme.primary),
          title: Text(loc?.editDocument ?? 'Edit Document'),
          onTap: onEdit,
        ),
        ListTile(
          leading: Icon(Icons.download, color: theme.colorScheme.primary),
          title: Text(loc?.downloadPdf ?? 'Download PDF'),
          onTap: onDownload,
        ),
        ListTile(
          leading: Icon(Icons.share, color: theme.colorScheme.primary),
          title: Text(loc?.shareDocument ?? 'Share Document'),
          onTap: onShare,
        ),
        if (document.documentStatus?.toLowerCase() != 'paid')
          ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: Text(loc?.markAsPaid ?? 'Mark as Paid'),
            onTap: onMarkAsPaid,
          ),
        const Divider(),
        ListTile(
          leading: Icon(Icons.delete, color: theme.colorScheme.error),
          title: Text(loc?.deleteDocument ?? 'Delete Document'),
          onTap: onDelete,
        ),
      ],
    );
  }
}

// Extension for String capitalization
extension StringExtensions on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
