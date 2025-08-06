import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/Response.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_impl_app/user_change_notifier.dart';
import 'package:gluttex_impl_business/product_change_notifier.dart';
import 'package:gluttex_impl_business/cart_change_notifier.dart';
import 'package:gluttex_impl_mediation/preferenceChangeNotifier.dart';
import 'package:medicom_catalog/screens/cart_screen.dart';
import 'package:medicom_catalog/screens/components/ProductOwner.dart';
import 'package:medicom_catalog/screens/components/add_to_cart.dart';
import 'package:medicom_catalog/screens/components/quantity_and_ref.dart';
import 'package:medicom_catalog/screens/components/description.dart';
import 'package:medicom_catalog/screens/components/dialogue/confirmation_dialogue.dart';
import 'package:medicom_catalog/screens/product_update_form_screen.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:gluttex_impl_business/supplier_change_notifier.dart';

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
    final bool isRTL = Provider.of<LocaleProvider>(context, listen: false)
            .locale
            ?.languageCode ==
        "ar";
    return Scaffold(
      floatingActionButton:
          ((Provider.of<AppUserNotifier>(context, listen: false).isLoggedIn))
              ? _buildFloatingCartButton(context)
              : null,
      appBar: _buildAppBar(context),
      body: SlidingUpPanel(
        controller: _panelController,
        minHeight:
            (Provider.of<AppUserNotifier>(context, listen: false).isLoggedIn)
                ? _panelMinHeight
                : 0,
        maxHeight:
            (Provider.of<AppUserNotifier>(context, listen: false).isLoggedIn)
                ? _panelMaxHeight
                : 0,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        color: theme.colorScheme.surface,
        backdropEnabled: true,
        backdropOpacity: 0.5,
        backdropColor: Colors.black,
        panel: _buildSlidingPanel(context),
        body: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(
                  top: GluttexConstants.kDefaultPaddin,
                  left: GluttexConstants.kDefaultPaddin,
                  right: GluttexConstants.kDefaultPaddin,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.background,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          // Background Image
                          if (_product.product_image_url != null &&
                              _product.product_image_url!.isNotEmpty)
                            Align(
                              alignment: isRTL
                                  ? Alignment.topLeft
                                  : Alignment.topRight,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width /
                                      2, // half screen
                                ),
                                child: Opacity(
                                  opacity: 1,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topRight: isRTL
                                          ? const Radius.circular(40)
                                          : Radius.zero,
                                      bottomRight: isRTL
                                          ? const Radius.circular(40)
                                          : Radius.zero,
                                      topLeft: isRTL
                                          ? Radius.zero
                                          : const Radius.circular(40),
                                      bottomLeft: isRTL
                                          ? Radius.zero
                                          : const Radius.circular(40),
                                    ),
                                    child: Hero(
                                      tag:
                                          "product-image-${_product.id_product}",
                                      child: Image.network(
                                        GluttexConstants.fsBaseUrl +
                                            _product.product_image_url!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(Icons.broken_image,
                                                    size: 64),
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // Foreground Content with half-width text
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: GluttexConstants.kDefaultPaddin,
                              vertical: GluttexConstants.kDefaultPaddin,
                            ),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width /
                                    2, // half screen width
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(_product.product_brand ?? ""),
                                  const SizedBox(height: 4),
                                  ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width /
                                                3, // half screen width
                                      ),
                                      child: Text(
                                        _product.product_name ?? "",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge!
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      )),
                                  const SizedBox(
                                      height: GluttexConstants.kDefaultPaddin),
                                  RichText(
                                    text: TextSpan(
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                      children: [
                                        TextSpan(
                                          text:
                                              "${AppLocalizations.of(context)!.priceText}\n",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface),
                                        ),
                                        TextSpan(
                                          text: AppLocalizations.of(context)!
                                              .price(_product.product_price
                                                  .toString()),
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall!
                                              .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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
                      if ((Provider.of<AppUserNotifier>(context, listen: false)
                          .isLoggedIn))
                        AddToCart(
                          product: _product,
                          onAddToCartPressed: _panelController.open,
                        ),
                      const SizedBox(
                          height: GluttexConstants.kDefaultPaddin / 2),
                      FutureBuilder<Widget>(
                        future: _buildProviderTile(context),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return const Text('Error loading provider tile');
                          } else {
                            return snapshot.data!;
                          }
                        },
                      ),
                      const SizedBox(
                          height: GluttexConstants.kDefaultPaddin * 8),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
    final isOwner = isProductOwner(context, _product.product_owner_id ?? 0);

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
    log('Owner Id: ${_product.product_owner_id}');
    log('Image Id: ${_product.id_product_image}');

    final updatedProduct = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductEditFormScreen(
          initialProductName: _product.product_name,
          initialProductBrand: _product.product_brand,
          initialProductBarcode: _product.product_barcode,
          // initialProductImage: _product.product_image_data,
          initialProductOwner: _product.product_owner_id,
          initialProductImageUrl: _product.product_image_url,
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

  Future<Widget> _buildProviderTile(BuildContext context) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final Supplier? provider =
        await Provider.of<SupplierChangeNotifier>(context, listen: false)
            .getSupplierById(_product.product_provider_id ?? 0);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: GluttexConstants.kDefaultPaddin / 8,
        vertical: 8,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.providedBy,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // Provider Avatar/Logo
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: provider != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SvgPicture.asset(
                            'assets/icons/${provider.productProviderTypeId}.svg',
                            package: "gluttex_localiser",
                            color: Theme.of(context).colorScheme.primary,
                            fit: BoxFit.cover,
                          ))
                      : _buildDefaultProviderIcon(),
                ),
                const SizedBox(width: 12),

                // Provider Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider?.providerName ??
                            AppLocalizations.of(context)!.unknownProvider,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (provider?.locationName != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              provider!.locationName!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Contact Button
                // IconButton(
                //   icon: Icon(
                //     Icons.contact_support_outlined,
                //     color: colorScheme.primary,
                //   ),
                //   onPressed: () => _showContactOptions(context, provider),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultProviderIcon() {
    return Center(
      child: Icon(
        Icons.store_outlined,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _showContactOptions(BuildContext context, Supplier? provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ListTile(
              //   leading: const Icon(Icons.phone),
              //   title: Text(AppLocalizations.of(context)!.callProvider),
              //   onTap: () {
              //     Navigator.pop(context);
              //     // if (provider?.phone != null) {
              //     //   // Implement phone call functionality
              //     // }
              //   },
              // ),
              // ListTile(
              //   leading: const Icon(Icons.email),
              //   // title: Text("AppLocalizations.of(context)!.emailProvider"),
              //   onTap: () {
              //     Navigator.pop(context);
              //     // if (provider?.email != null) {
              //     //   // Implement email functionality
              //     // }
              //   },
              // ),
              ListTile(
                leading: const Icon(Icons.map_outlined),
                title: Text(AppLocalizations.of(context)!.viewOnMap),
                onTap: () {
                  Navigator.pop(context);
                  // if (provider?.location != null) {
                  //   // Implement map view functionality
                  // }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
