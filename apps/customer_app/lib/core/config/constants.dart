/// Application-wide constants
class AppConstants {
  // App metadata
  static const String appName = 'Vijaya Store';
  static const String appVersion = '1.0.0';

  // API configuration
  static const String apiBaseUrl =
      'http://localhost:3000'; // Change this to your API URL

  // Time constants (in milliseconds)
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache durations
  static const Duration categoryCacheDuration = Duration(hours: 6);
  static const Duration productCacheDuration = Duration(hours: 2);
  static const Duration userCacheDuration = Duration(minutes: 30);

  // Product types
  static const String productTypeStationery = 'stationery';
  static const String productTypeBook = 'book';

  // Order statuses
  static const String orderStatusPending = 'pending';
  static const String orderStatusConfirmed = 'confirmed';
  static const String orderStatusShipped = 'shipped';
  static const String orderStatusDelivered = 'delivered';
  static const String orderStatusCancelled = 'cancelled';

  // Payment statuses
  static const String paymentStatusPending = 'pending';
  static const String paymentStatusCompleted = 'completed';
  static const String paymentStatusFailed = 'failed';

  // SharedPreferences keys
  static const String spKeyAuthToken = 'auth_token';
  static const String spKeyRefreshToken = 'refresh_token';
  static const String spKeyUser = 'user';
  static const String spKeyThemeMode = 'theme_mode';
}
