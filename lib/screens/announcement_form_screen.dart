import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class AnnouncementFormScreen extends StatefulWidget {
  final Map<String, dynamic>? announcement;

  const AnnouncementFormScreen({super.key, this.announcement});

  @override
  State<AnnouncementFormScreen> createState() => _AnnouncementFormScreenState();
}

class _AnnouncementFormScreenState extends State<AnnouncementFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  late String _selectedCategory;
  late bool _isPinned;

  final List<String> _categories = ['Info', 'Event', 'Emergency', 'Health'];

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.announcement?['title'] ?? '');
    _bodyController =
        TextEditingController(text: widget.announcement?['body'] ?? '');
    _selectedCategory = widget.announcement?['category'] ?? 'Info';
    _isPinned = widget.announcement?['isPinned'] ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> result = {
        'id': widget.announcement?['id'] ?? const Uuid().v4(),
        'title': _titleController.text.trim(),
        'body': _bodyController.text.trim(),
        'category': _selectedCategory,
        'isPinned': _isPinned,
        'datePosted': widget.announcement?['datePosted'] ??
            DateTime.now().toIso8601String(),
        'isDeleted': widget.announcement?['isDeleted'] ?? false,
        'deletedAt': widget.announcement?['deletedAt'],
      };
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditMode = widget.announcement != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Announcement' : 'New Announcement'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Field
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'Title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon:
                          const Icon(Icons.title, color: Color(0xFFE91E63)),
                    ),
                    validator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Body Field
                  TextFormField(
                    controller: _bodyController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'Body',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.description,
                          color: Color(0xFFE91E63)),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 8,
                    validator: (String? value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the body content';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon:
                          const Icon(Icons.category, color: Color(0xFFE91E63)),
                    ),
                    items: _categories.map((String category) {
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
                    validator: (String? value) {
                      if (value == null) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Pin Switch
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.push_pin, color: Color(0xFFE91E63)),
                        const SizedBox(width: 12),
                        const Text(
                          'Pin this announcement',
                          style: TextStyle(fontSize: 16),
                        ),
                        const Spacer(),
                        Switch(
                          value: _isPinned,
                          onChanged: (bool value) {
                            setState(() {
                              _isPinned = value;
                            });
                          },
                          activeColor: const Color(0xFFE91E63),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 54),
                      backgroundColor: const Color(0xFFE91E63),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Save',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Cancel Button
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
