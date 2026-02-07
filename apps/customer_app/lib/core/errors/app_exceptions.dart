/// Base exception for all app exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  AppException({required this.message, this.code, this.originalException});

  @override
  String toString() => message;
}

/// Exception thrown when network request fails
class NetworkException extends AppException {
  NetworkException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
         message: message,
         code: code ?? 'NETWORK_ERROR',
         originalException: originalException,
       );
}

/// Exception thrown when authentication fails
class AuthException extends AppException {
  AuthException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
         message: message,
         code: code ?? 'AUTH_ERROR',
         originalException: originalException,
       );
}

/// Exception thrown when user is unauthorized
class UnauthorizedException extends AppException {
  UnauthorizedException({
    String message = 'Unauthorized access',
    String? code,
    dynamic originalException,
  }) : super(
         message: message,
         code: code ?? 'UNAUTHORIZED',
         originalException: originalException,
       );
}

/// Exception thrown when resource is not found
class NotFoundException extends AppException {
  NotFoundException({
    String message = 'Resource not found',
    String? code,
    dynamic originalException,
  }) : super(
         message: message,
         code: code ?? 'NOT_FOUND',
         originalException: originalException,
       );
}

/// Exception thrown when server validation fails
class ValidationException extends AppException {
  final Map<String, List<String>>? errors;

  ValidationException({
    required String message,
    this.errors,
    String? code,
    dynamic originalException,
  }) : super(
         message: message,
         code: code ?? 'VALIDATION_ERROR',
         originalException: originalException,
       );
}

/// Exception thrown for server errors
class ServerException extends AppException {
  ServerException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
         message: message,
         code: code ?? 'SERVER_ERROR',
         originalException: originalException,
       );
}

/// Exception thrown for timeout errors
class TimeoutException extends AppException {
  TimeoutException({
    String message = 'Request timed out',
    String? code,
    dynamic originalException,
  }) : super(
         message: message,
         code: code ?? 'TIMEOUT',
         originalException: originalException,
       );
}

/// Exception thrown when local operation fails
class StorageException extends AppException {
  StorageException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
         message: message,
         code: code ?? 'STORAGE_ERROR',
         originalException: originalException,
       );
}

/// Exception thrown for parsing errors
class ParseException extends AppException {
  ParseException({
    required String message,
    String? code,
    dynamic originalException,
  }) : super(
         message: message,
         code: code ?? 'PARSE_ERROR',
         originalException: originalException,
       );
}
