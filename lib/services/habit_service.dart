import 'package:flutter/material.dart';
import 'package:myapp/models/habit.dart'; // Use alias for the entire model file if still needed, else direct
import 'package:uuid/uuid.dart';

class HabitService {
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
    required HabitFrequency frequency, // Changed from AddHabitCycle to HabitFrequency
    required HabitTrackingType trackingType, // Added trackingType
    required DateTime startDate, // Should be passed from AddHabitScheduleScreen
    List<int>? daysOfWeek, 
    DateTime? targetDate,
    TimeOfDay? reminderTime,
    bool notificationsEnabled = false,
    String priority = 'Normal', // Priority can be added later if needed
    String? description,
  }) async {
    // The 'frequency' parameter is now directly HabitFrequency, so no switch case needed here for conversion.
    // It's assumed that if it's weekly, daysOfWeek will be provided.
    // If it's custom, specific configuration for custom frequency might be needed elsewhere or passed.

    final newHabit = Habit(
      id: _uuid.v4(),
      title: title,
      description: description,
      category: categoryName,
      icon: categoryIcon,
      color: categoryColor,
      frequency: frequency, // Use the passed frequency directly
      trackingType: trackingType, // Use the passed trackingType
      daysOfWeek: daysOfWeek,
      reminderTime: reminderTime,
      notificationsEnabled: notificationsEnabled,
      createdAt: DateTime.now(), // Changed to DateTime.now()
      updatedAt: DateTime.now(),
      streak: 0,
      longestStreak: 0,
      totalCompletions: 0,
      completionHistory: {},
      dailyProgress: {}, 
      startDate: startDate, // Added startDate
      targetDate: targetDate, // Added targetDate
      // targetQuantity, quantityUnit, targetTime, subtasks would be set based on trackingType
      // For simOuNao, these are not applicable initially.
    );

    _habits.add(newHabit);
    debugPrint('Habit added: ${newHabit.title}, ID: ${newHabit.id}, Tracking: ${newHabit.trackingType}');
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
      // Ensure the habit model's markCompleted/NotCompleted handles dailyProgress for simOuNao if needed
      // Or, update dailyProgress here.
      habit.recordProgress(date, isCompleted: completed); // Use recordProgress for unified update
      // No need to call updateHabit separately if recordProgress modifies the habit and HabitService uses references
      // or if getHabitById returns a copy, then updateHabit(habit) would be needed.
      // Assuming _habits list holds references, direct modification via habit.recordProgress is enough before a UI update.
      debugPrint('Habit $habitId completion for $date marked as $completed');
    } else {
       debugPrint('Habit $habitId not found for marking completion.');
    }
  }
}
