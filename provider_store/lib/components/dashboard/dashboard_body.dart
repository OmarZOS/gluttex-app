import 'package:app_constants/app_routes.dart';
import 'package:event/delivery_change_notifier.dart';
import 'package:event/extensions/personnel_access_manager.dart';
import 'package:event/supplier_change_notifier.dart';
import 'package:flutter/material.dart';
import 'package:gluttex_core/app/ManagementRule.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_core/business/privileges/Privileges.dart';
import 'package:event/cart_change_notifier.dart';
import 'package:event/finance_change_notifier.dart';
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
import 'package:provider/provider.dart';
import 'dashboard_item.dart';

class DashboardBody extends StatelessWidget {
  final int selectedIndex;
  final List<DashboardItem> items;
  final int selectedSupplierId;
  final ValueChanged<int>? onSupplierChanged;

  const DashboardBody({
    super.key,
    required this.selectedIndex,
    required this.items,
    this.selectedSupplierId = 0,
    this.onSupplierChanged,
  });

  @override
  Widget build(BuildContext context) {
    final index = selectedIndex.clamp(0, items.length - 1);
    return IndexedStack(
      index: index,
      children: items.map((item) => _buildScreen(context, item)).toList(),
    );
  }

  // ============================================================
  // CORE DATA PROVIDERS
  // ============================================================
// ============================================================
// FIXED: Make it async and use proper data loading
// ============================================================

  /// Get all core data needed for the dashboard (ASYNC)
  Future<
      (
        int userId,
        List<int> supplierIds,
        List<ManagementRule> userRules,
        List<Supplier> suppliers,
        List<AccessibleSupplier> suppliersWithAccess,
        PersonnelAccessManager accessManager
      )> _getDashboardData(BuildContext context) async {
    final personnelNotifier = context.read<PersonnelNotifier>();
    final supplierNotifier = context.read<SupplierChangeNotifier>();
    final userNotifier = context.read<AppUserNotifier>();

    final userId = userNotifier.appUser?.idAppUser ?? 0;

    // Create access manager once
    final accessManager = PersonnelAccessManager(
      personnelNotifier: personnelNotifier,
      supplierNotifier: supplierNotifier,
    );

    // Get user rules
    final userRules = personnelNotifier.getRulesForUser(userId);

    // The access manager owns supplier loading and access filtering.
    final suppliersWithAccess =
        await accessManager.getAccessibleSuppliersWithAccessType(userId);
    final suppliers = suppliersWithAccess.map((s) => s.supplier).toList();
    final supplierIds = selectedSupplierId > 0
        ? [selectedSupplierId]
        : suppliersWithAccess.map((s) => s.id).toList();

    debugPrint('📊 [DASHBOARD] Loaded ${suppliers.length} suppliers');

    return (
      userId,
      supplierIds,
      userRules,
      suppliers,
      suppliersWithAccess,
      accessManager
    );
  }

// ============================================================
// FIXED: Use async/await in build
// ============================================================

  Widget _buildScreen(BuildContext context, DashboardItem item) {
    // ✅ Use FutureBuilder to handle async data
    return FutureBuilder(
      future: _getDashboardData(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading data: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _buildScreen(context, item),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final data = snapshot.data!;

        switch (item.type) {
          case DashboardScreenType.inventory:
            return _buildInventoryScreen(context, item, data);

          case DashboardScreenType.orders:
            return _buildOrdersScreen(context, item, data);

          case DashboardScreenType.operations:
            return _buildOperationsScreen(context, data);

          case DashboardScreenType.pos:
            return _buildPosScreen(context, data);

          case DashboardScreenType.finance:
            return _buildFinanceScreen(context, data);

          case DashboardScreenType.suppliersPersonnel:
            return _buildSuppliersPersonnelScreen(context, data);

          case DashboardScreenType.services:
            return _buildServicesScreen(context, item, data);
        }
      },
    );
  }

