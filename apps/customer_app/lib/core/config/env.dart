/// Environment configuration for the customer app
class Environment {
  /// API base URL
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api/v1',
  );

  /// Razorpay Key ID
  static const String razorpayKeyId = String.fromEnvironment(
    'RAZORPAY_KEY_ID',
    defaultValue: '',
  );

  /// Is debug mode
  static const bool isDebug = bool.fromEnvironment('DEBUG', defaultValue: true);
}
