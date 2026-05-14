import 'package:flutter/material.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> archivedItems = [
      {
        'title': 'Old Announcement 1',
        'body': 'This announcement was archived.',
        'type': 'Announcement',
      },
      {
        'title': 'Old Report 1',
        'body': 'This report was resolved and archived.',
        'type': 'Report',
      },
      {
        'title': 'Old Announcement 2',
        'body': 'Another archived announcement.',
        'type': 'Announcement',
      },
    ];

    return Scaffold(
      body: archivedItems.isEmpty
          ? const Center(
              child: Text("No archived items"),
            )
          : ListView.builder(
              itemCount: archivedItems.length,
              itemBuilder: (context, index) {
                final item = archivedItems[index];
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2,
                  child: ListTile(
                    leading: Icon(
                      item['type'] == 'Announcement' 
                          ? Icons.campaign 
                          : Icons.report_problem,
                      color: Colors.grey,
                    ),
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
                    trailing: const Icon(Icons.archive, color: Colors.grey),
                    onTap: null, 
                  ),
                );
              },
            ),
    );
  }
}