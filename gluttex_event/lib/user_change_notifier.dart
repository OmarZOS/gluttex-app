import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/app/GluttexImage.dart';
import 'package:gluttex_core/app/Services/AuthService.dart';
import 'package:gluttex_core/app/Services/UserService.dart';
import 'package:locator/locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppUserNotifier extends ChangeNotifier {
  final AppUserService _appUserService = GluttexLocator.get<AppUserService>();
  final AuthService _authService = GluttexLocator.get<AuthService>();

  AppUser? _appUser;
  String? _token;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  int _selectedTabIndex = 0;

  // Getters
  AppUser? get appUser => _appUser;
  String? get token => _token;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  int get selectedTabIndex => _selectedTabIndex;
  // bool get isLoggedIn => (_appUser?.id_app_user ?? 0) > 0 && _isAuthenticated;
  bool get isCookingChef =>
      ((appUser?.app_user_type_id ?? 0) == GluttexConstants.cookingChefDBId);

  // Initialize authentication state
  Future<void> initializeAuthState() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final storedToken = prefs.getString('auth_token');
      final storedUserData = prefs.getString('user_data');
      final isAuthenticated = prefs.getBool('is_authenticated') ?? false;

      print(
          'Initializing auth state - Token: ${storedToken != null ? "YES" : "NO"}, User: ${storedUserData != null ? "YES" : "NO"}');

      if (isAuthenticated && storedToken != null && storedUserData != null) {
        _token = storedToken;
        _appUser = AppUser.fromJson(jsonDecode(storedUserData));
        _isAuthenticated = true;

        print('Auth state restored: ${_appUser?.app_user_name}');
      } else {
        print('No valid auth state found, clearing data');
        await _clearAuthData();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error initializing auth state: $e');
      _isLoading = false;
      await _clearAuthData();
      notifyListeners();
    }
  }

  // Fetch user data
  Future<void> fetchAppUser(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      var appUser = await _appUserService.getAppUser(userId);
      _appUser = appUser;

      // Update stored user data
      if (_isAuthenticated) {
        await _storeAuthData();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Update user
  Future<void> updateAppUser(AppUser user) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _appUserService.updateAppUser(user);
      await fetchAppUser('${user.id_app_user}');
    } catch (e) {
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
  Future<void> signInAsGuest() async {
    _appUser = AppUser.empty();
    _isAuthenticated = false;
    _token = null;
    await _clearAuthData();
    notifyListeners();
  }

  // Add new user
  Future<int?> addAppUser(AppUser appUser) async {
    try {
      _isLoading = true;
      notifyListeners();

      int? status = await _appUserService.addAppUser(appUser);
      if (status != null && status > 0) {
        await fetchAppUser('${appUser.id_app_user}');
      }

      _isLoading = false;
      notifyListeners();
      return status;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Update user image
  Future<int?> updateAppUserImage(AppUser appUser) async {
    try {
      _isLoading = true;
      notifyListeners();

      int? status = await _appUserService.updateAppUserImage(appUser);
      if (status != null && status > 0) {
        await fetchAppUser('${appUser.id_app_user}');
      }

      _isLoading = false;
      notifyListeners();
      return status;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Delete user
  Future<int?> deleteAppUser(String idAppuser) async {
    try {
      _isLoading = true;
      notifyListeners();

      int? status = await _appUserService.deleteAppUser(idAppuser);
      if (status != null && status > 0) {
        await fetchAppUser(idAppuser);
      }

      _isLoading = false;
      notifyListeners();
      return status;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Sign up with registration data
  Future<dynamic> signUpWithData(Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      notifyListeners();

      dynamic appUserData = await _authService.signUpWithData(data);

      if (appUserData['id_app_user'] != null) {
        _token = appUserData['access_token'];
        _isAuthenticated = true;
        await fetchAppUser(appUserData['id_app_user'].toString());
        await _storeAuthData();
      } else {
        _isLoading = false;
        notifyListeners();
      }

      return appUserData;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Sign in with email and password
  Future<void> signInWithUsernameAndPassword(
      String username, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      dynamic appUserData =
          await _authService.signInWithUsernameAndPassword(username, password);

      if (appUserData['app_user_id'] != null) {
        _token = appUserData['access_token'];
        _isAuthenticated = true;
        await fetchAppUser(appUserData['app_user_id'].toString());
        await _storeAuthData();
      } else {
        _isLoading = false;
        notifyListeners();
        throw Exception('Login failed: No user ID received');
      }
    } catch (e) {
      _isLoading = false;
      _isAuthenticated = false;
      _token = null;
      notifyListeners();
      rethrow;
    }
  }

  // Sign in with Google
  Future<AppUser?> signInWithGoogle(dynamic data) async {
    try {
      _isLoading = true;
      notifyListeners();

      print('Google sign in data received: ${data.keys}');

      // Extract token and user data - handle different response structures
      _token = data['token']?['access_token'] ?? data['access_token'];
      _appUser = data['user'] != null ? AppUser.fromGoogleJson(data) : null;

      if (_token == null || _appUser == null) {
        throw Exception(
            'Invalid Google login response: missing token or user data');
      }

      _isAuthenticated = true;
      await _storeAuthData();

      _isLoading = false;
      notifyListeners();

      print(
          'Google sign-in successful: ${_appUser?.app_user_name}, Authenticated: $_isAuthenticated');
      return _appUser;
    } catch (e) {
      print('Error in signInWithGoogle: $e');
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
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _clearAuthData();

      _appUser = null;
      _token = null;
      _isAuthenticated = false;
      _selectedTabIndex = 0;

      _isLoading = false;
      notifyListeners();

      print('User signed out successfully');
    } catch (e) {
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

        print('Auth data stored successfully');
      }
    } catch (e) {
      print('Error storing auth data: $e');
    }
  }

  // Clear auth data
  Future<void> _clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      await prefs.remove('is_authenticated');

      print('Auth data cleared');
    } catch (e) {
      print('Error clearing auth data: $e');
    }
  }

  // Sign in with Facebook (placeholder)
  Future<AppUser?> signInWithFacebook() async {
    throw UnimplementedError('Facebook login not implemented');
  }
}
