import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';

/// Application theme configuration
class AppTheme {
  /// Light theme data
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiary,
      error: AppColors.error,
      surface: AppColors.lightSurface,
      onSurface: AppColors.darkText,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTypography.heading6.copyWith(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      color: AppColors.lightSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightInput,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      hintStyle: AppTypography.body2.copyWith(color: AppColors.hintText),
      labelStyle: AppTypography.body2.copyWith(color: AppColors.darkText),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: AppTypography.button.copyWith(color: Colors.white),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppTypography.button.copyWith(color: AppColors.primary),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: AppTypography.heading1,
      displayMedium: AppTypography.heading2,
      displaySmall: AppTypography.heading3,
      headlineMedium: AppTypography.heading4,
      headlineSmall: AppTypography.heading5,
      titleLarge: AppTypography.heading6,
      bodyLarge: AppTypography.body1,
      bodyMedium: AppTypography.body2,
      bodySmall: AppTypography.caption,
    ),
  );

  /// Dark theme data
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiary,
      error: AppColors.error,
      surface: AppColors.darkSurface,
      onSurface: AppColors.lightText,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTypography.heading6.copyWith(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkInput,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      hintStyle: AppTypography.body2.copyWith(color: AppColors.darkHintText),
      labelStyle: AppTypography.body2.copyWith(color: AppColors.lightText),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: AppTypography.button.copyWith(color: Colors.white),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppTypography.button.copyWith(color: AppColors.primary),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: AppTypography.heading1.copyWith(color: AppColors.lightText),
      displayMedium: AppTypography.heading2.copyWith(
        color: AppColors.lightText,
      ),
      displaySmall: AppTypography.heading3.copyWith(color: AppColors.lightText),
      headlineMedium: AppTypography.heading4.copyWith(
        color: AppColors.lightText,
      ),
      headlineSmall: AppTypography.heading5.copyWith(
        color: AppColors.lightText,
      ),
      titleLarge: AppTypography.heading6.copyWith(color: AppColors.lightText),
      bodyLarge: AppTypography.body1.copyWith(color: AppColors.lightText),
      bodyMedium: AppTypography.body2.copyWith(color: AppColors.lightText),
      bodySmall: AppTypography.caption.copyWith(color: AppColors.lightText),
    ),
  );
}
