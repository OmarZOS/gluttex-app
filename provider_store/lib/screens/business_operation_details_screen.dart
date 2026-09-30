// lib/screens/business_operation_details_screen.dart

import 'package:flutter/material.dart';
import 'package:gluttex_localizations/gen_l10n/app_localizations.dart';

import 'package:gluttex_core/business/finance/BusinessOperation.dart';
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
              expandedHeight: 240,
              pinned: true,
              flexibleSpace: _OperationHeader(operation: operation),
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
            SliverToBoxAdapter(child: _OperationBody(operation: operation)),
          ],
        ),
      ),
    );
  }

  void _shareOperation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.sharingOperation)),
    );
  }

  void _printOperation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.printingOperation)),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

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
          title: isCollapsed
              ? Text(
                  _title(context),
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

  String _title(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    if (operation.isCart) {
      return '${loc.cart} #${operation.sourceId}';
    }
    if (operation.isDelivery) {
      return '${loc.order} #${operation.sourceId}';
    }
    return loc.transactionDetails;
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
            _headerColor(colorScheme, operation),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _HeaderIcon(operation: operation, colorScheme: colorScheme),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _HeaderSummary(operation: operation),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _StatusPill(
                      label: operation.status ?? 'unknown',
                      color: _statusColor(operation.status, colorScheme),
                    ),
                    _StatusPill(
                      label: operation.invoiceStatus ?? 'unknown',
                      color: _invoiceStatusColor(
                        operation.invoiceStatus,
                        colorScheme,
                      ),
                    ),
                    _StatusPill(
                      label: operation.sourceType,
                      color: colorScheme.onPrimary.withOpacity(0.85),
                      onColor: colorScheme.onSurface,
                    ),
                    if (operation.invoiceMismatch)
                      _StatusPill(
                        label: 'invoice mismatch',
                        color: Colors.orange,
                      ),
                    if (!operation.paymentStatusConsistent)
                      _StatusPill(
                        label: 'payment mismatch',
                        color: Colors.red,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Color _headerColor(
    ColorScheme cs,
    BusinessOperation op,
  ) {
    final s = (op.invoiceStatus ?? '').toLowerCase();
    switch (s) {
      case 'paid':
        return cs.primary;
      case 'partially_paid':
      case 'partial':
        return cs.secondary;
      case 'unpaid':
        return cs.tertiary;
      default:
        return cs.onSurface;
    }
  }

  static Color _statusColor(String? s, ColorScheme cs) {
    switch ((s ?? '').toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'delivered':
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return cs.error;
      default:
        return cs.onSurfaceVariant;
    }
  }

  static Color _invoiceStatusColor(String? s, ColorScheme cs) {
    switch ((s ?? '').toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'partially_paid':
        return Colors.orange;
      case 'unpaid':
        return cs.error;
      default:
        return cs.onSurfaceVariant;
    }
  }
}

class _HeaderIcon extends StatelessWidget {
  final BusinessOperation operation;
  final ColorScheme colorScheme;

  const _HeaderIcon({required this.operation, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final paid = operation.isPaid;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: colorScheme.onPrimary.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        paid ? Icons.check_circle : Icons.receipt_long,
        size: 30,
        color: colorScheme.onPrimary,
      ),
    );
  }
}

class _HeaderSummary extends StatelessWidget {
  final BusinessOperation operation;

  const _HeaderSummary({required this.operation});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          FinancialUIManager.formatCurrency(operation.grandTotal, context),
          style: theme.textTheme.headlineMedium?.copyWith(
            color: cs.onPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Due ${FinancialUIManager.formatCurrency(operation.dueAmount, context)}'
          '  •  Paid ${FinancialUIManager.formatCurrency(operation.paidAmount, context)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onPrimary.withOpacity(0.9),
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color? onColor;

  const _StatusPill({
    required this.label,
    required this.color,
    this.onColor,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = onColor ?? Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label.replaceAll('_', ' '),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

class _OperationBody extends StatelessWidget {
  final BusinessOperation operation;

  const _OperationBody({required this.operation});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CommercialSection(operation: operation),
          const SizedBox(height: 16),
          _SettlementSection(operation: operation),
          const SizedBox(height: 16),
          _ProfitabilitySection(operation: operation),
          const SizedBox(height: 16),
          _ItemsSection(operation: operation),
          const SizedBox(height: 16),
          _ServicesSection(operation: operation),
          if (operation.invoice != null) ...[
            const SizedBox(height: 16),
            _InvoiceSection(invoice: operation.invoice!),
          ],
          if (operation.delivery != null) ...[
            const SizedBox(height: 16),
            _DeliverySection(delivery: operation.delivery!),
          ],
          if (operation.cart != null) ...[
            const SizedBox(height: 16),
            _CartSection(cart: operation.cart!),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Commercial
// ---------------------------------------------------------------------------

class _CommercialSection extends StatelessWidget {
  final BusinessOperation operation;
  const _CommercialSection({required this.operation});

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Commercial',
      icon: Icons.calculate_outlined,
      children: [
        _Row('Product subtotal', operation.productSubtotal),
        _Row('Service subtotal', operation.serviceSubtotal),
        _Row('Gross subtotal', operation.grossSubtotal, bold: true),
        _Row('Item discount', -operation.itemDiscountAmount),
        _Row('Order discount', -operation.orderDiscountAmount),
        _Row('Discount total', -operation.discountAmount, bold: true),
        _Row('Tax', operation.taxAmount),
        _Row('Delivery revenue', operation.deliveryRevenue),
        const Divider(height: 24),
        _Row(
          'Grand total',
          operation.grandTotal,
          bold: true,
          accent: Theme.of(context).colorScheme.primary,
        ),
        if (operation.invoiceMismatch)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Computed total (${operation.computedGrandTotal.toStringAsFixed(2)}) '
              'differs from invoice total.',
              style: TextStyle(
                color: Colors.orange.shade700,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Settlement
// ---------------------------------------------------------------------------

class _SettlementSection extends StatelessWidget {
  final BusinessOperation operation;
  const _SettlementSection({required this.operation});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return _Section(
      title: 'Settlement',
      icon: Icons.account_balance_wallet_outlined,
      children: [
        _Row('Invoice total', operation.invoiceTotal),
        _Row('Paid', operation.paidAmount, accent: Colors.teal),
        _Row(
          'Due',
          operation.dueAmount,
          bold: true,
          accent: operation.dueAmount > 0 ? Colors.orange : Colors.green,
        ),
        const Divider(height: 24),
        _SimpleRow('Invoice status', operation.invoiceStatus ?? '—'),
        _SimpleRow(
          'Payment consistency',
          operation.paymentStatusConsistent ? 'OK' : 'Mismatch',
          valueColor: operation.paymentStatusConsistent ? cs.primary : cs.error,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Profitability
// ---------------------------------------------------------------------------

class _ProfitabilitySection extends StatelessWidget {
  final BusinessOperation operation;
  const _ProfitabilitySection({required this.operation});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final margin = operation.marginAmount;
    final roi = operation.roi;

    return _Section(
      title: 'Profitability',
      icon: Icons.trending_up,
      children: [
        _Row('Product cost', operation.productCost),
        _Row('Consumable service cost', operation.consumableServiceCost),
        _Row('Non-consumable (amortized)', operation.nonConsumableServiceCost),
        _Row('Labor cost', operation.laborCost),
        _Row('Delivery cost', operation.deliveryCost),
        _Row('Total cost', operation.totalCost, bold: true),
        const Divider(height: 24),
        _Row(
          'Margin',
          margin,
          bold: true,
          accent: margin >= 0 ? Colors.green : cs.error,
        ),
        _SimpleRow(
          'ROI',
          roi == null ? '—' : '${(roi * 100).toStringAsFixed(1)}%',
          valueColor: roi == null
              ? cs.onSurfaceVariant
              : (roi >= 0 ? Colors.green : cs.error),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Items
// ---------------------------------------------------------------------------

class _ItemsSection extends StatelessWidget {
  final BusinessOperation operation;
  const _ItemsSection({required this.operation});

  @override
  Widget build(BuildContext context) {
    if (operation.items.isEmpty) return const SizedBox.shrink();
    return _Section(
      title: 'Items (${operation.itemCount})',
      icon: Icons.inventory_2_outlined,
      children: operation.items.map(_itemTile).toList(),
    );
  }

  Widget _itemTile(Map<String, dynamic> item) {
    final product = item['ordered_product'] as Map<String, dynamic>?;
    final name =
        product?['product_name'] ?? 'Product #${item['ordered_product_id']}';
    final qty = item['ordered_quantity'];
    final price = item['unit_price'];
    final vat = item['applied_vat'];
    final discount = item['product_discount'];
    final status = item['ordered_item_delivery_status'];

    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '× $qty',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'unit $price  ·  vat $vat%'
                '${discount != null ? '  ·  discount $discount' : ''}'
                '${status != null ? '  ·  $status' : ''}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Services
// ---------------------------------------------------------------------------

class _ServicesSection extends StatelessWidget {
  final BusinessOperation operation;
  const _ServicesSection({required this.operation});

  @override
  Widget build(BuildContext context) {
    if (operation.services.isEmpty) return const SizedBox.shrink();
    return _Section(
      title: 'Services (${operation.serviceCount})',
      icon: Icons.handyman_outlined,
      children: operation.services.map(_serviceTile).toList(),
    );
  }

  Widget _serviceTile(Map<String, dynamic> service) {
    final svc = service['ordered_service_service'] as Map<String, dynamic>?;
    final name = svc?['provided_service_name'] ??
        'Service #${service['ordered_service_service_id']}';
    final qty = service['ordered_service_quantity'];
    final total = service['ordered_service_total_price'];
    final scheduled = service['ordered_service_scheduled_at'];
    final status = service['ordered_service_delivery_status'];

    final resourceReqs =
        (svc?['service_resource_requirement'] as List<dynamic>?) ?? const [];

    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text('× $qty', style: theme.textTheme.bodySmall),
                  const SizedBox(width: 8),
                  Text('$total', style: theme.textTheme.bodyMedium),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                [
                  if (scheduled != null) 'scheduled $scheduled',
                  if (status != null) status,
                ].join('  ·  '),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (resourceReqs.isNotEmpty) ...[
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: resourceReqs.map((r) {
                      final rr = r as Map<String, dynamic>;
                      final consumable =
                          rr['service_resource_requirement_is_consumable'] ==
                                  1 ||
                              rr['service_resource_requirement_is_consumable'] ==
                                  true;
                      return Text(
                        '• ${rr['service_resource_requirement_name']} '
                        '× ${rr['service_resource_requirement_quantity']} '
                        '${consumable ? "(consumable)" : "(amortized)"}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Invoice / Delivery / Cart sub-payloads
// ---------------------------------------------------------------------------

class _InvoiceSection extends StatelessWidget {
  final Map<String, dynamic> invoice;
  const _InvoiceSection({required this.invoice});

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Invoice',
      icon: Icons.description_outlined,
      children: [
        _SimpleRow('Number', '${invoice['invoice_number'] ?? '—'}'),
        _SimpleRow('Status', '${invoice['invoice_status'] ?? '—'}'),
        _SimpleRow('Total', '${invoice['invoice_total_amount'] ?? 0}'),
        _SimpleRow('Issue date', '${invoice['invoice_issue_date'] ?? '—'}'),
        _SimpleRow('Due date', '${invoice['invoice_due_date'] ?? '—'}'),
        _SimpleRow('Type', '${invoice['invoice_type'] ?? '—'}'),
      ],
    );
  }
}

class _DeliverySection extends StatelessWidget {
  final Map<String, dynamic> delivery;
  const _DeliverySection({required this.delivery});

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Delivery',
      icon: Icons.local_shipping_outlined,
      children: [
        _SimpleRow('Delivery ID', '${delivery['id_delivery'] ?? '—'}'),
        _SimpleRow('Status', '${delivery['delivery_status'] ?? '—'}'),
        _SimpleRow('Method', '${delivery['delivery_shipping_method'] ?? '—'}'),
        _SimpleRow('Fee', '${delivery['delivery_fee'] ?? 0}'),
        _SimpleRow('Source type', '${delivery['delivery_source_type'] ?? '—'}'),
        _SimpleRow('Created', '${delivery['delivery_created_at'] ?? '—'}'),
      ],
    );
  }
}

class _CartSection extends StatelessWidget {
  final Map<String, dynamic> cart;
  const _CartSection({required this.cart});

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Cart',
      icon: Icons.shopping_cart_outlined,
      children: [
        _SimpleRow('Cart ID', '${cart['cart_id'] ?? '—'}'),
        _SimpleRow('Status', '${cart['cart_status'] ?? '—'}'),
        _SimpleRow('Total', '${cart['cart_total_amount'] ?? 0}'),
        _SimpleRow('Created', '${cart['cart_created_at'] ?? '—'}'),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared layout primitives
// ---------------------------------------------------------------------------

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _Section({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      elevation: 0,
      color: cs.surfaceVariant.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final double value;
  final bool bold;
  final Color? accent;

  const _Row(this.label, this.value, {this.bold = false, this.accent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = accent ?? theme.colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
          Text(
            FinancialUIManager.formatCurrency(value, context),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SimpleRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SimpleRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: valueColor ?? theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
