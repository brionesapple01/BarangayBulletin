import 'package:flutter/material.dart';
import 'announcement_form_screen.dart';

class AnnouncementDetailScreen extends StatelessWidget {
  final Map<String, String> announcement;
  final int index;
  final Function(int, Map<String, String>) onUpdate;

  const AnnouncementDetailScreen({
    super.key,
    required this.announcement,
    required this.index,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcement Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AnnouncementFormScreen(
                    title: announcement['title'],
                    body: announcement['body'],
                  ),
                ),
              );

              if (result != null) {
                onUpdate(index, result);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              announcement['title']!,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(announcement['body']!),
          ],
        ),
      ),
    );
  }
}