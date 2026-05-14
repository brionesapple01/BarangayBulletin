import 'package:flutter/material.dart';
import 'report_detail_screen.dart';
import 'report_form_screen.dart';

class ReportsListScreen extends StatelessWidget {
  const ReportsListScreen({super.key});

  void _addReport(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ReportFormScreen(),
      ),
    );

    if (result != null) {
      print('Report added: $result');
    }
  }

  void _openDetail(BuildContext context, int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportDetailScreen(
          reportIndex: index,
        ),
      ),
    );

    if (result != null) {
      print('Report updated: $result');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> sampleReports = [
      {'title': 'Report 1', 'body': 'Street light broken'},
      {'title': 'Report 2', 'body': 'Garbage not collected'},
      {'title': 'Report 3', 'body': 'Noise complaint'},
    ];

    return Scaffold(
      body: ListView.builder(
        itemCount: sampleReports.length,
        itemBuilder: (context, index) {
          final item = sampleReports[index];
          
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
              subtitle: Text(item['body']!),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openDetail(context, index),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addReport(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}