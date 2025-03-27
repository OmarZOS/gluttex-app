import 'package:flutter/material.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';

class MapScreen extends StatefulWidget {
  final Function(GoogleMapController) onMapCreated;
  final Position? userLocation;
  final List<Supplier> suppliers;
  final Function(Supplier)? onSupplierTap;

  const MapScreen({
    Key? key,
    required this.onMapCreated,
    required this.userLocation,
    required this.suppliers,
    this.onSupplierTap,
  }) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _updateMarkers();
  }

  @override
  void didUpdateWidget(MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.suppliers != oldWidget.suppliers ||
        widget.userLocation != oldWidget.userLocation) {
      _updateMarkers();
    }
  }

  Future<void> _updateMarkers() async {
    final markers = <Marker>{};
    final loc = AppLocalizations.of(context);

    // Add user location marker
    if (widget.userLocation != null) {
      markers.add(Marker(
        markerId: const MarkerId("user_location"),
        position: LatLng(
            widget.userLocation!.latitude, widget.userLocation!.longitude),
        infoWindow: InfoWindow(title: loc?.locationText ?? "Your Location"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        zIndex: 2,
      ));
    }

    // Add supplier markers
    for (final supplier in widget.suppliers) {
      markers.add(Marker(
        markerId: MarkerId(supplier.idProductProvider.toString()),
        position: LatLng(supplier.locationLatitude, supplier.locationLongitude),
        infoWindow: InfoWindow(
          title: supplier.providerName,
          snippet: loc?.tapForDetailsText ?? "Tap for details",
        ),
        onTap: () => widget.onSupplierTap?.call(supplier),
        zIndex: 1,
      ));
    }

    if (mounted) {
      setState(() => _markers.clear());
      setState(() => _markers.addAll(markers));

      if (_isMapReady && widget.userLocation != null) {
        // Adjust camera to show all markers with padding
        await _mapController.animateCamera(
          CameraUpdate.newLatLngBounds(
            _boundsFromMarkers(markers),
            100, // Padding
          ),
        );
      }
    }
  }

  LatLngBounds _boundsFromMarkers(Set<Marker> markers) {
    var bounds = LatLngBounds(
      southwest: const LatLng(0, 0),
      northeast: const LatLng(0, 0),
    );

    if (markers.isEmpty) return bounds;

    bounds = LatLngBounds(
      southwest: LatLng(
        markers.first.position.latitude,
        markers.first.position.longitude,
      ),
      northeast: LatLng(
        markers.first.position.latitude,
        markers.first.position.longitude,
      ),
    );

    bounds = getBounds(markers);
    _mapController.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50), // 50 is padding
    );

    return bounds;
  }

  @override
  Widget build(BuildContext context) {
    final initialPosition = widget.userLocation != null
        ? LatLng(widget.userLocation!.latitude, widget.userLocation!.longitude)
        : const LatLng(36.6563, 3.0); // Default to Algeria coordinates

    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (controller) {
            _mapController = controller;
            widget.onMapCreated(controller);
            setState(() => _isMapReady = true);
          },
          initialCameraPosition: CameraPosition(
            target: initialPosition,
            zoom: 12.0,
          ),
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          compassEnabled: true,
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
          onTap: (position) {
            // Handle map taps if needed
          },
        ),

        // Custom Location Button
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            child: Icon(
              Icons.my_location,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              if (widget.userLocation != null) {
                _mapController.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    LatLng(
                      widget.userLocation!.latitude,
                      widget.userLocation!.longitude,
                    ),
                    15,
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  LatLngBounds getBounds(Set<Marker> markers) {
    if (markers.isEmpty) {
      return LatLngBounds(
        southwest: LatLng(0, 0),
        northeast: LatLng(0, 0),
      );
    }

    double minLat = markers.first.position.latitude;
    double maxLat = markers.first.position.latitude;
    double minLng = markers.first.position.longitude;
    double maxLng = markers.first.position.longitude;

    for (final marker in markers) {
      if (marker.position.latitude < minLat) minLat = marker.position.latitude;
      if (marker.position.latitude > maxLat) maxLat = marker.position.latitude;
      if (marker.position.longitude < minLng)
        minLng = marker.position.longitude;
      if (marker.position.longitude > maxLng)
        maxLng = marker.position.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
}
