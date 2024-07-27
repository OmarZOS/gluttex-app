import 'package:gluttex_core/app/AppUser.dart';

abstract class StorageService {
  Future<dynamic> getAll(String destination) async {
    return null;
  }

  Future<int?> insert(String destination, Map<String, dynamic> data) async {
    return null;
  }

  Future<dynamic> get(String destination, String id) async {
    return null;
  }

  Future<int?> delete(String destination, String id) async {
    return null;
  }

  Future<int?> update(
      String destination, String id, Map<String, dynamic> data) async {
    return null;
  }

  Future<dynamic> signUpUsingUsernameAndPassword(
      String destination, Map<String, dynamic> data) async {
    return null;
  }

  Future<dynamic> signInUsingUsernameAndPassword(
      String destination, Map<String, dynamic> data) async {
    return null;
  }

  Future<dynamic> signInUsingProvider(String destination, String providerName,
      Map<String, dynamic> data) async {
    return null;
  }
}
