import 'package:flutter/material.dart';
import 'package:flutter_shared/models/user.dart';
import 'package:flutter_shared/auth/token_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/api_config.dart';
import '../../../core/config/constants.dart';
import '../../../core/errors/app_exceptions.dart';
import '../models/auth_models.dart';

/// Authentication state provider
class AuthProvider extends ChangeNotifier {
  final TokenManager _tokenManager = TokenManager();
  // State variables
  User? _currentUser;
  String? _accessToken;
  String? _refreshToken;
  bool _isLoading = false;
  String? _error;
  bool _isSplashComplete = false;

  // Getters
  User? get currentUser => _currentUser;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get isAuthenticated => _accessToken != null && _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSplashComplete => _isSplashComplete;

  /// Initialize auth from saved tokens
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString(AppConstants.spKeyAuthToken);
      final savedRefreshToken = prefs.getString(AppConstants.spKeyRefreshToken);
      final savedUserJson = prefs.getString(AppConstants.spKeyUser);

      if (savedToken != null && savedUserJson != null) {
        _accessToken = savedToken;
        _refreshToken = savedRefreshToken;
        _currentUser = User.fromJson(jsonDecode(savedUserJson));

        // Try to refresh token
        await _refreshAccessToken();
      }
    } catch (e) {
      // Clear invalid data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.spKeyAuthToken);
      await prefs.remove(AppConstants.spKeyRefreshToken);
      await prefs.remove(AppConstants.spKeyUser);
    }

    _isSplashComplete = true;
    notifyListeners();
  }

  /// Login with email and password
  Future<void> login(String email, String password) async {
    _setLoading(true);
    _error = null;

    try {
      final request = LoginRequest(email: email, password: password);
      final url = ApiConfig.buildUrl(ApiConfig.authLogin);

      // Debug logging
      print('=== LOGIN DEBUG ===');
      print('URL: $url');
      print('Email: $email');
      print('Request body: ${jsonEncode(request.toJson())}');

      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(
            const Duration(milliseconds: AppConstants.connectionTimeout),
            onTimeout: () {
              print('LOGIN TIMEOUT');
              throw TimeoutException();
            },
          );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final data = responseData['data'] as Map<String, dynamic>;
        final userData = data['user'] as Map<String, dynamic>;
        final tokensData = data['tokens'] as Map<String, dynamic>;

        _currentUser = User.fromJson(userData);
        _accessToken = tokensData['accessToken'] as String;
        _refreshToken = tokensData['refreshToken'] as String;

        // Save to local storage
        final authResponse = AuthResponse(
          user: _currentUser!,
          accessToken: _accessToken!,
          refreshToken: _refreshToken!,
        );
        await _saveTokens(authResponse);

        notifyListeners();
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: 'Invalid email or password');
      } else {
        throw ServerException(
          message: 'Login failed. Please try again.',
          originalException: response.body,
        );
      }
    } on AppException catch (e) {
      print('AppException: ${e.message}');
      _error = e.message;
      rethrow;
    } catch (e) {
      print('Login error: $e');
      print('Error type: ${e.runtimeType}');
      _error = 'Login failed: ${e.toString()}';
      throw NetworkException(message: _error!, originalException: e);
    } finally {
      _setLoading(false);
    }
  }

  /// Register a new user
  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final request = RegisterRequest(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );

      final response = await http
          .post(
            Uri.parse(ApiConfig.buildUrl(ApiConfig.authRegister)),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(
            const Duration(milliseconds: AppConstants.connectionTimeout),
            onTimeout: () => throw TimeoutException(),
          );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final data = responseData['data'] as Map<String, dynamic>;
        final userData = data['user'] as Map<String, dynamic>;
        final tokensData = data['tokens'] as Map<String, dynamic>;

        _currentUser = User.fromJson(userData);
        _accessToken = tokensData['accessToken'] as String;
        _refreshToken = tokensData['refreshToken'] as String;

        // Save to local storage
        final authResponse = AuthResponse(
          user: _currentUser!,
          accessToken: _accessToken!,
          refreshToken: _refreshToken!,
        );
        await _saveTokens(authResponse);

        notifyListeners();
      } else if (response.statusCode == 400) {
        final errorBody = jsonDecode(response.body);
        throw ValidationException(
          message: errorBody['message'] ?? 'Registration failed',
          originalException: response.body,
        );
      } else {
        throw ServerException(
          message: 'Registration failed. Please try again.',
          originalException: response.body,
        );
      }
    } on AppException catch (e) {
      _error = e.message;
      rethrow;
    } catch (e) {
      _error = 'Registration failed: ${e.toString()}';
      throw NetworkException(message: _error!, originalException: e);
    } finally {
      _setLoading(false);
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      // Call backend logout if authenticated
      if (_accessToken != null) {
        await http
            .post(
              Uri.parse(ApiConfig.buildUrl(ApiConfig.authLogout)),
              headers: {
                'Authorization': 'Bearer $_accessToken',
                'Content-Type': 'application/json',
              },
            )
            .timeout(
              const Duration(milliseconds: AppConstants.connectionTimeout),
            );
      }
    } catch (e) {
      // Continue logout even if backend call fails
    }

    // Clear local data
    _currentUser = null;
    _accessToken = null;
    _refreshToken = null;
    _error = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.spKeyAuthToken);
    await prefs.remove(AppConstants.spKeyRefreshToken);
    await prefs.remove(AppConstants.spKeyUser);

    // Also clear from TokenManager
    await _tokenManager.clearTokens();

    notifyListeners();
  }

  /// Refresh access token using refresh token
  Future<void> _refreshAccessToken() async {
    if (_refreshToken == null) {
      await logout();
      return;
    }

    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.buildUrl(ApiConfig.authRefresh)),
            headers: {
              'Authorization': 'Bearer $_refreshToken',
              'Content-Type': 'application/json',
            },
          )
          .timeout(
            const Duration(milliseconds: AppConstants.connectionTimeout),
            onTimeout: () => throw TimeoutException(),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['accessToken'];
        _refreshToken = data['refreshToken'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.spKeyAuthToken, _accessToken!);
        await prefs.setString(AppConstants.spKeyRefreshToken, _refreshToken!);

        notifyListeners();
      } else {
        await logout();
      }
    } catch (e) {
      await logout();
    }
  }

  /// Save tokens to local storage
  Future<void> _saveTokens(AuthResponse authResponse) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.spKeyAuthToken,
      authResponse.accessToken,
    );
    await prefs.setString(
      AppConstants.spKeyRefreshToken,
      authResponse.refreshToken,
    );
    await prefs.setString(
      AppConstants.spKeyUser,
      jsonEncode(authResponse.user.toJson()),
    );

    // Also save to TokenManager for API client
    await _tokenManager.saveTokens(
      accessToken: authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
      userId: authResponse.user.id,
      userRole: authResponse.user.role,
    );
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
