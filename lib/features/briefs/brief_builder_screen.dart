import 'package:flutter/material.dart';
import 'package:koral/app/theme.dart';

class BriefBuilderScreen extends StatelessWidget {
  const BriefBuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Brief composer',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Campaign objective', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  const TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Write the strategic objective, target audience, and key message.',
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Audience & channel mix', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      Chip(label: Text('Instagram')),
                      Chip(label: Text('LinkedIn')),
                      Chip(label: Text('Email')),
                      Chip(label: Text('Short-form video')),
                    ],
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Generate concept directions'),
                    style: FilledButton.styleFrom(backgroundColor: KoralTheme.teal),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
