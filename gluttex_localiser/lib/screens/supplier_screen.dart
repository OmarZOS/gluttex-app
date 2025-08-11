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

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.4),
    builder: (context) {
      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
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
        child: Consumer<ProductNotifier>(
          builder: (context, notifier, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Draggable handle
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {}, // Empty gesture to make handle tappable
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 4),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outline.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),

                // Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    children: [
                      // if ("supplier.providerLogoUrl" != null)
                      Hero(
                        tag: 'supplier-${supplier.idProductProvider}-avatar',
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: SvgPicture.asset(
                            'assets/icons/${supplier.productProviderTypeId}.svg',
                            package: "gluttex_localiser",
                            width: 24,
                            height: 24,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),
                      Expanded(
                        child: Hero(
                          tag: 'supplier-${supplier.idProviderDetails}-name',
                          child: Material(
                            type: MaterialType.transparency,
                            child: Text(
                              supplier.providerName,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      // IconButton(
                      //   icon: Icon(Icons.open_in_new, size: 24),
                      //   onPressed: () {
                      //     Navigator.pop(context);
                      //     // _navigateToSupplierDetailsScreen(context, supplier);
                      //   },
                      //   tooltip: "loc.viewFullDetails",
                      // ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            const SizedBox(height: 16),

                            // Location section
                            _buildSectionHeader(context, loc!.locationText),
                            buildLocationTile(context, supplier),
                            const SizedBox(height: 24),

                            // Contact section
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
                            const SizedBox(height: 24),

                            // Similar products
                            _buildSectionHeader(context,
                                "${notifier.products.length} loc.similarProductsFromSupplier}"),
                            const SizedBox(height: 8),
                          ]),
                        ),
                      ),

                      // Similar products list
                      if (notifier.isLoading && notifier.products.isEmpty)
                        const SliverFillRemaining(
                          child: Center(child: CircularProgressIndicator()),
                        ),

                      if (!notifier.isLoading && notifier.products.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Text(
                              loc.noProductsFound,
                              style: theme.textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),

                      if (!notifier.isLoading && notifier.products.isNotEmpty)
                        SliverPadding(
                          padding: const EdgeInsets.only(
                              left: 24, right: 24, bottom: 24),
                          sliver: SliverToBoxAdapter(
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.20,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: notifier.products.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 12),
                                itemBuilder: (context, index) {
                                  final product = notifier.products[index];
                                  return SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      child: SupplierProductCard(
                                        onTap: () => {
                                          Future.delayed(
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
                                          })
                                        },
                                        product: product,
                                        supplierName: supplier.providerName,
                                        stockQuantity:
                                            product.product_quantity ?? 0,
                                        minOrderQty: '1',
                                      ));
                                },
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Footer buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    children: [
                      Expanded(
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
                      // const SizedBox(width: 16),
                      // Expanded(
                      //   child: FilledButton(
                      //     onPressed: () {
                      //       Navigator.pop(context);
                      //       // _navigateToOrderScreen(context, supplier);
                      //     },
                      //     style: FilledButton.styleFrom(
                      //       padding: const EdgeInsets.symmetric(vertical: 16),
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(12),
                      //       ),
                      //     ),
                      //     child: Text(loc.orderNowTxt),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
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

// Future<void> _openMaps(
//     BuildContext context, double lat, double lng, String? name) async {
//   final uri = Uri.parse(
//       'https://www.google.com/maps/search/?api=1&query=$lat,$lng${name != null ? '&query_place_id=$name' : ''}');
//   if (await canLaunchUrl(uri)) {
//     await launchUrl(uri, mode: LaunchMode.externalApplication);
//   } else if (mounted) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Could not open maps')),
//     );
//   }
// }
