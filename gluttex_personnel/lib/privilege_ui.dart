import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';

class PrivilegeUI {
  final String id;
  final IconData icon;
  final String Function(BuildContext) title;
  final String Function(BuildContext) description;
  final String category;

  const PrivilegeUI({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
    required this.category,
  });

  // Helper method to get localized title
  String getTitle(BuildContext context) => title(context);

  // Helper method to get localized description
  String getDescription(BuildContext context) => description(context);
}

class PrivilegeUIManager {
  static final List<PrivilegeUI> allPrivileges = [
    PrivilegeUI(
      id: 'inventory_view',
      icon: Icons.inventory_2,
      title: (context) => AppLocalizations.of(context)!.inventory_view_title,
      description: (context) =>
          AppLocalizations.of(context)!.inventory_view_description,
      category: 'Inventory Management',
    ),
    PrivilegeUI(
      id: 'inventory_manage',
      icon: Icons.inventory,
      title: (context) => AppLocalizations.of(context)!.inventory_manage_title,
      description: (context) =>
          AppLocalizations.of(context)!.inventory_manage_description,
      category: 'Inventory Management',
    ),
    PrivilegeUI(
      id: 'orders_view',
      icon: Icons.shopping_cart,
      title: (context) => AppLocalizations.of(context)!.orders_view_title,
      description: (context) =>
          AppLocalizations.of(context)!.orders_view_description,
      category: 'Order Management',
    ),
    PrivilegeUI(
      id: 'orders_manage',
      icon: Icons.receipt_long,
      title: (context) => AppLocalizations.of(context)!.orders_manage_title,
      description: (context) =>
          AppLocalizations.of(context)!.orders_manage_description,
      category: 'Order Management',
    ),
    PrivilegeUI(
      id: 'personnel_view',
      icon: Icons.people,
      title: (context) => AppLocalizations.of(context)!.personnel_view_title,
      description: (context) =>
          AppLocalizations.of(context)!.personnel_view_description,
      category: 'Personnel Management',
    ),
    PrivilegeUI(
      id: 'personnel_manage',
      icon: Icons.manage_accounts,
      title: (context) => AppLocalizations.of(context)!.personnel_manage_title,
      description: (context) =>
          AppLocalizations.of(context)!.personnel_manage_description,
      category: 'Personnel Management',
    ),
  ];

  // Get privilege by ID
  static PrivilegeUI? getPrivilege(String id) {
    try {
      return allPrivileges.firstWhere((privilege) => privilege.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get privileges by category
  static Map<String, List<PrivilegeUI>> getPrivilegesByCategory() {
    final categories = <String, List<PrivilegeUI>>{};

    for (final privilege in allPrivileges) {
      if (!categories.containsKey(privilege.category)) {
        categories[privilege.category] = [];
      }
      categories[privilege.category]!.add(privilege);
    }

    return categories;
  }

  // Get all categories
  static List<String> getCategories() {
    return allPrivileges.map((e) => e.category).toSet().toList();
  }
}
