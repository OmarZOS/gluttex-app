import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/app/UserService.dart';
import 'package:locator/locator.dart';

class AppUserNotifier extends ChangeNotifier {
  final AppUserService _appUserService = GluttexLocator.get<AppUserService>();
  late AppUser? _appUser;

  AppUserNotifier() {
    // fetchAppUser("1");
  }
  AppUser? get appUser => _appUser;

  Future<void> fetchAppUser(String userId) async {
    var appUser = await _appUserService.getAppUser(userId);

    // log('${appUser?.id_app_user}');
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
}
