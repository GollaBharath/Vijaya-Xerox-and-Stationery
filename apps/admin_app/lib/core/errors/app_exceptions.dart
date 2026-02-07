/// Custom exception classes for the Admin App
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() => message;
}

/// Network-related exceptions
class NetworkException extends AppException {
  const NetworkException(String message, {String? code, dynamic details})
    : super(message, code: code, details: details);
}

/// Server error exceptions (5xx)
class ServerException extends AppException {
  const ServerException(String message, {String? code, dynamic details})
    : super(message, code: code, details: details);
}

/// Client error exceptions (4xx)
class ClientException extends AppException {
  const ClientException(String message, {String? code, dynamic details})
    : super(message, code: code, details: details);
}

/// Unauthorized exception (401)
class UnauthorizedException extends AppException {
  const UnauthorizedException([
    String message = 'Unauthorized. Please login again.',
    String code = '401',
    dynamic details,
  ]) : super(message, code: code, details: details);
}

/// Forbidden exception (403)
class ForbiddenException extends AppException {
  const ForbiddenException([
    String message = 'You do not have permission to perform this action.',
    String code = '403',
    dynamic details,
  ]) : super(message, code: code, details: details);
}

/// Not found exception (404)
class NotFoundException extends AppException {
  const NotFoundException([
    String message = 'The requested resource was not found.',
    String code = '404',
    dynamic details,
  ]) : super(message, code: code, details: details);
}

/// Validation exception (422)
class ValidationException extends AppException {
  final Map<String, List<String>>? errors;

  const ValidationException(
    String message, {
    String code = '422',
    this.errors,
    dynamic details,
  }) : super(message, code: code, details: details);

  String? getFieldError(String field) {
    if (errors == null || !errors!.containsKey(field)) return null;
    return errors![field]!.isNotEmpty ? errors![field]!.first : null;
  }

  List<String>? getFieldErrors(String field) {
    return errors?[field];
  }
}

/// Timeout exception
class TimeoutException extends AppException {
  const TimeoutException([
    String message = 'Request timed out. Please try again.',
    String code = 'TIMEOUT',
    dynamic details,
  ]) : super(message, code: code, details: details);
}

/// File upload exception
class FileUploadException extends AppException {
  const FileUploadException(String message, {String? code, dynamic details})
    : super(message, code: code, details: details);
}

/// Cache exception
class CacheException extends AppException {
  const CacheException(String message, {String? code, dynamic details})
    : super(message, code: code, details: details);
}

/// Parse exception
class ParseException extends AppException {
  const ParseException([
    String message = 'Failed to parse response data.',
    String code = 'PARSE_ERROR',
    dynamic details,
  ]) : super(message, code: code, details: details);
}

/// Generic unknown exception
class UnknownException extends AppException {
  const UnknownException([
    String message = 'An unknown error occurred. Please try again.',
    String code = 'UNKNOWN',
    dynamic details,
  ]) : super(message, code: code, details: details);
}

/// Connection exception
class ConnectionException extends NetworkException {
  const ConnectionException([
    String message = 'No internet connection. Please check your network.',
    String code = 'NO_CONNECTION',
    dynamic details,
  ]) : super(message, code: code, details: details);
}
