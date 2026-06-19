import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gluttex_localizations/gen_l10n/app_localizations.dart';
import 'package:app_constants/app_constants.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:event/product_change_notifier.dart';
import 'package:event/supplier_change_notifier.dart';
import 'package:ui/SupplierProductCard.dart';
import 'package:ui/components/supplier/BusinessOwner.dart';
import 'package:ui/components/supplier/contactTile.dart';
import 'package:ui/components/location/location_info.dart';
import 'package:ui/components/supplier/delete_confirm.dart';
import 'package:provider/provider.dart';

void showSupplierDetails(BuildContext context, Supplier supplier) {
  final theme = Theme.of(context);
  final productNotifier = Provider.of<ProductNotifier>(context, listen: false);
  final supplierNotifier =
      Provider.of<SupplierChangeNotifier>(context, listen: false);

  log('supplier.idProductProvider: ${supplier.idProductProvider}');

  // Fetch fresh supplier data in background
  supplierNotifier.getSupplierById(supplier.idProductProvider);

  final isDarkMode = theme.brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: isDarkMode
        ? Colors.white.withOpacity(0.5)
        : Colors.black.withOpacity(0.5),
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return _SupplierDetailsModal(
            supplier: supplier,
            supplierNotifier: supplierNotifier,
            productNotifier: productNotifier,
            scrollController: scrollController,
          );
        },
      );
    },
  );
}

class _SupplierDetailsModal extends StatefulWidget {
  final Supplier supplier;
  final SupplierChangeNotifier supplierNotifier;
  final ProductNotifier productNotifier;
  final ScrollController scrollController;

  const _SupplierDetailsModal({
    required this.supplier,
    required this.supplierNotifier,
    required this.productNotifier,
    required this.scrollController,
  });

  @override
  State<_SupplierDetailsModal> createState() => _SupplierDetailsModalState();
}

