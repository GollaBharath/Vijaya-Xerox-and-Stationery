import 'constants.dart';

/// API Configuration
class ApiConfig {
  static const String baseUrl = AppConstants.apiBaseUrl;

  // Auth endpoints
  static const String authRegister = '/api/v1/auth/register';
  static const String authLogin = '/api/v1/auth/login';
  static const String authMe = '/api/v1/auth/me';
  static const String authRefresh = '/api/v1/auth/refresh';
  static const String authLogout = '/api/v1/auth/logout';
  static const String fcmToken = '/api/v1/auth/fcm-token';

  // Category endpoints
  static const String categoriesHierarchy = '/api/v1/catalog/categories/tree';
  static const String categoriesList = '/api/v1/catalog/categories';

  // Subject endpoints
  static const String subjectsList = '/api/v1/catalog/subjects';
  static const String subjectsHierarchy = '/api/v1/catalog/subjects/tree';

  // Product endpoints
  static const String productsList = '/api/v1/catalog/products';
  static const String productsSearch = '/api/v1/catalog/products/search';
  static const String productDetail = '/api/v1/catalog/products';

  // Cart endpoints
  static const String cartItems = '/api/v1/cart';
  static const String cartCheckout = '/api/v1/cart/checkout';

  // Order endpoints
  static const String ordersList = '/api/v1/orders';
  static const String orderDetail = '/api/v1/orders';

  /// Build full URL for an endpoint
  static String buildUrl(String endpoint) => '$baseUrl$endpoint';

  /// Build URL with ID parameter
  static String buildUrlWithId(String endpoint, String id) =>
      '$baseUrl$endpoint/$id';

  /// Build URL with query parameters
  static String buildUrlWithQuery(String endpoint, Map<String, String> params) {
    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return '$baseUrl$endpoint${queryString.isNotEmpty ? '?$queryString' : ''}';
  }
}
