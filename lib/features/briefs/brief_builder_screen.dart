import 'package:flutter/material.dart';
import 'package:koral/app/theme.dart';

class ProjectListScreen extends StatelessWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final projects = [
      _ProjectCard(title: 'Spring Launch', status: 'In review', type: 'Campaign', progress: 0.76),
      _ProjectCard(title: 'Creator Retreat', status: 'Drafting', type: 'Story', progress: 0.43),
      _ProjectCard(title: 'Product A/B Test', status: 'Ready to export', type: 'Deck', progress: 0.92),
      _ProjectCard(title: 'Brand Retouch', status: 'Planning', type: 'Asset Pack', progress: 0.31),
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Project library',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('New project'),
                style: FilledButton.styleFrom(backgroundColor: KoralTheme.teal),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: ListView.separated(
              itemCount: projects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final project = projects[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                project.title,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: KoralTheme.coral.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(project.status),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(project.type, style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 14),
                        LinearProgressIndicator(value: project.progress),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text('Open project'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard {
  final String title;
  final String status;
  final String type;
  final double progress;

  const _ProjectCard({
    required this.title,
    required this.status,
    required this.type,
    required this.progress,
  });
}
