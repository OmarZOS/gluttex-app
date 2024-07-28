import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/app/AuthService.dart';
import 'package:gluttex_core/app/UserService.dart';
import 'package:locator/locator.dart';

class AppUserNotifier extends ChangeNotifier {
  final AppUserService _appUserService = GluttexLocator.get<AppUserService>();
  final AuthService _authService = GluttexLocator.get<AuthService>();
  late AppUser? _appUser;
  late String? token;

  AppUser? get appUser => _appUser;

  Future<void> fetchAppUser(String userId) async {
    var appUser = await _appUserService.getAppUser(userId);

    _appUser = appUser;
    notifyListeners();
  }

  Future<int?> addAppUser(AppUser appUser) async {
    int? status = await _appUserService.addAppUser(appUser);
    await fetchAppUser('${appUser.id_app_user}');
    return status;
  }

  Future<int?> updateAppUser(AppUser appUser) async {
    int? status = await _appUserService.updateAppUser(appUser);
    await fetchAppUser('${appUser.id_app_user}');
    return status;
  }

  Future<int?> deleteAppUser(String id_appUser) async {
    int? status = await _appUserService.deleteAppUser(id_appUser);
    await fetchAppUser(id_appUser);
    return status;
  }

  // Sign up with registration data
  Future<dynamic> signUpWithData(Map<String, dynamic> data) async {
    dynamic appUserData = await _authService.signUpWithData(data);

    if (appUserData['id_app_user'] != null) {
      await fetchAppUser(appUserData['id_app_user'].toString());
      return;
    }
    return appUserData;
  }

  // Sign in with email and password
  Future<dynamic> signInWithUsernameAndPassword(
      String username, String password) async {
    dynamic appUserData =
        await _authService.signInWithUsernameAndPassword(username, password);

    if (appUserData['app_user_id'] != null) {
      token = appUserData['access_token'];
      await fetchAppUser(appUserData['app_user_id'].toString());
      return;
    }
    return appUserData;
  }

  // Sign in with Google
  Future<AppUser?> signInWithGoogle() async {
    throw UnimplementedError();
  }

  // Sign in with Facebook
  Future<AppUser?> signInWithFacebook() async {
    throw UnimplementedError();
  }

  // Sign out
  Future<void> signOut() async {
    throw UnimplementedError();
  }
}
