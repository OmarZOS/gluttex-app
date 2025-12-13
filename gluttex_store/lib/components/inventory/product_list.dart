import 'package:flutter/material.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/privileges/Privileges.dart';
import 'package:medicom_catalog/screens/components/ProductCard.dart';

class ProductList extends StatelessWidget {
  final int selectedSupplierId;
  final String searchQuery;
  final List<Product> products;
  final ValueChanged<int> onProductTap;
  final PrivilegeLevel privilegeLevel;
  final bool isLoading;
  final Function() onAddFirstProduct;
  final Function() onManageSuppliers;

  const ProductList({
    super.key,
    required this.selectedSupplierId,
    required this.searchQuery,
    required this.products,
    required this.onProductTap,
    required this.privilegeLevel,
    this.isLoading = false,
    required this.onAddFirstProduct,
    required this.onManageSuppliers,
  });

  bool get _canManage => privilegeLevel == PrivilegeLevel.manage;
  bool get _canView => privilegeLevel == PrivilegeLevel.view;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    if (isLoading) {
      return _buildLoadingState(context);
    }

    final filteredProducts = _filterProducts();

    if (filteredProducts.isEmpty) {
      return _buildEmptyState(
        context,
        localizations,
        searchQuery.isNotEmpty,
      );
    }

    return _buildProductGrid(context, filteredProducts);
  }

  List<Product> _filterProducts() {
    if (searchQuery.isEmpty) return products;

    final query = searchQuery.toLowerCase();
    return products.where((product) {
      return product.product_name?.toLowerCase().contains(query) == true ||
          product.product_brand?.toLowerCase().contains(query) == true ||
          product.product_barcode?.toLowerCase().contains(query) == true;
    }).toList();
  }

  Widget _buildProductGrid(
      BuildContext context, List<Product> filteredProducts) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        return ProductCard(
          product: filteredProducts[index],
          // canEdit: _canManage,
          // onTap: () => _handleProductTap(filteredProducts[index]),
        );
      },
    );
  }

  void _handleProductTap(Product product) {
    if (!_canView) return;
    onProductTap(product.id_product ?? 0);
  }

  Widget _buildLoadingState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Text(
            localizations.loading,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations localizations,
    bool isSearching,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearching
                  ? Icons.search_off_rounded
                  : Icons.inventory_2_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              isSearching
                  ? localizations.noProductsFoundText
                  : localizations.noProductsText,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? localizations.tryDifferentSearchText
                  : localizations.addFirstProductText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (_canManage && !isSearching) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onAddFirstProduct,
                icon: const Icon(Icons.add_rounded),
                label:
                    Text(localizations.addFirstProduct ?? 'Add First Product'),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
