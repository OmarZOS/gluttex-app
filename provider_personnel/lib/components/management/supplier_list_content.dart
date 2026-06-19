import 'package:flutter/material.dart';
import 'package:gluttex_core/app/ManagementRule.dart';
import 'package:event/personnel_notifier.dart';
import 'package:provider_personnel/components/supplier_card.dart';
import 'package:provider_personnel/components/management/supplier_empty_state.dart';
import 'package:provider_personnel/components/management/supplier_loading_shimmer.dart';
import 'package:provider/provider.dart';

class SupplierListContent extends StatelessWidget {
  final String searchQuery;
  final int? selectedCategoryId;
  final int userId;
  final bool showActiveOnly; // Show only active suppliers
  final bool showPendingOnly; // Show only pending suppliers

  const SupplierListContent({
    super.key,
    required this.searchQuery,
    this.selectedCategoryId,
    required this.userId,
    this.showActiveOnly = false,
    this.showPendingOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PersonnelNotifier>(
      builder: (context, notifier, child) {
        // Get all management rules for this user
        final allRules = notifier.getRulesForUser(userId);

        if (notifier.isLoading && allRules.isEmpty) {
          return const SliverToBoxAdapter(child: SupplierLoadingShimmer());
        }

        // Filter rules based on status flags
        List<ManagementRule> filteredRules = allRules;

        if (showActiveOnly) {
          filteredRules = filteredRules
              .where((rule) => rule.isActiveStatus && !rule.isPending)
              .toList();
        } else if (showPendingOnly) {
          filteredRules =
              filteredRules.where((rule) => rule.isPending).toList();
        }

        // Apply search and category filters
        final displayRules = filteredRules.where(_filterRule).toList();

        if (displayRules.isEmpty) {
          return SliverToBoxAdapter(
            child: SupplierEmptyState(
              searchQuery: searchQuery,
              // hasRules: allRules.isNotEmpty,
              // isFiltered: filteredRules.length != allRules.length,
              // showPendingOnly: showPendingOnly,
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: SupplierCard(managementRule: displayRules[index]),
            ),
            childCount: displayRules.length,
          ),
        );
      },
    );
  }

  bool _filterRule(ManagementRule rule) {
    final productProvider = rule.productProvider;
    final providerDetails = productProvider?.product_provider_details;

    if (productProvider == null || providerDetails == null) {
      return false; // Skip rules without provider info
    }

    // Search filter
    final matchesSearch = searchQuery.isEmpty ||
            providerDetails.provider_name
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            rule.providerOrganisation!.provider_organisation_desc
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ??
        false;

    // Category filter
    final matchesCategory = selectedCategoryId == null ||
        selectedCategoryId == 0 || // "All" category
        productProvider.product_provider_type_id == selectedCategoryId;

    return matchesSearch && matchesCategory;
  }
}
