import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'report_form_screen.dart';

class ReportDetailScreen extends StatefulWidget {
  final String reportId;

  const ReportDetailScreen({
    super.key,
    required this.reportId,
  });

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  late Box _box;
  late Map<String, dynamic> _report;
  bool _isLoading = true;

  final List<String> _statusOptions = ['Pending', 'In Progress', 'Resolved'];

  @override
  void initState() {
    super.initState();
    _box = Hive.box('reports');
    _loadReport();
  }

  void _loadReport() {
    final dynamic data = _box.get(widget.reportId);
    if (data != null) {
      _report = Map<String, dynamic>.from(data);
    }
    _isLoading = false;
  }

  void _updateStatus(String newStatus) async {
    final Map<String, dynamic> updated = Map.from(_report);
    updated['status'] = newStatus;
    await _box.put(widget.reportId, updated);
    setState(() {
      _report = updated;
    });
  }

  void _editReport() async {
    final dynamic result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportFormScreen(
          report: _report,
        ),
      ),
    );

    if (result != null) {
      await _box.put(widget.reportId, result);
      setState(() {
        _report = Map<String, dynamic>.from(result);
      });
    }
  }

  void _softDelete() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Report'),
          content: const Text('Are you sure you want to delete this report?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final Map<String, dynamic> updated = Map.from(_report);
                updated['isDeleted'] = true;
                updated['deletedAt'] = DateTime.now().toIso8601String();
                await _box.put(widget.reportId, updated);
                if (mounted) {
                  Navigator.pop(context); 
                  Navigator.pop(context, true); 
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editReport,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _softDelete,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _statusOptions.map((String status) {
                      final bool isSelected = _report['status'] == status;
                      return ChoiceChip(
                        label: Text(status),
                        selected: isSelected,
                        onSelected: (bool selected) {
                          if (selected) {
                            _updateStatus(status);
                          }
                        },
                        backgroundColor: Colors.white,
                        selectedColor: _getStatusColor(status),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _report['category'].toString(),
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd, yyyy h:mm a').format(DateTime.parse(_report['dateReported'].toString())),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Text(
              _report['title'].toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            Text(
              _report['description'].toString(),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'In Progress':
        return Colors.blue;
      case 'Resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}