import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_event/supplier_change_notifier.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SupplierSearchFilter extends StatefulWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final int? selectedCategoryId;
  final ValueChanged<int?> onCategoryChanged;

  const SupplierSearchFilter({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    this.selectedCategoryId,
    required this.onCategoryChanged,
  });

  @override
  State<SupplierSearchFilter> createState() => _SupplierSearchFilterState();
}

class _SupplierSearchFilterState extends State<SupplierSearchFilter> {
  late ScrollController _scrollController;
  late FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SearchBar(
              controller: widget.searchController,
              query: widget.searchQuery,
              onChanged: widget.onSearchChanged,
              focusNode: _searchFocusNode,
              onClear: () {
                widget.searchController.clear();
                widget.onSearchChanged('');
                _searchFocusNode.unfocus();
              },
            ),
            const SizedBox(height: 12),
            Consumer<SupplierChangeNotifier>(
              builder: (context, notifier, child) {
                final categories = _extractUniqueCategories(
                  context,
                  notifier.suppliers,
                );
                return _CategoryChips(
                  categories: categories,
                  selectedCategoryId: widget.selectedCategoryId,
                  onCategoryChanged: widget.onCategoryChanged,
                  scrollController: _scrollController,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<_SupplierCategory> _extractUniqueCategories(
    BuildContext context,
    List suppliers,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final categories = <_SupplierCategory>[
      _SupplierCategory(
        id: 0,
        name: AppLocalizations.of(context)!.allText,
        color: colorScheme.primary,
        icon: Icons.all_inclusive_rounded,
      ),
    ];

    if (suppliers.isEmpty) return categories;

    final seenIds = <int>{};
    int colorIndex = 0;

    final categoryNames =
        AppLocalizations.of(context)!.providerCategoryTextList.split(',');

    for (final supplier in suppliers) {
      final categoryId = supplier.productProviderTypeId;

      if (categoryId != null &&
          !seenIds.contains(categoryId) &&
          categoryId < categoryNames.length) {
        final categoryName = categoryNames[categoryId];

        if (categoryName.isNotEmpty) {
          seenIds.add(categoryId);

          categories.add(_SupplierCategory(
            id: categoryId,
            name: categoryName,
            color: Theme.of(context).colorScheme.onSurface,
            icon: _getCategoryIcon(categoryId),
          ));

          colorIndex++;
        }
      }
    }

    return categories;
  }

  IconData _getCategoryIcon(int categoryId) {
    // Map category IDs to appropriate icons
    const icons = [
      Icons.restaurant_rounded,
      Icons.local_florist_rounded,
      Icons.cake_rounded,
      Icons.music_note_rounded,
      Icons.photo_camera_rounded,
      Icons.local_offer_rounded,
      Icons.design_services_rounded,
      Icons.construction_rounded,
    ];
    return icons[categoryId % icons.length];
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final FocusNode focusNode;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.focusNode,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.12) : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(
            Icons.search_rounded,
            color: colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                height: 1.2,
              ),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchSuppliersText,
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.2,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (query.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.clear_rounded,
                color: colorScheme.onSurfaceVariant,
                size: 18,
              ),
              onPressed: onClear,
              splashRadius: 16,
            ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final List<_SupplierCategory> categories;
  final int? selectedCategoryId;
  final ValueChanged<int?> onCategoryChanged;
  final ScrollController scrollController;

  const _CategoryChips({
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategoryChanged,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategoryId == category.id;

          return _CategoryChip(
            category: category,
            isSelected: isSelected,
            onTap: () {
              onCategoryChanged(isSelected ? null : category.id);
              if (isSelected && index > 0) {
                scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            },
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final _SupplierCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    final backgroundColor = isSelected
        ? colorScheme.primary
        : colorScheme.onSurface.withOpacity(isDark ? 0.08 : 0.05);

    final textColor =
        isSelected ? colorScheme.onPrimary : colorScheme.onSurface;

    final iconColor =
        isSelected ? colorScheme.onPrimary : colorScheme.onSurface;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.outline.withOpacity(0.3),
          width: isSelected ? 0 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                category.id == 0
                    ? Icon(
                        category.icon,
                        size: 24,
                        color: iconColor,
                      )
                    : SvgPicture.asset(
                        'assets/icons/${category.id + 1}.svg',
                        package: "gluttex_localiser",
                        width: 24,
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                const SizedBox(width: 6),
                Text(
                  category.name,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.1,
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

class _SupplierCategory {
  final int id;
  final String name;
  final Color color;
  final IconData icon;

  _SupplierCategory({
    required this.id,
    required this.name,
    required this.color,
    this.icon = Icons.category_rounded,
  });
}
