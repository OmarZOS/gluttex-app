library gluttex_impl_mediation;

import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:gluttex_constants/gluttex_constants.dart';
import 'package:gluttex_core/app/GluttexException.dart';
import 'package:gluttex_core/mediation/StorageService.dart';

class StorageServiceImpl extends StorageService<FormData> {
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

  void _logRequest(String method, String url,
      {dynamic data, dynamic params, String? callerKey}) {
    developer.log('[$method] $url', name: 'StorageService');
    if (callerKey != null) {
      developer.log('CallerKey: $callerKey', name: 'StorageService');
    }
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

  // Helper method to get caller key with default
  String _getCallerKey(String? providedKey, String defaultKey) {
    return providedKey ??
        '${defaultKey}_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<int?> delete(String destination, String id,
      {String? callerKey}) async {
    final key = _getCallerKey(callerKey, 'delete_$id');
    final url = '$destination/$id';
    _logRequest('DELETE', url, callerKey: key);

    try {
      final response = await _dio.delete(url);
      setSuccessResponse(key, response.statusCode,
          statusCode: response.statusCode);
      return response.statusCode;
    } on DioException catch (e) {
      setFailureResponse(
        key,
        data: e.message,
        statusCode: e.response?.statusCode,
        errorCode: 'DELETE_FAILED',
        message: e.message,
      );
      throw _createGluttexException(e);
    }
  }

  @override
  Future<dynamic> get(String destination, String id,
      {String? callerKey}) async {
    final key = _getCallerKey(callerKey, 'get_$id');
    final url = '$destination/$id';
    _logRequest('GET', url, callerKey: key);

    try {
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        _logResponse(response.data);
        setSuccessResponse(key, response.data, statusCode: response.statusCode);
        return response.data;
      } else if (response.statusCode == 404) {
        setFailureResponse(
          key,
          data: GluttexConstants.notFoundError,
          statusCode: 404,
          errorCode: 'NOT_FOUND',
          message: GluttexConstants.notFoundError,
        );
        throw Exception(GluttexConstants.notFoundError);
      } else {
        setFailureResponse(
          key,
          data: GluttexConstants.getFailure,
          statusCode: response.statusCode,
          errorCode: 'GET_FAILED',
          message: GluttexConstants.getFailure,
        );
        throw Exception(GluttexConstants.getFailure);
      }
    } on DioException catch (e) {
      developer.log('GET Error: ${e.message}', name: 'StorageService');
      developer.log('URL: $url', name: 'StorageService');
      setFailureResponse(
        key,
        data: e.message,
        statusCode: e.response?.statusCode,
        errorCode: 'DIO_EXCEPTION',
        message: e.message,
      );
      throw _createGluttexException(e);
    }
  }

  @override
  Future<dynamic> getAll(String destination,
      {params, String? callerKey}) async {
    final key = _getCallerKey(callerKey, 'getAll');
    _logRequest('GET', destination, params: params, callerKey: key);

    try {
      final response = await _dio.get(destination, queryParameters: params);

      if (response.statusCode == 200) {
        setSuccessResponse(key, response.data, statusCode: response.statusCode);
        return response.data;
      } else if (response.statusCode == 404) {
        setFailureResponse(
          key,
          data: GluttexConstants.notFoundError,
          statusCode: 404,
          errorCode: 'NOT_FOUND',
          message: GluttexConstants.notFoundError,
        );
        throw Exception(GluttexConstants.notFoundError);
      } else {
        setFailureResponse(
          key,
          data: GluttexConstants.getFailure,
          statusCode: response.statusCode,
          errorCode: 'GET_FAILED',
          message: GluttexConstants.getFailure,
        );
        throw Exception(GluttexConstants.getFailure);
      }
    } on DioException catch (e) {
      developer.log('GET All Error: ${e.message}', name: 'StorageService');
      setFailureResponse(
        key,
        data: e.message,
        statusCode: e.response?.statusCode,
        errorCode: 'DIO_EXCEPTION',
        message: e.message,
      );
      throw _createGluttexException(e);
    }
  }

  @override
  Future<dynamic> insert(String destination, Map<String, dynamic> data,
      {params, String? callerKey}) async {
    final key = _getCallerKey(callerKey, 'insert');
    _logRequest('POST', destination,
        data: data, params: params, callerKey: key);

    try {
      developer.log('Data type: ${data.runtimeType}', name: 'StorageService');
      developer.log('Params type: ${params?.runtimeType}',
          name: 'StorageService');

      final jsonString = jsonEncode(data);
      developer.log('Full JSON being sent:${data.toString()}',
          name: 'StorageService');
      developer.log(jsonString, name: 'StorageService');

      // Validate JSON
      try {
        jsonDecode(jsonString);
      } catch (e) {
        developer.log('JSON VALIDATION ERROR: $e', name: 'StorageService');
      }

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

      setSuccessResponse(key, response.data, statusCode: response.statusCode);
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

      setFailureResponse(
        key,
        data: e.message,
        statusCode: e.response?.statusCode,
        errorCode: 'INSERT_FAILED',
        message: e.message,
      );
      throw _createGluttexException(e);
    } catch (e, stackTrace) {
      developer.log('❌ UNEXPECTED INSERT ERROR: $e', name: 'StorageService');
      developer.log('Stack trace: $stackTrace', name: 'StorageService');
      setFailureResponse(
        key,
        data: e.toString(),
        statusCode: 500,
        errorCode: 'UNEXPECTED_ERROR',
        message: e.toString(),
      );
      rethrow;
    }
  }

