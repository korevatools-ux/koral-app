import 'package:flutter/material.dart';
import 'package:koral/app/theme.dart';

class TeamWorkspaceScreen extends StatelessWidget {
  const TeamWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final members = [
      _Member(name: 'Aisha', role: 'Creative lead', color: KoralTheme.coral),
      _Member(name: 'Leo', role: 'Brand strategist', color: KoralTheme.teal),
      _Member(name: 'Nora', role: 'Editor', color: Colors.purple),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Team workspace')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Collaboration', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 18),
            Expanded(
              child: ListView.builder(
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final member = members[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: member.color.withOpacity(0.2),
                        child: Text(member.name.substring(0, 1)),
                      ),
                      title: Text(member.name),
                      subtitle: Text(member.role),
                      trailing: const Icon(Icons.chat_bubble_outline),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Member {
  final String name;
  final String role;
  final Color color;

  const _Member({
    required this.name,
    required this.role,
    required this.color,
  });
}
