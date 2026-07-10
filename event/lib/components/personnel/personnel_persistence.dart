import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonnelPersistence {
  static const String _KEY = 'personnel_accessible_suppliers';

  final Map<int, List<int>> _accessibleSuppliers = {};
  int? _currentUserId;

  List<int> getAccessibleSuppliers(int userId) {
    return _accessibleSuppliers[userId] ?? [];
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString(_KEY);
      if (storedData != null && storedData.isNotEmpty) {
        final decoded = jsonDecode(storedData) as Map<String, dynamic>;
        _currentUserId = decoded['userId'];

        _accessibleSuppliers.clear();
        final suppliersMap = decoded['suppliers'] as Map<String, dynamic>?;
        if (suppliersMap != null) {
          suppliersMap.forEach((userId, supplierIds) {
            _accessibleSuppliers[int.parse(userId)] = (supplierIds as List)
                .map((e) => int.parse(e.toString()))
                .toList();
          });
        }

        debugPrint(
            '📂 Loaded accessible suppliers: ${_accessibleSuppliers.length} users');
      }
    } catch (e) {
      debugPrint('❌ Error loading persisted accessible suppliers: $e');
    }
  }

  Future<void> save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'userId': _currentUserId,
        'suppliers': _accessibleSuppliers.map(
            (userId, supplierIds) => MapEntry(userId.toString(), supplierIds)),
        'timestamp': DateTime.now().toIso8601String(),
      };
      await prefs.setString(_KEY, jsonEncode(data));
      debugPrint('💾 Persisted accessible suppliers');
    } catch (e) {
      debugPrint('❌ Error persisting accessible suppliers: $e');
    }
  }

  Future<void> addSupplier(int userId, int supplierId) async {
    final suppliers = _accessibleSuppliers[userId] ?? [];
    if (!suppliers.contains(supplierId)) {
      suppliers.add(supplierId);
      _accessibleSuppliers[userId] = suppliers;
      await save();
    }
  }

  Future<void> removeSupplier(int userId, int supplierId) async {
    final suppliers = _accessibleSuppliers[userId];
    if (suppliers != null) {
      suppliers.remove(supplierId);
      if (suppliers.isEmpty) {
        _accessibleSuppliers.remove(userId);
      } else {
        _accessibleSuppliers[userId] = suppliers;
      }
      await save();
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_KEY);
    _accessibleSuppliers.clear();
    _currentUserId = null;
    debugPrint('🗑️ Cleared persisted accessible suppliers');
  }

  void setCurrentUser(int userId) {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      load();
    }
  }

  Map<int, List<int>> get all => Map.unmodifiable(_accessibleSuppliers);
}
