import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors (Unique Design Palette)
  static const Color primaryColor = Color(0xFF1E293B);   // Slate Dark Blue (Premium look)
  static const Color accentColor = Color(0xFF10B981);    // Emerald Green (For success/buttons)
  static const Color backgroundColor = Color(0xFFF8FAFC); // Clean off-white background
  static const Color textMainColor = Color(0xFF0F172A);   // Deep Charcoal for high readability
  static const Color textMutedColor = Color(0xFF64748B);  // Soft Gray for hints/labels

  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: Colors.white,
      ),
      // Input Form Design (Enterprise UI Feel)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: textMutedColor, fontSize: 14),
        hintStyle: const TextStyle(color: textMutedColor, fontSize: 14),
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
          borderSide: const BorderSide(color: accentColor, width: 2),
        ),
      ),
      // Premium Global Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
      ),
    );
  }
}