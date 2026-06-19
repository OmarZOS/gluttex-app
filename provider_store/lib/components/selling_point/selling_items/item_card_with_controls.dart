import 'package:flutter/material.dart';
import 'package:gluttex_localizations/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/finance/ProvidedService.dart';
import 'package:event/cart_change_notifier.dart';
import 'package:provider_store/components/selling_point/config_sheet/product_configuration_sheet.dart';
import 'package:provider_store/components/selling_point/config_sheet/service_configuration_sheet.dart';
import 'package:provider/provider.dart';

class ItemCardWithConfiguration extends StatelessWidget {
  final dynamic item; // Product or ProvidedService
  final bool isProduct;

  const ItemCardWithConfiguration({
    super.key,
    required this.item,
    required this.isProduct,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CartChangeNotifier>(
      builder: (context, cartNotifier, child) {
        int currentQuantity = 0;

        if (isProduct) {
          final product = item as Product;
          final cartItem = cartNotifier.getProductCartItem(product);
          currentQuantity = cartItem?.quantity ?? 0;
        } else {
          final service = item as ProvidedService;
          final cartItem = cartNotifier.getServiceCartItem(service);
          currentQuantity = cartItem?.quantity ?? 0;
        }

        final colorScheme = Theme.of(context).colorScheme;
        final color = colorScheme.primary;

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
                // Main content - Clickable
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _addToCartDirectly(context, cartNotifier),
                    borderRadius: BorderRadius.circular(16),
                    child: _ItemContent(
                      item: item,
                      isProduct: isProduct,
                      hasQuantityInCart: currentQuantity > 0,
                    ),
                  ),
                ),

                // Configuration button - Positioned top right
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _showConfigurationSheet(context, cartNotifier),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.settings_rounded,
                        size: 16,
                        color: color,
                      ),
                    ),
                  ),
                ),

                // Quantity badge - Positioned top left
                if (currentQuantity > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color,
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
                          currentQuantity.toString(),
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
                if (currentQuantity > 0)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: _QuantityControls(
                      currentQuantity: currentQuantity,
                      onAdd: () => _addToCartDirectly(context, cartNotifier),
                      onRemove: () => _removeFromCart(context, cartNotifier),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addToCartDirectly(
      BuildContext context, CartChangeNotifier cartNotifier) {
    if (isProduct) {
      final product = item as Product;
      final cartItem = cartNotifier.getProductCartItem(product);

      if (cartItem != null) {
        // Increment quantity by 1
        cartNotifier.updateQuantity(
          product: product,
          newQuantity: cartItem.quantity + 1,
        );
      } else {
        // Add with default config (quantity = 1)
        cartNotifier.addItem(product, 1);
      }
    } else {
      final service = item as ProvidedService;
      final cartItem = cartNotifier.getServiceCartItem(service);

      if (cartItem != null) {
        // Increment quantity by 1
        cartNotifier.updateQuantity(
          service: service,
          newQuantity: cartItem.quantity + 1,
        );
      } else {
        // Add with default config (quantity = 1, no scheduling)
        cartNotifier.addService(
          service,
          quantity: 1,
          scheduledDate: null,
          scheduledTime: null,
        );
      }
    }
  }

  void _removeFromCart(BuildContext context, CartChangeNotifier cartNotifier) {
    if (isProduct) {
      final product = item as Product;
      final cartItem = cartNotifier.getProductCartItem(product);
      if (cartItem != null && cartItem.quantity > 1) {
        cartNotifier.updateQuantity(
          product: product,
          newQuantity: cartItem.quantity - 1,
        );
      } else if (cartItem != null) {
        cartNotifier.removeItem(product: product);
      }
    } else {
      final service = item as ProvidedService;
      final cartItem = cartNotifier.getServiceCartItem(service);
      if (cartItem != null && cartItem.quantity > 1) {
        cartNotifier.updateQuantity(
          service: service,
          newQuantity: cartItem.quantity - 1,
        );
      } else if (cartItem != null) {
        cartNotifier.removeItem(service: service);
      }
    }
  }

  void _showConfigurationSheet(
      BuildContext context, CartChangeNotifier cartNotifier) {
    if (isProduct) {
      final product = item as Product;
      final cartItem = cartNotifier.getProductCartItem(product);

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ProductConfigurationSheet(
          product: product,
          cartNotifier: cartNotifier,
          currentQuantity: cartItem?.quantity,
        ),
      );
    } else {
      final service = item as ProvidedService;
      final cartItem = cartNotifier.getServiceCartItem(service);

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => ServiceConfigurationSheet(
          service: service,
          initialQuantity: cartItem?.quantity ?? 1,
          onSave: (
              {required quantity,
              scheduledDate,
              scheduledTime,
              notes,
              parameters}) {
            if (cartItem != null) {
              // Update existing service in cart
              cartNotifier.updateQuantity(
                service: service,
                newQuantity: quantity,
              );
              cartNotifier.updateServiceScheduling(
                service: service,
                scheduledDate: scheduledDate,
                scheduledTime: scheduledTime,
              );
            } else {
              // Add new service to cart
              cartNotifier.addService(
                service,
                quantity: quantity,
                scheduledDate: scheduledDate,
                scheduledTime: scheduledTime,
              );
            }
          },
        ),
      );
    }
  }
}

