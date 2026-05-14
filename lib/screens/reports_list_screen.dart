import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'report_detail_screen.dart';
import 'report_form_screen.dart';

class ReportsListScreen extends StatefulWidget {
  const ReportsListScreen({super.key});

  @override
  State<ReportsListScreen> createState() => _ReportsListScreenState();
}

class _ReportsListScreenState extends State<ReportsListScreen> {
  final List<String> _statusFilters = ['All', 'Pending', 'In Progress', 'Resolved'];
  final List<String> _categoryFilters = ['All', 'Road', 'Power', 'Water', 'Safety', 'Other'];
  
  String _selectedStatus = 'All';
  String _selectedCategory = 'All';
  late Box _box;

  @override
  void initState() {
    super.initState();
    _box = Hive.box('reports');
    
    _box.watch().listen((event) {
      if (mounted) {
        setState(() {});
      }
    });
    
    if (_box.isEmpty) {
      _addSampleData();
    }
  }

  void _addSampleData() {
    final List<Map<String, dynamic>> sampleReports = [
      {
        'id': '1',
        'title': 'Pothole on Main Street',
        'description': 'Large pothole causing traffic issues near the intersection.',
        'category': 'Road',
        'status': 'Pending',
        'dateReported': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'isDeleted': false,
        'deletedAt': null,
      },
      {
        'id': '2',
        'title': 'Power Outage',
        'description': 'No electricity in Barangay Hall area since 2 PM.',
        'category': 'Power',
        'status': 'In Progress',
        'dateReported': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'isDeleted': false,
        'deletedAt': null,
      },
      {
        'id': '3',
        'title': 'Water Supply Interruption',
        'description': 'No water supply for 3 days in Phase 2.',
        'category': 'Water',
        'status': 'Resolved',
        'dateReported': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'isDeleted': false,
        'deletedAt': null,
      },
    ];

    for (var report in sampleReports) {
      _box.put(report['id'], report);
    }
  }

  List<Map<String, dynamic>> _getReports() {
    final List<Map<String, dynamic>> allReports = [];
    
    for (var key in _box.keys) {
      final item = _box.get(key);
      if (item != null && item['isDeleted'] == false) {
        allReports.add(Map<String, dynamic>.from(item));
      }
    }
    
    List<Map<String, dynamic>> filtered = List.from(allReports);
    if (_selectedStatus != 'All') {
      filtered = filtered.where((r) => r['status'] == _selectedStatus).toList();
    }
    
    if (_selectedCategory != 'All') {
      filtered = filtered.where((r) => r['category'] == _selectedCategory).toList();
    }
    
    filtered.sort((a, b) {
      return DateTime.parse(b['dateReported']).compareTo(DateTime.parse(a['dateReported']));
    });
    
    return filtered;
  }

  void _addReport() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ReportFormScreen(),
      ),
    );

    if (result != null) {
      await _box.put(result['id'], result);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> reports = _getReports();
    
    return Scaffold(
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _statusFilters.length,
                    itemBuilder: (context, index) {
                      final String status = _statusFilters[index];
                      final bool isSelected = _selectedStatus == status;
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(status),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() {
                              _selectedStatus = status;
                            });
                          },
                          backgroundColor: Colors.grey[200],
                          selectedColor: _getStatusColor(status),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Category:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: _categoryFilters.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          Expanded(
            child: reports.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.report_problem,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No reports found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the + button to submit a report',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final Map<String, dynamic> report = reports[index];
                      return _buildReportCard(report);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addReport,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        title: Text(
          report['title'].toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              report['description'].toString(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(report['status'].toString()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    report['status'].toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    report['category'].toString(),
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(DateTime.parse(report['dateReported'].toString())),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportDetailScreen(
                reportId: report['id'].toString(),
              ),
            ),
          );
          setState(() {});
        },
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