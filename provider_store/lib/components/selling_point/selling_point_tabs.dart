import 'package:flutter/material.dart';
import 'package:event/product_change_notifier.dart';
import 'package:event/service_change_notifier.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/finance/ProvidedService.dart';
import 'package:provider_store/components/selling_point/selling_items/item_card_with_controls.dart';
import 'package:provider_store/components/selling_point/selling_items/tab_selector.dart';
import 'package:provider/provider.dart';
import 'package:event/cart_change_notifier.dart';
import 'package:gluttex_localizations/gen_l10n/app_localizations.dart';

class SellingItemTabs extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabSelector(
            selectedTab: 0,
            onTabChanged: (index) {
              // Tab changed - DefaultTabController handles this
            },
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildProductGrid(context),
                _buildServiceGrid(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(BuildContext context) {
    if (isLoading && products.isEmpty) {
      return _buildLoadingState(context);
    }

    if (products.isEmpty) {
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
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final quantity = _getProductQuantity(product.id_product ?? 0);

        return ItemCardWithConfiguration(
          item: product,
          isProduct: true,
          quantity: quantity,
          onAddToCart: () => onAddToCart(product),
          onRemoveFromCart: () => onRemoveFromCart(product),
          onConfigure: () => onConfigureProduct(product),
        );
      },
    );
  }

  Widget _buildServiceGrid(BuildContext context) {
    if (isLoading && services.isEmpty) {
      return _buildLoadingState(context);
    }

    if (services.isEmpty) {
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
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        final quantity = _getServiceQuantity(service.id);

        return ItemCardWithConfiguration(
          item: service,
          isProduct: false,
          quantity: quantity,
          onAddToCart: () => onAddServiceToCart(service),
          onRemoveFromCart: () => onRemoveServiceFromCart(service),
          onConfigure: () => onConfigureService(service),
        );
      },
    );
  }

  int _getProductQuantity(int productId) {
    return cartNotifier.cartItems
        .where((item) => (item.product?.id_product ?? 0) == productId)
        .fold(0, (sum, item) => sum + item.quantity);
  }

  int _getServiceQuantity(int serviceId) {
    return cartNotifier.cartItems
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
