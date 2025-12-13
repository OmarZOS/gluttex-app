import 'package:flutter/material.dart';
import 'package:gluttex_core/app/ManagementRule.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/privileges/Privileges.dart';
import 'package:gluttex_core/business/privileges/role_bit_mapper.dart';
import 'package:gluttex_event/cart_change_notifier.dart';
import 'package:gluttex_event/personnel_notifier.dart';
import 'package:gluttex_event/product_change_notifier.dart';
import 'package:gluttex_event/service_change_notifier.dart';
import 'package:gluttex_event/user_change_notifier.dart';
import 'package:gluttex_personnel/supplier_entities_screen.dart';
import 'package:gluttex_store/screens/business_operations_screen.dart';
import 'package:gluttex_store/screens/finance_screen.dart';
import 'package:gluttex_store/screens/inventory_screen.dart';
import 'package:gluttex_store/screens/selling_screen.dart';
import 'package:gluttex_store/screens/services_screen.dart';
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

    final userId = _userNotifier.appUser?.id_app_user ?? 0;
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
                  onAddProduct: () => {},
                ));

      case DashboardScreenType.operations:
        return Consumer<PersonnelNotifier>(
            builder: (context, personnelNotifier, child) =>
                BusinessOperationsScreen());
      case DashboardScreenType.pos:
        return Consumer4<ServiceNotifier, PersonnelNotifier, ProductNotifier,
            CartChangeNotifier>(
          builder: (context, serviceNotifier, personnelNotifier,
                  productNotifier, cartNotifier, child) =>
              SellingPointScreen(
            serviceNotifier: serviceNotifier,
            userId: userId,
            accessibleSuppliers: accessibleSuppliers,
            personnelNotifier: personnelNotifier,
            productNotifier: productNotifier,
            cartNotifier: cartNotifier,
            onScanBarcode: () {},
            onSearchChanged: () {},
          ),
        );
      case DashboardScreenType.finance:
        return Consumer2<ProductNotifier, CartChangeNotifier>(
          builder: (context, productNotifier, cartNotifier, child) =>
              FinanceScreen(),
        );
      case DashboardScreenType.suppliers:
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
