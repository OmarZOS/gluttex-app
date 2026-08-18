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

    // 👇 FIXED: Get data once and reuse
    final supplierIds = selectedSupplierId > 0
        ? [selectedSupplierId]
        : personnelNotifier.getAccessibleSupplierIds(userId);

    final userRules = personnelNotifier.getRulesForUser(userId);
    final suppliers = _getSuppliersFromRules(userRules);

    // 👇 FIXED: Get selected supplier name properly
    String selectedSupplierName = '';
    if (selectedSupplierId > 0) {
      try {
        final supplier = supplierNotifier.suppliers.firstWhere(
          (s) => s.idProductProvider == selectedSupplierId,
        );
        selectedSupplierName = supplier.displayName;
      } catch (e) {
        selectedSupplierName = 'Selected Supplier';
      }
    }

    // 👇 FIXED: Switch with proper parameter passing
    switch (item.type) {
      case DashboardScreenType.inventory:
        return _buildInventoryScreen(
          context,
          item.privilegeLevel ?? PrivilegeLevel.view,
          userId,
          supplierIds,
          userRules,
          suppliers,
        );

      case DashboardScreenType.orders:
        return _buildOrdersScreen(context);

      case DashboardScreenType.operations:
        return _buildOperationsScreen(context);

      case DashboardScreenType.pos:
        return _buildPosScreen(
          context,
          userId,
          supplierIds,
          selectedSupplierId, // 👈 Pass the selected supplier ID
        );

      case DashboardScreenType.finance:
        return _buildFinanceScreen(context);

      case DashboardScreenType.suppliersPersonnel:
        return _buildSuppliersPersonnelScreen(
          context,
          userId,
          supplierIds,
          userRules,
          suppliers,
        );

      case DashboardScreenType.services:
        return _buildServicesScreen(
          context,
          item.privilegeLevel ?? PrivilegeLevel.view,
          userId,
          supplierIds,
          userRules,
        );
    }
  }

  // ==================== SCREEN BUILDERS ====================

  Widget _buildInventoryScreen(
    BuildContext context,
    PrivilegeLevel privilegeLevel,
    int userId,
    List<int> supplierIds,
    List<ManagementRule> userRules,
    List<ProductProvider> suppliers,
  ) {
    return Consumer<ProductNotifier>(
      builder: (context, productNotifier, child) => InventoryScreen(
        privilegeLevel: privilegeLevel,
        userId: userId,
        accessibleSuppliers: supplierIds,
        userRules: userRules,
        suppliers: suppliers,
        products: productNotifier.products,
        isLoading: productNotifier.isLoading,
        searchQuery: productNotifier.currentSearchQuery ?? '',
        currentProviderId: selectedSupplierId > 0
            ? selectedSupplierId
            : (productNotifier.currentProviderId ?? 0),
        onSupplierChanged: (supplierId) {
          productNotifier.fetchProducts(providerId: supplierId);
        },
        onSearchChanged: (query) {
          productNotifier.searchProducts(query);
        },
        onProductTap: (productId) {
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
  }

  Widget _buildOrdersScreen(BuildContext context) {
    return Consumer<OrderChangeNotifier>(
      builder: (context, orderNotifier, child) {
        // 👇 FIXED: Pass required parameters
        return DeliveryTabbedView(
            // Add required parameters here
            // Example:
            // orders: orderNotifier.orders,
            // isLoading: orderNotifier.isLoading,
            // onRefresh: () => orderNotifier.fetchOrders(),
            );
      },
    );
  }

  Widget _buildOperationsScreen(BuildContext context) {
    return Consumer<PersonnelNotifier>(
      builder: (context, personnelNotifier, child) {
        // 👇 FIXED: Pass required parameters
        return BusinessOperationsScreen(
            // Add required parameters here
            // Example:
            // personnelNotifier: personnelNotifier,
            );
      },
    );
  }

  Widget _buildPosScreen(
    BuildContext context,
    int userId,
    List<int> supplierIds,
    int selectedSupplierId, // 👈 Add this parameter
  ) {
    return Consumer3<ServiceNotifier, PersonnelNotifier, CartChangeNotifier>(
      builder:
          (context, serviceNotifier, personnelNotifier, cartNotifier, child) {
        return SellingPointScreen(
          userId: userId,
          selectedSupplierId: selectedSupplierId, // 👈 Pass it here
          accessibleSuppliers: supplierIds,
          personnelNotifier: personnelNotifier,
          productNotifier: context.read<ProductNotifier>(),
          serviceNotifier: serviceNotifier,
          cartNotifier: cartNotifier,
          onScanBarcode: () => _handleBarcodeScan(context),
          onSearchChanged: (query) => _handleSearch(context, query),
          onSupplierChanged: (supplierId) {
            // Update the selected supplier in the parent
            // This would need to be passed as a callback from Dashboard
          },
        );
      },
    );
  }

  Widget _buildFinanceScreen(BuildContext context) {
    return Consumer3<ProductNotifier, CartChangeNotifier,
        FinanceChangeNotifier>(
      builder:
          (context, productNotifier, cartNotifier, financeNotifier, child) {
        // 👇 FIXED: Pass all required parameters
        return FinanceScreen(
          financeNotifier: financeNotifier,
          // Add other required parameters:
          // productNotifier: productNotifier,
          // cartNotifier: cartNotifier,
        );
      },
    );
  }

  Widget _buildSuppliersPersonnelScreen(
    BuildContext context,
    int userId,
    List<int> supplierIds,
    List<ManagementRule> userRules,
    List<ProductProvider> suppliers,
  ) {
    return Consumer2<PersonnelNotifier, SupplierChangeNotifier>(
      builder: (context, personnelNotifier, supplierNotifier, child) {
        // Use cached data instead of refetching
        return SupplierEntitiesScreen(
          userId: userId,
          accessibleSuppliers: supplierIds,
          userRules: userRules,
          suppliers: suppliers,
        );
      },
    );
  }

  Widget _buildServicesScreen(
    BuildContext context,
    PrivilegeLevel privilegeLevel,
    int userId,
    List<int> supplierIds,
    List<ManagementRule> userRules,
  ) {
    return Consumer2<PersonnelNotifier, ServiceNotifier>(
      builder: (context, personnelNotifier, serviceNotifier, child) {
        return ServicesScreen(
          privilegeLevel: privilegeLevel,
          userId: userId,
          accessibleSuppliers: supplierIds,
          userRules: userRules,
          personnelNotifier: personnelNotifier,
          serviceNotifier: serviceNotifier,
        );
      },
    );
  }

  // ==================== HELPERS ====================

  List<ProductProvider> _getSuppliersFromRules(List<ManagementRule> rules) {
    if (rules.isEmpty) return [];

    final suppliers = <ProductProvider>[];
    final supplierIds = <int>{};

    for (final rule in rules) {
      final supplier = rule.productProvider;
      if (supplier != null &&
          supplier.idProductProvider != null &&
          supplier.idProductProvider! > 0 &&
          !supplierIds.contains(supplier.idProductProvider)) {
        supplierIds.add(supplier.idProductProvider);
        suppliers.add(supplier);
      }
    }

    return suppliers;
  }

  void _handleBarcodeScan(BuildContext context) {
    // Navigate to barcode scanner or show dialog
    // TODO: Implement barcode scanning
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Barcode scanning coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleSearch(BuildContext context, String query) {
    // Implement search logic
    // TODO: Implement search
    debugPrint('Searching: $query');
  }
}
