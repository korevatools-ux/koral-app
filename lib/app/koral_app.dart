import 'package:flutter/material.dart';
import 'package:koral/app/theme.dart';
import 'package:koral/features/auth/auth_gate.dart';

class KoralApp extends StatelessWidget {
  const KoralApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Koral',
      debugShowCheckedModeBanner: false,
      theme: KoralTheme.lightTheme,
      darkTheme: KoralTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const AuthGate(),
    );
  }
}
