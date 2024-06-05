// UserService.dart
import 'AppUser.dart';

// AppUserService.dart
abstract class AppUserService {
  Future<List<AppUserCategory>?>? getCategories() async {
    return null;
  }

  Future<AppUser?> getAppUser(String idAppUser) async {
    return null;
  }

  Future<int?> addAppUser(AppUser appUser) async {
    return null;
  }

  Future<int?> updateAppUser(AppUser updatedAppUser) async {
    return null;
  }

  Future<int?> deleteAppUser(String appUserId) async {
    return null;
  }
}
