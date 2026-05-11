import 'package:flutter/material.dart';
import 'announcement_detail_screen.dart';
import 'announcement_form_screen.dart';

class AnnouncementsListScreen extends StatelessWidget {
  const AnnouncementsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Temporary sample data
    final List<String> announcements = ['Announcement 1', 'Announcement 2', 'Announcement 3'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
      ),
      body: ListView.builder(
        itemCount: announcements.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(announcements[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnnouncementDetailScreen(),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to form screen (create mode - null means create)
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AnnouncementFormScreen(),
            ),
          );
          
          // If we get a result back, print it (will handle later)
          if (result != null) {
            print('Created: $result');
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}