import 'package:flutter/material.dart';

class AppTheme {
  // Brand luxury color palette
  static const Color background = Color(0xFF090D16);
  static const Color surface = Color(0xFF111827);
  static const Color surfaceElevated = Color(0xFF1E293B);
  static const Color surfaceLight = Color(0xFF334155);

  static const Color goldPrimary = Color(0xFFEAB308);
  static const Color goldLight = Color(0xFFFDE047);
  static const Color goldDark = Color(0xFFCA8A04);
  static const Color goldAccent = Color(0xFFFACC15);

  static const Color greenRate = Color(0xFF10B981);
  static const Color greenBackground = Color(0x1F10B981);

  static const Color redRate = Color(0xFFF43F5E);
  static const Color redBackground = Color(0x1FF43F5E);

  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFF099), Color(0xFFF5BA42), Color(0xFFD4931A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldCardGradient = LinearGradient(
    colors: [Color(0xFF1E2638), Color(0xFF141A29)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient chartAreaGradient = LinearGradient(
    colors: [
      Color(0x55F5BA42),
      Color(0x22F5BA42),
      Color(0x00F5BA42),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: goldPrimary,
        secondary: goldAccent,
        surface: surface,
      ),
      fontFamilyFallback: const ['Segoe UI', 'Roboto', 'system-ui', 'sans-serif'],
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF1F293D), width: 1),
        ),
      ),
    );
  }
}
