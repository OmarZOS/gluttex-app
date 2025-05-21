import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/app/Services/AuthService.dart';
import 'package:gluttex_core/app/Services/UserService.dart';
import 'package:locator/locator.dart';

class AppUserNotifier extends ChangeNotifier {
  final AppUserService _appUserService = GluttexLocator.get<AppUserService>();
  final AuthService _authService = GluttexLocator.get<AuthService>();
  AppUser? _appUser;
  late String? token;

  AppUser? get appUser => _appUser;

  bool get isLoggedIn => (_appUser?.id_app_user ?? 0) > 0;

  bool get isCookingChef =>
      ((appUser?.app_user_type_id ?? 0) == GluttexConstants.cookingChefDBId);

  Future<void> fetchAppUser(String userId) async {
    var appUser = await _appUserService.getAppUser(userId);
    _appUser = appUser;
    notifyListeners();
  }

  void logout() {
    _appUser = null;
    notifyListeners();
  }

  Future<void> signInAsGuest() async {
    _appUser = AppUser.empty();
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

  Future<int?> deleteAppUser(String idAppuser) async {
    int? status = await _appUserService.deleteAppUser(idAppuser);
    await fetchAppUser(idAppuser);
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
  Future<void> signInWithUsernameAndPassword(
      String username, String password) async {
    dynamic appUserData =
        await _authService.signInWithUsernameAndPassword(username, password);

    if (appUserData['app_user_id'] != null) {
      token = appUserData['access_token'];
      // log("Fetching : " + appUserData['app_user_id'].toString());
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
