import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      'A new concept direction was generated for Spring Launch.',
      'Alex commented on the brand tone for the product story.',
      'Your export bundle is ready for download.',
      'A teammate assigned a new review task to your project.',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) => Card(
          child: ListTile(
            leading: const Icon(Icons.notifications_active),
            title: Text(items[index]),
            subtitle: const Text('Just now • Team workspace'),
          ),
        ),
      ),
    );
  }
}
