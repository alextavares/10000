import 'package:flutter/material.dart';

/// Represents the frequency of a habit.
enum HabitFrequency {
  daily,
  weekly,
  monthly,
  custom,
}

/// Represents the type of tracking for a habit.
enum HabitTrackingType {
  simOuNao,      // Simple yes/no completion
  quantia,       // Numeric goal (e.g., drink 8 glasses of water)
  cronometro,    // Time-based goal (e.g., meditate for 30 minutes)
  listaAtividades, // List of activities/subtasks (premium feature)
}

/// Represents a subtask for habits with list tracking type.
class HabitSubtask {
  final String id;
  final String title;
  final bool isCompleted;

  HabitSubtask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  HabitSubtask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return HabitSubtask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  factory HabitSubtask.fromMap(Map<String, dynamic> map) {
    return HabitSubtask(
      id: map['id'],
      title: map['title'],
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}

/// Represents daily progress for a habit.
class HabitDailyProgress {
  final DateTime date;
  final bool isCompleted;
  final double? quantityAchieved; // For quantia type
  final Duration? timeSpent;      // For cronometro type
  final List<HabitSubtask>? subtasks; // For listaAtividades type

  HabitDailyProgress({
    required this.date,
    this.isCompleted = false,
    this.quantityAchieved,
    this.timeSpent,
    this.subtasks,
  });

  HabitDailyProgress copyWith({
    DateTime? date,
    bool? isCompleted,
    double? quantityAchieved,
    Duration? timeSpent,
    List<HabitSubtask>? subtasks,
  }) {
    return HabitDailyProgress(
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      quantityAchieved: quantityAchieved ?? this.quantityAchieved,
      timeSpent: timeSpent ?? this.timeSpent,
      subtasks: subtasks ?? this.subtasks,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'isCompleted': isCompleted,
      'quantityAchieved': quantityAchieved,
      'timeSpent': timeSpent?.inSeconds,
      'subtasks': subtasks?.map((s) => s.toMap()).toList(),
    };
  }

  factory HabitDailyProgress.fromMap(Map<String, dynamic> map) {
    return HabitDailyProgress(
      date: DateTime.parse(map['date']),
      isCompleted: map['isCompleted'] ?? false,
      quantityAchieved: map['quantityAchieved']?.toDouble(),
      timeSpent: map['timeSpent'] != null
          ? Duration(seconds: map['timeSpent'])
          : null,
      subtasks: map['subtasks'] != null
          ? (map['subtasks'] as List)
              .map((s) => HabitSubtask.fromMap(s))
              .toList()
          : null,
    );
  }

  /// Calculates completion percentage for this day
  double getCompletionPercentage(HabitTrackingType trackingType, {
    double? targetQuantity,
    Duration? targetTime,
  }) {
    switch (trackingType) {
      case HabitTrackingType.simOuNao:
        return isCompleted ? 1.0 : 0.0;

      case HabitTrackingType.quantia:
        if (targetQuantity == null || quantityAchieved == null) return 0.0;
        return (quantityAchieved! / targetQuantity).clamp(0.0, 1.0);

      case HabitTrackingType.cronometro:
        if (targetTime == null || timeSpent == null) return 0.0;
        return (timeSpent!.inSeconds / targetTime.inSeconds).clamp(0.0, 1.0);

      case HabitTrackingType.listaAtividades:
        if (subtasks == null || subtasks!.isEmpty) return 0.0;
        int completed = subtasks!.where((s) => s.isCompleted).length;
        return completed / subtasks!.length;
    }
  }
}

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

  /// Type of tracking for this habit
  final HabitTrackingType trackingType;

  /// Target quantity for quantia tracking type
  final double? targetQuantity;

  /// Unit for quantity tracking (e.g., "copos", "páginas", "km")
  final String? quantityUnit;

  /// Target time for cronometro tracking type
  final Duration? targetTime;

  /// List of subtasks for listaAtividades tracking type
  final List<HabitSubtask>? subtasks;

  /// Map of daily progress for advanced tracking
  final Map<DateTime, HabitDailyProgress> dailyProgress;

  /// Date when the habit starts
  final DateTime startDate; // Added field

  /// Date when the habit ends (optional)
  final DateTime? targetDate; // Added field

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
    this.trackingType = HabitTrackingType.simOuNao,
    this.targetQuantity,
    this.quantityUnit,
    this.targetTime,
    this.subtasks,
    required this.dailyProgress,
    required this.startDate, // Added to constructor
    this.targetDate,      // Added to constructor
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
    HabitTrackingType? trackingType,
    double? targetQuantity,
    String? quantityUnit,
    Duration? targetTime,
    List<HabitSubtask>? subtasks,
    Map<DateTime, HabitDailyProgress>? dailyProgress,
    DateTime? startDate, // Added to copyWith
    DateTime? targetDate, // Added to copyWith
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
      trackingType: trackingType ?? this.trackingType,
      targetQuantity: targetQuantity ?? this.targetQuantity,
      quantityUnit: quantityUnit ?? this.quantityUnit,
      targetTime: targetTime ?? this.targetTime,
      subtasks: subtasks ?? this.subtasks,
      dailyProgress: dailyProgress ?? this.dailyProgress,
      startDate: startDate ?? this.startDate, // Added to copyWith
      targetDate: targetDate ?? this.targetDate, // Added to copyWith
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
      'trackingType': trackingType.toString(),
      'targetQuantity': targetQuantity,
      'quantityUnit': quantityUnit,
      'targetTime': targetTime?.inSeconds,
      'subtasks': subtasks?.map((s) => s.toMap()).toList(),
      'dailyProgress': dailyProgress.map(
        (key, value) => MapEntry(key.toIso8601String(), value.toMap()),
      ),
      'startDate': startDate.toIso8601String(), // Added to toMap
      'targetDate': targetDate?.toIso8601String(), // Added to toMap
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
      trackingType: HabitTrackingType.values.firstWhere(
        (e) => e.toString() == map['trackingType'],
        orElse: () => HabitTrackingType.simOuNao,
      ),
      targetQuantity: map['targetQuantity']?.toDouble(),
      quantityUnit: map['quantityUnit'],
      targetTime: map['targetTime'] != null
          ? Duration(seconds: map['targetTime'])
          : null,
      subtasks: map['subtasks'] != null
          ? (map['subtasks'] as List)
              .map((s) => HabitSubtask.fromMap(s))
              .toList()
          : null,
      dailyProgress: map['dailyProgress'] != null
          ? (map['dailyProgress'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(
                DateTime.parse(key),
                HabitDailyProgress.fromMap(value)
              ),
            )
          : {},
      startDate: DateTime.parse(map['startDate']), // Added to fromMap
      targetDate: map['targetDate'] != null ? DateTime.parse(map['targetDate']) : null, // Added to fromMap
    );
  }

