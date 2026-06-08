// gluttex_core/lib/app/GluttexException.dart
class GluttexException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic error;
  final String? responseCode;
  final Map<String, dynamic>? details;

  GluttexException(
    this.message, {
    this.statusCode,
    this.error,
    this.responseCode,
    this.details,
  });

  @override
  String toString() {
    return 'GluttexException: $message (statusCode: $statusCode, responseCode: $responseCode)';
  }
}
