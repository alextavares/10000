import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:habitai/models/habit.dart';
import 'package:habitai/services/habit_service.dart';
import 'package:uuid/uuid.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final habitService = HabitService();
  final userId = 'test_user'; // Replace with a valid user ID

  final habit = Habit(
    id: const Uuid().v4(),
    title: 'Test Habit from Code',
    category: 'Test',
    icon: Icons.code,
    color: Colors.red,
    frequency: HabitFrequency.daily,
    trackingType: HabitTrackingType.simOuNao,
    startDate: DateTime.now(),
    reminderTime: const TimeOfDay(hour: 8, minute: 0),
    notificationsEnabled: true,
    priority: 'Normal',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    userId: userId,
    completionHistory: {},
    dailyProgress: {},
    streak: 0,
    longestStreak: 0,
    totalCompletions: 0,
  );

  await habitService.addHabit(habit);

  print('Habit created successfully!');
}
