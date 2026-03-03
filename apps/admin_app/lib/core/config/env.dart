/// Environment configuration for the Admin App
class Env {
  // API Base URL - configure based on environment
  // For Android emulator: 10.0.2.2 is the host machine
  // For iOS simulator or physical device: use your machine's local IP
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.0.7:3000',
  );

  // Enable debug logging
  static const bool enableDebugLogs = bool.fromEnvironment(
    'ENABLE_DEBUG_LOGS',
    defaultValue: true,
  );

  // App name
  static const String appName = 'Admin Panel';

  // Validate configuration
  static bool isValid() {
    return apiBaseUrl.isNotEmpty;
  }

  // Get formatted API URL
  static String get baseUrl => apiBaseUrl.endsWith('/')
      ? apiBaseUrl.substring(0, apiBaseUrl.length - 1)
      : apiBaseUrl;
}
