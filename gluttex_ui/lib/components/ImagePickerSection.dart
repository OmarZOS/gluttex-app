import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/GluttexImage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:locator/locator.dart';

class ImagePickerSection extends StatefulWidget {
  final String? initialImageUrl;
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
  bool _isHovering = false;
  late final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final context = this.context;
    final loc = AppLocalizations.of(context)!;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(loc.gallery),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(loc.camera),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final picked = await _picker.pickImage(source: source);
      if (picked != null && mounted) {
        setState(() => _pickedImageFile = File(picked.path));
        _uploadImage(picked.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.imagePickFailed),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  void _uploadImage(String path) async {
    setState(() => _isUploading = true);

    try {
      GluttexImage gluttexImage = GluttexLocator.get<GluttexImage>();

      gluttexImage.setupImage(
        path,
        path.split("/").last,
        widget.entityType,
        widget.ownerId,
        widget.entityId,
      );

      widget.onImageUploaded?.call(gluttexImage);

      // if (mounted) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text("AppLocalizations.of(context)!.imageUploadSuccess"),
      //     backgroundColor: Colors.green,
      //     behavior: SnackBarBehavior.floating,
      //   ),
      // );
      // }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('{AppLocalizations.of(context)!.uploadFailed}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final hasImage = _pickedImageFile != null ||
        (widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty);

    return Column(
      children: [
        // Image Preview Card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _isUploading ? null : _pickImage,
            onHover: (hovering) => setState(() => _isHovering = hovering),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Image Content
                  if (_isUploading)
                    const Center(child: CircularProgressIndicator())
                  else if (_pickedImageFile != null)
                    _buildImageFile(_pickedImageFile!)
                  else if (widget.initialImageUrl != null &&
                      widget.initialImageUrl!.isNotEmpty)
                    _buildNetworkImage(widget.initialImageUrl!)
                  else
                    _buildPlaceholder(theme, loc),

                  // Hover Effect
                  if (_isHovering && !_isUploading)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              hasImage ? Icons.edit : Icons.add_a_photo,
                              size: 36,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              hasImage ? loc.changeImage : loc.selectImage,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Action Buttons
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: Text(loc.uploadImage),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isUploading ? null : _pickImage,
              ),
            ),
            if (hasImage) ...[
              const SizedBox(width: 12),
              IconButton.filled(
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isUploading
                    ? null
                    : () => setState(() => _pickedImageFile = null),
                icon: const Icon(Icons.delete),
                tooltip: loc.removeImage,
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildImageFile(File file) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.file(
        file,
        fit: BoxFit.cover,
        width: double.infinity,
      ),
    );
  }

  Widget _buildNetworkImage(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        "${GluttexConstants.fsBaseUrl}$url",
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildErrorState(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme, AppLocalizations loc) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.image_search,
          size: 48,
          color: theme.colorScheme.onSurface.withOpacity(0.3),
        ),
        const SizedBox(height: 12),
        Text(
          loc.noImageSelected,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          SizedBox(height: 8),
          Text('Failed to load image'),
        ],
      ),
    );
  }
}
