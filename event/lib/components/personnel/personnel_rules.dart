import 'package:app_constants/app_constants.dart';
import 'package:gluttex_core/app/ManagementRule.dart';
import 'package:gluttex_core/business/privileges/role_bit_mapper.dart';
import 'personnel_cache.dart';
import 'personnel_state.dart';
import 'personnel_persistence.dart';

class PersonnelRules {
  final PersonnelCache _cache;
  final PersonnelState _state;
  final PersonnelPersistence _persistence;

  PersonnelRules({
    required PersonnelCache cache,
    required PersonnelState state,
    required PersonnelPersistence persistence,
  })  : _cache = cache,
        _state = state,
        _persistence = persistence;

  List<ManagementRule> getRulesForUser(int userId, {int supplierId = 0}) {
    final rules = _cache.getActiveRules(userId);
    if (rules == null) return const [];
    if (supplierId == 0) return List.from(rules);

    return rules
        .where(
            (rule) => rule.productProvider?.id_product_provider == supplierId)
        .toList();
  }

  List<ManagementRule> getPendingRulesForUser(int userId,
      {int supplierId = 0}) {
    final rules = _cache.getPendingRules(userId);
    if (rules == null) return const [];
    if (supplierId == 0) return List.from(rules);

    return rules
        .where(
            (rule) => rule.productProvider?.id_product_provider == supplierId)
        .toList();
  }

  bool hasPrivilege(int userId, int supplierId, String privilegeId) {
    final rules = getRulesForUser(userId, supplierId: supplierId);
    return rules.any((rule) => RoleBitMapper.hasPrivilege(
        rule.management_rule_code ?? 0, privilegeId));
  }

  bool hasAnyAccessToSupplier(int userId, int supplierId) {
    final rules = getRulesForUser(userId, supplierId: supplierId);
    return rules.isNotEmpty;
  }

  bool hasPendingRulesForSupplier(int userId, int supplierId) {
    final rules = _cache.getPendingRules(userId);
    if (rules == null) return false;
    return rules
        .any((rule) => rule.productProvider?.id_product_provider == supplierId);
  }

  ManagementRule? getRuleForUser({
    required int userId,
    int ruleId = 0,
    int supplierId = 0,
  }) {
    final rules = _cache.getPrivileges(userId);
    if (rules == null) return null;

    return rules.firstWhere(
      (rule) {
        final matchesRuleId = ruleId == 0 || rule.id_management_rule == ruleId;
        final matchesSupplier = supplierId == 0 ||
            rule.productProvider?.id_product_provider == supplierId;
        return matchesRuleId && matchesSupplier;
      },
    );
  }

  void syncRuleState(ManagementRule updatedRule) {
    final ruleId = updatedRule.id_management_rule;
    final userId = updatedRule.appUser?.idAppUser;
    if (ruleId == null || userId == null) return;
    if (_state.isRebuildingState) return;

    _state.isRebuildingState = true;

    try {
      final privileges = _cache.privileges[userId] ?? [];
      int existingIndex = -1;

      for (int i = 0; i < privileges.length; i++) {
        if (privileges[i].id_management_rule == ruleId) {
          existingIndex = i;
          break;
        }
      }

      if (existingIndex >= 0) {
        privileges[existingIndex] = updatedRule;
      } else {
        privileges.add(updatedRule);
      }

      _cache.cachePrivileges(userId, privileges);
      _rebuildUserState(userId);
    } finally {
      _state.isRebuildingState = false;
    }
  }

  void _rebuildUserState(int userId) {
    final rules = _cache.getPrivileges(userId);
    if (rules == null) {
      _cache.pendingRules.remove(userId);
      _cache.activeRules.remove(userId);
      _cache.userSupplierMappings.remove(userId);
      return;
    }

    final pending = <ManagementRule>[];
    final active = <ManagementRule>[];
    final userSuppliers = <int>{};

    for (final rule in rules) {
      final providerId = rule.productProvider?.id_product_provider;
      final isPending =
          (rule.ruleStatus ?? "").toUpperCase() == RuleStates.pending;

      if (isPending) {
        pending.add(rule);
      } else {
        active.add(rule);
        if (providerId != null && providerId > 0) {
          userSuppliers.add(providerId);
          _cache.addSupplierMapping(userId, providerId);
          _persistence.addSupplier(userId, providerId);
        }
      }
    }

    _cache.cachePendingRules(userId, pending);
    _cache.cacheActiveRules(userId, active);
    _cache.userSupplierMappings[userId] = userSuppliers.toList();
  }

  Map<String, int> getSupplierStats(int supplierId) {
    final userIds = _cache.getActiveUserIdsForSupplier(supplierId);
    int admins = 0;
    int managers = 0;

    for (final userId in userIds) {
      final user = _cache.getUser(userId);
      if (user != null) {
        if (user.isAdmin) {
          admins++;
        } else if (user.appUserType?.toString().contains('manager') ?? false) {
          managers++;
        }
      }
    }

    final pendingUsers = _cache.pendingRules.keys
        .where((userId) =>
            _cache.pendingRules[userId]?.any((rule) =>
                rule.productProvider?.id_product_provider == supplierId) ??
            false)
        .length;

    return {
      'active': userIds.length,
      'pending': pendingUsers,
      'admins': admins,
      'managers': managers,
      'total': userIds.length + pendingUsers,
    };
  }
}
