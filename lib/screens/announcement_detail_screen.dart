import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'announcement_form_screen.dart';

class AnnouncementDetailScreen extends StatefulWidget {
  final String announcementId;

  const AnnouncementDetailScreen({super.key, required this.announcementId});

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
    if (data != null) _announcement = Map<String, dynamic>.from(data);
    _isLoading = false;
  }

  void _togglePin() async {
    final Map<String, dynamic> updated = Map.from(_announcement);
    updated['isPinned'] = !(_announcement['isPinned'] as bool);
    await _box.put(widget.announcementId, updated);
    setState(() => _announcement = updated);
  }

  void _editAnnouncement() async {
    final dynamic result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              AnnouncementFormScreen(announcement: _announcement)),
    );
    if (result != null) {
      await _box.put(widget.announcementId, result);
      setState(() => _announcement = Map<String, dynamic>.from(result));
    }
  }

  void _softDelete() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Announcement'),
          content: const Text('Are you sure?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                final Map<String, dynamic> updated = Map.from(_announcement);
                updated['isDeleted'] = true; // ← MUST BE TRUE
                updated['deletedAt'] = DateTime.now().toIso8601String();
                await _box.put(widget.announcementId, updated); // ← SAVE BACK
                if (mounted) {
                  Navigator.pop(context);
                  Navigator.pop(context, true);
                }
              },
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

    final String category = _announcement['category'].toString();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F7),
      appBar: AppBar(
        title: const Text('Announcement Details'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
                _announcement['isPinned']
                    ? Icons.push_pin
                    : Icons.push_pin_outlined,
                color: const Color(0xFFFF8FA3)),
            onPressed: _togglePin,
          ),
          IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFFFF8FA3)),
              onPressed: _editAnnouncement),
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
                          .format(DateTime.parse(_announcement['datePosted'])),
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
              _announcement['title'],
              style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D2D2D)),
            ),
            const SizedBox(height: 20),
            const Divider(color: Color(0xFFEEEEEE)),
            const SizedBox(height: 20),
            // Body
            Text(
              _announcement['body'],
              style: GoogleFonts.inter(
                  fontSize: 16, color: const Color(0xFF555555), height: 1.6),
            ),
          ],
        ),
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