  // ============================================================
  // SCREEN BUILDERS
  // ============================================================

  Widget _buildInventoryScreen(
    BuildContext context,
    DashboardItem item,
    (
      int userId,
      List<int> supplierIds,
      List<ManagementRule> userRules,
      List<Supplier> suppliers,
      List<AccessibleSupplier> suppliersWithAccess,
      PersonnelAccessManager accessManager
    ) data,
  ) {
    final (userId, supplierIds, userRules, suppliers, _, accessManager) = data;
    final privilegeLevel = item.privilegeLevel ?? PrivilegeLevel.view;

    return Consumer<ProductNotifier>(
      builder: (context, productNotifier, child) => InventoryScreen(
        privilegeLevel: privilegeLevel,
        userId: userId,
        accessibleSuppliers: supplierIds,
        userRules: userRules,
        // suppliers: suppliers,
        products: List<Product>.from(productNotifier.products),
        isLoading: productNotifier.isLoading,
        searchQuery: productNotifier.currentSearchQuery,
        currentProviderId: selectedSupplierId > 0
            ? selectedSupplierId
            : productNotifier.currentProviderId,
        onSupplierChanged: (supplierId) {
          productNotifier.fetchProducts(providerId: supplierId);
          onSupplierChanged?.call(supplierId);
        },
        onSearchChanged: productNotifier.searchProducts,
        onProductTap: (productId) {
          Navigator.pushNamed(
            context,
            AppRoutes.productDetails,
            arguments: {'productId': productId},
          );
        },
        onRefresh: () => productNotifier.fetchProducts(
          providerId: selectedSupplierId,
          reset: true,
        ),
        onAddProduct: () =>
            Navigator.pushNamed(context, AppRoutes.productCreate),
      ),
    );
  }

  Widget _buildOrdersScreen(
    BuildContext context,
    DashboardItem item,
    (
      int userId,
      List<int> supplierIds,
      List<ManagementRule> userRules,
      List<Supplier> suppliers,
      List<AccessibleSupplier> suppliersWithAccess,
      PersonnelAccessManager accessManager
    ) data,
  ) {
    return Consumer<DeliveryChangeNotifier>(
      builder: (context, deliveryNotifier, child) => DeliveryTabbedView(
        notifier: deliveryNotifier,
        selectedSupplierId: selectedSupplierId,
        isLoading: deliveryNotifier.isLoading,
        onRefresh: deliveryNotifier.refreshDeliveries,
        onSearch: deliveryNotifier.searchDeliveries,
      ),
    );
  }

  Widget _buildOperationsScreen(
    BuildContext context,
    (
      int userId,
      List<int> supplierIds,
      List<ManagementRule> userRules,
      List<Supplier> suppliers,
      List<AccessibleSupplier> suppliersWithAccess,
      PersonnelAccessManager accessManager
    ) data,
  ) {
    final (_, _, _, _, _, _) = data;

    return Consumer<PersonnelNotifier>(
      builder: (context, personnelNotifier, child) => BusinessOperationsScreen(
        key: ValueKey('operations_$selectedSupplierId'),
        // selectedSupplierId: selectedSupplierId,
        // userId: userId,
        // accessibleSuppliers: supplierIds,
        // personnelNotifier: personnelNotifier,
        // accessManager: accessManager,
      ),
    );
  }

