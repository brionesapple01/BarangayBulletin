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

    final String category = _report['category'].toString();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Report Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFFE91E63)),
            onPressed: _editReport,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _softDelete,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF1F6),
              Color(0xFFF8F9FF),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE91E63),
                        ),
                      ),
                      const SizedBox(height: 12),
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
                              color: isSelected
                                  ? Colors.white
                                  : _getStatusColor(status),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            side: BorderSide(
                              color: _getStatusColor(status).withOpacity(0.5),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Category Badge and Date
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(category),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 14, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM dd, yyyy h:mm a').format(
                              DateTime.parse(
                                  _report['dateReported'].toString())),
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Title
                Text(
                  _report['title'].toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(color: Color(0xFFEEEEEE)),
                const SizedBox(height: 16),

                // Description
                Text(
                  _report['description'].toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF555555),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
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

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Road':
        return Colors.brown;
      case 'Power':
        return Colors.amber;
      case 'Water':
        return Colors.cyan;
      case 'Safety':
        return Colors.purple;
      case 'Other':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
