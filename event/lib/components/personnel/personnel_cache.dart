import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/app/ManagementRule.dart';

class PersonnelCache {
  final Map<int, AppUser> users = {};
  final Map<int, List<ManagementRule>> privileges = {};
  final Map<int, List<ManagementRule>> pendingRules = {};
  final Map<int, List<ManagementRule>> activeRules = {};
  final Map<int, List<int>> userSupplierMappings = {};
  final Map<int, List<int>> supplierPersonnelMappings = {};

  void clearAll() {
    users.clear();
    privileges.clear();
    pendingRules.clear();
    activeRules.clear();
    userSupplierMappings.clear();
    supplierPersonnelMappings.clear();
  }

  void cacheUser(AppUser user) {
    if (user.idAppUser != null) {
      users[user.idAppUser!] = user;
    }
  }

  AppUser? getUser(int userId) {
    return users[userId];
  }

  void cachePrivileges(int userId, List<ManagementRule> rules) {
    privileges[userId] = rules;
  }

  List<ManagementRule>? getPrivileges(int userId) {
    return privileges[userId];
  }

  void cachePendingRules(int userId, List<ManagementRule> rules) {
    pendingRules[userId] = rules;
  }

  List<ManagementRule>? getPendingRules(int userId) {
    return pendingRules[userId];
  }

  void cacheActiveRules(int userId, List<ManagementRule> rules) {
    activeRules[userId] = rules;
  }

  List<ManagementRule>? getActiveRules(int userId) {
    return activeRules[userId];
  }

  void addSupplierMapping(int userId, int supplierId) {
    final mappings = userSupplierMappings[userId] ?? [];
    if (!mappings.contains(supplierId)) {
      mappings.add(supplierId);
      userSupplierMappings[userId] = mappings;
    }

    final personnel = supplierPersonnelMappings[supplierId] ?? [];
    if (!personnel.contains(userId)) {
      personnel.add(userId);
      supplierPersonnelMappings[supplierId] = personnel;
    }
  }

  void removeSupplierMapping(int userId, int supplierId) {
    userSupplierMappings[userId]?.remove(supplierId);
    if (userSupplierMappings[userId]?.isEmpty ?? false) {
      userSupplierMappings.remove(userId);
    }

    supplierPersonnelMappings[supplierId]?.remove(userId);
    if (supplierPersonnelMappings[supplierId]?.isEmpty ?? false) {
      supplierPersonnelMappings.remove(supplierId);
    }
  }

  List<int> getActiveUserIdsForSupplier(int supplierId) {
    return supplierPersonnelMappings[supplierId] ?? [];
  }

  List<int> getSupplierIdsForUser(int userId) {
    return userSupplierMappings[userId] ?? [];
  }

  void invalidateUser(int userId) {
    users.remove(userId);
    privileges.remove(userId);
    pendingRules.remove(userId);
    activeRules.remove(userId);
    userSupplierMappings.remove(userId);
  }

  Map<String, int> getStats() {
    return {
      'users': users.length,
      'privileges': privileges.length,
      'pendingRules': pendingRules.length,
      'activeRules': activeRules.length,
      'supplierMappings': supplierPersonnelMappings.length,
    };
  }
}
