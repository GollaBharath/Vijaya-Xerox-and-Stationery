/// Route names for navigation throughout the app
class RouteNames {
  // Auth routes
  static const String splash = '/';
  static const String login = '/login';

  // Main routes
  static const String dashboard = '/dashboard';

  // Category management
  static const String categories = '/categories';
  static const String categoryForm = '/categories/form';
  static const String categoryDetail = '/categories/detail';

  // Subject management
  static const String subjects = '/subjects';
  static const String subjectForm = '/subjects/form';
  static const String subjectDetail = '/subjects/detail';

  // Product management
  static const String products = '/products';
  static const String productForm = '/products/form';
  static const String productDetail = '/products/detail';

  // Order management
  static const String orders = '/orders';
  static const String orderDetail = '/orders/detail';

  // User management
  static const String users = '/users';
  static const String userDetail = '/users/detail';

  // Feedback
  static const String feedback = '/feedback';

  // Settings
  static const String settings = '/settings';

  // Helper method to navigate with arguments
  static String categoryDetailWithId(String id) => '$categoryDetail?id=$id';
  static String categoryFormWithId(String? id) =>
      id != null ? '$categoryForm?id=$id' : categoryForm;

  static String subjectDetailWithId(String id) => '$subjectDetail?id=$id';
  static String subjectFormWithId(String? id) =>
      id != null ? '$subjectForm?id=$id' : subjectForm;

  static String productDetailWithId(String id) => '$productDetail?id=$id';
  static String productFormWithId(String? id) =>
      id != null ? '$productForm?id=$id' : productForm;

  static String orderDetailWithId(String id) => '$orderDetail?id=$id';
  static String userDetailWithId(String id) => '$userDetail?id=$id';
}
