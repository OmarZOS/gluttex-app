// UserService.dart
import 'AppUser.dart';

abstract class UserService {
  Future<AppUser?> getAppUser(String id) async {
    return null;
  }

  Future<int?> addAppUser(AppUser AppUser) async {
    return null;
  }

  Future<int?> updateAppUser(AppUser updatedAppUser) async {
    return null;
  }

  Future<int?> deleteAppUser(int appUserId) async {
    return null;
  }
}
