import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<LatLng?> showLocationInputDialog(BuildContext context) async {
  TextEditingController latController = TextEditingController();
  TextEditingController lngController = TextEditingController();
  return showDialog<LatLng>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Enter Coordinates'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: latController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Latitude'),
            ),
            TextField(
              controller: lngController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Longitude'),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: Text('Set Location'),
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
