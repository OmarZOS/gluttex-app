import 'package:flutter/material.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/finance/Cart.dart';
import 'package:gluttex_event/cart_change_notifier.dart';

class CartItemsList extends StatelessWidget {
  final CartChangeNotifier cart;
  final ScrollController? scrollController;

  const CartItemsList({
    required this.cart,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (cart.cartItems.isEmpty) {
      return const _EmptyCartState();
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      itemCount: cart.cartItems.length,
      itemBuilder: (context, index) {
        return _CartItemRow(
          cartItem: cart.cartItems[index],
          cart: cart,
          isLast: index == cart.cartItems.length - 1,
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

class _CartItemRow extends StatefulWidget {
  final CartItem cartItem;
  final CartChangeNotifier cart;
  final bool isLast;

  const _CartItemRow({
    required this.cartItem,
    required this.cart,
    required this.isLast,
  });

  @override
  State<_CartItemRow> createState() => _CartItemRowState();
}

class _CartItemRowState extends State<_CartItemRow> {
  bool _isProcessing = false;
  final _debounceDuration = const Duration(milliseconds: 150);

  Future<void> _updateQuantity(int delta) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    final newQuantity = widget.cartItem.quantity + delta;
    if (newQuantity > 0) {
      widget.cart.updateQuantity(widget.cartItem.product, newQuantity);
    } else {
      widget.cart.removeItem(widget.cartItem.product);
    }

    await Future.delayed(_debounceDuration);
    setState(() => _isProcessing = false);
  }

  void _removeItem() {
    widget.cart.removeItem(widget.cartItem.product);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final product = widget.cartItem.product;
    final subtotal = product.product_price! * widget.cartItem.quantity;

    return Container(
      margin: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: widget.isLast ? 8 : 8,
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
          // Product Image/Icon
          _ProductIcon(product: product, colorScheme: colorScheme),
          const SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.product_name ?? 'Product',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${product.product_price?.toStringAsFixed(2)} each',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                _QuantityControls(
                  quantity: widget.cartItem.quantity,
                  onDecrease: () => _updateQuantity(-1),
                  onIncrease: () => _updateQuantity(1),
                  onRemove: _removeItem,
                  isProcessing: _isProcessing,
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
                '\$${subtotal.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.cartItem.quantity} × \$${product.product_price?.toStringAsFixed(2)}',
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

class _ProductIcon extends StatelessWidget {
  final Product product;
  final ColorScheme colorScheme;

  const _ProductIcon({
    required this.product,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        Icons.inventory,
        color: colorScheme.primary,
        size: 24,
      ),
    );
  }
}

class _QuantityControls extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onRemove;
  final bool isProcessing;
  final ColorScheme colorScheme;

  const _QuantityControls({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
    required this.onRemove,
    required this.isProcessing,
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
            isActive: quantity > 1 && !isProcessing,
            isProcessing: isProcessing,
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
            isActive: !isProcessing,
            isProcessing: isProcessing,
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
  final bool isProcessing;
  final ColorScheme colorScheme;

  const _QuantityButton({
    required this.icon,
    required this.onTap,
    required this.isActive,
    required this.isProcessing,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isActive && !isProcessing ? onTap : null,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive && !isProcessing
                ? colorScheme.primary.withOpacity(0.1)
                : Colors.transparent,
          ),
          child: Center(
            child: isProcessing
                ? SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  )
                : Icon(
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
