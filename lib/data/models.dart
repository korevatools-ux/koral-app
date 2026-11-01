/// What Koral makes from a brief. [dbValue] must match the check constraint
/// on projects.kind and the KIND_INSTRUCTIONS keys in the generate function.
enum ProjectKind {
  socialPost('social_post', 'Social post'),
  document('document', 'Document'),
  slides('slides', 'Slide outline'),
  videoScript('video_script', 'Video script');

  const ProjectKind(this.dbValue, this.label);

  final String dbValue;
  final String label;

  static ProjectKind fromDb(String? value) => ProjectKind.values.firstWhere(
        (kind) => kind.dbValue == value,
        orElse: () => ProjectKind.document,
      );
}

/// Languages Koral writes in. Add the rest of your 15 here.
const outputLanguages = <String>['English', 'Shona', 'Swahili', 'Kinyarwanda'];

class Project {
  const Project({
    required this.id,
    required this.title,
    required this.kind,
    required this.language,
    required this.brief,
    required this.updatedAt,
  });

  factory Project.fromMap(Map<String, dynamic> map) => Project(
        id: map['id'] as String,
        title: map['title'] as String,
        kind: ProjectKind.fromDb(map['kind'] as String?),
        language: (map['language'] as String?) ?? 'English',
        brief: (map['brief'] as String?) ?? '',
        updatedAt: DateTime.parse(map['updated_at'] as String),
      );

  final String id;
  final String title;
  final ProjectKind kind;
  final String language;
  final String brief;
  final DateTime updatedAt;
}

class Generation {
  const Generation({
    required this.id,
    required this.output,
    required this.createdAt,
    this.model,
  });

  factory Generation.fromMap(Map<String, dynamic> map) => Generation(
        id: map['id'] as String,
        output: map['output'] as String,
        model: map['model'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  final String id;
  final String output;
  final String? model;
  final DateTime createdAt;
}

class AdminStats {
  const AdminStats({
    required this.users,
    required this.projects,
    required this.generations,
    required this.requestsToday,
  });

  factory AdminStats.fromMap(Map<String, dynamic> map) => AdminStats(
        users: (map['users'] as num).toInt(),
        projects: (map['projects'] as num).toInt(),
        generations: (map['generations'] as num).toInt(),
        requestsToday: (map['requests_today'] as num).toInt(),
      );

  final int users;
  final int projects;
  final int generations;
  final int requestsToday;
}
