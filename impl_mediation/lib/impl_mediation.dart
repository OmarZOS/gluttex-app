library impl_mediation;

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
    String? message;
    int? statusCode = e.response?.statusCode;
    Map<String, dynamic>? details;

    if (responseData != null) {
      try {
        if (responseData is Map<String, dynamic>) {
          // Handle the new error format from backend
          // {
          //   "success": false,
          //   "status_code": 401,
          //   "code": "INCORRECT_CREDENTIALS",
          //   "message": "Authentication failed",
          //   "details": {...}
          // }
          errorCode = responseData['code']?.toString() ??
              responseData['error_code']?.toString();
          message = responseData['message']?.toString();
          statusCode = responseData['status_code'] as int? ?? statusCode;
          details = responseData['details'] as Map<String, dynamic>?;
        } else if (responseData is String) {
          final decoded = jsonDecode(responseData) as Map<String, dynamic>;
          errorCode =
              decoded['code']?.toString() ?? decoded['error_code']?.toString();
          message = decoded['message']?.toString();
          statusCode = decoded['status_code'] as int? ?? statusCode;
          details = decoded['details'] as Map<String, dynamic>?;
        }
      } catch (_) {
        // Ignore parsing errors
      }
    }

    // Fallback to default error codes based on status code
    if (errorCode == null || errorCode.isEmpty) {
      switch (statusCode) {
        case 400:
          errorCode = 'BAD_REQUEST';
          break;
        case 401:
          errorCode = 'UNAUTHORIZED';
          break;
        case 403:
          errorCode = 'FORBIDDEN';
          break;
        case 404:
          errorCode = 'NOT_FOUND';
          break;
        case 409:
          errorCode = 'CONFLICT';
          break;
        case 422:
          errorCode = 'VALIDATION_ERROR';
          break;
        case 429:
          errorCode = 'RATE_LIMITED';
          break;
        case 500:
          errorCode = 'INTERNAL_SERVER_ERROR';
          break;
        case 502:
          errorCode = 'BAD_GATEWAY';
          break;
        case 503:
          errorCode = 'SERVICE_UNAVAILABLE';
          break;
        case 504:
          errorCode = 'GATEWAY_TIMEOUT';
          break;
        default:
          errorCode = 'HTTP_EXCEPTION';
      }
    }

    return GluttexException(
      errorCode,
      statusCode: statusCode,
      error: e,
      responseCode: errorCode,
      details: details,
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
          statusCode: response.statusCode, responseCode: 'SUCCESS');
      return response.statusCode;
    } on DioException catch (e) {
      final gluttexException = _createGluttexException(e);
      setFailureResponse(
        key,
        data: gluttexException.message,
        statusCode: gluttexException.statusCode,
        errorCode: gluttexException.message,
        message: gluttexException.message,
        responseCode: gluttexException.responseCode,
      );
      throw gluttexException;
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
        setSuccessResponse(key, response.data,
            statusCode: response.statusCode, responseCode: 'SUCCESS');
        return response.data;
      } else if (response.statusCode == 404) {
        setFailureResponse(
          key,
          data: GluttexConstants.notFoundError,
          statusCode: 404,
          errorCode: 'NOT_FOUND',
          message: GluttexConstants.notFoundError,
          responseCode: 'NOT_FOUND',
        );
        throw Exception(GluttexConstants.notFoundError);
      } else {
        setFailureResponse(
          key,
          data: GluttexConstants.getFailure,
          statusCode: response.statusCode,
          errorCode: 'GET_FAILED',
          message: GluttexConstants.getFailure,
          responseCode: 'GET_FAILED',
        );
        throw Exception(GluttexConstants.getFailure);
      }
    } on DioException catch (e) {
      developer.log('GET Error: ${e.message}', name: 'StorageService');
      developer.log('URL: $url', name: 'StorageService');
      final gluttexException = _createGluttexException(e);
      setFailureResponse(
        key,
        data: gluttexException.message,
        statusCode: gluttexException.statusCode,
        errorCode: gluttexException.message,
        message: gluttexException.message,
        responseCode: gluttexException.responseCode,
      );
      throw gluttexException;
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
        setSuccessResponse(key, response.data,
            statusCode: response.statusCode, responseCode: 'SUCCESS');
        return response.data;
      } else if (response.statusCode == 404) {
        setFailureResponse(
          key,
          data: GluttexConstants.notFoundError,
          statusCode: 404,
          errorCode: 'NOT_FOUND',
          message: GluttexConstants.notFoundError,
          responseCode: 'NOT_FOUND',
        );
        throw Exception(GluttexConstants.notFoundError);
      } else {
        setFailureResponse(
          key,
          data: GluttexConstants.getFailure,
          statusCode: response.statusCode,
          errorCode: 'GET_FAILED',
          message: GluttexConstants.getFailure,
          responseCode: 'GET_FAILED',
        );
        throw Exception(GluttexConstants.getFailure);
      }
    } on DioException catch (e) {
      developer.log('GET All Error: ${e.message}', name: 'StorageService');
      final gluttexException = _createGluttexException(e);
      setFailureResponse(
        key,
        data: gluttexException.message,
        statusCode: gluttexException.statusCode,
        errorCode: gluttexException.message,
        message: gluttexException.message,
        responseCode: gluttexException.responseCode,
      );
      throw gluttexException;
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

      setSuccessResponse(key, response.data,
          statusCode: response.statusCode, responseCode: 'SUCCESS');
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

      final gluttexException = _createGluttexException(e);
      setFailureResponse(
        key,
        data: gluttexException.message,
        statusCode: gluttexException.statusCode,
        errorCode: gluttexException.message,
        message: gluttexException.message,
        responseCode: gluttexException.responseCode,
      );
      throw gluttexException;
    } catch (e, stackTrace) {
      developer.log('❌ UNEXPECTED INSERT ERROR: $e', name: 'StorageService');
      developer.log('Stack trace: $stackTrace', name: 'StorageService');
      setFailureResponse(
        key,
        data: e.toString(),
        statusCode: 500,
        errorCode: 'UNEXPECTED_ERROR',
        message: e.toString(),
        responseCode: 'UNEXPECTED_ERROR',
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
      setSuccessResponse(key, response.data,
          statusCode: response.statusCode, responseCode: 'SUCCESS');
      return response.data;
    } on DioException catch (e) {
      developer.log('Insert Binary Error: ${e.message}',
          name: 'StorageService');
      final gluttexException = _createGluttexException(e);
      setFailureResponse(
        key,
        data: gluttexException.message,
        statusCode: gluttexException.statusCode,
        errorCode: gluttexException.message,
        message: gluttexException.message,
        responseCode: gluttexException.responseCode,
      );
      throw gluttexException;
    } catch (e) {
      developer.log('Unexpected binary upload error: $e',
          name: 'StorageService');
      setFailureResponse(
        key,
        data: e.toString(),
        statusCode: 500,
        errorCode: 'UNEXPECTED_UPLOAD_ERROR',
        message: e.toString(),
        responseCode: 'UNEXPECTED_UPLOAD_ERROR',
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
      setSuccessResponse(key, response.data,
          statusCode: response.statusCode, responseCode: 'SUCCESS');
      return response.data;
    } on DioException catch (e) {
      developer.log('Update Error: ${e.message}', name: 'StorageService');
      developer.log('Error Stack: ${e.stackTrace}', name: 'StorageService');
      final gluttexException = _createGluttexException(e);
      setFailureResponse(
        key,
        data: gluttexException.message,
        statusCode: gluttexException.statusCode,
        errorCode: gluttexException.message,
        message: gluttexException.message,
        responseCode: gluttexException.responseCode,
      );
      throw gluttexException;
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
          validateStatus: (status) =>
              status == 200 || status == 409 || status == 422,
          headers: {
            'Content-Type': 'application/json',
            'accept': 'application/json',
          },
          contentType: 'application/json',
        ),
      );

      developer.log('SignUp Response: ${response.data}',
          name: 'StorageService');

      if (response.statusCode == 200) {
        setSuccessResponse(key, response.data,
            statusCode: response.statusCode, responseCode: 'SIGNUP_SUCCESS');
        return response.data;
      } else {
        // Handle error response
        final errorData = response.data is Map
            ? response.data
            : jsonDecode(response.data) as Map<String, dynamic>;

        final errorCode = errorData['code'] ?? 'SIGNUP_FAILED';
        final errorMessage = errorData['message'] ?? 'Sign up failed';

        setFailureResponse(
          key,
          data: errorMessage,
          statusCode: response.statusCode,
          errorCode: errorCode,
          message: errorMessage,
          responseCode: errorCode,
        );
        throw GluttexException(
          errorCode,
          statusCode: response.statusCode,
          error: errorMessage,
          responseCode: errorCode,
        );
      }
    } on DioException catch (e) {
      developer.log('SignUp Dio Error: ${e.message}', name: 'StorageService');
      final gluttexException = _createGluttexException(e);
      setFailureResponse(
        key,
        data: gluttexException.message,
        statusCode: gluttexException.statusCode,
        errorCode: gluttexException.message,
        message: gluttexException.message,
        responseCode: gluttexException.responseCode,
      );
      throw gluttexException;
    } catch (e) {
      developer.log('Unexpected SignUp Error: $e', name: 'StorageService');
      setFailureResponse(
        key,
        data: e.toString(),
        statusCode: 500,
        errorCode: 'UNEXPECTED_SIGNUP_ERROR',
        message: e.toString(),
        responseCode: 'UNEXPECTED_SIGNUP_ERROR',
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
      // Use JSON, not form-urlencoded
      final response = await _dio.post(
        destination,
        data: data, // Send as JSON
        options: Options(
          validateStatus: (status) =>
              status == 200 || status == 401 || status == 403 || status == 422,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      developer.log('SignIn Response status: ${response.statusCode}',
          name: 'StorageService');
      developer.log('SignIn Response data: ${response.data}',
          name: 'StorageService');

      if (response.statusCode == 200) {
        setSuccessResponse(key, response.data,
            statusCode: response.statusCode, responseCode: 'LOGIN_SUCCESS');
        return response.data;
      } else {
        // Handle error response
        Map<String, dynamic> errorData;
        if (response.data is Map) {
          errorData = response.data;
        } else if (response.data is String) {
          try {
            errorData = jsonDecode(response.data) as Map<String, dynamic>;
          } catch (_) {
            errorData = {};
          }
        } else {
          errorData = {};
        }

        final errorCode = errorData['code'] ??
            errorData['error_code'] ??
            _getErrorCodeFromStatus(response.statusCode);
        final errorMessage = errorData['message'] ??
            errorData['detail'] ??
            'Authentication failed';
        final details = errorData['details'] as Map<String, dynamic>?;

        developer.log('SignIn Error - Code: $errorCode, Message: $errorMessage',
            name: 'StorageService');

        setFailureResponse(
          key,
          data: errorMessage,
          statusCode: response.statusCode,
          errorCode: errorCode,
          message: errorMessage,
          responseCode: errorCode,
        );

        throw GluttexException(
          errorCode,
          statusCode: response.statusCode,
          error: errorMessage,
          responseCode: errorCode,
          details: details,
        );
      }
    } on DioException catch (e) {
      developer.log('SignIn Dio Error: ${e.message}', name: 'StorageService');
      developer.log('SignIn Dio Response: ${e.response?.data}',
          name: 'StorageService');

      // Try to extract error from Dio response
      String errorCode = 'HTTP_EXCEPTION';
      String errorMessage = e.message ?? 'Network error';
      Map<String, dynamic>? details;

      if (e.response?.data != null) {
        try {
          final responseData = e.response!.data;
          if (responseData is Map) {
            errorCode = responseData['code'] ?? errorCode;
            errorMessage = responseData['message'] ?? errorMessage;
            details = responseData['details'];
          } else if (responseData is String) {
            final decoded = jsonDecode(responseData) as Map<String, dynamic>;
            errorCode = decoded['code'] ?? errorCode;
            errorMessage = decoded['message'] ?? errorMessage;
            details = decoded['details'];
          }
        } catch (_) {}
      }

      final gluttexException = GluttexException(
        errorCode,
        statusCode: e.response?.statusCode,
        error: e,
        responseCode: errorCode,
        details: details,
      );

      setFailureResponse(
        key,
        data: errorMessage,
        statusCode: gluttexException.statusCode,
        errorCode: errorCode,
        message: errorMessage,
        responseCode: errorCode,
      );
      throw gluttexException;
    }
  }

  String _getErrorCodeFromStatus(int? statusCode) {
    switch (statusCode) {
      case 401:
        return 'UNAUTHORIZED';
      case 403:
        return 'FORBIDDEN';
      case 404:
        return 'NOT_FOUND';
      case 409:
        return 'CONFLICT';
      case 422:
        return 'VALIDATION_ERROR';
      case 429:
        return 'RATE_LIMITED';
      case 500:
        return 'INTERNAL_SERVER_ERROR';
      default:
        return 'HTTP_EXCEPTION';
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

      setSuccessResponse(key, response.data,
          statusCode: response.statusCode, responseCode: 'SUCCESS');
      return response.data;
    } on DioException catch (e) {
      developer.log('Provider SignIn Error: ${e.message}',
          name: 'StorageService');
      final gluttexException = _createGluttexException(e);
      setFailureResponse(
        key,
        data: gluttexException.message,
        statusCode: gluttexException.statusCode,
        errorCode: gluttexException.message,
        message: gluttexException.message,
        responseCode: gluttexException.responseCode,
      );
      throw gluttexException;
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
