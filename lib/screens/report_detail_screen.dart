import 'package:flutter/material.dart';
import 'report_form_screen.dart';

class ReportDetailScreen extends StatelessWidget {
  final Map<String, String> report;
  final int index;
  final Function(int, Map<String, String>) onUpdate;

  const ReportDetailScreen({
    super.key,
    required this.report,
    required this.index,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReportFormScreen(
                    title: report['title'],
                    body: report['body'],
                    status: report['status'],
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
              report['title']!,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(report['status'] ?? 'Pending'),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                report['status'] ?? 'Pending',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              report['body']!,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Resolved':
        return Colors.green;
      case 'In Progress':
        return Colors.orange;
      case 'Pending':
      default:
        return Colors.red;
    }
  }
}