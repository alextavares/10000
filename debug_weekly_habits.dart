import 'package:flutter/material.dart';
import 'lib/models/habit.dart';
import 'lib/services/habit_service.dart';

void main() async {
  // Test creating a weekly habit
  final habitService = HabitService();
  
  print('=== Testing Weekly Habit Creation ===');
  
  // Create a habit for Monday, Wednesday, Friday (1, 3, 5)
  await habitService.addHabit(
    title: 'Test Weekly Habit',
    categoryName: 'Test',
    categoryIcon: Icons.star,
    categoryColor: Colors.blue,
    frequency: HabitFrequency.weekly,
    trackingType: HabitTrackingType.simOuNao,
    startDate: DateTime.now(),
    daysOfWeek: [1, 3, 5], // Monday, Wednesday, Friday
  );
  
  final habits = await habitService.getHabits();
  print('Created habits: ${habits.length}');
  
  if (habits.isNotEmpty) {
    final habit = habits.first;
    print('Habit: ${habit.title}');
    print('Frequency: ${habit.frequency}');
    print('DaysOfWeek: ${habit.daysOfWeek}');
    
    // Test different weekdays
    for (int weekday = 1; weekday <= 7; weekday++) {
      final testDate = DateTime(2025, 5, 26 + weekday - 1); // Start from Monday
      final isDue = habit.isDueToday(testDate);
      print('Weekday $weekday (${_getWeekdayName(weekday)}): $isDue');
    }
  }
}

String _getWeekdayName(int weekday) {
  switch (weekday) {
    case 1: return 'Monday';
    case 2: return 'Tuesday';
    case 3: return 'Wednesday';
    case 4: return 'Thursday';
    case 5: return 'Friday';
    case 6: return 'Saturday';
    case 7: return 'Sunday';
    default: return 'Unknown';
  }
}
