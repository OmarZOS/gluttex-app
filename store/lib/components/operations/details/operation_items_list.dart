import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/finance/BusinessOperation.dart';
import 'package:gluttex_core/business/finance/Cart.dart';
import 'package:gluttex_core/business/finance/Order.dart';
import 'package:event/order_change_notifier.dart';
import 'package:provider/provider.dart';
import 'package:event/cart_change_notifier.dart';

class OperationItemsList extends StatefulWidget {
  final BusinessOperation operation;

  const OperationItemsList({super.key, required this.operation});

  @override
  State<OperationItemsList> createState() => _OperationItemsListState();
}

class _OperationItemsListState extends State<OperationItemsList> {
  List<dynamic> _items = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void didUpdateWidget(OperationItemsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.operation.cartId != widget.operation.cartId ||
        oldWidget.operation.orderId != widget.operation.orderId) {
      _loadItems();
    }
  }

  Future<void> _loadItems() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final orderNotifier =
          Provider.of<OrderChangeNotifier>(context, listen: false);
      final cartNotifier =
          Provider.of<CartChangeNotifier>(context, listen: false);

      if (widget.operation.cartId != null) {
        await _loadCartItems(cartNotifier);
      } else if (widget.operation.orderId != null) {
        await _loadOrderItems(orderNotifier);
      } else {
        _items = [];
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _items = [];
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadCartItems(CartChangeNotifier cartNotifier) async {
    final cartId = widget.operation.cartId!;

    // Check if cart already exists in cache
    bool cartExists =
        cartNotifier.apiCarts.any((cart) => cart.cartId == cartId);

    if (!cartExists) {
      await cartNotifier.fetchCartDetails(cartId);
    }

    // Find cart after potential fetch
    final cart = cartNotifier.apiCarts.firstWhere(
      (cart) => cart.cartId == cartId,
      // orElse: () => Cart.empty(),
    );

    if (cart.orderedItems != null && cart.orderedItems!.isNotEmpty) {
      _items = cart.orderedItems!;
    } else {
      _items = [];
    }
  }

  Future<void> _loadOrderItems(OrderChangeNotifier cartNotifier) async {
    final orderId = widget.operation.orderId!;

    // Check if order already exists in cache
    bool orderExists =
        cartNotifier.orders.any((order) => order.idPlacedOrder == orderId);

    if (!orderExists) {
      await cartNotifier.fetchOrderDetails(orderId: orderId);
    }

    // Find order after potential fetch
    final order = cartNotifier.getOrderWithDetails(orderId);

    if (order != null && order.items != null && order.items!.isNotEmpty) {
      _items = order.items!.cast<OrderedItem>();
    } else {
      _items = [];
    }
  }

  void _handleRetry() {
    _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState(localizations);
    }

    if (_items.isEmpty) {
      return _EmptyItemsState(localizations: localizations);
    }

    return _ItemsListView(items: _items);
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading items...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(AppLocalizations localizations) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading items',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
            const SizedBox(height: 8),
            if (_errorMessage != null && _errorMessage!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _errorMessage!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: _handleRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemsListView extends StatelessWidget {
  final List<dynamic> items;

  const _ItemsListView({required this.items});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Items List
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (context, index) => Divider(
            color: colorScheme.outline.withOpacity(0.1),
            height: 16,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return _ItemCard(item: item);
          },
        ),

        const SizedBox(height: 16),

        // Total Summary
        _ItemsTotalSummary(items: items),
      ],
    );
  }
}

class _ItemCard extends StatelessWidget {
  final dynamic item;

  const _ItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isCartItem = item is CartItem;
    final colorScheme = Theme.of(context).colorScheme;
    final AppLocalizations loc = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isCartItem ? Icons.shopping_cart : Icons.receipt_long,
              size: 20,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),

          // Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getItemName(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildInfoText(
                        context, loc.orderAmountText(_getQuantity())),
                    const SizedBox(width: 12),
                    _buildInfoText(
                        context, loc.price(_getUnitPrice().toStringAsFixed(2))),
                  ],
                ),
                if (_getItemDescription() != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _getItemDescription()!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Item Total
          Text(
            loc.price(_getTotal().toStringAsFixed(2)),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoText(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }

  String _getItemName() {
    if (item is CartItem) {
      return (item as CartItem).product?.product_name ?? 'Product';
    } else if (item is OrderedItem) {
      return (item as OrderedItem).orderedProduct?.productName ?? 'Product';
    }
    return 'Item';
  }

  String? _getItemDescription() {
    if (item is CartItem) {
      return (item as CartItem).product?.product_description;
    } else if (item is OrderedItem) {
      return (item as OrderedItem).orderedProduct?.productDescription;
    }
    return null;
  }

  int _getQuantity() {
    if (item is CartItem) {
      return (item as CartItem).quantity ?? 1;
    } else if (item is OrderedItem) {
      return (item as OrderedItem).orderedQuantity ?? 1;
    }
    return 1;
  }

  double _getUnitPrice() {
    if (item is CartItem) {
      return (item as CartItem).totalPrice ?? 0.0;
    } else if (item is OrderedItem) {
      return (item as OrderedItem).unitPrice ?? 0.0;
    }
    return 0.0;
  }

  double _getTotal() {
    return _getQuantity() * _getUnitPrice();
  }
}

class _ItemsTotalSummary extends StatelessWidget {
  final List<dynamic> items;

  const _ItemsTotalSummary({required this.items});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final totals = _calculateTotals();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSummaryRow(context, 'Subtotal', totals.subtotal),
          const SizedBox(height: 8),
          _buildSummaryRow(context, 'Tax', totals.tax),
          const Divider(height: 24),
          _buildTotalRow(context, 'Total', totals.total),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, double amount) {
    AppLocalizations loc = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        Text(
          loc.price(amount.toStringAsFixed(2)),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Widget _buildTotalRow(BuildContext context, String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        Text(
          AppLocalizations.of(context)!.price(amount.toStringAsFixed(2)),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ],
    );
  }

  _Totals _calculateTotals() {
    double subtotal = 0.0;

    for (final item in items) {
      final quantity = _getItemQuantity(item);
      final unitPrice = _getItemUnitPrice(item);
      subtotal += quantity * unitPrice;
    }

    // Calculate tax (assuming 10% for demonstration)
    final tax = subtotal * 0.1;
    final total = subtotal + tax;

    return _Totals(
      subtotal: subtotal,
      tax: tax,
      total: total,
    );
  }

  int _getItemQuantity(dynamic item) {
    if (item is CartItem) return item.quantity ?? 1;
    if (item is OrderedItem) return item.orderedQuantity ?? 1;
    return 1;
  }

  double _getItemUnitPrice(dynamic item) {
    if (item is CartItem) return item.totalPrice ?? 0.0;
    if (item is OrderedItem) return item.unitPrice ?? 0.0;
    return 0.0;
  }
}

class _Totals {
  final double subtotal;
  final double tax;
  final double total;

  const _Totals({
    required this.subtotal,
    required this.tax,
    required this.total,
  });
}

class _EmptyItemsState extends StatelessWidget {
  final AppLocalizations localizations;

  const _EmptyItemsState({required this.localizations});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2,
              size: 48,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No items found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'This operation has no associated items',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
