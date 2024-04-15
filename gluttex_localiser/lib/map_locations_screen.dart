import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Set<Marker> _markers = {
    Marker(
      markerId: MarkerId('marker1'),
      position: LatLng(36.73, 3.0869),
      infoWindow: InfoWindow(
        title: 'Marker Title',
        snippet: 'Marker Snippet',
      ),
      icon: BitmapDescriptor.defaultMarker,
    ),
    // Add more markers as needed
  };

  late GoogleMapController mapController;

  final LatLng _center = const LatLng(36.73, 3.0869);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: _center,
        zoom: 13.0,
      ),
      markers: _markers,
    );
  }
}
