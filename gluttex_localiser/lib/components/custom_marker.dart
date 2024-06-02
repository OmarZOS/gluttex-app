import 'dart:typed_data';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
// import 'package:image/image.dart' as img;

Future<Uint8List> getBytesFromAsset(String path, int width) async {
  ByteData data = await rootBundle.load(path);
  // img.Image baseImage = img.decodeImage(data.buffer.asUint8List())!;
  // img.Image resizedImage = img.copyResize(baseImage, width: width);
  // return Uint8List.fromList(img.encodePng(resizedImage));
  throw UnimplementedError();
}

Future<BitmapDescriptor> createCustomMarkerWithProfile(
    String profileImagePath, String markerImagePath) async {
  // Load profile image
  final Uint8List profileImageBytes =
      await getBytesFromAsset(profileImagePath, 100);

  // Load base marker image
  final Uint8List markerImageBytes =
      await getBytesFromAsset(markerImagePath, 150);

  // Decode images
  // img.Image profileImage = img.decodeImage(profileImageBytes)!;
  // img.Image markerImage = img.decodeImage(markerImageBytes)!;

  // // Composite images
  // img.drawImage(markerImage, profileImage,
  //     dstX: (markerImage.width - profileImage.width) ~/ 2,
  //     dstY: (markerImage.height - profileImage.height) ~/ 2);

  // // Encode the result
  // final Uint8List markerWithProfileBytes =
  //     Uint8List.fromList(img.encodePng(markerImage));

  // return BitmapDescriptor.fromBytes(markerWithProfileBytes);
  throw UnimplementedError();
}
