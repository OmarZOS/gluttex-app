import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gluttex_core/app/ManagementRule.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_localizations/gen_l10n/app_localizations.dart';
import 'package:provider_personnel/personnel_management_screen.dart';

class SupplierCard extends StatelessWidget {
  final ManagementRule? managementRule;
  final Supplier? supplier;
  final VoidCallback? onTap;

  const SupplierCard({
    super.key,
    this.managementRule,
    this.supplier,
    this.onTap,
  });

  // Helper to get supplier name
  String get _supplierName {
    if (supplier != null) {
      return supplier!.providerName;
    }
    if (managementRule?.productProvider?.productProviderDetails.providerName !=
        null) {
      return managementRule!
          .productProvider!.productProviderDetails.providerName!;
    }
    return 'Unknown Supplier';
  }

  // Helper to get supplier ID
  int get _supplierId {
    if (supplier != null) {
      return supplier!.idProductProvider;
    }
    if (managementRule?.productProvider?.idProductProvider != null) {
      return managementRule!.productProvider!.idProductProvider;
    }
    return 0;
  }

  // Helper to get organisation ID
  int get _orgId {
    if (supplier != null) {
      return supplier!.idProviderOrganisation;
    }
    if (managementRule?.productProvider?.productProviderOrgId != null) {
      return managementRule!.productProvider!.productProviderOrgId;
    }
    return 0;
  }

  // Helper to get provider type ID
  int get _providerTypeId {
    if (supplier != null) {
      return supplier!.productProviderTypeId;
    }
    if (managementRule?.productProvider?.productProviderTypeId != null) {
      return managementRule!.productProvider!.productProviderTypeId;
    }
    return 0;
  }

  // Helper to get contact info
  String get _contactInfo {
    if (supplier?.locationName != null && supplier!.locationName!.isNotEmpty) {
      return supplier!.locationName!;
    }
    if (managementRule
            ?.productProvider?.productProviderDetails.providerContactInfo !=
        null) {
      return managementRule!
          .productProvider!.productProviderDetails.providerContactInfo!;
    }
    return '';
  }

  // Helper to get status
  bool get _isActive {
    if (managementRule != null) {
      return managementRule!.isActive;
    }
    return true; // Owned suppliers are always active
  }

  bool get _isPending {
    if (managementRule != null) {
      return managementRule!.isPending;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // Validate that we have either a management rule or a supplier
    if (managementRule == null && supplier == null) {
      return const SizedBox.shrink();
    }

    // If we have a supplier but no rule, use the supplier data
    // If we have a rule, use the rule data
    final hasValidData = (supplier != null) ||
        (managementRule?.productProvider != null &&
            managementRule!.productProvider!.productProviderDetails != null);

    if (!hasValidData) {
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

    return Stack(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: _isActive
                ? colorScheme.primaryContainer
                : colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: _providerTypeId == 0
              ? Icon(
                  _getCategoryIcon(_providerTypeId),
                  color: _isActive
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                  size: 28,
                )
              : SvgPicture.asset(
                  'assets/icons/${_providerTypeId + 1}.svg',
                  package: "provider_geo",
                  width: 20,
                  height: 20,
                  color: _isActive
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
                ),
        ),
        // Status indicator dot
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: _isActive ? Colors.green : Colors.orange,
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.surface,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSupplierInfo(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localizations = AppLocalizations.of(context)!;
    final categories = localizations.providerCategoryTextList.split(",");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Supplier Name
        Text(
          _supplierName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 4),

        // Contact/Location Info
        if (_contactInfo.isNotEmpty)
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
                  _contactInfo,
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
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _getStatusText(context),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: _getStatusColor(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Category Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _providerTypeId < categories.length
                    ? categories[_providerTypeId]
                    : 'General',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
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
          color: _isActive
              ? colorScheme.primaryContainer
              : colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          _isActive ? Icons.people_alt_rounded : Icons.pending_actions_rounded,
          color: _isActive
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSurfaceVariant,
          size: 20,
        ),
      ),
    );
  }

  Color _getStatusColor(BuildContext context) {
    final theme = Theme.of(context);

    if (_isActive) {
      return theme.colorScheme.primary;
    } else if (_isPending) {
      return theme.colorScheme.secondary;
    } else {
      return theme.colorScheme.error;
    }
  }

  String _getStatusText(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    if (_isActive) {
      return localizations.activeStatus ?? 'Active';
    } else if (_isPending) {
      return localizations.pendingStatus ?? 'Pending';
    } else {
      return localizations.status_inactive ?? 'Inactive';
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
    final id = _supplierId;
    final orgId = _orgId;

    if (id == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot navigate: Invalid supplier ID'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonnelManagementScreen(
          supplierName: _supplierName,
          orgId: orgId,
          supplierId: id,
        ),
      ),
    );
  }
}
