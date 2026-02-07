import 'env.dart';
import 'constants.dart';

/// API configuration for HTTP requests
class ApiConfig {
  // Base URL
  static String get baseUrl => Env.baseUrl;

  // Timeout configurations
  static Duration get timeout => AppConstants.apiTimeout;
  static Duration get uploadTimeout => AppConstants.uploadTimeout;

  // Common headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Headers with authentication token
  static Map<String, String> headersWithAuth(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };

  // Multipart headers with authentication
  static Map<String, String> multipartHeadersWithAuth(String token) => {
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
  };

  // Pagination parameters
  static Map<String, String> paginationParams({int page = 1, int limit = 20}) =>
      {'page': page.toString(), 'limit': limit.toString()};

  // Debug mode
  static bool get debugMode => Env.enableDebugLogs;
}
