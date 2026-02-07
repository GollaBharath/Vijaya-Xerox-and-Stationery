import 'dart:io';
import 'package:http/http.dart' as http;
import 'app_exceptions.dart';

/// Maps various errors to user-friendly messages and appropriate exceptions
class ErrorMapper {
  /// Map HTTP response to appropriate exception
  static AppException mapHttpError(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;

    String message =
        _extractErrorMessage(body) ?? _getDefaultMessage(statusCode);

    switch (statusCode) {
      case 400:
        return ClientException(message, code: '400', details: body);
      case 401:
        return UnauthorizedException(message, '401', body);
      case 403:
        return ForbiddenException(message, '403', body);
      case 404:
        return NotFoundException(message, '404', body);
      case 422:
        final errors = _extractValidationErrors(body);
        return ValidationException(
          message,
          code: '422',
          errors: errors,
          details: body,
        );
      case 429:
        return ClientException(
          'Too many requests. Please slow down.',
          code: '429',
          details: body,
        );
      case 500:
      case 501:
      case 502:
      case 503:
      case 504:
        return ServerException(
          message,
          code: statusCode.toString(),
          details: body,
        );
      default:
        if (statusCode >= 400 && statusCode < 500) {
          return ClientException(
            message,
            code: statusCode.toString(),
            details: body,
          );
        } else if (statusCode >= 500) {
          return ServerException(
            message,
            code: statusCode.toString(),
            details: body,
          );
        }
        return UnknownException(message, statusCode.toString(), body);
    }
  }

  /// Map generic exceptions to appropriate app exceptions
  static AppException mapException(dynamic error) {
    if (error is AppException) {
      return error;
    }

    if (error is SocketException) {
      return const ConnectionException();
    }

    if (error is HttpException) {
      return NetworkException(error.message);
    }

    if (error is FormatException) {
      return ParseException(error.message);
    }

    if (error is TimeoutException) {
      return const TimeoutException();
    }

    return UnknownException(error.toString(), 'UNKNOWN', error);
  }

  /// Get user-friendly error message
  static String getUserMessage(AppException exception) {
    if (exception is UnauthorizedException) {
      return 'Your session has expired. Please login again.';
    }
    if (exception is ForbiddenException) {
      return 'You do not have permission to perform this action.';
    }
    if (exception is NotFoundException) {
      return 'The requested resource was not found.';
    }
    if (exception is ValidationException) {
      return exception.message;
    }
    if (exception is ConnectionException) {
      return 'No internet connection. Please check your network.';
    }
    if (exception is TimeoutException) {
      return 'Request timed out. Please try again.';
    }
    if (exception is ServerException) {
      return 'Server error. Please try again later.';
    }
    return exception.message;
  }

  /// Extract error message from response body
  static String? _extractErrorMessage(String body) {
    try {
      // Try to parse JSON and extract error message
      // This is a simplified version - in production, use proper JSON parsing
      if (body.contains('"error"')) {
        final start = body.indexOf('"error"');
        final messageStart = body.indexOf(':', start) + 1;
        final messageEnd = body.indexOf(',', messageStart);
        if (messageEnd > messageStart) {
          return body
              .substring(messageStart, messageEnd)
              .trim()
              .replaceAll('"', '');
        }
      }
      if (body.contains('"message"')) {
        final start = body.indexOf('"message"');
        final messageStart = body.indexOf(':', start) + 1;
        final messageEnd = body.indexOf(',', messageStart);
        if (messageEnd > messageStart) {
          return body
              .substring(messageStart, messageEnd)
              .trim()
              .replaceAll('"', '');
        }
      }
    } catch (e) {
      // Ignore parsing errors
    }
    return null;
  }

  /// Extract validation errors from response body
  static Map<String, List<String>>? _extractValidationErrors(String body) {
    // Simplified version - in production, use proper JSON parsing
    // This should return a map of field names to error messages
    // Example: {'email': ['Email is required'], 'password': ['Password too short']}
    return null;
  }

  /// Get default error message for status code
  static String _getDefaultMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'The requested resource was not found.';
      case 422:
        return 'Validation error. Please check your input.';
      case 429:
        return 'Too many requests. Please slow down.';
      case 500:
        return 'Internal server error. Please try again later.';
      case 502:
        return 'Bad gateway. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      case 504:
        return 'Gateway timeout. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
