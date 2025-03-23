import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  void _fetchLocation() async {
    await Provider.of<SupplierChangeNotifier>(context, listen: false)
        .getCurrentLocation();
  }

  void _focusOnLocation(double latitude, double longitude) {
    _mapController
        ?.animateCamera(CameraUpdate.newLatLng(LatLng(latitude, longitude)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: "Search Suppliers",
            border: InputBorder.none,
            icon: Icon(Icons.search_outlined),
          ),
          onSubmitted: (query) {
            Provider.of<SupplierChangeNotifier>(context, listen: false)
                .searchSuppliers(query);
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              Provider.of<SupplierChangeNotifier>(context, listen: false)
                  .searchSuppliers(_searchController.text);
            },
            icon: const Icon(Icons.search),
          )
        ],
      ),
      body: Consumer<SupplierChangeNotifier>(
        builder: (context, supplierNotifier, child) {
          final suppliers = supplierNotifier.suppliers;

          return SlidingUpPanel(
            minHeight: MediaQuery.of(context).size.height * 0.2,
            maxHeight: MediaQuery.of(context).size.height * 0.5,
            backdropEnabled: true,
            panel: Column(
              children: [
                // Drag Handle
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: MediaQuery.of(context).size.width * 0.1,
                  height: MediaQuery.of(context).size.height * 0.0075,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                // Supplier List
                suppliers.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          "No suppliers found",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: suppliers.length,
                          itemBuilder: (context, index) {
                            final supplier = suppliers[index];
                            return ListTile(
                              title: Text(
                                supplier.provider_name,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColorDark),
                              ),
                              subtitle: Text(
                                AppLocalizations.of(context)!
                                        .providerCategoryTextList
                                        .split(",")[
                                    supplier.product_provider_type_id - 1],
                                style: TextStyle(
                                    color: Theme.of(context).primaryColorDark),
                              ),
                              trailing: IconButton(
                                onPressed: () => _focusOnLocation(
                                    supplier.location_latitude,
                                    supplier.location_longitude),
                                icon: const Icon(Icons.location_on_outlined),
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
            body: MapScreen(
              onMapCreated: (controller) => _mapController = controller,
              userLocation: supplierNotifier.currentLocation,
              suppliers: suppliers,
            ),
          );
        },
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
            Text(
                '${AppLocalizations.of(context)!.locationText}: ${supplier.location_name}'),
            GestureDetector(
              child: Text(supplier.provider_contact_info.replaceAll(",", "\n")),
              onLongPress: () {
                Clipboard.setData(
                    ClipboardData(text: supplier.provider_contact_info));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard')),
                );
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
