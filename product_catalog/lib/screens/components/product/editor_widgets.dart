// lib/screens/product_details/editor_widgets.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gluttex_localizations/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/Product.dart';

// ==================================================================
// Hero strip
// ==================================================================

class EditorHero extends StatelessWidget {
  final Product product;
  final bool isRTL;

  const EditorHero({
    super.key,
    required this.product,
    required this.isRTL,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final hasImage = _isValidImage(product.product_image_url);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.primary.withOpacity(0.08), cs.surface],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 110,
              height: 110,
              color: cs.surfaceVariant,
              child: hasImage
                  ? Image.network(
                      product.product_image_url!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(cs),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    )
                  : _placeholder(cs),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Badge(
                  label: isRTL ? 'وضع المحرر' : 'Editor mode',
                  color: cs.tertiary,
                ),
                const SizedBox(height: 10),
                if ((product.product_brand ?? '').isNotEmpty)
                  Text(
                    product.product_brand!,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  product.product_name ?? '',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if ((product.product_category_name ?? '').isNotEmpty)
                      _Pill(
                        label: product.product_category_name!,
                        color: cs.secondary,
                      ),
                    if ((product.product_quantifier ?? '').isNotEmpty)
                      _Pill(
                        label: product.product_quantifier!,
                        color: cs.onSurfaceVariant,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static bool _isValidImage(String? url) =>
      url != null && url.isNotEmpty && url.startsWith('http');

  Widget _placeholder(ColorScheme cs) {
    return Center(
      child: Icon(
        Icons.image_outlined,
        size: 36,
        color: cs.onSurfaceVariant.withOpacity(0.5),
      ),
    );
  }
}

// ==================================================================
// Pricing hero: base price + final price + margin
// ==================================================================

class PricingHero extends StatelessWidget {
  final Product product;

  const PricingHero({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final base = product.product_base_price ?? 0;
    final finalPrice = product.product_price ?? 0;
    final margin = product.unitMargin;
    final marginPct = product.unitMarginPercent;
    final hasBase = base > 0;
    final marginColor = (margin ?? 0) >= 0 ? const Color(0xFF1E8E5A) : cs.error;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.05),
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
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.payments_outlined,
                  size: 16,
                  color: cs.primary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Pricing',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _BigPrice(
                  label: 'Base price',
                  caption: 'Supplier cost',
                  value: hasBase ? base : null,
                  color: cs.onSurfaceVariant,
                ),
              ),
              Container(
                width: 1,
                height: 56,
                color: cs.outlineVariant.withOpacity(0.5),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _BigPrice(
                  label: 'Final price',
                  caption: 'Customer pays',
                  value: finalPrice > 0 ? finalPrice : null,
                  color: cs.primary,
                  alignEnd: true,
                ),
              ),
            ],
          ),
          if (hasBase) ...[
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _KpiPill(
                    label: 'Margin',
                    value: margin == null
                        ? '—'
                        : '${margin >= 0 ? '+' : ''}${margin.toStringAsFixed(2)}',
                    color: marginColor,
                    icon: (margin ?? 0) >= 0
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _KpiPill(
                    label: 'Margin %',
                    value: marginPct == null
                        ? '—'
                        : '${(marginPct * 100).toStringAsFixed(1)}%',
                    color: marginColor,
                    icon: Icons.percent_rounded,
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: cs.tertiaryContainer.withOpacity(0.35),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: cs.onTertiaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Set a base price to see margin and ROI',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onTertiaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ==================================================================
// Actions
// ==================================================================

class EditorActions extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onToggleVisibility;
  final bool isVisible;

  const EditorActions({
    super.key,
    required this.onEdit,
    required this.onToggleVisibility,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: Text(loc.edit),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onToggleVisibility,
            icon: Icon(
              isVisible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 18,
            ),
            label: Text(isVisible ? 'Hide' : 'Show'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: cs.outline.withOpacity(0.4)),
            ),
          ),
        ),
      ],
    );
  }
}

// ==================================================================
// Stock
// ==================================================================

class StockCard extends StatelessWidget {
  final Product product;

  const StockCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final stock = product.product_quantity ?? 0;
    final reserved = product.product_reserved_quantity ?? 0;
    final available = product.product_available_quantity;
    final total = stock > 0 ? stock : 1;
    final reservedRatio = (reserved / total).clamp(0.0, 1.0);
    final availableRatio = (available / total).clamp(0.0, 1.0);

