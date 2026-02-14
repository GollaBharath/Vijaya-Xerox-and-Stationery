import 'package:flutter/foundation.dart';
import 'package:flutter_shared/models/user.dart';
import 'package:flutter_shared/auth/auth_service.dart';
import 'package:flutter_shared/auth/token_manager.dart';
import 'package:flutter_shared/api/api_client.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../core/errors/app_exceptions.dart' as local_exceptions;
import '../../../core/config/constants.dart';
import '../../../core/config/env.dart';
import '../../../core/services/notification_service.dart';

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

      // Check if user is logged in (has valid tokens)
      final isLoggedIn = await _authService.isLoggedIn();

      if (isLoggedIn) {
        try {
          // Try to fetch current user from API
          _currentUser = await _authService.getCurrentUser();

          // Verify user is admin
          if (_currentUser?.role != AppConstants.roleAdmin) {
            _errorMessage = 'Access denied. Admin privileges required.';
            await logout();
          }
        } catch (e) {
          // If fetching user fails (network error, etc.), don't logout
          // User will stay logged in with cached tokens
          // They can still use the app and will be logged out only if token is truly invalid
          debugPrint('Failed to fetch user on init: $e');
          
          // Only logout if it's an authentication error (invalid token)
          if (e is local_exceptions.UnauthorizedException) {
            debugPrint('Token is invalid, logging out');
            await logout();
          } else {
            // For other errors (network, timeout), keep user logged in
            debugPrint('Keeping user logged in despite error');
            // Set a minimal user object from stored data if possible
            final tokenManager = TokenManager();
            final userId = await tokenManager.getUserId();
            final userRole = await tokenManager.getUserRole();
            
            if (userId != null && userRole == AppConstants.roleAdmin) {
              // Create a minimal user object to maintain logged-in state
              _currentUser = User(
                id: userId,
                name: 'Admin', // Placeholder, will be updated when network is available
                email: '', // Placeholder
                phone: '',
                role: userRole ?? AppConstants.roleAdmin,
                isActive: true,
                createdAt: DateTime.now(),
              );
            }
          }
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

      // Initialize notification service after successful login (only if Firebase is available)
      try {
        // Check if Firebase is initialized
        try {
          await Firebase.app();
          // Firebase is available, initialize notification service
          final notificationService = NotificationService();
          await notificationService.initialize();
          debugPrint('Notification service initialized after login');
        } on FirebaseException catch (e) {
          if (e.code == 'core/no-app') {
            debugPrint('Firebase not initialized, skipping notification service');
          } else {
            rethrow;
          }
        }
      } catch (e) {
        debugPrint('Failed to initialize notification service: $e');
        // Don't fail login if notification service fails
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
