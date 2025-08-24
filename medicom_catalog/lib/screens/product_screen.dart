import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/Response.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_event/user_change_notifier.dart';
import 'package:gluttex_event/product_change_notifier.dart';
import 'package:gluttex_event/preferenceChangeNotifier.dart';
import 'package:gluttex_event/cart_change_notifier.dart';
import 'package:gluttex_ui/SupplierProductCard.dart';
import 'package:gluttex_ui/components/supplier_screen.dart';
import 'package:medicom_catalog/screens/cart_screen.dart';
import 'package:medicom_catalog/screens/components/ProductOwner.dart';
import 'package:medicom_catalog/screens/components/add_to_cart.dart';
import 'package:medicom_catalog/screens/components/quantity_and_ref.dart';
import 'package:medicom_catalog/screens/components/description.dart';
import 'package:medicom_catalog/screens/components/dialogue/confirmation_dialogue.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:gluttex_event/supplier_change_notifier.dart';
import 'package:shimmer/shimmer.dart';

class ProductDetailsScreen extends StatelessWidget {
  // final Product product;

  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _ProductDetailsScreenContent();
  }
}

class _ProductDetailsScreenContent extends StatefulWidget {
  // final Product product;

  const _ProductDetailsScreenContent();

  @override
  State<_ProductDetailsScreenContent> createState() =>
      _ProductDetailsScreenContentState();
}

