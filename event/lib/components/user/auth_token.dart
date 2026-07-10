import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:gluttex_core/app/Services/AuthService.dart';
import 'auth_state.dart';
import 'auth_persistence.dart';

class AuthTokenManager {
  final AuthService _authService;
  final AuthState _state;
  final AuthPersistence _persistence;

  AuthTokenManager({
    required AuthService authService,
    required AuthState state,
    required AuthPersistence persistence,
  })  : _authService = authService,
        _state = state,
        _persistence = persistence;

  Future<bool> refresh({String? callerKey}) async {
    if (_state.isRefreshing) {
      debugPrint('Token refresh already in progress');
      return false;
    }

    if (_state.refreshToken == null) {
      debugPrint('No refresh token available');
      return false;
    }

    _state.setRefreshing(true);

    try {
      debugPrint('🔄 Refreshing token...');

      final result = await _authService.refreshTokenNow(_state.refreshToken!);

      if (result != null && result['access_token'] != null) {
        _state.setTokens(
          result['access_token'],
          result['refresh_token'] ?? _state.refreshToken!,
          result['expires_in'] ?? 3600,
        );
        await _saveAuthData();
        debugPrint('✅ Token refreshed successfully');
        _state.setRefreshing(false);
        return true;
      } else {
        await _clearAuth();
        _state.setRefreshing(false);
        return false;
      }
    } catch (e) {
      debugPrint('❌ Token refresh error: $e');
      _state.setRefreshing(false);
      return false;
    }
  }

  Future<bool> ensureValid({String? callerKey}) async {
    if (_state.token == null || _state.refreshToken == null) {
      return false;
    }

    if (!_state.hasValidToken && _state.needsTokenRefresh) {
      return await refresh(callerKey: callerKey);
    }

    return _state.hasValidToken;
  }

  Future<void> _saveAuthData() async {
    if (_state.appUser != null &&
        _state.token != null &&
        _state.isAuthenticated) {
      final userJson = _state.appUser!.toJson();
      await _persistence.save(
        token: _state.token!,
        refreshToken: _state.refreshToken ?? '',
        userData: jsonEncode(userJson),
        isAuthenticated: _state.isAuthenticated,
        expiry: _state.tokenExpiry?.toIso8601String() ?? '',
      );
    }
  }

  Future<void> _clearAuth() async {
    _state.clearTokens();
    _state.clearUser();
    await _persistence.clear();
  }
}
