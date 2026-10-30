import 'package:flutter/material.dart';

class KoralTheme {
  static const coral = Color(0xFFE8505B);
  static const coralDeep = Color(0xFFD63B49);

  static const lagoon = Color(0xFF1D7A85);
  static const abyss = Color(0xFF0B2E35);

  static const ink = Color(0xFF111827);
  static const panel = Color(0xFF123B43);
  static const background = Color(0xFF0B2E35);

  static const muted = Color(0xFF9AA9B8);

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: coral,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          primary: coral,
          secondary: lagoon,
          surface: panel,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: const CardTheme(
          color: panel,
          margin: EdgeInsets.zero,
        ),
      );
}
