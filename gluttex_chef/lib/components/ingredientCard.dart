import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class IngredientCard extends StatelessWidget {
  final String name;
  final String quantity;
  final String icon;
  final VoidCallback onClicked;

  const IngredientCard({
    super.key,
    required this.name,
    required this.quantity,
    required this.icon,
    required this.onClicked,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

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
                child: SvgPicture.string(
                  icon,
                  width: 28,
                  height: 28,
                  colorFilter: ColorFilter.mode(
                    theme.colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                  placeholderBuilder: (context) => SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
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
                  Text(
                    quantity,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),

              // Spacer and close icon
              const SizedBox(width: 8),
              Icon(
                Icons.close,
                size: 20,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
