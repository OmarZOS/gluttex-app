import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/app/ManagementRule.dart';
import 'package:gluttex_core/business/Product.dart';
import 'package:gluttex_core/business/privileges/Privileges.dart';
import 'package:gluttex_core/business/privileges/role_bit_mapper.dart';
import 'package:gluttex_event/cart_change_notifier.dart';
import 'package:gluttex_event/personnel_notifier.dart';
import 'package:gluttex_event/product_change_notifier.dart';
import 'package:gluttex_event/service_change_notifier.dart';
import 'package:gluttex_event/user_change_notifier.dart';
import 'package:gluttex_personnel/components/privilege_ui.dart';
import 'package:gluttex_personnel/supplier_entities_screen.dart';
import 'package:gluttex_store/screens/business_operations_screen.dart';
import 'package:gluttex_store/screens/finance_screen.dart';
import 'package:gluttex_store/screens/inventory_screen.dart';
import 'package:gluttex_store/screens/orders_screen.dart';
import 'package:gluttex_store/screens/selling_screen.dart';
import 'package:gluttex_store/screens/services_screen.dart';
import 'package:provider/provider.dart';
import 'dashboard_item.dart';
import 'dashboard_body.dart';
import 'dashboard_bottom_nav.dart';
import 'dashboard_fab.dart';
import 'no_access_screen.dart';
import 'pending_invitations_dialog.dart';

class DashboardContent extends StatefulWidget {
  final AppUser currentUser;
  final PersonnelNotifier personnelNotifier;

  const DashboardContent({
    required this.currentUser,
    required this.personnelNotifier,
  });

  @override
  State<DashboardContent> createState() => DashboardContentState();
}

class DashboardContentState extends State<DashboardContent> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userId = widget.currentUser.id_app_user ?? 0;
    final accessibleSuppliers =
        widget.personnelNotifier.getAccessibleSupplierIds(userId);

    if (accessibleSuppliers.isEmpty) {
      return NoAccessScreen(
        currentUser: widget.currentUser,
        personnelNotifier: widget.personnelNotifier,
      );
    }

    final dashboardItems =
        _buildDashboardItems(context, userId, accessibleSuppliers);

    if (dashboardItems.isEmpty) {
      return NoAccessScreen(
        currentUser: widget.currentUser,
        personnelNotifier: widget.personnelNotifier,
      );
    }

    return Scaffold(
      extendBody: true,
      body: DashboardBody(
        selectedIndex: _selectedIndex,
        items: dashboardItems,
      ),
      bottomNavigationBar: DashboardBottomNav(
        selectedIndex: _selectedIndex,
        items: dashboardItems,
        onIndexChanged: (index) => setState(() => _selectedIndex = index),
      ),
      floatingActionButton: _buildFloatingActionButton(context, dashboardItems),
    );
  }

  List<DashboardItem> _buildDashboardItems(
    BuildContext context,
    int userId,
    List<int> accessibleSuppliers,
  ) {
    final localizations = AppLocalizations.of(context);
    final items = <DashboardItem>[];

    // Suppliers screen
    items.add(DashboardItem(
      type: DashboardScreenType.suppliers,
      icon: Icons.business_rounded,
      label: localizations?.businesses ?? 'Businesses',
      index: 0,
    ));

    // Inventory
    final inventoryPrivilege = _getHighestPrivilege(
      userId,
      accessibleSuppliers,
      ['inventory_manage', 'inventory_view'],
    );
    if (inventoryPrivilege != null) {
      items.add(DashboardItem(
        type: DashboardScreenType.inventory,
        icon: Icons.inventory_2_rounded,
        label: localizations?.inventory ?? 'Inventory',
        index: items.length,
        privilegeLevel: inventoryPrivilege,
      ));
    }

    // Services
    final servicesPrivilege = _getHighestPrivilege(
      userId,
      accessibleSuppliers,
      ['services_manage', 'services_view'],
    );
    if (servicesPrivilege != null) {
      items.add(DashboardItem(
        type: DashboardScreenType.services,
        icon: Icons.handyman_sharp,
        label: localizations?.services ?? 'Services',
        index: items.length,
        privilegeLevel: servicesPrivilege,
      ));
    }

    // Orders
    final ordersPrivilege = _getHighestPrivilege(
      userId,
      accessibleSuppliers,
      ['orders_manage', 'orders_view'],
    );
    if (ordersPrivilege != null) {
      items.add(DashboardItem(
        type: DashboardScreenType.operations,
        icon: Icons.sell,
        label: localizations?.businessOperations ?? 'Orders',
        index: items.length,
        privilegeLevel: ordersPrivilege,
      ));
    }

    // POS
    if (ordersPrivilege != null) {
      items.add(DashboardItem(
        type: DashboardScreenType.pos,
        icon: Icons.point_of_sale,
        label: localizations?.pointOfSale ?? 'Seller',
        index: items.length,
        privilegeLevel: ordersPrivilege,
      ));
    }

    // Finance
    items.add(DashboardItem(
      type: DashboardScreenType.finance,
      icon: CupertinoIcons.money_euro,
      label: localizations?.financeAndPricing ?? 'Finance',
      index: items.length,
    ));

    return items;
  }

  PrivilegeLevel? _getHighestPrivilege(
    int userId,
    List<int> accessibleSuppliers,
    List<String> privilegeIds,
  ) {
    for (final supplierId in accessibleSuppliers) {
      for (final privilegeId in privilegeIds) {
        if (widget.personnelNotifier
            .hasPrivilege(userId, supplierId, privilegeId)) {
          return privilegeId.contains('_manage')
              ? PrivilegeLevel.manage
              : PrivilegeLevel.view;
        }
      }
    }
    return null;
  }

  Widget? _buildFloatingActionButton(
    BuildContext context,
    List<DashboardItem> items,
  ) {
    if (_selectedIndex >= items.length) return null;

    final currentItem = items[_selectedIndex];
    if (!currentItem.showFloatingAction ||
        currentItem.privilegeLevel != PrivilegeLevel.manage) {
      return null;
    }

    return DashboardFAB(
      item: currentItem,
      onPressed: () => _handleFloatingAction(context, currentItem.type),
    );
  }

  void _handleFloatingAction(
    BuildContext context,
    DashboardScreenType type,
  ) {
    final localizations = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final messages = {
      DashboardScreenType.inventory: localizations?.addProduct,
      DashboardScreenType.operations: localizations?.createNewOrder,
      DashboardScreenType.pos: localizations?.openCart,
      DashboardScreenType.finance: localizations?.createNewInvoice,
    };

    final message = messages[type];
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: colorScheme.primary,
        ),
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

  bool _checkInvoicePrivilege(List<ManagementRule> userRules) {
    for (final rule in userRules) {
      if (rule.isActiveStatus) {
        final ruleCode = rule.management_rule_code ?? 0;
        if (RoleBitMapper.hasPrivilege(ruleCode, 'finance_manage') ||
            RoleBitMapper.hasPrivilege(ruleCode, 'orders_manage')) {
          return true;
        }
      }
    }
    return false;
  }
}
