import 'package:flutter/material.dart';

class KoralTheme {
  static const coral = Color(0xFFEE7F6B);
  static const coralDeep = Color(0xFFDF6659);
  static const teal = Color(0xFF2EC4B6);
  static const tealDeep = Color(0xFF1EA39A);
  static const ink = Color(0xFF111827);
  static const panel = Color(0xFF162132);
  static const background = Color(0xFF0B1220);
  static const muted = Color(0xFF9AA9B8);

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: coral,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: ink,
          elevation: 0,
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: teal,
          brightness: Brightness.dark,
        ).copyWith(
          primary: coral,
          secondary: teal,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: const CardTheme(
          color: panel,
          margin: EdgeInsets.all(0),
        ),
      );
}
