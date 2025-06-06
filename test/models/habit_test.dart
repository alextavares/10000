import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:myapp/models/habit.dart';

void main() {
  group('Habit Model Tests', () {
    test('Deve criar um hábito com valores padrão', () {
      // Arrange & Act
      final habit = Habit(
        id: 'test-1',
        title: 'Test Habit',
        category: 'Test Category',
        icon: Icons.star,
        color: Colors.blue,
        frequency: HabitFrequency.daily,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        completionHistory: {},
        trackingType: HabitTrackingType.simOuNao,
        dailyProgress: {},
        startDate: DateTime.now(),
      );

      // Assert
      expect(habit.id, 'test-1');
      expect(habit.title, 'Test Habit');
      expect(habit.category, 'Test Category');
      expect(habit.frequency, HabitFrequency.daily);
      expect(habit.streak, 0);
      expect(habit.completionHistory, isEmpty);
    });

    test('Deve converter de/para Map corretamente', () {
      // Arrange
      final originalHabit = Habit(
        id: 'map-test',
        title: 'Map Test Habit',
        description: 'Testing Map conversion',
        category: 'Test',
        icon: Icons.code,
        color: Colors.green,
        frequency: HabitFrequency.weekly,
        daysOfWeek: [1, 3, 5],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
        completionHistory: {
          DateTime(2024, 1, 1): true,
          DateTime(2024, 1, 2): false,
        },
        trackingType: HabitTrackingType.quantia,
        targetQuantity: 8,
        quantityUnit: 'copos',
        dailyProgress: {},
        startDate: DateTime(2024, 1, 1),
        targetDate: DateTime(2024, 12, 31),
        reminderTime: TimeOfDay(hour: 9, minute: 0),
        streak: 1,
        longestStreak: 5,
      );

      // Act
      final map = originalHabit.toMap();
      final decodedHabit = Habit.fromMap(map);

      // Assert
      expect(decodedHabit.id, originalHabit.id);
      expect(decodedHabit.title, originalHabit.title);
      expect(decodedHabit.description, originalHabit.description);
      expect(decodedHabit.category, originalHabit.category);
      expect(decodedHabit.frequency, originalHabit.frequency);
      expect(decodedHabit.daysOfWeek, originalHabit.daysOfWeek);
      expect(decodedHabit.trackingType, originalHabit.trackingType);
      expect(decodedHabit.targetQuantity, originalHabit.targetQuantity);
      expect(decodedHabit.quantityUnit, originalHabit.quantityUnit);
      expect(decodedHabit.streak, originalHabit.streak);
      expect(decodedHabit.longestStreak, originalHabit.longestStreak);
    });

    test('Deve verificar se está completo hoje corretamente', () {
      // Arrange
      final today = DateTime.now();
      final dateKey = DateTime(today.year, today.month, today.day);
      
      final habit = Habit(
        id: 'completion-test',
        title: 'Completion Test',
        category: 'Test',
        icon: Icons.check,
        color: Colors.green,
        frequency: HabitFrequency.daily,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        completionHistory: {
          dateKey: true,
        },
        trackingType: HabitTrackingType.simOuNao,
        dailyProgress: {},
        startDate: DateTime.now(),
      );

      // Act & Assert
      expect(habit.isCompletedToday(), true);
      
      // Modificar para não completo
      habit.completionHistory[dateKey] = false;
      expect(habit.isCompletedToday(), false);
      
      // Remover entrada
      habit.completionHistory.remove(dateKey);
      expect(habit.isCompletedToday(), false);
    });

    test('Deve atualizar streak corretamente', () {
      // Arrange
      final today = DateTime.now();
      final habit = Habit(
        id: 'streak-test',
        title: 'Streak Test',
        category: 'Test',
        icon: Icons.trending_up,
        color: Colors.orange,
        frequency: HabitFrequency.daily,
        createdAt: today.subtract(Duration(days: 10)),
        updatedAt: today,
        completionHistory: {},
        trackingType: HabitTrackingType.simOuNao,
        dailyProgress: {},
        startDate: today.subtract(Duration(days: 10)),
      );

      // Adicionar histórico de conclusão
      for (int i = 0; i < 5; i++) {
        final date = today.subtract(Duration(days: i));
        final dateOnly = DateTime(date.year, date.month, date.day);
        habit.completionHistory[dateOnly] = true;
      }

      // Act
      habit.updateStreak();

      // Assert
      expect(habit.streak, 5);
    });

    test('Deve verificar se é devido hoje para hábitos semanais', () {
      // Arrange
      final currentWeekday = DateTime.now().weekday;
      
      final habitDueToday = Habit(
        id: 'weekly-due',
        title: 'Weekly Due Today',
        category: 'Test',
        icon: Icons.calendar_today,
        color: Colors.purple,
        frequency: HabitFrequency.weekly,
        daysOfWeek: [currentWeekday],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        completionHistory: {},
        trackingType: HabitTrackingType.simOuNao,
        dailyProgress: {},
        startDate: DateTime.now(),
      );

      final habitNotDueToday = Habit(
        id: 'weekly-not-due',
        title: 'Weekly Not Due Today',
        category: 'Test',
        icon: Icons.calendar_today,
        color: Colors.purple,
        frequency: HabitFrequency.weekly,
        daysOfWeek: [(currentWeekday % 7) + 1], // Próximo dia
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        completionHistory: {},
        trackingType: HabitTrackingType.simOuNao,
        dailyProgress: {},
        startDate: DateTime.now(),
      );

      // Act & Assert
      expect(habitDueToday.isDueToday(), true);
      expect(habitNotDueToday.isDueToday(), false);
    });

    test('Deve calcular progresso para hábitos de quantidade', () {
      // Arrange
      final today = DateTime.now();
      final dateKey = DateTime(today.year, today.month, today.day);
      
      final habit = Habit(
        id: 'quantity-test',
        title: 'Water Drinking',
        category: 'Health',
        icon: Icons.local_drink,
        color: Colors.blue,
        frequency: HabitFrequency.daily,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        completionHistory: {},
        trackingType: HabitTrackingType.quantia,
        targetQuantity: 8,
        quantityUnit: 'glasses',
        dailyProgress: {
          dateKey: HabitDailyProgress(
            date: dateKey,
            quantityAchieved: 5,
          ),
        },
        startDate: DateTime.now(),
      );

      // Act
      final progress = habit.getTodaysProgress();
      final percentage = habit.getTodaysCompletionPercentage();

      // Assert
      expect(progress?.quantityAchieved, 5);
      expect(percentage, 0.625); // 5/8 = 0.625
    });

    test('Deve criar cópia com copyWith', () {
      // Arrange
      final original = Habit(
        id: 'original',
        title: 'Original Habit',
        description: 'Original description',
        category: 'Original',
        icon: Icons.star,
        color: Colors.blue,
        frequency: HabitFrequency.daily,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        completionHistory: {},
        trackingType: HabitTrackingType.simOuNao,
        dailyProgress: {},
        startDate: DateTime.now(),
      );

      // Act
      final modified = original.copyWith(
        title: 'Modified Habit',
        color: Colors.red,
        frequency: HabitFrequency.weekly,
      );

      // Assert
      expect(modified.id, original.id);
      expect(modified.title, 'Modified Habit');
      expect(modified.description, original.description);
      expect(modified.color, Colors.red);
      expect(modified.frequency, HabitFrequency.weekly);
      expect(modified.category, original.category);
    });

    test('Deve comparar hábitos corretamente', () {
      // Arrange
      final habit1 = Habit(
        id: 'habit-1',
        title: 'Habit 1',
        category: 'Test',
        icon: Icons.star,
        color: Colors.blue,
        frequency: HabitFrequency.daily,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime.now(),
        completionHistory: {},
        trackingType: HabitTrackingType.simOuNao,
        dailyProgress: {},
        startDate: DateTime.now(),
      );

      final habit2 = Habit(
        id: 'habit-2',
        title: 'Habit 2',
        category: 'Test',
        icon: Icons.star,
        color: Colors.blue,
        frequency: HabitFrequency.daily,
        createdAt: DateTime(2024, 1, 2),
        updatedAt: DateTime.now(),
        completionHistory: {},
        trackingType: HabitTrackingType.simOuNao,
        dailyProgress: {},
        startDate: DateTime.now(),
      );

      // Act & Assert
      // O modelo Habit não implementa == e hashCode customizados,
      // então cada instância é diferente
      expect(habit1 == habit2, false); 
    });
  });
}
