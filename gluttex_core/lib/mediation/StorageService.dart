// import 'package:dio/dio.dart';

class CallerResponse {
  final dynamic data;
  final int? statusCode;
  final String? errorCode;
  final String? message;
  final bool isSuccess;
  final DateTime timestamp;

  CallerResponse({
    required this.data,
    this.statusCode,
    this.errorCode,
    this.message,
    required this.isSuccess,
    required this.timestamp,
  });

  factory CallerResponse.success(dynamic data, {int? statusCode}) {
    return CallerResponse(
      data: data,
      statusCode: statusCode ?? 200,
      isSuccess: true,
      timestamp: DateTime.now(),
    );
  }

  factory CallerResponse.failure({
    required dynamic data,
    int? statusCode,
    String? errorCode,
    String? message,
  }) {
    return CallerResponse(
      data: data,
      statusCode: statusCode ?? 500,
      errorCode: errorCode,
      message: message,
      isSuccess: false,
      timestamp: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'CallerResponse(isSuccess: $isSuccess, statusCode: $statusCode, errorCode: $errorCode)';
  }
}

abstract class StorageService<T> {
  // Map to store latest response for each caller key
  final Map<String, CallerResponse> _callerResponses = {};

  // ==================== Response Storage Methods ====================

  /// Store a successful response for a caller key
  void setSuccessResponse(String callerKey, dynamic data, {int? statusCode}) {
    _callerResponses[callerKey] =
        CallerResponse.success(data, statusCode: statusCode);
  }

  /// Store a failure response for a caller key
  void setFailureResponse(
    String callerKey, {
    required dynamic data,
    int? statusCode,
    String? errorCode,
    String? message,
  }) {
    _callerResponses[callerKey] = CallerResponse.failure(
      data: data,
      statusCode: statusCode,
      errorCode: errorCode,
      message: message,
    );
  }

  /// Get the latest response for a caller key
  CallerResponse? getResponse(String callerKey) {
    return _callerResponses[callerKey];
  }

  /// Get the latest response data for a caller key
  dynamic getResponseData(String callerKey) {
    return _callerResponses[callerKey]?.data;
  }

  /// Get the latest status code for a caller key
  int? getStatusCode(String callerKey) {
    return _callerResponses[callerKey]?.statusCode;
  }

  /// Check if the latest call for a caller key was successful
  bool isCallerSuccess(String callerKey) {
    return _callerResponses[callerKey]?.isSuccess ?? false;
  }

  /// Get error message for a caller key
  String? getErrorMessage(String callerKey) {
    return _callerResponses[callerKey]?.message;
  }

  /// Remove response for a caller key
  void clearResponse(String callerKey) {
    _callerResponses.remove(callerKey);
  }

  /// Clear all stored responses
  void clearAllResponses() {
    _callerResponses.clear();
  }

  /// Get all stored responses (for debugging)
  Map<String, CallerResponse> getAllResponses() {
    return Map.unmodifiable(_callerResponses);
  }

  // ==================== Existing Abstract Methods ====================

  Future<dynamic> getAll(String destination,
      {params, String? callerKey}) async {
    return null;
  }

  Future<dynamic> insert(String destination, Map<String, dynamic> data,
      {params, String? callerKey}) async {
    return null;
  }

  T toFormData(T data) {
    throw UnimplementedError();
  }

  Future<dynamic> insertBinary(String destination, T data,
      {String? callerKey}) async {
    return null;
  }

  Future<dynamic> get(String destination, String id,
      {String? callerKey}) async {
    return null;
  }

  Future<int?> delete(String destination, String id,
      {String? callerKey}) async {
    return null;
  }

  Future<dynamic> update(String destination, String id,
      Map<String, dynamic> parameters, Map<String, dynamic> data,
      {String? callerKey}) async {
    return null;
  }

  Future<dynamic> signUpUsingUsernameAndPassword(
      String destination, Map<String, dynamic> data,
      {String? callerKey}) async {
    return null;
  }

  Future<dynamic> signInUsingUsernameAndPassword(
      String destination, Map<String, dynamic> data,
      {String? callerKey}) async {
    return null;
  }

  Future<dynamic> signInUsingProvider(
      String destination, String providerName, Map<String, dynamic> data,
      {String? callerKey}) async {
    return null;
  }
}

// Optional: Extension for easier access
extension StorageServiceExtension on StorageService {
  /// Get response data with automatic type casting
  T? getResponseDataAs<T>(String callerKey) {
    final data = getResponseData(callerKey);
    if (data is T) {
      return data;
    }
    return null;
  }
}
