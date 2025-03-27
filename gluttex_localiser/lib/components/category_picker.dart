import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_localiser/components/supplier_icon.dart';

class CategoryPicker extends StatefulWidget {
  final ValueChanged<int> onCategoryChanged;
  final List<SupplierCategory> categories;
  final int initialSelection;

  const CategoryPicker({
    Key? key,
    required this.onCategoryChanged,
    required this.categories,
    this.initialSelection = 0,
  }) : super(key: key);

  @override
  _CategoryPickerState createState() => _CategoryPickerState();
}

class _CategoryPickerState extends State<CategoryPicker> {
  late int _selectedCategoryIndex;

  @override
  void initState() {
    super.initState();
    _selectedCategoryIndex = widget.initialSelection;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final categoryNames = localizations.providerCategoryTextList.split(",");

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.dividerColor,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showPicker(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/${_selectedCategoryIndex + 1}.svg',
                color: theme.colorScheme.primary,
                width: 32,
                height: 32,
                package: "gluttex_localiser",
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "localizations.categ",
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      categoryNames[_selectedCategoryIndex],
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showPicker(BuildContext context) async {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final categoryNames = localizations.providerCategoryTextList.split(",");

    await showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.4,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    localizations.addText,
                    style: theme.textTheme.titleMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(
                  initialItem: _selectedCategoryIndex,
                ),
                itemExtent: 48,
                onSelectedItemChanged: (int index) {
                  setState(() {
                    _selectedCategoryIndex = index;
                  });
                  widget.onCategoryChanged(
                    widget.categories[index].productProviderTypeId,
                  );
                },
                children: widget.categories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final category = entry.value;
                  return Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/${index + 1}.svg',
                          color: theme.colorScheme.primary,
                          width: 24,
                          height: 24,
                          package: "gluttex_localiser",
                        ),
                        const SizedBox(width: 12),
                        Text(
                          categoryNames[category.productProviderTypeId - 1],
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
