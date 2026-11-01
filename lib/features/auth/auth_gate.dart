import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:koral/features/auth/sign_in_screen.dart';
import 'package:koral/features/home/home_shell.dart';

/// Shows the sign-in screen until Supabase reports a real session.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth;
    return StreamBuilder<AuthState>(
      stream: auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session ?? auth.currentSession;
        return session == null ? const SignInScreen() : const HomeShell();
      },
    );
  }
}
