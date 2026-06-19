import 'package:flutter/material.dart';
import 'package:gluttex_localizations/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/finance/BusinessOperation.dart';
import 'package:provider/provider.dart';
import 'package:event/views/finance_view_model.dart';

class BusinessOperationsFilters extends StatefulWidget {
  const BusinessOperationsFilters({super.key});

  @override
  State<BusinessOperationsFilters> createState() =>
      _BusinessOperationsFiltersState();
}

class _BusinessOperationsFiltersState extends State<BusinessOperationsFilters> {
  String? _selectedStatus;
  String? _selectedSource;

  void _applyFilters(FinanceViewModel viewModel) {
    final filter = viewModel.businessFilter.copyWith(
      paymentStatus: _selectedStatus,
      sourceTable: _selectedSource,
    );
    viewModel.setBusinessFilter(filter);
  }

  void _clearFilters(FinanceViewModel viewModel) {
    viewModel.setBusinessFilter(const BusinessFilter());
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final viewModel = context.watch<FinanceViewModel>();
    final hasFilters = _selectedStatus != null || _selectedSource != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          _FilterChip(
            label: localizations.status,
            value: _selectedStatus,
            items: const [
              FilterItem(null, 'All'),
              FilterItem('paid', 'Paid'),
              FilterItem('partial', 'Partial'),
              FilterItem('unpaid', 'Unpaid'),
              FilterItem('overdue', 'Overdue'),
            ],
            onChanged: (value) {
              setState(() => _selectedStatus = value);
              _applyFilters(viewModel);
            },
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: localizations.source,
            value: _selectedSource,
            items: const [
              FilterItem(null, 'All'),
              FilterItem('cart_based', 'Carts'),
              FilterItem('order_based', 'Orders'),
            ],
            onChanged: (value) {
              setState(() => _selectedSource = value);
              _applyFilters(viewModel);
            },
          ),
          const Spacer(),
          if (hasFilters)
            _ClearButton(
              onPressed: () {
                setState(() {
                  _selectedStatus = null;
                  _selectedSource = null;
                });
                _clearFilters(viewModel);
              },
              colorScheme: colorScheme,
              label: localizations.clearFilters,
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String? value;
  final List<FilterItem> items;
  final ValueChanged<String?> onChanged;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedItem = items.firstWhere(
      (item) => item.value == value,
      orElse: () => items.first,
    );

    return GestureDetector(
      onTap: () => _showFilterSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_alt_outlined,
              size: 14,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              '$label: ${selectedItem.displayLabel}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ...items.map((item) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Radio<String?>(
                  value: item.value,
                  groupValue: value,
                  onChanged: (newValue) {
                    onChanged(newValue);
                    Navigator.pop(context);
                  },
                  activeColor: colorScheme.primary,
                ),
                title: Text(
                  item.displayLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: item.value == value ? FontWeight.w600 : null,
                  ),
                ),
                onTap: () {
                  onChanged(item.value);
                  Navigator.pop(context);
                },
              );
            }).toList(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class FilterItem {
  final String? value;
  final String displayLabel;

  const FilterItem(this.value, this.displayLabel);
}

class _ClearButton extends StatelessWidget {
  final VoidCallback onPressed;
  final ColorScheme colorScheme;
  final String label;

  const _ClearButton({
    required this.onPressed,
    required this.colorScheme,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: Icon(
        Icons.clear_all,
        size: 14,
        color: colorScheme.error,
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: colorScheme.error,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
