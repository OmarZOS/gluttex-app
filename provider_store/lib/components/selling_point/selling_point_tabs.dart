import 'package:flutter/material.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/finance/ProvidedService.dart';
import 'package:provider_store/components/selling_point/selling_items/item_card_with_controls.dart';
import 'package:provider_store/components/selling_point/selling_items/tab_selector.dart';
import 'package:event/cart_change_notifier.dart';
import 'package:gluttex_localizations/gen_l10n/app_localizations.dart';

class SellingItemTabs extends StatefulWidget {
  final List<Product> products;
  final List<ProvidedService> services;
  final bool isLoading;
  final CartChangeNotifier cartNotifier;
  final Function(Product) onAddToCart;
  final Function(ProvidedService) onAddServiceToCart;
  final Function(Product) onRemoveFromCart;
  final Function(ProvidedService) onRemoveServiceFromCart;
  final Function(Product) onConfigureProduct;
  final Function(ProvidedService) onConfigureService;

  const SellingItemTabs({
    super.key,
    required this.products,
    required this.services,
    required this.isLoading,
    required this.cartNotifier,
    required this.onAddToCart,
    required this.onAddServiceToCart,
    required this.onRemoveFromCart,
    required this.onRemoveServiceFromCart,
    required this.onConfigureProduct,
    required this.onConfigureService,
  });

  @override
  State<SellingItemTabs> createState() => _SellingItemTabsState();
}

class _SellingItemTabsState extends State<SellingItemTabs>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChanged);
  }

  void _handleTabChanged() {
    if (_tabController.indexIsChanging ||
        _selectedTab == _tabController.index) {
      return;
    }
    setState(() => _selectedTab = _tabController.index);
  }

  void _selectTab(int index) {
    if (_selectedTab == index) return;
    setState(() => _selectedTab = index);
    _tabController.animateTo(index);
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_handleTabChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabSelector(
          selectedTab: _selectedTab,
          onTabChanged: _selectTab,
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildProductGrid(context),
              _buildServiceGrid(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductGrid(BuildContext context) {
    if (widget.isLoading && widget.products.isEmpty) {
      return _buildLoadingState(context);
    }

    if (widget.products.isEmpty) {
      return _buildEmptyState(context, isProduct: true);
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: widget.products.length,
      itemBuilder: (context, index) {
        final product = widget.products[index];
        final quantity = _getProductQuantity(product.id_product ?? 0);

        return ItemCardWithConfiguration(
          item: product,
          isProduct: true,
          quantity: quantity,
          onAddToCart: () => widget.onAddToCart(product),
          onRemoveFromCart: () => widget.onRemoveFromCart(product),
          onConfigure: () => widget.onConfigureProduct(product),
        );
      },
    );
  }

  Widget _buildServiceGrid(BuildContext context) {
    if (widget.isLoading && widget.services.isEmpty) {
      return _buildLoadingState(context);
    }

    if (widget.services.isEmpty) {
      return _buildEmptyState(context, isProduct: false);
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: widget.services.length,
      itemBuilder: (context, index) {
        final service = widget.services[index];
        final quantity = _getServiceQuantity(service.id);

        return ItemCardWithConfiguration(
          item: service,
          isProduct: false,
          quantity: quantity,
          onAddToCart: () => widget.onAddServiceToCart(service),
          onRemoveFromCart: () => widget.onRemoveServiceFromCart(service),
          onConfigure: () => widget.onConfigureService(service),
        );
      },
    );
  }

  int _getProductQuantity(int productId) {
    return widget.cartNotifier.cartItems
        .where((item) => (item.product?.id_product ?? 0) == productId)
        .fold(0, (sum, item) => sum + item.quantity);
  }

  int _getServiceQuantity(int serviceId) {
    return widget.cartNotifier.cartItems
        .where((item) => (item.service?.id ?? 0) == serviceId)
        .fold(0, (sum, item) => sum + item.quantity);
  }

  Widget _buildLoadingState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            localizations.loading,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, {required bool isProduct}) {
    final colorScheme = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isProduct ? Icons.inventory_outlined : Icons.handyman_outlined,
            size: 64,
            color: colorScheme.onSurfaceVariant.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            isProduct
                ? localizations.noProductsFound
                : localizations.noServicesFound,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isProduct
                ? localizations.addProductsToGetStarted
                : localizations.addServicesToGetStarted,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
