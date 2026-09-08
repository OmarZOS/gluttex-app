import 'package:app_constants/app_routes.dart';
import 'package:event/delivery_change_notifier.dart';
import 'package:event/product_change_notifier.dart';
import 'package:event/service_change_notifier.dart';
import 'package:event/supplier_change_notifier.dart';
import 'package:event/extensions/personnel_access_manager.dart';
import 'package:flutter/material.dart';
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
import 'pending_invitations_dialog.dart';
import 'package:provider/provider.dart';

// ============================================================
// DATA CLASS
// ============================================================

class SupplierData {
  final int id;
  final String name;
  final Supplier supplier;
  final SupplierAccessType accessType;
  final int orgId;

  const SupplierData({
    required this.id,
    required this.name,
    required this.supplier,
    required this.accessType,
    required this.orgId,
  });

  factory SupplierData.fromAccessible(AccessibleSupplier accessible) =>
      SupplierData(
        id: accessible.id,
        name: accessible.name,
        supplier: accessible.supplier,
        accessType: accessible.accessType,
        orgId: accessible.supplier.idProviderOrganisation,
      );

  bool get isValid => id > 0;
}

// ============================================================
// MODULE CLASS
// ============================================================

class _Module {
  final DashboardScreenType type;
  final IconData icon;
  final String label;
  final List<String> privilegeIds;

  const _Module(this.type, this.icon, this.label, this.privilegeIds);
}

