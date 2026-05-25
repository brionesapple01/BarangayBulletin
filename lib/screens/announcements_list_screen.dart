import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'announcement_detail_screen.dart';
import 'announcement_form_screen.dart';

class AnnouncementsListScreen extends StatefulWidget {
  const AnnouncementsListScreen({super.key});

  @override
  State<AnnouncementsListScreen> createState() =>
      _AnnouncementsListScreenState();
}

class _AnnouncementsListScreenState extends State<AnnouncementsListScreen> {
  final List<String> _categories = [
    'All',
    'Info',
    'Event',
    'Emergency',
    'Health'
  ];
  String _selectedCategory = 'All';
  late Box _box;

  @override
  void initState() {
    super.initState();
    _box = Hive.box('announcements');
    _box.watch().listen((event) {
      if (mounted) setState(() {});
    });
    if (_box.isEmpty) _addSampleData();
  }

  void _addSampleData() {
    final List<Map<String, dynamic>> sampleAnnouncements = [
      {
        'id': '1',
        'title': 'New Barangay Clearance Process',
        'body':
            'The Barangay Office is pleased to announce that starting June 1, 2024, all barangay clearance applications will be processed through our new barangay system.',
        'category': 'Info',
        'isPinned': false,
        'datePosted':
            DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'isDeleted': false,
        'deletedAt': null,
      },
      {
        'id': '2',
        'title': 'Senior Citizen Benefits Registration',
        'body':
            'All senior citizens aged 60+ who have not yet registered are encouraged to visit the Barangay Health Center.',
        'category': 'Info',
        'isPinned': true,
        'datePosted':
            DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'isDeleted': false,
        'deletedAt': null,
      },
      {
        'id': '3',
        'title': 'Blood Donation Drive',
        'body':
            'The Barangay Health Center will conduct a Blood Donation Drive on July 15, 2024.',
        'category': 'Event',
        'isPinned': false,
        'datePosted':
            DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'isDeleted': false,
        'deletedAt': null,
      },
    ];
    for (var announcement in sampleAnnouncements) {
      _box.put(announcement['id'], announcement);
    }
  }

  List<Map<String, dynamic>> _getAnnouncements() {
    final List<Map<String, dynamic>> allAnnouncements = [];
    for (var key in _box.keys) {
      final item = _box.get(key);
      if (item != null && item['isDeleted'] == false) {
        allAnnouncements.add(Map<String, dynamic>.from(item));
      }
    }
    List<Map<String, dynamic>> filtered = List.from(allAnnouncements);
    if (_selectedCategory != 'All') {
      filtered =
          filtered.where((a) => a['category'] == _selectedCategory).toList();
    }
    filtered.sort((a, b) {
      if (a['isPinned'] != b['isPinned']) return b['isPinned'] ? 1 : -1;
      return DateTime.parse(b['datePosted'])
          .compareTo(DateTime.parse(a['datePosted']));
    });
    return filtered;
  }

  void _addAnnouncement() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AnnouncementFormScreen()),
    );
    if (result != null) {
      await _box.put(result['id'], result);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final announcements = _getAnnouncements();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F7),
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, Resident! 👋',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Stay updated with barangay announcements',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Category Chips
          SliverToBoxAdapter(
            child: SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = category),
                      backgroundColor: Colors.white,
                      selectedColor: const Color(0xFFFFB7C5),
                      labelStyle: GoogleFonts.inter(
                        color:
                            isSelected ? Colors.white : const Color(0xFF2D2D2D),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      shape: StadiumBorder(
                        side: isSelected
                            ? BorderSide.none
                            : BorderSide(
                                color:
                                    const Color(0xFFFFB7C5).withOpacity(0.5)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Announcement Count
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
              child: Row(
                children: [
                  Text(
                    '${announcements.length} Announcements',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFF8FA3),
                    ),
                  ),
                  const Spacer(),
                  if (_selectedCategory != 'All')
                    GestureDetector(
                      onTap: () => setState(() => _selectedCategory = 'All'),
                      child: Text(
                        'Clear Filter',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFFFF8FA3),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Announcement List
          announcements.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.campaign_outlined,
                            size: 64, color: const Color(0xFFFFB7C5)),
                        const SizedBox(height: 16),
                        Text(
                          'No announcements yet',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2D2D2D),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the + button to create one',
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
                      final item = announcements[index];
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
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AnnouncementDetailScreen(
                                    announcementId: item['id'].toString(),
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
                                  Row(
                                    children: [
                                      if (item['isPinned'] == true)
                                        const Icon(Icons.push_pin,
                                            size: 16, color: Color(0xFFFF8FA3)),
                                      if (item['isPinned'] == true)
                                        const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          item['title'],
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF2D2D2D),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getCategoryColor(category),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          category,
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item['body'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: const Color(0xFF757575)),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time,
                                          size: 12,
                                          color: const Color(0xFFBDBDBD)),
                                      const SizedBox(width: 4),
                                      Text(
                                        DateFormat('MMM dd, yyyy').format(
                                            DateTime.parse(item['datePosted'])),
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
                    childCount: announcements.length,
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAnnouncement,
        backgroundColor: const Color(0xFFFF8FA3),
        elevation: 0,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Info':
        return const Color(0xFF6C5CE7);
      case 'Event':
        return const Color(0xFF00B894);
      case 'Emergency':
        return const Color(0xFFE17055);
      case 'Health':
        return const Color(0xFFA29BFE);
      default:
        return const Color(0xFFFFB7C5);
    }
  }
}
