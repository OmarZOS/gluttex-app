// supplier_entities_screen.dart

import 'package:event/extensions/personnel_access_manager.dart';
import 'package:flutter/material.dart';
import 'package:event/personnel_notifier.dart';
import 'package:event/supplier_change_notifier.dart';
import 'package:event/user_change_notifier.dart';
import 'package:provider/provider.dart';
import 'package:gluttex_core/app/ManagementRule.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_core/business/Organisation.dart';

// Import your content widget - adjust path as needed
// import 'package:provider_personnel/components/management/supplier_entities_content.dart';

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
  int? _selectedCategoryId;
  bool _showAllSuppliers = true;
  bool _isLoading = false;
  bool _showPendingOnly = false;
  String _filterType = 'all'; // 'all', 'owned', 'managed', 'pending'

  String _searchQuery = '';

  // ✅ Use AccessManager to get filtered lists
  List<AccessibleSupplier> get _managedSuppliers {
    return widget.suppliersWithAccess
        .where((s) => s.accessType == SupplierAccessType.managed)
        .toList();
  }

  List<AccessibleSupplier> get _ownedSuppliers {
    return widget.suppliersWithAccess
        .where((s) => s.accessType == SupplierAccessType.owner)
        .toList();
  }

  List<AccessibleSupplier> get _pendingSuppliers {
    final pendingIds = widget.userRules
        .where((r) => r.isPending)
        .map((r) => r.productProvider?.idProductProvider)
        .where((id) => id != null && id > 0)
        .cast<int>()
        .toSet();

    return widget.suppliersWithAccess
        .where((s) => pendingIds.contains(s.supplier.idProductProvider))
        .toList();
  }

  // ✅ Get all suppliers with access (owned + managed)
  List<AccessibleSupplier> get _allAccessibleSuppliers {
    final allSuppliers = <AccessibleSupplier>[];
    final addedIds = <int>{};

    // Add owned suppliers first
    for (final supplier in _ownedSuppliers) {
      if (addedIds.add(supplier.id)) {
        allSuppliers.add(supplier);
      }
    }

    // Add managed suppliers
    for (final supplier in _managedSuppliers) {
      if (addedIds.add(supplier.id)) {
        allSuppliers.add(supplier);
      }
    }

    return allSuppliers;
  }

  // ✅ Get filtered suppliers based on search and filters
  List<AccessibleSupplier> get _filteredSuppliers {
    var suppliers = _allAccessibleSuppliers;

    // Filter by type
    switch (_filterType) {
      case 'owned':
        suppliers = _ownedSuppliers;
        break;
      case 'managed':
        suppliers = _managedSuppliers;
        break;
      case 'pending':
        // Get suppliers with pending rules
        final pendingIds = widget.userRules
            .where((r) => r.isPending)
            .map((r) => r.productProvider?.idProductProvider)
            .where((id) => id != null && id > 0)
            .cast<int>()
            .toSet();
        suppliers = suppliers
            .where((s) => pendingIds.contains(s.supplier.idProductProvider))
            .toList();
        break;
      case 'all':
      default:
        break;
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      suppliers = suppliers.where((s) {
        final name = s.supplier.providerName?.toLowerCase() ?? '';
        final orgName =
            s.supplier.providerOrganisationName?.toLowerCase() ?? '';
        final desc = s.supplier.providerOrganisationDesc?.toLowerCase() ?? '';
        return name.contains(query) ||
            orgName.contains(query) ||
            desc.contains(query);
      }).toList();
    }

    return suppliers;
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  Future<void> _refreshData() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      // Refresh owned suppliers
      await widget.supplierNotifier.fetchOwnedSuppliers(
        widget.userId,
        forceRefresh: true,
      );

      // Refresh personnel rules
      await widget.personnelNotifier.loadPersonnel(
        userId: widget.userId,
        reset: true,
        includePending: true,
      );

      // Refresh organisations if needed
      if (widget.supplierNotifier.organisations.isEmpty) {
        await widget.supplierNotifier.fetchOrganisations(reset: true);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data refreshed successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filteredSuppliers = _filteredSuppliers;
    final ownedCount = _ownedSuppliers.length;
    final managedCount = _managedSuppliers.length;
    final pendingCount = _pendingSuppliers.length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, colorScheme),
            _buildSearchFilter(context, colorScheme),
            _buildStatsBar(
              context,
              colorScheme,
              total: widget.suppliersWithAccess.length,
              owned: ownedCount,
              managed: managedCount,
              pending: pendingCount,
            ),
            _buildFilterChips(context, colorScheme),
            Expanded(
              child: _buildContent(context, filteredSuppliers),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context, colorScheme),
    );
  }

  Widget _buildAppBar(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Businesses',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '${widget.suppliersWithAccess.length} accessible businesses',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimary.withOpacity(0.8),
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
                      color: colorScheme.onPrimary,
                    ),
                  )
                : Icon(Icons.refresh, color: colorScheme.onPrimary),
            onPressed: _isLoading ? null : _refreshData,
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFilter(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search businesses...',
          prefixIcon: Icon(Icons.search, color: colorScheme.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          filled: true,
          fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: colorScheme.onSurfaceVariant),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildStatsBar(
    BuildContext context,
    ColorScheme colorScheme, {
    required int total,
    required int owned,
    required int managed,
    required int pending,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatChip(
            context,
            label: 'Total',
            count: total,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 8),
          _buildStatChip(
            context,
            label: 'Owned',
            count: owned,
            color: Colors.blue,
          ),
          const SizedBox(width: 8),
          _buildStatChip(
            context,
            label: 'Managed',
            count: managed,
            color: Colors.green,
          ),
          const SizedBox(width: 8),
          if (pending > 0)
            _buildStatChip(
              context,
              label: 'Pending',
              count: pending,
              color: Colors.orange,
            ),
        ],
      ),
    );
  }

  Widget _buildStatChip(
    BuildContext context, {
    required String label,
    required int count,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count.toString(),
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, ColorScheme colorScheme) {
    final filters = [
      {'value': 'all', 'label': 'All'},
      {'value': 'owned', 'label': 'Owned'},
      {'value': 'managed', 'label': 'Managed'},
      {'value': 'pending', 'label': 'Pending Invitations'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = _filterType == filter['value'];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter['label']!),
                selected: isSelected,
                onSelected: (_) {
                  setState(() {
                    _filterType = filter['value']!;
                  });
                },
                selectedColor: colorScheme.primary.withOpacity(0.2),
                checkmarkColor: colorScheme.primary,
                labelStyle: TextStyle(
                  color:
                      isSelected ? colorScheme.primary : colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: isSelected
                    ? BorderSide(color: colorScheme.primary, width: 2)
                    : BorderSide(color: colorScheme.outline.withOpacity(0.3)),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, List<AccessibleSupplier> suppliers) {
    if (suppliers.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: suppliers.length,
      itemBuilder: (context, index) {
        final accessibleSupplier = suppliers[index];
        final supplier = accessibleSupplier.supplier;
        final isOwned =
            accessibleSupplier.accessType == SupplierAccessType.owner;
        final hasPending = widget.userRules.any(
          (r) =>
              r.productProvider?.idProductProvider ==
                  supplier.idProductProvider &&
              r.isPending,
        );

        return _buildSupplierCard(
          context,
          supplier: supplier,
          isOwned: isOwned,
          hasPending: hasPending,
        );
      },
    );
  }

  Widget _buildSupplierCard(
    BuildContext context, {
    required Supplier supplier,
    required bool isOwned,
    required bool hasPending,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: hasPending
            ? BorderSide(color: Colors.orange, width: 2)
            : BorderSide.none,
      ),
      elevation: hasPending ? 4 : 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              isOwned ? colorScheme.primary : colorScheme.secondaryContainer,
          child: Text(
            supplier.providerName?.isNotEmpty == true
                ? supplier.providerName![0].toUpperCase()
                : 'S',
            style: TextStyle(
              color: isOwned
                  ? colorScheme.onPrimary
                  : colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                supplier.providerName ?? 'Unnamed Business',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isOwned)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'Owner',
                      style: TextStyle(
                        fontSize: 10,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            if (hasPending)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Pending',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (supplier.providerOrganisationName?.isNotEmpty == true)
              Text(
                supplier.providerOrganisationName!,
                style: const TextStyle(fontSize: 12),
              ),
            if (supplier.providerOrganisationDesc?.isNotEmpty == true)
              Text(
                supplier.providerOrganisationDesc!,
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Text('View Details'),
            ),
            if (isOwned)
              const PopupMenuItem(
                value: 'edit',
                child: Text('Edit Business'),
              ),
            if (!isOwned)
              const PopupMenuItem(
                value: 'manage',
                child: Text('Manage Access'),
              ),
            const PopupMenuItem(
              value: 'view_privileges',
              child: Text('View Privileges'),
            ),
          ],
          onSelected: (value) {
            _handleMenuAction(context, value, supplier);
          },
        ),
        onTap: () {
          // Navigate to supplier details
          _navigateToSupplierDetails(context, supplier.idProductProvider);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_rounded,
            size: 80,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No businesses found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'No businesses match your search'
                : 'You don\'t have access to any businesses yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear Search'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return FloatingActionButton.extended(
      onPressed: _addNewBusiness,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      icon: const Icon(Icons.add_business_rounded),
      label: const Text('Add Business'),
    );
  }

  void _handleMenuAction(
      BuildContext context, dynamic value, Supplier supplier) {
    switch (value) {
      case 'view':
        _navigateToSupplierDetails(context, supplier.idProductProvider);
        break;
      case 'edit':
        // Navigate to edit supplier
        break;
      case 'manage':
        // Navigate to manage access
        break;
      case 'view_privileges':
        // Show privileges dialog
        _showPrivilegesDialog(context, supplier);
        break;
    }
  }

  void _navigateToSupplierDetails(BuildContext context, int supplierId) {
    // TODO: Navigate to supplier details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing supplier: $supplierId'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showPrivilegesDialog(BuildContext context, Supplier supplier) {
    final rules = widget.userRules
        .where((r) =>
            r.productProvider?.idProductProvider == supplier.idProductProvider)
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Privileges for ${supplier.providerName}'),
        content: rules.isEmpty
            ? const Text('No specific privileges assigned.')
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: rules.map((rule) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          rule.isActive
                              ? Icons.check_circle_rounded
                              : Icons.pending_rounded,
                          color: rule.isActive ? Colors.green : Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            rule.managementRuleCode?.toString() ?? 'Privilege',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _addNewBusiness() {
    // TODO: Navigate to add business screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add new business'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
