import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gluttex_core/app/ManagementRule.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_event/personnel_notifier.dart';
import 'package:gluttex_event/supplier_change_notifier.dart';
import 'package:gluttex_event/user_change_notifier.dart';
import 'package:gluttex_personnel/components/management/supplier_app_bar.dart';
import 'package:gluttex_personnel/components/management/supplier_search_filter.dart';
import 'package:provider/provider.dart';

class SupplierEntitiesState {
  final String searchQuery;
  final int? selectedCategoryId;
  final bool showAllSuppliers;

  SupplierEntitiesState({
    this.searchQuery = '',
    this.selectedCategoryId,
    this.showAllSuppliers = true,
  });

  SupplierEntitiesState copyWith({
    String? searchQuery,
    int? selectedCategoryId,
    bool? showAllSuppliers,
  }) {
    return SupplierEntitiesState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      showAllSuppliers: showAllSuppliers ?? this.showAllSuppliers,
    );
  }
}

class SupplierEntitiesController {
  final ValueNotifier<SupplierEntitiesState> _state =
      ValueNotifier(SupplierEntitiesState());
  final TextEditingController _searchController = TextEditingController();

  ValueListenable<SupplierEntitiesState> get state => _state;

  void initializeData(BuildContext context) {
    final supplierNotifier = context.read<SupplierChangeNotifier>();
    final personnelNotifier = context.read<PersonnelNotifier>();

    if (supplierNotifier.suppliers.isEmpty) {
      supplierNotifier.fetchSuppliers(reset: true);
    }

    personnelNotifier.loadPersonnel(supplierId: 0, includePending: true);

    _searchController.addListener(() {
      _state.value = _state.value.copyWith(
        searchQuery: _searchController.text.trim(),
      );
    });
  }

  void updateCategory(int? categoryId) {
    _state.value = _state.value.copyWith(selectedCategoryId: categoryId);
  }

  void toggleShowAll(bool value) {
    _state.value = _state.value.copyWith(showAllSuppliers: value);
  }

  Widget buildAppBar(BuildContext context) {
    return SupplierAppBar(
      searchQuery: _state.value.searchQuery,
      selectedCategoryId: _state.value.selectedCategoryId,
      onCategoryChanged: updateCategory,
      showAllSuppliers: _state.value.showAllSuppliers,
      onShowAllChanged: toggleShowAll,
    );
  }

  Widget buildSearchFilter(BuildContext context) {
    return SupplierSearchFilter(
      searchController: _searchController,
      searchQuery: _state.value.searchQuery,
      onSearchChanged: (value) =>
          _state.value = _state.value.copyWith(searchQuery: value),
      selectedCategoryId: _state.value.selectedCategoryId,
      onCategoryChanged: updateCategory,
    );
  }

  List<Supplier> filterOwnedSuppliers(
    List<Supplier> suppliers,
    String searchQuery,
    int? selectedCategoryId,
  ) {
    return suppliers.where((supplier) {
      final matchesSearch = searchQuery.isEmpty ||
          supplier.providerName
              .toLowerCase()
              .contains(searchQuery.toLowerCase());

      final matchesCategory = selectedCategoryId == null ||
          selectedCategoryId == 0 ||
          supplier.productProviderTypeId == selectedCategoryId;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<ManagementRule> filterManagedRules(
    List<ManagementRule> rules,
    String searchQuery,
    int? selectedCategoryId,
  ) {
    return rules.where((rule) {
      final productProvider = rule.productProvider;
      if (productProvider == null) return false;

      final matchesSearch = searchQuery.isEmpty ||
          productProvider.product_provider_details.provider_name
              .toLowerCase()
              .contains(searchQuery.toLowerCase());

      final matchesCategory = selectedCategoryId == null ||
          selectedCategoryId == 0 ||
          productProvider.product_provider_type_id == selectedCategoryId;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  Widget buildFloatingActionButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FloatingActionButton(
      onPressed: _addNewBusiness,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.add_business_rounded, size: 24),
    );
  }

  void _addNewBusiness() {
    print('Add new business');
  }

  void dispose() {
    _searchController.dispose();
  }
}
