import 'package:flutter/material.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_event/personnel_notifier.dart';
import 'package:gluttex_event/supplier_change_notifier.dart';
import 'package:gluttex_personnel/components/supplier_card.dart';
import 'package:gluttex_personnel/personnel_management_screen.dart';
import 'package:provider/provider.dart';

class SupplierEntitiesScreen extends StatefulWidget {
  const SupplierEntitiesScreen({Key? key}) : super(key: key);

  @override
  State<SupplierEntitiesScreen> createState() => _SupplierEntitiesScreenState();
}

class _SupplierEntitiesScreenState extends State<SupplierEntitiesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  EntityStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _initializeData() {
    final supplierNotifier = context.read<SupplierChangeNotifier>();
    final personnelNotifier = context.read<PersonnelNotifier>();

    if (supplierNotifier.suppliers.isEmpty) {
      supplierNotifier.fetchSuppliers(reset: true);
    }

    personnelNotifier.loadPersonnel(
      supplierId: 0, // Global statistics
      includePending: true,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildSearchAndFilter(),
          _buildSupplierList(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  // ================ MAIN WIDGETS ================

  SliverAppBar _buildAppBar() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SliverAppBar(
      expandedHeight: 220,
      floating: false,
      pinned: true,
      snap: false,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary,
                colorScheme.primaryContainer,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 60, left: 20, right: 20, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppBarHeader(theme, colorScheme),
                  const SizedBox(height: 16),
                  _buildPerformanceIndicator(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarHeader(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildTitleAndStats(),
        ),
        const SizedBox(width: 12),
        // buildAddBusinessButton(colorScheme),
      ],
    );
  }

  Widget _buildTitleAndStats() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Businesses',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Consumer2<SupplierChangeNotifier, PersonnelNotifier>(
          builder: (context, supplierNotifier, personnelNotifier, child) {
            final totalSuppliers = supplierNotifier.suppliers.length;
            // final globalStats = personnelNotifier.getGlobalStats();
            final totalActiveUsers = 0;
            final totalPendingUsers = 0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$totalSuppliers locations • $totalActiveUsers team members',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimary.withOpacity(0.9),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (totalPendingUsers > 0)
                  Text(
                    '$totalPendingUsers pending invitations',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimary.withOpacity(0.7),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildPerformanceIndicator() {
    return Consumer2<SupplierChangeNotifier, PersonnelNotifier>(
      builder: (context, supplierNotifier, personnelNotifier, child) {
        final activeBusinesses = supplierNotifier.suppliers.length;
        // final globalStats = personnelNotifier.getGlobalStats();
        // final totalPersonnel = globalStats['totalActiveUsers'] ?? 0;
        // final admins = globalStats['admins'] ?? 0;
        // final managers = globalStats['managers'] ?? 0;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPerformanceItem(
                'Businesses',
                '$activeBusinesses',
                Icons.business_rounded,
                Theme.of(context).colorScheme.primary,
              ),
              _buildPerformanceItem(
                'Team',
                '',
                Icons.people_alt_rounded,
                Theme.of(context).colorScheme.secondary,
              ),
              _buildPerformanceItem(
                'Management',
                '}',
                Icons.manage_accounts_rounded,
                Theme.of(context).colorScheme.tertiary,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPerformanceItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimary.withOpacity(0.8),
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildSearchAndFilter() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _handleSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search businesses...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: colorScheme.onSurfaceVariant, size: 20),
                  suffixIcon: _buildClearSearchButton(),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildFilterChips(),
          ],
        ),
      ),
    );
  }

  Widget? _buildClearSearchButton() {
    if (_searchQuery.isEmpty) return null;

    return IconButton(
      icon: Icon(Icons.clear_rounded,
          color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
      onPressed: () {
        _searchController.clear();
        setState(() => _searchQuery = '');
        context.read<SupplierChangeNotifier>().fetchSuppliers(reset: true);
      },
    );
  }

  void _handleSearchChanged(String value) {
    setState(() => _searchQuery = value);
    if (value.isNotEmpty) {
      context.read<SupplierChangeNotifier>().searchSuppliers(value);
    } else {
      context.read<SupplierChangeNotifier>().fetchSuppliers(reset: true);
    }
  }

  Widget _buildFilterChips() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filters = [
      _FilterChipData('All', null, colorScheme.primary),
      _FilterChipData('Active', EntityStatus.active, Colors.green),
      _FilterChipData('Maintenance', EntityStatus.maintenance, Colors.orange),
      _FilterChipData('Inactive', EntityStatus.inactive, Colors.red),
    ];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _filterStatus == filter.status;

          return FilterChip(
            selected: isSelected,
            onSelected: (selected) =>
                setState(() => _filterStatus = selected ? filter.status : null),
            label: Text(
              filter.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected ? Colors.white : filter.color,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: colorScheme.surface,
            selectedColor: filter.color,
            checkmarkColor: Colors.white,
            side: BorderSide(color: filter.color.withOpacity(0.3), width: 1),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            labelPadding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          );
        },
      ),
    );
  }

  Consumer<SupplierChangeNotifier> _buildSupplierList() {
    return Consumer<SupplierChangeNotifier>(
      builder: (context, notifier, child) {
        if (notifier.isLoading && notifier.suppliers.isEmpty) {
          return SliverToBoxAdapter(child: _buildLoadingShimmer());
        }

        final filteredSuppliers =
            notifier.suppliers.where(_filterSupplier).toList();

        if (filteredSuppliers.isEmpty) {
          return SliverToBoxAdapter(child: _buildEmptyState());
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: SupplierCard(supplier: filteredSuppliers[index]),
            ),
            childCount: filteredSuppliers.length,
          ),
        );
      },
    );
  }

  bool _filterSupplier(Supplier supplier) {
    final matchesSearch = _searchQuery.isEmpty ||
        supplier.providerName
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()) ||
        (supplier.provider_organisation_desc
                ?.toLowerCase()
                .contains(_searchQuery.toLowerCase()) ??
            false);

    final supplierStatus = _mapSupplierToEntityStatus(supplier);
    final matchesFilter =
        _filterStatus == null || supplierStatus == _filterStatus;

    return matchesSearch && matchesFilter;
  }

  Widget _buildLoadingShimmer() {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 16,
                    color: colorScheme.surfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 80,
                    height: 14,
                    color: colorScheme.surfaceVariant,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.business_center_rounded,
            size: 56,
            color: colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No businesses found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try adjusting your search or filters'
                : 'Add your first business to get started',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _addNewBusiness,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Add Business'),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    final colorScheme = Theme.of(context).colorScheme;

    return FloatingActionButton(
      onPressed: _addNewBusiness,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.add_business_rounded, size: 24),
    );
  }

  // ================ HELPER METHODS ================

  EntityStatus _mapSupplierToEntityStatus(Supplier supplier) {
    // TODO: Implement actual status mapping from Supplier model
    return EntityStatus.active;
  }

  void _addNewBusiness() {
    // TODO: Implement add new business
    print('Add new business');
  }

  void _navigateToPersonnelManagement(Supplier supplier) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonnelManagementScreen(
          supplierName: supplier.providerName,
          orgId: supplier.id_provider_organisation,
          supplierId: supplier.idProductProvider,
        ),
      ),
    );
  }
}

class _FilterChipData {
  final String label;
  final EntityStatus? status;
  final Color color;

  _FilterChipData(this.label, this.status, this.color);
}

enum EntityStatus { active, maintenance, inactive }
