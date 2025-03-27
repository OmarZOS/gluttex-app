import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/Response.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_impl_business/product_change_notifier.dart';
import 'package:gluttex_impl_business/cart_change_notifier.dart';
import 'package:medicom_catalog/screens/cart_screen.dart';
import 'package:medicom_catalog/screens/components/ProductOwner.dart';
import 'package:medicom_catalog/screens/components/add_to_cart.dart';
import 'package:medicom_catalog/screens/components/quantity_and_ref.dart';
import 'package:medicom_catalog/screens/components/counter_with_fav_btn.dart';
import 'package:medicom_catalog/screens/components/description.dart';
import 'package:medicom_catalog/screens/components/dialogue/confirmation_dialogue.dart';
import 'package:medicom_catalog/screens/components/product_title_with_image.dart';
import 'package:medicom_catalog/screens/product_update_form_screen.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class DetailsScreen extends StatefulWidget {
  final Product product;

  const DetailsScreen({super.key, required this.product});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late Product _product;
  final PanelController _panelController = PanelController();
  late ProductNotifier _productNotifier;
  int quantity = 1;
  final double _panelMinHeight = 80;
  final double _panelMaxHeight = 320;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _subscribeToProductUpdates();
  }

  @override
  void dispose() {
    _productNotifier.stopPollingProductUpdates();
    super.dispose();
  }

  void _subscribeToProductUpdates() {
    _productNotifier = Provider.of<ProductNotifier>(context, listen: false);
    _productNotifier.startPollingProductUpdates(_product);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      floatingActionButton: _buildFloatingCartButton(context),
      appBar: _buildAppBar(context),
      body: SlidingUpPanel(
        controller: _panelController,
        minHeight: _panelMinHeight,
        maxHeight: _panelMaxHeight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        color: theme.colorScheme.surface,
        backdropEnabled: true,
        backdropOpacity: 0.5,
        backdropColor: Colors.black,
        panel: _buildSlidingPanel(context),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: size.height,
                child: Stack(
                  children: [
                    // Background content
                    Container(
                      margin: EdgeInsets.only(top: size.height * 0.3),
                      padding: EdgeInsets.only(
                        top: size.height * 0.12,
                        left: GluttexConstants.kDefaultPaddin,
                        right: GluttexConstants.kDefaultPaddin,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.background,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          Consumer<ProductNotifier>(
                            builder: (context, productNotifier, child) {
                              return QuantityAndRef(
                                product: productNotifier.products.firstWhere(
                                  (element) =>
                                      element.id_product == _product.id_product,
                                  orElse: () => _product,
                                ),
                              );
                            },
                          ),
                          const SizedBox(
                              height: GluttexConstants.kDefaultPaddin / 2),
                          Description(product: _product),
                          const SizedBox(
                              height: GluttexConstants.kDefaultPaddin / 2),
                          AddToCart(
                            product: widget.product,
                            onAddToCartPressed: _panelController.open,
                          ),
                        ],
                      ),
                    ),
                    // Product title and image
                    ProductTitleWithImage(product: _product),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingCartButton(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).colorScheme.primary,
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CartScreen()),
      ),
      child: Consumer<CartChangeNotifier>(
        builder: (context, cart, child) {
          return Badge(
            isLabelVisible: cart.cartItemCount > 0,
            label: Text('${cart.cartItemCount}'),
            child: const Icon(Icons.shopping_cart, color: Colors.white),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final isOwner = is_product_owner(context, _product.product_owner_id ?? 0);

    return AppBar(
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (isOwner) _buildDeleteButton(context),
        if (isOwner) _buildEditButton(context),
        const SizedBox(width: GluttexConstants.kDefaultPaddin / 2),
      ],
    );
  }

  IconButton _buildDeleteButton(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
      onPressed: () => _showDeleteConfirmation(context),
    );
  }

  IconButton _buildEditButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () => _navigateToEditScreen(context),
    );
  }

  Widget _buildSlidingPanel(BuildContext context) {
    final theme = Theme.of(context);
    final price = (_product.product_price ?? 0) * quantity;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPanelHandle(),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildProductThumbnail(theme),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _product.product_name ??
                          AppLocalizations.of(context)!.missingText,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!
                          .price(price.toStringAsFixed(2)),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildQuantityControls(theme),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _addToCart,
            child: Text(
              AppLocalizations.of(context)!.cartAddConfirmationMessage,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 5,
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildProductThumbnail(ThemeData theme) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
          width: 24,
          height: 24,
          // color: theme.colorScheme.onSurfaceVariant,
          child: SvgPicture.asset(
            'assets/icons/${_product.product_category_id ?? 1}.svg',
            package: "medicom_catalog",
            // color: isSelected
            //     ? Theme.of(context).colorScheme.onPrimary
            //     : Theme.of(context).colorScheme.onSurface,
          )),
    );
  }

  Widget _buildQuantityControls(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppLocalizations.of(context)!.productQuantity,
          style: theme.textTheme.bodyLarge,
        ),
        Row(
          children: [
            IconButton(
              onPressed: () => setState(() {
                if (quantity > 1) quantity--;
              }),
              icon: Icon(Icons.remove_circle,
                  size: 32, color: theme.colorScheme.error),
            ),
            Container(
              width: 40,
              alignment: Alignment.center,
              child: Text(
                '$quantity',
                style: theme.textTheme.titleMedium,
              ),
            ),
            IconButton(
              onPressed: () => setState(() => quantity++),
              icon: Icon(Icons.add_circle,
                  size: 32, color: theme.colorScheme.primary),
            ),
          ],
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showConfirmationDialog(
      context,
      AppLocalizations.of(context)!.productdeletionConfirmationMessage,
      () async {
        final statusCode =
            await Provider.of<ProductNotifier>(context, listen: false)
                .deleteProduct('${_product.id_product}');

        final response = Response();

        if (statusCode == 200) {
          response.color = Colors.green;
          response.text = AppLocalizations.of(context)!.deleteSuccess;
          Navigator.pop(context);
        } else if (statusCode == 406 || statusCode == 422) {
          response.color = Colors.amber;
          response.text = AppLocalizations.of(context)!.deleteFailure;
        } else {
          response.color = Colors.red;
          response.text = AppLocalizations.of(context)!.serverError;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.text),
            backgroundColor: response.color,
          ),
        );
      },
    );
  }

  Future<void> _navigateToEditScreen(BuildContext context) async {
    final updatedProduct = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductEditFormScreen(
          initialProductName: _product.product_name,
          initialProductBrand: _product.product_brand,
          initialProductBarcode: _product.product_barcode,
          initialProductImage: _product.product_image_data,
          initialProductOwner: _product.product_owner_id,
          initialProductTypeId: _product.product_category_id,
          initialProductPrice: _product.product_price,
          initialProductQuantity: _product.product_quantity,
          initialProduct_provider_id: _product.product_provider_id,
          initialProduct_category_id: _product.product_category_id,
          initialIdProduct: _product.id_product,
          initialIdProductImage: _product.id_product_image,
          initialProductDescription: _product.product_description,
        ),
      ),
    );

    if (updatedProduct != null) {
      setState(() => _product = updatedProduct);
    }
  }

  void _addToCart() {
    Provider.of<CartChangeNotifier>(context, listen: false)
        .addItem(widget.product, quantity);
    _panelController.close();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.putSuccess),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
