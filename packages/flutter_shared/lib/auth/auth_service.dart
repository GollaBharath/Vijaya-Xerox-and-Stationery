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

      print('🔐 Login response: $response');

      // Extract data from API response wrapper
      final data = response['data'] as Map<String, dynamic>;
      print('📦 Data extracted: $data');

      final tokens = data['tokens'] as Map<String, dynamic>;
      print('🎫 Tokens extracted: $tokens');

      // Extract tokens from response
      final accessToken = tokens['accessToken'] as String;
      final refreshToken = tokens['refreshToken'] as String;
      final user = User.fromJson(data['user'] as Map<String, dynamic>);
      print('👤 User created: ${user.email}, role: ${user.role}');

      // Save tokens
      await tokenManager.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        userId: user.id,
        userRole: user.role,
      );
      print('✅ Tokens saved successfully');

      return user;
    } catch (e, stackTrace) {
      print('❌ Login error: $e');
      print('Stack trace: $stackTrace');
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

      // Extract data from API response wrapper
      final data = response['data'] as Map<String, dynamic>;
      final tokens = data['tokens'] as Map<String, dynamic>;

      // Extract tokens from response
      final accessToken = tokens['accessToken'] as String;
      final refreshToken = tokens['refreshToken'] as String;
      final user = User.fromJson(data['user'] as Map<String, dynamic>);

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
      final data = response['data'] as Map<String, dynamic>;
      return User.fromJson(data['user'] as Map<String, dynamic>);
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
        body: {'refreshToken': oldRefreshToken},
        withAuth: false,
      );

      final data = response['data'] as Map<String, dynamic>;
      final newAccessToken = data['accessToken'] as String;

      await tokenManager.updateAccessToken(newAccessToken);
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
