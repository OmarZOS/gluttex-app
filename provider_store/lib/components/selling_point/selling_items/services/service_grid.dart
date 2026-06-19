import 'package:flutter/material.dart';
import 'package:gluttex_core/business/finance/ProvidedService.dart';
import 'package:event/cart_change_notifier.dart';
import 'package:provider_store/components/selling_point/selling_items/item_card_with_controls.dart';

class ServiceGrid extends StatelessWidget {
  final List<ProvidedService> services;
  final CartChangeNotifier cartNotifier;

  const ServiceGrid({
    super.key,
    required this.services,
    required this.cartNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: _getMaxCrossAxisExtent(context),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return ItemCardWithConfiguration(
              item: services[index],
              // cartNotifier: cartNotifier, isProduct: false,
              isProduct: false,
            );
          },
          childCount: services.length,
        ),
      ),
    );
  }

  double _getMaxCrossAxisExtent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > 1200) return 300; // Large desktop
    if (screenWidth > 900) return 280; // Desktop
    if (screenWidth > 600) return 250; // Tablet
    return screenWidth * 0.8; // Mobile - 80% of screen width
  }
}
