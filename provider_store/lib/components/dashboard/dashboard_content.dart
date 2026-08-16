import 'package:app_constants/app_routes.dart';
import 'package:event/supplier_change_notifier.dart';
import 'package:flutter/material.dart';
import 'package:app_constants/app_constants.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/business/Organisation.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_core/business/privileges/Privileges.dart';
import 'package:event/cart_change_notifier.dart';
import 'package:event/personnel_notifier.dart';
import 'package:gluttex_localizations/gen_l10n/app_localizations.dart';
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
  // ==================== STATE ====================
  int _selectedIndex = 0;
  int _selectedSupplierId = 0;
  int _selectedOrgId = 0;
  bool _isLoading = true;

  final List<Organisation> _organisations = [];
  final List<SupplierData> _availableSuppliers = [];

  // ==================== INIT ====================

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  // ==================== DATA LOADING ====================

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final userId = widget.currentUser.idAppUser ?? 0;
      if (userId == 0) {
        setState(() => _isLoading = false);
        return;
      }

      widget.supplierNotifier.setCurrentUserId(userId);

      // Load suppliers
      await _loadSuppliers(userId);

      // Build available suppliers list
      _buildAvailableSuppliers(userId);

      // Build organisations
      _buildOrganisations();

      // Auto-select defaults
      _autoSelectDefaults();

      debugPrint(
          '📊 Loaded: ${_availableSuppliers.length} suppliers, ${_organisations.length} orgs');
    } catch (e) {
      debugPrint('❌ Error loading data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSuppliers(int userId) async {
    // 1. Fetch owned suppliers (always fresh)
    await widget.supplierNotifier.fetchOwnedSuppliers(
      userId,
      forceRefresh: true,
    );

    // 2. Load missing staff suppliers
    final staffIds = widget.personnelNotifier.getAccessibleSupplierIds(userId);
    final loadedIds = widget.supplierNotifier.suppliers
        .map((s) => s.idProductProvider)
        .toSet();

    final missingIds = staffIds.where((id) => !loadedIds.contains(id)).toList();

    for (final id in missingIds) {
      await widget.supplierNotifier.getSupplierById(id);
    }
  }

  Future<void> _buildAvailableSuppliers(int userId) async {
    _availableSuppliers.clear();
    final addedIds = <int>{};
    final allSuppliers = widget.supplierNotifier.suppliers;
    final staffIds = widget.personnelNotifier.getAccessibleSupplierIds(userId);

    // Add owned suppliers FIRST (they take priority)
    for (final s
        in allSuppliers.where((s) => s.productProviderOwnerId == userId)) {
      if (addedIds.add(s.idProductProvider)) {
        _availableSuppliers
            .add(SupplierData.fromSupplier(s, SupplierAccessType.owner));
      }
    }

    // Add staff-accessible suppliers
    for (final id in staffIds) {
      if (addedIds.contains(id)) continue;

      try {
        final s = allSuppliers.firstWhere((s) => s.idProductProvider == id);
        _availableSuppliers
            .add(SupplierData.fromSupplier(s, SupplierAccessType.managed));
        addedIds.add(id);
      } catch (_) {
        // Fetch individually if not in list
        final s = await widget.supplierNotifier.getSupplierById(id);
        if (s != null && s.idProductProvider != 0) {
          final accessType = s.productProviderOwnerId == userId
              ? SupplierAccessType.owner
              : SupplierAccessType.managed;
          _availableSuppliers.add(SupplierData.fromSupplier(s, accessType));
          addedIds.add(id);
        }
      }
    }

    // Sort: Owners first, then managed suppliers
    _availableSuppliers.sort((a, b) {
      if (a.accessType == b.accessType) {
        return a.name.compareTo(b.name);
      }
      return a.accessType == SupplierAccessType.owner ? -1 : 1;
    });
  }

  void _buildOrganisations() {
    _organisations.clear();
    final orgIds = <int>{};

    for (final data in _availableSuppliers) {
      final supplier = data.supplier;
      final orgId = supplier.idProviderOrganisation;

      if (orgId > 0 && orgIds.add(orgId)) {
        _organisations.add(Organisation(
          id_provider_organisation: orgId,
          provider_organisation_name: supplier.providerOrganisationName,
          provider_organisation_desc: supplier.providerOrganisationDesc,
        ));
      }
    }

    _organisations.sort((a, b) =>
        a.provider_organisation_name.compareTo(b.provider_organisation_name));
  }

  void _autoSelectDefaults() {
    if (_organisations.isEmpty) return;

    _selectedOrgId = _organisations.first.id_provider_organisation;

    final filtered = _getSuppliersForOrg(_selectedOrgId);
    if (filtered.isNotEmpty) {
      // Prefer owned suppliers first
      final owned =
          filtered.where((s) => s.accessType == SupplierAccessType.owner);
      _selectedSupplierId =
          owned.isNotEmpty ? owned.first.id : filtered.first.id;
    }
  }

  List<SupplierData> _getSuppliersForOrg(int orgId) =>
      _availableSuppliers.where((s) => s.orgId == orgId).toList();

  // ==================== DASHBOARD ITEMS ====================

  List<DashboardItem> _buildDashboardItems() {
    if (_selectedSupplierId == 0) return [];

    final data = _availableSuppliers.firstWhere(
      (s) => s.id == _selectedSupplierId,
      orElse: () => SupplierData.empty(),
    );
    if (!data.isValid) return [];

    final userId = widget.currentUser.idAppUser ?? 0;
    final isOwner = data.accessType == SupplierAccessType.owner;
    final supplierIds = [data.id];

    const modules = [
      _Module(
        DashboardScreenType.suppliersPersonnel,
        Icons.business_rounded,
        'Businesses',
        [],
      ),
      _Module(
        DashboardScreenType.inventory,
        Icons.inventory_2_rounded,
        'Inventory',
        ['inventory_manage', 'inventory_view'],
      ),
      _Module(
        DashboardScreenType.services,
        Icons.handyman_sharp,
        'Services',
        ['services_manage', 'services_view'],
      ),
      _Module(
        DashboardScreenType.pos,
        Icons.point_of_sale,
        'Seller',
        ['pos_manage', 'pos_view'],
      ),
      _Module(
        DashboardScreenType.orders,
        Icons.delivery_dining,
        'Orders',
        ['orders_manage', 'orders_view'],
      ),
      _Module(
        DashboardScreenType.operations,
        Icons.sell,
        'Operations',
        ['operations_manage', 'operations_view'],
      ),
      _Module(
        DashboardScreenType.finance,
        Icons.attach_money,
        'Finance',
        ['finance_manage', 'finance_view'],
      ),
    ];

    final items = <DashboardItem>[];

    for (final m in modules) {
      final hasAccess =
          isOwner || _hasAnyPrivilege(userId, supplierIds, m.privilegeIds);
      if (!hasAccess) continue;

      final level = isOwner
          ? PrivilegeLevel.manage
          : _getHighestPrivilege(userId, supplierIds, m.privilegeIds);

      items.add(DashboardItem(
        type: m.type,
        icon: m.icon,
        label: m.label,
        index: items.length,
        privilegeLevel: level ?? PrivilegeLevel.view,
        supplierAccessType: data.accessType,
      ));
    }

    return items;
  }

  bool _hasAnyPrivilege(
      int userId, List<int> supplierIds, List<String> privilegeIds) {
    if (privilegeIds.isEmpty) return false;

    for (final s in supplierIds) {
      for (final p in privilegeIds) {
        if (widget.personnelNotifier.hasPrivilege(userId, s, p)) {
          return true;
        }
      }
    }
    return false;
  }

  PrivilegeLevel? _getHighestPrivilege(
      int userId, List<int> supplierIds, List<String> privilegeIds) {
    for (final s in supplierIds) {
      for (final p in privilegeIds) {
        if (widget.personnelNotifier.hasPrivilege(userId, s, p)) {
          return p.contains('_manage')
              ? PrivilegeLevel.manage
              : PrivilegeLevel.view;
        }
      }
    }
    return null;
  }

  // ==================== UI ====================

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoading();
    if (_availableSuppliers.isEmpty) return _buildNoAccess();

    final items = _buildDashboardItems();
    if (items.isEmpty) return _buildNoAccess();

    return Scaffold(
      extendBody: true,
      body: Column(
        children: [
          _buildSelector(),
          Expanded(
            child: DashboardBody(
              selectedIndex: _selectedIndex,
              items: items,
              selectedSupplierId: _selectedSupplierId,
            ),
          ),
        ],
      ),
      bottomNavigationBar: DashboardBottomNav(
        selectedIndex: _selectedIndex,
        items: items,
        onIndexChanged: (i) => setState(() => _selectedIndex = i),
      ),
      floatingActionButton: _buildFab(items),
    );
  }

  Widget _buildLoading() => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator.adaptive(),
              const SizedBox(height: 16),
              Text(
                'Loading dashboard...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );

  Widget _buildNoAccess() => NoAccessScreen(
        currentUser: widget.currentUser,
        personnelNotifier: widget.personnelNotifier,
        onReturn: () => Navigator.pop(context),
      );

  // ==================== SELECTOR ====================

  Widget _buildSelector() {
    final cs = Theme.of(context).colorScheme;

    if (_organisations.isEmpty) {
      return _buildSelectorBar(
        child: Row(
          children: [
            Icon(Icons.warning_rounded, color: cs.secondary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'No organisations available.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
              ),
            ),
          ],
        ),
      );
    }

    return _buildSelectorBar(
      child: Row(
        children: [
          Icon(Icons.storefront_rounded, size: 20, color: cs.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _buildOrganisationDropdown(),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: _buildSupplierDropdown(),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh_rounded,
                size: 20, color: cs.onSurfaceVariant),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorBar({required Widget child}) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
        ),
      ),
      child: child,
    );
  }

  Widget _buildOrganisationDropdown() {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        value: _selectedOrgId,
        isExpanded: true,
        icon: Icon(Icons.arrow_drop_down_rounded, color: cs.onSurfaceVariant),
        style: tt.bodySmall?.copyWith(
          color: cs.onSurface,
          fontWeight: FontWeight.w500,
        ),
        dropdownColor: cs.surface,
        borderRadius: BorderRadius.circular(8),
        items: _organisations.map((o) {
          final isSelected = o.id_provider_organisation == _selectedOrgId;
          return DropdownMenuItem<int>(
            value: o.id_provider_organisation,
            child: Row(
              children: [
                Icon(
                  Icons.business,
                  size: 14,
                  color: isSelected ? cs.primary : cs.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    o.provider_organisation_name,
                    overflow: TextOverflow.ellipsis,
                    style: tt.bodySmall?.copyWith(
                      color: isSelected ? cs.primary : cs.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_rounded, size: 14, color: cs.primary),
              ],
            ),
          );
        }).toList(),
        onChanged: (id) => setState(() {
          _selectedOrgId = id ?? 0;
          final filtered = _getSuppliersForOrg(_selectedOrgId);
          if (filtered.isNotEmpty) {
            // Prefer owned suppliers
            final owned =
                filtered.where((s) => s.accessType == SupplierAccessType.owner);
            _selectedSupplierId =
                owned.isNotEmpty ? owned.first.id : filtered.first.id;
          } else {
            _selectedSupplierId = 0;
          }
          _selectedIndex = 0;
        }),
      ),
    );
  }

  Widget _buildSupplierDropdown() {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final suppliers = _getSuppliersForOrg(_selectedOrgId);

    if (suppliers.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: cs.onSurfaceVariant),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'No suppliers in this organisation',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          ],
        ),
      );
    }

    // Group suppliers by access type
    final owned = suppliers
        .where((s) => s.accessType == SupplierAccessType.owner)
        .toList();
    final managed = suppliers
        .where((s) => s.accessType == SupplierAccessType.managed)
        .toList();

    return DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        value: _selectedSupplierId,
        isExpanded: true,
        icon: Icon(Icons.arrow_drop_down_rounded, color: cs.onSurfaceVariant),
        style: tt.bodySmall?.copyWith(
          color: cs.onSurface,
          fontWeight: FontWeight.w500,
        ),
        dropdownColor: cs.surface,
        borderRadius: BorderRadius.circular(8),
        items: [
          // Owned suppliers section
          if (owned.isNotEmpty) ...[
            const DropdownMenuItem<int>(
              value: null,
              enabled: false,
              child: Divider(),
            ),
            ...owned.map((data) => _buildSupplierMenuItem(data, cs, tt)),
          ],
          // Managed suppliers section
          if (managed.isNotEmpty) ...[
            if (owned.isNotEmpty)
              const DropdownMenuItem<int>(
                value: null,
                enabled: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Divider(),
                ),
              ),
            ...managed.map((data) => _buildSupplierMenuItem(data, cs, tt)),
          ],
        ],
        onChanged: (id) => setState(() {
          _selectedSupplierId = id ?? 0;
          _selectedIndex = 0;
        }),
      ),
    );
  }

  DropdownMenuItem<int> _buildSupplierMenuItem(
      SupplierData data, ColorScheme cs, TextTheme tt) {
    final isSelected = data.id == _selectedSupplierId;
    final isOwner = data.accessType == SupplierAccessType.owner;

    return DropdownMenuItem<int>(
      value: data.id,
      child: Row(
        children: [
          _buildSupplierAvatar(data, cs, isSelected),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.name,
                  overflow: TextOverflow.ellipsis,
                  style: tt.bodySmall?.copyWith(
                    color: isSelected ? cs.primary : cs.onSurface,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      isOwner
                          ? Icons.star_rounded
                          : Icons.person_outline_rounded,
                      size: 12,
                      color: isOwner ? cs.primary : cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      isOwner ? 'Owner' : 'Managed',
                      style: tt.labelSmall?.copyWith(
                        color: isOwner ? cs.primary : cs.onSurfaceVariant,
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isSelected)
            Icon(Icons.check_rounded, size: 16, color: cs.primary),
        ],
      ),
    );
  }

  Widget _buildSupplierAvatar(
      SupplierData data, ColorScheme cs, bool selected) {
    final isOwner = data.accessType == SupplierAccessType.owner;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: isOwner ? Border.all(color: cs.primary, width: 1.5) : null,
        color: selected
            ? cs.primary
            : (isOwner ? cs.primaryContainer : cs.surfaceContainerHighest),
      ),
      child: Center(
        child: Text(
          data.name.isNotEmpty ? data.name[0].toUpperCase() : 'S',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: selected
                ? cs.onPrimary
                : (isOwner ? cs.primary : cs.onSurfaceVariant),
          ),
        ),
      ),
    );
  }

  // ==================== FAB ====================

  Widget? _buildFab(List<DashboardItem> items) {
    if (_selectedIndex >= items.length) return null;

    final item = items[_selectedIndex];
    if (!item.showFloatingAction ||
        item.privilegeLevel != PrivilegeLevel.manage) {
      return null;
    }

    return DashboardFAB(
      item: item,
      onPressed: () => _handleFab(context, item.type),
    );
  }

  void _handleFab(BuildContext context, DashboardScreenType type) {
    switch (type) {
      case DashboardScreenType.pos:
        _showCartSheet(context);
        break;
      case DashboardScreenType.inventory:
        Navigator.pushNamed(context, AppRoutes.productCreate);
        break;
      case DashboardScreenType.services:
        Navigator.pushNamed(context, AppRoutes.serviceForm);
        break;
      default:
        _showDefaultAction(context, type);
        break;
    }
  }

  void _showCartSheet(BuildContext context) {
    final cart = context.read<CartChangeNotifier>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        snap: true,
        snapSizes: const [0.5, 0.85, 0.95],
        builder: (_, sc) => CartSummarySheet(cart: cart, scrollController: sc),
      ),
    );
  }

  void _showDefaultAction(BuildContext context, DashboardScreenType type) {
    final loc = AppLocalizations.of(context);
    final messages = {
      DashboardScreenType.operations: loc?.createNewOrder ?? 'Create New Order',
      DashboardScreenType.finance:
          loc?.createNewInvoice ?? 'Create New Invoice',
    };

    final msg = messages[type];
    if (msg != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

// ==================== ENUMS ====================

enum SupplierAccessType {
  owner,
  managed,
}

// ==================== DATA CLASS ====================

class SupplierData {
  final int id;
  final String name;
  final Supplier supplier;
  final SupplierAccessType accessType;
  final int orgId;

  SupplierData({
    required this.id,
    required this.name,
    required this.supplier,
    required this.accessType,
    required this.orgId,
  });

  factory SupplierData.fromSupplier(
          Supplier s, SupplierAccessType accessType) =>
      SupplierData(
        id: s.idProductProvider,
        name: s.displayName,
        supplier: s,
        accessType: accessType,
        orgId: s.idProviderOrganisation,
      );

  factory SupplierData.empty() => SupplierData(
        id: 0,
        name: '',
        supplier: Supplier.empty(),
        accessType: SupplierAccessType.managed,
        orgId: 0,
      );

  bool get isValid => id > 0;
}

// ==================== MODULE CLASS ====================

class _Module {
  final DashboardScreenType type;
  final IconData icon;
  final String label;
  final List<String> privilegeIds;

  const _Module(this.type, this.icon, this.label, this.privilegeIds);
}
