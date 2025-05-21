import 'package:flutter/material.dart'; // For IconData, Color
import 'package:flutter_test/flutter_test.dart'; // Import flutter_test for 'test' and 'expect'
import 'package:myapp/models/habit.dart';

// --- Mock Habit Service (Copied from previous step, no changes needed here) ---
class MockHabitService {
  final List<Habit> _habits = [];
  int _nextId = 1;

  Future<List<Habit>> getHabits() async {
    await Future.delayed(Duration.zero); 
    return List.from(_habits);
  }

  Future<Habit?> getHabit(String habitId) async {
    await Future.delayed(Duration.zero);
    try {
      return _habits.firstWhere((h) => h.id == habitId);
    } catch (e) {
      return null;
    }
  }

  Future<String?> addHabit(Habit habit) async {
    await Future.delayed(Duration.zero);
    // In a real scenario, Firestore generates the ID. Here, we simulate it.
    final newHabitWithId = habit.copyWith(id: _nextId.toString(), updatedAt: DateTime.now(), createdAt: habit.createdAt ?? DateTime.now());
    _nextId++;
    _habits.add(newHabitWithId);
    return newHabitWithId.id;
  }

  Future<bool> updateHabit(Habit habit) async {
    await Future.delayed(Duration.zero);
    int index = _habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      _habits[index] = habit.copyWith(updatedAt: DateTime.now());
      return true;
    }
    return false;
  }

  Future<bool> deleteHabit(String habitId) async {
    await Future.delayed(Duration.zero);
    int initialLength = _habits.length;
    _habits.removeWhere((h) => h.id == habitId);
    return _habits.length < initialLength;
  }

  Future<bool> markHabitCompleted(String habitId, DateTime date) async {
    Habit? habit = await getHabit(habitId);
    if (habit == null) return false;

    final dateOnly = DateTime(date.year, date.month, date.day);
    final updatedCompletionHistory = Map<DateTime, bool>.from(habit.completionHistory);
    bool wasAlreadyCompleted = updatedCompletionHistory[dateOnly] == true;
    updatedCompletionHistory[dateOnly] = true;
    
    int newTotalCompletions = habit.totalCompletions;
    if (!wasAlreadyCompleted) {
        newTotalCompletions = habit.totalCompletions + 1;
    }

    final updatedHabit = habit.copyWith(
      completionHistory: updatedCompletionHistory,
      totalCompletions: newTotalCompletions,
    );
    // Simulate that updateStreak would be called based on DateTime.now() context for "today"
    // For the mock, the direct update of completionHistory is what matters.
    // updatedHabit.updateStreak(); 
    return await updateHabit(updatedHabit);
  }

  Future<bool> markHabitNotCompleted(String habitId, DateTime date) async {
    Habit? habit = await getHabit(habitId);
    if (habit == null) return false;

    final dateOnly = DateTime(date.year, date.month, date.day);
    final updatedCompletionHistory = Map<DateTime, bool>.from(habit.completionHistory);
    bool wasCompleted = updatedCompletionHistory[dateOnly] == true;
    updatedCompletionHistory[dateOnly] = false;

    int newTotalCompletions = habit.totalCompletions;
    if (wasCompleted) { 
        newTotalCompletions = habit.totalCompletions > 0 ? habit.totalCompletions - 1 : 0;
    }
    
    final updatedHabit = habit.copyWith(
      completionHistory: updatedCompletionHistory,
      totalCompletions: newTotalCompletions,
    );
    // updatedHabit.updateStreak();
    return await updateHabit(updatedHabit);
  }

  void clearAllHabits() {
    _habits.clear();
    _nextId = 1;
    // print("MockHabitService: All habits cleared."); // Optional: keep for debugging if needed
  }
}

// --- Test Configuration ---
final today = DateTime(2024, 7, 24); // Wednesday
final tomorrow = DateTime(2024, 7, 25); // Thursday
final yesterday = DateTime(2024, 7, 23); // Tuesday

final testMonday = DateTime(2024, 7, 22);
final testTuesday = DateTime(2024, 7, 23); 
final testWednesday = DateTime(2024, 7, 24); 
final testFriday = DateTime(2024, 7, 26);

const String dailyHabitName = "Test Daily Habit - Drink Water";
const String weeklyHabitName = "Test Weekly Habit - Exercise";

// Helper function (no changes needed)
Future<List<Habit>> fetchHabitsForDate(MockHabitService service, DateTime selectedDate) async {
  final allHabits = await service.getHabits();
  final selectedDateOnly = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

  return allHabits.where((habit) {
    if (habit.frequency == HabitFrequency.daily) {
      return true;
    } else if (habit.frequency == HabitFrequency.weekly) {
      return habit.daysOfWeek?.contains(selectedDateOnly.weekday) ?? false;
    } else if (habit.frequency == HabitFrequency.monthly) {
      return habit.createdAt.day == selectedDateOnly.day;
    }
    return false;
  }).toList();
}

