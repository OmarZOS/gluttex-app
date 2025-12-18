import 'package:flutter/material.dart';
import 'package:gluttex_ui/components/supplier/SupplierUIProvider.dart';

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
  final _uiProvider = SupplierUIProvider();

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
            // 搜索栏 - 使用UI提供者
            _uiProvider.buildSearchBar(
              context: context,
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

            // 分类筛选器 - 直接使用实际分类ID
            _uiProvider.buildCategoryFilterRow(
              context: context,
              availableCategoryIds:
                  _uiProvider.getExistingCategoryIds(), // 使用实际存在的分类
              selectedCategoryId: widget.selectedCategoryId,
              onCategoryChanged: widget.onCategoryChanged,
              scrollController: _scrollController,
            ),
          ],
        ),
      ),
    );
  }
}
