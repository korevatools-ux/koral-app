import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:koral/data/koral_repository.dart';
import 'package:koral/data/models.dart';

class ProjectDetailScreen extends StatefulWidget {
  const ProjectDetailScreen({
    super.key,
    required this.repo,
    required this.project,
    required this.isOwner,
  });

  final KoralRepository repo;
  final Project project;
  final bool isOwner;

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  late final TextEditingController _brief =
      TextEditingController(text: widget.project.brief);
  late Project _project = widget.project;
  List<Generation> _generations = const [];
  int? _usedToday;
  bool _loading = true;
  bool _saving = false;
  bool _generating = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _brief.dispose();
    super.dispose();
  }

  void _retry() {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final generations = await widget.repo.listGenerations(_project.id);
      final used =
          widget.isOwner ? null : await widget.repo.requestsUsedToday();
      if (!mounted) return;
      setState(() {
        _generations = generations;
        _usedToday = used;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = friendlyError(e);
        _loading = false;
      });
    }
  }

  bool get _briefChanged => _brief.text.trim() != _project.brief.trim();

  Future<bool> _saveBrief({bool quiet = false}) async {
    final text = _brief.text.trim();
    if (text.length > 4000) {
      _snack('Keep the brief under 4,000 characters.');
      return false;
    }
    setState(() => _saving = true);
    try {
      final updated = await widget.repo.updateBrief(_project.id, text);
      if (!mounted) return false;
      setState(() => _project = updated);
      if (!quiet) _snack('Brief saved.');
      return true;
    } catch (e) {
      _snack(friendlyError(e));
      return false;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _generate() async {
    if (_brief.text.trim().isEmpty) {
      _snack('Write a brief first.');
      return;
    }
    setState(() => _generating = true);
    try {
      if (_briefChanged && !await _saveBrief(quiet: true)) return;
      final generation = await widget.repo.generate(_project.id);
      if (!mounted) return;
      setState(() => _generations = [generation, ..._generations]);
      if (!widget.isOwner) {
        final used = await widget.repo.requestsUsedToday();
        if (mounted) setState(() => _usedToday = used);
      }
    } catch (e) {
      _snack(friendlyError(e));
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this project?'),
        content: const Text(
          'The brief and everything generated from it will be removed. '
          'This can’t be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete project'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await widget.repo.deleteProject(_project.id);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _snack(friendlyError(e));
    }
  }

  Future<void> _copy(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    _snack('Copied.');
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String get _usageLine {
    if (widget.isOwner) return 'Owner account: no daily limit.';
    final used = _usedToday;
    if (used == null) return '';
    final left = KoralRepository.dailyLimit - used;
    final shown = left < 0 ? 0 : left;
    return '$shown of ${KoralRepository.dailyLimit} requests left today.';
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final busy = _saving || _generating;
    return Scaffold(
      appBar: AppBar(
        title: Text(_project.title),
        actions: [
          IconButton(
            tooltip: 'Delete project',
            icon: const Icon(Icons.delete_outline),
            onPressed: busy ? null : _delete,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${_project.kind.label} in ${_project.language}',
            style: text.labelLarge,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _brief,
            minLines: 5,
            maxLines: 12,
            maxLength: 4000,
            decoration: const InputDecoration(
              labelText: 'Brief',
              hintText: 'Who is it for, what should it say, and what tone '
                  'should it have?',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              OutlinedButton(
                onPressed: busy ? null : () => _saveBrief(),
                child: const Text('Save brief'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: busy ? null : _generate,
                  icon: _generating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(_generating ? 'Generating…' : 'Generate'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(_usageLine, style: text.bodySmall),
          const SizedBox(height: 24),
          Text('Results', style: text.titleMedium),
          const SizedBox(height: 8),
          ..._results(text),
        ],
      ),
    );
  }

  List<Widget> _results(TextTheme text) {
    if (_loading) {
      return const [
        Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    final error = _loadError;
    if (error != null) {
      return [
        Text(error),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(onPressed: _retry, child: const Text('Try again')),
        ),
      ];
    }
    if (_generations.isEmpty) {
      return [
        Text(
          'Nothing generated yet. Write a brief and tap Generate.',
          style: text.bodyMedium,
        ),
      ];
    }
    return [
      for (final generation in _generations)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _formatTime(generation.createdAt),
                          style: text.bodySmall,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Copy',
                        icon: const Icon(Icons.copy),
                        onPressed: () => _copy(generation.output),
                      ),
                    ],
                  ),
                  SelectableText(generation.output),
                ],
              ),
            ),
          ),
        ),
    ];
  }
}

String _formatTime(DateTime time) {
  final local = time.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} '
      '${two(local.hour)}:${two(local.minute)}';
}
