import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/app/Services/AuthService.dart';
import 'package:gluttex_core/app/Services/UserService.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:locator/locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppUserNotifier extends ChangeNotifier {
  final AppUserService _appUserService = GluttexLocator.get<AppUserService>();
  final AuthService _authService = GluttexLocator.get<AuthService>();
  final StorageService _storageService = GluttexLocator.get<StorageService>();

  AppUser? _appUser;
  String? _token;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  int _selectedTabIndex = 0;

  Map<int, AppUser> users = {};

  // Track current operation keys
  String? _currentOperationKey;

  // Getters
  AppUser? get appUser => _appUser;
  String? get token => _token;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  int get selectedTabIndex => _selectedTabIndex;
  bool get isCookingChef =>
      ((appUser?.app_user_type_id ?? 0) == GluttexConstants.cookingChefDBId);

  // Helper method to generate caller key
  String _getCallerKey(String method, {String? id, String? suffix}) {
    final parts = [method];
    if (id != null) parts.add(id);
    if (suffix != null) parts.add(suffix);
    parts.add(DateTime.now().millisecondsSinceEpoch.toString());
    return parts.join('_');
  }

  // Response tracking methods
  void _storeSuccessResponse(String callerKey, dynamic data,
      {int? statusCode, String? responseCode}) {
    _storageService.setSuccessResponse(callerKey, data,
        statusCode: statusCode ?? 200, responseCode: responseCode);
    debugPrint('✅ Stored SUCCESS: $callerKey - $responseCode');
  }

  void _storeFailureResponse(String callerKey, dynamic data,
      {int? statusCode,
      String? errorCode,
      String? message,
      String? responseCode}) {
    _storageService.setFailureResponse(callerKey,
        data: data,
        statusCode: statusCode ?? 500,
        errorCode: errorCode,
        message: message,
        responseCode: responseCode);
    debugPrint('❌ Notifier Stored FAILURE: $callerKey - $responseCode');
  }

  // Initialize authentication state
  Future<void> initializeAuthState({String? callerKey}) async {
    final key = callerKey ?? _getCallerKey('initializeAuthState');

    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final storedToken = prefs.getString('auth_token');
      final storedUserData = prefs.getString('user_data');
      final isAuthenticated = prefs.getBool('is_authenticated') ?? false;

      debugPrint(
          'Initializing auth state - Token: ${storedToken != null ? "YES" : "NO"}, User: ${storedUserData != null ? "YES" : "NO"}');

      if (isAuthenticated && storedToken != null && storedUserData != null) {
        _token = storedToken;
        _appUser = AppUser.fromJson(jsonDecode(storedUserData));
        _isAuthenticated = true;
        _storeSuccessResponse(key, _appUser,
            statusCode: 200, responseCode: 'AUTH_RESTORED');
        debugPrint('Auth state restored: ${_appUser?.app_user_name}');
      } else {
        debugPrint('No valid auth state found, clearing data');
        await _clearAuthData();
        _storeSuccessResponse(key, null,
            statusCode: 200, responseCode: 'NO_AUTH_FOUND');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing auth state: $e');
      _storeFailureResponse(key, e.toString(),
          statusCode: 500,
          errorCode: 'INIT_AUTH_ERROR',
          message: 'Failed to initialize auth state',
          responseCode: 'INIT_AUTH_ERROR');
      _isLoading = false;
      await _clearAuthData();
      notifyListeners();
    }
  }

  // Fetch user data
  Future<void> fetchAppUser(String userId, {String? callerKey}) async {
    final key = callerKey ?? _getCallerKey('fetchAppUser', id: userId);

    try {
      _isLoading = true;
      notifyListeners();

      var appUser = await _appUserService.getAppUser(userId);
      _appUser = appUser;

      if (_isAuthenticated) {
        await _storeAuthData();
      }

      _storeSuccessResponse(key, _appUser,
          statusCode: 200, responseCode: 'SUCCESS');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _storeFailureResponse(key, e.toString(),
          statusCode: 500,
          errorCode: 'FETCH_USER_ERROR',
          message: 'Failed to fetch user',
          responseCode: 'FETCH_USER_ERROR');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Fetch user data passively (with cache)
  Future<AppUser?> fetchUserPassively(String userId,
      {String? callerKey}) async {
    final key = callerKey ?? _getCallerKey('fetchUserPassively', id: userId);

    try {
      if (users.containsKey(int.parse(userId))) {
        final cachedUser = users[int.parse(userId)];
        _storeSuccessResponse(key, cachedUser,
            statusCode: 200, responseCode: 'CACHE_HIT');
        return cachedUser;
      }

      AppUser? appUser = await _appUserService.getAppUser(userId);
      if (appUser != null) {
        users[int.parse(userId)] = appUser;
        _storeSuccessResponse(key, appUser,
            statusCode: 200, responseCode: 'SUCCESS');
      } else {
        _storeFailureResponse(key, null,
            statusCode: 404,
            errorCode: 'USER_NOT_FOUND',
            message: 'User not found',
            responseCode: 'USER_NOT_FOUND');
      }
      return appUser;
    } catch (e) {
      _storeFailureResponse(key, e.toString(),
          statusCode: 500,
          errorCode: 'FETCH_PASSIVE_ERROR',
          message: 'Failed to fetch user passively',
          responseCode: 'FETCH_PASSIVE_ERROR');
      rethrow;
    }
  }

  // Update user
  Future<void> updateAppUser(AppUser user, {String? callerKey}) async {
    final key = callerKey ??
        _getCallerKey('updateAppUser', id: user.id_app_user.toString());

    try {
      _isLoading = true;
      notifyListeners();

      await _appUserService.updateAppUser(user);
      await fetchAppUser('${user.id_app_user}');

      _storeSuccessResponse(key, user,
          statusCode: 200, responseCode: 'UPDATED');
    } catch (e) {
      _storeFailureResponse(key, e.toString(),
          statusCode: 500,
          errorCode: 'UPDATE_USER_ERROR',
          message: 'Failed to update user',
          responseCode: 'UPDATE_USER_ERROR');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Tab management
  void setSelectedTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  // Guest login
  Future<void> signInAsGuest({String? callerKey}) async {
    final key = callerKey ?? _getCallerKey('signInAsGuest');

    _appUser = AppUser.empty();
    _isAuthenticated = false;
    _token = null;
    await _clearAuthData();

    _storeSuccessResponse(key, _appUser,
        statusCode: 200, responseCode: 'GUEST_LOGIN');
    notifyListeners();
  }

  // Add new user
  Future<int?> addAppUser(AppUser appUser, {String? callerKey}) async {
    final key =
        callerKey ?? _getCallerKey('addAppUser', suffix: appUser.app_user_name);

    try {
      _isLoading = true;
      notifyListeners();

      int? status = await _appUserService.addAppUser(appUser);
      if (status != null && status > 0) {
        await fetchAppUser('${appUser.id_app_user}');
        _storeSuccessResponse(key, status,
            statusCode: 200, responseCode: 'CREATED');
      } else {
        _storeFailureResponse(key, null,
            statusCode: 500,
            errorCode: 'ADD_USER_FAILED',
            message: 'Failed to add user',
            responseCode: 'ADD_USER_FAILED');
      }

      _isLoading = false;
      notifyListeners();
      return status;
    } catch (e) {
      _storeFailureResponse(key, e.toString(),
          statusCode: 500,
          errorCode: 'ADD_USER_ERROR',
          message: 'Failed to add user',
          responseCode: 'ADD_USER_ERROR');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Update user image
  Future<int?> updateAppUserImage(AppUser appUser, {String? callerKey}) async {
    final key = callerKey ??
        _getCallerKey('updateAppUserImage', id: appUser.id_app_user.toString());

    try {
      _isLoading = true;
      notifyListeners();

      int? status = await _appUserService.updateAppUserImage(appUser);
      if (status != null && status > 0) {
        await fetchAppUser('${appUser.id_app_user}');
        _storeSuccessResponse(key, status,
            statusCode: 200, responseCode: 'IMAGE_UPDATED');
      } else {
        _storeFailureResponse(key, null,
            statusCode: 500,
            errorCode: 'UPDATE_IMAGE_FAILED',
            message: 'Failed to update user image',
            responseCode: 'UPDATE_IMAGE_FAILED');
      }

      _isLoading = false;
      notifyListeners();
      return status;
    } catch (e) {
      _storeFailureResponse(key, e.toString(),
          statusCode: 500,
          errorCode: 'UPDATE_IMAGE_ERROR',
          message: 'Failed to update user image',
          responseCode: 'UPDATE_IMAGE_ERROR');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Delete user
  Future<int?> deleteAppUser(String idAppuser, {String? callerKey}) async {
    final key = callerKey ?? _getCallerKey('deleteAppUser', id: idAppuser);

    try {
      _isLoading = true;
      notifyListeners();

      int? status = await _appUserService.deleteAppUser(idAppuser);
      if (status != null && status > 0) {
        await fetchAppUser(idAppuser);
        _storeSuccessResponse(key, status,
            statusCode: 200, responseCode: 'DELETED');
      } else {
        _storeFailureResponse(key, null,
            statusCode: 500,
            errorCode: 'DELETE_USER_FAILED',
            message: 'Failed to delete user',
            responseCode: 'DELETE_USER_FAILED');
      }

      _isLoading = false;
      notifyListeners();
      return status;
    } catch (e) {
      _storeFailureResponse(key, e.toString(),
          statusCode: 500,
          errorCode: 'DELETE_USER_ERROR',
          message: 'Failed to delete user',
          responseCode: 'DELETE_USER_ERROR');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Sign up with registration data
  Future<dynamic> signUpWithData(Map<String, dynamic> data,
      {String? callerKey}) async {
    final key = callerKey ??
        _getCallerKey('signUpWithData',
            suffix: data['app_user_name']?.toString());

    try {
      _isLoading = true;
      notifyListeners();

      dynamic appUserData = await _authService.signUpWithData(
        data,
      );

      if (appUserData['id_app_user'] != null) {
        _token = appUserData['access_token'];
        _isAuthenticated = true;
        await fetchAppUser(appUserData['id_app_user'].toString());
        await _storeAuthData();
        _storeSuccessResponse(key, appUserData,
            statusCode: 200, responseCode: 'SIGNUP_SUCCESS');
      } else {
        _storeFailureResponse(key, appUserData,
            statusCode: 400,
            errorCode: 'SIGNUP_FAILED',
            message: 'Sign up failed',
            responseCode: 'SIGNUP_FAILED');
        _isLoading = false;
        notifyListeners();
      }

      return appUserData;
    } catch (e) {
      _storeFailureResponse(key, e.toString(),
          statusCode: 500,
          errorCode: 'SIGNUP_ERROR',
          message: 'Sign up failed',
          responseCode: 'SIGNUP_ERROR');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Sign in with email and password
  Future<bool> signInWithUsernameAndPassword(String username, String password,
      {String? callerKey}) async {
    final key = callerKey ??
        _getCallerKey('signInWithUsernameAndPassword', suffix: username);

    try {
      _isLoading = true;
      notifyListeners();

      debugPrint('🔐 Attempting login for user: $username - Notifier');

      dynamic appUserData = await _authService
          .signInWithUsernameAndPassword(username, password, callerKey: key);

      if (appUserData['app_user_id'] != null) {
        _token = appUserData['access_token'];
        _isAuthenticated = true;
        await fetchAppUser(appUserData['app_user_id'].toString());
        await _storeAuthData();
        debugPrint('✅ Login successful for user: $username - Notifier');
        return true;
      } else {
        debugPrint('⚠️ Login returned null user_id for: $username - Notifier');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Login failed for user: $username - Error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign in with Google
  Future<AppUser?> signInWithGoogle(dynamic data, {String? callerKey}) async {
    final key = callerKey ?? _getCallerKey('signInWithGoogle');

    try {
      _isLoading = true;
      notifyListeners();

      debugPrint('Google sign in data received: ${data.keys}');

      _token = data['token']?['access_token'] ?? data['access_token'];
      _appUser = data['user'] != null ? AppUser.fromGoogleJson(data) : null;

      if (_token == null || _appUser == null) {
        _storeFailureResponse(key, null,
            statusCode: 400,
            errorCode: 'GOOGLE_SIGNIN_INVALID',
            message: 'Invalid Google login response',
            responseCode: 'GOOGLE_SIGNIN_INVALID');
        throw Exception(
            'Invalid Google login response: missing token or user data');
      }

      _isAuthenticated = true;
      await _storeAuthData();

      _storeSuccessResponse(key, _appUser,
          statusCode: 200, responseCode: 'GOOGLE_LOGIN_SUCCESS');

      _isLoading = false;
      notifyListeners();

      debugPrint(
          'Google sign-in successful: ${_appUser?.app_user_name}, Authenticated: $_isAuthenticated');
      return _appUser;
    } catch (e) {
      debugPrint('Error in signInWithGoogle: $e');
      _storeFailureResponse(key, e.toString(),
          statusCode: 500,
          errorCode: 'GOOGLE_SIGNIN_ERROR',
          message: 'Google sign in failed',
          responseCode: 'GOOGLE_SIGNIN_ERROR');
      _isLoading = false;
      _isAuthenticated = false;
      _token = null;
      _appUser = null;
      await _clearAuthData();
      notifyListeners();
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut({String? callerKey}) async {
    final key = callerKey ?? _getCallerKey('signOut');

    try {
      _isLoading = true;
      notifyListeners();

      await _authService.signOut();
      await _clearAuthData();

      _appUser = null;
      _token = null;
      _isAuthenticated = false;
      _selectedTabIndex = 0;

      _storeSuccessResponse(key, true,
          statusCode: 200, responseCode: 'SIGNOUT_SUCCESS');

      _isLoading = false;
      notifyListeners();

      debugPrint('User signed out successfully');
    } catch (e) {
      _storeFailureResponse(key, e.toString(),
          statusCode: 500,
          errorCode: 'SIGNOUT_ERROR',
          message: 'Sign out failed',
          responseCode: 'SIGNOUT_ERROR');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Store auth data persistently
  Future<void> _storeAuthData() async {
    try {
      if (_appUser != null && _token != null && _isAuthenticated) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setString('user_data', jsonEncode(_appUser!.toJson()));
        await prefs.setBool('is_authenticated', true);

        debugPrint('Auth data stored successfully');
      }
    } catch (e) {
      debugPrint('Error storing auth data: $e');
    }
  }

  // Clear auth data
  Future<void> _clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      await prefs.remove('is_authenticated');

      debugPrint('Auth data cleared');
    } catch (e) {
      debugPrint('Error clearing auth data: $e');
    }
  }

  // Sign in with Facebook (placeholder)
  Future<AppUser?> signInWithFacebook({String? callerKey}) async {
    final key = callerKey ?? _getCallerKey('signInWithFacebook');

    try {
      final result = await _authService.signInWithFacebook();
      if (result != null) {
        _storeSuccessResponse(key, result,
            statusCode: 200, responseCode: 'FACEBOOK_LOGIN_SUCCESS');
      }
      return result;
    } catch (e) {
      _storeFailureResponse(key, e.toString(),
          statusCode: 500,
          errorCode: 'FACEBOOK_SIGNIN_ERROR',
          message: 'Facebook sign in failed',
          responseCode: 'FACEBOOK_SIGNIN_ERROR');
      rethrow;
    }
  }

  // ============ HELPER METHODS FOR RESPONSE RETRIEVAL ============

  /// Get stored response for a caller key
  CallerResponse? getResponse(String callerKey) {
    return _storageService.getResponse(callerKey);
  }

  /// Check if a call was successful
  bool isSuccess(String callerKey) {
    return _storageService.isCallerSuccess(callerKey);
  }

  /// Get response data
  dynamic getResponseData(String callerKey) {
    return _storageService.getResponseData(callerKey);
  }

  /// Get status code
  int? getStatusCode(String callerKey) {
    return _storageService.getStatusCode(callerKey);
  }

  /// Get response code
  String? getResponseCode(String callerKey) {
    return _storageService.getResponseCode(callerKey);
  }

  /// Get error message
  String? getErrorMessage(String callerKey) {
    return _storageService.getErrorMessage(callerKey);
  }

  /// Clear response for a caller key
  void clearResponse(String callerKey) {
    _storageService.clearResponse(callerKey);
  }

  /// Clear all responses
  void clearAllResponses() {
    _storageService.clearAllResponses();
  }
}
