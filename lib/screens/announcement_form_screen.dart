import 'package:flutter/material.dart';

class AnnouncementFormScreen extends StatefulWidget {
  final String? title;
  final String? body;

  const AnnouncementFormScreen({super.key, this.title, this.body});

  @override
  State<AnnouncementFormScreen> createState() =>
      _AnnouncementFormScreenState();
}

class _AnnouncementFormScreenState extends State<AnnouncementFormScreen> {
  late TextEditingController titleController;
  late TextEditingController bodyController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.title ?? '');
    bodyController = TextEditingController(text: widget.body ?? '');
  }

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.title != null && widget.body != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Announcement' : 'New Announcement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bodyController,
              decoration: const InputDecoration(
                labelText: 'Body',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final result = {
                  'title': titleController.text,
                  'body': bodyController.text,
                };
                Navigator.pop(context, result);
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}