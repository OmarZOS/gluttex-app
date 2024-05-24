// UserService.dart
import 'AppUser.dart';

abstract class UserService {
  Future<AppUser?> getAppUser(String id) async {
    return null;
  }

  Future<String?> addAppUser(AppUser AppUser) async {
    return null;
  }

  Future<String?> updateAppUser(AppUser updatedAppUser) async {
    return null;
  }

  Future<String?> deleteAppUser(int appUserId) async {
    return null;
  }
}
