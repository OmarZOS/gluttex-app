import 'package:flutter/material.dart';
import 'package:gluttex_core/business/Supplier.dart';
import 'package:gluttex_event/personnel_notifier.dart';
import 'package:gluttex_personnel/personnel_management_screen.dart';
import 'package:provider/provider.dart';

class SupplierCard extends StatelessWidget {
  final Supplier supplier;

  const SupplierCard({
    super.key,
    required this.supplier,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      child: InkWell(
        onTap: () => _navigateToPersonnelManagement(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSupplierImage(context),
              const SizedBox(width: 12),
              Expanded(
                child: Consumer<PersonnelNotifier>(
                  builder: (context, personnelNotifier, child) {
                    final stats = personnelNotifier
                        .getSupplierStats(supplier.idProductProvider);
                    return _buildSupplierInfo(context, stats);
                  },
                ),
              ),
              _buildSupplierActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupplierImage(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
              color: Colors.green, // TODO: Use actual status color
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
              'ACTIVE', // TODO: Use actual status text
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

  Widget _buildSupplierInfo(BuildContext context, Map<String, int> stats) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final activeCount = stats['active'] ?? 0;
    final pendingCount = stats['pending'] ?? 0;

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
                ],
              ),
            ),
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
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            _buildInfoChip(
              icon: Icons.people_alt_rounded,
              value: '$activeCount',
              label: 'Team',
              color: colorScheme.primary,
              theme: theme,
            ),
            if (pendingCount > 0)
              _buildInfoChip(
                icon: Icons.pending_actions_rounded,
                value: '$pendingCount',
                label: 'Pending',
                color: Colors.orange,
                theme: theme,
              ),
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

  Widget _buildSupplierActions(BuildContext context) {
    return Consumer<PersonnelNotifier>(
      builder: (context, personnelNotifier, child) {
        final activeCount = personnelNotifier
                .getSupplierStats(supplier.idProductProvider)['active'] ??
            0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _navigateToPersonnelManagement(context),
              icon: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.people_alt_rounded,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        size: 18),
                  ),
                  if (activeCount > 0)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.surface,
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
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToPersonnelManagement(BuildContext context) {
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
