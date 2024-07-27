library gluttex_impl_app;

import 'dart:developer';

import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/app/UserService.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:locator/locator.dart';

class AppUserServiceImpl implements AppUserService {
  List<AppUserCategory> categories = [];
  @override
  Future<int?> addAppUser(AppUser appUser) async {
    StorageService storageService = GluttexLocator.get<StorageService>();

    return await storageService.insert(
        GluttexConstants.apiBaseUrl + GluttexConstants.addAppUserEndpoint,
        appUser.toJson());
  }

  @override
  Future<int?> deleteAppUser(String AppUserId) async {
    StorageService storageService = GluttexLocator.get<StorageService>();

    return await storageService.delete(
        GluttexConstants.apiBaseUrl + GluttexConstants.deleteAppUserEndpoint,
        AppUserId);
  }

  @override
  Future<int?> updateAppUser(AppUser updatedAppUser) async {
    StorageService storageService = GluttexLocator.get<StorageService>();
    return await storageService.update(
        GluttexConstants.apiBaseUrl + GluttexConstants.appUserEndpoint,
        '${updatedAppUser.id_app_user}',
        updatedAppUser.toJson());
  }

  @override
  Future<AppUser?> getAppUser(String id) async {
    StorageService storageService = GluttexLocator.get<StorageService>();
    try {
      // log('${await storageService.get(GluttexConstants.apiBaseUrl + GluttexConstants.appUserEndpoint, id)}');
      var data = await storageService.get(
          GluttexConstants.apiBaseUrl + GluttexConstants.appUserEndpoint, id);
      // log('${data}');

      var appUsers = data
          .map((data) => AppUser.fromJson(data as Map<String, dynamic>))
          .toList();
      var user = appUsers.first;
      return user;
    } catch (e, stacktrace) {
      log('${e}');
      log('${stacktrace}');

      return AppUser.empty();
    }
  }

  @override
  Future<List<AppUserCategory>>? getCategories() async {
    if (categories.isNotEmpty) return categories;
    try {
      // Get the storage service instance
      StorageService storageService = GluttexLocator.get<StorageService>();

      // Make a call to get all categories
      List<dynamic> responseData = await storageService.getAll(
          GluttexConstants.apiBaseUrl +
              GluttexConstants.getAppUserCategoriesEndpoint);

      // Check if the response data is not null and is a list
      // Convert the list of AppUserCategory maps to a list of Supplier objects
      List dateien = responseData;
      List<AppUserCategory?> categories = dateien
          .map((data) => AppUserCategory.fromJson(data as Map<String, dynamic>))
          .toList();
      // developer.//log('${dateien.length}');
      return categories as List<AppUserCategory>;
    } catch (e) {
      log(e.toString());
      // Handle exceptions here
      return [];
    }
  }
}
