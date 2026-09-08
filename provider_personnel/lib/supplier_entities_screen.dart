// supplier_entities_screen.dart

import 'package:app_constants/app_routes.dart';
import 'package:event/extensions/personnel_access_manager.dart';
import 'package:flutter/material.dart';
import 'package:event/personnel_notifier.dart';
import 'package:event/supplier_change_notifier.dart';
import 'package:gluttex_core/app/ManagementRule.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_localizations/gen_l10n/app_localizations.dart';

class SupplierEntitiesScreen extends StatefulWidget {
  final int userId;
  final List<int> accessibleSuppliers;
  final List<ManagementRule> userRules;
  final List<Supplier> suppliers;
  final List<AccessibleSupplier> suppliersWithAccess;
  final PersonnelNotifier personnelNotifier;
  final SupplierChangeNotifier supplierNotifier;
  final PersonnelAccessManager accessManager;

  const SupplierEntitiesScreen({
    Key? key,
    required this.userId,
    required this.accessibleSuppliers,
    required this.userRules,
    required this.suppliers,
    required this.suppliersWithAccess,
    required this.personnelNotifier,
    required this.supplierNotifier,
    required this.accessManager,
  }) : super(key: key);

  @override
  State<SupplierEntitiesScreen> createState() => _SupplierEntitiesScreenState();
}

