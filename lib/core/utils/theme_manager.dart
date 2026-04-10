import 'package:flutter/material.dart';

class ThemeManager {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFE68A2E),
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w500),
      displayMedium: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w400),
      bodyLarge: TextStyle(fontFamily: 'monospace', fontSize: 24, fontWeight: FontWeight.w500),
      labelLarge: TextStyle(fontFamily: 'monospace', fontSize: 20, letterSpacing: 1.2),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFE68A2E),
      secondary: Color(0xFF2CA02C),
      surface: Color(0xFF1E2A36),
      surfaceContainerHighest: Color(0xFF2A3E4B),
      error: Color(0xFFB33B2C),
      onSurface: Color(0xFFEEF4FF),
      onSurfaceVariant: Color(0xFF6C8D9C),
    ),
    scaffoldBackgroundColor: const Color(0xFF0F1A24),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w500),
      displayMedium: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w400),
      bodyLarge: TextStyle(fontFamily: 'monospace', fontSize: 24, fontWeight: FontWeight.w500),
      labelLarge: TextStyle(fontFamily: 'monospace', fontSize: 20, letterSpacing: 1.2),
    ),
    cardTheme: CardThemeData(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: const Color(0xFF1E2A36),
    ),
  );
}