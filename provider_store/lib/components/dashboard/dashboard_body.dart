import 'package:app_constants/app_routes.dart';
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
// import 'package:product_catalog/screens/orders_screen.dart';
import 'package:provider/provider.dart';
import 'dashboard_item.dart';

class DashboardBody extends StatelessWidget {
  final int selectedIndex;
  final List<DashboardItem> items;

  const DashboardBody({
    required this.selectedIndex,
    required this.items,
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
    final _personnelNotifier = context.read<PersonnelNotifier>();
    final _userNotifier = context.read<AppUserNotifier>();

    final userId = _userNotifier.appUser?.idAppUser ?? 0;
    final accessibleSuppliers =
        _personnelNotifier.getAccessibleSupplierIds(userId);
    final userRules = _personnelNotifier.getRulesForUser(userId);
    final suppliers = _getSuppliersFromRules(userRules);

    switch (item.type) {
      case DashboardScreenType.inventory:
        return Consumer<ProductNotifier>(
            builder: (context, productNotifier, child) => InventoryScreen(
                  privilegeLevel: item.privilegeLevel ?? PrivilegeLevel.view,
                  userId: userId,
                  accessibleSuppliers: accessibleSuppliers,
                  userRules: userRules,
                  suppliers: suppliers,
                  products: productNotifier.products,
                  isLoading: productNotifier.isLoading,
                  searchQuery: productNotifier.currentSearchQuery,
                  currentProviderId: productNotifier.currentProviderId,
                  onSupplierChanged: (supplierId) {
                    productNotifier.fetchProducts(providerId: supplierId);
                  },
                  onSearchChanged: productNotifier.searchProducts,
                  onProductTap: (productId) {},
                  onRefresh: () => {},
                  onAddProduct: () =>
                      {Navigator.pushNamed(context, AppRoutes.productCreate)},
                ));
      case DashboardScreenType.orders:
        return Consumer<OrderChangeNotifier>(
            builder: (context, cartNotifier, child) => DeliveryTabbedView(
                // privilegeLevel: item.privilegeLevel ?? PrivilegeLevel.view,
                // userId: userId,
                // accessibleSuppliers: accessibleSuppliers,
                // personnelNotifier: _personnelNotifier,
                ));
      case DashboardScreenType.operations:
        return Consumer<PersonnelNotifier>(
            builder: (context, personnelNotifier, child) =>
                BusinessOperationsScreen());
      case DashboardScreenType.pos:
        return Consumer3<ServiceNotifier, PersonnelNotifier,
            CartChangeNotifier>(
          builder: (context, serviceNotifier, personnelNotifier, cartNotifier,
                  child) =>
              SellingPointScreen(
            serviceNotifier: serviceNotifier,
            userId: userId,
            accessibleSuppliers: accessibleSuppliers,
            personnelNotifier: personnelNotifier,
            productNotifier: context.read<ProductNotifier>(),
            cartNotifier: cartNotifier,
            onScanBarcode: () {},
            onSearchChanged: () {},
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
        return const SupplierEntitiesScreen();
      case DashboardScreenType.services:
        return Consumer2<PersonnelNotifier, ServiceNotifier>(
          builder: (context, personnelNotifier, serviceNotifier, child) {
            final userRules = personnelNotifier.getRulesForUser(userId);
            final suppliers = _getSuppliersFromRules(userRules);

            return ServicesScreen(
                privilegeLevel: item.privilegeLevel ?? PrivilegeLevel.view,
                userId: userId,
                accessibleSuppliers: accessibleSuppliers,
                userRules: userRules,
                personnelNotifier: personnelNotifier,
                serviceNotifier: serviceNotifier);
          },
        );
    }
  }

  List<ProductProvider> _getSuppliersFromRules(List<ManagementRule> rules) {
    final suppliers = <ProductProvider>[];
    final supplierIds = <int>{};

    for (final rule in rules) {
      final supplier = rule.productProvider;
      if (supplier != null &&
          !supplierIds.contains(supplier.id_product_provider)) {
        supplierIds.add(supplier.id_product_provider);
        suppliers.add(supplier);
      }
    }

    return suppliers;
  }
}
