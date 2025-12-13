import 'package:flutter/material.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/finance/ProvidedService.dart';
import 'package:gluttex_event/cart_change_notifier.dart';
import 'package:gluttex_store/components/selling_point/selling_product_card.dart';
import 'services/service_card.dart';

class ItemCardWithControls extends StatefulWidget {
  final dynamic item; // Product or Service
  final CartChangeNotifier cartNotifier;
  final bool isProduct;

  const ItemCardWithControls({
    super.key,
    required this.item,
    required this.cartNotifier,
    required this.isProduct,
  });

  @override
  State<ItemCardWithControls> createState() => _ItemCardWithControlsState();
}

class _ItemCardWithControlsState extends State<ItemCardWithControls> {
  int _currentQuantity = 0;

  @override
  void initState() {
    super.initState();
    _updateCurrentQuantity();
  }

  void _updateCurrentQuantity() {
    final id = widget.isProduct
        ? (widget.item as Product).id_product
        : (widget.item as ProvidedService).id;
    final quantity = widget.cartNotifier.cart.getProductQuantity(id ?? 0);
    setState(() => _currentQuantity = quantity);
  }

  void _addToCart() {
    widget.cartNotifier.addItem(widget.item, 1);
    _updateCurrentQuantity();
  }

  void _removeFromCart() {
    if (_currentQuantity > 0) {
      widget.cartNotifier.updateQuantity(widget.item, _currentQuantity - 1);
      _updateCurrentQuantity();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.75, // This maintains consistent card proportions
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
          fit: StackFit.expand, // Use this instead of Positioned.fill
          children: [
            // Main content
            _ItemCard(
              item: widget.item,
              isProduct: widget.isProduct,
              onTap: _addToCart,
            ),

            // Quantity controls overlay
            if (_currentQuantity > 0)
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: _QuantityControls(
                  currentQuantity: _currentQuantity,
                  onAdd: _addToCart,
                  onRemove: _removeFromCart,
                ),
              ),
          ],
        ),
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
      ),
      child: Row(
        children: [
          _QuantityButton(
            icon: Icons.remove,
            onTap: onRemove,
            isActive: currentQuantity > 1,
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
            icon: Icons.add,
            onTap: onAdd,
            isActive: true,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final dynamic item;
  final bool isProduct;
  final VoidCallback onTap;

  const _ItemCard({
    required this.item,
    required this.isProduct,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isProduct) {
      return SellingProductCard(
        product: item as Product,
        onTap: onTap,
      );
    } else {
      return ServiceCard(
        service: item as ProvidedService,
        onTap: onTap,
      );
    }
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
