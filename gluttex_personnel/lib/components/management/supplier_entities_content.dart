import 'package:flutter/material.dart';
import 'package:gluttex_core/app/ManagementRule.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';
import 'package:gluttex_event/personnel_notifier.dart';
import 'package:gluttex_event/supplier_change_notifier.dart';
import 'package:gluttex_event/user_change_notifier.dart';
import 'package:gluttex_personnel/components/supplier_card.dart';
import 'package:gluttex_personnel/personnel_management_screen.dart';
import 'package:gluttex_ui/components/supplier/supplier_screen.dart';
import 'package:provider/provider.dart';
import 'supplier_entities_controller.dart';

class SupplierEntitiesContent extends StatefulWidget {
  final SupplierEntitiesController controller;
  final SupplierEntitiesState state;

  const SupplierEntitiesContent({
    super.key,
    required this.controller,
    required this.state,
  });

  @override
  State<SupplierEntitiesContent> createState() =>
      _SupplierEntitiesContentState();
}

class _SupplierEntitiesContentState extends State<SupplierEntitiesContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Consumer3<SupplierChangeNotifier, PersonnelNotifier,
        AppUserNotifier>(
      builder: (context, supplierNotifier, personnelNotifier, userNotifier, _) {
        final userId = userNotifier.appUser?.id_app_user;
        if (userId == null) return const SliverFillRemaining(child: SizedBox());

        final ownedSuppliers = widget.controller.filterOwnedSuppliers(
          supplierNotifier.suppliers
              .where((s) => s.productProviderOwnerId == userId)
              .toList(),
          widget.state.searchQuery,
          widget.state.selectedCategoryId,
        );

        final managedRules = widget.controller.filterManagedRules(
          personnelNotifier
              .getRulesForUser(userId)
              .where((r) => r.isActiveStatus)
              .toList(),
          widget.state.searchQuery,
          widget.state.selectedCategoryId,
        );

        if (ownedSuppliers.isEmpty && managedRules.isEmpty) {
          return _buildEmptyState(context, localizations);
        }

        return SliverFillRemaining(
          child: Column(
            children: [
              _buildTabBar(
                  context, ownedSuppliers, managedRules, localizations),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTabContent(
                      context,
                      ownedSuppliers,
                      isOwned: true,
                      localizations: localizations,
                    ),
                    _buildTabContent(
                      context,
                      managedRules,
                      isOwned: false,
                      localizations: localizations,
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

  Widget _buildTabBar(
    BuildContext context,
    List<Supplier> ownedSuppliers,
    List<ManagementRule> managedRules,
    AppLocalizations localizations,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: colorScheme.primary,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        labelColor: colorScheme.onPrimary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        labelStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.business_rounded, size: 18),
                const SizedBox(width: 6),
                Text('${localizations.ownedText} (${ownedSuppliers.length})'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.people_alt_rounded, size: 18),
                const SizedBox(width: 6),
                Text('${localizations.managedText} (${managedRules.length})'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(
    BuildContext context,
    List<dynamic> items, {
    required bool isOwned,
    required AppLocalizations localizations,
  }) {
    if (items.isEmpty) {
      return _buildEmptyTab(context, isOwned, localizations);
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return isOwned
            ? _buildOwnedSupplierCard(context, items[index] as Supplier)
            : SupplierCard(managementRule: items[index] as ManagementRule);
      },
    );
  }

  Widget _buildOwnedSupplierCard(BuildContext context, Supplier supplier) {
    final rule = ManagementRule(
      id_management_rule: -1,
      management_rule_code: 0xFF,
      productProvider: _createProductProvider(supplier),
      ruleStatus: 'ACTIVE',
      isActive: true,
    );

    return SupplierCard(
      managementRule: rule,
      onTap: () => showSupplierDetails(context, supplier),
    );
  }

  ProductProvider _createProductProvider(Supplier supplier) {
    return ProductProvider(
      product_provider_type_id: supplier.productProviderTypeId,
      product_provider_location_id: supplier.id_location ?? 0,
      product_provider_org_id: supplier.id_provider_organisation,
      id_product_provider: supplier.idProductProvider,
      product_provider_details_id: supplier.idProductProvider,
      product_provider_owner: supplier.productProviderOwnerId,
      product_provider_details: ProductProviderDetails(
        provider_name: supplier.providerName,
        idprovider_details_id: supplier.idProductProvider,
        provider_contact_info: supplier.locationName ?? '',
      ),
    );
  }

  Widget _buildEmptyTab(
    BuildContext context,
    bool isOwned,
    AppLocalizations localizations,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isOwned ? Icons.business_outlined : Icons.people_outline,
              size: 64,
              color: colorScheme.onSurfaceVariant.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              isOwned
                  ? localizations.noOwnedBusinessesTitle
                  : localizations.noManagedBusinessesTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isOwned
                  ? localizations.noOwnedBusinessesDescription
                  : localizations.noManagedBusinessesDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.business,
                size: 64,
                color: colorScheme.onSurfaceVariant.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                widget.state.searchQuery.isEmpty
                    ? localizations.noBusinessesTitle
                    : localizations.noResultsTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.state.searchQuery.isEmpty
                    ? localizations.noBusinessesDescription
                    : localizations.adjustSearchFiltersText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
