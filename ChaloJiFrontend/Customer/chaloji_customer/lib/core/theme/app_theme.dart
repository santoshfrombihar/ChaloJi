import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors (ChaloJi Brand Consistency)
  static const Color primaryColor = Color(0xFF1E293B); // Deep Slate / Navy
  static const Color accentColor = Color(0xFF2563EB);  // Premium Royal Blue
  static const Color backgroundColor = Color(0xFFF8FAFC); // Off-White
  static const Color textMutedColor = Color(0xFF64748B); // Slate Grey

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: 'Roboto', // Default system font or choose your own
      textSelectionTheme: const TextSelectionThemeData(cursorColor: accentColor),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentColor, width: 1.5),
        ),
      ),
    );
  }
}