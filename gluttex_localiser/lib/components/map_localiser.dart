import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';

class MapPicker extends StatefulWidget {
  const MapPicker({Key? key}) : super(key: key);

  @override
  _MapPickerState createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker> {
  GoogleMapController? _mapController;
  Marker? _marker;
  LatLng? _markerPosition;
  bool _loading = true;
  BitmapDescriptor? _customMarker;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _createCustomMarker();
    await _getCurrentLocation();
  }

  Future<void> _createCustomMarker() async {
    // final marker =
    // Marker(
    //   icon: BitmapDescriptor.defaultMarker,
    // );
    // await createCustomMarkerWithProfile(
    //   'assets/profile.png', // Path to profile image
    //   'assets/Pin_source.png', // Path to marker image
    // );

    setState(() {
      // _customMarker = marker;
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    // LocationPermission permission;

    // serviceEnabled = await Geolocator.isLocationServiceEnabled();
    // if (!serviceEnabled) {
    //   return Future.error('Location services are disabled.');
    // }

    // permission = await Geolocator.checkPermission();
    // if (permission == LocationPermission.denied) {
    //   permission = await Geolocator.requestPermission();
    //   if (permission == LocationPermission.denied) {
    //     return Future.error('Location permissions are denied');
    //   }
    // }

    // if (permission == LocationPermission.deniedForever) {
    //   return Future.error(
    //       'Location permissions are permanently denied, we cannot request permissions.');
    // }

    // Position position = await Geolocator.getCurrentPosition(
    //     desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _loading = false;
      // _markerPosition = LatLng(position.latitude, position.longitude);
      _marker = Marker(
        markerId: const MarkerId('currentLocation'),
        position: _markerPosition!,
        icon: _customMarker ?? BitmapDescriptor.defaultMarker,
        draggable: true,
        onDragEnd: (LatLng newPosition) {
          setState(() {
            _markerPosition = newPosition;
          });
        },
      );
    });

    _mapController?.animateCamera(CameraUpdate.newLatLng(_markerPosition!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Picker'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: _markerPosition ?? const LatLng(0, 0),
                zoom: 15,
              ),
              // markers: _marker != null ? {_marker!} : <dynamic>{},
              onTap: (LatLng position) {
                setState(() {
                  _markerPosition = position;
                  _marker = Marker(
                    markerId: const MarkerId('selectedLocation'),
                    position: position,
                    icon: _customMarker ?? BitmapDescriptor.defaultMarker,
                    draggable: true,
                    onDragEnd: (LatLng newPosition) {
                      setState(() {
                        _markerPosition = newPosition;
                      });
                    },
                  );
                });
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_markerPosition != null) {
            Navigator.pop(context, _markerPosition);
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
