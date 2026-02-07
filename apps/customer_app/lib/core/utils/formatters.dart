import 'package:intl/intl.dart';

/// Formatting utilities
class Formatters {
  /// Format number as currency (₹)
  static String currency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  /// Format number with commas (e.g., 1,00,000)
  static String numberWithCommas(int number) {
    final formatter = NumberFormat('#,##,##0', 'en_IN');
    return formatter.format(number);
  }

  /// Format date as "dd MMM yyyy"
  static String date(DateTime dateTime) {
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  /// Format time as "HH:mm"
  static String time(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  /// Format date and time as "dd MMM yyyy, HH:mm"
  static String dateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
  }

  /// Format phone number
  static String phone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length == 10) {
      return '+91 ${cleaned.substring(0, 5)} ${cleaned.substring(5)}';
    }
    return phone;
  }

  /// Format percentage
  static String percentage(double value) {
    return '${(value * 100).toStringAsFixed(2)}%';
  }

  /// Truncate string with ellipsis
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Format file size (bytes to KB/MB/GB)
  static String fileSize(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var size = bytes.toDouble();
    var suffixIndex = 0;

    while (size > 1024 && suffixIndex < suffixes.length - 1) {
      size /= 1024;
      suffixIndex++;
    }

    if (suffixIndex == 0) {
      return '${size.toStringAsFixed(0)} ${suffixes[suffixIndex]}';
    }
    return '${size.toStringAsFixed(2)} ${suffixes[suffixIndex]}';
  }
}
