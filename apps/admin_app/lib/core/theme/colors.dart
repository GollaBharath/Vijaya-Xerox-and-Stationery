import 'package:flutter/material.dart';

/// Color palette for the Admin App
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF1976D2); // Blue
  static const Color primaryLight = Color(0xFF63A4FF);
  static const Color primaryDark = Color(0xFF004BA0);

  // Secondary Colors
  static const Color secondary = Color(0xFFFF6F00); // Orange
  static const Color secondaryLight = Color(0xFFFF9D3F);
  static const Color secondaryDark = Color(0xFFC43E00);

  // Neutral Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF121212);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color warning = Color(0xFFFFC107); // Amber
  static const Color error = Color(0xFFF44336); // Red
  static const Color info = Color(0xFF2196F3); // Blue

  // Order Status Colors
  static const Color orderPending = Color(0xFFFFC107); // Amber
  static const Color orderConfirmed = Color(0xFF2196F3); // Blue
  static const Color orderShipped = Color(0xFF9C27B0); // Purple
  static const Color orderDelivered = Color(0xFF4CAF50); // Green
  static const Color orderCancelled = Color(0xFFF44336); // Red

  // Payment Status Colors
  static const Color paymentPending = Color(0xFFFFC107); // Amber
  static const Color paymentPaid = Color(0xFF4CAF50); // Green
  static const Color paymentFailed = Color(0xFFF44336); // Red
  static const Color paymentRefunded = Color(0xFF9E9E9E); // Grey

  // Border & Divider Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFBDBDBD);

  // Disabled States
  static const Color disabled = Color(0xFFBDBDBD);
  static const Color disabledBackground = Color(0xFFF5F5F5);

  // Shadows
  static const Color shadow = Color(0x1F000000);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);
}
