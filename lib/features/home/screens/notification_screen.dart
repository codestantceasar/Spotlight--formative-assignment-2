import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  static const _notifications = [
    {
      'title': 'Welcome to Spotlight',
      'subtitle': 'Your feed is ready. Share your first post!',
    },
    {
      'title': 'Application sent',
      'subtitle': 'Your job application has been submitted successfully.',
    },
    {
      'title': 'New follower',
      'subtitle': 'Someone started following you.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Text(
                'No notifications yet.',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withAlpha(180),
                  fontSize: 16,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = _notifications[index];
                return ListTile(
                  title: Text(
                    item['title']!,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    item['subtitle']!,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withAlpha(180),
                    ),
                  ),
                  leading: const Icon(Icons.notifications, color: Colors.blueAccent),
                );
              },
            ),
    );
  }
}
