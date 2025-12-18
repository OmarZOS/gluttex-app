import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/finance/Cart.dart';
import 'package:gluttex_core/business/finance/ProvidedService.dart';
import 'package:gluttex_event/cart_change_notifier.dart';
import 'package:provider/provider.dart';

class CartItemsList extends StatelessWidget {
  final ScrollController? scrollController;

  const CartItemsList({
    super.key,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CartChangeNotifier>(
      builder: (context, cartNotifier, child) {
        final cartItems = cartNotifier.cartItems;

        if (cartItems.isEmpty) {
          return const _EmptyCartState();
        }

        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          itemCount: cartItems.length,
          itemBuilder: (context, index) {
            return _CartItemRow(
              cartItem: cartItems[index],
              isLast: index == cartItems.length - 1,
            );
          },
        );
      },
    );
  }
}

class _EmptyCartState extends StatelessWidget {
  const _EmptyCartState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Your cart is empty',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add products to get started',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemRow extends StatelessWidget {
  final CartItem cartItem;
  final bool isLast;

  const _CartItemRow({
    required this.cartItem,
    required this.isLast,
  });

  void _updateQuantity(BuildContext context, int delta) {
    final cartNotifier = context.read<CartChangeNotifier>();
    final newQuantity = cartItem.quantity + delta;

    if (cartItem.product != null) {
      // Update product quantity
      if (newQuantity > 0) {
        cartNotifier.updateQuantity(
          product: cartItem.product!,
          newQuantity: newQuantity,
        );
      } else {
        cartNotifier.removeItem(product: cartItem.product!);
      }
    } else if (cartItem.service != null) {
      // Update service quantity
      if (newQuantity > 0) {
        cartNotifier.updateQuantity(
          service: cartItem.service!,
          newQuantity: newQuantity,
        );
      } else {
        cartNotifier.removeItem(service: cartItem.service!);
      }
    }
  }

  void _removeItem(BuildContext context) {
    final cartNotifier = context.read<CartChangeNotifier>();
    if (cartItem.product != null) {
      cartNotifier.removeItem(product: cartItem.product!);
    } else if (cartItem.service != null) {
      cartNotifier.removeItem(service: cartItem.service!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final product = cartItem.product;
    final service = cartItem.service;
    final itemName = product?.product_name ?? service?.name ?? "";
    final itemPrice =
        (product?.product_price ?? service?.finalPrice ?? 0.0) * 0.81;
    final subtotal = itemPrice * cartItem.quantity;
    final loc = AppLocalizations.of(context)!;

    return Container(
      margin: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: isLast ? 8 : 8,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product/Service Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withOpacity(0.1),
                  colorScheme.primaryContainer.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              product != null ? Icons.inventory : Icons.medical_services,
              color: colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Product/Service Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemName,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  loc.price(itemPrice.toStringAsFixed(2)),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (cartItem.scheduledDate != null ||
                    cartItem.scheduledTime != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${cartItem.scheduledDate ?? ''} ${cartItem.scheduledTime ?? ''}'
                          .trim(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.secondary,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                _QuantityControls(
                  quantity: cartItem.quantity,
                  onDecrease: () => _updateQuantity(context, -1),
                  onIncrease: () => _updateQuantity(context, 1),
                  onRemove: () => _removeItem(context),
                  colorScheme: colorScheme,
                ),
              ],
            ),
          ),

          // Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                loc.price(subtotal.toStringAsFixed(2)),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${cartItem.quantity} × ${loc.price(itemPrice.toStringAsFixed(2))}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityControls extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onRemove;
  final ColorScheme colorScheme;

  const _QuantityControls({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
    required this.onRemove,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrease button
          _QuantityButton(
            icon: Icons.remove,
            onTap: onDecrease,
            isActive: quantity > 1,
            colorScheme: colorScheme,
          ),

          // Quantity display
          Container(
            width: 40,
            alignment: Alignment.center,
            child: Text(
              quantity.toString(),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // Increase button
          _QuantityButton(
            icon: Icons.add,
            onTap: onIncrease,
            isActive: true,
            colorScheme: colorScheme,
          ),

          // Spacer
          const SizedBox(width: 8),

          // Remove button
          _RemoveButton(
            onTap: onRemove,
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
                ? colorScheme.primary.withOpacity(0.1)
                : Colors.transparent,
          ),
          child: Center(
            child: Icon(
              icon,
              size: 16,
              color: isActive
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant.withOpacity(0.4),
            ),
          ),
        ),
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _RemoveButton({
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Remove',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.error.withOpacity(0.1),
            ),
            child: Icon(
              Icons.delete_outline,
              size: 16,
              color: colorScheme.error,
            ),
          ),
        ),
      ),
    );
  }
}
