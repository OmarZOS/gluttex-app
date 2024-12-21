import 'dart:typed_data';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:image/image.dart' as img;
import 'package:custom_image_crop/custom_image_crop.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Uint8List resizeImage(Uint8List data, int width, int height) {
  // Decode the image from Uint8List
  img.Image? image = img.decodeImage(data);
  if (image == null) {
    throw Exception("Failed to decode image.");
  }

  // Resize the image to the desired dimensions
  img.Image resizedImage = img.copyResize(image, width: width, height: height);

  // Encode the image back to Uint8List
  return Uint8List.fromList(img.encodePng(resizedImage));
}

class ImagePickerComponent extends StatefulWidget {
  final Function(Uint8List) onImageEdited;
  final Uint8List? initialProductImage;

  const ImagePickerComponent({
    Key? key,
    this.initialProductImage,
    required this.onImageEdited,
  }) : super(key: key);

  @override
  _ImagePickerComponentState createState() => _ImagePickerComponentState();
}

class _ImagePickerComponentState extends State<ImagePickerComponent> {
  late CustomImageCropController controller;
  CustomCropShape _currentShape = CustomCropShape.Square;
  final CustomImageFit _imageFit = CustomImageFit.fillCropSpace;
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _radiusController = TextEditingController();
  Uint8List? productImage;
  double _width = 16;
  double _height = 9;
  double _radius = 4;

  @override
  void initState() {
    super.initState();
    productImage = widget.initialProductImage;
    controller = CustomImageCropController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _changeCropShape(CustomCropShape newShape) {
    setState(() {
      _currentShape = newShape;
    });
  }

  void _updateRatio() {
    setState(() {
      if (_widthController.text.isNotEmpty) {
        _width = double.tryParse(_widthController.text) ?? 16;
      }
      if (_heightController.text.isNotEmpty) {
        _height = double.tryParse(_heightController.text) ?? 9;
      }
      if (_radiusController.text.isNotEmpty) {
        _radius = double.tryParse(_radiusController.text) ?? 4;
      }
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: productImage != null
              ? CustomImageCrop(
                  cropController: controller,
                  image: MemoryImage(productImage!),
                  shape: _currentShape,
                  ratio: _currentShape == CustomCropShape.Square
                      ? Ratio(width: _width, height: _height)
                      : null,
                  canRotate: true,
                  canMove: true,
                  canScale: true,
                  borderRadius:
                      _currentShape == CustomCropShape.Ratio ? _radius : 0,
                  customProgressIndicator: const CupertinoActivityIndicator(),
                  imageFit: _imageFit,
                  pathPaint: Paint()
                    ..color = Colors.red
                    ..strokeWidth = 4.0
                    ..style = PaintingStyle.stroke
                    ..strokeJoin = StrokeJoin.round,
                )
              : Center(
                  child:
                      Text(AppLocalizations.of(context)!.noImageSelectedTxt)),
        ),
        ElevatedButton(
          onPressed: () async {
            // Crop the image and pass it back
            final croppedImage = await controller.onCropImage();
            if (croppedImage != null) {
              widget.onImageEdited(croppedImage as Uint8List);
            }
          },
          child: const Icon(Icons.crop),
        ),
      ],
    );
  }

  Widget getShapeIcon(CustomCropShape shape) {
    switch (shape) {
      case CustomCropShape.Circle:
        return const Icon(Icons.circle_outlined);
      case CustomCropShape.Square:
        return const Icon(Icons.square_outlined);
      case CustomCropShape.Ratio:
        return const Icon(Icons.crop_16_9_outlined);
    }
  }
}
