import 'env.dart';

/// API Configuration
class ApiConfig {
  static const String baseUrl = Environment.apiBaseUrl;

  // Auth endpoints
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authMe = '/auth/me';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';

  // Category endpoints
  static const String categoriesHierarchy = '/categories/hierarchy';
  static const String categoriesList = '/categories';

  // Subject endpoints
  static const String subjectsList = '/subjects';
  static const String subjectsHierarchy = '/subjects/hierarchy';

  // Product endpoints
  static const String productsList = '/products';
  static const String productsSearch = '/products/search';
  static const String productDetail = '/products';

  // Cart endpoints
  static const String cartItems = '/cart/items';
  static const String cartCheckout = '/cart/checkout';

  // Order endpoints
  static const String ordersList = '/orders';
  static const String orderDetail = '/orders';

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
