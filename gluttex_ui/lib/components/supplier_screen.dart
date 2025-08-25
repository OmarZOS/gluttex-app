import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/GluttexException.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_event/product_change_notifier.dart';
import 'package:gluttex_event/supplier_change_notifier.dart';
import 'package:gluttex_ui/Services/ResponseHandler.dart';
import 'package:gluttex_ui/SupplierProductCard.dart';
import 'package:gluttex_ui/components/BusinessOwner.dart';
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
                            child: Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment
                                  .center, // center vertically
                              alignment:
                                  WrapAlignment.start, // start horizontally
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor:
                                      theme.colorScheme.primaryContainer,
                                  child: Image.network(
                                    GluttexConstants.fsBaseUrl +
                                        (supplier.supplier_image_url ?? ""),
                                    fit: BoxFit.cover,
                                    alignment: Alignment.center,
                                    key: ValueKey(supplier.supplier_image_url),
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
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
                                    errorBuilder: (context, error, stackTrace) {
                                      return SvgPicture.asset(
                                        'assets/icons/${supplier.productProviderTypeId}.svg',
                                        package: "gluttex_localiser",
                                        width: 40,
                                        height: 40,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      );
                                    },
                                  ),
                                ),

                                // Text column
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                      maxWidth: 200), // keep responsive
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start, // left align text
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        supplier.providerName,
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        supplier.provider_organisation_name,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onSurface
                                              .withOpacity(0.7),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),

                                // Buttons
                                if (!productNotifier.isLoading &&
                                    isBusinessOwner(context,
                                        supplier.productProviderOwnerId))
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    alignment: WrapAlignment
                                        .start, // align to the left
                                    children: [
                                      IconButton(
                                        iconSize: 27,
                                        color: theme.colorScheme.tertiary,
                                        onPressed: () {
                                          _showDeleteConfirmation(
                                            context,
                                            supplierNotifer,
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
                                              "supplier": supplierNotifer
                                                  .detailed_suppliers
                                                  .where((e) =>
                                                      e.idProductProvider ==
                                                      supplier
                                                          .idProductProvider)
                                                  .firstOrNull,
                                            },
                                          );
                                        },
                                        icon:
                                            const Icon(Icons.edit_location_alt),
                                      ),
                                    ],
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
                          _buildLocationInfo(
                              context, supplierNotifer, supplier),
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
                            loc.productsFromSupplier(supplier.providerName),
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

// Add this method to your _OrganisationPickerState class
Widget _buildLocationInfo(BuildContext context,
    SupplierChangeNotifier supplierNotifier, Supplier supplier) {
  // Find the supplier by name

  // // If supplier not found, show appropriate message
  // if (supplier == null) {
  //   return _buildNoLocationInfo();
  // }

  // Use FutureBuilder to handle the async operation
  return FutureBuilder<Supplier?>(
    future: supplierNotifier.getSupplierById(supplier.idProductProvider),
    builder: (context, snapshot) {
      // Show loading state
      if (snapshot.connectionState == ConnectionState.waiting) {
        return _buildLocationLoading();
      }

      // Show error state
      if (snapshot.hasError) {
        return _buildLocationError('Failed to load location data');
      }

      // Show data
      final detailedSupplier = snapshot.data;
      return _buildResponsiveLocationDetails(
          context, detailedSupplier ?? supplier);
    },
  );
}

// Loading state widget
Widget _buildLocationLoading() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12.0),
    child: Center(
      child: SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            Colors.grey[400]!,
          ),
        ),
      ),
    ),
  );
}

// Error state widget
Widget _buildLocationError(String message) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      children: [
        Icon(
          Icons.error_outline,
          size: 14,
          color: Colors.red[400],
        ),
        const SizedBox(width: 6),
        Text(
          message,
          style: TextStyle(
            color: Colors.red[600],
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

// Enhanced no location info widget to match premium style
Widget _buildNoLocationInfo() {
  return Container(
    margin: const EdgeInsets.only(top: 4, bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      // color: Colors.grey[50],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        // color: Colors.grey,
        width: 1,
      ),
    ),
    child: Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            // color: Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.location_off_outlined,
            size: 16,
            // color: Colors.grey[500],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'No location information available',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    ),
  );
}

// Responsive grid version
Widget _buildResponsiveLocationDetails(
    BuildContext context, Supplier supplier) {
  final hasLocationData = (supplier.address_street.isNotEmpty) ||
      (supplier.address_city.isNotEmpty) ||
      (supplier.address_postal_code.isNotEmpty) ||
      (supplier.address_country.isNotEmpty);

  if (!hasLocationData) {
    return _buildNoLocationInfo();
  }

  return Container(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLocationTile(context, supplier),
        const SizedBox(height: 8),

        // ✅ Responsive 2-column grid
        LayoutBuilder(
          builder: (context, constraints) {
            final double itemWidth =
                (constraints.maxWidth - 8) / 2; // half width minus spacing

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (supplier.address_street.isNotEmpty)
                  SizedBox(
                    width: itemWidth,
                    child: _buildGridLocationItem(
                      context,
                      supplier.address_street,
                      'Street',
                      FontAwesomeIcons.road,
                      Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                if (supplier.address_city.isNotEmpty)
                  SizedBox(
                    width: itemWidth,
                    child: _buildGridLocationItem(
                      context,
                      supplier.address_city,
                      'City',
                      Icons.location_city_outlined,
                      Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                if (supplier.address_postal_code.isNotEmpty)
                  SizedBox(
                    width: itemWidth,
                    child: _buildGridLocationItem(
                      context,
                      supplier.address_postal_code,
                      'Postal Code',
                      Icons.local_post_office_outlined,
                      Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                if (supplier.address_country.isNotEmpty)
                  SizedBox(
                    width: itemWidth,
                    child: _buildGridLocationItem(
                      context,
                      supplier.address_country,
                      'Country',
                      Icons.public_outlined,
                      Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    ),
  );
}

// Premium grid item widget
Widget _buildGridLocationItem(BuildContext context, String text, String label,
    IconData icon, Color color) {
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      // color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: Colors.grey[200]!,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 14,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                text,
                style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 12,
                  // fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    ),
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
