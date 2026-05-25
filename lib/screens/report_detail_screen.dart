import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'report_form_screen.dart';

class ReportDetailScreen extends StatefulWidget {
  final String reportId;

  const ReportDetailScreen({super.key, required this.reportId});

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
    if (data != null) _report = Map<String, dynamic>.from(data);
    _isLoading = false;
  }

  void _updateStatus(String newStatus) async {
    final Map<String, dynamic> updated = Map.from(_report);
    updated['status'] = newStatus;
    await _box.put(widget.reportId, updated);
    setState(() => _report = updated);
  }

  void _editReport() async {
    final dynamic result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ReportFormScreen(report: _report)),
    );
    if (result != null) {
      await _box.put(widget.reportId, result);
      setState(() => _report = Map<String, dynamic>.from(result));
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
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final Map<String, dynamic> updated = Map.from(_report);
                updated['isDeleted'] = true;
                updated['deletedAt'] = DateTime.now().toIso8601String();
                await _box.put(widget.reportId, updated);
                if (mounted) {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context, true); // Close detail screen
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final String category = _report['category'].toString();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F7),
      appBar: AppBar(
        title: const Text('Report Details'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFFFF8FA3)),
              onPressed: _editReport),
          IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _softDelete),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status',
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFF8FA3)),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: _statusOptions.map((String status) {
                      final bool isSelected = _report['status'] == status;
                      return ChoiceChip(
                        label: Text(status),
                        selected: isSelected,
                        onSelected: (bool selected) =>
                            selected ? _updateStatus(status) : null,
                        backgroundColor: Colors.white,
                        selectedColor: _getStatusColor(status),
                        labelStyle: GoogleFonts.inter(
                          color: isSelected
                              ? Colors.white
                              : _getStatusColor(status),
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        side: BorderSide(
                            color: _getStatusColor(status).withOpacity(0.3)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Header Row
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(category),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category,
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 11),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 14, color: const Color(0xFFBDBDBD)),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM dd, yyyy h:mm a')
                          .format(DateTime.parse(_report['dateReported'])),
                      style: GoogleFonts.inter(
                          fontSize: 12, color: const Color(0xFFBDBDBD)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Title
            Text(
              _report['title'],
              style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D2D2D)),
            ),
            const SizedBox(height: 20),
            const Divider(color: Color(0xFFEEEEEE)),
            const SizedBox(height: 20),
            // Description
            Text(
              _report['description'],
              style: GoogleFonts.inter(
                  fontSize: 16, color: const Color(0xFF555555), height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFFFFB74D);
      case 'In Progress':
        return const Color(0xFF64B5F6);
      case 'Resolved':
        return const Color(0xFF81C784);
      default:
        return const Color(0xFFBDBDBD);
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Road':
        return const Color(0xFF795548);
      case 'Power':
        return const Color(0xFFFFA726);
      case 'Water':
        return const Color(0xFF4FC3F7);
      case 'Safety':
        return const Color(0xFFBA68C8);
      default:
        return const Color(0xFFBDBDBD);
    }
  }
}
