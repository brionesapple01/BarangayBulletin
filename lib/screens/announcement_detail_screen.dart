import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'announcement_form_screen.dart';

class AnnouncementDetailScreen extends StatefulWidget {
  final String announcementId;

  const AnnouncementDetailScreen({
    super.key,
    required this.announcementId,
  });

  @override
  State<AnnouncementDetailScreen> createState() =>
      _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState extends State<AnnouncementDetailScreen> {
  late Box _box;
  late Map<String, dynamic> _announcement;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _box = Hive.box('announcements');
    _loadAnnouncement();
  }

  void _loadAnnouncement() {
    final dynamic data = _box.get(widget.announcementId);
    if (data != null) {
      _announcement = Map<String, dynamic>.from(data);
    }
    _isLoading = false;
  }

  void _togglePin() async {
    final Map<String, dynamic> updated = Map.from(_announcement);
    updated['isPinned'] = !(_announcement['isPinned'] as bool);
    await _box.put(widget.announcementId, updated);
    setState(() {
      _announcement = updated;
    });
  }

  void _editAnnouncement() async {
    final dynamic result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnnouncementFormScreen(
          announcement: _announcement,
        ),
      ),
    );

    if (result != null) {
      await _box.put(widget.announcementId, result);
      setState(() {
        _announcement = Map<String, dynamic>.from(result);
      });
    }
  }

  void _softDelete() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Announcement'),
          content:
              const Text('Are you sure you want to delete this announcement?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final Map<String, dynamic> updated = Map.from(_announcement);
                updated['isDeleted'] = true;
                updated['deletedAt'] = DateTime.now().toIso8601String();
                await _box.put(widget.announcementId, updated);
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

    final String category = _announcement['category'].toString();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Announcement Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(
              (_announcement['isPinned'] as bool)
                  ? Icons.push_pin
                  : Icons.push_pin_outlined,
              color: const Color(0xFFE91E63),
            ),
            onPressed: _togglePin,
            tooltip: (_announcement['isPinned'] as bool) ? 'Unpin' : 'Pin',
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFFE91E63)),
            onPressed: _editAnnouncement,
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
                // Category Badge and Date Row
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
                                  _announcement['datePosted'].toString())),
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
                  _announcement['title'].toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFEEEEEE)),
                const SizedBox(height: 16),

                // Body
                Text(
                  _announcement['body'].toString(),
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
