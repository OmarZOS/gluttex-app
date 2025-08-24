import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/GluttexException.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_event/product_change_notifier.dart';
import 'package:gluttex_event/supplier_change_notifier.dart';
import 'package:gluttex_ui/Services/ResponseHandler.dart';
import 'package:gluttex_ui/SupplierProductCard.dart';
import 'package:gluttex_ui/components/LocationTile.dart';
import 'package:gluttex_ui/components/confirmation_dialogue.dart';
import 'package:gluttex_ui/components/contactTile.dart';
// import 'package:gluttex_ui/components/SupplierProductCard.dart';
import 'package:provider/provider.dart';

void _showDeleteConfirmation(BuildContext context,
    SupplierChangeNotifier supplierNotifer, int idProductProvider) {
  showConfirmationDialog(
    context,
    AppLocalizations.of(context)!.recipedeletionConfirmationMessage,
    () async {
      try {
        await supplierNotifer.deleteSupplier(idProductProvider);
        ResponseHandler.handleResponse(
          context: context,
          statusCode: 200,
          responseCode: "SUCCESS",
          finalMessage: AppLocalizations.of(context)!.deleteSuccess,
        );
        Navigator.pop(context);
      } on GluttexException catch (e) {
        ResponseHandler.handleResponse(
          context: context,
          statusCode: e.statusCode ?? 300,
          responseCode: e.message,
          finalMessage: AppLocalizations.of(context)!.deleteFailure,
        );
      }
    },
  );
}

void showSupplierDetails(BuildContext context, Supplier supplier) {
  final theme = Theme.of(context);
  final loc = AppLocalizations.of(context);
  final productNotifier = Provider.of<ProductNotifier>(context, listen: false);
  final supplierNotifer =
      Provider.of<SupplierChangeNotifier>(context, listen: false);
  final contacts = parseContactInfo(supplier.providerContactInfo);

  log('supplier.idProductProvider: ${supplier.idProductProvider}');

  supplierNotifer.getSupplierById(supplier.idProductProvider);

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
                                    radius: 50,
                                    backgroundColor:
                                        theme.colorScheme.primaryContainer,
                                    child: Image.network(
                                      GluttexConstants.fsBaseUrl +
                                          (supplier.supplier_image_url ?? ""),
                                      fit: BoxFit
                                          .cover, // Covers all available space
                                      alignment:
                                          Alignment.center, // Centers the image
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return SizedBox.expand(
                                          // Fallback also fills space
                                          child: SvgPicture.asset(
                                            'assets/icons/${supplier.productProviderTypeId}.svg',
                                            package: "gluttex_localiser",
                                            width: 25,
                                            height: 25,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                        );
                                      },
                                      key:
                                          ValueKey(supplier.supplier_image_url),
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
                                IconButton(
                                    iconSize: 27,
                                    color: theme.colorScheme.tertiary,
                                    onPressed: () {
                                      _showDeleteConfirmation(
                                          context,
                                          supplierNotifer,
                                          supplier.idProductProvider);
                                    },
                                    icon: Icon(Icons.delete)),
                                IconButton(
                                    iconSize: 27,
                                    color: theme.colorScheme.secondary,
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.providerCreate,
                                        arguments: {"supplier": supplier},
                                      );
                                    },
                                    icon: Icon(Icons.edit_location_alt)),
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

                    if (supplierNotifer.isLoading)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: theme.colorScheme.primary,
                            ),
                          ),
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
                                      Navigator.pushNamed(
                                          context, AppRoutes.productDetails,
                                          arguments: {"product": product});
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
                                          Navigator.pushNamed(
                                              context, AppRoutes.productDetails,
                                              arguments: {"product": product});
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
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
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