    return _SectionCard(
      icon: Icons.inventory_2_outlined,
      title: 'Stock',
      trailing: _Pill(
        label: available > 0 ? 'In stock' : 'Out of stock',
        color: available > 0 ? const Color(0xFF1E8E5A) : cs.error,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  Expanded(
                    flex: (availableRatio * 1000).round().clamp(1, 1000),
                    child: const ColoredBox(
                      color: Color(0xFF1E8E5A),
                    ),
                  ),
                  if (reserved > 0)
                    Expanded(
                      flex: (reservedRatio * 1000).round().clamp(1, 1000),
                      child: ColoredBox(color: cs.tertiary),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _Stat(
                  label: 'Total',
                  value: '$stock',
                  color: cs.onSurface,
                ),
              ),
              Expanded(
                child: _Stat(
                  label: 'Reserved',
                  value: '$reserved',
                  color: cs.tertiary,
                ),
              ),
              Expanded(
                child: _Stat(
                  label: 'Available',
                  value: '$available',
                  color: available > 0 ? const Color(0xFF1E8E5A) : cs.error,
                  bold: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// Metadata
// ==================================================================

class MetadataCard extends StatelessWidget {
  final Product product;

  const MetadataCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final entries = <_MetaEntry>[
      _MetaEntry(
        icon: Icons.tag,
        label: 'ID',
        value: '${product.id_product ?? '—'}',
      ),
      _MetaEntry(
        icon: Icons.category_outlined,
        label: 'Category',
        value: product.product_category_name ?? '—',
      ),
      _MetaEntry(
        icon: Icons.qr_code,
        label: 'Barcode',
        value: product.product_barcode ?? '—',
      ),
      _MetaEntry(
        icon: Icons.straighten,
        label: 'Unit',
        value: product.product_quantifier ?? '—',
      ),
      _MetaEntry(
        icon: Icons.storefront_outlined,
        label: 'Provider',
        value: '${product.product_provider_id ?? '—'}',
      ),
      _MetaEntry(
        icon: Icons.person_outline,
        label: 'Owner',
        value: '${product.product_owner_id ?? '—'}',
      ),
      _MetaEntry(
        icon: Icons.public,
        label: 'Origin',
        value: '${product.product_origin_id ?? '—'}',
      ),
      _MetaEntry(
        icon: Icons.visibility_outlined,
        label: 'Visibility',
        value: product.isVisible ? 'Visible' : 'Hidden',
      ),
    ];

    return _SectionCard(
      icon: Icons.info_outline,
      title: 'Product metadata',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: entries.map((e) => _MetaChip(entry: e)).toList(),
      ),
    );
  }
}

// ==================================================================
// Danger zone
// ==================================================================

class DangerZoneCard extends StatelessWidget {
  final VoidCallback onDelete;

  const DangerZoneCard({super.key, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.errorContainer.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.error.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 18, color: cs.error),
              const SizedBox(width: 8),
              Text(
                'Danger zone',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Deleting a product removes it from the catalog. '
            'Orders that reference it keep their historical record.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, size: 18),
              label: Text(loc.delete),
              style: FilledButton.styleFrom(
                backgroundColor: cs.error,
                foregroundColor: cs.onError,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// Building blocks
// ==================================================================

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    this.trailing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 14, color: cs.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _BigPrice extends StatelessWidget {
  final String label;
  final String caption;
  final double? value;
  final Color color;
  final bool alignEnd;

  const _BigPrice({
    required this.label,
    required this.caption,
    required this.value,
    required this.color,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final crossAxis =
        alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: crossAxis,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value == null ? '—' : value!.toStringAsFixed(2),
          style: theme.textTheme.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
            height: 1.05,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          caption,
          style: theme.textTheme.labelSmall?.copyWith(
            color: cs.onSurfaceVariant.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

class _KpiPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _KpiPill({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
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

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool bold;

  const _Stat({
    required this.label,
    required this.value,
    required this.color,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
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
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _MetaEntry {
  final IconData icon;
  final String label;
  final String value;
  const _MetaEntry({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _MetaChip extends StatelessWidget {
  final _MetaEntry entry;
  const _MetaChip({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(entry.icon, size: 13, color: cs.primary),
          const SizedBox(width: 6),
          Text(
            '${entry.label}: ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          Text(
            entry.value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