class _ItemContent extends StatelessWidget {
  final dynamic item;
  final bool isProduct;
  final bool hasQuantityInCart;

  const _ItemContent({
    required this.item,
    required this.isProduct,
    required this.hasQuantityInCart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasControls = hasQuantityInCart;
    final loc = AppLocalizations.of(context)!;

    if (isProduct) {
      final product = item as Product;
      final id = product.id_product ?? 0;
      final price = product.product_price ?? 0;
      final stock = product.product_quantity ?? 0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Product image
          AspectRatio(
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
                  Icons.inventory_2_rounded,
                  size: 48,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),

          // Product info
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  12,
                  12,
                  12,
                  hasControls
                      ? 48
                      : 12), // Extra bottom padding when controls are visible
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
                            loc.price(price.toStringAsFixed(2)),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            loc.stock(stock),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: stock > 0 ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: hasQuantityInCart
                              ? colorScheme.tertiary
                              : colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: hasQuantityInCart
                            ? IconButton(
                                icon: Icon(Icons.delete),
                                color: hasQuantityInCart
                                    ? colorScheme.onTertiary
                                    : colorScheme.onPrimary,
                                iconSize: 18,
                                onPressed: () {
                                  context
                                      .read<CartChangeNotifier>()
                                      .removeItem(product: item as Product);
                                  // .cart
                                  // .removeItem(productId: id);
                                },
                              )
                            : Icon(
                                Icons.add,
                                size: 18,
                                color: Colors.white,
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
    } else {
      final service = item as ProvidedService;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Service icon
          AspectRatio(
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
                  Icons.handyman,
                  size: 48,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),

          // Service info
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  12,
                  12,
                  12,
                  hasControls
                      ? 48
                      : 12), // Extra bottom padding when controls are visible
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
                            loc.price(service.finalPrice.toStringAsFixed(2)),
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
                      // if (!hasQuantityInCart)
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: hasQuantityInCart
                              ? colorScheme.tertiary
                              : colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: hasQuantityInCart
                            ? IconButton(
                                icon: Icon(Icons.delete),
                                color: hasQuantityInCart
                                    ? colorScheme.onTertiary
                                    : colorScheme.onPrimary,
                                iconSize: 18,
                                onPressed: () {
                                  context.read<CartChangeNotifier>().removeItem(
                                      service: item as ProvidedService);
                                },
                              )
                            : Icon(
                                Icons.add,
                                size: 18,
                                color: Colors.white,
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
            icon: Icons.remove,
            onTap: onRemove,
            isActive: true,
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
        onTap: onTap,
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
