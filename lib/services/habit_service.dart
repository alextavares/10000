import 'package:flutter/material.dart';
import 'package:myapp/models/habit.dart' as habit_model; // Use alias for the entire model file
import 'package:myapp/screens/habit/add_habit_frequency_screen.dart' show AddHabitCycle;
import 'package:uuid/uuid.dart';

class HabitService {
  final List<habit_model.Habit> _habits = [];
  final _uuid = const Uuid();

  Future<List<habit_model.Habit>> getHabits() async {
    return List<habit_model.Habit>.from(_habits);
  }

  Future<void> addHabit({
    required String title,
    required String categoryName,
    required IconData categoryIcon,
    required Color categoryColor,
    required AddHabitCycle frequencyEnumFromScreen, 
    required DateTime startDate,
    List<int>? daysOfWeek, 
    DateTime? targetDate,
    TimeOfDay? reminderTime,
    bool notificationsEnabled = false,
    String priority = 'Normal',
    String? description,
  }) async {
    habit_model.HabitFrequency modelFrequency;
    List<int>? effectiveDaysOfWeek = daysOfWeek;

    switch (frequencyEnumFromScreen) {
      case AddHabitCycle.daily:
        modelFrequency = habit_model.HabitFrequency.daily;
        break;
      case AddHabitCycle.specificWeekDays:
        modelFrequency = habit_model.HabitFrequency.weekly;
        break;
      case AddHabitCycle.specificMonthDays:
        modelFrequency = habit_model.HabitFrequency.monthly;
        break;
      case AddHabitCycle.specificYearDays:
      case AddHabitCycle.sometimesPerPeriod:
      case AddHabitCycle.repeat:
      default:
        modelFrequency = habit_model.HabitFrequency.custom;
        break;
    }

    final newHabit = habit_model.Habit(
      id: _uuid.v4(),
      title: title,
      description: description,
      category: categoryName,
      icon: categoryIcon,
      color: categoryColor,
      frequency: modelFrequency,
      daysOfWeek: effectiveDaysOfWeek,
      reminderTime: reminderTime,
      notificationsEnabled: notificationsEnabled,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      streak: 0,
      longestStreak: 0,
      totalCompletions: 0,
      completionHistory: {},
    );

    _habits.add(newHabit);
    debugPrint('Habit added: ${newHabit.title}, ID: ${newHabit.id}');
    debugPrint('Total habits: ${_habits.length}');
  }

  Future<habit_model.Habit?> getHabitById(String id) async {
    try {
      return _habits.firstWhere((habit) => habit.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateHabit(habit_model.Habit habitToUpdate) async {
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
      if (completed) {
        habit.markCompleted(date);
      } else {
        habit.markNotCompleted(date);
      }
      await updateHabit(habit);
      debugPrint('Habit $habitId completion for $date marked as $completed');
    }
  }
}
