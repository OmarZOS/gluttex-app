import 'package:flutter/material.dart';
import 'package:gluttex_localizations/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/finance/ProvidedService.dart';
import 'package:event/cart_change_notifier.dart';
import 'package:provider_store/components/selling_point/config_sheet/product_configuration_sheet.dart';
import 'package:provider_store/components/selling_point/config_sheet/service_configuration_sheet.dart';
import 'package:provider/provider.dart';

class ItemCardWithConfiguration extends StatelessWidget {
  final dynamic item;
  final bool isProduct;
  final int quantity;
  final VoidCallback onAddToCart;
  final VoidCallback onRemoveFromCart;
  final VoidCallback onConfigure;

  const ItemCardWithConfiguration({
    super.key,
    required this.item,
    required this.isProduct,
    required this.quantity,
    required this.onAddToCart,
    required this.onRemoveFromCart,
    required this.onConfigure,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasQuantity = quantity > 0;

    return AspectRatio(
      aspectRatio: 0.75,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Main content - Clickable to add to cart
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onAddToCart,
                borderRadius: BorderRadius.circular(16),
                child: _ItemContent(
                  item: item,
                  isProduct: isProduct,
                  quantity: quantity,
                  onRemove: onRemoveFromCart,
                ),
              ),
            ),

            // Configuration button - Positioned top right
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: onConfigure,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.settings_rounded,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),

            // Quantity badge - Positioned top left
            if (hasQuantity)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
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
                      quantity.toString(),
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

            // Quantity controls overlay (when quantity > 0)
            if (hasQuantity)
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: _QuantityControls(
                  currentQuantity: quantity,
                  onAdd: onAddToCart,
                  onRemove: onRemoveFromCart,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ItemContent extends StatelessWidget {
  final dynamic item;
  final bool isProduct;
  final int quantity;
  final VoidCallback onRemove;

  const _ItemContent({
    required this.item,
    required this.isProduct,
    required this.quantity,
    required this.onRemove,
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
            context,
            icon: Icons.inventory_2_rounded,
            colorScheme: colorScheme,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                12,
                12,
                12,
                hasQuantity ? 48 : 12,
              ),
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
                    ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${price.toStringAsFixed(2)} ${loc.currencySymbol ?? 'DA'}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            stock > 0 ? loc.inStock(stock) : loc.outOfStock,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: stock > 0 ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      _buildActionButton(
                        context,
                        hasQuantity: hasQuantity,
                        colorScheme: colorScheme,
                        onRemove: onRemove,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      final service = item as ProvidedService;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildImageSection(
            context,
            icon: Icons.handyman_rounded,
            colorScheme: colorScheme,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                12,
                12,
                12,
                hasQuantity ? 48 : 12,
              ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                      _buildActionButton(
                        context,
                        hasQuantity: hasQuantity,
                        colorScheme: colorScheme,
                        onRemove: onRemove,
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
  }

  Widget _buildImageSection(
    BuildContext context, {
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
          child: Icon(
            icon,
            size: 48,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required bool hasQuantity,
    required ColorScheme colorScheme,
    required VoidCallback onRemove,
  }) {
    final cartNotifier = context.read<CartChangeNotifier>();

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: hasQuantity ? colorScheme.tertiary : colorScheme.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: hasQuantity
          ? IconButton(
              icon: const Icon(Icons.remove_shopping_cart_rounded, size: 16),
              color: colorScheme.onTertiary,
              onPressed: onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            )
          : const Icon(
              Icons.add_rounded,
              size: 18,
              color: Colors.white,
            ),
    );
  }
}

class _QuantityControls extends StatelessWidget {
  final int currentQuantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _QuantityControls({
    required this.currentQuantity,
    required this.onAdd,
    required this.onRemove,
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
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _QuantityButton(
            icon: Icons.remove_rounded,
            onTap: onRemove,
            isActive: currentQuantity > 0,
            colorScheme: colorScheme,
          ),
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
          _QuantityButton(
            icon: Icons.add_rounded,
            onTap: onAdd,
            isActive: true,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;
  final ColorScheme colorScheme;

  const _QuantityButton({
    required this.icon,
    required this.onTap,
    required this.isActive,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isActive ? onTap : null,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? colorScheme.onPrimary.withOpacity(0.2)
                : Colors.transparent,
          ),
          child: Icon(
            icon,
            size: 18,
            color: isActive
                ? colorScheme.onPrimary
                : colorScheme.onPrimary.withOpacity(0.4),
          ),
        ),
      ),
    );
  }
}