class _ProductDetailsScreenContentState
    extends State<_ProductDetailsScreenContent> {
  late final PanelController _panelController;
  int _quantity = 1;
  Supplier? _provider;
  late Product _product;
  bool _isLoadingProvider = true;
  late ProductNotifier productNotifier;
  bool _initialized = false; // to prevent re-initialization

  @override
  void initState() {
    // _product = _product;
    _panelController = PanelController();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      _product = args?["product"];
      _fetchProvider(); // Async operation without mounted check
      _initializeProducts();
      _initialized = true;
    }
  }

  void _initializeProducts() {
    productNotifier = context.read<ProductNotifier>();
    // productNotifier.fetchProducts(
    //     categoryId: _product.product_category_id ?? 0);
    productNotifier.startPollingProductUpdates(_product);
  }

  @override
  void dispose() {
    // _panelController.dispose();
    productNotifier.stopPollingProductUpdates();

    super.dispose();
  }

  Future<void> _fetchProvider() async {
    if (!mounted) return;

    setState(() => _isLoadingProvider = true);

    try {
      final provider =
          await Provider.of<SupplierChangeNotifier>(context, listen: false)
              .getSupplierById(_product.product_provider_id ?? 0);

      if (mounted) {
        setState(() {
          _provider = provider;
          _isLoadingProvider = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingProvider = false);
      }
      debugPrint('Error fetching provider: $e');
    }
  }

  void _updateQuantity(int newValue) {
    if (!mounted) return;
    setState(() => _quantity = newValue); // Add reasonable limits
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRTL = context.read<LocaleProvider>().locale?.languageCode == "ar";
    final isLoggedIn = context.read<AppUserNotifier>().isLoggedIn;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      floatingActionButton:
          isLoggedIn ? _buildFloatingCartButton(context) : null,
      appBar: _buildAppBar(context, _product),
      body: SlidingUpPanel(
        controller: _panelController,
        minHeight: isLoggedIn ? 80 : 0,
        maxHeight: isLoggedIn ? 320 : 0,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        color: theme.colorScheme.surface,
        backdropEnabled: true,
        backdropOpacity: 0.5,
        backdropColor: isDarkMode
            ? Colors.white.withOpacity(0.5)
            : Colors.black.withOpacity(0.5), // Border color
        panel: _buildSlidingPanel(context),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
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
                child: Column(
                  children: [
                    _buildProductHeader(context, isRTL, _product),
                    const SizedBox(height: GluttexConstants.kDefaultPaddin),
                    Consumer<ProductNotifier>(
                      builder: (context, productNotifier, _) {
                        final currentProduct =
                            productNotifier.products.firstWhere(
                          (element) =>
                              element.id_product == _product.id_product,
                          orElse: () => _product,
                        );
                        return QuantityAndRef(product: currentProduct);
                      },
                    ),
                    const SizedBox(height: GluttexConstants.kDefaultPaddin / 2),
                    Description(product: _product),
                    if (isLoggedIn) ...[
                      const SizedBox(
                          height: GluttexConstants.kDefaultPaddin / 2),
                      AddToCart(
                        product: _product,
                        onAddToCartPressed: _panelController.open,
                      ),
                    ],
                    const SizedBox(height: GluttexConstants.kDefaultPaddin / 2),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        AppLocalizations.of(context)!
                            .similarProductsFromCategory(
                                AppLocalizations.of(context)!
                                        .productCategoryTextList
                                        .split(",")[
                                    (_product.product_category_id ?? 1) - 1]),
                        textAlign: isRTL ? TextAlign.right : TextAlign.left,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Consumer<ProductNotifier>(
                      builder: (context, notifier, _) {
                        if (notifier.isLoading) {
                          return SizedBox(
                            height: 180,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: 3,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                return Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      width: 360,
                                      decoration: BoxDecoration(
                                        color: isDarkMode
                                            ? Colors.white.withOpacity(0.5)
                                            : Colors.black.withOpacity(
                                                0.5), // Border color,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ));
                              },
                            ),
                          );
                        }

                        if (notifier.products.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return SizedBox(
                          height: 180,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: notifier.products.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final product = notifier.products[index];
                              if (product.id_product == _product.id_product) {
                                return const SizedBox.shrink();
                              }
                              return SizedBox(
                                width: 360,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Material(
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () => Future.delayed(
                                        const Duration(milliseconds: 150),
                                        () {
                                          Navigator.pushNamed(
                                              context, AppRoutes.productDetails,
                                              arguments: {"product": product});
                                        },
                                      ),
                                      child: SupplierProductCard(
                                        product: product,
                                        supplierName:
                                            _provider?.providerName ?? "",
                                        stockQuantity:
                                            product.product_quantity ?? 0,
                                        minOrderQty: '1',
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    _buildProviderTile(),
                    if (isLoggedIn) const SizedBox(height: 160),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductHeader(
      BuildContext context, bool isRTL, Product product) {
    final theme = Theme.of(context);
    // log("Screen id_product: ${product.id_product}");
    return Stack(
      children: [
        if (product.product_image_url != null &&
            product.product_image_url!.isNotEmpty)
          Align(
            alignment: isRTL ? Alignment.topLeft : Alignment.topRight,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width / 2,
              ),
              child: Opacity(
                opacity: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topRight: isRTL ? const Radius.circular(40) : Radius.zero,
                    bottomRight:
                        isRTL ? const Radius.circular(40) : Radius.zero,
                    topLeft: isRTL ? Radius.zero : const Radius.circular(40),
                    bottomLeft: isRTL ? Radius.zero : const Radius.circular(40),
                  ),
                  child: Hero(
                    tag: "product-image-${product.id_product}-card",
                    child: Image.network(
                      GluttexConstants.fsBaseUrl + product.product_image_url!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 64),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: GluttexConstants.kDefaultPaddin,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width / 2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (product.product_brand != null &&
                    product.product_brand!.isNotEmpty)
                  Text(product.product_brand!),
                const SizedBox(height: 4),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width / 3,
                  ),
                  child: Text(
                    product.product_name ?? "",
                    style: theme.textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: GluttexConstants.kDefaultPaddin),
                RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodyLarge,
                    children: [
                      TextSpan(
                        text: "${AppLocalizations.of(context)!.priceText}\n",
                        style: theme.textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      TextSpan(
                        text: AppLocalizations.of(context)!
                            .price(product.product_price.toString()),
                        style: theme.textTheme.headlineSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingCartButton(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'floating-button-0',
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

  AppBar _buildAppBar(BuildContext context, Product product) {
    final isOwner = isProductOwner(context, product.product_owner_id ?? 0);

    return AppBar(
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (isOwner)
          IconButton(
            icon: Icon(Icons.delete,
                color: Theme.of(context).colorScheme.tertiary),
            onPressed: () => _showDeleteConfirmation(context, product),
          ),
        if (isOwner)
          IconButton(
            icon: Icon(Icons.edit,
                color: Theme.of(context).colorScheme.secondary),
            onPressed: () => _navigateToEditScreen(context, product),
          ),
        const SizedBox(width: GluttexConstants.kDefaultPaddin / 2),
      ],
    );
  }

  Widget _buildSlidingPanel(BuildContext context) {
    final theme = Theme.of(context);
    final price =
        (_product?.product_price ?? 0) * (_product?.product_quantity ?? 0);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPanelHandle(),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildProductThumbnail(theme, _product),
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
          _buildQuantityControls(context, theme),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => _addToCart(context),
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

  Widget _buildProductThumbnail(ThemeData theme, Product? product) {
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
          child: SvgPicture.asset(
            'assets/icons/${product?.product_category_id ?? 1}.svg',
            package: "medicom_catalog",
          )),
    );
  }

  Widget _buildQuantityControls(BuildContext context, ThemeData theme) {
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
              onPressed: () =>
                  {log('$_quantity'), _updateQuantity(_quantity - 1)},
              icon: Icon(Icons.remove_circle,
                  size: 32, color: theme.colorScheme.error),
            ),
            Container(
              width: 40,
              alignment: Alignment.center,
              child: Text(
                '${_quantity}',
                style: theme.textTheme.titleMedium,
              ),
            ),
            IconButton(
              onPressed: () => _updateQuantity(_quantity + 1),
              icon: Icon(Icons.add_circle,
                  size: 32, color: theme.colorScheme.primary),
            ),
          ],
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, Product product) {
    showConfirmationDialog(
      context,
      AppLocalizations.of(context)!.productdeletionConfirmationMessage,
      () async {
        final statusCode =
            await Provider.of<ProductNotifier>(context, listen: false)
                .deleteProduct('${product.id_product}');

        final response = Response();

        if (statusCode == 200) {
          // response.color = Colors.green;
          response.text = AppLocalizations.of(context)!.deleteSuccess;
          Navigator.pop(context);
        } else if (statusCode == 406 || statusCode == 422) {
          // response.color = Colors.amber;
          response.text = AppLocalizations.of(context)!.deleteFailure;
        } else {
          // response.color = Colors.red;
          response.text = AppLocalizations.of(context)!.serverError;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.text),
            // backgroundColor: response.color,
          ),
        );
      },
    );
  }

  Future<void> _navigateToEditScreen(
      BuildContext context, Product product) async {
    // log('Owner Id: ${product.product_owner_id}');
    // log('Image Id: ${product.id_product_image}');

    final updatedProduct = await Navigator.pushNamed(
        context, AppRoutes.productCreate,
        arguments: {"product": product});

    // if (updatedProduct != null) {
    //   Provider.of<ProductNotifier>(context, listen: false)
    //       .addOrUpdateProduct(updatedProduct);
    // }
  }

  void _addToCart(BuildContext context) {
    Provider.of<CartChangeNotifier>(context, listen: false)
        .addItem(_product, _quantity);
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

  Widget _buildProviderTile() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoadingProvider) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: GluttexConstants.kDefaultPaddin / 8,
        vertical: 8,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          showSupplierDetails(context, _provider ?? Supplier.empty());
        },
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
                    child: _provider != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SvgPicture.asset(
                              'assets/icons/${_provider?.productProviderTypeId ?? 0}.svg',
                              package: "gluttex_localiser",
                              color: Theme.of(context).colorScheme.primary,
                              fit: BoxFit.cover,
                            ),
                          )
                        : _buildDefaultProviderIcon(context),
                  ),
                  const SizedBox(width: 12),

                  // Provider Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _provider?.providerName ??
                              AppLocalizations.of(context)!.unknownProvider,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_provider?.locationName != null) ...[
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
                                _provider?.locationName ?? "",
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultProviderIcon(
    BuildContext context,
  ) {
    return Center(
      child: Icon(
        Icons.store_outlined,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
