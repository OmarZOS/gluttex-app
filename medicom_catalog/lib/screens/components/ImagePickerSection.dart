import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/GluttexImage.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerSection extends StatefulWidget {
  final String? initialImageUrl; // remote URL (from FS)
  final String entityType;
  final String ownerId;
  final String entityId;
  final void Function(GluttexImage? newImageUrl)? onImageUploaded;

  const ImagePickerSection({
    super.key,
    required this.initialImageUrl,
    required this.entityType,
    required this.ownerId,
    required this.entityId,
    this.onImageUploaded,
  });

  @override
  State<ImagePickerSection> createState() => _ImagePickerSectionState();
}

class _ImagePickerSectionState extends State<ImagePickerSection> {
  File? _pickedImageFile;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() => _pickedImageFile = File(picked.path));
      pickImage(picked.path);
    }
  }

  void pickImage(String path) {
    setState(() => _isUploading = true);
    try {
      GluttexImage gluttexImage = GluttexImage(
        filepath: path,
        filename: path.split("/").last,
        entityType: widget.entityType,
        ownerId: widget.ownerId,
        entityId: widget.entityId,
      );

      if (widget.onImageUploaded != null) {
        widget.onImageUploaded!(gluttexImage);
      }
    } catch (e) {
      // Optionally show a snackbar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image upload failed")),
        );
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    final loc = AppLocalizations.of(context)!;

    if (_pickedImageFile != null) {
      content = Image.file(
        _pickedImageFile!,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    } else if (widget.initialImageUrl != null &&
        widget.initialImageUrl!.isNotEmpty) {
      content = Image.network(
        "${GluttexConstants.fsBaseUrl}${widget.initialImageUrl!}",
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 50),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
      );
    } else {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image, size: 50, color: Colors.grey),
          Text(loc.noImageSelectedTxt),
        ],
      );
    }

    return Column(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _isUploading
                ? const Center(child: CircularProgressIndicator())
                : content,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          icon: const Icon(Icons.camera_alt),
          label: Text(loc.pickImageMsg),
          style: OutlinedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12.0),
          ),
          onPressed: _isUploading ? null : _pickImage,
        ),
      ],
    );
  }
}
