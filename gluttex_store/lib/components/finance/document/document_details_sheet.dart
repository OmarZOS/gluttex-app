// lib/views/finance/widgets/document_details_sheet.dart
import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/finance/FinancialDocument.dart';
import 'package:gluttex_ui/components/finance/financial_ui_manager.dart';
import 'package:gluttex_ui/screens/payment_form_screen.dart';

class DocumentDetailsSheet extends StatelessWidget {
  final FinancialDocument document;

  const DocumentDetailsSheet({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final documentColor =
        FinancialUIManager.getDocumentColor(document.documentType, theme);
    AppLocalizations loc = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: -5,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with gradient
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        documentColor.withOpacity(0.15),
                        documentColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: documentColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          FinancialUIManager.getDocumentIcon(
                            document.documentType,
                          ),
                          color: documentColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              FinancialUIManager.getDocumentTypeDisplay(
                                document.documentType,
                              ),
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: documentColor,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              document.documentNumber,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: FinancialUIManager.getPaymentStatusColor(
                                  document.paymentStatus, theme)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: FinancialUIManager.getPaymentStatusColor(
                                    document.paymentStatus, theme)
                                .withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          FinancialUIManager.getPaymentStatusDisplay(
                            document.paymentStatus,
                          ).toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: FinancialUIManager.getPaymentStatusColor(
                                document.paymentStatus, theme),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Key metrics in a beautiful grid
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.1),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildMetricItem(
                          theme: theme,
                          label: 'Total',
                          value: FinancialUIManager.formatCurrency(
                              document.documentAmount, context),
                          icon: Icons.attach_money_rounded,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        color: theme.colorScheme.outline.withOpacity(0.1),
                      ),
                      Expanded(
                        child: _buildMetricItem(
                          theme: theme,
                          label: 'Paid',
                          value: FinancialUIManager.formatCurrency(
                              document.totalPaid, context),
                          icon: Icons.check_circle_rounded,
                          color: Colors.green,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        color: theme.colorScheme.outline.withOpacity(0.1),
                      ),
                      Expanded(
                        child: _buildMetricItem(
                          theme: theme,
                          label: 'Balance',
                          value: FinancialUIManager.formatCurrency(
                              document.outstandingBalance, context),
                          icon: Icons.balance_rounded,
                          color: document.outstandingBalance > 0
                              ? Colors.orange
                              : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Payment progress with beautiful design
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Payment Progress',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${((document.totalPaid + document.totalDeposited) / document.documentAmount * 100).toStringAsFixed(1)}%',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Stack(
                        children: [
                          FractionallySizedBox(
                            widthFactor:
                                (document.totalPaid + document.totalDeposited) /
                                    document.documentAmount,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.primaryContainer,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Paid + Deposited',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          FinancialUIManager.formatCurrency(
                              document.totalPaid + document.totalDeposited,
                              context),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Important details
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.1),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Document Details',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        theme: theme,
                        label: 'Issue Date',
                        value: FinancialUIManager.formatDate(
                          document.issueDate,
                        ),
                        icon: Icons.calendar_month_rounded,
                      ),
                      if (document.dueDate != null)
                        _buildDetailRow(
                          theme: theme,
                          label: 'Due Date',
                          value: FinancialUIManager.formatDate(
                            document.dueDate!,
                          ),
                          icon: Icons.timer_rounded,
                          valueColor: document.isOverdue
                              ? Colors.red
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      _buildDetailRow(
                        theme: theme,
                        label: 'Customer',
                        value: FinancialUIManager.getCustomerTypeDisplay(
                          document.customerType,
                        ),
                        icon: FinancialUIManager.getCustomerTypeIcon(
                          document.customerType,
                        ),
                      ),
                      _buildDetailRow(
                        theme: theme,
                        label: 'Days Issued',
                        value: document.daysIssued.toString(),
                        icon: Icons.history_rounded,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action buttons with prominent payment button
                Column(
                  children: [
                    // if (document.outstandingBalance > 0)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          // Navigate to payment form with this document
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentFormScreen(
                                sourceDocument: document,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.payment_rounded),
                        label: Text(
                          'Pay ${loc.price(document.outstandingBalance.toStringAsFixed(2))}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                          shadowColor:
                              theme.colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Share document
                            },
                            icon: const Icon(Icons.share_rounded),
                            label: const Text('Share'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {
                              // Download document
                            },
                            icon: const Icon(Icons.download_rounded),
                            label: const Text('Download'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required ThemeData theme,
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color.withOpacity(0.8)),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required ThemeData theme,
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: valueColor ?? theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
