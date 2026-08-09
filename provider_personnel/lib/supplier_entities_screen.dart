// supplier_entities_screen.dart

import 'package:flutter/material.dart';
import 'package:event/personnel_notifier.dart';
import 'package:event/supplier_change_notifier.dart';
import 'package:event/user_change_notifier.dart';
import 'package:provider_personnel/components/management/supplier_entities_content.dart';
import 'package:provider/provider.dart';
import 'package:gluttex_core/app/ManagementRule.dart';
import 'package:gluttex_core/business/Supplier.dart';

class SupplierEntitiesScreen extends StatefulWidget {
  final int userId;
  final List<int> accessibleSuppliers;
  final List<ManagementRule> userRules;
  final List<ProductProvider> suppliers;

  const SupplierEntitiesScreen({
    Key? key,
    required this.userId,
    required this.accessibleSuppliers,
    required this.userRules,
    required this.suppliers,
  }) : super(key: key);

  @override
  State<SupplierEntitiesScreen> createState() => _SupplierEntitiesScreenState();
}

class _SupplierEntitiesScreenState extends State<SupplierEntitiesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int? _selectedCategoryId;
  bool _showAllSuppliers = true;
  bool _isLoading = false;

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

    setState(() {
      _isLoading = true;
    });

    try {
      // Refresh supplier data
      final supplierNotifier = context.read<SupplierChangeNotifier>();
      await supplierNotifier.fetchSuppliers(
          ownerId: widget.userId, reset: true);

      // Refresh personnel rules
      final personnelNotifier = context.read<PersonnelNotifier>();
      await personnelNotifier.loadPersonnel(
        userId: widget.userId,
        reset: true,
        includePending: true,
      );

      // Refresh organisations if needed
      if (supplierNotifier.organisations.isEmpty) {
        await supplierNotifier.fetchOrganisations(reset: true);
      }

      // Show success message
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
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _updateCategory(int? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
  }

  void _toggleShowAll(bool showAll) {
    setState(() {
      _showAllSuppliers = showAll;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            _buildAppBar(context),

            // Search and Filter
            _buildSearchFilter(context),

            // Content
            SupplierEntitiesContent(
              searchQuery: _searchQuery,
              selectedCategoryId: _selectedCategoryId,
              showAllSuppliers: _showAllSuppliers,
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverAppBar(
      title: const Text('Businesses'),
      floating: true,
      snap: true,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      actions: [
        IconButton(
          icon: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.refresh),
          onPressed: _isLoading ? null : _refreshData,
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildSearchFilter(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search businesses...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 12),

            // Supplier Counts
            Row(
              children: [
                _buildCountChip(
                  context,
                  label: 'Total',
                  count: widget.userRules.length + widget.suppliers.length,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                _buildCountChip(
                  context,
                  label: 'Active',
                  count: widget.userRules.where((r) => r.isActive).length,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                _buildCountChip(
                  context,
                  label: 'Pending',
                  count: widget.userRules.where((r) => r.isPending).length,
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                _buildCountChip(
                  context,
                  label: 'Owned',
                  count: widget.suppliers.length,
                  color: Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountChip(
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

  Widget _buildFloatingActionButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FloatingActionButton(
      onPressed: _addNewBusiness,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.add_business_rounded, size: 24),
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
