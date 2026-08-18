import 'package:flutter/material.dart';
import 'package:gluttex_localizations/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/app/ManagementRule.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_core/business/privileges/role_bit_mapper.dart';
import 'package:event/cart_change_notifier.dart';
import 'package:event/personnel_notifier.dart';
import 'package:event/product_change_notifier.dart';
import 'package:event/service_change_notifier.dart';
import 'package:provider_store/components/selling_point/selling_point_app_bar.dart';
import 'package:provider_store/components/selling_point/selling_point_cart.dart';
import 'package:provider_store/components/selling_point/selling_point_tabs.dart';
import 'package:provider_store/components/selling_point/selling_point_supplier.dart';
import 'package:provider/provider.dart';

import '../components/selling_point/cart_summary/cart_summary_screen.dart';

class SellingPointScreen extends StatefulWidget {
  final int userId;
  final int? selectedSupplierId;
  final List<int> accessibleSuppliers;
  final PersonnelNotifier personnelNotifier;
  final ServiceNotifier serviceNotifier;
  final CartChangeNotifier cartNotifier;
  final ProductNotifier productNotifier;
  final Function() onScanBarcode;
  final Function(String) onSearchChanged;
  final Function(int) onSupplierChanged;

  const SellingPointScreen({
    super.key,
    required this.userId,
    this.selectedSupplierId,
    required this.accessibleSuppliers,
    required this.personnelNotifier,
    required this.productNotifier,
    required this.serviceNotifier,
    required this.cartNotifier,
    required this.onScanBarcode,
    required this.onSearchChanged,
    required this.onSupplierChanged,
  });

  @override
  State<SellingPointScreen> createState() => _SellingPointScreenState();
}

class _SellingPointScreenState extends State<SellingPointScreen> {
  late final TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);

    // Load initial data if supplier is selected
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.selectedSupplierId != null && widget.selectedSupplierId! > 0) {
        _loadSupplierData(widget.selectedSupplierId!);
      }
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    setState(() {
      _searchQuery = query;
    });
    widget.onSearchChanged(query);
  }

  void _loadSupplierData(int supplierId) {
    widget.productNotifier.fetchProducts(providerId: supplierId);
    widget.serviceNotifier.fetchServices(providerId: supplierId);
  }

  List<Product> get _filteredProducts {
    if (_searchQuery.isEmpty) return widget.productNotifier.products;

    final query = _searchQuery.toLowerCase();
    return widget.productNotifier.products.where((product) {
      final name = product.product_name?.toLowerCase() ?? '';
      final desc = product.product_description?.toLowerCase() ?? '';
      return name.contains(query) || desc.contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasSupplier =
        widget.selectedSupplierId != null && widget.selectedSupplierId! > 0;

    if (!hasSupplier) {
      return _buildNoSupplierSelected(context);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            SellingPointAppBar(
              onScanBarcode: widget.onScanBarcode,
            ),
            // Show current supplier info (optional)
            // _buildSupplierInfo(context),
            // Search Bar
            _buildSearchBar(context),
            // Products/Services Tabs
            Expanded(
              child: SellingItemTabs(
                products: _filteredProducts,
                services: widget.serviceNotifier.services,
                isLoading: widget.productNotifier.isLoading ||
                    widget.serviceNotifier.isLoading,
                cartNotifier: widget.cartNotifier,
                onAddToCart: (product) {
                  widget.cartNotifier.addProduct(product);
                },
                onAddServiceToCart: (ProvidedService) {},
                onRemoveFromCart: (Product) {},
                onRemoveServiceFromCart: (ProvidedService) {},
                onConfigureProduct: (Product) {},
                onConfigureService: (ProvidedService) {},
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildCartFAB(context),
    );
  }

  // Widget _buildSupplierInfo(BuildContext context) {
  //   final colorScheme = Theme.of(context).colorScheme;

  //   // Get supplier name from product notifier or personnel notifier
  //   String supplierName = '';
  //   try {
  //     final supplier = widget.productNotifier.suppliers.firstWhere(
  //       (s) => s.idProductProvider == widget.selectedSupplierId,
  //     );
  //     supplierName = supplier.displayName;
  //   } catch (_) {
  //     supplierName = 'Supplier #${widget.selectedSupplierId}';
  //   }

  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //     color: colorScheme.primaryContainer.withOpacity(0.3),
  //     child: Row(
  //       children: [
  //         Icon(
  //           Icons.storefront_rounded,
  //           size: 16,
  //           color: colorScheme.primary,
  //         ),
  //         const SizedBox(width: 8),
  //         Expanded(
  //           child: Text(
  //             'Selling from: $supplierName',
  //             style: TextStyle(
  //               fontSize: 12,
  //               color: colorScheme.onSurfaceVariant,
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildSearchBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search products or services...',
          prefixIcon: Icon(
            Icons.search,
            color: colorScheme.onSurfaceVariant,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: colorScheme.onSurfaceVariant,
                    size: 18,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                    widget.onSearchChanged('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: colorScheme.surfaceVariant,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildNoSupplierSelected(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
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
      ),
    );
  }

  Widget _buildCartFAB(BuildContext context) {
    final cartItemCount = widget.cartNotifier.cartItems.length;
    if (cartItemCount == 0) return Container();

    final colorScheme = Theme.of(context).colorScheme;

    return FloatingActionButton.extended(
      onPressed: () {
        // Show cart
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, sc) => CartSummarySheet(
              cart: widget.cartNotifier,
              scrollController: sc,
            ),
          ),
        );
      },
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      icon: Stack(
        children: [
          const Icon(Icons.shopping_cart_rounded),
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: colorScheme.error,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                cartItemCount > 9 ? '9+' : cartItemCount.toString(),
                style: const TextStyle(
                  fontSize: 8,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
      label: Text(
        'Cart (${cartItemCount})',
        style: TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
