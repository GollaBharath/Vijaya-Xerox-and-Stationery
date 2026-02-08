import 'package:flutter/material.dart';

/// Color palette for the Admin App
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF1E3A8A); // Navy
  static const Color primaryLight = Color(0xFF4F6FE3);
  static const Color primaryDark = Color(0xFF102A5E);

  // Secondary Colors
  static const Color secondary = Color(0xFF0F766E); // Teal
  static const Color secondaryLight = Color(0xFF2BA79B);
  static const Color secondaryDark = Color(0xFF0B4F4A);

  // Neutral Colors
  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF121212);

  // Text Colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
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
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFE5E7EB);

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
