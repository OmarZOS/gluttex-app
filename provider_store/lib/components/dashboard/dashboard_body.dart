import 'package:app_constants/app_routes.dart';
import 'package:event/supplier_change_notifier.dart';
import 'package:flutter/material.dart';
import 'package:app_constants/app_constants.dart';
import 'package:gluttex_core/app/ManagementRule.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/privileges/Privileges.dart';
import 'package:gluttex_core/business/privileges/role_bit_mapper.dart';
import 'package:event/cart_change_notifier.dart';
import 'package:event/finance_change_notifier.dart';
import 'package:event/order_change_notifier.dart';
import 'package:event/personnel_notifier.dart';
import 'package:event/product_change_notifier.dart';
import 'package:event/service_change_notifier.dart';
import 'package:event/user_change_notifier.dart';
import 'package:provider_personnel/supplier_entities_screen.dart';
import 'package:provider_store/screens/business_operations_screen.dart';
import 'package:provider_store/screens/finance_screen.dart';
import 'package:provider_store/screens/inventory_screen.dart';
import 'package:provider_store/screens/deliveries_screen.dart';
import 'package:provider_store/screens/selling_screen.dart';
import 'package:provider_store/screens/services_screen.dart';
import 'package:product_catalog/screens/orders_screen.dart';
import 'package:provider/provider.dart';
import 'dashboard_item.dart';

class DashboardBody extends StatelessWidget {
  final int selectedIndex;
  final List<DashboardItem> items;
  final int selectedSupplierId;

  const DashboardBody({
    super.key,
    required this.selectedIndex,
    required this.items,
    this.selectedSupplierId = 0,
  });

  @override
  Widget build(BuildContext context) {
    final index = selectedIndex.clamp(0, items.length - 1);
    final item = items[index];

    return IndexedStack(
      index: index,
      children: items.map((item) => _buildScreen(context, item)).toList(),
    );
  }

  Widget _buildScreen(BuildContext context, DashboardItem item) {
    final personnelNotifier = context.read<PersonnelNotifier>();
    final userNotifier = context.read<AppUserNotifier>();
    final supplierNotifier = context.read<SupplierChangeNotifier>();

    final userId = userNotifier.appUser?.idAppUser ?? 0;

    // Use selectedSupplierId if provided, otherwise get all accessible suppliers
    final supplierIds = selectedSupplierId > 0
        ? [selectedSupplierId]
        : personnelNotifier.getAccessibleSupplierIds(userId);

    final userRules = personnelNotifier.getRulesForUser(userId);
    final suppliers = _getSuppliersFromRules(userRules);

    // Get the selected supplier name if available
    if (selectedSupplierId > 0) {
      try {
        final supplier = supplierNotifier.suppliers.firstWhere(
          (s) => s.idProductProvider == selectedSupplierId,
        );
      } catch (e) {
        // Supplier not found
      }
    }

    switch (item.type) {
      case DashboardScreenType.inventory:
        return Consumer<ProductNotifier>(
          builder: (context, productNotifier, child) => InventoryScreen(
            privilegeLevel: item.privilegeLevel ?? PrivilegeLevel.view,
            userId: userId,
            accessibleSuppliers: supplierIds,
            userRules: userRules,
            suppliers: suppliers,
            products: productNotifier.products,
            isLoading: productNotifier.isLoading,
            searchQuery: productNotifier.currentSearchQuery ?? '',
            currentProviderId: selectedSupplierId > 0
                ? selectedSupplierId
                : productNotifier.currentProviderId ?? 0,
            onSupplierChanged: (supplierId) {
              productNotifier.fetchProducts(providerId: supplierId);
            },
            onSearchChanged: (query) {
              productNotifier.searchProducts(query);
            },
            onProductTap: (productId) {
              // Navigate to product details
              Navigator.pushNamed(
                context,
                AppRoutes.productDetails,
                arguments: {'productId': productId},
              );
            },
            onRefresh: () => productNotifier.fetchProducts(reset: true),
            onAddProduct: () =>
                Navigator.pushNamed(context, AppRoutes.productCreate),
          ),
        );

      case DashboardScreenType.orders:
        return Consumer<OrderChangeNotifier>(
          builder: (context, orderNotifier, child) => DeliveryTabbedView(),
        );

      case DashboardScreenType.operations:
        return Consumer<PersonnelNotifier>(
          builder: (context, personnelNotifier, child) =>
              BusinessOperationsScreen(),
        );

      case DashboardScreenType.pos:
        return Consumer3<ServiceNotifier, PersonnelNotifier,
            CartChangeNotifier>(
          builder: (context, serviceNotifier, personnelNotifier, cartNotifier,
                  child) =>
              SellingPointScreen(
            serviceNotifier: serviceNotifier,
            userId: userId,
            accessibleSuppliers: supplierIds,
            personnelNotifier: personnelNotifier,
            productNotifier: context.read<ProductNotifier>(),
            cartNotifier: cartNotifier,
            onScanBarcode: () {
              // Handle barcode scan
            },
            onSearchChanged: () {
              // Handle search
            },
          ),
        );

      case DashboardScreenType.finance:
        return Consumer3<ProductNotifier, CartChangeNotifier,
            FinanceChangeNotifier>(
          builder: (context, productNotifier, cartNotifier,
                  financeChangeNotifier, child) =>
              FinanceScreen(
            financeNotifier: financeChangeNotifier,
          ),
        );

      case DashboardScreenType.suppliersPersonnel:
        return Consumer2<PersonnelNotifier, SupplierChangeNotifier>(
          builder: (context, personnelNotifier, supplierNotifier, child) {
            final currentUserId =
                context.read<AppUserNotifier>().appUser?.idAppUser ?? 0;
            final accessibleSuppliers = selectedSupplierId > 0
                ? [selectedSupplierId]
                : personnelNotifier.getAccessibleSupplierIds(currentUserId);
            final userRules = personnelNotifier.getRulesForUser(currentUserId);
            final suppliers = _getSuppliersFromRules(userRules);

            return SupplierEntitiesScreen(
              userId: currentUserId,
              accessibleSuppliers: accessibleSuppliers,
              userRules: userRules,
              suppliers: suppliers,
            );
          },
        );

      case DashboardScreenType.services:
        return Consumer2<PersonnelNotifier, ServiceNotifier>(
          builder: (context, personnelNotifier, serviceNotifier, child) {
            final userRules = personnelNotifier.getRulesForUser(userId);
            final suppliers = _getSuppliersFromRules(userRules);

            return ServicesScreen(
              privilegeLevel: item.privilegeLevel ?? PrivilegeLevel.view,
              userId: userId,
              accessibleSuppliers: supplierIds,
              userRules: userRules,
              personnelNotifier: personnelNotifier,
              serviceNotifier: serviceNotifier,
            );
          },
        );
    }
  }

  List<ProductProvider> _getSuppliersFromRules(List<ManagementRule> rules) {
    if (rules.isEmpty) return [];

    final suppliers = <ProductProvider>[];
    final supplierIds = <int>{};

    for (final rule in rules) {
      try {
        final supplier = rule.productProvider;
        if (supplier != null &&
            supplier.idProductProvider != null &&
            !supplierIds.contains(supplier.idProductProvider)) {
          supplierIds.add(supplier.idProductProvider);
          suppliers.add(supplier);
        }
      } catch (e) {
        // Skip invalid rules
        continue;
      }
    }

    return suppliers;
  }
}
