import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF47A138);
  static const Color primaryOrange = Color(0xFFFF5722);
  static const Color backgroundGray = Color(0xFFE4EDE3);
  static const Color white = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF333333);
  static const Color textGray = Color(0xFF757575);
  static const Color inputBorder = Color(0xFFE0E0E0);

  static ThemeData get theme {
    return ThemeData(
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: backgroundGray,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        secondary: primaryOrange,
        surface: white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundGray,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryGreen),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: primaryGreen),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        hintStyle: const TextStyle(color: textGray),
        labelStyle: const TextStyle(color: textDark),
      ),
      useMaterial3: true,
    );
  }
}
