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
  State<AnnouncementDetailScreen> createState() => _AnnouncementDetailScreenState();
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
          content: const Text('Are you sure you want to delete this announcement?'),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcement Details'),
        actions: [
          IconButton(
            icon: Icon(
              (_announcement['isPinned'] as bool) ? Icons.push_pin : Icons.push_pin_outlined,
            ),
            onPressed: _togglePin,
            tooltip: (_announcement['isPinned'] as bool) ? 'Unpin' : 'Pin',
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editAnnouncement,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _softDelete,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(_announcement['category'].toString()),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _announcement['category'].toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd, yyyy h:mm a').format(DateTime.parse(_announcement['datePosted'].toString())),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _announcement['title'].toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              _announcement['body'].toString(),
              style: const TextStyle(fontSize: 16),
            ),
          ],
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