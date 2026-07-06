import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:app_constants/app_constants.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/app/Services/AuthService.dart';
import 'package:gluttex_core/app/Services/UserService.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:locator/locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppUserNotifier extends ChangeNotifier {
  final AppUserService _appUserService = AppLocator.get<AppUserService>();
  final AuthService _authService = AppLocator.get<AuthService>();
  final StorageService _storageService = AppLocator.get<StorageService>();

  AppUser? _appUser;
  String? _token;
  String? _refreshToken;
  int? _expiresIn;
  DateTime? _tokenExpiry;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  int _selectedTabIndex = 0;
  bool _isRefreshing = false;

  Map<int, AppUser> users = {};

  // Track current operation keys
  String? _currentOperationKey;

  // Getters
  AppUser? get appUser => _appUser;
  String? get token => _token;
  String? get refreshToken => _refreshToken;
  int? get tokenExpiresIn => _expiresIn;
  DateTime? get tokenExpiry => _tokenExpiry;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  int get selectedTabIndex => _selectedTabIndex;
  bool get isCookingRecipe => ((appUser?.app_user_type_id ?? 0) ==
      AppConstants.cookingrecipe_catalogDBId);

  bool get hasValidToken {
    if (_token == null || _tokenExpiry == null) return false;
    // Add 1 minute buffer to avoid edge cases
    return DateTime.now()
        .add(const Duration(minutes: 1))
        .isBefore(_tokenExpiry!);
  }

  bool get needsTokenRefresh {
    if (_token == null || _tokenExpiry == null || _refreshToken == null)
      return false;
    // Refresh if token expires within 10 minutes
    return DateTime.now()
        .add(const Duration(minutes: 10))
        .isAfter(_tokenExpiry!);
  }

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

  // ============ TOKEN MANAGEMENT ============

  /// Store auth data persistently
  Future<void> _storeAuthData() async {
    try {
      if (_appUser != null && _token != null && _isAuthenticated) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setString('auth_refresh_token', _refreshToken ?? '');
        await prefs.setString('user_data', jsonEncode(_appUser!.toJson()));
        await prefs.setBool('is_authenticated', true);
        await prefs.setString(
            'token_expiry', _tokenExpiry?.toIso8601String() ?? '');

        debugPrint('Auth data stored successfully');
      }
    } catch (e) {
      debugPrint('Error storing auth data: $e');
    }
  }

  /// Clear auth data
  Future<void> _clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('auth_refresh_token');
      await prefs.remove('user_data');
      await prefs.remove('is_authenticated');
      await prefs.remove('token_expiry');

      debugPrint('Auth data cleared');
    } catch (e) {
      debugPrint('Error clearing auth data: $e');
    }
  }

  /// Set token and expiry
  void _setTokens(String accessToken, String refreshToken, int expiresIn) {
    _token = accessToken;
    _refreshToken = refreshToken;
    _expiresIn = expiresIn;
    _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));
  }

  /// Refresh token
  Future<bool> refreshTokenNow({String? callerKey}) async {
    if (_isRefreshing) {
      debugPrint('Token refresh already in progress');
      return false;
    }

    if (_refreshToken == null) {
      debugPrint('No refresh token available');
      return false;
    }

    final key = callerKey ?? _getCallerKey('refreshToken');
    _isRefreshing = true;
    notifyListeners();

    try {
      debugPrint('🔄 Refreshing token...');

      final result = await _authService.refreshTokenNow(_refreshToken!);

      if (result != null && result['access_token'] != null) {
        _setTokens(
          result['access_token'],
          result['refresh_token'] ?? _refreshToken!,
          result['expires_in'] ?? 3600,
        );
        _isAuthenticated = true;
        await _storeAuthData();

        _storeSuccessResponse(key, result,
            statusCode: 200, responseCode: 'TOKEN_REFRESHED');
        debugPrint('✅ Token refreshed successfully');
        _isRefreshing = false;
        notifyListeners();
        return true;
      } else {
        // Refresh failed - clear auth
        await _clearAuthData();
        _isAuthenticated = false;
        _token = null;
        _refreshToken = null;
        _tokenExpiry = null;
        _appUser = null;

        _storeFailureResponse(key, result,
            statusCode: 401,
            errorCode: 'REFRESH_FAILED',
            message: 'Token refresh failed',
            responseCode: 'REFRESH_FAILED');
        _isRefreshing = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('❌ Token refresh error: $e');
      _storeFailureResponse(key, e.toString(),
          statusCode: 500,
          errorCode: 'REFRESH_ERROR',
          message: 'Token refresh error',
          responseCode: 'REFRESH_ERROR');
      _isRefreshing = false;
      notifyListeners();
      return false;
    }
  }

  /// Ensure valid token - refresh if needed
  Future<bool> ensureValidToken({String? callerKey}) async {
    if (_token == null || _refreshToken == null) {
      return false;
    }

    if (!hasValidToken && needsTokenRefresh) {
      return await refreshTokenNow(callerKey: callerKey);
    }

    return hasValidToken;
  }

  // ============ INITIALIZATION ============

  /// Initialize authentication state - called on app startup
  Future<void> initializeAuthState({String? callerKey}) async {
    final key = callerKey ?? _getCallerKey('initializeAuthState');

    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final storedToken = prefs.getString('auth_token');
      final storedRefreshToken = prefs.getString('auth_refresh_token');
      final storedUserData = prefs.getString('user_data');
      final isAuthenticated = prefs.getBool('is_authenticated') ?? false;
      final storedExpiry = prefs.getString('token_expiry');

      debugPrint('🔐 Initializing auth state...');
      debugPrint('   Token: ${storedToken != null ? "YES" : "NO"}');
      debugPrint(
          '   Refresh Token: ${storedRefreshToken != null ? "YES" : "NO"}');
      debugPrint('   User Data: ${storedUserData != null ? "YES" : "NO"}');
      debugPrint('   Is Authenticated: $isAuthenticated');

      if (isAuthenticated && storedToken != null && storedUserData != null) {
        _token = storedToken;
        _refreshToken = storedRefreshToken;
        _isAuthenticated = true;
        _appUser = AppUser.fromJson(jsonDecode(storedUserData));

        // Restore token expiry
        if (storedExpiry != null && storedExpiry.isNotEmpty) {
          _tokenExpiry = DateTime.tryParse(storedExpiry);
        }

        // Check if token is expired or needs refresh
        if (_tokenExpiry != null && DateTime.now().isAfter(_tokenExpiry!)) {
          debugPrint('⚠️ Token expired, attempting refresh...');
          final refreshed = await refreshTokenNow(callerKey: key);
          if (!refreshed) {
            debugPrint('❌ Token refresh failed, clearing auth');
            await _clearAuthData();
            _isAuthenticated = false;
            _token = null;
            _appUser = null;
          }
        } else if (needsTokenRefresh) {
          debugPrint('🔄 Token needs refresh (expires soon), refreshing...');
          await refreshTokenNow(callerKey: key);
        }

        _storeSuccessResponse(key, _appUser,
            statusCode: 200, responseCode: 'AUTH_RESTORED');
        debugPrint('✅ Auth state restored: ${_appUser?.app_user_name}');
        debugPrint('   Token valid until: $_tokenExpiry');
      } else {
        debugPrint('ℹ️ No valid auth state found, clearing data');
        await _clearAuthData();
        _isAuthenticated = false;
        _token = null;
        _refreshToken = null;
        _tokenExpiry = null;
        _appUser = null;
        _storeSuccessResponse(key, null,
            statusCode: 200, responseCode: 'NO_AUTH_FOUND');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error initializing auth state: $e');
      _storeFailureResponse(key, e.toString(),
          statusCode: 500,
          errorCode: 'INIT_AUTH_ERROR',
          message: 'Failed to initialize auth state',
          responseCode: 'INIT_AUTH_ERROR');
      _isLoading = false;
      await _clearAuthData();
      _isAuthenticated = false;
      _token = null;
      _appUser = null;
      notifyListeners();
    }
  }

  // ============ USER MANAGEMENT ============

  /// Fetch user data
  Future<void> fetchAppUser(String userId, {String? callerKey}) async {
    final key = callerKey ?? _getCallerKey('fetchAppUser', id: userId);

    try {
      _isLoading = true;
      notifyListeners();

      // Ensure we have a valid token
      if (!await ensureValidToken(callerKey: key)) {
        throw Exception('Invalid or expired token');
      }

      final appUser = await _appUserService.getAppUser(userId);
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

  /// Fetch user data passively (with cache)
  Future<AppUser?> fetchUserPassively(String userId,
      {String? callerKey}) async {
    final key = callerKey ?? _getCallerKey('fetchUserPassively', id: userId);

    try {
      // Check cache first
      if (users.containsKey(int.parse(userId))) {
        final cachedUser = users[int.parse(userId)];
        _storeSuccessResponse(key, cachedUser,
            statusCode: 200, responseCode: 'CACHE_HIT');
        return cachedUser;
      }

      // Ensure valid token
      if (!await ensureValidToken(callerKey: key)) {
        _storeFailureResponse(key, null,
            statusCode: 401,
            errorCode: 'INVALID_TOKEN',
            message: 'Invalid or expired token',
            responseCode: 'INVALID_TOKEN');
        return null;
      }

      final appUser = await _appUserService.getAppUser(userId);
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

  /// Update user
  Future<void> updateAppUser(AppUser user, {String? callerKey}) async {
    final key = callerKey ??
        _getCallerKey('updateAppUser', id: user.id_app_user.toString());

    try {
      _isLoading = true;
      notifyListeners();

      if (!await ensureValidToken(callerKey: key)) {
        throw Exception('Invalid or expired token');
      }

      await _appUserService.updateAppUser(user);
      await fetchAppUser('${user.id_app_user}');

      _storeSuccessResponse(key, user,
          statusCode: 200, responseCode: 'UPDATED');

      _isLoading = false;
      notifyListeners();
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

  // ============ AUTHENTICATION ============

  /// Sign in with email and password
  Future<bool> signInWithUsernameAndPassword(String username, String password,
      {String? callerKey}) async {
    final key = callerKey ??
        _getCallerKey('signInWithUsernameAndPassword', suffix: username);

    try {
      _isLoading = true;
      notifyListeners();

      debugPrint('🔐 Attempting login for user: $username');

      final authResult = await _authService
          .signInWithUsernameAndPassword(username, password, callerKey: key);

      if (authResult['app_user_id'] != null) {
        // Extract tokens
        final accessToken =
            authResult['access_token'] ?? authResult['token']?['access_token'];
        final refreshToken = authResult['refresh_token'] ??
            authResult['token']?['refresh_token'];
        final expiresIn = authResult['expires_in'] ??
            authResult['token']?['expires_in'] ??
            3600;

        final app_user_id =
            authResult['app_user_id'] ?? authResult['user']?['id_app_user'];

        if (accessToken == null) {
          throw Exception('No access token received');
        }

        _setTokens(accessToken, refreshToken ?? '', expiresIn);
        _isAuthenticated = true;

        await fetchAppUser(app_user_id.toString());
        await _storeAuthData();

        _storeSuccessResponse(key, authResult,
            statusCode: 200, responseCode: 'LOGIN_SUCCESS');
        debugPrint('✅ Login successful for user: $username');

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        debugPrint('⚠️ Login failed for user: $username');
        _storeFailureResponse(key, authResult,
            statusCode: 401,
            errorCode: 'LOGIN_FAILED',
            message: authResult['message'] ?? 'Login failed',
            responseCode: 'LOGIN_FAILED');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('❌ Login error for user: $username - Error: $e');
      _storeFailureResponse(key, e.toString(),
          statusCode: 500,
          errorCode: 'LOGIN_ERROR',
          message: 'Login error occurred',
          responseCode: 'LOGIN_ERROR');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Sign in with Google
  Future<AppUser?> signInWithGoogle(dynamic data, {String? callerKey}) async {
    final key = callerKey ?? _getCallerKey('signInWithGoogle');

    try {
      _isLoading = true;
      notifyListeners();

      debugPrint('🔐 Google sign in initiated');

      _token = data['token']?['access_token'] ?? data['access_token'];
      _refreshToken = data['token']?['refresh_token'] ?? data['refresh_token'];
      _expiresIn = data['token']?['expires_in'] ?? data['expires_in'] ?? 3600;
      _tokenExpiry = DateTime.now().add(Duration(seconds: _expiresIn!));
      _appUser = data['user'] != null ? AppUser.fromGoogleJson(data) : null;

      if (_token == null || _appUser == null) {
        _storeFailureResponse(key, null,
            statusCode: 400,
            errorCode: 'GOOGLE_SIGNIN_INVALID',
            message: 'Invalid Google login response',
            responseCode: 'GOOGLE_SIGNIN_INVALID');
        throw Exception('Invalid Google login response');
      }

      _isAuthenticated = true;
      await _storeAuthData();

      _storeSuccessResponse(key, _appUser,
          statusCode: 200, responseCode: 'GOOGLE_LOGIN_SUCCESS');

      _isLoading = false;
      notifyListeners();

      debugPrint('✅ Google sign-in successful: ${_appUser?.app_user_name}');
      return _appUser;
    } catch (e) {
      debugPrint('❌ Google sign-in error: $e');
      _storeFailureResponse(key, e.toString(),
          statusCode: 500,
          errorCode: 'GOOGLE_SIGNIN_ERROR',
          message: 'Google sign in failed',
          responseCode: 'GOOGLE_SIGNIN_ERROR');
      _isLoading = false;
      _isAuthenticated = false;
      _token = null;
      _refreshToken = null;
      _tokenExpiry = null;
      _appUser = null;
      await _clearAuthData();
      notifyListeners();
      rethrow;
    }
  }

  /// Sign in with Facebook
  Future<AppUser?> signInWithFacebook({String? callerKey}) async {
    final key = callerKey ?? _getCallerKey('signInWithFacebook');

    try {
      _isLoading = true;
      notifyListeners();

      final result = await _authService.signInWithFacebook();
      if (result != null) {
        _storeSuccessResponse(key, result,
            statusCode: 200, responseCode: 'FACEBOOK_LOGIN_SUCCESS');
      }

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _storeFailureResponse(key, e.toString(),
          statusCode: 500,
          errorCode: 'FACEBOOK_SIGNIN_ERROR',
          message: 'Facebook sign in failed',
          responseCode: 'FACEBOOK_SIGNIN_ERROR');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Sign up with registration data
  Future<dynamic> signUpWithData(Map<String, dynamic> data,
      {String? callerKey}) async {
    final key = callerKey ??
        _getCallerKey('signUpWithData',
            suffix: data['app_user_name']?.toString());

    try {
      _isLoading = true;
      notifyListeners();

      final result = await _authService.signUpWithData(data);

      if (result['id_app_user'] != null) {
        final accessToken = result['access_token'];
        final refreshToken = result['refresh_token'];
        final expiresIn = result['expires_in'] ?? 3600;

        if (accessToken != null) {
          _setTokens(accessToken, refreshToken ?? '', expiresIn);
          _isAuthenticated = true;
          await fetchAppUser(result['id_app_user'].toString());
          await _storeAuthData();
        }

        _storeSuccessResponse(key, result,
            statusCode: 200, responseCode: 'SIGNUP_SUCCESS');
      } else {
        _storeFailureResponse(key, result,
            statusCode: 400,
            errorCode: 'SIGNUP_FAILED',
            message: 'Sign up failed',
            responseCode: 'SIGNUP_FAILED');
      }

      _isLoading = false;
      notifyListeners();
      return result;
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

  /// Guest login
  Future<void> signInAsGuest({String? callerKey}) async {
    final key = callerKey ?? _getCallerKey('signInAsGuest');

    _appUser = AppUser.empty();
    _isAuthenticated = false;
    _token = null;
    _refreshToken = null;
    _tokenExpiry = null;
    await _clearAuthData();

    _storeSuccessResponse(key, _appUser,
        statusCode: 200, responseCode: 'GUEST_LOGIN');
    notifyListeners();
  }

  /// Sign out
  Future<void> signOut({String? callerKey}) async {
    final key = callerKey ?? _getCallerKey('signOut');

    try {
      _isLoading = true;
      notifyListeners();

      // await _authService.signOut();
      await _clearAuthData();

      _appUser = null;
      _token = null;
      _refreshToken = null;
      _tokenExpiry = null;
      _isAuthenticated = false;
      _selectedTabIndex = 0;
      users.clear();

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

  // ============ USER CRUD OPERATIONS ============

  /// Add new user
  Future<int?> addAppUser(AppUser appUser, {String? callerKey}) async {
    final key =
        callerKey ?? _getCallerKey('addAppUser', suffix: appUser.app_user_name);

    try {
      _isLoading = true;
      notifyListeners();

      if (!await ensureValidToken(callerKey: key)) {
        throw Exception('Invalid or expired token');
      }

      final status = await _appUserService.addAppUser(appUser);
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

  /// Update user image
  Future<int?> updateAppUserImage(AppUser appUser, {String? callerKey}) async {
    final key = callerKey ??
        _getCallerKey('updateAppUserImage', id: appUser.id_app_user.toString());

    try {
      _isLoading = true;
      notifyListeners();

      if (!await ensureValidToken(callerKey: key)) {
        throw Exception('Invalid or expired token');
      }

      final status = await _appUserService.updateAppUserImage(appUser);
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

  /// Delete user
  Future<int?> deleteAppUser(String idAppuser, {String? callerKey}) async {
    final key = callerKey ?? _getCallerKey('deleteAppUser', id: idAppuser);

    try {
      _isLoading = true;
      notifyListeners();

      if (!await ensureValidToken(callerKey: key)) {
        throw Exception('Invalid or expired token');
      }

      final status = await _appUserService.deleteAppUser(idAppuser);
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

  // ============ UI STATE ============

  void setSelectedTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  // ============ RESPONSE RETRIEVAL ============

  CallerResponse? getResponse(String callerKey) {
    return _storageService.getResponse(callerKey);
  }

  bool isSuccess(String callerKey) {
    return _storageService.isCallerSuccess(callerKey);
  }

  dynamic getResponseData(String callerKey) {
    return _storageService.getResponseData(callerKey);
  }

  int? getStatusCode(String callerKey) {
    return _storageService.getStatusCode(callerKey);
  }

  String? getResponseCode(String callerKey) {
    return _storageService.getResponseCode(callerKey);
  }

  String? getErrorMessage(String callerKey) {
    return _storageService.getErrorMessage(callerKey);
  }

  void clearResponse(String callerKey) {
    _storageService.clearResponse(callerKey);
  }

  void clearAllResponses() {
    _storageService.clearAllResponses();
  }
}
