import 'package:cloud_firestore/cloud_firestore.dart'; // Import Timestamp
import 'package:flutter/material.dart'; // For IconData, Color, TimeOfDay

enum TaskType {
  yesNo,
  // Future types: multipleChoice, numericalInput, etc.
}

class Task {
  final String id;
  final String title;
  final String? description;
  final String? category;
  final TaskType type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dueDate; // Optional due date for tasks
  final TimeOfDay? reminderTime; // Optional reminder time

  // For Yes/No tasks: Map of completion dates and their status (true for yes, false for no/skipped)
  final Map<DateTime, bool> completionHistory;

  // Future extensibility:
  // final Map<String, dynamic>? options; // For multiple choice, numerical ranges, etc.

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
    required this.completionHistory,
    // this.options,
  });

  /// Creates a copy of this Task with the given fields replaced with the new values.
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
    Map<DateTime, bool>? completionHistory,
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
      completionHistory: completionHistory ?? this.completionHistory,
    );
  }

  /// Converts the Task to a Map for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'type': type.toString(), // Store enum as string
      'createdAt': Timestamp.fromDate(createdAt), // Convert DateTime to Timestamp
      'updatedAt': Timestamp.fromDate(updatedAt), // Convert DateTime to Timestamp
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'reminderTime': reminderTime != null
          ? '${reminderTime!.hour}:${reminderTime!.minute}' // Store TimeOfDay as string H:M
          : null,
      // Store completionHistory with keys as ISO8601 strings
      'completionHistory': completionHistory.map(
        (key, value) => MapEntry(key.toIso8601String(), value),
      ),
    };
  }

  /// Creates a Task from a Firestore Map.
  factory Task.fromMap(Map<String, dynamic> map) {
    // Helper to convert Firestore Timestamp or ISO String to DateTime
    DateTime _parseDateTime(dynamic dateValue) {
      if (dateValue is Timestamp) {
        return dateValue.toDate();
      }
      if (dateValue is String) {
        return DateTime.parse(dateValue);
      }
      throw ArgumentError('Invalid date format in Task.fromMap: $dateValue');
    }

    return Task(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      category: map['category'],
      type: TaskType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => TaskType.yesNo, // Default value if type is missing or invalid
      ),
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
      dueDate: map['dueDate'] != null ? _parseDateTime(map['dueDate']) : null,
      reminderTime: map['reminderTime'] != null
          ? TimeOfDay(
              hour: int.parse(map['reminderTime'].split(':')[0]),
              minute: int.parse(map['reminderTime'].split(':')[1]),
            )
          : null,
      completionHistory: (map['completionHistory'] as Map<String, dynamic>? ?? {})
          .map((key, value) => MapEntry(DateTime.parse(key), value as bool)),
    );
  }

  /// Marks the task as completed for the given date.
  void markCompleted(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    completionHistory[dateOnly] = true;
  }

  /// Marks the task as not completed for the given date.
  void markNotCompleted(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    completionHistory[dateOnly] = false;
  }

  /// Checks if the task was completed today.
  bool isCompletedToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return completionHistory[today] == true;
  }
}
