import 'package:flutter/material.dart';
import 'package:koral/app/theme.dart';

class StoryboardScreen extends StatelessWidget {
  const StoryboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scenes = [
      'Opening hook with founder story',
      'Product demo sequence',
      'Client proof and outcomes',
      'Final CTA and social cutdown',
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Storyboard and scenes',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: ListView.builder(
              itemCount: scenes.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: KoralTheme.coral.withOpacity(0.2),
                      child: Text('${index + 1}'),
                    ),
                    title: Text(scenes[index]),
                    subtitle: const Text('Style: cinematic, close-up motion, warm lighting'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {},
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
