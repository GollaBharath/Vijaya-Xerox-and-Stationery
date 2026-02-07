/// Application-wide constants
class AppConstants {
  // App Info
  static const String appName = 'Vijaya Admin';
  static const String appVersion = '1.0.0';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // File Upload Limits
  static const int maxImageSizeMB = 5;
  static const int maxPdfSizeMB = 10;
  static const int maxImageSizeBytes = maxImageSizeMB * 1024 * 1024;
  static const int maxPdfSizeBytes = maxPdfSizeMB * 1024 * 1024;

  // Supported File Types
  static const List<String> supportedImageTypes = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];
  static const List<String> supportedPdfTypes = ['pdf'];

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 2);

  // Cache Durations
  static const Duration categoryTreeCacheDuration = Duration(minutes: 5);
  static const Duration userCacheDuration = Duration(minutes: 1);

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 8.0;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 50;
  static const int minNameLength = 2;
  static const int maxNameLength = 100;
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 15;

  // Order Status Values (must match backend)
  static const String orderStatusPending = 'PENDING';
  static const String orderStatusConfirmed = 'CONFIRMED';
  static const String orderStatusShipped = 'SHIPPED';
  static const String orderStatusDelivered = 'DELIVERED';
  static const String orderStatusCancelled = 'CANCELLED';

  // Payment Status Values (must match backend)
  static const String paymentStatusPending = 'PENDING';
  static const String paymentStatusPaid = 'PAID';
  static const String paymentStatusFailed = 'FAILED';
  static const String paymentStatusRefunded = 'REFUNDED';

  // Product File Types (must match backend)
  static const String fileTypeImage = 'IMAGE';
  static const String fileTypePdf = 'PDF';
  static const String fileTypeNone = 'NONE';

  // User Roles (must match backend)
  static const String roleAdmin = 'ADMIN';
  static const String roleCustomer = 'CUSTOMER';

  // Product Variant Types (must match backend)
  static const String variantTypeNew = 'NEW';
  static const String variantTypeOld = 'OLD';
}