class _SupplierDetailsModalState extends State<_SupplierDetailsModal> {
  late Future<List<Product>> _supplierProductsFuture;
  List<Product>? _cachedProducts;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSupplierProducts();
  }

  void _loadSupplierProducts() {
    final supplierId = widget.supplier.idProductProvider;

    // Check for cached products first
    final cached = widget.productNotifier.getCachedSupplierProducts(supplierId);
    if (cached != null && cached.isNotEmpty) {
      log('Using cached products: ${cached.length}');
      _cachedProducts = cached;
    }

    // Create future for fetching fresh data (will use cache if available)
    _supplierProductsFuture = _fetchSupplierProducts();
  }

  Future<List<Product>> _fetchSupplierProducts() async {
    final supplierId = widget.supplier.idProductProvider;

    // First, check if products are already in the notifier's products list
    final existingProducts = widget.productNotifier.products
        .where((p) => p.product_provider_id == supplierId)
        .toList();

    if (existingProducts.isNotEmpty) {
      log('Using existing products from notifier: ${existingProducts.length}');
      return existingProducts;
    }

    // Check product notifier's supplier cache
    final cachedProducts =
        widget.productNotifier.getCachedSupplierProducts(supplierId);
    if (cachedProducts != null && cachedProducts.isNotEmpty) {
      log('Using cached products: ${cachedProducts.length}');
      return cachedProducts;
    }

    // Fetch from API
    log('Fetching products from API for supplier $supplierId');
    setState(() {
      _isLoading = true;
    });

    try {
      final products =
          await widget.productNotifier.fetchSupplierProducts(supplierId);
      log('API returned ${products.length} products');
      return products;
    } catch (e) {
      log('Failed to load supplier products: $e');
      return [];
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _isValidImageUrl(String? url) {
    return url != null && url.isNotEmpty && url.startsWith('http');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final supplier = widget.supplier;
    final contacts = parseContactInfo(supplier.providerContactInfo);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(context, supplier),
          Expanded(
            child: CustomScrollView(
              controller: widget.scrollController,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 16),
                      _buildSectionHeader(context, loc.locationText),
                      buildLocationInfo(
                          context, widget.supplierNotifier, supplier),
                      const SizedBox(height: 24),
                      if (supplier.providerContactInfo != null &&
                          supplier.providerContactInfo!.isNotEmpty)
                        _buildSectionHeader(context, loc.contactInfoMsg),
                      ...contacts.map(
                        (contact) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: buildContactTile(
                            context,
                            contact['type']!,
                            contact['value']!,
                          ),
                        ),
                      ),
                      _buildSectionHeader(
                        context,
                        loc.productsFromSupplier(supplier.providerName),
                      ),
                      const SizedBox(height: 8),
                    ]),
                  ),
                ),
                _buildProductSection(context, loc, theme),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: FilledButton.tonal(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(loc.close),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSection(
      BuildContext context, AppLocalizations loc, ThemeData theme) {
    return SliverToBoxAdapter(
      child: FutureBuilder<List<Product>>(
        future: _supplierProductsFuture,
        builder: (context, snapshot) {
          // Show loading state while fetching, but if we have cached products, show them immediately
          final hasCachedProducts =
              _cachedProducts != null && _cachedProducts!.isNotEmpty;
          final isLoading =
              snapshot.connectionState == ConnectionState.waiting || _isLoading;

          // Display cached products while loading if available
          if (hasCachedProducts && isLoading) {
            return Column(
              children: [
                // Show cached products
                SizedBox(
                  height: 180,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _cachedProducts!.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final product = _cachedProducts![index];
                      return _buildProductCard(context, product);
                    },
                  ),
                ),
                // Show loading indicator at the bottom
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            );
          }

          // Show loading state (no cached products)
          if (isLoading) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          // Handle error
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Icon(Icons.error_outline,
                      color: theme.colorScheme.error, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to load products',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _supplierProductsFuture = _fetchSupplierProducts();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Show products
          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  loc.noOtherProductsAvailable,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            );
          }

          return SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildProductCard(context, product);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.productDetails,
          arguments: {"product": product},
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 360,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SupplierProductCard(
            product: product,
            supplierName: product.product_brand ?? "",
            stockQuantity: product.product_quantity ?? 0,
            minOrderQty: '1',
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Supplier supplier) {
    final theme = Theme.of(context);

    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: theme.colorScheme.outline.withOpacity(0.4),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Wrap(
            spacing: 16,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.start,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: _isValidImageUrl(supplier.supplierImageUrl)
                    ? ClipOval(
                        child: Image.network(
                          supplier.supplierImageUrl!,
                          fit: BoxFit.cover,
                          width: 100,
                          height: 100,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return SvgPicture.asset(
                              'assets/icons/${supplier.productProviderTypeId}.svg',
                              package: "provider_geo",
                              width: 40,
                              height: 40,
                              color: Theme.of(context).colorScheme.onSurface,
                            );
                          },
                        ),
                      )
                    : SvgPicture.asset(
                        'assets/icons/${supplier.productProviderTypeId}.svg',
                        package: "provider_geo",
                        width: 40,
                        height: 40,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      supplier.providerName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      supplier.providerOrganisationName ?? '',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isBusinessOwner(context, supplier.productProviderOwnerId))
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.start,
                  children: [
                    IconButton(
                      iconSize: 27,
                      color: theme.colorScheme.tertiary,
                      onPressed: () {
                        showDeleteConfirmation(
                          context,
                          widget.supplierNotifier,
                          supplier.idProductProvider,
                        );
                      },
                      icon: const Icon(Icons.delete),
                    ),
                    IconButton(
                      iconSize: 27,
                      color: theme.colorScheme.secondary,
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.providerCreate,
                          arguments: {
                            "supplier": supplier,
                          },
                        );
                      },
                      icon: const Icon(Icons.edit_location_alt),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
