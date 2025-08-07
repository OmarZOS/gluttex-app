import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/Services/SnackbarService.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_impl_app/user_change_notifier.dart';
import 'package:gluttex_localiser/screens/business_form_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gluttex_impl_business/supplier_change_notifier.dart';
import 'package:gluttex_localiser/screens/map_locations_screen.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SlidingSuppliersWidget extends StatefulWidget {
  const SlidingSuppliersWidget({Key? key}) : super(key: key);

  @override
  _SlidingSuppliersWidgetState createState() => _SlidingSuppliersWidgetState();
}

class _SlidingSuppliersWidgetState extends State<SlidingSuppliersWidget> {
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

        // TextField(
        //   controller: _searchController,
        //   decoration: InputDecoration(
        //     hintText: loc.searchTxt,
        //     hintStyle: TextStyle(
        //       color: Theme.of(context).hintColor.withOpacity(0.6),
        //     ),
        //     border: _buildOutlineInputBorder(), // Custom border (see below)
        //     enabledBorder: _buildOutlineInputBorder(),
        //     focusedBorder: _buildOutlineInputBorder(
        //       borderColor: Theme.of(context).primaryColor, // Green for focus
        //     ),
        //     filled: true,
        //     fillColor:
        //         Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
        //     contentPadding:
        //         const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        //     prefixIcon: Icon(
        //       Icons.search,
        //       color: Theme.of(context).hintColor.withOpacity(0.7),
        //     ),
        //     suffixIcon: _searchController.text.isEmpty
        //         ? null // Hide clear button when empty
        //         : IconButton(
        //             icon: Icon(
        //               Icons.close,
        //               color: Theme.of(context).hintColor.withOpacity(0.7),
        //             ),
        //             splashRadius: 20, // Smaller splash area
        //             onPressed: () {
        //               _searchController.clear();
        //               _handleSearch('');
        //               FocusScope.of(context)
        //                   .unfocus(); // Optional: Close keyboard
        //             },
        //           ),
        //   ),
        //   style: TextStyle(
        //     color: Theme.of(context).colorScheme.onSurface,
        //   ),
        //   cursorColor: Theme.of(context).primaryColor, // Green cursor
        //   textInputAction:
        //       TextInputAction.search, // Android/iOS "search" keyboard button
        //   onSubmitted: _handleSearch,
        //   onChanged: (value) {
        //     setState(() {}); // Rebuild to show/hide clear button
        //   },
        // ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.add_business),
        //     onPressed: () {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //           builder: (context) => const SupplierFormScreen(),
        //         ),
        //       );
        //     },
        //     tooltip: 'Add Supplier', // Optional accessibility hint
        //   )
        // ],
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
                      // TextButton(
                      //   onPressed: () {
                      //     // Optionally open Google Maps in a browser
                      //     final url = 'https://www.google.com/maps';
                      //     // launchUrl(Uri.parse(url));
                      //   },
                      //   child: Text("Open in Google Maps"),
                      // ),
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
                    showSupplierDetails(context, supplier);
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
              color: theme.colorScheme.primary,
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
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              radius: 40,
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              child: SvgPicture.asset(
                                'assets/icons/${supplier.productProviderTypeId}.svg',
                                package: "gluttex_localiser",
                                width: 35,
                                height: 35,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.5),
                              ),
                            ),
                            title: Text(
                              supplier.providerName,
                              style: theme.textTheme.titleMedium,
                            ),
                            subtitle: Text(
                              category,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.6),
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.location_on_outlined,
                                color: theme.colorScheme.primary,
                              ),
                              onPressed: () => _focusOnLocation(
                                supplier.locationLatitude,
                                supplier.locationLongitude,
                              ),
                            ),
                            onTap: () {
                              _focusOnLocation(
                                supplier.locationLatitude,
                                supplier.locationLongitude,
                              );
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
}

void showSupplierDetails(BuildContext context, Supplier supplier) {
  final theme = Theme.of(context);
  final loc = AppLocalizations.of(context)!;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            supplier.providerName,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            context,
            icon: Icons.location_on_outlined,
            label: loc.locationText,
            value: supplier.locationName ?? "",
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            context,
            icon: Icons.contact_page_outlined,
            label: loc.contactInfoMsg,
            value: supplier.providerContactInfo.replaceAll(",", "\n"),
            onLongPress: () {
              Clipboard.setData(
                  ClipboardData(text: supplier.providerContactInfo));

              SnackbarService.showSnackbar(
                  context: context, message: loc.copiedToClipboardText);
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            child: Text(loc.cancelTxt),
          ),
        ],
      ),
    ),
  );
}

Widget _buildDetailRow(
  BuildContext context, {
  required IconData icon,
  required String label,
  required String value,
  VoidCallback? onLongPress,
}) {
  return GestureDetector(
    onLongPress: onLongPress,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
