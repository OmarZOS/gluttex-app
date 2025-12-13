import 'package:flutter/material.dart';
import 'package:gluttex_core/business/finance/ProvidedService.dart';

class ServiceCard extends StatelessWidget {
  final ProvidedService service;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.service,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.08),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          highlightColor: colorScheme.primary.withOpacity(0.1),
          splashColor: colorScheme.primary.withOpacity(0.2),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Icon Container
                Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary.withOpacity(0.1),
                        colorScheme.secondary.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getServiceIcon(service),
                        size: 24,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Service Name
                Flexible(
                  child: Text(
                    service.name?.isNotEmpty == true
                        ? service.name!
                        : 'Service',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),

                // Service Category/Tag
                if (service.categoryId == true)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        service.categoryId.toString(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                const Spacer(),

                // Price Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Price',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '\$${service.finalPrice?.toStringAsFixed(2) ?? '0.00'}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.primary,
                            fontSize: 24,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),

                    // Duration if available
                    if (service.actualDuration != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 12,
                              color: colorScheme.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${service.durationFormatted} min',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getServiceIcon(ProvidedService service) {
    final category = service.categoryId ?? '';

    // if (category.contains('repair') || category.contains('fix')) {
    //   return Icons.build_rounded;
    // } else if (category.contains('consult') || category.contains('advice')) {
    //   return Icons.lightbulb_rounded;
    // } else if (category.contains('install') || category.contains('setup')) {
    //   return Icons.settings_rounded;
    // } else if (category.contains('delivery') || category.contains('shipping')) {
    //   return Icons.local_shipping_rounded;
    // } else if (category.contains('clean') || category.contains('maintain')) {
    //   return Icons.cleaning_services_rounded;
    // } else if (category.contains('design') || category.contains('create')) {
    //   return Icons.design_services_rounded;
    // } else if (category.contains('train') || category.contains('teach')) {
    //   return Icons.school_rounded;
    // } else if (category.contains('health') || category.contains('medical')) {
    //   return Icons.medical_services_rounded;
    // } else if (category.contains('tech') || category.contains('it')) {
    //   return Icons.computer_rounded;
    // }

    return Icons.handyman_rounded;
  }
}