// ============================================================
// DASHBOARD CONTENT
// ============================================================

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
  int _selectedOrgId = 0;
  bool _isLoading = true;

  late PersonnelAccessManager _accessManager;
  final List<Organisation> _organisations = [];
  final List<SupplierData> _availableSuppliers = [];

  @override
  void initState() {
    super.initState();
    _accessManager = PersonnelAccessManager(
      personnelNotifier: widget.personnelNotifier,
      supplierNotifier: widget.supplierNotifier,
    );
    widget.supplierNotifier.addListener(_onSupplierChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _onSupplierChanged() {
    final id = widget.supplierNotifier.selectedSupplierId ?? 0;
    if (id != 0 && id != _selectedSupplierId) {
      setState(() => _selectedSupplierId = id);
      _loadDataForSupplier(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoading();
    if (_availableSuppliers.isEmpty) return _buildNoAccess();

    final items = _buildDashboardItems();
    if (items.isEmpty) return _buildNoAccess();

    return _buildDashboard(items);
  }

  Widget _buildDashboard(List<DashboardItem> items) => Scaffold(
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

  // ============================================================
  // DATA LOADING
  // ============================================================

  Future<void> _loadData() async {
    final userId = widget.currentUser.idAppUser ?? 0;
    if (userId == 0) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      widget.supplierNotifier.setCurrentUserId(userId);

      if (widget.supplierNotifier.suppliers.isEmpty) {
        final suppliersWithAccess =
            await _accessManager.getAccessibleSuppliersWithAccessType(
          userId,
          forceRefresh: true,
        );
        _buildSupplierList(suppliersWithAccess);
      } else {
        final suppliersWithAccess =
            _accessManager.getAccessibleSuppliersWithAccessTypeSync(userId);
        _buildSupplierList(suppliersWithAccess);
      }

      debugPrint('📊 Loaded ${_availableSuppliers.length} suppliers');
    } catch (e) {
      debugPrint('❌ Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _buildSupplierList(List<AccessibleSupplier> suppliersWithAccess) {
    _availableSuppliers
      ..clear()
      ..addAll(suppliersWithAccess.map(SupplierData.fromAccessible));

    _selectedSupplierId = 0;
    _selectedOrgId = 0;

    _buildOrganisations();
    _autoSelectDefaults();

    if (_selectedSupplierId > 0) {
      _loadDataForSupplier(_selectedSupplierId);
    }
  }

  Future<void> _loadDataForSupplier(int supplierId) async {
    final productNotifier = context.read<ProductNotifier>();
    final serviceNotifier = context.read<ServiceNotifier>();
    final deliveryNotifier = context.read<DeliveryChangeNotifier>();

    if (supplierId > 0) {
      await productNotifier.fetchProducts(providerId: supplierId, reset: true);
      await serviceNotifier.fetchServices(providerId: supplierId, reset: true);
      deliveryNotifier.setFilters(providerId: supplierId);
      await deliveryNotifier.fetchFirstPage();
    }
  }

  void _buildOrganisations() {
    _organisations.clear();
    final orgIds = <int>{};
    for (final data in _availableSuppliers) {
      final orgId = data.supplier.idProviderOrganisation;
      if (orgId > 0 && orgIds.add(orgId)) {
        _organisations.add(Organisation(
          id_provider_organisation: orgId,
          provider_organisation_name: data.supplier.providerOrganisationName,
          provider_organisation_desc: data.supplier.providerOrganisationDesc,
        ));
      }
    }
    _organisations.sort((a, b) =>
        a.provider_organisation_name.compareTo(b.provider_organisation_name));
  }

  void _autoSelectDefaults() {
    if (_availableSuppliers.isEmpty) return;

    if (_organisations.isEmpty) {
      _selectedSupplierId = _availableSuppliers.first.id;
      widget.supplierNotifier.selectSupplier(_selectedSupplierId);
      return;
    }

    _selectedOrgId = _organisations.first.id_provider_organisation;

    final filtered =
        _availableSuppliers.where((s) => s.orgId == _selectedOrgId).toList();
    if (filtered.isNotEmpty) {
      final owned =
          filtered.where((s) => s.accessType == SupplierAccessType.owner);
      _selectedSupplierId =
          owned.isNotEmpty ? owned.first.id : filtered.first.id;
      widget.supplierNotifier.selectSupplier(_selectedSupplierId);
    }
  }

  // ============================================================
  // DASHBOARD ITEMS
  // ============================================================

  List<DashboardItem> _buildDashboardItems() {
    if (_selectedSupplierId == 0) return [];

    final data = _availableSuppliers.firstWhere(
      (s) => s.id == _selectedSupplierId,
      orElse: () => _availableSuppliers.isNotEmpty
          ? _availableSuppliers.first
          : SupplierData(
              id: 0,
              name: '',
              supplier: Supplier.empty(),
              accessType: SupplierAccessType.managed,
              orgId: 0,
            ),
    );
    if (data.id == 0) return [];

    final userId = widget.currentUser.idAppUser ?? 0;
    final isOwner = data.accessType == SupplierAccessType.owner;

    const modules = [
      _Module(DashboardScreenType.suppliersPersonnel, Icons.people_rounded,
          'Personnel', ['personnel_manage', 'personnel_view']),
      _Module(DashboardScreenType.inventory, Icons.inventory_2_rounded,
          'Inventory', ['inventory_manage', 'inventory_view']),
      _Module(DashboardScreenType.services, Icons.handyman_sharp, 'Services',
          ['services_manage', 'services_view']),
      _Module(DashboardScreenType.pos, Icons.point_of_sale, 'Seller',
          ['pos_manage', 'pos_view']),
      _Module(DashboardScreenType.orders, Icons.delivery_dining, 'Orders',
          ['orders_manage', 'orders_view']),
      _Module(DashboardScreenType.operations, Icons.sell, 'Operations',
          ['operations_manage', 'operations_view']),
      _Module(DashboardScreenType.finance, Icons.attach_money, 'Finance',
          ['finance_manage', 'finance_view']),
    ];

    final items = <DashboardItem>[];
    for (final m in modules) {
      final hasAccess =
          isOwner || _hasPrivilege(userId, [data.id], m.privilegeIds);
      if (!hasAccess) continue;
      items.add(DashboardItem(
        type: m.type,
        icon: m.icon,
        label: m.label,
        index: items.length,
        privilegeLevel: isOwner
            ? PrivilegeLevel.manage
            : _getPrivilegeLevel(userId, [data.id], m.privilegeIds) ??
                PrivilegeLevel.view,
        supplierAccessType: data.accessType,
      ));
    }
    return items;
  }

  bool _hasPrivilege(
      int userId, List<int> supplierIds, List<String> privilegeIds) {
    for (final s in supplierIds) {
      for (final p in privilegeIds) {
        if (widget.personnelNotifier.hasPrivilege(userId, s, p)) return true;
      }
    }
    return false;
  }

  PrivilegeLevel? _getPrivilegeLevel(
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

  // ============================================================
  // UI HELPERS
  // ============================================================

  Widget _buildLoading() {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator.adaptive(),
            const SizedBox(height: 16),
            Text(
              l10n?.loadingDashboard ?? 'Loading dashboard...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoAccess() => NoAccessScreen(
        currentUser: widget.currentUser,
        personnelNotifier: widget.personnelNotifier,
        onReturn: () => Navigator.pop(context),
      );

  @override
  void dispose() {
    widget.supplierNotifier.removeListener(_onSupplierChanged);
    super.dispose();
  }

  // ============================================================
  // SELECTOR
  // ============================================================

  Widget _buildSelector() {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    if (_organisations.isEmpty) {
      return _buildSelectorBar(
        child: Row(
          children: [
            Icon(Icons.warning_rounded, color: cs.secondary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n?.noOrganisationsAvailable ?? 'No organisations available.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: cs.onSurfaceVariant),
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
                Expanded(flex: 1, child: _buildOrganisationDropdown()),
                const SizedBox(width: 8),
                Expanded(flex: 2, child: _buildSupplierDropdown()),
              ],
            ),
          ),
          _buildPendingInvitationsButton(cs),
          IconButton(
            icon: Icon(Icons.refresh_rounded,
                size: 20, color: cs.onSurfaceVariant),
            onPressed: _loadData,
            tooltip: l10n?.refresh ?? 'Refresh',
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorBar({required Widget child}) => Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
              bottom: BorderSide(
                  color:
                      Theme.of(context).colorScheme.outline.withOpacity(0.1))),
        ),
        child: child,
      );

  Widget _buildOrganisationDropdown() {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        value: _selectedOrgId,
        isExpanded: true,
        icon: Icon(Icons.arrow_drop_down_rounded, color: cs.onSurfaceVariant),
        style: tt.bodySmall
            ?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w500),
        dropdownColor: cs.surface,
        borderRadius: BorderRadius.circular(8),
        items: _organisations.map((o) {
          final isSelected = o.id_provider_organisation == _selectedOrgId;
          return DropdownMenuItem<int>(
            value: o.id_provider_organisation,
            child: Row(
              children: [
                Icon(Icons.business,
                    size: 14,
                    color: isSelected ? cs.primary : cs.onSurfaceVariant),
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
        onChanged: (id) {
          if (id == null) return;
          setState(() {
            _selectedOrgId = id;
            final filtered =
                _availableSuppliers.where((s) => s.orgId == id).toList();
            if (filtered.isNotEmpty) {
              final owned = filtered
                  .where((s) => s.accessType == SupplierAccessType.owner);
              _selectedSupplierId =
                  owned.isNotEmpty ? owned.first.id : filtered.first.id;
              widget.supplierNotifier.selectSupplier(_selectedSupplierId);
            }
          });
        },
      ),
    );
  }

  Widget _buildSupplierDropdown() {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final suppliers =
        _availableSuppliers.where((s) => s.orgId == _selectedOrgId).toList();

    if (suppliers.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: cs.onSurfaceVariant),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                l10n?.noSuppliersInOrganisation ??
                    'No suppliers in this organisation',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          ],
        ),
      );
    }

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
        style: tt.bodySmall
            ?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w500),
        dropdownColor: cs.surface,
        borderRadius: BorderRadius.circular(8),
        items: [
          if (owned.isNotEmpty) ...[
            const DropdownMenuItem<int>(
                value: null, enabled: false, child: Divider()),
            ...owned.map((d) => _buildMenuItem(d, cs, tt)),
          ],
          if (managed.isNotEmpty) ...[
            if (owned.isNotEmpty)
              const DropdownMenuItem<int>(
                  value: null, enabled: false, child: Divider()),
            ...managed.map((d) => _buildMenuItem(d, cs, tt)),
          ],
        ],
        onChanged: (id) {
          if (id == null) return;
          setState(() {
            _selectedSupplierId = id;
            _selectedIndex = 0;
            widget.supplierNotifier.selectSupplier(id);
          });
        },
      ),
    );
  }

  DropdownMenuItem<int> _buildMenuItem(
      SupplierData data, ColorScheme cs, TextTheme tt) {
    final isSelected = data.id == _selectedSupplierId;
    final isOwner = data.accessType == SupplierAccessType.owner;
    final l10n = AppLocalizations.of(context);

    return DropdownMenuItem<int>(
      value: data.id,
      child: Row(
        children: [
          _buildAvatar(data, cs, isSelected, isOwner),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.supplier.providerName,
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
                        color: isOwner ? cs.primary : cs.onSurfaceVariant),
                    const SizedBox(width: 2),
                    Text(
                      isOwner
                          ? (l10n?.owner ?? 'Owner')
                          : (l10n?.managed ?? 'Managed'),
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

  Widget _buildAvatar(
          SupplierData data, ColorScheme cs, bool selected, bool isOwner) =>
      Container(
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
            data.supplier.providerName.isNotEmpty
                ? data.supplier.providerName[0].toUpperCase()
                : 'S',
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

  Widget _buildPendingInvitationsButton(ColorScheme cs) {
    final userId = widget.currentUser.idAppUser ?? 0;
    final pending = widget.personnelNotifier.getPendingRulesForUser(userId);
    final count = pending.length;
    final l10n = AppLocalizations.of(context);

    return IconButton(
      icon: Stack(
        children: [
          Icon(Icons.mail_outline, size: 20, color: cs.onSurfaceVariant),
          if (count > 0)
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration:
                    BoxDecoration(color: cs.error, shape: BoxShape.circle),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Center(
                  child: Text(
                    count > 9 ? '9+' : '$count',
                    style: TextStyle(
                        fontSize: 10,
                        color: cs.onError,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
        ],
      ),
      onPressed: () => showDialog(
        context: context,
        builder: (ctx) => PendingInvitationsDialog(
          pendingRules: pending,
          personnelNotifier: widget.personnelNotifier,
        ),
      ),
      tooltip: l10n?.pendingInvitations ?? 'Pending invitations',
    );
  }

  // ============================================================
  // FAB
  // ============================================================

  Widget? _buildFab(List<DashboardItem> items) {
    if (_selectedIndex >= items.length) return null;
    final item = items[_selectedIndex];
    if (!item.showFloatingAction ||
        item.privilegeLevel != PrivilegeLevel.manage) return null;
    return DashboardFAB(
        item: item, onPressed: () => _handleFab(context, item.type));
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
        Navigator.pushNamed(context, AppRoutes.serviceForm,
            arguments: {'providerId': _selectedSupplierId});
        break;
      default:
        _showDefaultAction(context, type);
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
            behavior: SnackBarBehavior.floating),
      );
    }
  }
}
