import 'package:intl/intl.dart';

/// String extensions
extension StringExtension on String {
  /// Check if string is a valid email
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  /// Check if string is a valid phone number (10-15 digits)
  bool get isValidPhone {
    final phoneRegex = RegExp(r'^[0-9]{10,15}$');
    return phoneRegex.hasMatch(replaceAll(RegExp(r'[^\d]'), ''));
  }

  /// Check if string is empty or whitespace
  bool get isEmptyOrWhitespace => trim().isEmpty;

  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Convert to title case
  String get toTitleCase {
    return split(' ')
        .map(
          (word) => word.isEmpty
              ? ''
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  /// Truncate string to specified length
  String truncate(int length) {
    if (this.length <= length) return this;
    return '${substring(0, length)}...';
  }

  /// Remove special characters
  String get removeSpecialCharacters {
    return replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '');
  }
}

/// DateTime extensions
extension DateTimeExtension on DateTime {
  /// Format date as "dd/MM/yyyy"
  String get formattedDate {
    return DateFormat('dd/MM/yyyy').format(this);
  }

  /// Format date-time as "dd/MM/yyyy HH:mm"
  String get formattedDateTime {
    return DateFormat('dd/MM/yyyy HH:mm').format(this);
  }

  /// Format date-time as "dd MMM yyyy, HH:mm"
  String get formattedDateTimeVerbose {
    return DateFormat('dd MMM yyyy, HH:mm').format(this);
  }

  /// Format time as "HH:mm"
  String get formattedTime {
    return DateFormat('HH:mm').format(this);
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

  /// Get relative time string (e.g., "2 hours ago")
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'just now';
    }
  }
}

/// Double extensions
extension DoubleExtension on double {
  /// Format as currency (₹)
  String get formattedCurrency {
    return '₹${toStringAsFixed(2)}';
  }

  /// Format as percentage
  String get formattedPercentage {
    return '${(this * 100).toStringAsFixed(2)}%';
  }

  /// Check if equal to another double with tolerance
  bool isAlmostEqualTo(double other, {double tolerance = 0.001}) {
    return (this - other).abs() < tolerance;
  }
}

/// List extensions
extension ListExtension<T> on List<T> {
  /// Check if list is empty
  bool get isEmpty => length == 0;

  /// Check if list is not empty
  bool get isNotEmpty => length > 0;

  /// Get first element or null
  T? get firstOrNull => isEmpty ? null : first;

  /// Get last element or null
  T? get lastOrNull => isEmpty ? null : last;

  /// Duplicate list
  List<T> duplicate() => [...this];

  /// Group list by key function
  Map<K, List<T>> groupBy<K>(K Function(T) keyFunction) {
    final map = <K, List<T>>{};
    for (final item in this) {
      final key = keyFunction(item);
      (map[key] ??= []).add(item);
    }
    return map;
  }
}

/// Map extensions
extension MapExtension<K, V> on Map<K, V> {
  /// Check if map is empty
  bool get isEmpty => length == 0;

  /// Check if map is not empty
  bool get isNotEmpty => length > 0;
}

/// Null extensions
extension NullableExtension<T> on T? {
  /// Execute if value is not null
  R? let<R>(R Function(T) block) {
    return this != null ? block(this as T) : null;
  }

  /// Execute if value is null
  T? ifNull(T Function() block) {
    return this ?? block();
  }
}
