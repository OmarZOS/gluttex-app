// GluttexException.dart

class GluttexException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic error;

  GluttexException(this.message, {this.statusCode, this.error});

  @override
  String toString() => 'StorageException: $message (Status: $statusCode)';
}
