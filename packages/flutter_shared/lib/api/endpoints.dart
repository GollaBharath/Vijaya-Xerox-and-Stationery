/// API endpoint constants for Vijaya Xerox API
class ApiEndpoints {
  // Base URL will be configured in ApiClient

  // Auth endpoints
  static const String authLogin = '/api/v1/auth/login';
  static const String authRegister = '/api/v1/auth/register';
  static const String authLogout = '/api/v1/auth/logout';
  static const String authMe = '/api/v1/auth/me';
  static const String authRefresh = '/api/v1/auth/refresh';

  // Admin endpoints
  static const String adminDashboard = '/api/v1/admin/dashboard';
  static const String adminSettings = '/api/v1/admin/settings';
  static const String adminUsers = '/api/v1/admin/users';

  // Catalog endpoints
  static const String categoriesRoot = '/api/v1/catalog/categories';
  static const String subjectsRoot = '/api/v1/catalog/subjects';
  static const String productsRoot = '/api/v1/catalog/products';

  // Cart endpoints
  static const String cartRoot = '/api/v1/cart';
  static const String cartClear = '/api/v1/cart/clear';

  // Order endpoints
  static const String ordersRoot = '/api/v1/orders';

  // File upload endpoints
  static const String uploadImage = '/api/v1/catalog/products/upload-image';
  static const String uploadPdf = '/api/v1/catalog/products/upload-pdf';

  // File serving endpoints
  static const String filesImages = '/api/v1/files/images';
  static const String filesPdfs = '/api/v1/files/pdfs';

  // Helper methods for dynamic endpoints
  static String userId(String id) => '$adminUsers/$id';
  static String category(String id) => '$categoriesRoot/$id';
  static String subject(String id) => '$subjectsRoot/$id';
  static String product(String id) => '$productsRoot/$id';
  static String productFiles(String id) => '$productsRoot/$id/files';
  static String cartItem(String itemId) => '$cartRoot/$itemId';
  static String order(String id) => '$ordersRoot/$id';
}
