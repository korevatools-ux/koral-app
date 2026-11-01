import 'package:flutter_test/flutter_test.dart';

import 'package:koral/data/models.dart';

void main() {
  group('Project.fromMap', () {
    test('reads a database row', () {
      final project = Project.fromMap({
        'id': 'abc',
        'title': 'Spring launch',
        'kind': 'video_script',
        'language': 'Shona',
        'brief': 'A 30 second story',
        'updated_at': '2026-10-31T12:00:00.123456+00:00',
      });

      expect(project.kind, ProjectKind.videoScript);
      expect(project.language, 'Shona');
      expect(project.updatedAt.toUtc().hour, 12);
    });

    test('falls back safely when optional fields are missing', () {
      final project = Project.fromMap({
        'id': 'x',
        'title': 'T',
        'kind': 'not_a_real_kind',
        'updated_at': '2026-10-31T00:00:00Z',
      });

      expect(project.kind, ProjectKind.document);
      expect(project.language, 'English');
      expect(project.brief, '');
    });
  });

  test('every project kind round-trips through its database value', () {
    for (final kind in ProjectKind.values) {
      expect(ProjectKind.fromDb(kind.dbValue), kind);
    }
  });

  test('Generation.fromMap reads a saved result', () {
    final generation = Generation.fromMap({
      'id': 'g1',
      'output': 'Hello',
      'model': 'some-model',
      'created_at': '2026-10-31T08:15:00+00:00',
    });

    expect(generation.output, 'Hello');
    expect(generation.model, 'some-model');
  });

  test('AdminStats.fromMap reads counts', () {
    final stats = AdminStats.fromMap({
      'users': 3,
      'projects': 5,
      'generations': 9,
      'requests_today': 2,
    });

    expect(stats.users, 3);
    expect(stats.generations, 9);
  });
}
