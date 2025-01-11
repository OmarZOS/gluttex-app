import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_localiser/components/supplier_icon.dart';
import 'package:gluttex_localiser/screens/business_form_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:locator/locator.dart';
import 'package:gluttex_core/business/services/SupplierService.dart';
import 'package:gluttex_impl_business/supplier_change_notifier.dart';
import 'package:gluttex_localiser/screens/map_locations_screen.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:provider/provider.dart';

class SlidingSuppliersWidget extends StatefulWidget {
  const SlidingSuppliersWidget({Key? key}) : super(key: key);

  @override
  _SlidingSuppliersWidgetState createState() => _SlidingSuppliersWidgetState();
}

class _SlidingSuppliersWidgetState extends State<SlidingSuppliersWidget> {
  GoogleMapController? mapController; // Change to nullable type
  final Set<Marker> _markers = {};

  List<Supplier> _suppliers = [];
  List<Supplier> _filteredSuppliers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
    _searchController.addListener(_filterSuppliers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSuppliers() async {
    try {
      final suppliers =
          await GluttexLocator.get<SupplierService>().getAllSuppliers();
      setState(() {
        _suppliers = suppliers;
        _filteredSuppliers = suppliers;
      });
      _updateMarkers(_filteredSuppliers);
    } catch (e) {
      print('Error loading suppliers: $e');
    }
  }

  void _filterSuppliers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSuppliers = _suppliers.where((supplier) {
        return supplier.provider_name.toLowerCase().contains(query) ||
            supplier.provider_name.toLowerCase().contains(query);
      }).toList();
    });
    _updateMarkers(_filteredSuppliers);
  }

  void _focusOnLocation(double latitude, double longitude) {
    if (mapController != null) {
      mapController!.animateCamera(CameraUpdate.newLatLng(
        LatLng(latitude, longitude),
      ));
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _updateMarkers(_filteredSuppliers); // Initial marker load
  }

  void _onMarkerTapped(Supplier supplier) {
    showSupplierDetails(context, supplier);
  }

  void _updateMarkers(List<Supplier> suppliers) {
    // developer.log("Markers updated");
    final newMarkers = suppliers
        .map((supplier) {
          if (supplier.location_latitude != 0.0 &&
              supplier.location_longitude != 0.0) {
            return Marker(
              markerId: MarkerId(supplier.id_product_provider.toString()),
              position: LatLng(
                supplier.location_latitude,
                supplier.location_longitude,
              ),
              infoWindow: InfoWindow(
                title: supplier.provider_name,
                snippet: supplier.provider_contact_info,
              ),
              icon: BitmapDescriptor.defaultMarker,
              onTap: () {
                _onMarkerTapped(supplier); // Trigger the callback
              },
            );
          }
          return null;
        })
        .where((marker) => marker != null)
        .toSet()
        .cast<Marker>();

    setState(() {
      _markers.clear();
      _markers.addAll(newMarkers);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.searchTxt,
              border: InputBorder.none,
              icon: const Icon(Icons.search_outlined)),
        ),
        actions: [
          IconButton(
              onPressed: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SupplierFormScreen()),
                    )
                  },
              icon: const Icon(Icons.add_business))
        ],
      ),
      body: SlidingUpPanel(
        backdropEnabled: true,
        panel: Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.all(GluttexConstants.kDefaultPaddin / 2),
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width / 1.5,
                  height: 20.0,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                  ),
                ),
              ),
            ),
            Consumer<SupplierChangeNotifier>(
                builder: (context, supplierNotifier, child) {
              return Expanded(
                child: ListView.builder(
                  itemCount: _filteredSuppliers.length,
                  itemBuilder: (context, index) {
                    var supplier = _filteredSuppliers[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        // tileColor: Colors.blue[50],
                        leading: getProviderTypeIcon(
                            supplier.product_provider_type_id),
                        title: Text(supplier.provider_name),
                        subtitle: Text(AppLocalizations.of(context)!
                            .providerCategoryTextList
                            .split(",")[supplier.product_provider_type_id - 1]),
                        trailing: IconButton(
                          onPressed: () {
                            _focusOnLocation(supplier.location_latitude,
                                supplier.location_longitude);
                          },
                          icon: const Icon(Icons.location_on_outlined),
                        ),
                        onTap: () {
                          showSupplierDetails(context, supplier);
                        },
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
        collapsed: Container(
          child: const Center(
            child: Text(' '),
          ),
        ),
        minHeight: MediaQuery.of(context).size.height * 0.2,
        maxHeight: MediaQuery.of(context).size.height * 0.7,
        body: MapScreen(
          onFocusLocation: _focusOnLocation,
          onMapCreated: _onMapCreated,
          markers: _markers,
        ),
      ),
    );
  }
}

void showSupplierDetails(BuildContext context, Supplier supplier) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(supplier.provider_name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // FutureBuilder<Category?>(
            //   future: GluttexLocator.get<SupplierService>()
            //       .getCategoryById(supplier.product_provider_type_id),
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return CircularProgressIndicator(); // Show a loading indicator while waiting
            //     } else if (snapshot.hasError) {
            //       return Text('Error: ${snapshot.error}');
            //     } else if (!snapshot.hasData || snapshot.data == null) {
            //       return Text('Category not found');
            //     } else {
            //       return Text(snapshot.data!.product_category_desc);
            //     }
            //   },
            // ),
            Text(
                '${AppLocalizations.of(context)!.locationText}: ${supplier.location_name}'),
            GestureDetector(
              child: Text(supplier.provider_contact_info.replaceAll(",", "\n")),
              onLongPress: () {
                Clipboard.setData(ClipboardData(
                    text:
                        supplier.provider_contact_info.replaceAll(",", "\n")));
              },
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: const Icon(Icons.keyboard_return_rounded),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
