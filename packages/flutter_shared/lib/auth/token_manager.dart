import 'package:shared_preferences/shared_preferences.dart';

/// Token manager for storing and retrieving JWT tokens
class TokenManager {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';

  late SharedPreferences _prefs;
  bool _initialized = false;

  /// Initialize token manager (must be called once at app startup)
  Future<void> initialize() async {
    if (!_initialized) {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  /// Save tokens after login
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    String? userId,
    String? userRole,
  }) async {
    await _prefs.setString(_accessTokenKey, accessToken);
    await _prefs.setString(_refreshTokenKey, refreshToken);

    if (userId != null) {
      await _prefs.setString(_userIdKey, userId);
    }
    if (userRole != null) {
      await _prefs.setString(_userRoleKey, userRole);
    }
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    return _prefs.getString(_accessTokenKey);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return _prefs.getString(_refreshTokenKey);
  }

  /// Get stored user ID
  Future<String?> getUserId() async {
    return _prefs.getString(_userIdKey);
  }

  /// Get stored user role
  Future<String?> getUserRole() async {
    return _prefs.getString(_userRoleKey);
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Check if user is admin
  Future<bool> isAdmin() async {
    final role = await getUserRole();
    return role == 'ADMIN';
  }

  /// Clear all tokens (logout)
  Future<void> clearTokens() async {
    await _prefs.remove(_accessTokenKey);
    await _prefs.remove(_refreshTokenKey);
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_userRoleKey);
  }

  /// Update access token after refresh
  Future<void> updateAccessToken(String newAccessToken) async {
    await _prefs.setString(_accessTokenKey, newAccessToken);
  }
}