  @override
  Future<dynamic> insertBinary(String destination, FormData data,
      {String? callerKey}) async {
    final key = _getCallerKey(callerKey, 'insertBinary');
    _logRequest('POST', destination,
        data: 'FormData with ${data.files.length} files', callerKey: key);

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
      setSuccessResponse(key, response.data, statusCode: response.statusCode);
      return response.data;
    } on DioException catch (e) {
      developer.log('Insert Binary Error: ${e.message}',
          name: 'StorageService');
      setFailureResponse(
        key,
        data: e.message,
        statusCode: e.response?.statusCode,
        errorCode: 'UPLOAD_FAILED',
        message: e.message,
      );
      throw GluttexException(
        e.response?.data?['error_code']?.toString() ?? 'UPLOAD_FAILED',
        statusCode: e.response?.statusCode,
        error: e,
      );
    } catch (e) {
      developer.log('Unexpected binary upload error: $e',
          name: 'StorageService');
      setFailureResponse(
        key,
        data: e.toString(),
        statusCode: 500,
        errorCode: 'UNEXPECTED_UPLOAD_ERROR',
        message: e.toString(),
      );
      return "";
    }
  }

  @override
  Future<dynamic> update(String destination, String id,
      Map<String, dynamic> parameters, Map<String, dynamic> data,
      {String? callerKey}) async {
    final key = _getCallerKey(callerKey, 'update_$id');
    final url = '$destination/$id';
    _logRequest('PUT', url, data: data, params: parameters, callerKey: key);

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
      setSuccessResponse(key, response.data, statusCode: response.statusCode);
      return response.data;
    } on DioException catch (e) {
      developer.log('Update Error: ${e.message}', name: 'StorageService');
      developer.log('Error Stack: ${e.stackTrace}', name: 'StorageService');
      setFailureResponse(
        key,
        data: e.message,
        statusCode: e.response?.statusCode,
        errorCode: 'UPDATE_FAILED',
        message: e.message,
      );
      throw _createGluttexException(e);
    }
  }

  @override
  Future<dynamic> signUpUsingUsernameAndPassword(
      String destination, Map<String, dynamic> data,
      {String? callerKey}) async {
    final key = _getCallerKey(callerKey, 'signUp');
    _logRequest('POST', destination, data: data, callerKey: key);

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
        setFailureResponse(
          key,
          data: response.data["detail"],
          statusCode: 406,
          errorCode: 'SIGNUP_FAILED',
          message: response.data["detail"],
        );
        throw Exception(response.data["detail"]);
      }

      setSuccessResponse(key, response.data, statusCode: response.statusCode);
      return response.data;
    } on DioException catch (e) {
      developer.log('SignUp Dio Error: ${e.message}', name: 'StorageService');
      setFailureResponse(
        key,
        data: e.message,
        statusCode: e.response?.statusCode,
        errorCode: 'SIGNUP_DIO_ERROR',
        message: e.message,
      );
      throw _createGluttexException(e);
    } catch (e) {
      developer.log('Unexpected SignUp Error: $e', name: 'StorageService');
      setFailureResponse(
        key,
        data: e.toString(),
        statusCode: 500,
        errorCode: 'UNEXPECTED_SIGNUP_ERROR',
        message: e.toString(),
      );
      throw Exception('Unexpected error occurred.');
    }
  }

  @override
  Future<dynamic> signInUsingUsernameAndPassword(
      String destination, Map<String, dynamic> data,
      {String? callerKey}) async {
    final key = _getCallerKey(callerKey, 'signIn');
    _logRequest('POST', destination, data: data, callerKey: key);

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
        setFailureResponse(
          key,
          data: response.data.toString(),
          statusCode: 406,
          errorCode: 'INCORRECT_CREDENTIALS',
          message: 'Invalid username or password',
        );
        throw GluttexException(
          "INCORRECT_CREDENTIALS",
          statusCode: 406,
          error: response.data.toString(),
        );
      }

      setSuccessResponse(key, response.data, statusCode: response.statusCode);
      return response.data;
    } on DioException catch (e) {
      developer.log('SignIn Dio Error: ${e.message}', name: 'StorageService');
      setFailureResponse(
        key,
        data: e.message,
        statusCode: e.response?.statusCode,
        errorCode: 'SIGNIN_DIO_ERROR',
        message: e.message,
      );
      throw _createGluttexException(e);
    }
  }

  @override
  Future<dynamic> signInUsingProvider(
      String destination, String providerName, Map<String, dynamic> data,
      {String? callerKey}) async {
    final key = _getCallerKey(callerKey, 'signInProvider_$providerName');
    _logRequest('PUT', destination, data: data, callerKey: key);

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

      setSuccessResponse(key, response.data, statusCode: response.statusCode);
      return response.data;
    } on DioException catch (e) {
      developer.log('Provider SignIn Error: ${e.message}',
          name: 'StorageService');
      setFailureResponse(
        key,
        data: e.message,
        statusCode: e.response?.statusCode,
        errorCode: 'PROVIDER_SIGNIN_FAILED',
        message: e.message,
      );
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