class _SupplierEntitiesScreenState extends State<SupplierEntitiesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterType = 'all';
  bool _isLoading = false;
  bool _dataLoaded = false;

  // ============================================================
  // COMPUTED GETTERS
  // ============================================================

  List<AccessibleSupplier> get _visibleSuppliers {
    if (widget.suppliersWithAccess.isEmpty && widget.userId > 0) {
      return widget.accessManager
          .getAccessibleSuppliersWithAccessTypeSync(widget.userId);
    }

    return widget.suppliersWithAccess
        .where((supplier) =>
            supplier.isOwner ||
            widget.personnelNotifier
                .hasPrivilege(widget.userId, supplier.id, 'personnel_view') ||
            widget.personnelNotifier
                .hasPrivilege(widget.userId, supplier.id, 'personnel_manage'))
        .toList();
  }

  List<AccessibleSupplier> get _owned =>
      _visibleSuppliers.where((s) => s.isOwner).toList();

  List<AccessibleSupplier> get _managed =>
      _visibleSuppliers.where((s) => s.isManaged).toList();

  // ✅ SIMPLIFIED: Get pending rules directly from the notifier
  List<ManagementRule> get _pendingRules {
    return widget.personnelNotifier.getPendingRulesForUser(widget.userId);
  }

  // ✅ Get pending suppliers from pending rules
  List<AccessibleSupplier> get _pendingSuppliers {
    final pendingRules = _pendingRules;
    if (pendingRules.isEmpty) return [];

    final pendingSuppliers = <AccessibleSupplier>[];
    final addedIds = <int>{};

    for (final rule in pendingRules) {
      final provider = rule.productProvider;
      if (provider == null) continue;

      final supplierId = provider.idProductProvider;
      if (addedIds.contains(supplierId)) continue;

      // Try to find the supplier in the suppliers list
      final supplier = widget.suppliers.firstWhere(
        (s) => s.idProductProvider == supplierId,
        orElse: () => provider as Supplier,
      );

      // Determine if it's owned or managed
      final isOwned = supplier.productProviderOwnerId == widget.userId;

      pendingSuppliers.add(AccessibleSupplier(
        supplier: supplier,
        accessType:
            isOwned ? SupplierAccessType.owner : SupplierAccessType.managed,
      ));
      addedIds.add(supplierId);
    }

    return pendingSuppliers;
  }

  // ✅ Get pending count directly
  int get _pendingCount => _pendingRules.length;

  List<AccessibleSupplier> get _filtered {
    var suppliers = _visibleSuppliers;

    switch (_filterType) {
      case 'owned':
        suppliers = _owned;
        break;
      case 'managed':
        suppliers = _managed;
        break;
      case 'pending':
        suppliers = _pendingSuppliers;
        break;
      default:
        break;
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      suppliers = suppliers.where((s) {
        final name = s.supplier.providerName?.toLowerCase() ?? '';
        final org = s.supplier.providerOrganisationName?.toLowerCase() ?? '';
        return name.contains(q) || org.contains(q);
      }).toList();
    }

    return suppliers;
  }

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim());
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if ((widget.suppliersWithAccess.isEmpty || widget.suppliers.isEmpty) &&
          widget.userId > 0) {
        _loadData();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // DATA LOADING
  // ============================================================

  Future<void> _loadData() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      await widget.supplierNotifier.fetchOwnedSuppliers(
        widget.userId,
        forceRefresh: true,
      );
      await widget.personnelNotifier.loadPersonnel(
        userId: widget.userId,
        reset: true,
        includePending: true,
      );

      setState(() => _dataLoaded = true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AppLocalizations.of(context)?.refreshSuccess ?? 'Refreshed'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)?.error}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refresh() async {
    await _loadData();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final filtered = _filtered;
    final visibleSuppliers = _visibleSuppliers;
    final pendingCount = _pendingCount;

    if (_isLoading && visibleSuppliers.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator.adaptive(),
              const SizedBox(height: 16),
              Text(l10n?.loading ?? 'Loading...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(l10n, cs, visibleSuppliers),
            _buildSearch(l10n, cs),
            _buildStats(l10n, cs, visibleSuppliers, pendingCount),
            _buildFilters(l10n, cs),
            Expanded(child: _buildList(l10n, filtered)),
          ],
        ),
      ),
      floatingActionButton: _buildFab(l10n, cs),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(AppLocalizations? l10n, ColorScheme cs,
          List<AccessibleSupplier> visibleSuppliers) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: cs.onPrimary),
              onPressed: () => Navigator.pop(context),
              tooltip: l10n?.back ?? 'Back',
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n?.businesses ?? 'Businesses',
                    style: TextStyle(
                      color: cs.onPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${visibleSuppliers.length} ${l10n?.accessible ?? 'accessible'}',
                    style: TextStyle(
                      color: cs.onPrimary.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cs.onPrimary,
                      ),
                    )
                  : Icon(Icons.refresh, color: cs.onPrimary),
              onPressed: _isLoading ? null : _refresh,
            ),
          ],
        ),
      );

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearch(AppLocalizations? l10n, ColorScheme cs) => Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: l10n?.searchBusinesses ?? 'Search businesses...',
            prefixIcon: Icon(Icons.search, color: cs.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.outline.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.outline.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.primary, width: 2),
            ),
            filled: true,
            fillColor: cs.surfaceVariant.withOpacity(0.2),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: cs.onSurfaceVariant),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
          ),
        ),
      );

  // ============================================================
  // STATS
  // ============================================================

  Widget _buildStats(AppLocalizations? l10n, ColorScheme cs,
      List<AccessibleSupplier> visibleSuppliers, int pendingCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _chip(l10n?.total ?? 'Total', visibleSuppliers.length, cs.primary),
          const SizedBox(width: 8),
          _chip(l10n?.owned ?? 'Owned', _owned.length, Colors.blue),
          const SizedBox(width: 8),
          _chip(l10n?.managed ?? 'Managed', _managed.length, Colors.green),
          if (pendingCount > 0) ...[
            const SizedBox(width: 8),
            _chip(l10n?.pending ?? 'Pending', pendingCount, Colors.orange),
          ],
        ],
      ),
    );
  }

  Widget _chip(String label, int count, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 11),
            ),
          ],
        ),
      );

  // ============================================================
  // FILTERS
  // ============================================================

  Widget _buildFilters(AppLocalizations? l10n, ColorScheme cs) {
    final filters = [
      {'value': 'all', 'label': l10n?.all ?? 'All'},
      {'value': 'owned', 'label': l10n?.owned ?? 'Owned'},
      {'value': 'managed', 'label': l10n?.managed ?? 'Managed'},
      {'value': 'pending', 'label': l10n?.pendingInvitations ?? 'Pending'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final selected = _filterType == f['value'];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(f['label']!),
                selected: selected,
                onSelected: (_) => setState(() => _filterType = f['value']!),
                selectedColor: cs.primary.withOpacity(0.15),
                checkmarkColor: cs.primary,
                labelStyle: TextStyle(
                  color: selected ? cs.primary : cs.onSurface,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: selected
                    ? BorderSide(color: cs.primary, width: 2)
                    : BorderSide(color: cs.outline.withOpacity(0.3)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ============================================================
  // LIST
  // ============================================================

  Widget _buildList(
      AppLocalizations? l10n, List<AccessibleSupplier> suppliers) {
    if (suppliers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? l10n?.noResults ?? 'No results found'
                  : (widget.suppliersWithAccess.isEmpty && widget.userId > 0
                      ? l10n?.loading ?? 'Loading...'
                      : l10n?.noBusinesses ?? 'No businesses'),
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
                icon: const Icon(Icons.clear, size: 18),
                label: Text(l10n?.clearSearch ?? 'Clear search'),
              ),
            ],
            if (widget.suppliersWithAccess.isEmpty && widget.userId > 0) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: Text(l10n?.refresh ?? 'Refresh'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: suppliers.length,
      itemBuilder: (_, i) => _buildCard(l10n, suppliers[i]),
    );
  }

  // ============================================================
  // CARD
  // ============================================================

  Widget _buildCard(AppLocalizations? l10n, AccessibleSupplier data) {
    final s = data.supplier;
    final isOwner = data.isOwner;
    final isPending = widget.userRules.any(
      (r) =>
          r.productProvider?.idProductProvider == s.idProductProvider &&
          r.isPending,
    );
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isPending
            ? BorderSide(color: Colors.orange, width: 2)
            : BorderSide.none,
      ),
      elevation: isPending ? 3 : 1,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: isOwner ? cs.primary : cs.secondaryContainer,
          radius: 20,
          child: Text(
            s.providerName.isNotEmpty ? s.providerName[0].toUpperCase() : 'S',
            style: TextStyle(
              color: isOwner ? cs.onPrimary : cs.onSecondaryContainer,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                s.providerName,
                style: const TextStyle(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isOwner)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, size: 14, color: cs.primary),
                    const SizedBox(width: 2),
                    Text(
                      l10n?.owner ?? 'Owner',
                      style: TextStyle(
                          fontSize: 10,
                          color: cs.primary,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            if (isPending)
              Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  l10n?.pending ?? 'Pending',
                  style: const TextStyle(
                      fontSize: 10,
                      color: Colors.orange,
                      fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (s.providerOrganisationName.isNotEmpty)
              Text(
                s.providerOrganisationName,
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
            if (isPending)
              Text(
                'Invitation pending...',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.orange,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: Icon(Icons.more_vert, color: cs.onSurfaceVariant),
          itemBuilder: (_) => [
            PopupMenuItem(
                value: 'view',
                child: Text(l10n?.viewDetails ?? 'View Details')),
            if (isOwner)
              PopupMenuItem(value: 'edit', child: Text(l10n?.edit ?? 'Edit')),
            if (!isOwner && !isPending)
              PopupMenuItem(
                  value: 'manage',
                  child: Text(l10n?.manageAccess ?? 'Manage Access')),
            if (isPending)
              PopupMenuItem(
                  value: 'cancel_invitation',
                  child: Text(l10n?.cancelInvitation ?? 'Cancel Invitation')),
            PopupMenuItem(
                value: 'privileges',
                child: Text(l10n?.privileges ?? 'Privileges')),
          ],
          onSelected: (v) => _handleAction(context, v, s),
        ),
        onTap: () => _navigateToSupplierManage(context, s),
      ),
    );
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  void _handleAction(BuildContext context, String value, Supplier supplier) {
    switch (value) {
      case 'view':
        _navigateToSupplierManage(context, supplier);
        break;
      case 'edit':
        _navigateToSupplierManage(context, supplier);
        break;
      case 'manage':
        _navigateToSupplierManage(context, supplier);
        break;
      case 'privileges':
        _showPrivileges(context, supplier);
        break;
      case 'cancel_invitation':
        _cancelInvitation(context, supplier);
        break;
      default:
        break;
    }
  }

  void _navigateToSupplierManage(BuildContext context, Supplier supplier) {
    Navigator.pushNamed(
      context,
      AppRoutes.supplierManage,
      arguments: {
        'supplierName': supplier.providerName,
        'orgId': supplier.idProviderOrganisation,
        'supplierId': supplier.idProductProvider,
      },
    );
  }

  void _cancelInvitation(BuildContext context, Supplier supplier) {
    final rule = widget.userRules.firstWhere(
      (r) =>
          r.productProvider?.idProductProvider == supplier.idProductProvider &&
          r.isPending,
      orElse: () => ManagementRule.empty(),
    );

    if (rule.idManagementRule == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)?.noPendingInvitation ??
              'No pending invitation found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.cancelInvitation ??
            'Cancel Invitation'),
        content: Text(
          '${AppLocalizations.of(context)?.areYouSureYouWantToCancelTheInvitationFor ?? 'Are you sure you want to cancel the invitation for'} ${supplier.providerName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success =
                  await widget.personnelNotifier.removeUserFromSupplier(
                rule.idManagementRule,
                widget.userId,
                supplier.idProductProvider,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? (AppLocalizations.of(context)
                                  ?.invitationCancelledSuccessfully ??
                              'Invitation cancelled successfully')
                          : (AppLocalizations.of(context)
                                  ?.failedToCancelInvitation ??
                              'Failed to cancel invitation'),
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
                if (success) _refresh();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)?.cancelInvitation ??
                'Cancel Invitation'),
          ),
        ],
      ),
    );
  }

  void _showPrivileges(BuildContext context, Supplier supplier) {
    final rules = widget.userRules
        .where(
          (r) =>
              r.productProvider?.idProductProvider ==
              supplier.idProductProvider,
        )
        .toList();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
            '${AppLocalizations.of(context)?.privilegesFor} ${supplier.providerName}'),
        content: rules.isEmpty
            ? Text(AppLocalizations.of(context)?.noPrivileges ??
                'No privileges assigned.')
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: rules
                    .map((r) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Icon(
                                r.isActive
                                    ? Icons.check_circle_rounded
                                    : Icons.pending_rounded,
                                color:
                                    r.isActive ? Colors.green : Colors.orange,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(r.managementRuleCode.toString()),
                            ],
                          ),
                        ))
                    .toList(),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)?.close ?? 'Close'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FAB
  // ============================================================

  Widget _buildFab(AppLocalizations? l10n, ColorScheme cs) =>
      FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppRoutes.supplierManage,
            arguments: {
              'supplierId': 0,
              'orgId': 0,
              'isNew': true,
            },
          );
        },
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        icon: const Icon(Icons.add_business_rounded),
        label: Text(l10n?.add ?? 'Add'),
      );
}
