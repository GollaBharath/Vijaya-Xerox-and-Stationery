import 'package:intl/intl.dart';

/// Extension methods for various types
extension StringExtensions on String {
  /// Capitalize first letter
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalize each word
  String capitalizeWords() {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  /// Truncate string with ellipsis
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$suffix';
  }

  /// Check if string is a valid email
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// Check if string is a valid phone number
  bool get isValidPhone {
    final phoneRegex = RegExp(r'^\d{10,15}$');
    return phoneRegex.hasMatch(replaceAll(RegExp(r'[\s\-\(\)\+]'), ''));
  }

  /// Remove all whitespace
  String removeWhitespace() {
    return replaceAll(RegExp(r'\s+'), '');
  }

  /// Check if string contains only numbers
  bool get isNumeric {
    return RegExp(r'^[0-9]+$').hasMatch(this);
  }

  /// Parse to int safely
  int? toIntOrNull() {
    return int.tryParse(this);
  }

  /// Parse to double safely
  double? toDoubleOrNull() {
    return double.tryParse(this);
  }
}

extension DateTimeExtensions on DateTime {
  /// Format date as "15 Jan 2025"
  String toFormattedDate() {
    return DateFormat('d MMM yyyy').format(this);
  }

  /// Format date and time as "15 Jan 2025 at 3:45 PM"
  String toFormattedDateTime() {
    return DateFormat('d MMM yyyy \'at\' h:mm a').format(this);
  }

  /// Format time as "3:45 PM"
  String toFormattedTime() {
    return DateFormat('h:mm a').format(this);
  }

  /// Format as relative time ("2 days ago", "Just now")
  String toRelativeTime() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Check if date is in the past
  bool get isPast {
    return isBefore(DateTime.now());
  }

  /// Check if date is in the future
  bool get isFuture {
    return isAfter(DateTime.now());
  }
}

extension NumExtensions on num {
  /// Format number with comma separators
  String toFormattedNumber() {
    return NumberFormat('#,##0').format(this);
  }

  /// Format as price with currency symbol
  String toFormattedPrice() {
    return '₹${NumberFormat('#,##0.00').format(this)}';
  }

  /// Format as percentage
  String toFormattedPercentage({int decimals = 0}) {
    return '${toStringAsFixed(decimals)}%';
  }

  /// Format file size in bytes to human-readable format
  String toFileSize() {
    if (this < 1024) return '$this B';
    if (this < 1024 * 1024) return '${(this / 1024).toStringAsFixed(1)} KB';
    if (this < 1024 * 1024 * 1024) {
      return '${(this / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(this / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

extension ListExtensions<T> on List<T> {
  /// Check if list is null or empty
  bool get isNullOrEmpty => isEmpty;

  /// Get first element or null
  T? get firstOrNull => isEmpty ? null : first;

  /// Get last element or null
  T? get lastOrNull => isEmpty ? null : last;

  /// Chunk list into smaller lists of specified size
  List<List<T>> chunk(int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      final end = (i + size < length) ? i + size : length;
      chunks.add(sublist(i, end));
    }
    return chunks;
  }
}

extension MapExtensions<K, V> on Map<K, V> {
  /// Check if map is null or empty
  bool get isNullOrEmpty => isEmpty;

  /// Get value or return default
  V getOrDefault(K key, V defaultValue) {
    return containsKey(key) ? this[key] as V : defaultValue;
  }
}
