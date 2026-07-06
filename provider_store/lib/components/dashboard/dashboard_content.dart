import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gluttex_localizations/gen_l10n/app_localizations.dart';
import 'package:app_constants/app_constants.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/business/privileges/Privileges.dart';
import 'package:event/cart_change_notifier.dart';
import 'package:event/personnel_notifier.dart';
import 'package:provider_store/components/selling_point/cart_summary/cart_summary_screen.dart';
import 'dashboard_item.dart';
import 'dashboard_body.dart';
import 'dashboard_bottom_nav.dart';
import 'dashboard_fab.dart';
import 'no_access_screen.dart';
import 'package:provider/provider.dart';

class DashboardContent extends StatefulWidget {
  final AppUser currentUser;
  final PersonnelNotifier personnelNotifier;

  const DashboardContent({
    super.key,
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
    final userId = widget.currentUser.idAppUser ?? 0;
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
    final personnelPrivilege = _getHighestPrivilege(
      userId,
      accessibleSuppliers,
      ['personnel_manage', 'personnel_view'],
    );
    if (personnelPrivilege != null) {
      items.add(DashboardItem(
        type: DashboardScreenType.suppliersPersonnel,
        icon: Icons.business_rounded,
        label: localizations?.manageSuppliers ?? 'Businesses',
        index: items.length,
      ));
    }

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

    // POS
    final posPrivilege = _getHighestPrivilege(
      userId,
      accessibleSuppliers,
      ['pos_manage', 'pos_view'],
    );

    // POS
    if (posPrivilege != null) {
      items.add(DashboardItem(
        type: DashboardScreenType.pos,
        icon: Icons.point_of_sale,
        label: localizations?.pointOfSale ?? 'Seller',
        index: items.length,
        privilegeLevel: posPrivilege,
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
        type: DashboardScreenType.orders,
        icon: Icons.delivery_dining,
        label: localizations?.ordersText ?? 'Orders',
        index: items.length,
        privilegeLevel: ordersPrivilege,
      ));
    }

    final operationsPrivilege = _getHighestPrivilege(
      userId,
      accessibleSuppliers,
      ['operations_manage', 'operations_view'],
    );

    if (operationsPrivilege != null) {
      items.add(DashboardItem(
        type: DashboardScreenType.operations,
        icon: Icons.sell,
        label: localizations?.businessOperations ?? 'operations',
        index: items.length,
        privilegeLevel: operationsPrivilege,
      ));
    }

    // Finance
    final financePrivilege = _getHighestPrivilege(
      userId,
      accessibleSuppliers,
      ['finance_manage', 'finance_view'],
    );

    if (financePrivilege != null) {
      items.add(DashboardItem(
        type: DashboardScreenType.finance,
        icon: CupertinoIcons.money_euro,
        label: localizations?.financeAndPricing ?? 'Finance',
        index: items.length,
        privilegeLevel: financePrivilege,
      ));
    }

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
    if (type == DashboardScreenType.pos) {
      final cartNotifier = context.read<CartChangeNotifier>();
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          snap: true,
          snapSizes: const [0.5, 0.85, 0.95],
          builder: (context, scrollController) => CartSummarySheet(
            cart: cartNotifier,
            scrollController: scrollController,
          ),
        ),
      );

      return;
    }

    if (type == DashboardScreenType.inventory) {
      Navigator.pushNamed(context, AppRoutes.productCreate);

      return;
    }

    if (type == DashboardScreenType.services) {
      Navigator.pushNamed(
        context,
        AppRoutes.serviceForm,
      );

      return;
    }

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
}
