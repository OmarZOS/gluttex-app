import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_event/user_change_notifier.dart';
import 'package:gluttex_localiser/screens/supplier_form_page.dart';
import 'package:gluttex_ui/components/supplier_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gluttex_event/supplier_change_notifier.dart';
import 'package:gluttex_localiser/screens/map_locations_screen.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SuppliersMapScreen extends StatefulWidget {
  const SuppliersMapScreen({Key? key}) : super(key: key);

  @override
  _SuppliersMapScreenState createState() => _SuppliersMapScreenState();
}

class _SuppliersMapScreenState extends State<SuppliersMapScreen> {
  late final TextEditingController _searchController;
  GoogleMapController? _mapController;
  final PanelController _panelController = PanelController();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _fetchLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

// Helper method for consistent borders
  OutlineInputBorder _buildOutlineInputBorder({Color? borderColor}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: borderColor ?? Theme.of(context).dividerColor,
        width: 1.2,
      ),
    );
  }

  Future<void> _fetchLocation() async {
    await Provider.of<SupplierChangeNotifier>(context, listen: false)
        .getCurrentLocation();
  }

  void _focusOnLocation(double latitude, double longitude) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(latitude, longitude),
        15, // Zoom level
      ),
    );
    _panelController.close(); // Close panel when focusing on location
  }

  void _handleSearch(String query) {
    Provider.of<SupplierChangeNotifier>(context, listen: false)
        .searchSuppliers(query);
    _panelController.open(); // Open panel when searching
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      floatingActionButton: [
        GluttexConstants.cookingChefDBId,
        GluttexConstants.supplierDBId
      ].contains(// Cooking Chef and Supplier id in the database
              Provider.of<AppUserNotifier>(context).appUser?.app_user_type_id)
          ? FloatingActionButton(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              heroTag: 'floating-button-12',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SupplierFormScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add_business),
            )
          : null,
      appBar: AppBar(
        // leading: ,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)?.searchTxt,
              prefixIcon: Icon(Icons.search_outlined,
                  color: Theme.of(context).colorScheme.onSurface),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
      body: Consumer<SupplierChangeNotifier>(
        builder: (context, supplierNotifier, child) {
          final suppliers = supplierNotifier.suppliers;
          final isLoading = supplierNotifier.isLoading;

          return Stack(
            children: [
              // Fallback for Web or if Map Fails
              if (kIsWeb) // Check if web or map not initialized
                Container(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map_outlined,
                        size: 48,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        loc.mapNotAvailableText,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                )
              else
                // Map Screen (only for mobile)
                MapScreen(
                  onMapCreated: (controller) => _mapController = controller,
                  userLocation: supplierNotifier.currentLocation,
                  suppliers: suppliers,
                  onSupplierTap: (supplier) {
                    _focusOnLocation(
                      supplier.locationLatitude,
                      supplier.locationLongitude,
                    );
                    Future.delayed(const Duration(milliseconds: 400), () {
                      showSupplierDetails(context, supplier);
                    });
                  },
                ),

              // Sliding Panel (always visible)
              SlidingUpPanel(
                controller: _panelController,
                minHeight: 80,
                maxHeight: MediaQuery.of(context).size.height * 0.6,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                backdropEnabled: true,
                backdropOpacity: 0.2,
                backdropColor: Theme.of(context).colorScheme.onSurface,
                panelBuilder: (scrollController) => _buildPanelContent(
                  context,
                  suppliers,
                  isLoading,
                  scrollController,
                ),
                color: Theme.of(context).colorScheme.surface,
                collapsed: _buildCollapsedPanel(context),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCollapsedPanel(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.providersText,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildPanelContent(
    BuildContext context,
    List<Supplier> suppliers,
    bool isLoading,
    ScrollController scrollController,
  ) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Drag Handle
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            loc.providersText,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Supplier List
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : suppliers.isEmpty
                  ? Center(
                      child: Text(
                        loc.notFoundError,
                        style: theme.textTheme.bodyLarge,
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: suppliers.length,
                      itemBuilder: (context, index) {
                        final supplier = suppliers[index];
                        final category = loc.providerCategoryTextList
                            .split(",")[supplier.productProviderTypeId - 1];

                        return Card(
                          color: (isDarkMode)
                              ? theme.colorScheme.primaryContainer
                                  .withOpacity(0.2)
                              : null,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            // tileColor: theme.colorScheme.onSurfaceVariant,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                                radius: 40,
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
                                    return SizedBox.expand(
                                      // Fallback also fills space
                                      child: SvgPicture.asset(
                                        'assets/icons/${supplier.productProviderTypeId}.svg',
                                        package: "gluttex_localiser",
                                        width: 35,
                                        height: 35,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    );
                                  },
                                  key: ValueKey(supplier.supplier_image_url),
                                )),
                            title: Row(
                              // mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  supplier.providerName,
                                  style: theme.textTheme.titleMedium,
                                  // overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    category, // e.g. "Restaurant"
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme
                                          .colorScheme.onSecondaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              supplier.provider_organisation_name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.6),
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                FontAwesomeIcons.locationDot,
                                color: theme.colorScheme.primary,
                              ),
                              onPressed: () => _focusOnLocation(
                                supplier.locationLatitude,
                                supplier.locationLongitude,
                              ),
                            ),
                            onTap: () {
                              showSupplierDetails(context, supplier);
                            },
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  // Helper widget for product cards
  Widget _buildProductCard(BuildContext context, Product product) {
    final theme = Theme.of(context);

    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.pop(context); // Close bottom sheet
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => ProductDetailsScreen(product: product),
            //     ));
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image
                Container(
                  height: 80,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: theme.colorScheme.surfaceVariant,
                    image: product.product_image_url != null
                        ? DecorationImage(
                            image: NetworkImage(product.product_image_url!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: product.product_image_url == null
                      ? Center(
                          child: Icon(
                            Icons.shopping_bag,
                            size: 32,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 8),
                // Product name
                Text(
                  product.product_name ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
                // Product price if available
                if (product.product_price != null)
                  Text(
                    product.product_price!.toStringAsFixed(2),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
