import 'package:flutter/material.dart';
import 'report_form_screen.dart';

class ReportDetailScreen extends StatelessWidget {
  final int reportIndex;

  const ReportDetailScreen({
    super.key,
    required this.reportIndex,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, String> sampleReport = {
      'title': 'Report ${reportIndex + 1}',
      'body': 'This is the detailed description of report ${reportIndex + 1}',
    };

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
                    title: sampleReport['title'],
                    body: sampleReport['body'],
                  ),
                ),
              );

              if (result != null) {
                Navigator.pop(context, result);
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
              sampleReport['title']!,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(sampleReport['body']!),
          ],
        ),
      ),
    );
  }
}