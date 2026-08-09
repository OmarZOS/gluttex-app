import 'package:app_constants/app_routes.dart';
import 'package:event/supplier_change_notifier.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gluttex_localizations/gen_l10n/app_localizations.dart';
import 'package:app_constants/app_constants.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/business/Supplier.dart';
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
  final SupplierChangeNotifier supplierNotifier;

  const DashboardContent({
    super.key,
    required this.currentUser,
    required this.personnelNotifier,
    required this.supplierNotifier,
  });

  @override
  State<DashboardContent> createState() => DashboardContentState();
}

class DashboardContentState extends State<DashboardContent> {
  int _selectedIndex = 0;
  int _selectedSupplierId = 0;
  final List<Map<String, dynamic>> _availableSuppliers = [];
  bool _isLoadingSuppliers = true;
  bool _hasTriedWithoutFilter = false;
  List<int> _pendingSupplierIds = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSupplierData();
    });
  }

  Future<void> _loadSupplierData() async {
    setState(() {
      _isLoadingSuppliers = true;
    });

    try {
      final userId = widget.currentUser.idAppUser ?? 0;
      debugPrint('🔍 Loading suppliers for user: $userId');

      if (userId == 0) {
        debugPrint('⚠️ User ID is 0, cannot load suppliers');
        setState(() {
          _isLoadingSuppliers = false;
        });
        return;
      }

      // Set current user ID for persistence
      widget.supplierNotifier.setCurrentUserId(userId);

      // Get accessible suppliers from PersonnelNotifier
      var accessibleSuppliers =
          widget.personnelNotifier.getAccessibleSupplierIds(userId);
      debugPrint(
          '🔑 Accessible suppliers from PersonnelNotifier: $accessibleSuppliers');

      // Store pending supplier IDs
      _pendingSupplierIds = accessibleSuppliers;

      // Try 1: Fetch suppliers with owner filter
      debugPrint('📡 Fetching suppliers with ownerId: $userId');
      await widget.supplierNotifier.fetchSuppliers(
        ownerId: userId,
        reset: true,
      );

      debugPrint(
          '📦 Suppliers with filter: ${widget.supplierNotifier.suppliers.length}');

      // Try 2: If no suppliers found with filter, try without filter
      if (widget.supplierNotifier.suppliers.isEmpty &&
          !_hasTriedWithoutFilter) {
        _hasTriedWithoutFilter = true;
        debugPrint('⚠️ No suppliers with filter. Fetching all suppliers...');

        await widget.supplierNotifier.fetchSuppliers(
          reset: true,
          // No owner filter
        );

        debugPrint(
            '📦 All suppliers: ${widget.supplierNotifier.suppliers.length}');
      }

      // Build available suppliers list
      await _buildAvailableSuppliers();

      // If still no suppliers, try fetching individually
      if (_availableSuppliers.isEmpty && _pendingSupplierIds.isNotEmpty) {
        debugPrint('🔄 Fetching individual suppliers: $_pendingSupplierIds');
        await _fetchIndividualSuppliers(_pendingSupplierIds);
      }

      // If still no suppliers, show a message
      if (_availableSuppliers.isEmpty) {
        debugPrint('⚠️ No available suppliers found for user $userId');
      }
    } catch (e) {
      debugPrint('❌ Error loading suppliers: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSuppliers = false;
        });
      }
    }
  }

  Future<void> _buildAvailableSuppliers() async {
    final userId = widget.currentUser.idAppUser ?? 0;

    // Get accessible suppliers from PersonnelNotifier
    var accessibleSuppliers =
        widget.personnelNotifier.getAccessibleSupplierIds(userId);

    debugPrint('🔑 Accessible suppliers: $accessibleSuppliers');
    debugPrint(
        '📦 Available suppliers: ${widget.supplierNotifier.suppliers.length}');

    _availableSuppliers.clear();

    // If accessibleSuppliers is empty, use all suppliers
    if (accessibleSuppliers.isEmpty) {
      debugPrint(
          'ℹ️ No accessible suppliers from PersonnelNotifier. Using all suppliers.');
      // Use all suppliers from the notifier
      for (final supplier in widget.supplierNotifier.suppliers) {
        _availableSuppliers.add({
          'id': supplier.idProductProvider,
          'name': supplier.displayName,
          'supplier': supplier,
        });
        debugPrint(
            '✅ Added supplier: ${supplier.displayName} (ID: ${supplier.idProductProvider})');
      }
    } else {
      // Use only accessible suppliers
      for (final supplierId in accessibleSuppliers) {
        try {
          final supplier = widget.supplierNotifier.suppliers.firstWhere(
            (s) => s.idProductProvider == supplierId,
            orElse: () => throw Exception('Supplier not found'),
          );
          _availableSuppliers.add({
            'id': supplierId,
            'name': supplier.displayName,
            'supplier': supplier,
          });
          debugPrint(
              '✅ Added supplier: ${supplier.displayName} (ID: $supplierId)');
        } catch (e) {
          debugPrint('⚠️ Supplier $supplierId not found in cache: $e');
          // Add to pending list for individual fetch
          if (!_pendingSupplierIds.contains(supplierId)) {
            _pendingSupplierIds.add(supplierId);
          }
        }
      }
    }

    // Select first supplier if available
    if (_availableSuppliers.isNotEmpty && _selectedSupplierId == 0) {
      setState(() {
        _selectedSupplierId = _availableSuppliers.first['id'] as int;
      });
      debugPrint('✅ Selected supplier: $_selectedSupplierId');
    } else if (_availableSuppliers.isEmpty) {
      debugPrint('⚠️ No available suppliers after building list');
    }
  }

  Future<void> _fetchIndividualSuppliers(List<int> supplierIds) async {
    if (supplierIds.isEmpty) return;

    debugPrint('🔄 Fetching ${supplierIds.length} individual suppliers...');

    final List<Supplier> fetchedSuppliers = [];

    for (final supplierId in supplierIds) {
      try {
        final supplier =
            await widget.supplierNotifier.getSupplierById(supplierId);
        if (supplier != null && supplier.idProductProvider != 0) {
          fetchedSuppliers.add(supplier);
          debugPrint(
              '✅ Fetched supplier: ${supplier.displayName} (ID: $supplierId)');
        } else {
          debugPrint('⚠️ Supplier $supplierId returned null');
        }
      } catch (e) {
        debugPrint('❌ Failed to fetch supplier $supplierId: $e');
      }
    }

    // Rebuild available suppliers with the fetched ones
    if (fetchedSuppliers.isNotEmpty) {
      // Add fetched suppliers to the available list
      for (final supplier in fetchedSuppliers) {
        final exists = _availableSuppliers
            .any((s) => s['id'] == supplier.idProductProvider);
        if (!exists) {
          _availableSuppliers.add({
            'id': supplier.idProductProvider,
            'name': supplier.displayName,
            'supplier': supplier,
          });
          debugPrint(
              '✅ Added fetched supplier: ${supplier.displayName} (ID: ${supplier.idProductProvider})');
        }
      }

      // Update selected supplier if not set
      if (_selectedSupplierId == 0 && _availableSuppliers.isNotEmpty) {
        setState(() {
          _selectedSupplierId = _availableSuppliers.first['id'] as int;
        });
        debugPrint(
            '✅ Selected supplier from fetched list: $_selectedSupplierId');
      }

      // Notify UI
      if (mounted) {
        setState(() {});
      }
    }

    debugPrint('📦 Total available suppliers: ${_availableSuppliers.length}');
  }

  void _onSupplierChanged(int? supplierId) {
    if (supplierId != null && supplierId != _selectedSupplierId) {
      setState(() {
        _selectedSupplierId = supplierId;
        _selectedIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = widget.currentUser.idAppUser ?? 0;

    // Check if we have suppliers
    final hasSuppliers = _availableSuppliers.isNotEmpty ||
        widget.supplierNotifier.suppliers.isNotEmpty;

    // Show loading state
    if (_isLoadingSuppliers) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Loading dashboard...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    // Show no access if no suppliers
    if (!hasSuppliers) {
      return NoAccessScreen(
        currentUser: widget.currentUser,
        personnelNotifier: widget.personnelNotifier,
        onReturn: () {
          Navigator.of(context).pop();
        },
      );
    }

    // Get accessible suppliers (synchronous, uses cached data)
    final accessibleSuppliers =
        widget.personnelNotifier.getAccessibleSupplierIds(userId);

    // Build dashboard items with selected supplier
    final dashboardItems = _buildDashboardItems(
      context,
      userId,
      accessibleSuppliers.isEmpty
          ? widget.supplierNotifier.suppliers
              .map((s) => s.idProductProvider)
              .toList()
          : accessibleSuppliers,
      _selectedSupplierId,
    );

    if (dashboardItems.isEmpty) {
      return NoAccessScreen(
        currentUser: widget.currentUser,
        personnelNotifier: widget.personnelNotifier,
        onReturn: () {
          Navigator.of(context).pop();
        },
      );
    }

    return Scaffold(
      extendBody: true,
      body: Column(
        children: [
          // Top Navigation Bar - Supplier Selector
          _buildSupplierSelector(context),

          // Main Content
          Expanded(
            child: DashboardBody(
              selectedIndex: _selectedIndex,
              items: dashboardItems,
              selectedSupplierId: _selectedSupplierId,
            ),
          ),
        ],
      ),
      bottomNavigationBar: DashboardBottomNav(
        selectedIndex: _selectedIndex,
        items: dashboardItems,
        onIndexChanged: (index) => setState(() => _selectedIndex = index),
      ),
      floatingActionButton: _buildFloatingActionButton(context, dashboardItems),
    );
  }

  Widget _buildSupplierSelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_isLoadingSuppliers) {
      return Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outline.withOpacity(0.1),
            ),
          ),
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_availableSuppliers.isEmpty) {
      return Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outline.withOpacity(0.1),
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.warning_rounded,
              color: colorScheme.secondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'No suppliers available. Please contact your administrator.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.storefront_rounded,
            size: 20,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSupplierDropdown(context),
          ),
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
            onPressed: _isLoadingSuppliers ? null : _loadSupplierData,
            tooltip: 'Refresh suppliers',
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierDropdown(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DropdownButton<int>(
      value: _selectedSupplierId > 0 ? _selectedSupplierId : null,
      hint: Text(
        'Select Supplier',
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      isExpanded: true,
      underline: const SizedBox.shrink(),
      icon: Icon(
        Icons.arrow_drop_down_rounded,
        color: colorScheme.onSurfaceVariant,
      ),
      style: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      dropdownColor: colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      items: _availableSuppliers.map((supplier) {
        final id = supplier['id'] as int;
        final name = supplier['name'] as String;
        final isSelected = id == _selectedSupplierId;

        return DropdownMenuItem<int>(
          value: id,
          child: Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: isSelected
                    ? colorScheme.primary
                    : colorScheme.primaryContainer,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'S',
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: colorScheme.primary,
                ),
            ],
          ),
        );
      }).toList(),
      onChanged: _onSupplierChanged,
    );
  }

  List<DashboardItem> _buildDashboardItems(
    BuildContext context,
    int userId,
    List<int> supplierIds,
    int selectedSupplierId,
  ) {
    final localizations = AppLocalizations.of(context);
    final items = <DashboardItem>[];

    // Only build items if a supplier is selected
    if (selectedSupplierId == 0 || supplierIds.isEmpty) {
      return items;
    }

    // Check if the selected supplier is owned by the user
    final selectedSupplier = _availableSuppliers.firstWhere(
      (s) => s['id'] == selectedSupplierId,
    );
    final isOwner = selectedSupplier != null &&
        selectedSupplier['supplier']?.productProviderOwnerId == userId;

    // Always show these modules if the user owns the supplier OR has privileges
    final hasPersonnelPrivilege = isOwner ||
        _hasAnyPrivilege(userId, [selectedSupplierId],
            ['personnel_manage', 'personnel_view']);
    final hasInventoryPrivilege = isOwner ||
        _hasAnyPrivilege(userId, [selectedSupplierId],
            ['inventory_manage', 'inventory_view']);
    final hasServicesPrivilege = isOwner ||
        _hasAnyPrivilege(
            userId, [selectedSupplierId], ['services_manage', 'services_view']);
    final hasPosPrivilege = isOwner ||
        _hasAnyPrivilege(
            userId, [selectedSupplierId], ['pos_manage', 'pos_view']);
    final hasOrdersPrivilege = isOwner ||
        _hasAnyPrivilege(
            userId, [selectedSupplierId], ['orders_manage', 'orders_view']);
    final hasOperationsPrivilege = isOwner ||
        _hasAnyPrivilege(userId, [selectedSupplierId],
            ['operations_manage', 'operations_view']);
    final hasFinancePrivilege = isOwner ||
        _hasAnyPrivilege(
            userId, [selectedSupplierId], ['finance_manage', 'finance_view']);

    // Suppliers screen - always show if user has any supplier
    items.add(DashboardItem(
      type: DashboardScreenType.suppliersPersonnel,
      icon: Icons.business_rounded,
      label: localizations?.manageSuppliers ?? 'Businesses',
      index: items.length,
    ));

    // Inventory
    if (hasInventoryPrivilege) {
      final privilege = isOwner
          ? PrivilegeLevel.manage
          : _getHighestPrivilege(userId, [selectedSupplierId],
              ['inventory_manage', 'inventory_view']);
      items.add(DashboardItem(
        type: DashboardScreenType.inventory,
        icon: Icons.inventory_2_rounded,
        label: localizations?.inventory ?? 'Inventory',
        index: items.length,
        privilegeLevel: privilege ?? PrivilegeLevel.view,
      ));
    }

    // Services
    if (hasServicesPrivilege) {
      final privilege = isOwner
          ? PrivilegeLevel.manage
          : _getHighestPrivilege(userId, [selectedSupplierId],
              ['services_manage', 'services_view']);
      items.add(DashboardItem(
        type: DashboardScreenType.services,
        icon: Icons.handyman_sharp,
        label: localizations?.services ?? 'Services',
        index: items.length,
        privilegeLevel: privilege ?? PrivilegeLevel.view,
      ));
    }

    // POS
    if (hasPosPrivilege) {
      final privilege = isOwner
          ? PrivilegeLevel.manage
          : _getHighestPrivilege(
              userId, [selectedSupplierId], ['pos_manage', 'pos_view']);
      items.add(DashboardItem(
        type: DashboardScreenType.pos,
        icon: Icons.point_of_sale,
        label: localizations?.pointOfSale ?? 'Seller',
        index: items.length,
        privilegeLevel: privilege ?? PrivilegeLevel.view,
      ));
    }

    // Orders
    if (hasOrdersPrivilege) {
      final privilege = isOwner
          ? PrivilegeLevel.manage
          : _getHighestPrivilege(
              userId, [selectedSupplierId], ['orders_manage', 'orders_view']);
      items.add(DashboardItem(
        type: DashboardScreenType.orders,
        icon: Icons.delivery_dining,
        label: localizations?.ordersText ?? 'Orders',
        index: items.length,
        privilegeLevel: privilege ?? PrivilegeLevel.view,
      ));
    }

    // Operations
    if (hasOperationsPrivilege) {
      final privilege = isOwner
          ? PrivilegeLevel.manage
          : _getHighestPrivilege(userId, [selectedSupplierId],
              ['operations_manage', 'operations_view']);
      items.add(DashboardItem(
        type: DashboardScreenType.operations,
        icon: Icons.sell,
        label: localizations?.businessOperations ?? 'Operations',
        index: items.length,
        privilegeLevel: privilege ?? PrivilegeLevel.view,
      ));
    }

    // Finance
    if (hasFinancePrivilege) {
      final privilege = isOwner
          ? PrivilegeLevel.manage
          : _getHighestPrivilege(
              userId, [selectedSupplierId], ['finance_manage', 'finance_view']);
      items.add(DashboardItem(
        type: DashboardScreenType.finance,
        icon: CupertinoIcons.money_euro,
        label: localizations?.financeAndPricing ?? 'Finance',
        index: items.length,
        privilegeLevel: privilege ?? PrivilegeLevel.view,
      ));
    }

    debugPrint(
        '📋 Built ${items.length} dashboard items for supplier $selectedSupplierId (isOwner: $isOwner)');
    return items;
  }

  bool _hasAnyPrivilege(
    int userId,
    List<int> supplierIds,
    List<String> privilegeIds,
  ) {
    for (final supplierId in supplierIds) {
      for (final privilegeId in privilegeIds) {
        if (widget.personnelNotifier
            .hasPrivilege(userId, supplierId, privilegeId)) {
          return true;
        }
      }
    }
    return false;
  }

  PrivilegeLevel? _getHighestPrivilege(
    int userId,
    List<int> supplierIds,
    List<String> privilegeIds,
  ) {
    for (final supplierId in supplierIds) {
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
    switch (type) {
      case DashboardScreenType.pos:
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
        break;

      case DashboardScreenType.inventory:
        Navigator.pushNamed(context, AppRoutes.productCreate);
        break;

      case DashboardScreenType.services:
        Navigator.pushNamed(context, AppRoutes.serviceForm);
        break;

      default:
        final localizations = AppLocalizations.of(context);
        final colorScheme = Theme.of(context).colorScheme;
        final messages = {
          DashboardScreenType.operations: localizations?.createNewOrder,
          DashboardScreenType.finance: localizations?.createNewInvoice,
        };

        final message = messages[type];
        if (message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: colorScheme.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        break;
    }
  }
}
