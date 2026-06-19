import 'package:flutter/material.dart';
import 'package:gluttex_localizations/gen_l10n/app_localizations.dart';
import 'package:gluttex_core/business/finance/ProvidedService.dart';
import 'package:event/service_change_notifier.dart';
import 'package:store/components/selling_point/selling_items/item_card_with_controls.dart';
import 'package:provider/provider.dart';
import 'package:event/cart_change_notifier.dart';

class ServiceGridSliver extends StatelessWidget {
  const ServiceGridSliver({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final serviceNotifier = context.watch<ServiceNotifier>();
    final cartNotifier = context.watch<CartChangeNotifier>();
    final services = serviceNotifier.services;
    final isLoading = serviceNotifier.isLoading;

    // Get selected service IDs from cart
    final selectedServiceIds = cartNotifier.serviceItems
        .map((item) => item.service?.id)
        .where((id) => id != null)
        .toSet();

    if (isLoading) {
      return _LoadingState(localizations: localizations);
    }

    if (services.isEmpty) {
      return _EmptyState(localizations: localizations);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with selection count
        _ServicesHeader(selectedCount: selectedServiceIds.length),
        const SizedBox(height: 16),
        _ServicesGrid(
          services: services,
          selectedServiceIds: selectedServiceIds,
        ),
      ],
    );
  }
}

class _ServicesHeader extends StatelessWidget {
  final int selectedCount;

  const _ServicesHeader({required this.selectedCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final localizations = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.08),
            colorScheme.surface,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon with selection count badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.primaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.medical_services_rounded,
                  color: colorScheme.onPrimary,
                  size: 28,
                ),
              ),

              // Selection badge
              if (selectedCount > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiary,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.surface,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      selectedCount.toString(),
                      style: TextStyle(
                        color: colorScheme.onTertiary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.services,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    fontSize: 28,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  selectedCount > 0
                      ? localizations.nServicesSelected(selectedCount)
                      : localizations.browseAndSelectServices,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: selectedCount > 0
                        ? colorScheme.tertiary
                        : colorScheme.onSurfaceVariant,
                    height: 1.4,
                    fontWeight: selectedCount > 0 ? FontWeight.w600 : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServicesGrid extends StatelessWidget {
  final List<ProvidedService> services;
  final Set<int?> selectedServiceIds;

  const _ServicesGrid({
    required this.services,
    required this.selectedServiceIds,
  });

  @override
  Widget build(BuildContext context) {
    final cartNotifier = context.read<CartChangeNotifier>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = 2;
        final spacing = 16.0;
        final padding = 20.0;
        final availableWidth = constraints.maxWidth - (padding * 2);
        final itemWidth =
            (availableWidth - spacing * (crossAxisCount - 1)) / crossAxisCount;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: services.map((service) {
              return SizedBox(
                width: itemWidth,
                child: ItemCardWithConfiguration(
                  item: service,
                  isProduct: false,
                  // cartNotifier: cartNotifier,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

// Enhanced ItemCardWithControls to show quantity badge
class ServiceCardWithBadges extends StatelessWidget {
  final ProvidedService service;
  final CartChangeNotifier cartNotifier;

  const ServiceCardWithBadges({
    super.key,
    required this.service,
    required this.cartNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final cartItem = cartNotifier.getServiceCartItem(service);
    final isInCart = cartItem != null;
    final quantity = cartItem?.quantity ?? 0;
    final loc = AppLocalizations.of(context)!;

    return Stack(
      children: [
        ItemCardWithConfiguration(
          item: service,
          isProduct: false,
          // cartNotifier: cartNotifier,
          // isProduct: false,
        ),

        // Quantity badge if service is in cart
        if (isInCart && quantity > 0)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.tertiary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_cart_checkout,
                    size: 12,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    quantity.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Duration badge
        Positioned(
          bottom: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              service.durationFormatted ?? '0min',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        // Price badge
        Positioned(
          bottom: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade600,
                  Colors.green.shade800,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              loc.price(service.finalPrice.toStringAsFixed(2)),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Alternative: Badge only on selection
class ServiceSelectionBadge extends StatelessWidget {
  final bool isSelected;
  final int? quantity;

  const ServiceSelectionBadge({
    super.key,
    required this.isSelected,
    this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    if (!isSelected) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            size: 14,
            color: Colors.white,
          ),
          if (quantity != null && quantity! > 1) ...[
            const SizedBox(width: 4),
            Text(
              '×$quantity',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(width: 4),
          Text(
            'IN CART',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// Loading and Empty states remain the same
class _LoadingState extends StatelessWidget {
  final AppLocalizations localizations;

  const _LoadingState({required this.localizations});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              color: colorScheme.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            localizations.loadingServices,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.preparingServiceCatalog,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations localizations;

  const _EmptyState({required this.localizations});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withOpacity(0.05),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.1),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.handyman_rounded,
                size: 48,
                color: colorScheme.primary.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              localizations.noServicesAvailable,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                localizations.servicesWillAppearHere,
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                // TODO: Navigate to service creation or refresh
              },
              icon: Icon(
                Icons.refresh_rounded,
                size: 18,
                color: colorScheme.onPrimary,
              ),
              label: Text(
                localizations.refreshServices,
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Update your localization strings:
// Add to your AppLocalizations:
// String get nServicesSelected(int count) => '$count services selected';
// String get inCart => 'IN CART';
// String get selected => 'SELECTED';
