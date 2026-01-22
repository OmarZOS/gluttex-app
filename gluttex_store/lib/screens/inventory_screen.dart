import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/app/ManagementRule.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_core/business/privileges/Privileges.dart';
import 'package:gluttex_core/business/privileges/role_bit_mapper.dart';
import 'package:gluttex_store/components/inventory/inventory_app_bar.dart';
import 'package:gluttex_store/components/inventory/product_list.dart';
import 'package:gluttex_store/components/inventory/search_bar.dart';
import 'package:gluttex_store/components/selling_point/selling_point_supplier.dart';

class InventoryScreen extends StatefulWidget {
  final PrivilegeLevel privilegeLevel;
  final int userId;
  final List<int> accessibleSuppliers;
  final List<ManagementRule> userRules;
  final List<ProductProvider> suppliers;
  final List<Product> products;
  final bool isLoading;
  final String searchQuery;
  final int? currentProviderId;
  final Function(int) onSupplierChanged;
  final Function(String) onSearchChanged;
  final Function(int) onProductTap;
  final Function() onRefresh;
  final Function() onAddProduct;

  const InventoryScreen({
    super.key,
    required this.privilegeLevel,
    required this.userId,
    required this.accessibleSuppliers,
    required this.userRules,
    required this.suppliers,
    required this.products,
    required this.isLoading,
    required this.searchQuery,
    required this.currentProviderId,
    required this.onSupplierChanged,
    required this.onSearchChanged,
    required this.onProductTap,
    required this.onRefresh,
    required this.onAddProduct,
  });