  Widget _buildPosScreen(
    BuildContext context,
    (
      int userId,
      List<int> supplierIds,
      List<ManagementRule> userRules,
      List<Supplier> suppliers,
      List<AccessibleSupplier> suppliersWithAccess,
      PersonnelAccessManager accessManager
    ) data,
  ) {
    final (userId, supplierIds, _, _, _, _) = data;

    return Consumer4<ServiceNotifier, PersonnelNotifier, CartChangeNotifier,
        ProductNotifier>(
      builder: (context, serviceNotifier, personnelNotifier, cartNotifier,
          productNotifier, child) {
        return SellingPointScreen(
          userId: userId,
          selectedSupplierId: selectedSupplierId,
          accessibleSuppliers: supplierIds,
          personnelNotifier: personnelNotifier,
          productNotifier: productNotifier,
          serviceNotifier: serviceNotifier,
          cartNotifier: cartNotifier,
          // accessManager: accessManager,
          onScanBarcode: () => _handleBarcodeScan(context),
          onSearchChanged: (query) => _handleSearch(context, query),
          onSupplierChanged: (supplierId) {
            productNotifier.fetchProducts(providerId: supplierId, reset: true);
            serviceNotifier.fetchServices(providerId: supplierId, reset: true);
            onSupplierChanged?.call(supplierId);
          },
        );
      },
    );
  }

  Widget _buildFinanceScreen(
    BuildContext context,
    (
      int userId,
      List<int> supplierIds,
      List<ManagementRule> userRules,
      List<Supplier> suppliers,
      List<AccessibleSupplier> suppliersWithAccess,
      PersonnelAccessManager accessManager
    ) data,
  ) {
    final (_, _, _, _, _, _) = data;

    return Consumer3<ProductNotifier, CartChangeNotifier,
        FinanceChangeNotifier>(
      builder:
          (context, productNotifier, cartNotifier, financeNotifier, child) {
        return FinanceScreen(
          key: ValueKey('finance_$selectedSupplierId'),
          // selectedSupplierId: selectedSupplierId,
          financeNotifier: financeNotifier,
          // productNotifier: productNotifier,
          // cartNotifier: cartNotifier,
          // accessManager: accessManager,
        );
      },
    );
  }

  Widget _buildSuppliersPersonnelScreen(
    BuildContext context,
    (
      int userId,
      List<int> supplierIds,
      List<ManagementRule> userRules,
      List<Supplier> suppliers,
      List<AccessibleSupplier> suppliersWithAccess,
      PersonnelAccessManager accessManager
    ) data,
  ) {
    final (
      userId,
      supplierIds,
      userRules,
      suppliers,
      suppliersWithAccess,
      accessManager
    ) = data;

    return SupplierEntitiesScreen(
      key: ValueKey('personnel_${userId}_${supplierIds.length}'),
      userId: userId,
      accessibleSuppliers: supplierIds,
      userRules: userRules,
      suppliers: suppliers,
      suppliersWithAccess: suppliersWithAccess,
      personnelNotifier: context.read<PersonnelNotifier>(),
      supplierNotifier: context.read<SupplierChangeNotifier>(),
      accessManager: accessManager,
    );
  }

  Widget _buildServicesScreen(
    BuildContext context,
    DashboardItem item,
    (
      int userId,
      List<int> supplierIds,
      List<ManagementRule> userRules,
      List<Supplier> suppliers,
      List<AccessibleSupplier> suppliersWithAccess,
      PersonnelAccessManager accessManager
    ) data,
  ) {
    final (userId, supplierIds, userRules, _, _, accessManager) = data;
    final privilegeLevel = item.privilegeLevel ?? PrivilegeLevel.view;

    return Consumer2<PersonnelNotifier, ServiceNotifier>(
      builder: (context, personnelNotifier, serviceNotifier, child) {
        return ServicesScreen(
          key: ValueKey('services_$selectedSupplierId'),
          privilegeLevel: privilegeLevel,
          userId: userId,
          accessibleSuppliers: supplierIds,
          userRules: userRules,
          personnelNotifier: personnelNotifier,
          serviceNotifier: serviceNotifier,
          selectedSupplierId: selectedSupplierId,
          // accessManager: accessManager,
          // onSupplierChanged: (supplierId) {
          //   serviceNotifier.fetchServices(providerId: supplierId, reset: true);
          //   onSupplierChanged?.call(supplierId);
          // },
        );
      },
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  void _handleBarcodeScan(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Barcode scanning coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleSearch(BuildContext context, String query) {
    debugPrint('Searching: $query');
  }
}
