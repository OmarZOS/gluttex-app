// ui/lib/components/store/dashboard_header.dart

import 'package:flutter/material.dart';

/// A simple, non-collapsing header used at the top of dashboard screens.
///
/// Renders a leading icon, a title, an optional subtitle, an optional
/// trailing action row, and an optional search bar. Everything is laid out
/// in a `Column` with fixed padding — no `SliverAppBar`, no
/// `FlexibleSpaceBar`, no transforms.
///
/// This is intentionally not the same thing as a collapsing header: it's
/// a header that stays put while the content below scrolls. Use it when
/// the screen has its own scroll view and the header should not participate
/// in the scroll.
class DashboardHeader extends StatelessWidget {
  final IconData? leadingIcon;
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget? searchBar;
  final EdgeInsetsGeometry padding;

  const DashboardHeader({
    super.key,
    required this.title,
    this.leadingIcon,
    this.subtitle,
    this.actions = const [],
    this.searchBar,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 8),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      color: cs.surface,
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: 22, color: cs.primary),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ...actions,
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (searchBar != null) ...[
            const SizedBox(height: 12),
            searchBar!,
          ],
        ],
      ),
    );
  }
}