  /// Marks the habit as completed for the given date.
  void markCompleted(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    completionHistory[dateOnly] = true;
    totalCompletions++;
    updateStreak();
  }

  /// Marks the habit as not completed for the given date.
  void markNotCompleted(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    completionHistory[dateOnly] = false;
    if (totalCompletions > 0) {
      totalCompletions--;
    }
    updateStreak();
  }

  /// Records progress for advanced tracking types
  void recordProgress(DateTime date, {
    bool? isCompleted,
    double? quantityAchieved,
    Duration? timeSpent,
    List<HabitSubtask>? subtasks,
  }) {
    final dateOnly = DateTime(date.year, date.month, date.day);

    final progress = HabitDailyProgress(
      date: dateOnly,
      isCompleted: isCompleted ?? false,
      quantityAchieved: quantityAchieved,
      timeSpent: timeSpent,
      subtasks: subtasks,
    );

    dailyProgress[dateOnly] = progress;

    // Update completion history based on tracking type
    bool completed = false;
    switch (trackingType) {
      case HabitTrackingType.simOuNao:
        completed = isCompleted ?? false;
        break;
      case HabitTrackingType.quantia:
        completed = targetQuantity != null &&
                   quantityAchieved != null &&
                   quantityAchieved >= targetQuantity!;
        break;
      case HabitTrackingType.cronometro:
        completed = targetTime != null &&
                   timeSpent != null &&
                   timeSpent >= targetTime!;
        break;
      case HabitTrackingType.listaAtividades:
        if (subtasks != null && subtasks.isNotEmpty) {
          completed = subtasks.every((s) => s.isCompleted);
        }
        break;
    }

    if (completed) {
      markCompleted(date);
    } else {
      markNotCompleted(date);
    }
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

  /// Gets today's progress for advanced tracking
  HabitDailyProgress? getTodaysProgress() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return dailyProgress[today];
  }

  /// Calculates the completion rate as a percentage.
  double getCompletionRate() {
    if (completionHistory.isEmpty) return 0.0;

    int completed = completionHistory.values.where((v) => v).length;
    return completed / completionHistory.length;
  }

  /// Gets completion percentage for today based on tracking type
  double getTodaysCompletionPercentage() {
    final progress = getTodaysProgress();
    if (progress == null) return 0.0;

    return progress.getCompletionPercentage(
      trackingType,
      targetQuantity: targetQuantity,
      targetTime: targetTime,
    );
  }
}
