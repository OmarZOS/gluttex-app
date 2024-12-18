import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gluttex_constants/gluttex_constants.dart';

Future<LatLng?> showLocationInputDialog(BuildContext context) async {
  TextEditingController latController = TextEditingController();
  TextEditingController lngController = TextEditingController();
  return showDialog<LatLng>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(GluttexConstants.insertCoordinatesMsg),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: latController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration:
                  const InputDecoration(labelText: GluttexConstants.latitudeMsg),
            ),
            TextField(
              controller: lngController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration:
                  const InputDecoration(labelText: GluttexConstants.longitudeMsg),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(GluttexConstants.cancelTxt),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: const Text(GluttexConstants.setLocationMsg),
            onPressed: () {
              double? latitude = double.tryParse(latController.text);
              double? longitude = double.tryParse(lngController.text);
              if (latitude != null && longitude != null) {
                Navigator.of(context).pop(LatLng(latitude, longitude));
              } else {
                // Show an error or handle invalid input
              }
            },
          ),
        ],
      );
    },
  );
}
