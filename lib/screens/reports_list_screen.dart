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
  final List<String> _statusFilters = [
    'All',
    'Pending',
    'In Progress',
    'Resolved'
  ];
  final List<String> _categoryFilters = [
    'All',
    'Road',
    'Power',
    'Water',
    'Safety',
    'Other'
  ];

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
        'title': 'Broken Traffic Light',
        'description':
            'The traffic light at the main intersection has been non-functional for three days.',
        'category': 'Road',
        'status': 'Pending',
        'dateReported':
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'isDeleted': false,
        'deletedAt': null,
      },
      {
        'id': '2',
        'title': 'Unfinished Road Construction',
        'description':
            'The road construction project has been left unfinished for two weeks.',
        'category': 'Road',
        'status': 'In Progress',
        'dateReported':
            DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'isDeleted': false,
        'deletedAt': null,
      },
      {
        'id': '3',
        'title': 'Fallen Electric Post',
        'description': 'A wooden electric post fell down during the storm.',
        'category': 'Power',
        'status': 'Resolved',
        'dateReported':
            DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
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
      filtered =
          filtered.where((r) => r['category'] == _selectedCategory).toList();
    }

    filtered.sort((a, b) {
      return DateTime.parse(b['dateReported'])
          .compareTo(DateTime.parse(a['dateReported']));
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
      backgroundColor: Colors.transparent,
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
        child: Column(
          children: [
            // Status Filter Chips
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                    height: 50,
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            selectedColor: _getStatusColor(status),
                            backgroundColor: Colors.white,
                            elevation: 0,
                            label: Text(status),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              setState(() {
                                _selectedStatus = status;
                              });
                            },
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : _getStatusColor(status),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Category Dropdown
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Category:',
                    style: TextStyle(
                      fontSize: 14,
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
                          borderRadius: BorderRadius.circular(30),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        filled: true,
                        fillColor: Colors.white,
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

            // Reports List
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
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: reports.length,
                      itemBuilder: (context, index) {
                        final Map<String, dynamic> report = reports[index];
                        return _buildReportCard(report);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addReport,
        backgroundColor: const Color(0xFFE91E63),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("New"),
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final String status = report['status'].toString();
    final String category = report['category'].toString();

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
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
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report['title'].toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  report['description'].toString(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.access_time, size: 12, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM dd, yyyy').format(
                          DateTime.parse(report['dateReported'].toString())),
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                  ],
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
}
