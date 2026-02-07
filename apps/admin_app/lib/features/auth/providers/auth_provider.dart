import 'package:flutter/foundation.dart';
import 'package:flutter_shared/models/user.dart';
import 'package:flutter_shared/auth/auth_service.dart';
import 'package:flutter_shared/auth/token_manager.dart';
import 'package:flutter_shared/api/api_client.dart';
import '../../../core/errors/app_exceptions.dart' as local_exceptions;
import '../../../core/config/constants.dart';
import '../../../core/config/env.dart';

/// Authentication state provider for admin app
class AuthProvider extends ChangeNotifier {
  late final AuthService _authService;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider() {
    final tokenManager = TokenManager();
    final apiClient = ApiClient(
      tokenManager: tokenManager,
      baseUrl: Env.baseUrl,
    );
    _authService = AuthService(
      apiClient: apiClient,
      tokenManager: tokenManager,
    );
  }

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.role == AppConstants.roleAdmin;

  /// Initialize auth state - check if user is logged in
  Future<void> initialize() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Check if user is logged in
      final isLoggedIn = await _authService.isLoggedIn();

      if (isLoggedIn) {
        // Fetch current user from API
        _currentUser = await _authService.getCurrentUser();

        // Verify user is admin
        if (_currentUser?.role != AppConstants.roleAdmin) {
          _errorMessage = 'Access denied. Admin privileges required.';
          await logout();
        }
      }
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Attempt login
      _currentUser = await _authService.login(email: email, password: password);

      // Verify user is admin
      if (_currentUser?.role != AppConstants.roleAdmin) {
        _errorMessage = 'Access denied. Admin privileges required.';
        await logout();
        return false;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      // Ignore logout errors, clear local state anyway
      debugPrint('Logout error: $e');
    } finally {
      _currentUser = null;
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresh current user data
  Future<void> refreshUser() async {
    try {
      if (!isAuthenticated) return;

      _currentUser = await _authService.getCurrentUser();

      // Verify user is still admin
      if (_currentUser?.role != AppConstants.roleAdmin) {
        _errorMessage = 'Access denied. Admin privileges revoked.';
        await logout();
      } else {
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = _getErrorMessage(e);

      // If unauthorized, logout
      if (e is local_exceptions.UnauthorizedException) {
        await logout();
      }
    }
  }

  /// Get user-friendly error message from exception
  String _getErrorMessage(dynamic error) {
    if (error is local_exceptions.UnauthorizedException) {
      return 'Invalid email or password.';
    } else if (error is local_exceptions.ForbiddenException) {
      return 'Access denied. Admin privileges required.';
    } else if (error is local_exceptions.ConnectionException) {
      return 'No internet connection. Please check your network.';
    } else if (error is local_exceptions.TimeoutException) {
      return 'Request timed out. Please try again.';
    } else if (error is local_exceptions.AppException) {
      return error.message;
    } else {
      return 'An error occurred. Please try again.';
    }
  }
}
