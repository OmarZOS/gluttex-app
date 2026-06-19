import 'package:flutter/material.dart';
import 'package:gluttex_localizations/gen_l10n/app_localizations.dart';

class DateFilterSelector extends StatefulWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const DateFilterSelector({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  State<DateFilterSelector> createState() => _DateFilterSelectorState();
}

class _DateFilterSelectorState extends State<DateFilterSelector> {
  final List<Map<String, dynamic>> _filters = [
    {'value': 'today', 'label': 'Today'},
    {'value': 'week', 'label': 'This Week'},
    {'value': 'month', 'label': 'This Month'},
    {'value': 'quarter', 'label': 'This Quarter'},
    {'value': 'year', 'label': 'This Year'},
    {'value': 'all', 'label': 'All Time'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((filter) {
            final isSelected = widget.selectedFilter == filter['value'];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilterChip(
                label: Text(
                  _getLocalizedLabel(filter['label'] as String, loc),
                  style: TextStyle(
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    widget.onFilterChanged(filter['value'] as String);
                  }
                },
                backgroundColor: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceVariant,
                selectedColor: theme.colorScheme.primary,
                checkmarkColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getLocalizedLabel(String label, AppLocalizations loc) {
    switch (label) {
      case 'Today':
        return loc.today;
      case 'This Week':
        return loc.thisWeek;
      case 'This Month':
        return loc.thisMonth;
      case 'This Quarter':
        return loc.thisQuarter;
      case 'This Year':
        return loc.thisYear;
      case 'All Time':
        return loc.allTime;
      default:
        return label;
    }
  }
}
