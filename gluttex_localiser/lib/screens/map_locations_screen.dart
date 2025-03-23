import 'package:flutter/material.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatelessWidget {
  final Function(GoogleMapController) onMapCreated;
  final Position? userLocation;
  final List<Supplier> suppliers;

  const MapScreen(
      {Key? key,
      required this.onMapCreated,
      required this.userLocation,
      required this.suppliers})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Set<Marker> markers = suppliers.map((supplier) {
      return Marker(
        markerId: MarkerId(supplier.id_product_provider.toString()),
        position:
            LatLng(supplier.location_latitude, supplier.location_longitude),
        infoWindow: InfoWindow(title: supplier.provider_name),
      );
    }).toSet();

    if (userLocation != null) {
      markers.add(Marker(
        markerId: const MarkerId("user_location"),
        position: LatLng(userLocation!.latitude, userLocation!.longitude),
        infoWindow: const InfoWindow(title: "Your Location"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
    }

    return GoogleMap(
      onMapCreated: onMapCreated,
      initialCameraPosition: CameraPosition(
        target: userLocation != null
            ? LatLng(userLocation!.latitude, userLocation!.longitude)
            : const LatLng(36.6563, 3.0),
        zoom: 10.0,
      ),
      markers: markers,
    );
  }
}
