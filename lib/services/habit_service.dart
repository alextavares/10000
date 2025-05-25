import 'package:flutter/material.dart';
import 'package:myapp/models/habit.dart'; 
import 'package:uuid/uuid.dart';

class HabitService extends ChangeNotifier {
  final List<Habit> _habits = [];
  final _uuid = const Uuid();

  Future<List<Habit>> getHabits() async {
    return List<Habit>.from(_habits);
  }

  Future<void> addHabit({
    required String title,
    required String categoryName,
    required IconData categoryIcon,
    required Color categoryColor,
    required HabitFrequency frequency, 
    required HabitTrackingType trackingType, 
    required DateTime startDate, 
    List<int>? daysOfWeek,
    List<int>? daysOfMonth, // Added daysOfMonth
    List<DateTime>? specificYearDates, // Added specificYearDates
    int? timesPerPeriod,
    String? periodType,
    int? repeatEveryDays,
    bool? isFlexible,
    bool? alternateDays,
    DateTime? targetDate,
    TimeOfDay? reminderTime,
    bool notificationsEnabled = false,
    String priority = 'Normal', 
    String? description,
  }) async {
    final newHabit = Habit(
      id: _uuid.v4(),
      title: title,
      description: description,
      category: categoryName,
      icon: categoryIcon,
      color: categoryColor,
      frequency: frequency, 
      trackingType: trackingType, 
      daysOfWeek: daysOfWeek,
      // Pass daysOfMonth to Habit constructor (ensure Habit model is updated)
      daysOfMonth: daysOfMonth,
      specificYearDates: specificYearDates, // Pass specificYearDates to Habit constructor
      timesPerPeriod: timesPerPeriod,
      periodType: periodType,
      repeatEveryDays: repeatEveryDays,
      isFlexible: isFlexible,
      alternateDays: alternateDays,
      reminderTime: reminderTime,
      notificationsEnabled: notificationsEnabled,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      streak: 0,
      longestStreak: 0,
      totalCompletions: 0,
      completionHistory: {},
      dailyProgress: {}, 
      startDate: startDate, 
      targetDate: targetDate, 
    );

    _habits.add(newHabit);
    notifyListeners(); // Notifica as telas que escutam mudanças
    debugPrint('Habit added: ${newHabit.title}, ID: ${newHabit.id}, Tracking: ${newHabit.trackingType}, Freq: ${newHabit.frequency}');
    if (daysOfMonth != null) {
      debugPrint('Days of Month: ${daysOfMonth.join(', ')}');
    }
    if (specificYearDates != null) {
      debugPrint('Specific Year Dates: ${specificYearDates.map((d) => d.toIso8601String()).join(', ')}');
    }
    debugPrint('Total habits: ${_habits.length}');
  }

  Future<Habit?> getHabitById(String id) async {
    try {
      return _habits.firstWhere((habit) => habit.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateHabit(Habit habitToUpdate) async {
    final index = _habits.indexWhere((h) => h.id == habitToUpdate.id);
    if (index != -1) {
      _habits[index] = habitToUpdate.copyWith(updatedAt: DateTime.now());
      debugPrint('Habit updated: ${habitToUpdate.title}');
    } else {
      debugPrint('Habit with id ${habitToUpdate.id} not found for update.');
    }
  }

  Future<void> deleteHabit(String id) async {
    final initialLength = _habits.length;
    _habits.removeWhere((habit) => habit.id == id);
    if (_habits.length < initialLength) {
      debugPrint('Habit deleted: $id');
    } else {
      debugPrint('Habit with id $id not found for deletion.');
    }
  }

  Future<void> markHabitCompletion(String habitId, DateTime date, bool completed) async {
    final habit = await getHabitById(habitId);
    if (habit != null) {
      habit.recordProgress(date, isCompleted: completed); 
      debugPrint('Habit $habitId completion for $date marked as $completed');
    } else {
       debugPrint('Habit $habitId not found for marking completion.');
    }
  }
}
