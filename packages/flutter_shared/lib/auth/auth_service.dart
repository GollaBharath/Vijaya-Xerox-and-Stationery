import '../models/user.dart';
import '../api/api_client.dart';
import '../api/endpoints.dart';
import 'token_manager.dart';

/// Authentication service for login, register, and token refresh
class AuthService {
  final ApiClient apiClient;
  final TokenManager tokenManager;

  AuthService({required this.apiClient, required this.tokenManager});

  /// Login with email and password
  Future<User> login({required String email, required String password}) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.authLogin,
        body: {'email': email, 'password': password},
        withAuth: false,
      );

      // Extract tokens from response
      final accessToken = response['access_token'] as String;
      final refreshToken = response['refresh_token'] as String;
      final user = User.fromJson(response['user'] as Map<String, dynamic>);

      // Save tokens
      await tokenManager.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        userId: user.id,
        userRole: user.role,
      );

      return user;
    } catch (e) {
      rethrow;
    }
  }

  /// Register new user
  Future<User> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.authRegister,
        body: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
        },
        withAuth: false,
      );

      // Extract tokens from response
      final accessToken = response['access_token'] as String;
      final refreshToken = response['refresh_token'] as String;
      final user = User.fromJson(response['user'] as Map<String, dynamic>);

      // Save tokens
      await tokenManager.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        userId: user.id,
        userRole: user.role,
      );

      return user;
    } catch (e) {
      rethrow;
    }
  }

  /// Get current logged-in user
  Future<User> getCurrentUser() async {
    try {
      final response = await apiClient.get(ApiEndpoints.authMe);
      return User.fromJson(response['user'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Refresh access token using refresh token
  Future<void> refreshToken() async {
    try {
      final oldRefreshToken = await tokenManager.getRefreshToken();
      if (oldRefreshToken == null) {
        throw UnauthorizedException('No refresh token available');
      }

      final response = await apiClient.post(
        ApiEndpoints.authRefresh,
        body: {'refresh_token': oldRefreshToken},
        withAuth: false,
      );

      final newAccessToken = response['access_token'] as String;
      final newRefreshToken = response['refresh_token'] as String;

      await tokenManager.updateAccessToken(newAccessToken);
      // Update refresh token if provided
      if (newRefreshToken.isNotEmpty) {
        await tokenManager.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
          userId: await tokenManager.getUserId(),
          userRole: await tokenManager.getUserRole(),
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      // Call logout endpoint (backend may invalidate tokens)
      await apiClient.post(ApiEndpoints.authLogout);
    } catch (e) {
      // Continue with logout even if endpoint fails
      print('Logout endpoint error: $e');
    }

    // Always clear tokens locally
    await tokenManager.clearTokens();
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await tokenManager.isLoggedIn();
  }

  /// Check if current user is admin
  Future<bool> isAdmin() async {
    return await tokenManager.isAdmin();
  }
}
