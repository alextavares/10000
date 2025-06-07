import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Represents the frequency of a recurring task.
enum RecurringTaskFrequency {
  daily,
  someDaysOfWeek,
  specificDaysOfMonth,
  specificDaysOfYear,
  someTimesPerPeriod,
  repeat,
}

/// Represents the tracking type for a recurring task.
enum RecurringTaskTrackingType {
  simOuNao,           // Yes/No tracking
  listaAtividades,    // List of activities (Premium feature)
}

/// Represents the priority level of a recurring task.
enum RecurringTaskPriority {
  baixa,    // Low
  normal,   // Normal
  alta,     // High
  urgente,  // Urgent
}

/// Represents a subtask for recurring tasks with list tracking type.
class RecurringTaskSubtask {
  final String id;
  final String title;
  final bool isCompleted;

  RecurringTaskSubtask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  RecurringTaskSubtask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return RecurringTaskSubtask(
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

  factory RecurringTaskSubtask.fromMap(Map<String, dynamic> map) {
    return RecurringTaskSubtask(
      id: map['id'],
      title: map['title'],
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}

/// Represents daily progress for a recurring task.
class RecurringTaskDailyProgress {
  final DateTime date;
  final bool isCompleted;
  final List<RecurringTaskSubtask>? subtasks;

  RecurringTaskDailyProgress({
    required this.date,
    this.isCompleted = false,
    this.subtasks,
  });

  RecurringTaskDailyProgress copyWith({
    DateTime? date,
    bool? isCompleted,
    List<RecurringTaskSubtask>? subtasks,
  }) {
    return RecurringTaskDailyProgress(
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      subtasks: subtasks ?? this.subtasks,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'isCompleted': isCompleted,
      'subtasks': subtasks?.map((s) => s.toMap()).toList(),
    };
  }

  factory RecurringTaskDailyProgress.fromMap(Map<String, dynamic> map) {
    return RecurringTaskDailyProgress(
      date: DateTime.parse(map['date']),
      isCompleted: map['isCompleted'] ?? false,
      subtasks: map['subtasks'] != null
          ? (map['subtasks'] as List)
              .map((s) => RecurringTaskSubtask.fromMap(s))
              .toList()
          : null,
    );
  }

  double getCompletionPercentage(RecurringTaskTrackingType trackingType) {
    switch (trackingType) {
      case RecurringTaskTrackingType.simOuNao:
        return isCompleted ? 1.0 : 0.0;
      case RecurringTaskTrackingType.listaAtividades:
        if (subtasks == null || subtasks!.isEmpty) return 0.0;
        int completed = subtasks!.where((s) => s.isCompleted).length;
        return completed / subtasks!.length;
    }
  }
}

class RecurringTask {
  final String id;
  final String title;
  final String? description;
  final String category;
  final RecurringTaskFrequency frequency;
  final List<int>? daysOfWeek;
  final List<int>? daysOfMonth;
  final List<DateTime>? specificYearDates;
  final int? timesPerPeriod;
  final String? periodType;
  final int? repeatEveryDays;
  final TimeOfDay? reminderTime;
  final bool notificationsEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime startDate;
  final DateTime? targetDate;
  final RecurringTaskTrackingType trackingType;
  final List<RecurringTaskSubtask>? subtasks;
  final RecurringTaskPriority priority;
  final Map<DateTime, bool> completionHistory;
  final Map<DateTime, RecurringTaskDailyProgress> dailyProgress;
  int streak;
  int longestStreak;
  int totalCompletions;

  RecurringTask({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.frequency,
    this.daysOfWeek,
    this.daysOfMonth,
    this.specificYearDates,
    this.timesPerPeriod,
    this.periodType,
    this.repeatEveryDays,
    this.reminderTime,
    this.notificationsEnabled = false,
    required this.createdAt,
    required this.updatedAt,
    required this.startDate,
    this.targetDate,
    this.trackingType = RecurringTaskTrackingType.simOuNao,
    this.subtasks,
    this.priority = RecurringTaskPriority.normal,
    required this.completionHistory,
    required this.dailyProgress,
    this.streak = 0,
    this.longestStreak = 0,
    this.totalCompletions = 0,
  });

  RecurringTask copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    RecurringTaskFrequency? frequency,
    List<int>? daysOfWeek,
    List<int>? daysOfMonth,
    List<DateTime>? specificYearDates,
    int? timesPerPeriod,
    String? periodType,
    int? repeatEveryDays,
    TimeOfDay? reminderTime,
    bool? notificationsEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? startDate,
    DateTime? targetDate,
    RecurringTaskTrackingType? trackingType,
    List<RecurringTaskSubtask>? subtasks,
    RecurringTaskPriority? priority,
    Map<DateTime, bool>? completionHistory,
    Map<DateTime, RecurringTaskDailyProgress>? dailyProgress,
    int? streak,
    int? longestStreak,
    int? totalCompletions,
  }) {
    return RecurringTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      daysOfMonth: daysOfMonth ?? this.daysOfMonth,
      specificYearDates: specificYearDates ?? this.specificYearDates,
      timesPerPeriod: timesPerPeriod ?? this.timesPerPeriod,
      periodType: periodType ?? this.periodType,
      repeatEveryDays: repeatEveryDays ?? this.repeatEveryDays,
      reminderTime: reminderTime ?? this.reminderTime,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      trackingType: trackingType ?? this.trackingType,
      subtasks: subtasks ?? this.subtasks,
      priority: priority ?? this.priority,
      completionHistory: completionHistory ?? this.completionHistory,
      dailyProgress: dailyProgress ?? this.dailyProgress,
      streak: streak ?? this.streak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalCompletions: totalCompletions ?? this.totalCompletions,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'frequency': frequency.toString(),
      'daysOfWeek': daysOfWeek,
      'daysOfMonth': daysOfMonth,
      'specificYearDates': specificYearDates?.map((d) => d.toIso8601String()).toList(),
      'timesPerPeriod': timesPerPeriod,
      'periodType': periodType,
      'repeatEveryDays': repeatEveryDays,
      'reminderTime': reminderTime != null
          ? '${reminderTime!.hour}:${reminderTime!.minute}'
          : null,
      'notificationsEnabled': notificationsEnabled,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'startDate': Timestamp.fromDate(startDate),
      'targetDate': targetDate != null ? Timestamp.fromDate(targetDate!) : null,
      'trackingType': trackingType.toString(),
      'subtasks': subtasks?.map((s) => s.toMap()).toList(),
      'priority': priority.toString(),
      'completionHistory': completionHistory.map(
        (key, value) => MapEntry(key.toIso8601String(), value),
      ),
      'dailyProgress': dailyProgress.map(
        (key, value) => MapEntry(key.toIso8601String(), value.toMap()),
      ),
      'streak': streak,
      'longestStreak': longestStreak,
      'totalCompletions': totalCompletions,
    };
  }

