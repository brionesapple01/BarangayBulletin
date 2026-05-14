import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class Announcement {
  final String id;
  String title;
  String body;
  String category;
  bool isPinned;
  DateTime datePosted;
  bool isDeleted;
  DateTime? deletedAt;

  Announcement({
    String? id,
    required this.title,
    required this.body,
    required this.category,
    this.isPinned = false,
    DateTime? datePosted,
    this.isDeleted = false,
    this.deletedAt,
  }) : id = id ?? const Uuid().v4(),
       datePosted = datePosted ?? DateTime.now();

  Announcement copyWith({
    String? title,
    String? body,
    String? category,
    bool? isPinned,
    DateTime? datePosted,
    bool? isDeleted,
    DateTime? deletedAt,
  }) {
    return Announcement(
      id: this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      isPinned: isPinned ?? this.isPinned,
      datePosted: datePosted ?? this.datePosted,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}