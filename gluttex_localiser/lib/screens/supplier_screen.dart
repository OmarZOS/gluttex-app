import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_impl_business/product_change_notifier.dart';
import 'package:gluttex_impl_business/supplier_change_notifier.dart';
import 'package:gluttex_localiser/components/LocationTile.dart';
import 'package:gluttex_localiser/components/contactTile.dart';
import 'package:medicom_catalog/screens/product_screen.dart';
import 'package:provider/provider.dart';

import '../components/SupplierProductCard.dart';

void showSupplierDetails(BuildContext context, Supplier supplier) {
  final theme = Theme.of(context);
  final loc = AppLocalizations.of(context);
  final productNotifier = Provider.of<ProductNotifier>(context, listen: false);
  final contacts = parseContactInfo(supplier.providerContactInfo);

  log('supplier.idProductProvider: ${supplier.idProductProvider}');
  productNotifier.fetchProducts(
      providerId: supplier.idProductProvider, reset: true);
  final isDarkMode = theme.brightness == Brightness.dark;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: isDarkMode
        ? Colors.white.withOpacity(0.5)
        : Colors.black.withOpacity(0.5), // Border color
    // Colors.black.withOpacity(0.4),
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Consumer<ProductNotifier>(
              builder: (context, notifier, _) {
                return CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    // Header
                    SliverToBoxAdapter(
                      child: Column(
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
                            child: Row(
                              children: [
                                Hero(
                                  tag:
                                      'supplier-${supplier.idProductProvider}-avatar',
                                  child: CircleAvatar(
                                    radius: 24,
                                    backgroundColor:
                                        theme.colorScheme.primaryContainer,
                                    child: SvgPicture.asset(
                                      'assets/icons/${supplier.productProviderTypeId}.svg',
                                      package: "gluttex_localiser",
                                      width: 24,
                                      height: 24,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.5),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Hero(
                                    tag:
                                        'supplier-${supplier.idProviderDetails}-name',
                                    child: Material(
                                      type: MaterialType.transparency,
                                      child: Text(
                                        supplier.providerName,
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          const SizedBox(height: 16),
                          _buildSectionHeader(context, loc!.locationText),
                          buildLocationTile(context, supplier),
                          const SizedBox(height: 24),
                          if (supplier.providerContactInfo != "")
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
                            loc.otherProductsFromSupplier(
                                supplier.providerName),
                          ),
                          const SizedBox(height: 8),
                        ]),
                      ),
                    ),

                    // Product list or loading/empty state
                    if (notifier.isLoading)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      )
                    else if (notifier.products.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              loc.noOtherProductsAvailable,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.6),
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 180,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: notifier.products.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final product = notifier.products[index];
                              return InkWell(
                                onTap: () {
                                  // Ripple effect
                                  Future.delayed(
                                    const Duration(milliseconds: 150),
                                    () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DetailsScreen(product: product),
                                        ),
                                      );
                                    },
                                  );
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  width: 360,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(16),
                                        onTap: () => Future.delayed(
                                            const Duration(milliseconds: 150),
                                            () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DetailsScreen(
                                                      product: product),
                                            ),
                                          );
                                        }),
                                        child: SupplierProductCard(
                                          product: product,
                                          supplierName:
                                              product.product_brand ?? "",
                                          stockQuantity:
                                              product.product_quantity ?? 0,
                                          minOrderQty: '1',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                    // Footer button
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                        child: FilledButton.tonal(
                          onPressed: () => Navigator.pop(context),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(loc.close),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      );
    },
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
