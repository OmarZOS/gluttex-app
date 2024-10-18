library gluttex_impl_mediation;

import 'dart:developer' as developer;

import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/AppUser.dart';
import 'package:gluttex_core/mediation/StorageService.dart';

class StorageServiceImpl implements StorageService {
  final Dio _dio = Dio();

  @override
  Future<int?> delete(String destination, String id) async {
    try {
      final response = await _dio.delete("$destination/$id");
      return response.statusCode;
    } on DioException catch (e, stacktrace) {
      developer.log('${stacktrace}');
      return 505;
    }
  }

  @override
  Future<dynamic> get(String destination, String id) async {
    try {
      final response = await _dio.get('$destination/$id');
      if (response.statusCode == 200) {
        return response.data;
      } else if (response.statusCode == 404) {
        throw Exception(GluttexConstants.notFoundError);
      } else {
        throw Exception(GluttexConstants.getFailure);
      }
    } on DioException catch (e, stacktrace) {
      log('${e}');
      log('${stacktrace}');
      log('$destination/$id');
      throw Exception(GluttexConstants.serverError);
    }
  }

  @override
  Future<dynamic> getAll(String destination) async {
    try {
      final response = await _dio.get(destination);
      if (response.statusCode == 200) {
        // developer.log('${response.data}');
        return response.data;
      } else if (response.statusCode == 404) {
        throw Exception(GluttexConstants.notFoundError);
      } else {
        throw Exception(GluttexConstants.getFailure);
      }
    } on DioException catch (e, stacktrace) {
      // log("${destination}");
      developer.log('${e}');
      developer.log('${stacktrace}');
      throw Exception(GluttexConstants.serverError);
    }
  }

  @override
  Future<int?> insert(String destination, Map<String, dynamic> data) async {
    try {
      // Log the request data
      log('Request data: ${json.encode(data)}');

      // Make the PUT request
      final response = await _dio.put(
        destination,
        data: json.encode(data),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      // Log the response status code and data
      // //log('Response status code: ${response.statusCode}');
      // //log('Response data: ${response.data}');

      // Check the response status code
      return response.statusCode;

      // Return success message
    } on DioException catch (e, stacktrace) {
      // Log the error and stack trace for better debugging
      log('Error: $e');
      log('Stack trace: $stacktrace');

      // Return server error message
      return e.response?.statusCode;
    } catch (e) {
      return 500;
    }
  }

  @override
  Future<int?> update(
      String destination, String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('${destination}/${id}',
          data: json.encode(data),
          options: Options(headers: {
            'Content-Type': 'application/json',
            'accept': 'application/json'
          }));

      return response.statusCode;
    } on DioException catch (e, stacktrace) {
      log('Error: $e');
      log('Stack trace: $stacktrace');

      // Return server error message
      return e.response?.statusCode;
    }
  }

  @override
  Future<dynamic> signUpUsingUsernameAndPassword(
      String destination, Map<String, dynamic> data) async {
    try {
      log('$data');
      final response = await _dio.put('${destination}',
          data: data, //json.encode(data)
          options: Options(
              validateStatus: (status) => status == 200 || status == 406,
              headers: {
                'Content-Type': 'application/json',
                'accept': 'application/json'
              }));
      if (response.statusCode == 406) {
        throw Exception(response.data["detail"]);
      }
      return response.data;
    } on DioException catch (e) {
      // log('Error: ' + e.message.toString());
      // log('Stack trace: $stacktrace');
      // Return server error message
      throw Exception(e.message);
    }
  }

  @override
  Future<dynamic> signInUsingUsernameAndPassword(
      String destination, Map<String, dynamic> data) async {
    try {
      // log('${json.encode(data)}');
      final response = await _dio.post('${destination}',
          data: json.encode(data),
          options: Options(
              validateStatus: (status) => status == 200 || status == 406,
              headers: {
                'Content-Type': 'application/json',
                'accept': 'application/json'
              }));
      if (response.statusCode == 406) {
        throw Exception(response.data["detail"]);
      }
      return response.data;
    } on DioException catch (e) {
      // Return server error message
      throw Exception(e.message);
    }
  }

  Future<dynamic> signInUsingProvider(String destination, String providerName,
      Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('${destination}',
          data: json.encode(data),
          options: Options(headers: {
            'Content-Type': 'application/json',
            'accept': 'application/json'
          }));

      return response.data;
    } on DioException catch (e, stacktrace) {
      log('Error: $e');
      log('Stack trace: $stacktrace');

      // Return server error message
      return 'Stack trace: $stacktrace';
    }
  }
}
