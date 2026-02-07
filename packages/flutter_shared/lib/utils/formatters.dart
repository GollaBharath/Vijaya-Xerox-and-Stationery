import 'package:intl/intl.dart';

/// Formatters for displaying data in UI
class Formatters {
  /// Format price with currency symbol (Indian Rupees)
  static String formatPrice(double price) {
    final formatter = NumberFormat('₹#,##0.00', 'en_IN');
    return formatter.format(price);
  }

  /// Format date to readable format (e.g., "15 Jan 2025")
  static String formatDate(DateTime date) {
    final formatter = DateFormat('dd MMM yyyy');
    return formatter.format(date);
  }

  /// Format date with time (e.g., "15 Jan 2025 at 3:45 PM")
  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('dd MMM yyyy \'at\' h:mm a');
    return formatter.format(dateTime);
  }

  /// Format time only (e.g., "3:45 PM")
  static String formatTime(DateTime dateTime) {
    final formatter = DateFormat('h:mm a');
    return formatter.format(dateTime);
  }

  /// Format relative time (e.g., "2 days ago", "Just now")
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else {
      return formatDate(dateTime);
    }
  }

  /// Format phone number (e.g., "+91 9876543210")
  static String formatPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanPhone.length == 10) {
      return '+91 ${cleanPhone.substring(0, 4)} ${cleanPhone.substring(4, 8)} ${cleanPhone.substring(8)}';
    } else if (cleanPhone.length == 12 && cleanPhone.startsWith('91')) {
      return '+${cleanPhone.substring(0, 2)} ${cleanPhone.substring(2, 6)} ${cleanPhone.substring(6, 10)} ${cleanPhone.substring(10)}';
    }

    return phone;
  }

  /// Format file size (e.g., "2.5 MB")
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / 1024 / 1024).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(2)} GB';
    }
  }

  /// Format order status with readable text
  static String formatOrderStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Pending';
      case 'CONFIRMED':
        return 'Confirmed';
      case 'SHIPPED':
        return 'Shipped';
      case 'DELIVERED':
        return 'Delivered';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
  }

  /// Format payment status with readable text
  static String formatPaymentStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Pending';
      case 'PAID':
        return 'Paid';
      case 'FAILED':
        return 'Failed';
      default:
        return status;
    }
  }

  /// Format file type with icon/badge text
  static String formatFileType(String fileType) {
    switch (fileType.toUpperCase()) {
      case 'IMAGE':
        return '📷 Image';
      case 'PDF':
        return '📄 PDF';
      case 'NONE':
        return 'No file';
      default:
        return fileType;
    }
  }

  /// Format product count (e.g., "2 items")
  static String formatItemCount(int count, {String item = 'item'}) {
    return '$count ${item}${count != 1 ? 's' : ''}';
  }

  /// Format text with ellipsis if too long
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }

  /// Capitalize first letter of each word
  static String capitalizeWords(String text) {
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  /// Format number with comma separators (e.g., "1,234,567")
  static String formatNumber(int number) {
    final formatter = NumberFormat('#,##0', 'en_IN');
    return formatter.format(number);
  }

  /// Format rating (e.g., "4.5 ⭐")
  static String formatRating(double rating) {
    return '${rating.toStringAsFixed(1)} ⭐';
  }

  /// Format percentage
  static String formatPercentage(double percentage) {
    return '${(percentage * 100).toStringAsFixed(1)}%';
  }
}