  bool get _canManage => privilegeLevel == PrivilegeLevel.manage;
  bool get _canView => privilegeLevel == PrivilegeLevel.view;

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late int? _selectedSupplierId;
  late List<Product> _filteredProducts;
  late bool _hasInventoryAccess;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void didUpdateWidget(InventoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shouldRebuild(oldWidget)) {
      _initializeData();
    }
  }

  bool _shouldRebuild(InventoryScreen oldWidget) {
    return oldWidget.userId != widget.userId ||
        oldWidget.userRules != widget.userRules ||
        oldWidget.products != widget.products ||
        oldWidget.searchQuery != widget.searchQuery ||
        oldWidget.currentProviderId != widget.currentProviderId ||
        oldWidget.privilegeLevel != widget.privilegeLevel;
  }

  void _initializeData() {
    _hasInventoryAccess = _checkInventoryAccess();
    _selectedSupplierId = _getSelectedSupplierId();
    _filteredProducts = _filterProducts();
  }

  bool _checkInventoryAccess() {
    return widget.userRules.any((rule) {
      if (!rule.isActiveStatus) return false;
      final ruleCode = rule.management_rule_code ?? 0;
      return RoleBitMapper.hasPrivilege(ruleCode, 'inventory_view') ||
          RoleBitMapper.hasPrivilege(ruleCode, 'inventory_manage');
    });
  }

  int? _getSelectedSupplierId() {
    // First, check if there's a currentProviderId from parent
    if (widget.currentProviderId != null) {
      return widget.currentProviderId;
    }

    // If not, fall back to finding first accessible supplier
    for (final rule in widget.userRules) {
      if (!rule.isActiveStatus) continue;

      final ruleCode = rule.management_rule_code ?? 0;
      final hasRequiredPrivilege = widget._canManage
          ? RoleBitMapper.hasPrivilege(ruleCode, 'inventory_manage')
          : RoleBitMapper.hasPrivilege(ruleCode, 'inventory_view');

      if (hasRequiredPrivilege) {
        return rule.productProvider?.id_product_provider;
      }
    }
    return null;
  }

  List<Product> _filterProducts() {
    if (widget.searchQuery.isEmpty) return widget.products;

    return widget.products
        .where((product) => product.product_name!
            .toLowerCase()
            .contains(widget.searchQuery.toLowerCase()))
        .toList();
  }

  List<ProductProvider> _getAccessibleSuppliers() {
    final accessibleSuppliers = <ProductProvider>[];
    final supplierIds = <int>{};

    for (final rule in widget.userRules) {
      if (!rule.isActiveStatus) continue;

      final ruleCode = rule.management_rule_code ?? 0;
      final hasRequiredPrivilege = widget._canManage
          ? RoleBitMapper.hasPrivilege(ruleCode, 'inventory_manage')
          : RoleBitMapper.hasPrivilege(ruleCode, 'inventory_view');

      if (hasRequiredPrivilege) {
        final supplier = rule.productProvider;
        if (supplier != null &&
            !supplierIds.contains(supplier.id_product_provider)) {
          supplierIds.add(supplier.id_product_provider);
          accessibleSuppliers.add(supplier);
        }
      }
    }

    return accessibleSuppliers;
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasInventoryAccess) {
      return _buildNoAccessState(context);
    }

    if (_selectedSupplierId == null) {
      return _buildNoSupplierSelected(context);
    }

    final accessibleSuppliers = _getAccessibleSuppliers();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            InventoryAppBar(
              onRefresh: widget.onRefresh,
              privilegeLevel: widget.privilegeLevel,
              hasSupplierSelected: _selectedSupplierId != null,
            ),
            SupplierSelector(
              accessibleSuppliers: accessibleSuppliers,
              selectedSupplierId: _selectedSupplierId,
              // allSuppliers: accessibleSuppliers,
              onSupplierChanged: (supplierId) {
                if (supplierId != null) {
                  widget.onSupplierChanged(supplierId);
                }
              },
              // filterPrivilege:
              //     widget._canManage ? 'inventory_manage' : 'inventory_view',
              // userRules: widget.userRules,
            ),
            const SizedBox(height: 8),
            if (_hasInventoryAccess && _selectedSupplierId != null)
              InventorySearchBar(
                searchQuery: widget.searchQuery,
                onSearchChanged: widget.onSearchChanged,
                isEnabled: widget._canView,
              ),
            const SizedBox(height: 8),
            Expanded(
              child: _buildProductList(context),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildAddProductButton(context),
    );
  }

  Widget _buildProductList(BuildContext context) {
    if (widget.isLoading && widget.products.isEmpty) {
      return _buildLoadingState(context);
    }

    if (_filteredProducts.isEmpty) {
      return _buildEmptyState(context);
    }

    return ProductList(
      selectedSupplierId: _selectedSupplierId!,
      searchQuery: widget.searchQuery,
      products: _filteredProducts,
      isLoading: widget.isLoading,
      onProductTap: widget.onProductTap,
      privilegeLevel: widget.privilegeLevel,
      onAddFirstProduct: () => widget.onAddProduct(),
      onManageSuppliers: () {
        // Navigate to supplier management
        // Could be passed from DashboardScreen
      },
    );
  }

  Widget _buildNoAccessState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: colorScheme.onSurfaceVariant.withOpacity(0.3),
              ),
              const SizedBox(height: 24),
              Text(
                localizations.noInventoryPrivilegesText,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                localizations.noInventoryPrivilegesText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoSupplierSelected(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.storefront_outlined,
                size: 64,
                color: colorScheme.onSurfaceVariant.withOpacity(0.3),
              ),
              const SizedBox(height: 24),
              Text(
                localizations.selectSupplierFirstText,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                localizations.selectSupplierToViewText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            localizations.loading,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              widget.searchQuery.isNotEmpty
                  ? localizations.noResultsTitle
                  : localizations.noProductsFound,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.searchQuery.isNotEmpty
                  ? localizations.adjustSearchFiltersText
                  : localizations.addFirstProduct,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildAddProductButton(BuildContext context) {
    if (!widget._canManage || _selectedSupplierId == null) return null;

    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return FloatingActionButton.extended(
      onPressed: () => widget.onAddProduct(),
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      icon: const Icon(Icons.add_rounded),
      label: Text(
        localizations.addProduct,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      heroTag: 'inventory_add_product_fab',
    );
  }
}
