import 'package:gluttex_core/app/AppUser.dart';

abstract class StorageService {
  void insertAppUser(Map<String, dynamic> data) {}
  AppUser? getAppUser() {
    return null;
  }

  void deleteAppUser(Map<String, dynamic> data) {}
}
