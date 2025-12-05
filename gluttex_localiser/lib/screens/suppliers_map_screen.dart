import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_event/user_change_notifier.dart';
import 'package:gluttex_localiser/screens/supplier_form_page.dart';
import 'package:gluttex_ui/components/floating_buttons.dart';
import 'package:gluttex_ui/components/supplier/supplier_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gluttex_event/supplier_change_notifier.dart';
import 'package:gluttex_localiser/screens/map_locations_screen.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:provider/provider.dart';
import '../components/suppliers_panel.dart';

class SuppliersMapScreen extends StatefulWidget {
  const SuppliersMapScreen({Key? key}) : super(key: key);

  @override
  _SuppliersMapScreenState createState() => _SuppliersMapScreenState();
}

class _SuppliersMapScreenState extends State<SuppliersMapScreen> {
  late final TextEditingController _searchController;
  GoogleMapController? _mapController;
  final PanelController _panelController = PanelController();
  dynamic _selectedLocation;
  final ValueNotifier<bool> _isFilterApplied = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _fetchLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _isFilterApplied.dispose();
    super.dispose();
  }

  void onDeleteLocationFilter() {
    Provider.of<SupplierChangeNotifier>(context, listen: false).fetchSuppliers(
      reset: true, // 👈 ensures fresh search each time
    );
    setState(() {
      _selectedLocation = null;
      _isFilterApplied.value = false;
    });
  }

  Future<void> _fetchLocation() async {
    await Provider.of<SupplierChangeNotifier>(context, listen: false)
        .getCurrentLocation();
  }

  void _focusOnLocation(double latitude, double longitude,
      {double zoomLevel = 5}) {
    _panelController.close();
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(latitude, longitude),
        zoomLevel,
      ),
    );
  }

  void _applyLocationFilter(dynamic location) {
    _focusOnLocation(location["latitude"], location["longitude"],
        zoomLevel: location["zoom_level"]);
    setState(() {
      _selectedLocation = location;
      _isFilterApplied.value = true;
      _handleGeoSearch(location);
    });
  }

  void _handleGeoSearch(dynamic location) {
    Provider.of<SupplierChangeNotifier>(context, listen: false)
        .searchSuppliersByGeo(
      longitude: location["longitude"],
      latitude: location["latitude"],
      distance: location["radius_km"],
      offset: 0,
      itemsPerPage: 20,
      reset: true, // 👈 ensures fresh search each time
    );
    _panelController.open();
  }

  void _handleSearch(String query) {
    Provider.of<SupplierChangeNotifier>(context, listen: false)
        .searchSuppliers(query);
    _panelController.open();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      floatingActionButton: CustomSpeedDial(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        horizontalButtons: [
          SpeedDialButton(
            icon: Icon(Icons.add_business,
                color: Theme.of(context).colorScheme.onPrimary),
            label: AppLocalizations.of(context)?.addSupplierTxt,
            backgroundColor: Theme.of(context).colorScheme.primary,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.providerCreate,
              );
            },
          ),
        ],
        verticalButtons: [
          SpeedDialButton(
            icon: Icon(FontAwesomeIcons.peopleGroup,
                color: Theme.of(context).colorScheme.onPrimary),
            label: AppLocalizations.of(context)?.personnel_manage_title,
            backgroundColor: Theme.of(context).colorScheme.primary,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.supplierEntitiesPage);
            },
          ),
          // SpeedDialButton(
          //   icon: Icon(Icons.dashboard,
          //       color: Theme.of(context).colorScheme.onPrimary),
          //   label: AppLocalizations.of(context)?.cartText,
          //   backgroundColor: Theme.of(context).colorScheme.primary,
          //   onTap: () {
          //     Navigator.pushNamed(
          //       context,
          //       AppRoutes.dashboardPage,
          //     );
          //   },
          // ),
        ],
      ),
      appBar: AppBar(
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
            onChanged: _handleSearch,
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
          return Stack(
            children: [
              if (kIsWeb || defaultTargetPlatform == TargetPlatform.linux)
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
                MapScreen(
                  onMapCreated: (controller) => _mapController = controller,
                  userLocation: supplierNotifier.currentLocation,
                  suppliers: supplierNotifier.suppliers,
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

              // Sliding Panel with optimized rebuilds
              SlidingUpPanel(
                controller: _panelController,
                minHeight: 80,
                maxHeight: MediaQuery.of(context).size.height * 0.6,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                backdropEnabled: true,
                backdropOpacity: 0.2,
                backdropColor: Theme.of(context).colorScheme.onSurface,
                panelBuilder: (scrollController) {
                  // Use a separate consumer to prevent entire panel rebuilds
                  return Consumer<SupplierChangeNotifier>(
                    builder: (context, supplierNotifier, child) {
                      return PanelContent(
                        suppliers: supplierNotifier.suppliers,
                        isLoading: supplierNotifier.isLoading,
                        scrollController: scrollController,
                        focusOnLocation: _focusOnLocation,
                        selectedLocation: _selectedLocation,
                        onDeleteLocationFilter: onDeleteLocationFilter,
                        applyLocationFilter: _applyLocationFilter,
                      );
                    },
                  );
                },
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
}
