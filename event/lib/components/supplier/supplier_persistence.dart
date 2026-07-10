import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupplierPersistence {
  static const String _KEY_OWNED_SUPPLIERS = 'owned_suppliers';
  static const String _KEY_OWNED_ORGANISATIONS = 'owned_organisations';

  final Map<int, List<int>> _ownedSuppliers = {};
  final Map<int, List<int>> _ownedOrganisations = {};
  int? _currentUserId;

  int get currentUserId => _currentUserId ?? 0;

  List<int> getOwnedSuppliers(int userId) => _ownedSuppliers[userId] ?? [];
  List<int> getOwnedOrganisations(int userId) =>
      _ownedOrganisations[userId] ?? [];

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await _loadOwnedSuppliers(prefs);
      await _loadOwnedOrganisations(prefs);
    } catch (e) {
      debugPrint('❌ Error loading persisted data: $e');
    }
  }

  Future<void> _loadOwnedSuppliers(SharedPreferences prefs) async {
    final stored = prefs.getString(_KEY_OWNED_SUPPLIERS);
    if (stored != null && stored.isNotEmpty) {
      final decoded = jsonDecode(stored) as Map<String, dynamic>;
      _currentUserId = decoded['userId'];
      final suppliers = decoded['suppliers'] as Map<String, dynamic>?;
      if (suppliers != null) {
        _ownedSuppliers.clear();
        suppliers.forEach((userId, ids) {
          _ownedSuppliers[int.parse(userId)] =
              (ids as List).map((e) => int.parse(e.toString())).toList();
        });
      }
      debugPrint('📂 Loaded owned suppliers: ${_ownedSuppliers.length} users');
    }
  }

  Future<void> _loadOwnedOrganisations(SharedPreferences prefs) async {
    final stored = prefs.getString(_KEY_OWNED_ORGANISATIONS);
    if (stored != null && stored.isNotEmpty) {
      final decoded = jsonDecode(stored) as Map<String, dynamic>;
      final orgs = decoded['organisations'] as Map<String, dynamic>?;
      if (orgs != null) {
        _ownedOrganisations.clear();
        orgs.forEach((userId, ids) {
          _ownedOrganisations[int.parse(userId)] =
              (ids as List).map((e) => int.parse(e.toString())).toList();
        });
      }
      debugPrint('📂 Loaded owned orgs: ${_ownedOrganisations.length} users');
    }
  }

  Future<void> saveOwnedSuppliers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'userId': _currentUserId,
        'suppliers': _ownedSuppliers.map(
          (userId, ids) => MapEntry(userId.toString(), ids),
        ),
        'timestamp': DateTime.now().toIso8601String(),
      };
      await prefs.setString(_KEY_OWNED_SUPPLIERS, jsonEncode(data));
      debugPrint('💾 Saved owned suppliers');
    } catch (e) {
      debugPrint('❌ Error saving owned suppliers: $e');
    }
  }

  Future<void> saveOwnedOrganisations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'organisations': _ownedOrganisations.map(
          (userId, ids) => MapEntry(userId.toString(), ids),
        ),
        'timestamp': DateTime.now().toIso8601String(),
      };
      await prefs.setString(_KEY_OWNED_ORGANISATIONS, jsonEncode(data));
      debugPrint('💾 Saved owned organisations');
    } catch (e) {
      debugPrint('❌ Error saving owned organisations: $e');
    }
  }

  Future<void> addSupplier(int userId, int supplierId) async {
    final list = _ownedSuppliers[userId] ?? [];
    if (!list.contains(supplierId)) {
      list.add(supplierId);
      _ownedSuppliers[userId] = list;
      await saveOwnedSuppliers();
    }
  }

  Future<void> removeSupplier(int userId, int supplierId) async {
    final list = _ownedSuppliers[userId];
    if (list != null && list.remove(supplierId)) {
      if (list.isEmpty) {
        _ownedSuppliers.remove(userId);
      } else {
        _ownedSuppliers[userId] = list;
      }
      await saveOwnedSuppliers();
    }
  }

  Future<void> addOrganisation(int userId, int orgId) async {
    final list = _ownedOrganisations[userId] ?? [];
    if (!list.contains(orgId)) {
      list.add(orgId);
      _ownedOrganisations[userId] = list;
      await saveOwnedOrganisations();
    }
  }

  Future<void> removeOrganisation(int userId, int orgId) async {
    final list = _ownedOrganisations[userId];
    if (list != null && list.remove(orgId)) {
      if (list.isEmpty) {
        _ownedOrganisations.remove(userId);
      } else {
        _ownedOrganisations[userId] = list;
      }
      await saveOwnedOrganisations();
    }
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_KEY_OWNED_SUPPLIERS);
    await prefs.remove(_KEY_OWNED_ORGANISATIONS);
    _ownedSuppliers.clear();
    _ownedOrganisations.clear();
    _currentUserId = null;
    debugPrint('🗑️ Cleared all persisted data');
  }

  void setCurrentUser(int userId) {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      load();
    }
  }
}
