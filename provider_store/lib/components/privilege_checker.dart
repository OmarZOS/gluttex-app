import 'package:flutter/material.dart';
import 'package:event/personnel_notifier.dart';
import 'package:event/user_change_notifier.dart';
import 'package:provider/provider.dart';

class PrivilegeChecker extends StatelessWidget {
  final int supplierId;
  final int requiredPrivilege; // 0x01 for inventory, 0x02 for orders
  final Widget child;
  final Widget? noAccessChild;

  const PrivilegeChecker({
    super.key,
    required this.supplierId,
    required this.requiredPrivilege,
    required this.child,
    this.noAccessChild,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppUserNotifier, PersonnelNotifier>(
      builder: (context, userNotifier, personnelNotifier, _) {
        final currentUser = userNotifier.appUser;
        if (currentUser == null) {
          return noAccessChild ?? const SizedBox();
        }

        final userRules = personnelNotifier
            .getRulesForUser(currentUser.idAppUser ?? 0)
            .where((r) => r.isActiveStatus)
            .toList();

        final hasAccess = userRules.any((rule) =>
            rule.productProvider?.id_product_provider == supplierId &&
            (rule.management_rule_code & requiredPrivilege) != 0);

        if (!hasAccess) {
          return noAccessChild ?? _buildNoAccessWidget(context);
        }

        return child;
      },
    );
  }

  Widget _buildNoAccessWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock, size: 64),
          const SizedBox(height: 16),
          Text(
            'Access Denied',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'You don\'t have the required privileges',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Convenience widgets
class InventoryAccess extends StatelessWidget {
  final int supplierId;
  final Widget child;
  final Widget? noAccessChild;

  const InventoryAccess({
    super.key,
    required this.supplierId,
    required this.child,
    this.noAccessChild,
  });

  @override
  Widget build(BuildContext context) {
    return PrivilegeChecker(
      supplierId: supplierId,
      requiredPrivilege: 0x01,
      child: child,
      noAccessChild: noAccessChild,
    );
  }
}

class OrderAccess extends StatelessWidget {
  final int supplierId;
  final Widget child;
  final Widget? noAccessChild;

  const OrderAccess({
    super.key,
    required this.supplierId,
    required this.child,
    this.noAccessChild,
  });

  @override
  Widget build(BuildContext context) {
    return PrivilegeChecker(
      supplierId: supplierId,
      requiredPrivilege: 0x02,
      child: child,
      noAccessChild: noAccessChild,
    );
  }
}
