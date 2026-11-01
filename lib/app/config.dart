/// Values passed at build time with `--dart-define-from-file=env.json`.
///
/// The anon (publishable) key is meant to ship inside the app: row-level
/// security in the database decides what each signed-in person can read and
/// write. Never put the service_role / secret key or an AI key here.
class AppConfig {
  const AppConfig._();

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
