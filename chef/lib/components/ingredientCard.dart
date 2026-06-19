import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gluttex_localizations/gen_l10n/app_localizations.dart';
import 'package:app_constants/app_constants.dart';

class IngredientCard extends StatelessWidget {
  final String name;
  final String quantity;
  final int id;
  final VoidCallback onClicked;
  final String? imageUrl; // Optional image URL for ingredient

  const IngredientCard({
    super.key,
    required this.name,
    required this.quantity,
    required this.id,
    required this.onClicked,
    this.imageUrl,
  });

  /// Build ingredient icon with priority: URL > SVG asset > Fallback icon
  Widget _buildIngredientIcon(BuildContext context) {
    final hasValidUrl = imageUrl != null &&
        imageUrl!.isNotEmpty &&
        (imageUrl!.startsWith('http') || imageUrl!.startsWith('https'));

    final svgAssetPath = 'assets/ingredient_svg/$id.svg';

    if (!hasValidUrl) {
      return _buildSvgIcon(context, svgAssetPath);
    }

    final isSvgUrl = imageUrl!.toLowerCase().endsWith('.svg');

    if (isSvgUrl) {
      return _buildNetworkSvgIcon(context, imageUrl!, svgAssetPath);
    }

    return _buildNetworkImageIcon(context, imageUrl!, svgAssetPath);
  }

  /// Build network SVG icon
  Widget _buildNetworkSvgIcon(
      BuildContext context, String url, String fallbackSvgPath) {
    return SizedBox(
      width: 40,
      height: 40,
      child: SvgPicture.network(
        url,
        width: 32,
        height: 32,
        fit: BoxFit.contain,
        placeholderBuilder: (context) => const SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        errorBuilder: (context, error, stackTrace) {
          return _buildSvgIcon(context, fallbackSvgPath);
        },
      ),
    );
  }

  /// Build network raster image icon (PNG, JPG, JPEG, etc.)
  Widget _buildNetworkImageIcon(
      BuildContext context, String url, String fallbackSvgPath) {
    return SizedBox(
      width: 40,
      height: 40,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          url,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildSvgIcon(context, fallbackSvgPath);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Build local SVG icon with fallback
  Widget _buildSvgIcon(BuildContext context, String svgAssetPath) {
    return SizedBox(
      width: 40,
      height: 40,
      child: SvgPicture.asset(
        svgAssetPath,
        package: "chef",
        width: 32,
        height: 32,
        fit: BoxFit.contain,
        placeholderBuilder: (context) => const SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackIcon(context);
        },
      ),
    );
  }

  /// Build fallback icon when all else fails
  Widget _buildFallbackIcon(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.food_bank,
        size: 24,
        color: theme.colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    log('Parts : ${quantity.toString()}');
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final parts = quantity.split(':'); // ["Kg", "1.0"]
    final loc = AppLocalizations.of(context)!;

    final unitCode = parts[0];
    final amount = parts.length > 1 ? parts[1] : '';
    final unitIndex = AppConstants.recipeUnits
        .indexOf(unitCode); // 'units' is your list of short codes
    final unitName = unitIndex != -1
        ? loc.ingredientUnits.split(',')[unitIndex]
        : unitCode; // fallback to code if not found

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onClicked,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Container
              Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? theme.colorScheme.primary.withOpacity(0.2)
                      : theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: _buildIngredientIcon(context),
              ),
              const SizedBox(width: 12),

              // Text Content
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (quantity.isNotEmpty)
                    Text(
                      "$amount $unitName",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
