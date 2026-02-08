/// API endpoint constants for Vijaya Xerox API
class ApiEndpoints {
  // Base URL will be configured in ApiClient

  // Auth endpoints
  static const String authLogin = '/api/v1/auth/login';
  static const String authRegister = '/api/v1/auth/register';
  static const String authLogout = '/api/v1/auth/logout';
  static const String authMe = '/api/v1/auth/me';
  static const String authRefresh = '/api/v1/auth/refresh';
  static const String authFirebaseLogin = '/api/v1/auth/firebase-login';

  // Admin endpoints
  static const String adminDashboard = '/api/v1/admin/dashboard';
  static const String adminSettings = '/api/v1/admin/settings';
  static const String adminUsers = '/api/v1/admin/users';
  static const String adminOrders = '/api/v1/admin/orders';

  // Catalog endpoints
  static const String categories = '/api/v1/catalog/categories';
  static const String subjects = '/api/v1/catalog/subjects';
  static const String products = '/api/v1/catalog/products';
  static const String productsSearch = '/api/v1/catalog/products/search';
  static const String variants = '/api/v1/catalog/variants';

  // Legacy aliases (deprecated)
  static const String categoriesRoot = categories;
  static const String subjectsRoot = subjects;
  static const String productsRoot = products;

  // Cart endpoints
  static const String cart = '/api/v1/cart';
  static const String cartClear = '/api/v1/cart/clear';

  // Legacy aliases (deprecated)
  static const String cartRoot = cart;

  // Order endpoints
  static const String orders = '/api/v1/orders';

  // Legacy aliases (deprecated)
  static const String ordersRoot = orders;

  // File upload endpoints
  static const String uploadImage = '/api/v1/catalog/products/upload-image';
  static const String uploadPdf = '/api/v1/catalog/products/upload-pdf';

  // File serving endpoints
  static const String filesImages = '/api/v1/files/images';
  static const String filesPdfs = '/api/v1/files/pdfs';

  // Helper methods for dynamic endpoints
  static String userId(String id) => '$adminUsers/$id';
  static String adminUser(String id) => '$adminUsers/$id';
  static String adminOrder(String id) => '$adminOrders/$id';
  static String adminOrderCancel(String id) => '$adminOrders/$id/cancel';
  static String category(String id) => '$categories/$id';
  static String subject(String id) => '$subjects/$id';
  static String product(String id) => '$products/$id';
  static String productFiles(String id) => '$products/$id/files';
  static String productVariants(String productId) =>
      '$products/$productId/variants';
  static String variant(String id) => '$variants/$id';
  static String cartItem(String itemId) => '$cart/$itemId';
  static String order(String id) => '$orders/$id';
}

// Shorter alias for convenience
typedef Endpoints = ApiEndpoints;
