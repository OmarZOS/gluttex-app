import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_constants/gluttex_constants.dart';

class IngredientCard extends StatelessWidget {
  final String name;
  final String quantity;
  final int id;
  final VoidCallback onClicked;

  const IngredientCard({
    super.key,
    required this.name,
    required this.quantity,
    required this.id,
    required this.onClicked,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final parts = quantity.split(':'); // ["Kg", "1.0"]
    final loc = AppLocalizations.of(context)!;

    final unitCode = parts[0];
    final amount = parts.length > 1 ? parts[1] : '';
    final unitIndex = GluttexConstants.recipeUnits
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
                child: SvgPicture.asset(
                  'assets/ingredient_svg/$id.svg',
                  package: "gluttex_chef",
                  width: 28,
                  height: 28,
                  placeholderBuilder: (context) => const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),
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
                  quantity != ""
                      ? Text(
                          "$amount $unitName",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        )
                      : Container(),
                ],
              ),

              // Spacer and close icon
              const SizedBox(width: 8),
              // Icon(
              //   Icons.close,
              //   size: 20,
              //   color: theme.colorScheme.onSurface.withOpacity(0.6),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
