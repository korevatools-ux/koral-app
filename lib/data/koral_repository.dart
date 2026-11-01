import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:koral/data/models.dart';

/// A problem worth showing to the person as-is.
class KoralException implements Exception {
  const KoralException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Turns any error into a sentence that tells the person what to do next.
String friendlyError(Object error) {
  if (error is KoralException) return error.message;
  if (error is AuthException) return error.message;
  if (error is PostgrestException) return error.message;
  return 'Couldn’t reach Koral. Check your connection and try again.';
}

/// Every read and write the app makes. Row-level security in the database
/// decides what each signed-in person may see; this class only asks.
class KoralRepository {
  KoralRepository([SupabaseClient? client])
      : _db = client ?? Supabase.instance.client;

  final SupabaseClient _db;

  /// Must match DAILY_LIMIT in supabase/functions/generate/index.ts.
  static const dailyLimit = 40;

  String get _uid {
    final user = _db.auth.currentUser;
    if (user == null) {
      throw const KoralException('Sign in again to continue.');
    }
    return user.id;
  }

  Future<bool> isOwner() async {
    final row = await _db
        .from('profiles')
        .select('role')
        .eq('id', _uid)
        .maybeSingle();
    return row?['role'] == 'owner';
  }

  Future<List<Project>> listProjects() async {
    final rows = await _db
        .from('projects')
        .select()
        .eq('owner_id', _uid)
        .order('updated_at', ascending: false);
    return rows.map(Project.fromMap).toList();
  }

  Future<Project> createProject({
    required String title,
    required ProjectKind kind,
    required String language,
  }) async {
    final row = await _db
        .from('projects')
        .insert({
          'owner_id': _uid,
          'title': title,
          'kind': kind.dbValue,
          'language': language,
        })
        .select()
        .single();
    return Project.fromMap(row);
  }

  Future<Project> updateBrief(String projectId, String brief) async {
    final row = await _db
        .from('projects')
        .update({'brief': brief})
        .eq('id', projectId)
        .select()
        .single();
    return Project.fromMap(row);
  }

  Future<void> deleteProject(String projectId) async {
    await _db.from('projects').delete().eq('id', projectId);
  }

  Future<List<Generation>> listGenerations(String projectId) async {
    final rows = await _db
        .from('generations')
        .select()
        .eq('project_id', projectId)
        .order('created_at', ascending: false);
    return rows.map(Generation.fromMap).toList();
  }

  /// AI requests used today. Days reset at midnight UTC.
  Future<int> requestsUsedToday() async {
    final today = DateTime.now().toUtc().toIso8601String().substring(0, 10);
    final row = await _db
        .from('ai_usage')
        .select('requests')
        .eq('user_id', _uid)
        .eq('day', today)
        .maybeSingle();
    return (row?['requests'] as num?)?.toInt() ?? 0;
  }

  /// Asks the server to write the piece described by the project's brief.
  /// The AI key lives on the server; the app never sees it.
  Future<Generation> generate(String projectId) async {
    try {
      final response = await _db.functions.invoke(
        'generate',
        body: {'project_id': projectId},
      );
      final data = response.data;
      if (data is Map && data['generation'] is Map) {
        return Generation.fromMap(
          Map<String, dynamic>.from(data['generation'] as Map),
        );
      }
      throw const KoralException(
        'The server sent back something unexpected. Try again.',
      );
    } on FunctionException catch (e) {
      final details = e.details;
      if (details is Map && details['error'] is String) {
        throw KoralException(details['error'] as String);
      }
      throw KoralException('Generation failed (error ${e.status}). Try again.');
    }
  }

  Future<AdminStats> adminStats() async {
    final result = await _db.rpc('admin_stats');
    return AdminStats.fromMap(Map<String, dynamic>.from(result as Map));
  }
}
