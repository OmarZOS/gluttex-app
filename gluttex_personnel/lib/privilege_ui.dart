import 'package:flutter/material.dart';
import 'package:gluttex_constants/gen_l10n/app_localizations.dart';

class PrivilegeUI {
  final String id;
  final IconData icon;
  final String Function(BuildContext) title;
  final String Function(BuildContext) description;
  final String Function(BuildContext) roleName;
  final String category;

  const PrivilegeUI({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
    required this.roleName,
    required this.category,
  });

  // Helper method to get localized title
  String getTitle(BuildContext context) => title(context);

  String getRoleName(BuildContext context) => roleName(context);

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
      roleName: (context) => AppLocalizations.of(context)!.roleStaff, // NEW
      category: 'Inventory Management',
    ),
    PrivilegeUI(
      id: 'inventory_manage',
      icon: Icons.inventory,
      title: (context) => AppLocalizations.of(context)!.inventory_manage_title,
      description: (context) =>
          AppLocalizations.of(context)!.inventory_manage_description,
      roleName: (context) => AppLocalizations.of(context)!.roleManager, // NEW
      category: 'Inventory Management',
    ),
    PrivilegeUI(
      id: 'orders_view',
      icon: Icons.shopping_cart,
      title: (context) => AppLocalizations.of(context)!.orders_view_title,
      description: (context) =>
          AppLocalizations.of(context)!.orders_view_description,
      roleName: (context) => AppLocalizations.of(context)!.roleViewer, // NEW
      category: 'Order Management',
    ),
    PrivilegeUI(
      id: 'orders_manage',
      icon: Icons.receipt_long,
      title: (context) => AppLocalizations.of(context)!.orders_manage_title,
      description: (context) =>
          AppLocalizations.of(context)!.orders_manage_description,
      roleName: (context) => AppLocalizations.of(context)!.roleManager, // NEW
      category: 'Order Management',
    ),
    PrivilegeUI(
      id: 'personnel_view',
      icon: Icons.people,
      title: (context) => AppLocalizations.of(context)!.personnel_view_title,
      description: (context) =>
          AppLocalizations.of(context)!.personnel_view_description,
      roleName: (context) =>
          AppLocalizations.of(context)!.roleSupervisor, // NEW
      category: 'Personnel Management',
    ),
    PrivilegeUI(
      id: 'personnel_manage',
      icon: Icons.manage_accounts,
      title: (context) => AppLocalizations.of(context)!.personnel_manage_title,
      description: (context) =>
          AppLocalizations.of(context)!.personnel_manage_description,
      roleName: (context) => AppLocalizations.of(context)!.roleAdmin, // NEW
      category: 'Personnel Management',
    ),
  ];

  static String localizeCategory(BuildContext context, String categoryId) {
    final l = AppLocalizations.of(context)!;

    switch (categoryId) {
      case 'inventory_management':
        return l.category_inventory;
      case 'order_management':
        return l.category_orders;
      case 'personnel_management':
        return l.category_personnel;
      default:
        return categoryId;
    }
  }

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

  static List<String> getOptimizedPrivilegeIds(List<String> privilegeIds) {
    final optimized = List<String>.from(privilegeIds);

    // Remove redundant view privileges when manage privilege exists
    if (optimized.contains('inventory_manage') &&
        optimized.contains('inventory_view')) {
      optimized.remove('inventory_view');
    }

    if (optimized.contains('orders_manage') &&
        optimized.contains('orders_view')) {
      optimized.remove('orders_view');
    }

    if (optimized.contains('personnel_manage') &&
        optimized.contains('personnel_view')) {
      optimized.remove('personnel_view');
    }

    return optimized;
  }

  /// Get an optimized list of PrivilegeUI objects
  static List<PrivilegeUI> getOptimizedPrivileges(List<String> privilegeIds) {
    final optimizedIds = getOptimizedPrivilegeIds(privilegeIds);
    return optimizedIds
        .map((id) => getPrivilege(id))
        .whereType<PrivilegeUI>()
        .toList();
  }

  /// Get a very brief summary (e.g., "Full Access", "Limited Access", "View Only")
  static String getAccessLevelSummary(
    List<String> privilegeIds, {
    required BuildContext context,
  }) {
    final optimized = getOptimizedPrivilegeIds(privilegeIds);

    if (optimized.isEmpty) {
      return AppLocalizations.of(context)!.roleNoPrivileges;
    }

    // Check for full access (has all manage privileges)
    final hasAllManage = optimized.contains('inventory_manage') &&
        optimized.contains('orders_manage') &&
        optimized.contains('personnel_manage');

    if (hasAllManage) {
      return AppLocalizations.of(context)!.roleAdmin;
    }

    // Check for manager access (has at least one manage privilege)
    final hasManageAccess = optimized.any((id) => id.endsWith('_manage'));
    if (hasManageAccess) {
      return AppLocalizations.of(context)!.roleManager;
    }

    // Check for view access (has at least one view privilege)
    final hasViewAccess = optimized.any((id) => id.endsWith('_view'));
    if (hasViewAccess) {
      return AppLocalizations.of(context)!.roleViewer;
    }

    return AppLocalizations.of(context)!.roleStaff;
  }

  /// Get icons for the optimized privilege set
  static List<IconData> getOptimizedIcons(List<String> privilegeIds) {
    final optimized = getOptimizedPrivilegeIds(privilegeIds);
    return optimized
        .map((id) => getPrivilege(id))
        .whereType<PrivilegeUI>()
        .map((privilege) => privilege.icon)
        .toList();
  }

  /// Get the highest role/privilege for display (most significant one)
  static String? getHighestRole(
    List<String> privilegeIds, {
    required BuildContext context,
  }) {
    if (privilegeIds.isEmpty) return null;

    final optimized = getOptimizedPrivilegeIds(privilegeIds);

    // Define privilege hierarchy (from highest to lowest)
    const hierarchy = [
      'personnel_manage', // Admin level
      'orders_manage', // Manager level
      'inventory_manage', // Manager level
      'personnel_view', // Supervisor level
      'orders_view', // Viewer level
      'inventory_view', // Staff level
    ];

    // Find the highest privilege in the hierarchy
    for (final privilegeId in hierarchy) {
      if (optimized.contains(privilegeId)) {
        final privilege = getPrivilege(privilegeId);
        return privilege?.getRoleName(context);
      }
    }

    return null;
  }

  // Get all categories
  static List<String> getCategories() {
    return allPrivileges.map((e) => e.category).toSet().toList();
  }
}
