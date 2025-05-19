import 'package:flutter/material.dart';

/// Represents a habit that the user wants to track.
class Habit {
  /// Unique identifier for the habit
  final String id;

  /// Title of the habit
  final String title;

  /// Optional description of the habit
  final String? description;

  /// Category of the habit (e.g., Health, Productivity, etc.)
  final String category;

  /// Icon to represent the habit
  final IconData icon;

  /// Color associated with the habit
  final Color color;

  /// Frequency of the habit (e.g., daily, weekly, etc.)
  final HabitFrequency frequency;

  /// Days of the week when the habit should be performed (for weekly habits)
  final List<int>? daysOfWeek;

  /// Time of day when the habit should be performed
  final TimeOfDay? reminderTime;

  /// Whether notifications are enabled for this habit
  final bool notificationsEnabled;

  /// Date when the habit was created
  final DateTime createdAt;

  /// Date when the habit was last modified
  final DateTime updatedAt;

  /// AI-generated suggestions for this habit
  final List<String>? aiSuggestions;

  /// Streak count (number of consecutive completions)
  int streak;

  /// Longest streak achieved
  int longestStreak;

  /// Total number of completions
  int totalCompletions;

  /// Map of completion dates and their status
  final Map<DateTime, bool> completionHistory;

  Habit({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.icon,
    required this.color,
    required this.frequency,
    this.daysOfWeek,
    this.reminderTime,
    this.notificationsEnabled = false,
    required this.createdAt,
    required this.updatedAt,
    this.aiSuggestions,
    this.streak = 0,
    this.longestStreak = 0,
    this.totalCompletions = 0,
    required this.completionHistory,
  });

  /// Creates a copy of this Habit with the given fields replaced with the new values.
  Habit copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    IconData? icon,
    Color? color,
    HabitFrequency? frequency,
    List<int>? daysOfWeek,
    TimeOfDay? reminderTime,
    bool? notificationsEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? aiSuggestions,
    int? streak,
    int? longestStreak,
    int? totalCompletions,
    Map<DateTime, bool>? completionHistory,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      frequency: frequency ?? this.frequency,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      reminderTime: reminderTime ?? this.reminderTime,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      aiSuggestions: aiSuggestions ?? this.aiSuggestions,
      streak: streak ?? this.streak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalCompletions: totalCompletions ?? this.totalCompletions,
      completionHistory: completionHistory ?? this.completionHistory,
    );
  }

  /// Converts the Habit to a Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'icon': icon.codePoint,
      'color': color.value,
      'frequency': frequency.toString(),
      'daysOfWeek': daysOfWeek,
      'reminderTime': reminderTime != null
          ? '${reminderTime!.hour}:${reminderTime!.minute}'
          : null,
      'notificationsEnabled': notificationsEnabled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'aiSuggestions': aiSuggestions,
      'streak': streak,
      'longestStreak': longestStreak,
      'totalCompletions': totalCompletions,
      'completionHistory': completionHistory.map(
        (key, value) => MapEntry(key.toIso8601String(), value),
      ),
    };
  }

  /// Creates a Habit from a Map.
  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      icon: IconData(map['icon'], fontFamily: 'MaterialIcons'),
      color: Color(map['color']),
      frequency: HabitFrequency.values.firstWhere(
        (e) => e.toString() == map['frequency'],
        orElse: () => HabitFrequency.daily,
      ),
      daysOfWeek: map['daysOfWeek'] != null
          ? List<int>.from(map['daysOfWeek'])
          : null,
      reminderTime: map['reminderTime'] != null
          ? TimeOfDay(
              hour: int.parse(map['reminderTime'].split(':')[0]),
              minute: int.parse(map['reminderTime'].split(':')[1]),
            )
          : null,
      notificationsEnabled: map['notificationsEnabled'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      aiSuggestions: map['aiSuggestions'] != null
          ? List<String>.from(map['aiSuggestions'])
          : null,
      streak: map['streak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      totalCompletions: map['totalCompletions'] ?? 0,
      completionHistory: (map['completionHistory'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(DateTime.parse(key), value as bool)),
    );
  }

  /// Marks the habit as completed for the given date.
  void markCompleted(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    completionHistory[dateOnly] = true;
    totalCompletions++;
    _updateStreak();
  }

  /// Marks the habit as not completed for the given date.
  void markNotCompleted(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    completionHistory[dateOnly] = false;
    if (totalCompletions > 0) {
      totalCompletions--;
    }
    _updateStreak();
  }

  /// Updates the streak count based on the completion history.
  /// Private method for internal use.
  void _updateStreak() {
    updateStreak();
  }
  
  /// Updates the streak count based on the completion history.
  /// Public method that can be called from outside the class.
  void updateStreak() {
    int currentStreak = 0;
    DateTime today = DateTime.now();
    DateTime dateToCheck = DateTime(today.year, today.month, today.day);

    // Check backwards from today
    while (completionHistory[dateToCheck] == true) {
      currentStreak++;
      dateToCheck = dateToCheck.subtract(const Duration(days: 1));
    }

    streak = currentStreak;
    if (streak > longestStreak) {
      longestStreak = streak;
    }
  }

  /// Checks if the habit is due today.
  bool isDueToday() {
    final now = DateTime.now();
    final today = now.weekday; // 1 = Monday, 7 = Sunday

    switch (frequency) {
      case HabitFrequency.daily:
        return true;
      case HabitFrequency.weekly:
        return daysOfWeek?.contains(today) ?? false;
      case HabitFrequency.monthly:
        // Due on the same day of the month as when it was created
        return now.day == createdAt.day;
      case HabitFrequency.custom:
        // Custom logic would go here
        return daysOfWeek?.contains(today) ?? false;
    }
  }

  /// Checks if the habit was completed today.
  bool isCompletedToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return completionHistory[today] == true;
  }

  /// Calculates the completion rate as a percentage.
  double getCompletionRate() {
    if (completionHistory.isEmpty) return 0.0;
    
    int completed = completionHistory.values.where((v) => v).length;
    return completed / completionHistory.length;
  }
}

/// Represents the frequency of a habit.
enum HabitFrequency {
  daily,
  weekly,
  monthly,
  custom,
}
