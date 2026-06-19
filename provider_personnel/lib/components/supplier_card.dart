import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gluttex_core/app/ManagementRule.dart';
import 'package:gluttex_localizations/gen_l10n/app_localizations.dart';
import 'package:provider_personnel/personnel_management_screen.dart';

class SupplierCard extends StatelessWidget {
  final ManagementRule managementRule;
  final VoidCallback? onTap;

  const SupplierCard({
    super.key,
    required this.managementRule,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final productProvider = managementRule.productProvider;
    final providerDetails = productProvider?.product_provider_details;

    if (productProvider == null || providerDetails == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap ?? () => _navigateToPersonnelManagement(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Supplier Logo/Status
              _buildSupplierLogo(context),
              const SizedBox(width: 16),

              // Supplier Info
              Expanded(child: _buildSupplierInfo(context)),

              // Action Button
              _buildActionButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupplierLogo(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final productProvider = managementRule.productProvider!;

    return Stack(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: productProvider.product_provider_type_id == 0
              ? Icon(
                  _getCategoryIcon(productProvider.product_provider_type_id),
                  color: colorScheme.onPrimaryContainer,
                  size: 28,
                )
              : SvgPicture.asset(
                  'assets/icons/${productProvider.product_provider_type_id + 1}.svg',
                  package: "provider_geo",
                  width: 20,
                  height: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
        ),

        // Status Badge
      ],
    );
  }

  Widget _buildSupplierInfo(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final providerDetails =
        managementRule.productProvider!.product_provider_details;
    final localizations = AppLocalizations.of(context)!;
    final categories = localizations.providerCategoryTextList.split(",");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Supplier Name
        Text(
          providerDetails.provider_name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 4),

        // Contact/Location Info
        if (providerDetails.provider_contact_info.isNotEmpty)
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  providerDetails.provider_contact_info,
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

        // Status and Category Row
        Row(
          children: [
            // Category Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                categories[
                    managementRule.productProvider!.product_provider_type_id],
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const Spacer(),

            // Privilege Indicator
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      onPressed: () => _navigateToPersonnelManagement(context),
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: managementRule.isActiveStatus
              ? colorScheme.primaryContainer
              : colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          managementRule.isActiveStatus
              ? Icons.people_alt_rounded
              : Icons.pending_actions_rounded,
          color: managementRule.isActiveStatus
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSurfaceVariant,
          size: 20,
        ),
      ),
    );
  }

  Color _getStatusColor(BuildContext context) {
    final theme = Theme.of(context);

    if (managementRule.isActiveStatus) {
      return theme.colorScheme.primary;
    } else if (managementRule.isPending) {
      return theme.colorScheme.secondary;
    } else if (managementRule.isRejected) {
      return theme.colorScheme.error;
    } else {
      return theme.colorScheme.onSurfaceVariant;
    }
  }

  IconData _getCategoryIcon(int categoryId) {
    const icons = [
      Icons.restaurant_rounded,
      Icons.store_rounded,
      Icons.local_offer_rounded,
      Icons.build_rounded,
      Icons.medical_services_rounded,
      Icons.school_rounded,
      Icons.home_work_rounded,
      Icons.business_rounded,
    ];
    return icons[categoryId % icons.length];
  }

  void _navigateToPersonnelManagement(BuildContext context) {
    final productProvider = managementRule.productProvider;
    if (productProvider == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonnelManagementScreen(
          supplierName: productProvider.product_provider_details.provider_name,
          orgId: productProvider.product_provider_org_id,
          supplierId: productProvider.id_product_provider,
        ),
      ),
    );
  }
}
