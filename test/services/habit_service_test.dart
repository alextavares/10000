import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/services/habit_service.dart';
import 'package:flutter/material.dart';

void main() {
  group('HabitService Tests', () {
    late HabitService habitService;
    
    setUp(() {
      habitService = HabitService();
    });

    test('Deve adicionar um novo hábito com sucesso', () async {
      // Act
      await habitService.addHabit(
        title: 'Beber água',
        description: 'Beber 2L de água por dia',
        categoryName: 'Saúde',
        categoryIcon: Icons.local_drink,
        categoryColor: Colors.blue,
        frequency: HabitFrequency.daily,
        trackingType: HabitTrackingType.simOuNao,
        startDate: DateTime.now(),
      );
      
      // Assert
      final habits = await habitService.getHabits();
      expect(habits.length, 1);
      expect(habits.first.title, 'Beber água');
      expect(habits.first.category, 'Saúde');
    });

    test('Deve remover um hábito existente', () async {
      // Arrange - Adicionar um hábito primeiro
      await habitService.addHabit(
        title: 'Exercício',
        description: '30 minutos de exercício',
        categoryName: 'Fitness',
        categoryIcon: Icons.fitness_center,
        categoryColor: Colors.orange,
        frequency: HabitFrequency.daily,
        trackingType: HabitTrackingType.simOuNao,
        startDate: DateTime.now(),
      );
      
      // Verificar que foi adicionado
      var habits = await habitService.getHabits();
      expect(habits.length, 1);
      final habitId = habits.first.id;
      
      // Act - Remover o hábito
      await habitService.deleteHabit(habitId);
      
      // Assert
      habits = await habitService.getHabits();
      expect(habits.length, 0);
    });

    test('Deve atualizar um hábito existente', () async {
      // Arrange
      await habitService.addHabit(
        title: 'Leitura',
        description: 'Ler 30 minutos',
        categoryName: 'Educação',
        categoryIcon: Icons.book,
        categoryColor: Colors.green,
        frequency: HabitFrequency.daily,
        trackingType: HabitTrackingType.simOuNao,
        startDate: DateTime.now(),
      );
      
      var habits = await habitService.getHabits();
      final originalHabit = habits.first;
      
      // Act - Atualizar o hábito
      final updatedHabit = originalHabit.copyWith(
        title: 'Leitura Diária',
        description: 'Ler 1 hora por dia',
      );
      
      await habitService.updateHabit(updatedHabit);
      
      // Assert
      habits = await habitService.getHabits();
      expect(habits.first.title, 'Leitura Diária');
      expect(habits.first.description, 'Ler 1 hora por dia');
    });

    test('Deve marcar hábito como completo', () async {
      // Arrange
      await habitService.addHabit(
        title: 'Meditação',
        description: '10 minutos de meditação',
        categoryName: 'Bem-estar',
        categoryIcon: Icons.self_improvement,
        categoryColor: Colors.purple,
        frequency: HabitFrequency.daily,
        trackingType: HabitTrackingType.simOuNao,
        startDate: DateTime.now(),
      );
      
      var habits = await habitService.getHabits();
      final habitId = habits.first.id;
      
      // Act
      final today = DateTime.now();
      await habitService.markHabitCompletion(habitId, today, true);
      
      // Assert
      habits = await habitService.getHabits();
      expect(habits.first.isCompletedToday(), true);
    });

    test('Deve listar apenas hábitos do dia correto (semanal)', () async {
      // Arrange
      final weekday = DateTime.now().weekday;
      await habitService.addHabit(
        title: 'Academia',
        description: 'Ir à academia',
        categoryName: 'Fitness',
        categoryIcon: Icons.sports_gymnastics,
        categoryColor: Colors.red,
        frequency: HabitFrequency.weekly,
        daysOfWeek: [weekday],
        trackingType: HabitTrackingType.simOuNao,
        startDate: DateTime.now(),
      );
      
      // Act & Assert
      final habits = await habitService.getHabits();
      expect(habits.length, 1);
      expect(habits.first.isDueToday(), true);
    });

    test('Deve adicionar múltiplos hábitos', () async {
      // Arrange & Act
      await habitService.addHabit(
        title: 'Hábito 1',
        categoryName: 'Categoria 1',
        categoryIcon: Icons.star,
        categoryColor: Colors.blue,
        frequency: HabitFrequency.daily,
        trackingType: HabitTrackingType.simOuNao,
        startDate: DateTime.now(),
      );
      
      await habitService.addHabit(
        title: 'Hábito 2',
        categoryName: 'Categoria 2',
        categoryIcon: Icons.favorite,
        categoryColor: Colors.red,
        frequency: HabitFrequency.daily,
        trackingType: HabitTrackingType.simOuNao,
        startDate: DateTime.now(),
      );
      
      await habitService.addHabit(
        title: 'Hábito 3',
        categoryName: 'Categoria 3',
        categoryIcon: Icons.work,
        categoryColor: Colors.green,
        frequency: HabitFrequency.daily,
        trackingType: HabitTrackingType.simOuNao,
        startDate: DateTime.now(),
      );

      // Assert
      final habits = await habitService.getHabits();
      expect(habits.length, 3);
      expect(habits.map((h) => h.title).toList(), 
        containsAll(['Hábito 1', 'Hábito 2', 'Hábito 3']));
    });

    test('Deve retornar null ao buscar hábito inexistente', () async {
      // Act
      final habit = await habitService.getHabitById('non-existent-id');
      
      // Assert
      expect(habit, isNull);
    });

    test('Deve marcar hábito como não completo', () async {
      // Arrange
      await habitService.addHabit(
        title: 'Teste',
        categoryName: 'Teste',
        categoryIcon: Icons.check,
        categoryColor: Colors.green,
        frequency: HabitFrequency.daily,
        trackingType: HabitTrackingType.simOuNao,
        startDate: DateTime.now(),
      );
      
      var habits = await habitService.getHabits();
      final habitId = habits.first.id;
      final today = DateTime.now();
      
      // Marcar como completo primeiro
      await habitService.markHabitCompletion(habitId, today, true);
      
      // Act - Marcar como não completo
      await habitService.markHabitCompletion(habitId, today, false);
      
      // Assert
      habits = await habitService.getHabits();
      expect(habits.first.isCompletedToday(), false);
    });

    test('Deve criar hábito com tracking de quantidade', () async {
      // Act
      await habitService.addHabit(
        title: 'Beber Água',
        categoryName: 'Saúde',
        categoryIcon: Icons.local_drink,
        categoryColor: Colors.blue,
        frequency: HabitFrequency.daily,
        trackingType: HabitTrackingType.quantia,
        startDate: DateTime.now(),
      );
      
      // Assert
      final habits = await habitService.getHabits();
      expect(habits.length, 1);
      expect(habits.first.trackingType, HabitTrackingType.quantia);
    });

    test('Deve criar hábito mensal', () async {
      // Act
      await habitService.addHabit(
        title: 'Pagar Contas',
        categoryName: 'Finanças',
        categoryIcon: Icons.attach_money,
        categoryColor: Colors.green,
        frequency: HabitFrequency.monthly,
        daysOfMonth: [1, 15], // Dias 1 e 15 do mês
        trackingType: HabitTrackingType.simOuNao,
        startDate: DateTime.now(),
      );
      
      // Assert
      final habits = await habitService.getHabits();
      expect(habits.length, 1);
      expect(habits.first.frequency, HabitFrequency.monthly);
      expect(habits.first.daysOfMonth, [1, 15]);
    });
  });
}
