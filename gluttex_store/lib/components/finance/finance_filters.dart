import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_event/views/finance_view_model.dart';
import 'package:provider/provider.dart';

class DateFilterSelector extends StatelessWidget {
  const DateFilterSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final viewModel = context.watch<FinanceViewModel>();

    // Get the current date filter from the business filter or use default
    final currentDateFilter = viewModel.businessFilter.dateRangeType ?? 'today';

    return _DateFilterList(
      filters: [
        DateFilter('today', localizations.today),
        DateFilter('week', localizations.thisWeek),
        DateFilter('month', localizations.thisMonth),
        DateFilter('quarter', localizations.thisQuarter),
        DateFilter('year', localizations.thisYear),
        DateFilter('all', localizations.allTime),
      ],
      selectedFilter: currentDateFilter,
      onFilterSelected: (filter) => viewModel.selectDateFilter(filter),
    );
  }
}

class _DateFilterList extends StatelessWidget {
  final List<DateFilter> filters;
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  const _DateFilterList({
    required this.filters,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = selectedFilter == filter.id;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _DateFilterChip(
                label: filter.label,
                isSelected: isSelected,
                onSelected: () => onFilterSelected(filter.id),
                selectedColor: colorScheme.primary,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _DateFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;
  final Color selectedColor;

  const _DateFilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
    required this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? selectedColor : colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: isSelected
          ? selectedColor.withOpacity(0.1)
          : colorScheme.surfaceVariant,
      selectedColor: selectedColor.withOpacity(0.2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color:
              isSelected ? selectedColor : colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      showCheckmark: false,
    );
  }
}

class DateFilter {
  final String id;
  final String label;

  const DateFilter(this.id, this.label);
}
