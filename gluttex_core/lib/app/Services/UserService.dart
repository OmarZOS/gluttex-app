// UserService.dart
import 'package:gluttex_core/app/GluttexImage.dart';

import '../AppUser.dart';

// AppUserService.dart
abstract class AppUserService {
  Future<List<AppUserCategory>?>? getCategories() async {
    return null;
  }

  Future<AppUser?> getAppUser(String idAppUser) async {
    return null;
  }

  Future<AppUser?> updateAppUser(AppUser appUser) async {
    return null;
  }

  Future<int?> addAppUser(AppUser appUser) async {
    return null;
  }

  Future<int?> updateAppUserImage(AppUser updatedAppUser) async {
    return null;
  }

  Future<int?> deleteAppUser(String appUserId) async {
    return null;
  }
}
