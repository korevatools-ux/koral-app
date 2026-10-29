import 'package:flutter/material.dart';
import 'package:koral/app/theme.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Admin dashboard', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 18),
          const Row(
            children: [
              Expanded(child: _MetricCard(label: 'Projects', value: '84')),
              SizedBox(width: 12),
              Expanded(child: _MetricCard(label: 'Team members', value: '26')),
              SizedBox(width: 12),
              Expanded(child: _MetricCard(label: 'Exports', value: '143')),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Global operations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    SizedBox(height: 12),
                    Text('• Team permissions and role assignments'),
                    Text('• Project health and delivery tracking'),
                    Text('• Export usage and workspace analytics'),
                    Text('• Offline sync status and storage health'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;

  const _MetricCard({required this.label, required this.value, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: KoralTheme.teal.withOpacity(0.12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}
