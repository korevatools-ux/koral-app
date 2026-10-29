import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    const url = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

    if (url.isEmpty || anonKey.isEmpty) {
      debugPrint('Supabase not configured. Running in local demo mode.');
      _initialized = true;
      return;
    }

    await Supabase.initialize(url: url, anonKey: anonKey);
    _initialized = true;
  }

  static bool get isConfigured =>
      const String.fromEnvironment('SUPABASE_URL', defaultValue: '').isNotEmpty &&
      const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '').isNotEmpty;
}
