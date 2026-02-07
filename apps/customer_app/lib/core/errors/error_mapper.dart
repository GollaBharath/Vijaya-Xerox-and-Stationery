import 'app_exceptions.dart';

/// Maps exceptions to user-friendly error messages
class ErrorMapper {
  /// Convert exception to user-friendly message
  static String mapExceptionToMessage(dynamic exception) {
    if (exception is AppException) {
      return exception.message;
    }

    if (exception is TimeoutException) {
      return 'Request took too long. Please check your internet connection.';
    }

    if (exception is NetworkException) {
      return 'Network error. Please check your internet connection.';
    }

    if (exception is UnauthorizedException) {
      return 'You are not authorized. Please log in again.';
    }

    if (exception is NotFoundException) {
      return 'The requested resource was not found.';
    }

    if (exception is ValidationException) {
      return exception.message;
    }

    if (exception is ServerException) {
      return 'Server error. Please try again later.';
    }

    if (exception is StorageException) {
      return 'Local storage error. Please try again.';
    }

    if (exception is ParseException) {
      return 'Error processing data. Please try again.';
    }

    // Fallback for unknown exceptions
    return 'An unexpected error occurred. Please try again.';
  }

  /// Convert exception to error code
  static String mapExceptionToCode(dynamic exception) {
    if (exception is AppException) {
      return exception.code ?? 'UNKNOWN_ERROR';
    }
    return 'UNKNOWN_ERROR';
  }

  /// Check if error is recoverable
  static bool isRecoverableError(dynamic exception) {
    return exception is! UnauthorizedException &&
        exception is! AuthException &&
        exception is! NotFoundException;
  }

  /// Check if error requires login
  static bool requiresReLogin(dynamic exception) {
    return exception is UnauthorizedException ||
        (exception is AuthException &&
            (exception.code == 'INVALID_TOKEN' ||
                exception.code == 'TOKEN_EXPIRED'));
  }
}
