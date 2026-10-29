import 'package:flutter/material.dart';
import 'package:koral/app/theme.dart';

class ExportCenterScreen extends StatelessWidget {
  const ExportCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Export center', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ExportTile(label: 'Deck', icon: Icons.file_present, color: KoralTheme.coral),
              _ExportTile(label: 'Document', icon: Icons.description, color: KoralTheme.teal),
              _ExportTile(label: 'Social bundle', icon: Icons.public, color: Colors.indigo),
              _ExportTile(label: 'Video scene', icon: Icons.video_library, color: Colors.purple),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExportTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _ExportTile({
    required this.label,
    required this.icon,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 120,
      child: Card(
        color: color.withOpacity(0.12),
        child: InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 36, color: color),
                const SizedBox(height: 10),
                Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
