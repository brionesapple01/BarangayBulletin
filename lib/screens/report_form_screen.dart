import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ReportFormScreen extends StatefulWidget {
  final Map<String, dynamic>? report;

  const ReportFormScreen({super.key, this.report});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _selectedCategory;

  final List<String> _categories = ['Road', 'Power', 'Water', 'Safety', 'Other'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.report?['title'] ?? '');
    _descriptionController = TextEditingController(text: widget.report?['description'] ?? '');
    _selectedCategory = widget.report?['category'] ?? 'Road';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> result = {
        'id': widget.report?['id'] ?? const Uuid().v4(),
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'status': widget.report?['status'] ?? 'Pending',
        'dateReported': widget.report?['dateReported'] ?? DateTime.now().toIso8601String(),
        'isDeleted': widget.report?['isDeleted'] ?? false,
        'deletedAt': widget.report?['deletedAt'],
      };
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditMode = widget.report != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Report' : 'New Report'),
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
                  labelText: 'Report Title',
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
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
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