import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  final List<String> _typeFilters = [
    'All',
    'Announcements Only',
    'Reports Only'
  ];
  String _selectedType = 'All';

  late Box _announcementsBox;
  late Box _reportsBox;

  List<Map<String, dynamic>> _archivedItems = [];

  @override
  void initState() {
    super.initState();
    _announcementsBox = Hive.box('announcements');
    _reportsBox = Hive.box('reports');

    _announcementsBox.watch().listen((event) {
      if (mounted) {
        _loadArchivedItems();
      }
    });

    _reportsBox.watch().listen((event) {
      if (mounted) {
        _loadArchivedItems();
      }
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

    items.sort((a, b) {
      return DateTime.parse(b['deletedAt'])
          .compareTo(DateTime.parse(a['deletedAt']));
    });

    if (mounted) {
      setState(() {
        _archivedItems = items;
      });
    }
  }

  List<Map<String, dynamic>> _getFilteredItems() {
    if (_selectedType == 'Announcements Only') {
      return _archivedItems
          .where((item) => item['type'] == 'Announcement')
          .toList();
    } else if (_selectedType == 'Reports Only') {
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

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item['type']} restored successfully'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _hardDelete(Map<String, dynamic> item) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permanent Delete'),
          content: Text(
            'Are you sure you want to permanently delete "${item['title']}"?\n\nThis action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final box = item['box'] == 'announcements'
                    ? _announcementsBox
                    : _reportsBox;
                await box.delete(item['id']);
                _loadArchivedItems();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${item['type']} permanently deleted'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete Permanently'),
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
            Container(
              height: 50,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _typeFilters.length,
                itemBuilder: (context, index) {
                  final String type = _typeFilters[index];
                  final bool isSelected = _selectedType == type;

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
                      selectedColor: const Color(0xFFE91E63),
                      backgroundColor: Colors.white,
                      elevation: 0,
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedType = type;
                        });
                      },
                      labelStyle: TextStyle(
                        color:
                            isSelected ? Colors.white : const Color(0xFFE91E63),
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: filteredItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.archive_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nothing in the archive',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Deleted items will appear here',
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
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return _buildArchiveCard(item);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArchiveCard(Map<String, dynamic> item) {
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
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: CircleAvatar(
            backgroundColor: item['type'] == 'Announcement'
                ? Colors.blue[100]
                : Colors.orange[100],
            child: Icon(
              item['type'] == 'Announcement'
                  ? Icons.campaign
                  : Icons.report_problem,
              color: item['type'] == 'Announcement'
                  ? Colors.blue[700]
                  : Colors.orange[700],
              size: 20,
            ),
          ),
          title: Text(
            item['title'].toString(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: item['type'] == 'Announcement'
                      ? Colors.blue[50]
                      : Colors.orange[50],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  item['type'].toString(),
                  style: TextStyle(
                    color: item['type'] == 'Announcement'
                        ? Colors.blue[700]
                        : Colors.orange[700],
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.delete_outline, size: 12, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(
                'Deleted: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(item['deletedAt']))}',
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _restoreItem(item),
                icon: const Icon(Icons.restore, color: Colors.green),
              ),
              IconButton(
                onPressed: () => _hardDelete(item),
                icon: const Icon(Icons.delete_forever, color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
