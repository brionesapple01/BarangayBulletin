import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'announcement_detail_screen.dart';
import 'announcement_form_screen.dart';

class AnnouncementsListScreen extends StatefulWidget {
  const AnnouncementsListScreen({super.key});

  @override
  State<AnnouncementsListScreen> createState() => _AnnouncementsListScreenState();
}

class _AnnouncementsListScreenState extends State<AnnouncementsListScreen> {
  final List<String> _categories = ['All', 'Info', 'Event', 'Emergency', 'Health'];
  String _selectedCategory = 'All';
  late Box _box;
  
  late VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    _box = Hive.box('announcements');
    
    _listener = () {
      if (mounted) {
        setState(() {});
      }
    };
    _box.watch().listen((event) {
      _listener();
    });
    
    if (_box.isEmpty) {
      _addSampleData();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _addSampleData() {
    final List<Map<String, dynamic>> sampleAnnouncements = [
      {
        'id': '1',
        'title': 'Barangay Meeting',
        'body': 'There will be a community meeting on Friday at 8 AM.',
        'category': 'Event',
        'isPinned': true,
        'datePosted': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'isDeleted': false,
        'deletedAt': null,
      },
      {
        'id': '2',
        'title': 'COVID-19 Update',
        'body': 'New vaccination schedule announced.',
        'category': 'Health',
        'isPinned': false,
        'datePosted': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'isDeleted': false,
        'deletedAt': null,
      },
      {
        'id': '3',
        'title': 'Typhoon Warning',
        'body': 'Signal No. 2 raised in our area.',
        'category': 'Emergency',
        'isPinned': true,
        'datePosted': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'isDeleted': false,
        'deletedAt': null,
      },
      {
        'id': '4',
        'title': 'New Barangay Officials',
        'body': 'Please welcome our new barangay officials.',
        'category': 'Info',
        'isPinned': false,
        'datePosted': DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
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
      filtered = filtered.where((a) => a['category'] == _selectedCategory).toList();
    }
    
    filtered.sort((a, b) {
      if (a['isPinned'] != b['isPinned']) {
        return b['isPinned'] ? 1 : -1;
      }
      return DateTime.parse(b['datePosted']).compareTo(DateTime.parse(a['datePosted']));
    });
    
    return filtered;
  }

  void _addAnnouncement() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AnnouncementFormScreen(),
      ),
    );

    if (result != null) {
      await _box.put(result['id'], result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> announcements = _getAnnouncements();
    
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final String category = _categories[index];
                final bool isSelected = _selectedCategory == category;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: const Color.fromARGB(255, 243, 33, 149),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                );
              },
            ),
          ),
          
          Expanded(
            child: announcements.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.campaign,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No announcements found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedCategory == 'All' 
                              ? 'Tap the + button to create one'
                              : 'No announcements in this category',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: announcements.length,
                    itemBuilder: (context, index) {
                      final Map<String, dynamic> announcement = announcements[index];
                      return _buildAnnouncementCard(announcement);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAnnouncement,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAnnouncementCard(Map<String, dynamic> announcement) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        title: Row(
          children: [
            if (announcement['isPinned'] == true)
              const Icon(Icons.push_pin, size: 16, color: Colors.orange),
            if (announcement['isPinned'] == true) const SizedBox(width: 4),
            Expanded(
              child: Text(
                announcement['title'].toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              announcement['body'].toString(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(announcement['category'].toString()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    announcement['category'].toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(DateTime.parse(announcement['datePosted'].toString())),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        onTap: () async {
          final bool? result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnnouncementDetailScreen(
                announcementId: announcement['id'].toString(),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Info':
        return Colors.blue;
      case 'Event':
        return Colors.green;
      case 'Emergency':
        return Colors.red;
      case 'Health':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}