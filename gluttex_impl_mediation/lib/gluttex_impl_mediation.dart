library gluttex_impl_mediation;

import 'dart:developer' as developer;

import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/mediation/StorageService.dart';
import 'package:gluttex_core/app/GluttexException.dart';

class StorageServiceImpl implements StorageService<FormData> {
  final Dio _dio;

  // Constructor allows optional Dio injection
  StorageServiceImpl({Dio? dio}) : _dio = dio ?? Dio();

  @override
  Future<int?> delete(String destination, String id) async {
    try {
      final response = await _dio.delete("$destination/$id");
      return response.statusCode;
    } on DioException catch (e, stacktrace) {
      throw GluttexException(e.response?.data["error_code"],
          statusCode: e.response?.statusCode, error: e);
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
      log('$e');
      log('$stacktrace');
      log('$destination/$id');
      throw GluttexException(e.response?.data["error_code"],
          statusCode: e.response?.statusCode, error: e);
    }
  }

  @override
  Future<dynamic> getAll(String destination, {params}) async {
    try {
      final response = await _dio.get(destination, queryParameters: params);
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
      developer.log('$e');
      developer.log('$stacktrace');
      throw GluttexException(e.response?.data["error_code"],
          statusCode: e.response?.statusCode, error: e);
    }
  }

  @override
  Future<dynamic> insert(String destination, Map<String, dynamic> data) async {
    try {
      // Log the request data
      // log('Request data: ${json.encode(data)}');
      log('Sending data to $destination');
      log(data.toString());
      // Make the PUT request
      final response = await _dio.post(
        destination,
        data: data,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      // Log the response status code and data
      // //log('Response status code: ${response.statusCode}');
      log('Response data: ${response.data}');

      // Check the response status code
      return response.data;

      // Return success message
    } on DioException catch (e, stacktrace) {
      // Log the error and stack trace for better debugging
      log('Error: $e');
      log('Stack trace: $stacktrace');

      throw GluttexException(e.response?.data["error_code"],
          statusCode: e.response?.statusCode, error: e);
    } catch (e) {
      return 500;
    }
  }

  @override
  Future<String?> insertBinary(String destination, FormData data) async {
    try {
      // Log the request data
      // log('Request data: ${data.files}');
      log('Sending data to $destination');
      // log(json.encode(data));
      // Make the POST request
      final response = await _dio.put(
        destination,
        data: data,
        options: Options(headers: {
          'accept': 'application/json',
          'Content-Type': 'multipart/form-data',
        }),
      );

      // Log the response status code and data
      // //log('Response status code: ${response.statusCode}');
      log('Response data uploading image: ${response.data}');

      // Check the response status code
      return response.data['path'].toString().replaceFirst("files/", "");

      // Return success message
    } on DioException catch (e, stacktrace) {
      // Log the error and stack trace for better debugging
      log('Error: $e');
      log('Stack trace: $stacktrace');

      throw GluttexException(e.response?.data["error_code"],
          statusCode: e.response?.statusCode, error: e);
    } catch (e) {
      return "";
    }
  }

  @override
  Future<dynamic> update(String destination, String id,
      Map<String, dynamic> parameters, Map<String, dynamic> data) async {
    try {
      log('Sending data to $destination');
      // log(data.toString());
      log(data.toString());
      final response = await _dio.put(destination,
          data: data,
          queryParameters: parameters,
          options: Options(headers: {'Content-Type': 'application/json'}));
      log('Update Response data: ${response.data}');
      return response.data;
    } on DioException catch (e, stacktrace) {
      log('Error: $e');
      log('Stack trace: $stacktrace');

      // throw GluttexException(e.response?.data?["error_code"],
      //     statusCode: e.response?.statusCode, error: e);
    }
  }

  @override
  Future<dynamic> signUpUsingUsernameAndPassword(
      String destination, Map<String, dynamic> data) async {
    try {
      log('Sending data: $data'); // ✅ Log request data

      final response = await _dio.post(
        destination,
        data: data, // ✅ Removed json.encode(data)
        options: Options(
          validateStatus: (status) => status == 200 || status == 406,
          headers: {
            'Content-Type': 'application/json',
            'accept': 'application/json',
          },
        ),
      );

      log('Response: ${response.data}'); // ✅ Log response

      if (response.statusCode == 406) {
        throw Exception(response.data["detail"]);
      }

      return response.data;
    } on DioException catch (e) {
      log('Dio Error: ${e.response?.data ?? e.message}'); // ✅ Better error logging
      throw GluttexException(e.response?.data["error_code"],
          statusCode: e.response?.statusCode, error: e);
    } catch (e) {
      log('Unexpected Error: $e'); // ✅ Catch other errors
      throw Exception('Unexpected error occurred.');
    }
  }

  @override
  Future<dynamic> signInUsingUsernameAndPassword(
      String destination, Map<String, dynamic> data) async {
    try {
      log('${json.encode(data)}');
      final response = await _dio.post(destination,
          data: json.encode(data),
          options: Options(
              validateStatus: (status) => status == 200 || status == 406,
              headers: {
                'Content-Type': 'application/json',
                'accept': 'application/json'
              }));
      if (response.statusCode == 406) {
        log(response.data.toString());
        GluttexException("INCORRECT_CREDENTIALS",
            statusCode: 406, error: response.data.toString());
      }
      log(response.data.toString());
      return response.data;
    } on DioException catch (e) {
      // Return server error message
      log('${e.response}');
      // String error_code = getErrorCode(e);

      // throw GluttexException(error_code,
      //     statusCode: e.response?.statusCode ?? 501, error: "");
    }
  }

  @override
  Future<dynamic> signInUsingProvider(String destination, String providerName,
      Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(destination,
          data: json.encode(data),
          options: Options(headers: {
            'Content-Type': 'application/json',
            'accept': 'application/json'
          }));

      return response.data;
    } on DioException catch (e, stacktrace) {
      log('Error: $e');
      log('Stack trace: $stacktrace');

      throw GluttexException(e.response?.data["error_code"],
          statusCode: e.response?.statusCode, error: e);
    }
  }

  // String getErrorCode(DioException e) {
  //   try {
  //     // Check if response exists and has data
  //     if (e.response?.data != null) {
  //       final responseData = e.response!.data;

  //       // Handle case where data is a Map
  //       if (responseData is Map<String, dynamic>) {
  //         return responseData['error_code']?.toString() ??
  //             'INCORRECT_CREDENTIALS';
  //       }
  //       // Handle case where data is a String (might be JSON encoded)
  //       else if (responseData is String) {
  //         try {
  //           final decoded = jsonDecode(responseData) as Map<String, dynamic>;
  //           return decoded['error_code']?.toString() ?? 'UNKNOWN_ERROR';
  //         } catch (_) {
  //           return 'HTTP_EXCEPTION';
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     developer.log('Error extracting error_code', error: e);
  //   }

  //   return 'HTTP_EXCEPTION';
  // }
}
