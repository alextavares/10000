import 'package:flutter/material.dart';

/// Represents the frequency of a habit.
enum HabitFrequency {
  daily,
  weekly,
  monthly,
  specificDaysOfYear,
  someTimesPerPeriod, // Nova opção: algumas vezes por período
  repeat, // Nova opção: repetir
  custom,
}

/// Represents the type of tracking for a habit.
enum HabitTrackingType {
  simOuNao,      
  quantia,       
  cronometro,    
  listaAtividades, 
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
  final double? quantityAchieved; 
  final Duration? timeSpent;      
  final List<HabitSubtask>? subtasks; 

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

class Habit {
  final String id;
  final String title;
  final String? description;
  final String category;
  final IconData icon;
  final Color color;
  final HabitFrequency frequency;
  final List<int>? daysOfWeek;
  final List<int>? daysOfMonth; // Added daysOfMonth field
  final List<DateTime>? specificYearDates;
  final int? timesPerPeriod; // Quantas vezes por período (ex: 3 vezes)
  final String? periodType; // Tipo do período (SEMANA, MÊS, ANO)
  final int? repeatEveryDays; // A cada X dias (para opção "Repetir")
  final bool? isFlexible; // Flexível - será exibida todos os dias até ser concluída
  final bool? alternateDays; // Alternar dias
  final TimeOfDay? reminderTime;
  final bool notificationsEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String>? aiSuggestions;
  int streak;
  int longestStreak;
  int totalCompletions;
  final Map<DateTime, bool> completionHistory;
  final HabitTrackingType trackingType;
  final double? targetQuantity;
  final String? quantityUnit;
  final Duration? targetTime;
  final List<HabitSubtask>? subtasks;
  final Map<DateTime, HabitDailyProgress> dailyProgress;
  final DateTime startDate;
  final DateTime? targetDate;

  Habit({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.icon,
    required this.color,
    required this.frequency,
    this.daysOfWeek,
    this.daysOfMonth, // Added to constructor
    this.specificYearDates,
    this.timesPerPeriod,
    this.periodType,
    this.repeatEveryDays,
    this.isFlexible,
    this.alternateDays,
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
    required this.startDate,
    this.targetDate,
  });

  Habit copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    IconData? icon,
    Color? color,
    HabitFrequency? frequency,
    List<int>? daysOfWeek,
    List<int>? daysOfMonth, // Added to copyWith
    List<DateTime>? specificYearDates,
    int? timesPerPeriod,
    String? periodType,
    int? repeatEveryDays,
    bool? isFlexible,
    bool? alternateDays,
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
    DateTime? startDate,
    DateTime? targetDate,
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
      daysOfMonth: daysOfMonth ?? this.daysOfMonth, // Added to copyWith logic
      specificYearDates: specificYearDates ?? this.specificYearDates,
      timesPerPeriod: timesPerPeriod ?? this.timesPerPeriod,
      periodType: periodType ?? this.periodType,
      repeatEveryDays: repeatEveryDays ?? this.repeatEveryDays,
      isFlexible: isFlexible ?? this.isFlexible,
      alternateDays: alternateDays ?? this.alternateDays,
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
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
    );
  }

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
      'daysOfMonth': daysOfMonth, // Added to toMap
      'specificYearDates': specificYearDates?.map((d) => d.toIso8601String()).toList(),
      'timesPerPeriod': timesPerPeriod,
      'periodType': periodType,
      'repeatEveryDays': repeatEveryDays,
      'isFlexible': isFlexible,
      'alternateDays': alternateDays,
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
      'startDate': startDate.toIso8601String(),
      'targetDate': targetDate?.toIso8601String(),
    };
  }

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
      daysOfMonth: map['daysOfMonth'] != null
          ? List<int>.from(map['daysOfMonth'])
          : null, // Added to fromMap
      specificYearDates: map['specificYearDates'] != null
          ? (map['specificYearDates'] as List)
              .map((d) => DateTime.parse(d))
              .toList()
          : null,
      timesPerPeriod: map['timesPerPeriod'],
      periodType: map['periodType'],
      repeatEveryDays: map['repeatEveryDays'],
      isFlexible: map['isFlexible'],
      alternateDays: map['alternateDays'],
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
      startDate: DateTime.parse(map['startDate']),
      targetDate: map['targetDate'] != null ? DateTime.parse(map['targetDate']) : null,
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
      case HabitFrequency.daily:
        return true;
      case HabitFrequency.weekly:
        final result = daysOfWeek?.contains(checkDate.weekday) ?? false;
        print('Weekly habit check: $title, today=${checkDate.weekday}, daysOfWeek=$daysOfWeek, result=$result');
        return result;
      case HabitFrequency.monthly:
        // Check if today is one of the selected days of the month
        // Or if it's the last day of the month and 0 was selected.
        bool isSelectedDay = daysOfMonth?.contains(checkDate.day) ?? false;
        // A more robust way for last day:
        if (daysOfMonth?.contains(0) ?? false) {
          final lastDayOfMonth = DateTime(checkDate.year, checkDate.month + 1, 0).day;
          if (checkDate.day == lastDayOfMonth) return true;
        }
        return isSelectedDay;
      case HabitFrequency.specificDaysOfYear:
        return specificYearDates?.any((date) =>
            date.year == today.year &&
            date.month == today.month &&
            date.day == today.day
        ) ?? false;
      case HabitFrequency.someTimesPerPeriod:
        // Para "algumas vezes por período", sempre retorna true
        // A lógica de controle será feita nas telas baseada no progresso
        return true;
      case HabitFrequency.repeat:
        // Para "repetir", implementar lógica baseada nas configurações
        if (isFlexible == true) {
          // Se é flexível, sempre mostra até ser concluído
          return true;
        }
        if (repeatEveryDays != null && repeatEveryDays! > 0) {
          // A cada X dias
          final daysSinceStart = today.difference(DateTime(startDate.year, startDate.month, startDate.day)).inDays;
          return daysSinceStart % repeatEveryDays! == 0;
        }
        if (alternateDays == true) {
          // Alternar dias (dia sim, dia não)
          final daysSinceStart = today.difference(DateTime(startDate.year, startDate.month, startDate.day)).inDays;
          return daysSinceStart % 2 == 0;
        }
        return false;
      case HabitFrequency.custom:
        return false;
    }
  }

  // Helper function to check for leap year (for February)
  bool isLeapYear(int year) => (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);

  // Helper function to get days in month (simplified)
  int daysInMonth(int year, int month) {
    if (month == DateTime.february) {
      return isLeapYear(year) ? 29 : 28;
    }
    const days = <int>[0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return days[month];
  }

  bool isCompletedToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return completionHistory[today] == true;
  }

  HabitDailyProgress? getTodaysProgress() {
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
    return progress.getCompletionPercentage(
      trackingType,
      targetQuantity: targetQuantity,
      targetTime: targetTime,
    );
  }
}
