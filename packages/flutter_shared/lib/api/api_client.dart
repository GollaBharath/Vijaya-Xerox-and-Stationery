import 'package:http/http.dart' as http;
import 'dart:convert';
import '../auth/token_manager.dart';

/// API client for communicating with Vijaya Xerox backend
class ApiClient {
  final String baseUrl;
  final TokenManager tokenManager;

  // HTTP client
  late http.Client _httpClient;

  ApiClient({required this.baseUrl, required this.tokenManager}) {
    _httpClient = http.Client();
  }

  /// Build headers with authorization token
  Future<Map<String, String>> _buildHeaders({
    bool withAuth = true,
    String contentType = 'application/json',
  }) async {
    final headers = {'Content-Type': contentType, 'Accept': 'application/json'};

    if (withAuth) {
      final token = await tokenManager.getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Handle response errors
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw ApiException('Failed to decode response: $e');
      }
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Unauthorized: ${response.body}');
    } else if (response.statusCode == 403) {
      throw ForbiddenException('Forbidden: ${response.body}');
    } else if (response.statusCode == 404) {
      throw NotFoundException('Not found: ${response.body}');
    } else if (response.statusCode == 422) {
      try {
        final error = jsonDecode(response.body);
        throw ValidationException(
          'Validation error: ${error['message'] ?? response.body}',
        );
      } catch (e) {
        throw ValidationException('Validation error: ${response.body}');
      }
    } else if (response.statusCode >= 500) {
      throw ServerException(
        'Server error: ${response.statusCode} - ${response.body}',
      );
    } else {
      throw ApiException('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  /// GET request
  Future<dynamic> get(String endpoint, {bool withAuth = true}) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = await _buildHeaders(withAuth: withAuth);

      final response = await _httpClient.get(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  /// POST request
  Future<dynamic> post(
    String endpoint, {
    dynamic body,
    bool withAuth = true,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = await _buildHeaders(withAuth: withAuth);

      final response = await _httpClient.post(
        url,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  /// PATCH request
  Future<dynamic> patch(
    String endpoint, {
    dynamic body,
    bool withAuth = true,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = await _buildHeaders(withAuth: withAuth);

      final response = await _httpClient.patch(
        url,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  /// DELETE request
  Future<dynamic> delete(String endpoint, {bool withAuth = true}) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = await _buildHeaders(withAuth: withAuth);

      final response = await _httpClient.delete(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Multipart file upload request
  Future<dynamic> multipartPost(
    String endpoint, {
    required Map<String, String> fields,
    required Map<String, List<int>> files, // filename -> file bytes
    bool withAuth = true,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = await _buildHeaders(
        withAuth: withAuth,
        contentType: 'multipart/form-data',
      );

      // Remove Content-Type for multipart requests (http package will set it with boundary)
      headers.remove('Content-Type');

      var request = http.MultipartRequest('POST', url)..headers.addAll(headers);

      // Add fields
      fields.forEach((key, value) {
        request.fields[key] = value;
      });

      // Add files
      files.forEach((filename, bytes) {
        request.files.add(
          http.MultipartFile.fromBytes('file', bytes, filename: filename),
        );
      });

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final httpResponse = http.Response(
        responseBody,
        response.statusCode,
        headers: response.headers,
      );

      return _handleResponse(httpResponse);
    } catch (e) {
      rethrow;
    }
  }

  /// Close HTTP client
  void close() {
    _httpClient.close();
  }
}

// Custom exceptions
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message);
}

class ForbiddenException extends ApiException {
  ForbiddenException(String message) : super(message);
}

class NotFoundException extends ApiException {
  NotFoundException(String message) : super(message);
}

class ValidationException extends ApiException {
  ValidationException(String message) : super(message);
}

class ServerException extends ApiException {
  ServerException(String message) : super(message);
}
