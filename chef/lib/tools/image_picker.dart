import 'dart:typed_data';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:ui/Services/SnackbarService.dart';
import 'package:image/image.dart' as img;
import 'package:custom_image_crop/custom_image_crop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImagePickerComponent extends StatefulWidget {
  final ValueChanged<Uint8List> onImageEdited;
  final Uint8List? initialRecipeImage;

  const ImagePickerComponent({
    super.key,
    this.initialRecipeImage,
    required this.onImageEdited,
  });

  @override
  State<ImagePickerComponent> createState() => _ImagePickerComponentState();
}

class _ImagePickerComponentState extends State<ImagePickerComponent> {
  late final CustomImageCropController _controller;
  final List<CustomCropShape> _availableShapes = [
    CustomCropShape.Circle,
    CustomCropShape.Square,
    CustomCropShape.Ratio,
  ];
  CustomCropShape _currentShape = CustomCropShape.Square;
  Uint8List? _recipeImage;
  final _aspectRatio = ValueNotifier<Ratio>(Ratio(width: 16, height: 9));
  final _borderRadius = ValueNotifier<double>(4);

  @override
  void initState() {
    super.initState();
    _controller = CustomImageCropController();
    _recipeImage = widget.initialRecipeImage;
  }

  @override
  void dispose() {
    _controller.dispose();
    _aspectRatio.dispose();
    _borderRadius.dispose();
    super.dispose();
  }

  Future<void> _cropAndSaveImage() async {
    try {
      final croppedImage = await _controller.onCropImage();
      if (croppedImage == null) return;

      final imageBytes = croppedImage as Uint8List;
      widget.onImageEdited(imageBytes);
    } catch (e) {
      SnackbarService.showSnackbar(
          context: context,
          backgroundColor: Colors.red,
          message: AppLocalizations.of(context)!.imageProcessingErrorText);
    }
  }

  Widget _buildShapeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _availableShapes.map((shape) {
        return IconButton(
          icon: _getShapeIcon(shape),
          color: _currentShape == shape
              ? Theme.of(context).colorScheme.primary
              : null,
          onPressed: () => setState(() => _currentShape = shape),
        );
      }).toList(),
    );
  }

  Widget _getShapeIcon(CustomCropShape shape) {
    switch (shape) {
      case CustomCropShape.Circle:
        return const Icon(Icons.circle_outlined);
      case CustomCropShape.Square:
        return const Icon(Icons.square_outlined);
      case CustomCropShape.Ratio:
        return const Icon(Icons.crop_16_9_outlined);
    }
  }

  Widget _buildRatioControls() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _currentShape == CustomCropShape.Ratio
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: '16',
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.widthText,
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (value) {
                            final width = double.tryParse(value);
                            if (width != null && width > 0) {
                              _aspectRatio.value = Ratio(
                                width: width,
                                height: _aspectRatio.value.height,
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          initialValue: '9',
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.heightText,
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (value) {
                            final height = double.tryParse(value);
                            if (height != null && height > 0) {
                              _aspectRatio.value = Ratio(
                                width: _aspectRatio.value.width,
                                height: height,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _borderRadius.value,
                    min: 0,
                    max: 20,
                    divisions: 20,
                    label: _borderRadius.value.toStringAsFixed(0),
                    onChanged: (value) => _borderRadius.value = value,
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildCropButton() {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      onPressed: _cropAndSaveImage,
      child: const Icon(Icons.crop),
    );
  }

  Widget _buildImageCropArea() {
    if (_recipeImage == null) {
      return Center(
        child: Text(AppLocalizations.of(context)!.noImageSelectedTxt),
      );
    }

    return ValueListenableBuilder<Ratio>(
      valueListenable: _aspectRatio,
      builder: (context, ratio, _) {
        return ValueListenableBuilder<double>(
          valueListenable: _borderRadius,
          builder: (context, radius, _) {
            return CustomImageCrop(
              cropController: _controller,
              image: MemoryImage(_recipeImage!),
              shape: _currentShape,
              ratio: _currentShape == CustomCropShape.Ratio ? ratio : null,
              canRotate: true,
              canMove: true,
              canScale: true,
              borderRadius: _currentShape == CustomCropShape.Ratio ? radius : 0,
              customProgressIndicator: const CircularProgressIndicator(),
              imageFit: CustomImageFit.fillCropSpace,
              pathPaint: Paint()
                ..color = Theme.of(context).colorScheme.primary
                ..strokeWidth = 2.0
                ..style = PaintingStyle.stroke
                ..strokeJoin = StrokeJoin.round,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildShapeSelector(),
        _buildRatioControls(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildImageCropArea(),
          ),
        ),
        _buildCropButton(),
      ],
    );
  }
}

Uint8List resizeImage(Uint8List data, int width, int height) {
  try {
    final image = img.decodeImage(data);
    if (image == null) throw Exception("Failed to decode image");

    final resizedImage = img.copyResize(
      image,
      width: width,
      height: height,
      interpolation: img.Interpolation.average,
    );

    return Uint8List.fromList(img.encodePng(resizedImage));
  } catch (e) {
    throw Exception("Image processing failed: ${e.toString()}");
  }
}