void main() {
  late MockHabitService habitService;
  String? dailyHabitId;
  String? weeklyHabitId;

  setUp(() {
    habitService = MockHabitService();
    dailyHabitId = null;
    weeklyHabitId = null;
    // print("\n--- Test Group Setup ---"); // Optional for debugging
  });

  group('Habit Functionality Tests', () {
    test('Test Case 1: Add Daily Habit and Verify Visibility', () async {
      final newDailyHabit = Habit(
        id: '', 
        title: dailyHabitName,
        category: "Health",
        icon: Icons.local_drink, 
        color: Colors.blue, 
        frequency: HabitFrequency.daily,
        createdAt: today, 
        updatedAt: today,
        completionHistory: {},
      );
      dailyHabitId = await habitService.addHabit(newDailyHabit);
      expect(dailyHabitId, isNotNull, reason: "Failed to add daily habit.");

      List<Habit> habitsForToday = await fetchHabitsForDate(habitService, today);
      expect(habitsForToday.any((h) => h.id == dailyHabitId), isTrue, reason: "$dailyHabitName should appear for today.");

      List<Habit> habitsForTomorrow = await fetchHabitsForDate(habitService, tomorrow);
      expect(habitsForTomorrow.any((h) => h.id == dailyHabitId), isTrue, reason: "$dailyHabitName should appear for tomorrow.");

      List<Habit> habitsForYesterday = await fetchHabitsForDate(habitService, yesterday);
      expect(habitsForYesterday.any((h) => h.id == dailyHabitId), isTrue, reason: "$dailyHabitName should appear for yesterday.");
    });

    test('Test Case 2: Add Weekly Habit and Verify Visibility', () async {
      final newWeeklyHabit = Habit(
        id: '', 
        title: weeklyHabitName,
        category: "Fitness",
        icon: Icons.fitness_center, 
        color: Colors.green, 
        frequency: HabitFrequency.weekly,
        daysOfWeek: [DateTime.monday, DateTime.wednesday, DateTime.friday],
        createdAt: today,
        updatedAt: today,
        completionHistory: {},
      );
      weeklyHabitId = await habitService.addHabit(newWeeklyHabit);
      expect(weeklyHabitId, isNotNull, reason: "Failed to add weekly habit.");

      List<Habit> habitsForMonday = await fetchHabitsForDate(habitService, testMonday);
      expect(habitsForMonday.any((h) => h.id == weeklyHabitId), isTrue, reason: "$weeklyHabitName should appear for Monday.");

      List<Habit> habitsForTuesday = await fetchHabitsForDate(habitService, testTuesday);
      expect(habitsForTuesday.any((h) => h.id == weeklyHabitId), isFalse, reason: "$weeklyHabitName should NOT appear for Tuesday.");
      
      List<Habit> habitsForWednesday = await fetchHabitsForDate(habitService, testWednesday);
      expect(habitsForWednesday.any((h) => h.id == weeklyHabitId), isTrue, reason: "$weeklyHabitName should appear for Wednesday.");
    });

    test('Test Case 3: Mark Daily Habit Complete/Incomplete', () async {
      // First, add the daily habit
      final newDailyHabit = Habit(id: '', title: dailyHabitName, category: "Health", icon: Icons.local_drink, color: Colors.blue, frequency: HabitFrequency.daily, createdAt: today, updatedAt: today, completionHistory: {});
      dailyHabitId = await habitService.addHabit(newDailyHabit);
      expect(dailyHabitId, isNotNull);

      // Mark complete for today
      bool markedComplete = await habitService.markHabitCompleted(dailyHabitId!, today);
      expect(markedComplete, isTrue, reason: "Failed to mark habit complete.");
      Habit? updatedHabit = await habitService.getHabit(dailyHabitId!);
      expect(updatedHabit?.completionHistory[DateTime(today.year, today.month, today.day)], isTrue, reason: "Habit should be completed in DB for today.");

      // Mark incomplete for today
      bool markedIncomplete = await habitService.markHabitNotCompleted(dailyHabitId!, today);
      expect(markedIncomplete, isTrue, reason: "Failed to mark habit incomplete.");
      updatedHabit = await habitService.getHabit(dailyHabitId!);
      expect(updatedHabit?.completionHistory[DateTime(today.year, today.month, today.day)], isFalse, reason: "Habit should be incomplete in DB for today.");
    });

    test('Test Case 4: Check Daily Habit Completion Across Different Dates', () async {
      // First, add the daily habit
      final newDailyHabit = Habit(id: '', title: dailyHabitName, category: "Health", icon: Icons.local_drink, color: Colors.blue, frequency: HabitFrequency.daily, createdAt: today, updatedAt: today, completionHistory: {});
      dailyHabitId = await habitService.addHabit(newDailyHabit);
      expect(dailyHabitId, isNotNull);

      // Mark complete for today
      await habitService.markHabitCompleted(dailyHabitId!, today);
      Habit? habitTodayView = await habitService.getHabit(dailyHabitId!);
      expect(habitTodayView?.completionHistory[DateTime(today.year, today.month, today.day)], isTrue, reason: "Habit should be complete for today.");

      // Check status for tomorrow
      List<Habit> habitsTomorrowList = await fetchHabitsForDate(habitService, tomorrow);
      Habit? dailyHabitTomorrowInstance = habitsTomorrowList.firstWhere((h) => h.id == dailyHabitId!, orElse: () => newDailyHabit.copyWith(id: "error")); // provide a default non-null
      
      expect(dailyHabitTomorrowInstance.id, dailyHabitId, reason: "$dailyHabitName should be visible for tomorrow.");
      expect(dailyHabitTomorrowInstance.completionHistory[DateTime(tomorrow.year, tomorrow.month, tomorrow.day)], isNot(true), reason: "$dailyHabitName should be incomplete for tomorrow by default.");
    });
  });
}
