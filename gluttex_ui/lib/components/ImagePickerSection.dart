import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final bool landscape;
  final void Function(GluttexImage? newImageUrl)? onImageUploaded;

  const ImagePickerSection(
      {super.key,
      required this.initialImageUrl,
      required this.entityType,
      required this.ownerId,
      required this.entityId,
      this.onImageUploaded,
      this.landscape = false});

  @override
  State<ImagePickerSection> createState() => _ImagePickerSectionState();
}

class _ImagePickerSectionState extends State<ImagePickerSection> {
  File? _pickedImageFile;
  bool _isUploading = false;
  bool _isHovering = false;
  late final ImagePicker _picker = ImagePicker();
  late final landscape;

  @override
  void initState() {
    landscape = widget.landscape;
    super.initState();
  }

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
        filepath: path,
        filename: path.split("/").last,
        entityType: widget.entityType,
        ownerId: widget.ownerId,
        entityId: widget.entityId,
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
              height: landscape ? 200 : MediaQuery.of(context).size.width * 0.5,
              width: landscape
                  ? double.infinity
                  : MediaQuery.of(context).size.width * 0.5,
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        _pickedImageFile!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    )
                  else if (widget.initialImageUrl != null &&
                      widget.initialImageUrl!.isNotEmpty)
                    ClipRRect(
                      // Make sure this matches the condition above
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        widget.initialImageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
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
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholder(theme, loc);
                        },
                      ),
                    )
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
                              color: theme.colorScheme.onSurface,
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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: _isUploading
                      ? null
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primaryContainer,
                          ],
                        ),
                  boxShadow: _isUploading
                      ? null
                      : [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: FilledButton.icon(
                  icon: _isUploading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : const Icon(Icons.camera_alt, size: 22),
                  label: _isUploading
                      ? Text(
                          "loc.uploadingImage",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        )
                      : Text(
                          hasImage ? loc.changeImage : loc.uploadImage,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor:
                        _isUploading ? Colors.grey[300] : Colors.transparent,
                    foregroundColor: _isUploading
                        ? Colors.grey[600]
                        : Theme.of(context).colorScheme.onPrimary,
                    elevation: 0,
                  ),
                  onPressed: _isUploading ? null : _pickImage,
                ),
              ),
            ),
            if (_pickedImageFile != null) ...[
              const SizedBox(width: 12),
              AnimatedScale(
                duration: const Duration(milliseconds: 300),
                scale: _isUploading ? 0.9 : 1.0,
                child: Tooltip(
                  message: loc.removeImage,
                  child: IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: _isUploading
                          ? Colors.grey[300]
                          : Theme.of(context).colorScheme.errorContainer,
                      foregroundColor: _isUploading
                          ? Colors.grey[600]
                          : Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    onPressed: _isUploading
                        ? null
                        : () {
                            HapticFeedback.lightImpact();
                            setState(() => _pickedImageFile = null);
                          },
                    icon: _isUploading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.onErrorContainer,
                              ),
                            ),
                          )
                        : const Icon(Icons.delete_outline, size: 22),
                  ),
                ),
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
