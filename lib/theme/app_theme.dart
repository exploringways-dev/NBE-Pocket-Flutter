import 'package:flutter/material.dart';

/// Central place for every color / style used across the app.
/// Keeping these in one file means the two screens never hardcode
/// a hex value — change the brand color here and both pages update.
class AppColors {
  AppColors._();

  static const Color primaryGreen = Color(0xFF1E4B3A);
  static const Color primaryGreenDark = Color(0xFF15382C);
  static const Color accentOrange = Color(0xFFE8792E);
  static const Color background = Color(0xFFF3F4F1);
  static const Color inputFill = Color(0xFFFFFFFF);
  static const Color hintGray = Color(0xFF9AA39D);
  static const Color labelGray = Color(0xFF5C6660);
  static const Color divider = Color(0xFFDDE1DD);
}

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle headerTitle = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle headerSubtitle = TextStyle(
    fontSize: 14,
    color: Colors.white70,
  );

  static const TextStyle fieldLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.labelGray,
  );

  static const TextStyle inputText = TextStyle(
    fontSize: 15,
    color: Colors.black87,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreen,
        primary: AppColors.primaryGreen,
        secondary: AppColors.accentOrange,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primaryGreen,
        selectionColor: AppColors.primaryGreen,
      ),
    );
  }
}
