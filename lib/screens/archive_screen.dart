import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  final List<String> _typeFilters = ['All', 'Announcements', 'Reports'];
  String _selectedType = 'All';

  late Box _announcementsBox;
  late Box _reportsBox;
  List<Map<String, dynamic>> _archivedItems = [];

  @override
  void initState() {
    super.initState();
    _announcementsBox = Hive.box('announcements');
    _reportsBox = Hive.box('reports');

    // ADD THESE LISTENERS - Auto refresh when data changes
    _announcementsBox.watch().listen((event) {
      if (mounted) _loadArchivedItems();
    });
    _reportsBox.watch().listen((event) {
      if (mounted) _loadArchivedItems();
    });

    _loadArchivedItems();
  }

  void _loadArchivedItems() {
    final List<Map<String, dynamic>> items = [];

    for (var key in _announcementsBox.keys) {
      final item = _announcementsBox.get(key);
      if (item != null && item['isDeleted'] == true) {
        items.add({
          'id': key,
          'type': 'Announcement',
          'title': item['title'],
          'deletedAt': item['deletedAt'],
          'originalData': item,
          'box': 'announcements',
        });
      }
    }

    for (var key in _reportsBox.keys) {
      final item = _reportsBox.get(key);
      if (item != null && item['isDeleted'] == true) {
        items.add({
          'id': key,
          'type': 'Report',
          'title': item['title'],
          'deletedAt': item['deletedAt'],
          'originalData': item,
          'box': 'reports',
        });
      }
    }

    items.sort((a, b) => DateTime.parse(b['deletedAt'])
        .compareTo(DateTime.parse(a['deletedAt'])));
    setState(() => _archivedItems = items);
  }

  List<Map<String, dynamic>> _getFilteredItems() {
    if (_selectedType == 'Announcements') {
      return _archivedItems
          .where((item) => item['type'] == 'Announcement')
          .toList();
    } else if (_selectedType == 'Reports') {
      return _archivedItems.where((item) => item['type'] == 'Report').toList();
    }
    return _archivedItems;
  }

  void _restoreItem(Map<String, dynamic> item) async {
    final box =
        item['box'] == 'announcements' ? _announcementsBox : _reportsBox;
    final Map<String, dynamic> updatedData = Map.from(item['originalData']);
    updatedData['isDeleted'] = false;
    updatedData['deletedAt'] = null;
    await box.put(item['id'], updatedData);
    _loadArchivedItems();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('${item['type']} restored'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2)),
    );
  }

  void _hardDelete(Map<String, dynamic> item) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permanent Delete'),
          content: Text('Delete "${item['title']}" permanently?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                final box = item['box'] == 'announcements'
                    ? _announcementsBox
                    : _reportsBox;
                await box.delete(item['id']);
                _loadArchivedItems();
                if (mounted) Navigator.pop(context);
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
    final filteredItems = _getFilteredItems();

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
                    'Archive 📦',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Restore or permanently delete items',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Filter Chips
          SliverToBoxAdapter(
            child: SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _typeFilters.length,
                itemBuilder: (context, index) {
                  final type = _typeFilters[index];
                  final isSelected = _selectedType == type;
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: FilterChip(
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedType = type),
                      backgroundColor: Colors.white,
                      selectedColor: const Color(0xFFFFB7C5),
                      labelStyle: GoogleFonts.inter(
                        color:
                            isSelected ? Colors.white : const Color(0xFF2D2D2D),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Archive List
          filteredItems.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.archive_outlined,
                            size: 64, color: const Color(0xFFFFB7C5)),
                        const SizedBox(height: 16),
                        Text(
                          'Nothing in the archive',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2D2D2D),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Deleted items will appear here',
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
                      final item = filteredItems[index];
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
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: item['type'] == 'Announcement'
                                    ? const Color(0xFFFFB7C5).withOpacity(0.2)
                                    : const Color(0xFFFF8FA3).withOpacity(0.2),
                                child: Icon(
                                  item['type'] == 'Announcement'
                                      ? Icons.campaign
                                      : Icons.report_problem,
                                  color: item['type'] == 'Announcement'
                                      ? const Color(0xFFFFB7C5)
                                      : const Color(0xFFFF8FA3),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF2D2D2D),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color:
                                                item['type'] == 'Announcement'
                                                    ? const Color(0xFFFFB7C5)
                                                        .withOpacity(0.15)
                                                    : const Color(0xFFFF8FA3)
                                                        .withOpacity(0.15),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            item['type'],
                                            style: GoogleFonts.inter(
                                              color:
                                                  item['type'] == 'Announcement'
                                                      ? const Color(0xFFFFB7C5)
                                                      : const Color(0xFFFF8FA3),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(Icons.delete_outline,
                                            size: 12,
                                            color: const Color(0xFFBDBDBD)),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Deleted: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(item['deletedAt']))}',
                                          style: GoogleFonts.inter(
                                              fontSize: 11,
                                              color: const Color(0xFFBDBDBD)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => _restoreItem(item),
                                    icon: const Icon(Icons.restore,
                                        color: Color(0xFF81C784)),
                                  ),
                                  IconButton(
                                    onPressed: () => _hardDelete(item),
                                    icon: const Icon(Icons.delete_forever,
                                        color: Color(0xFFE57373)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: filteredItems.length,
                  ),
                ),
        ],
      ),
    );
  }
}
