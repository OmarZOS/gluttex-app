// import 'package:dio/dio.dart';

abstract class StorageService<T> {
  Future<dynamic> getAll(String destination, {params}) async {
    return null;
  }

  Future<dynamic> insert(String destination, Map<String, dynamic> data) async {
    return null;
  }

  Future<dynamic> insertBinary(String destination, T data) async {
    return null;
  }

  Future<dynamic> get(String destination, String id) async {
    return null;
  }

  Future<int?> delete(String destination, String id) async {
    return null;
  }

  Future<dynamic> update(String destination, String id,
      Map<String, dynamic> parameters, Map<String, dynamic> data) async {
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
