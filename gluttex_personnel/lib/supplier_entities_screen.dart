import 'package:flutter/material.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_event/personnel_notifier.dart';
import 'package:gluttex_event/supplier_change_notifier.dart';
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
    // Initialize data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final supplierNotifier = context.read<SupplierChangeNotifier>();
      final personnelNotifier = context.read<PersonnelNotifier>();

      if (supplierNotifier.suppliers.isEmpty) {
        supplierNotifier.fetchSuppliers(reset: true);
      }

      // Load global personnel statistics
      personnelNotifier.loadPersonnel(
        0, // userId
        supplierId: 0, // Global (all suppliers)
        includePending: true,
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(theme, colorScheme),
          _buildSearchAndFilter(theme, colorScheme),
          _buildSupplierList(theme, colorScheme),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(colorScheme),
    );
  }

  SliverAppBar _buildAppBar(ThemeData theme, ColorScheme colorScheme) {
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
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
                            Consumer2<SupplierChangeNotifier,
                                PersonnelNotifier>(
                              builder: (context, supplierNotifier,
                                  personnelNotifier, child) {
                                final totalSuppliers =
                                    supplierNotifier.suppliers.length;

                                // Get global statistics from your PersonnelNotifier
                                final globalStats =
                                    personnelNotifier.getGlobalStats();
                                final totalActiveUsers =
                                    globalStats['totalActiveUsers'] ?? 0;
                                final totalPendingUsers =
                                    globalStats['totalPendingUsers'] ?? 0;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$totalSuppliers locations • $totalActiveUsers team members',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onPrimary
                                            .withOpacity(0.9),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (totalPendingUsers > 0)
                                      Text(
                                        '$totalPendingUsers pending invitations',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onPrimary
                                              .withOpacity(0.7),
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
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildAddBusinessButton(theme, colorScheme),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildPerformanceIndicator(theme, colorScheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddBusinessButton(ThemeData theme, ColorScheme colorScheme) {
    return FloatingActionButton.small(
      onPressed: _addNewBusiness,
      backgroundColor: colorScheme.onPrimary,
      foregroundColor: colorScheme.primary,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.add_business_rounded, size: 20),
    );
  }

  Widget _buildPerformanceIndicator(ThemeData theme, ColorScheme colorScheme) {
    return Consumer2<SupplierChangeNotifier, PersonnelNotifier>(
      builder: (context, supplierNotifier, personnelNotifier, child) {
        final activeBusinesses = supplierNotifier.suppliers.length;
        // final totalRevenue = _calculateTotalRevenue(supplierNotifier.suppliers);

        // Get personnel statistics
        final globalStats = personnelNotifier.getGlobalStats();
        final totalPersonnel = globalStats['totalActiveUsers'] ?? 0;
        final admins = globalStats['admins'] ?? 0;
        final managers = globalStats['managers'] ?? 0;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: colorScheme.onPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.onPrimary.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPerformanceItem(
                'Businesses',
                '$activeBusinesses',
                Icons.business_rounded,
                colorScheme.primary,
                theme,
                colorScheme,
              ),
              _buildPerformanceItem(
                'Team',
                '$totalPersonnel',
                Icons.people_alt_rounded,
                colorScheme.secondary,
                theme,
                colorScheme,
              ),
              // _buildPerformanceItem(
              //   'Revenue',
              //   '\$${totalRevenue.toStringAsFixed(0)}',
              //   Icons.trending_up_rounded,
              //   Colors.amber,
              //   theme,
              //   colorScheme,
              // ),
              _buildPerformanceItem(
                'Management',
                '${admins + managers}',
                Icons.manage_accounts_rounded,
                colorScheme.tertiary,
                theme,
                colorScheme,
              ),
            ],
          ),
        );
      },
    );
  }

  // double _calculateTotalRevenue(List<Supplier> suppliers) {
  //   // Placeholder - replace with actual revenue calculation from your Supplier model
  //   return suppliers.length * 10000.0;
  // }

  Widget _buildPerformanceItem(
    String label,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
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

  SliverToBoxAdapter _buildSearchAndFilter(
      ThemeData theme, ColorScheme colorScheme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          children: [
            // Search Bar
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
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                  // Trigger search in notifier
                  if (value.isNotEmpty) {
                    context
                        .read<SupplierChangeNotifier>()
                        .searchSuppliers(value);
                  } else {
                    // Reset to all suppliers when search is cleared
                    context
                        .read<SupplierChangeNotifier>()
                        .fetchSuppliers(reset: true);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Search businesses...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: colorScheme.onSurfaceVariant, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded,
                              color: colorScheme.onSurfaceVariant, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                            context
                                .read<SupplierChangeNotifier>()
                                .fetchSuppliers(reset: true);
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Filter Chips
            _buildFilterChips(theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme, ColorScheme colorScheme) {
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
            onSelected: (selected) {
              setState(() {
                _filterStatus = selected ? filter.status : null;
              });
            },
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
            side: BorderSide(
              color: filter.color.withOpacity(0.3),
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            labelPadding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          );
        },
      ),
    );
  }

  Consumer<SupplierChangeNotifier> _buildSupplierList(
      ThemeData theme, ColorScheme colorScheme) {
    return Consumer<SupplierChangeNotifier>(
      builder: (context, notifier, child) {
        if (notifier.isLoading && notifier.suppliers.isEmpty) {
          return SliverToBoxAdapter(
            child: _buildLoadingShimmer(colorScheme),
          );
        }

        // Apply local filters to the notifier's suppliers
        final filteredSuppliers = notifier.suppliers.where((supplier) {
          final matchesSearch = _searchQuery.isEmpty ||
              supplier.providerName
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              (supplier.provider_organisation_desc
                      ?.toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ??
                  false);

          // You'll need to map your Supplier status to EntityStatus
          final supplierStatus = _mapSupplierToEntityStatus(supplier);
          final matchesFilter =
              _filterStatus == null || supplierStatus == _filterStatus;

          return matchesSearch && matchesFilter;
        }).toList();

        if (filteredSuppliers.isEmpty) {
          return SliverToBoxAdapter(
            child: _buildEmptyState(theme, colorScheme),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final supplier = filteredSuppliers[index];
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: _buildSupplierCard(supplier, theme, colorScheme),
              );
            },
            childCount: filteredSuppliers.length,
          ),
        );
      },
    );
  }

  EntityStatus _mapSupplierToEntityStatus(Supplier supplier) {
    // Map your Supplier status to EntityStatus
    // This is a placeholder - adjust based on your actual Supplier model
    return EntityStatus.active;
    // // if (supplier.isActive ?? true) {
    // } else if (supplier.isUnderMaintenance ?? false) {
    //   return EntityStatus.maintenance;
    // } else {
    //   return EntityStatus.inactive;
    // }
  }

  Widget _buildLoadingShimmer(ColorScheme colorScheme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
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
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
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

  Widget _buildSupplierCard(
      Supplier supplier, ThemeData theme, ColorScheme colorScheme) {
    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      child: InkWell(
        onTap: () => _navigateToPersonnelManagement(supplier),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSupplierImage(supplier, colorScheme),
              const SizedBox(width: 12),
              Expanded(
                child: Consumer<PersonnelNotifier>(
                  builder: (context, personnelNotifier, child) {
                    // Get personnel statistics for this specific supplier
                    final supplierStats = personnelNotifier.getSupplierStats(
                      supplier.idProductProvider,
                    );

                    final activeCount = supplierStats['active'] ?? 0;
                    final pendingCount = supplierStats['pending'] ?? 0;

                    return _buildSupplierInfo(supplier, activeCount,
                        pendingCount, theme, colorScheme);
                  },
                ),
              ),
              _buildSupplierActions(supplier, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupplierImage(Supplier supplier, ColorScheme colorScheme) {
    return Stack(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: supplier.supplier_image_url != null &&
                    supplier.supplier_image_url!.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(supplier.supplier_image_url!),
                    fit: BoxFit.cover,
                  )
                : null,
            color: supplier.supplier_image_url == null
                ? colorScheme.surfaceVariant
                : null,
          ),
          child: supplier.supplier_image_url == null
              ? Icon(
                  Icons.business_rounded,
                  size: 30,
                  color: colorScheme.onSurfaceVariant,
                )
              : null,
        ),
        Positioned(
          top: -2,
          right: -2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: _getStatusColor(
                  _mapSupplierToEntityStatus(supplier), colorScheme),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              _getStatusText(_mapSupplierToEntityStatus(supplier)),
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                height: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSupplierInfo(Supplier supplier, int activePersonnel,
      int pendingInvitations, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    supplier.providerName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // const SizedBox(height: 4),
                  // Row(
                  //   children: [
                  //     Icon(Icons.category_rounded,
                  //         size: 14, color: colorScheme.onSurfaceVariant),
                  //     const SizedBox(width: 4),
                  //     Expanded(
                  //       child: Text(
                  //         supplier.provider_organisation_desc ??
                  //             'No description',
                  //         style: theme.textTheme.bodySmall?.copyWith(
                  //           color: colorScheme.onSurfaceVariant,
                  //           fontWeight: FontWeight.w500,
                  //         ),
                  //         maxLines: 1,
                  //         overflow: TextOverflow.ellipsis,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // You can replace this with actual business rating if available
            // _buildRatingBadge(4.5, theme, colorScheme), // Placeholder rating
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.location_on_rounded,
                size: 14, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                supplier.locationName ?? 'No location',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  _buildInfoChip(
                    icon: Icons.people_alt_rounded,
                    value: '$activePersonnel',
                    label: 'Team',
                    color: colorScheme.primary,
                    theme: theme,
                  ),
                  if (pendingInvitations > 0)
                    _buildInfoChip(
                      icon: Icons.pending_actions_rounded,
                      value: '$pendingInvitations',
                      label: 'Pending',
                      color: Colors.orange,
                      theme: theme,
                    ),
                  // _buildInfoChip(
                  //   icon: Icons.attach_money_rounded,
                  //   value:
                  //       '\$${_calculateSupplierRevenue(supplier).toStringAsFixed(0)}',
                  //   label: 'Revenue',
                  //   color: colorScheme.tertiary,
                  //   theme: theme,
                  // ),
                ],
              ),
            ),
            // Text(
            //   'Recently active',
            //   style: theme.textTheme.labelSmall?.copyWith(
            //     color: colorScheme.onSurfaceVariant.withOpacity(0.6),
            //   ),
            // ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            value,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
          const SizedBox(width: 1),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color.withOpacity(0.7),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierActions(Supplier supplier, ColorScheme colorScheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Consumer<PersonnelNotifier>(
          builder: (context, personnelNotifier, child) {
            final supplierStats = personnelNotifier.getSupplierStats(
              supplier.idProductProvider,
            );
            final activeCount = supplierStats['active'] ?? 0;

            return IconButton(
              onPressed: () => _navigateToPersonnelManagement(supplier),
              icon: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.people_alt_rounded,
                        color: colorScheme.onPrimaryContainer, size: 18),
                  ),
                  if (activeCount > 0)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.surface,
                            width: 1.5,
                          ),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$activeCount',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        // PopupMenuButton<String>(
        //   onSelected: (value) => _handleMenuAction(value, supplier),
        //   itemBuilder: (context) => [
        //     PopupMenuItem(
        //       value: 'analytics',
        //       child: Row(
        //         children: [
        //           Icon(Icons.analytics_rounded,
        //               color: colorScheme.primary, size: 18),
        //           const SizedBox(width: 8),
        //           const Text('Analytics'),
        //         ],
        //       ),
        //     ),
        //     PopupMenuItem(
        //       value: 'edit',
        //       child: Row(
        //         children: [
        //           Icon(Icons.edit_rounded,
        //               color: colorScheme.secondary, size: 18),
        //           const SizedBox(width: 8),
        //           const Text('Edit'),
        //         ],
        //       ),
        //     ),
        //     PopupMenuItem(
        //       value: 'settings',
        //       child: Row(
        //         children: [
        //           Icon(Icons.settings_rounded,
        //               color: colorScheme.tertiary, size: 18),
        //           const SizedBox(width: 8),
        //           const Text('Settings'),
        //         ],
        //       ),
        //     ),
        //     const PopupMenuDivider(),
        //     PopupMenuItem(
        //       value: 'archive',
        //       child: Row(
        //         children: [
        //           Icon(Icons.archive_rounded,
        //               color: colorScheme.error, size: 18),
        //           const SizedBox(width: 8),
        //           const Text('Archive'),
        //         ],
        //       ),
        //     ),
        //   ],
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(12),
        //   ),
        //   child: Container(
        //     padding: const EdgeInsets.all(8),
        //     decoration: BoxDecoration(
        //       color: colorScheme.surfaceVariant,
        //       borderRadius: BorderRadius.circular(10),
        //     ),
        //     child: Icon(Icons.more_vert_rounded,
        //         color: colorScheme.onSurfaceVariant, size: 18),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildFloatingActionButton(ColorScheme colorScheme) {
    return FloatingActionButton(
      onPressed: _addNewBusiness,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.add_business_rounded, size: 24),
    );
  }

  void _handleMenuAction(String action, Supplier supplier) {
    switch (action) {
      case 'analytics':
        _viewAnalytics(supplier);
        break;
      case 'edit':
        _editBusiness(supplier);
        break;
      case 'settings':
        _businessSettings(supplier);
        break;
      case 'archive':
        _archiveBusiness(supplier);
        break;
    }
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

  Color _getStatusColor(EntityStatus status, ColorScheme colorScheme) {
    switch (status) {
      case EntityStatus.active:
        return Colors.green;
      case EntityStatus.maintenance:
        return Colors.orange;
      case EntityStatus.inactive:
        return colorScheme.error;
    }
  }

  String _getStatusText(EntityStatus status) {
    switch (status) {
      case EntityStatus.active:
        return 'ACTIVE';
      case EntityStatus.maintenance:
        return 'MAINT';
      case EntityStatus.inactive:
        return 'INACTIVE';
    }
  }

  void _addNewBusiness() {
    // Implement add new business
    print('Add new business');
  }

  void _viewAnalytics(Supplier supplier) {
    print('View analytics for ${supplier.providerName}');
  }

  void _editBusiness(Supplier supplier) {
    print('Edit business ${supplier.providerName}');
  }

  void _businessSettings(Supplier supplier) {
    print('Open settings for ${supplier.providerName}');
  }

  void _archiveBusiness(Supplier supplier) {
    print('Archive business ${supplier.providerName}');
  }
}

class _FilterChipData {
  final String label;
  final EntityStatus? status;
  final Color color;

  _FilterChipData(this.label, this.status, this.color);
}

enum EntityStatus {
  active,
  maintenance,
  inactive,
}
