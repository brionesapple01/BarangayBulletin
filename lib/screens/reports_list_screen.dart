import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      if (mounted) setState(() {});
    });
    if (_box.isEmpty) _addSampleData();
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
    filtered.sort((a, b) => DateTime.parse(b['dateReported'])
        .compareTo(DateTime.parse(a['dateReported'])));
    return filtered;
  }

  void _addReport() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReportFormScreen()),
    );
    if (result != null) {
      await _box.put(result['id'], result);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final reports = _getReports();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F7),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Report an Issue 📝',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Help improve our community',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text(
                    'Filter by Status',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFF8FA3),
                    ),
                  ),
                ),
                SizedBox(
                  height: 45,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _statusFilters.length,
                    itemBuilder: (context, index) {
                      final status = _statusFilters[index];
                      final isSelected = _selectedStatus == status;
                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: FilterChip(
                          label: Text(status),
                          selected: isSelected,
                          onSelected: (_) =>
                              setState(() => _selectedStatus = status),
                          backgroundColor: Colors.white,
                          selectedColor: _getStatusColor(status),
                          labelStyle: GoogleFonts.inter(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF2D2D2D),
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                          shape: StadiumBorder(
                            side: isSelected
                                ? BorderSide.none
                                : BorderSide(
                                    color: _getStatusColor(status)
                                        .withOpacity(0.5)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down,
                      color: Color(0xFFFF8FA3)),
                  items: _categoryFilters.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(
                        category,
                        style:
                            GoogleFonts.inter(color: const Color(0xFF2D2D2D)),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
              child: Text(
                '${reports.length} Reports',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFF8FA3),
                ),
              ),
            ),
          ),
          reports.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.report_problem_outlined,
                            size: 64, color: const Color(0xFFFFB7C5)),
                        const SizedBox(height: 16),
                        Text(
                          'No reports yet',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2D2D2D),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the + button to submit a report',
                          style: GoogleFonts.inter(
                              fontSize: 14, color: const Color(0xFF9E9E9E)),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = reports[index];
                      final status = item['status'].toString();
                      final category = item['category'].toString();
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReportDetailScreen(
                                    reportId: item['id'].toString(),
                                  ),
                                ),
                              );
                              if (result == true) {
                                setState(() {});
                              }
                            },
                            borderRadius: BorderRadius.circular(24),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF2D2D2D),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item['description'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: const Color(0xFF757575)),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(status),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          status,
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF5F5F5),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          category,
                                          style: GoogleFonts.inter(
                                            color: const Color(0xFF757575),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Icon(Icons.access_time,
                                          size: 12,
                                          color: const Color(0xFFBDBDBD)),
                                      const SizedBox(width: 4),
                                      Text(
                                        DateFormat('MMM dd').format(
                                            DateTime.parse(
                                                item['dateReported'])),
                                        style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: const Color(0xFFBDBDBD)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: reports.length,
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addReport,
        backgroundColor: const Color(0xFFFF8FA3),
        elevation: 0,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
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
}
