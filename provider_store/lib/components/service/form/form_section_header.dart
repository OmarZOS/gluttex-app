// components/form_section_header.dart
import 'package:flutter/material.dart';

class FormSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isExpanded;
  final bool isCompleted;
  final bool isOptional;
  final VoidCallback onTap;

  const FormSectionHeader({
    super.key,
    required this.title,
    required this.icon,
    required this.isExpanded,
    required this.isCompleted,
    required this.isOptional,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    Color backgroundColor;
    Color iconColor;
    Color textColor;
    IconData headerIcon;

    if (isCompleted) {
      backgroundColor = colors.primaryContainer.withOpacity(0.15);
      iconColor = colors.primary;
      textColor = colors.primary;
      headerIcon = Icons.check_circle;
    } else if (isExpanded) {
      backgroundColor = colors.surfaceVariant;
      iconColor = colors.secondary;
      textColor = colors.onSurface;
      headerIcon = icon;
    } else {
      backgroundColor = colors.surfaceVariant.withOpacity(0.5);
      iconColor = colors.onSurfaceVariant;
      textColor = colors.onSurfaceVariant;
      headerIcon = icon;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? colors.primary.withOpacity(0.2)
              : colors.outline.withOpacity(0.1),
          width: isCompleted ? 2 : 1,
        ),
        boxShadow: [
          if (isExpanded)
            BoxShadow(
              color: colors.shadow.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? colors.primary.withOpacity(0.1)
                        : colors.surfaceVariant,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: iconColor.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(headerIcon, size: 20, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ),
                          if (isOptional)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colors.surfaceVariant,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Optional',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (isCompleted)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Completed',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.primary.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                AnimatedRotation(
                  turns: isExpanded ? 0 : -0.25,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Icon(
                    Icons.arrow_right,
                    size: 24,
                    color:
                        isCompleted ? colors.primary : colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
