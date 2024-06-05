import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatelessWidget {
  final Function(double, double) onFocusLocation;
  final Function(GoogleMapController) onMapCreated;
  final Set<Marker> markers;

  const MapScreen({
    Key? key,
    required this.onFocusLocation,
    required this.onMapCreated,
    required this.markers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: (controller) {
        onMapCreated(controller);
      },
      initialCameraPosition: const CameraPosition(
        target: LatLng(30.65630000, 2.64740000),
        zoom: 10.0,
      ),
      markers: markers,
    );
  }
}
