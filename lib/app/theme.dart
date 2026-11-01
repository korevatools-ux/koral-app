import 'package:flutter/material.dart';

/// Koral's palette. Contrast is checked against WCAG AA (4.5:1 for text):
/// white on [coralDeep] is 4.6:1, so filled buttons use [coralDeep];
/// [coral] reads at 3.7:1 with white, so keep it for large shapes only.
/// [coralLight] is for coral-coloured text and outlines on dark surfaces.
///
/// Surfaces are set through the colour scheme only (no CardTheme/AppBarTheme),
/// because those component theme classes have been renamed between Flutter
/// releases and the colour scheme hasn't.
class KoralTheme {
  const KoralTheme._();

  static const coral = Color(0xFFE8505B);
  static const coralDeep = Color(0xFFD63B49);
  static const coralLight = Color(0xFFFF8A8F);
  static const lagoon = Color(0xFF1D7A85);
  static const abyss = Color(0xFF0B2E35);
  static const panel = Color(0xFF123B43);
  static const ink = Color(0xFF111827);
  static const muted = Color(0xFF9AA9B8);

  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: coralDeep,
      onPrimary: Colors.white,
      secondary: lagoon,
      onSecondary: Colors.white,
      secondaryContainer: lagoon,
      onSecondaryContainer: Colors.white,
      surface: abyss,
      onSurface: Colors.white,
      onSurfaceVariant: muted,
      surfaceContainerLowest: abyss,
      surfaceContainerLow: panel,
      surfaceContainer: panel,
      surfaceContainerHigh: panel,
      surfaceContainerHighest: panel,
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: abyss,
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: coralLight),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: coralLight,
          side: const BorderSide(color: coralLight),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: coralDeep,
          primary: coralDeep,
          onPrimary: Colors.white,
          secondary: lagoon,
          onSecondary: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
      );
}
