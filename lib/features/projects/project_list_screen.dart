import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:koral/data/koral_repository.dart';
import 'package:koral/data/models.dart';
import 'package:koral/features/projects/project_detail_screen.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({
    super.key,
    required this.repo,
    required this.isOwner,
  });

  final KoralRepository repo;
  final bool isOwner;

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  late Future<List<Project>> _projects;

  @override
  void initState() {
    super.initState();
    _projects = widget.repo.listProjects();
  }

  Future<void> _reload() async {
    final next = widget.repo.listProjects();
    setState(() => _projects = next);
    try {
      await next;
    } catch (_) {
      // The FutureBuilder shows the error.
    }
  }

  Future<void> _newProject() async {
    final draft = await showDialog<_ProjectDraft>(
      context: context,
      builder: (_) => const _NewProjectDialog(),
    );
    if (draft == null || !mounted) return;
    try {
      final project = await widget.repo.createProject(
        title: draft.title,
        kind: draft.kind,
        language: draft.language,
      );
      if (!mounted) return;
      await _open(project);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(friendlyError(e))));
    }
  }

  Future<void> _open(Project project) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProjectDetailScreen(
          repo: widget.repo,
          project: project,
          isOwner: widget.isOwner,
        ),
      ),
    );
    if (mounted) await _reload();
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _newProject,
        icon: const Icon(Icons.add),
        label: const Text('New project'),
      ),
      body: FutureBuilder<List<Project>>(
        future: _projects,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _CenteredMessage(
              message: friendlyError(snapshot.error!),
              actionLabel: 'Try again',
              onAction: _reload,
            );
          }
          final projects = snapshot.data ?? const <Project>[];
          if (projects.isEmpty) {
            return const _CenteredMessage(
              message: 'No projects yet. Tap New project and write your '
                  'first brief.',
            );
          }
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              itemCount: projects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final project = projects[i];
                return Card(
                  child: ListTile(
                    title: Text(project.title),
                    subtitle: Text(
                      '${project.kind.label} in ${project.language}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _open(project),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 12),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProjectDraft {
  const _ProjectDraft(this.title, this.kind, this.language);

  final String title;
  final ProjectKind kind;
  final String language;
}

class _NewProjectDialog extends StatefulWidget {
  const _NewProjectDialog();

  @override
  State<_NewProjectDialog> createState() => _NewProjectDialogState();
}

class _NewProjectDialogState extends State<_NewProjectDialog> {
  final _title = TextEditingController();
  ProjectKind _kind = ProjectKind.socialPost;
  String _language = outputLanguages.first;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  void _create() {
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Give the project a name.');
      return;
    }
    Navigator.of(context).pop(_ProjectDraft(title, _kind, _language));
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelLarge;
    return AlertDialog(
      title: const Text('New project'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _title,
              autofocus: true,
              maxLength: 120,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(labelText: 'Name', errorText: _error),
              onSubmitted: (_) => _create(),
            ),
            const SizedBox(height: 8),
            Text('What should Koral make?', style: labelStyle),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final kind in ProjectKind.values)
                  ChoiceChip(
                    label: Text(kind.label),
                    selected: _kind == kind,
                    onSelected: (_) => setState(() => _kind = kind),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Language', style: labelStyle),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final language in outputLanguages)
                  ChoiceChip(
                    label: Text(language),
                    selected: _language == language,
                    onSelected: (_) => setState(() => _language = language),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _create, child: const Text('Create project')),
      ],
    );
  }
}
