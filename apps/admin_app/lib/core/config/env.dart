/// Environment configuration for the Admin App
class Env {
  // API Base URL - configure based on environment
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api/v1',
  );

  // Enable debug logging
  static const bool enableDebugLogs = bool.fromEnvironment(
    'ENABLE_DEBUG_LOGS',
    defaultValue: true,
  );

  // App name
  static const String appName = 'Vijaya Admin';

  // Validate configuration
  static bool isValid() {
    return apiBaseUrl.isNotEmpty;
  }

  // Get formatted API URL
  static String get baseUrl => apiBaseUrl.endsWith('/')
      ? apiBaseUrl.substring(0, apiBaseUrl.length - 1)
      : apiBaseUrl;
}
