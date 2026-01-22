library gluttex_impl_mediation;

import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/GluttexException.dart';
import 'package:gluttex_core/mediation/StorageService.dart';

class StorageServiceImpl implements StorageService<FormData> {
  final Dio _dio;

  StorageServiceImpl({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 7),
              receiveTimeout: const Duration(seconds: 7),
              sendTimeout: const Duration(seconds: 7),
            ));

  GluttexException _createGluttexException(DioException e) {
    final responseData = e.response?.data;
    String? errorCode;

    if (responseData != null) {
      try {
        if (responseData is Map<String, dynamic>) {
          errorCode = responseData['error_code']?.toString();
        } else if (responseData is String) {
          final decoded = jsonDecode(responseData) as Map<String, dynamic>?;
          errorCode = decoded?['error_code']?.toString();
        }
      } catch (_) {
        // Ignore parsing errors
      }
    }

    return GluttexException(
      errorCode ?? 'HTTP_EXCEPTION',
      statusCode: e.response?.statusCode,
      error: e,
    );
  }

  void _logRequest(String method, String url, {dynamic data, dynamic params}) {
    developer.log('[$method] $url');
    if (params != null) {
      developer.log('Params: $params', name: 'StorageService');
    }
    if (data != null) {
      try {
        final jsonString = jsonEncode(data);
        developer.log(
            'Data: ${jsonString.substring(0, min(200, jsonString.length))}...',
            name: 'StorageService');
      } catch (_) {
        developer.log('Data: $data', name: 'StorageService');
      }
    }
  }

  void _logResponse(dynamic response) {
    try {
      final jsonString = jsonEncode(response);
      developer.log(
          'Response: ${jsonString.substring(0, min(200, jsonString.length))}...',
          name: 'StorageService');
    } catch (_) {
      developer.log('Response: $response', name: 'StorageService');
    }
  }

  int min(int a, int b) => a < b ? a : b;

  @override
  Future<int?> delete(String destination, String id) async {
    final url = '$destination/$id';
    _logRequest('DELETE', url);

    try {
      final response = await _dio.delete(url);
      return response.statusCode;
    } on DioException catch (e) {
      throw _createGluttexException(e);
    }
  }

  @override
  Future<dynamic> get(String destination, String id) async {
    final url = '$destination/$id';
    _logRequest('GET', url);

    try {
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        _logResponse(response.data);
        return response.data;
      } else if (response.statusCode == 404) {
        throw Exception(GluttexConstants.notFoundError);
      } else {
        throw Exception(GluttexConstants.getFailure);
      }
    } on DioException catch (e) {
      developer.log('GET Error: ${e.message}', name: 'StorageService');
      developer.log('URL: $url', name: 'StorageService');
      throw _createGluttexException(e);
    }
  }

  @override
  Future<dynamic> getAll(String destination, {params}) async {
    _logRequest('GET', destination, params: params);

    try {
      final response = await _dio.get(destination, queryParameters: params);

      if (response.statusCode == 200) {
        return response.data;
      } else if (response.statusCode == 404) {
        throw Exception(GluttexConstants.notFoundError);
      } else {
        throw Exception(GluttexConstants.getFailure);
      }
    } on DioException catch (e) {
      developer.log('GET All Error: ${e.message}', name: 'StorageService');
      throw _createGluttexException(e);
    }
  }

  // In StorageServiceImpl, modify the insert method:
  @override
  Future<dynamic> insert(String destination, Map<String, dynamic> data,
      {params}) async {
    // Enhanced logging
    _logRequest('POST', destination, data: data, params: params);

    // Log the full URL with query parameters
    // final uri = Uri.parse(destination);

    // if (params != null) {
    //   final fullUri = uri.replace(
    //       queryParameters: params.map((k, v) => MapEntry(k, v.toString())));
    //   developer.log('Full URL with params: $fullUri', name: 'StorageService');
    // }

    try {
      // 1. Log exactly what's being sent
      developer.log('Data type: ${data.runtimeType}', name: 'StorageService');
      developer.log('Params type: ${params?.runtimeType}',
          name: 'StorageService');

      final jsonString = jsonEncode(data);
      developer.log('Full JSON being sent:${data.toString()}',
          name: 'StorageService');
      developer.log(jsonString, name: 'StorageService');

      // 2. Check for any circular references or issues
      try {
        jsonDecode(jsonString); // Try to decode it back to ensure it's valid
      } catch (e) {
        developer.log('JSON VALIDATION ERROR: $e', name: 'StorageService');
      }

      // 3. Make the request with detailed logging
      developer.log('Making Dio request...', name: 'StorageService');
      final response = await _dio.post(
        destination,
        queryParameters: params,
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          contentType: 'application/json',
        ),
      );

      developer.log('Response status: ${response.statusCode}',
          name: 'StorageService');
      developer.log('Response headers: ${response.headers}',
          name: 'StorageService');

      if (response.data != null) {
        _logResponse(response.data);
      } else {
        developer.log('Response body is null or empty', name: 'StorageService');
      }

      return response.data;
    } on DioException catch (e) {
      // Enhanced error logging
      developer.log('❌ INSERT ERROR DETAILS:', name: 'StorageService');
      developer.log('Error type: ${e.type}', name: 'StorageService');
      developer.log('Error message: ${e.message}', name: 'StorageService');
      developer.log('Error response: ${e.response}', name: 'StorageService');
      developer.log('Error status code: ${e.response?.statusCode}',
          name: 'StorageService');
      developer.log('Error response data: ${e.response?.data}',
          name: 'StorageService');
      developer.log('Error request: ${e.requestOptions}',
          name: 'StorageService');
      developer.log('Error request headers: ${e.requestOptions.headers}',
          name: 'StorageService');
      developer.log('Error request data: ${e.requestOptions.data}',
          name: 'StorageService');

      if (e.response != null) {
        developer.log('Response headers: ${e.response!.headers}',
            name: 'StorageService');
        developer.log('Response real status: ${e.response!.statusCode}',
            name: 'StorageService');
      }

      throw _createGluttexException(e);
    } catch (e, stackTrace) {
      developer.log('❌ UNEXPECTED INSERT ERROR: $e', name: 'StorageService');
      developer.log('Stack trace: $stackTrace', name: 'StorageService');
      rethrow;
    }
  }

  @override
  Future<dynamic> insertBinary(String destination, FormData data) async {
    _logRequest('POST', destination,
        data: 'FormData with ${data.files.length} files');

    try {
      final response = await _dio.post(
        destination,
        data: data,
        options: Options(
          headers: {
            'accept': 'application/json',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      developer.log('Image upload response: ${response.data}',
          name: 'StorageService');
      return response.data;
    } on DioException catch (e) {
      developer.log('Insert Binary Error: ${e.message}',
          name: 'StorageService');
      throw GluttexException(
        e.response?.data?['error_code']?.toString() ?? 'UPLOAD_FAILED',
        statusCode: e.response?.statusCode,
        error: e,
      );
    } catch (e) {
      developer.log('Unexpected binary upload error: $e',
          name: 'StorageService');
      return "";
    }
  }

  @override
  Future<dynamic> update(String destination, String id,
      Map<String, dynamic> parameters, Map<String, dynamic> data) async {
    final url = '$destination/$id';
    _logRequest('PUT', url, data: data, params: parameters);

    try {
      final response = await _dio.put(
        url,
        data: data,
        queryParameters: parameters,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          contentType: 'application/json',
        ),
      );

      developer.log('Update Response: ${response.data}',
          name: 'StorageService');
      return response.data;
    } on DioException catch (e) {
      developer.log('Update Error: ${e.message}', name: 'StorageService');
      developer.log('Error Stack: ${e.stackTrace}', name: 'StorageService');
      throw _createGluttexException(e);
    }
  }

  @override
  Future<dynamic> signUpUsingUsernameAndPassword(
      String destination, Map<String, dynamic> data) async {
    _logRequest('POST', destination, data: data);

    try {
      final response = await _dio.post(
        destination,
        data: data,
        options: Options(
          validateStatus: (status) => status == 200 || status == 406,
          headers: {
            'Content-Type': 'application/json',
            'accept': 'application/json',
          },
          contentType: 'application/json',
        ),
      );

      developer.log('SignUp Response: ${response.data}',
          name: 'StorageService');

      if (response.statusCode == 406) {
        throw Exception(response.data["detail"]);
      }

      return response.data;
    } on DioException catch (e) {
      developer.log('SignUp Dio Error: ${e.message}', name: 'StorageService');
      throw _createGluttexException(e);
    } catch (e) {
      developer.log('Unexpected SignUp Error: $e', name: 'StorageService');
      throw Exception('Unexpected error occurred.');
    }
  }

  @override
  Future<dynamic> signInUsingUsernameAndPassword(
      String destination, Map<String, dynamic> data) async {
    _logRequest('POST', destination, data: data);

    try {
      final response = await _dio.post(
        destination,
        data: data,
        options: Options(
          validateStatus: (status) => status == 200 || status == 406,
          headers: {
            'Content-Type': 'application/json',
            'accept': 'application/json',
          },
          contentType: 'application/json',
        ),
      );

      developer.log('SignIn Response: ${response.data}',
          name: 'StorageService');

      if (response.statusCode == 406) {
        throw GluttexException(
          "INCORRECT_CREDENTIALS",
          statusCode: 406,
          error: response.data.toString(),
        );
      }

      return response.data;
    } on DioException catch (e) {
      developer.log('SignIn Dio Error: ${e.message}', name: 'StorageService');
      throw _createGluttexException(e);
    }
  }

  @override
  Future<dynamic> signInUsingProvider(String destination, String providerName,
      Map<String, dynamic> data) async {
    _logRequest('PUT', destination, data: data);

    try {
      final response = await _dio.put(
        destination,
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'accept': 'application/json',
          },
          contentType: 'application/json',
        ),
      );

      return response.data;
    } on DioException catch (e) {
      developer.log('Provider SignIn Error: ${e.message}',
          name: 'StorageService');
      throw _createGluttexException(e);
    }
  }

  @override
  FormData toFormData(dynamic destination) {
    return FormData.fromMap({
      'file': MultipartFile.fromBytes(
        destination is List<int> ? destination : destination as List<int>,
        filename: 'upload.jpg',
      ),
    });
  }
}
