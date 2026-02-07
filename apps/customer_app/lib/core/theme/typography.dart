import 'package:flutter/material.dart';

/// Application typography styles
class AppTypography {
  // Heading 1 - Extra Large
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
    letterSpacing: -0.5,
  );

  // Heading 2 - Large
  static const TextStyle heading2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.25,
    letterSpacing: -0.25,
  );

  // Heading 3 - Medium-Large
  static const TextStyle heading3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.33,
  );

  // Heading 4 - Medium
  static const TextStyle heading4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // Heading 5 - Small-Medium
  static const TextStyle heading5 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.44,
  );

  // Heading 6 - Small
  static const TextStyle heading6 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  // Body 1 - Large body text
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  // Body 2 - Regular body text
  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.43,
  );

  // Button - Button text
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
    letterSpacing: 0.5,
  );

  // Caption - Small text
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.33,
    letterSpacing: 0.3,
  );

  // Overline - Extra small text
  static const TextStyle overline = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.45,
    letterSpacing: 1.0,
  );
}
