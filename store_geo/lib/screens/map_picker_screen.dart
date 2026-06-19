import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MapPickerHomeScreen(),
    );
  }
}

class MapPickerHomeScreen extends StatelessWidget {
  const MapPickerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // title: const Text('Home Screen'),
          ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // LatLng? pickedLocation = await Navigator.push(
            //   context,
            //   // MaterialPageRoute(builder: (context) => const MapPicker()),
            // );

            // if (pickedLocation != null) {
            //   ScaffoldMessenger.of(context).showSnackBar(
            //     SnackBar(
            //       content: Text(
            //           'Picked Location: ${pickedLocation.latitude}, ${pickedLocation.longitude}'),
            //     ),
            //   );
            // }
          },
          child: const Text('Pick Location on Map'),
        ),
      ),
    );
  }
}
