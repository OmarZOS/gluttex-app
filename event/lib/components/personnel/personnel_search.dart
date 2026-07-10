import 'dart:async';
import 'dart:developer';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/app/Person.dart';
import 'package:flutter/foundation.dart';
import 'package:gluttex_core/app/Services/UserService.dart';
import 'personnel_cache.dart';
import 'personnel_state.dart';

class PersonnelSearch {
  final AppUserService _userService;
  final PersonnelCache _cache;
  final PersonnelState _state;
  Timer? _debounceTimer;

  static const _itemsPerPage = 50;
  static const _debounceDelayMs = 300;

  PersonnelSearch({
    required AppUserService userService,
    required PersonnelCache cache,
    required PersonnelState state,
  })  : _userService = userService,
        _cache = cache,
        _state = state;

  void dispose() => _debounceTimer?.cancel();

  void clear({int supplierId = 0}) {
    _state.setSearchQuery('');
    _state.searchResults = [];
    _state.personSearchResults = [];
    _state.setError(null);
    _state.personnel.clear();
    _state.personnel.addAll(_getActiveUsersForSupplier(supplierId));
  }

  Future<void> search(String query, {int supplierId = 0}) async {
    final trimmed = query.trim();
    _state.setSearchQuery(trimmed);

    _debounceTimer?.cancel();

    if (trimmed.isEmpty) {
      _state.searchResults = [];
      _state.personSearchResults = [];
      return;
    }

    _debounceTimer = Timer(
      const Duration(milliseconds: _debounceDelayMs),
      () => _performSearch(trimmed, supplierId),
    );
  }

  Future<void> _performSearch(String query, int supplierId) async {
    _state.setLoading(true);
    _state.searchResults = [];
    _state.personSearchResults = [];

    try {
      await Future.wait([
        _searchAppUsers(query, supplierId),
        _searchPeople(query, supplierId),
      ]);
      _state.setError(null);
    } catch (e) {
      _state.setError('Search failed: ${e.toString()}');
    } finally {
      _state.setLoading(false);
    }
  }

  Future<void> _searchAppUsers(String query, int supplierId) async {
    try {
      final results =
          await _userService.searchAppUsers(query, 0, _itemsPerPage);
      if (results != null) {
        _state.searchResults = results;
      }
    } catch (e) {
      debugPrint('Error searching app users: $e');
    }
  }

  Future<void> _searchPeople(String query, int supplierId) async {
    try {
      final results = await _userService.searchPeople(query, 0, _itemsPerPage);
      if (results != null) {
        _state.personSearchResults = results;
      }
    } catch (e) {
      debugPrint('Error searching people: $e');
    }
  }

  List<AppUser> _getActiveUsersForSupplier(int supplierId) {
    if (supplierId == 0) {
      return _cache.activeRules.keys
          .map((userId) => _cache.getUser(userId))
          .whereType<AppUser>()
          .toList();
    }

    final userIds = _cache.getActiveUserIdsForSupplier(supplierId);
    return userIds
        .map((id) => _cache.getUser(id))
        .whereType<AppUser>()
        .toList();
  }
}
