import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:flutter/material.dart'; 

enum TaskType {
  yesNo,
}

class Task {
  final String id;
  final String title;
  final String? description;
  final String? category;
  final TaskType type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dueDate; 
  final TimeOfDay? reminderTime; 
  final bool notificationsEnabled; 

  final Map<DateTime, bool> completionHistory;
  final bool isCompleted; 

  Task({
    required this.id,
    required this.title,
    this.description,
    this.category,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
    this.reminderTime,
    required this.notificationsEnabled,
    required this.completionHistory,
    required this.isCompleted,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    TaskType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    TimeOfDay? reminderTime,
    bool? notificationsEnabled,
    Map<DateTime, bool>? completionHistory,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueDate: dueDate ?? this.dueDate,
      reminderTime: reminderTime ?? this.reminderTime,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      completionHistory: completionHistory ?? this.completionHistory,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'type': type.toString(), 
      'createdAt': Timestamp.fromDate(createdAt), 
      'updatedAt': Timestamp.fromDate(updatedAt), 
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'reminderTime': reminderTime != null 
          ? '${reminderTime!.hour}:${reminderTime!.minute}'
          : null,
      'notificationsEnabled': notificationsEnabled, 
      'completionHistory': completionHistory.map((key, value) => MapEntry(key.toIso8601String(), value)),
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    // Helper to convert Firestore Timestamp or ISO String to DateTime
    // Added null check for safety when parsing dates from Firestore
    DateTime parseDateTime(dynamic dateValue) {
      if (dateValue == null) {
        return DateTime.now(); // Provide a fallback if date is null
      }
      if (dateValue is Timestamp) {
        return dateValue.toDate();
      }
      if (dateValue is String) {
        return DateTime.parse(dateValue);
      }
      // Fallback for unexpected types, or re-throw if stricter validation is needed
      return DateTime.now(); 
    }

    return Task(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      category: map['category'],
      type: TaskType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => TaskType.yesNo, 
      ),
      createdAt: parseDateTime(map['createdAt']),
      updatedAt: parseDateTime(map['updatedAt']),
      dueDate: map['dueDate'] != null ? parseDateTime(map['dueDate']) : null,
      reminderTime: map['reminderTime'] != null
          ? TimeOfDay(
              hour: int.parse(map['reminderTime'].split(':')[0]),
              minute: int.parse(map['reminderTime'].split(':')[1]),
            )
          : null,
      notificationsEnabled: map['notificationsEnabled'] ?? false, 
      completionHistory: (map['completionHistory'] as Map<String, dynamic>? ?? {})
          .map((key, value) => MapEntry(DateTime.parse(key), value as bool)),
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  void markCompleted(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    completionHistory[dateOnly] = true;
  }

  void markNotCompleted(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    completionHistory[dateOnly] = false;
  }

  bool isCompletedToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return completionHistory[today] == true;
  }
}
