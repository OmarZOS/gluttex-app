// UserService.dart
import 'AppUser.dart';

abstract class UserService {
  Future<List<AppUser>?> getAllAppUsers() async {
    return null;
  }

  Future<void> addAppUser(AppUser AppUser) async {
// ... code to add a new AppUser
  }

  Future<void> updateAppUser(AppUser updatedAppUser) async {
// ... code to update an existing AppUser
  }

  Future<void> deleteAppUser(int appUserId) async {
// ... code to delete a supplier by id
  }
}
