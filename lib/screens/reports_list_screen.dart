import 'package:flutter/material.dart';
import 'report_detail_screen.dart';
import 'report_form_screen.dart';

class ReportsListScreen extends StatelessWidget {
  final List<Map<String, String>> reports;
  final Function(Map<String, String>) onAddReport;
  final Function(int, Map<String, String>) onUpdateReport;

  const ReportsListScreen({
    super.key,
    required this.reports,
    required this.onAddReport,
    required this.onUpdateReport,
  });

  void _addReport(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ReportFormScreen(),
      ),
    );

    if (result != null) {
      onAddReport(result);
    }
  }

  void _openDetail(BuildContext context, Map<String, String> report, int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportDetailScreen(
          report: report,
          index: index,
          onUpdate: onUpdateReport,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: reports.isEmpty
          ? const Center(
              child: Text("No reports submitted"),
            )
          : ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final item = reports[index];
                
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
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['body']!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor(item['status'] ?? 'Pending'),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item['status'] ?? 'Pending',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openDetail(context, item, index),
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