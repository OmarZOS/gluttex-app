import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gluttex_localizations/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/finance/ProvidedService.dart';

class ItemCardWithConfiguration extends StatelessWidget {
  final dynamic item;
  final bool isProduct;
  final int quantity;
  final VoidCallback onAddToCart;
  final VoidCallback onRemoveFromCart;
  final VoidCallback onRemoveAll;
  final VoidCallback onConfigure;

  const ItemCardWithConfiguration({
    super.key,
    required this.item,
    required this.isProduct,
    required this.quantity,
    required this.onAddToCart,
    required this.onRemoveFromCart,
    required this.onRemoveAll,
    required this.onConfigure,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasQuantity = quantity > 0;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Card body — tap anywhere = +1.
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                onAddToCart();
              },
              borderRadius: BorderRadius.circular(16),
              child: _ItemContent(
                item: item,
                isProduct: isProduct,
                quantity: quantity,
              ),
            ),
          ),

          // Config — top right.
          Positioned(
            top: 8,
            right: 8,
            child: _CircleButton(
              icon: Icons.settings_rounded,
              onTap: onConfigure,
              background: colorScheme.primary.withOpacity(0.15),
              border: colorScheme.primary.withOpacity(0.3),
              foreground: colorScheme.primary,
            ),
          ),

          // Quantity badge — top left.
          if (hasQuantity)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                constraints: const BoxConstraints(minWidth: 24),
                height: 24,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '×$quantity',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ),

          // Controls overlay — bottom. Only when in cart.
          if (hasQuantity)
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: _QuantityControls(
                currentQuantity: quantity,
                onAdd: onAddToCart,
                onRemove: onRemoveFromCart,
                onRemoveAll: onRemoveAll,
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Reusable circular icon button (gear).
// ─────────────────────────────────────────────────────────────

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color background;
  final Color border;
  final Color foreground;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    required this.background,
    required this.border,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: background,
            shape: BoxShape.circle,
            border: Border.all(color: border, width: 1.5),
          ),
          child: Icon(icon, size: 16, color: foreground),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Card content — image, name, brand/description, price, stock.
// ─────────────────────────────────────────────────────────────

class _ItemContent extends StatelessWidget {
  final dynamic item;
  final bool isProduct;
  final int quantity;

  const _ItemContent({
    required this.item,
    required this.isProduct,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasQuantity = quantity > 0;
    final loc = AppLocalizations.of(context)!;

    if (isProduct) {
      final product = item as Product;
      final price = product.product_price ?? 0;
      final stock = product.product_quantity ?? 0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildImageSection(
            icon: Icons.inventory_2_rounded,
            colorScheme: colorScheme,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(12, 12, 12, hasQuantity ? 52 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.product_name ?? 'Unnamed Product',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (product.product_brand != null)
                    Text(
                      product.product_brand!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const Spacer(),
                  Text(
                    '${price.toStringAsFixed(2)} ${loc.currencySymbol ?? 'DA'}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: stock > 0 ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        stock > 0 ? loc.inStock(stock) : loc.outOfStock,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final service = item as ProvidedService;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildImageSection(
          icon: Icons.handyman_rounded,
          colorScheme: colorScheme,
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(12, 12, 12, hasQuantity ? 52 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (service.description.isNotEmpty)
                  Text(
                    service.description,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const Spacer(),
                Text(
                  '${service.finalPrice.toStringAsFixed(2)} ${loc.currencySymbol ?? 'DA'}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      service.durationFormatted,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection({
    required IconData icon,
    required ColorScheme colorScheme,
  }) {
    return AspectRatio(
      aspectRatio: 5 / 3,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.1),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Center(
          child: Icon(icon, size: 48, color: colorScheme.primary),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Overlay: [−]  N  [+]  |  [🗑]
// ─────────────────────────────────────────────────────────────

class _QuantityControls extends StatelessWidget {
  final int currentQuantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onRemoveAll;

  const _QuantityControls({
    required this.currentQuantity,
    required this.onAdd,
    required this.onRemove,
    required this.onRemoveAll,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.95),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Minus
          _OverlayIconButton(
            icon: Icons.remove_rounded,
            onTap: currentQuantity > 0 ? onRemove : null,
            colorScheme: colorScheme,
          ),

          // Quantity label
          Expanded(
            child: Center(
              child: Text(
                currentQuantity.toString(),
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          // Plus
          _OverlayIconButton(
            icon: Icons.add_rounded,
            onTap: onAdd,
            colorScheme: colorScheme,
          ),

          // Divider
          Container(
            width: 1,
            height: 20,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            color: colorScheme.onPrimary.withOpacity(0.3),
          ),

          // Trash
          _OverlayIconButton(
            icon: Icons.delete_outline_rounded,
            onTap: onRemoveAll,
            colorScheme: colorScheme,
            tint: colorScheme.error,
          ),

          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _OverlayIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final ColorScheme colorScheme;
  final Color? tint;

  const _OverlayIconButton({
    required this.icon,
    required this.onTap,
    required this.colorScheme,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final iconColor = tint ?? colorScheme.onPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled
            ? () {
                HapticFeedback.selectionClick();
                onTap!();
              }
            : null,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: enabled
                ? colorScheme.onPrimary.withOpacity(0.15)
                : Colors.transparent,
          ),
          child: Icon(
            icon,
            size: 18,
            color: enabled ? iconColor : iconColor.withOpacity(0.35),
          ),
        ),
      ),
    );
  }
}
