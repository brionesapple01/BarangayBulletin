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
    _titleController = TextEditingController(text: widget.announcement?['title'] ?? '');
    _bodyController = TextEditingController(text: widget.announcement?['body'] ?? '');
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
        'datePosted': widget.announcement?['datePosted'] ?? DateTime.now().toIso8601String(),
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
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Announcement' : 'New Announcement'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bodyController,
                decoration: const InputDecoration(
                  labelText: 'Body',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the body content';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
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
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Pin this announcement'),
                  const Spacer(),
                  Switch(
                    value: _isPinned,
                    onChanged: (bool value) {
                      setState(() {
                        _isPinned = value;
                      });
                    },
                    activeColor: const Color.fromARGB(255, 243, 33, 149),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Save'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}