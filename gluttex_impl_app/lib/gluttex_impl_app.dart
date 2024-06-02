library gluttex_impl_app;

import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/app/UserService.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:locator/locator.dart';

class UserServiceImpl implements UserService {
  @override
  Future<int?> addAppUser(AppUser appUser) {
    StorageService storageService = GluttexLocator.get<StorageService>();

    return storageService.insert(
        '$GluttexConstants.apiBaseUrl$GluttexConstants.addAppUserEndpoint',
        appUser.toJson());
  }

  @override
  Future<int?> deleteAppUser(int appUserId) {
    StorageService storageService = GluttexLocator.get<StorageService>();

    return storageService.delete(
        '$GluttexConstants.apiBaseUrl$GluttexConstants.addAppUserEndpoint',
        '$appUserId');
  }

  @override
  Future<int?> updateAppUser(AppUser updatedAppUser) {
    StorageService storageService = GluttexLocator.get<StorageService>();
    return storageService.update(
        '$GluttexConstants.apiBaseUrl$GluttexConstants.addAppUserEndpoint',
        '$updatedAppUser.id_app_user',
        updatedAppUser.toJson());
  }

  @override
  Future<AppUser?> getAppUser(String id) {
    StorageService storageService = GluttexLocator.get<StorageService>();
    Map<String, dynamic> data = storageService.get(
        GluttexConstants.apiBaseUrl, id) as Map<String, dynamic>;
    return AppUser.fromJson(data) as Future<AppUser?>;
  }
}
