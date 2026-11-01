import 'package:flutter/material.dart';

import 'package:koral/data/koral_repository.dart';
import 'package:koral/data/models.dart';

/// Live counts for the owner. The numbers come from the admin_stats database
/// function, which refuses anyone who isn't the owner.
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key, required this.repo});

  final KoralRepository repo;

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late Future<AdminStats> _stats = widget.repo.adminStats();

  Future<void> _reload() async {
    final next = widget.repo.adminStats();
    setState(() => _stats = next);
    try {
      await next;
    } catch (_) {
      // The FutureBuilder shows the error.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Owner')),
      body: FutureBuilder<AdminStats>(
        future: _stats,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      friendlyError(snapshot.error!),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _reload,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }
          final stats = snapshot.requireData;
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _StatRow(label: 'People signed up', value: stats.users),
                _StatRow(label: 'Projects', value: stats.projects),
                _StatRow(label: 'Results generated', value: stats.generations),
                _StatRow(label: 'AI requests today', value: stats.requestsToday),
                const SizedBox(height: 16),
                Text(
                  'Counts come straight from the database. Pull down to '
                  'refresh. You see totals, not other people’s work.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: Text(
        '$value',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}
