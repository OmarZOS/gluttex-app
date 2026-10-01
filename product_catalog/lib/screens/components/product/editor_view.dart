// lib/screens/product_details/editor_view.dart

import 'package:app_constants/app_constants.dart';
import 'package:app_constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:gluttex_localizations/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:event/product_change_notifier.dart';
import 'package:product_catalog/screens/components/description.dart';
import 'package:provider/provider.dart';

import 'editor_widgets.dart';
import 'provider_tile.dart';

class EditorProductView extends StatefulWidget {
  final Product product;
  final bool isRTL;
  final ValueChanged<Product> onProductUpdated;

  const EditorProductView({
    super.key,
    required this.product,
    required this.isRTL,
    required this.onProductUpdated,
  });

  @override
  State<EditorProductView> createState() => _EditorProductViewState();
}

class _EditorProductViewState extends State<EditorProductView> {
  late ProductNotifier _productNotifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _productNotifier = context.read<ProductNotifier>();
  }

  Future<void> _toggleVisibility() async {
    // Wire to the product update endpoint.
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(
        content: Text(
          'Visibility toggle is not wired yet. Connect to your update API.',
        ),
      ),
    );
  }

  Future<void> _navigateToEdit() async {
    final updated = await Navigator.pushNamed(
      context,
      AppRoutes.productCreate,
      arguments: {'product': widget.product},
    );

    if (!mounted) return;

    if (updated is Product) {
      widget.onProductUpdated(updated);
    } else {
      final refreshed = _productNotifier.products.firstWhere(
        (p) => p.id_product == widget.product.id_product,
        orElse: () => widget.product,
      );
      widget.onProductUpdated(refreshed);
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text(
          'Deleting "${widget.product.product_name ?? 'this product'}" '
          'removes it from the catalog. Orders that reference it keep '
          'their historical record.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);

              final status = await _productNotifier.deleteProduct(
                '${widget.product.id_product}',
              );

              if (!mounted) return;

              if (status == 200) {
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Product deleted')),
                );
              } else {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Failed to delete product')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = widget.product;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: EditorHero(
              product: product,
              isRTL: widget.isRTL,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                PricingHero(product: product),
                const SizedBox(height: 20),
                EditorActions(
                  onEdit: _navigateToEdit,
                  onToggleVisibility: _toggleVisibility,
                  isVisible: product.isVisible,
                ),
                const SizedBox(height: 20),
                StockCard(product: product),
                const SizedBox(height: 20),
                MetadataCard(product: product),
                if ((product.product_description ?? '').isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Description(product: product),
                ],
                const SizedBox(height: 20),
                ProviderTile(
                  providerId: product.product_provider_id ?? 0,
                ),
                const SizedBox(height: 20),
                DangerZoneCard(onDelete: _showDeleteConfirmation),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
