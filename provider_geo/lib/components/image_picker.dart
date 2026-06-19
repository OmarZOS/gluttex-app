import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

Future<Uint8List?> pickImage() async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  if (image != null) {
    return await image.readAsBytes();
  }
  return null;
}
