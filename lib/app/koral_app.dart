import 'package:flutter/material.dart';

import 'package:koral/app/config.dart';
import 'package:koral/app/theme.dart';
import 'package:koral/features/auth/auth_gate.dart';

class KoralApp extends StatelessWidget {
  const KoralApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Koral',
      debugShowCheckedModeBanner: false,
      theme: KoralTheme.light,
      darkTheme: KoralTheme.dark,
      themeMode: ThemeMode.dark,
      home: AppConfig.isConfigured
          ? const AuthGate()
          : const SetupRequiredScreen(),
    );
  }
}

/// Shown instead of a fake demo when the app starts without database settings.
class SetupRequiredScreen extends StatelessWidget {
  const SetupRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Koral needs its database settings',
                    style: text.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Start the app with your Supabase URL and anon key:',
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'flutter run --dart-define-from-file=env.json',
                    style: TextStyle(fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Copy env.example.json to env.json and fill in both '
                    'values. The README has the full steps.',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
