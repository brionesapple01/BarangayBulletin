import 'package:flutter/material.dart';
import 'announcement_detail_screen.dart';
import 'announcement_form_screen.dart';

class AnnouncementsListScreen extends StatelessWidget {
  final List<Map<String, String>> announcements;
  final Function(Map<String, String>) onAddAnnouncement;
  final Function(int, Map<String, String>) onUpdateAnnouncement;

  const AnnouncementsListScreen({
    super.key,
    required this.announcements,
    required this.onAddAnnouncement,
    required this.onUpdateAnnouncement,
  });

  void _addAnnouncement(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AnnouncementFormScreen(),
      ),
    );

    if (result != null) {
      onAddAnnouncement(result);
    }
  }

  void _openDetail(BuildContext context, Map<String, String> announcement, int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnnouncementDetailScreen(
          announcement: announcement,
          index: index,
          onUpdate: onUpdateAnnouncement,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: announcements.length,
        itemBuilder: (context, index) {
          final item = announcements[index];
          
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            child: ListTile(
              title: Text(
                item['title']!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                item['body']!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openDetail(context, item, index),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addAnnouncement(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}