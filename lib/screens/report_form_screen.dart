import 'package:flutter/material.dart';

class ReportFormScreen extends StatefulWidget {
  final String? title;
  final String? body;
  final String? status;

  const ReportFormScreen({
    super.key,
    this.title,
    this.body,
    this.status,
  });

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  late TextEditingController titleController;
  late TextEditingController bodyController;
  late String selectedStatus;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.title ?? '');
    bodyController = TextEditingController(text: widget.body ?? '');
    selectedStatus = widget.status ?? 'Pending';
  }

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.title != null || widget.body != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Report' : 'New Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Issue Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bodyController,
              decoration: const InputDecoration(
                labelText: 'Issue Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            const Text(
              'Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                DropdownMenuItem(value: 'In Progress', child: Text('In Progress')),
                DropdownMenuItem(value: 'Resolved', child: Text('Resolved')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedStatus = value!;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final result = {
                  'title': titleController.text,
                  'body': bodyController.text,
                  'status': selectedStatus,
                };
                Navigator.pop(context, result);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Save'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}