  factory RecurringTask.fromMap(Map<String, dynamic> map) {
    // Helper to convert Firestore Timestamp or ISO String to DateTime
    DateTime parseDateTime(dynamic dateValue) {
      if (dateValue is Timestamp) {
        return dateValue.toDate();
      }
      if (dateValue is String) {
        return DateTime.parse(dateValue);
      }
      throw ArgumentError('Invalid date format in RecurringTask.fromMap: $dateValue');
    }

    return RecurringTask(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      category: map['category'] ?? '',
      frequency: RecurringTaskFrequency.values.firstWhere(
        (e) => e.toString() == map['frequency'],
        orElse: () => RecurringTaskFrequency.daily,
      ),
      daysOfWeek: map['daysOfWeek'] != null
          ? List<int>.from(map['daysOfWeek'])
          : null,
      daysOfMonth: map['daysOfMonth'] != null
          ? List<int>.from(map['daysOfMonth'])
          : null,
      specificYearDates: map['specificYearDates'] != null
          ? (map['specificYearDates'] as List)
              .map((d) => DateTime.parse(d))
              .toList()
          : null,
      timesPerPeriod: map['timesPerPeriod'],
      periodType: map['periodType'],
      repeatEveryDays: map['repeatEveryDays'],
      reminderTime: map['reminderTime'] != null
          ? TimeOfDay(
              hour: int.parse(map['reminderTime'].split(':')[0]),
              minute: int.parse(map['reminderTime'].split(':')[1]),
            )
          : null,
      notificationsEnabled: map['notificationsEnabled'] ?? false,
      createdAt: parseDateTime(map['createdAt']),
      updatedAt: parseDateTime(map['updatedAt']),
      startDate: parseDateTime(map['startDate']),
      targetDate: map['targetDate'] != null ? parseDateTime(map['targetDate']) : null,
      trackingType: RecurringTaskTrackingType.values.firstWhere(
        (e) => e.toString() == map['trackingType'],
        orElse: () => RecurringTaskTrackingType.simOuNao,
      ),
      subtasks: map['subtasks'] != null
          ? (map['subtasks'] as List)
              .map((s) => RecurringTaskSubtask.fromMap(s))
              .toList()
          : null,
      priority: RecurringTaskPriority.values.firstWhere(
        (e) => e.toString() == map['priority'],
        orElse: () => RecurringTaskPriority.normal,
      ),
      completionHistory: (map['completionHistory'] as Map<String, dynamic>? ?? {})
          .map((key, value) => MapEntry(DateTime.parse(key), value as bool)),
      dailyProgress: map['dailyProgress'] != null
          ? (map['dailyProgress'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(
                DateTime.parse(key),
                RecurringTaskDailyProgress.fromMap(value)
              ),
            )
          : {},
      streak: map['streak'] ?? 0,
      longestStreak: map['longestStreak'] ?? 0,
      totalCompletions: map['totalCompletions'] ?? 0,
    );
  }

  void markCompleted(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    completionHistory[dateOnly] = true;
    totalCompletions++;
    updateStreak();
  }

  void markNotCompleted(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    completionHistory[dateOnly] = false;
    if (totalCompletions > 0) {
      totalCompletions--;
    }
    updateStreak();
  }

  void recordProgress(DateTime date, {
    bool? isCompleted,
    List<RecurringTaskSubtask>? subtasks,
  }) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final progress = RecurringTaskDailyProgress(
      date: dateOnly,
      isCompleted: isCompleted ?? false,
      subtasks: subtasks,
    );
    dailyProgress[dateOnly] = progress;
    
    bool completed = false;
    switch (trackingType) {
      case RecurringTaskTrackingType.simOuNao:
        completed = isCompleted ?? false;
        break;
      case RecurringTaskTrackingType.listaAtividades:
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

  void updateStreak() {
    int currentStreak = 0;
    DateTime today = DateTime.now();
    DateTime dateToCheck = DateTime(today.year, today.month, today.day);
    
    while (completionHistory[dateToCheck] == true) {
      currentStreak++;
      dateToCheck = dateToCheck.subtract(const Duration(days: 1));
    }
    
    streak = currentStreak;
    if (streak > longestStreak) {
      longestStreak = streak;
    }
  }

  bool isDueToday([DateTime? date]) {
    final checkDate = date ?? DateTime.now();
    final today = DateTime(checkDate.year, checkDate.month, checkDate.day);
    
    switch (frequency) {
      case RecurringTaskFrequency.daily:
        return true;
      case RecurringTaskFrequency.someDaysOfWeek:
        return daysOfWeek?.contains(checkDate.weekday) ?? false;
      case RecurringTaskFrequency.specificDaysOfMonth:
        bool isSelectedDay = daysOfMonth?.contains(checkDate.day) ?? false;
        if (daysOfMonth?.contains(0) ?? false) {
          final lastDayOfMonth = DateTime(checkDate.year, checkDate.month + 1, 0).day;
          if (checkDate.day == lastDayOfMonth) return true;
        }
        return isSelectedDay;
      case RecurringTaskFrequency.specificDaysOfYear:
        return specificYearDates?.any((date) =>
            date.year == today.year &&
            date.month == today.month &&
            date.day == today.day
        ) ?? false;
      case RecurringTaskFrequency.someTimesPerPeriod:
        return true;
      case RecurringTaskFrequency.repeat:
        if (repeatEveryDays != null && repeatEveryDays! > 0) {
          final daysSinceStart = today.difference(DateTime(startDate.year, startDate.month, startDate.day)).inDays;
          return daysSinceStart % repeatEveryDays! == 0;
        }
        return false;
    }
  }

  bool isCompletedToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return completionHistory[today] == true;
  }

  RecurringTaskDailyProgress? getTodaysProgress() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return dailyProgress[today];
  }

  double getCompletionRate() {
    if (completionHistory.isEmpty) return 0.0;
    int completed = completionHistory.values.where((v) => v).length;
    return completed / completionHistory.length;
  }

  double getTodaysCompletionPercentage() {
    final progress = getTodaysProgress();
    if (progress == null) return 0.0;
    return progress.getCompletionPercentage(trackingType);
  }

  String getPriorityDisplayName() {
    switch (priority) {
      case RecurringTaskPriority.baixa:
        return 'Baixa';
      case RecurringTaskPriority.normal:
        return 'Normal';
      case RecurringTaskPriority.alta:
        return 'Alta';
      case RecurringTaskPriority.urgente:
        return 'Urgente';
    }
  }

  Color getPriorityColor() {
    switch (priority) {
      case RecurringTaskPriority.baixa:
        return Colors.green;
      case RecurringTaskPriority.normal:
        return Colors.blue;
      case RecurringTaskPriority.alta:
        return Colors.orange;
      case RecurringTaskPriority.urgente:
        return Colors.red;
    }
  }
}