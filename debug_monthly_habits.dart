import 'package:flutter/material.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/services/habit_service.dart';

void main() async {
  print('=== TESTE DE HÁBITOS MENSAIS ===');
  
  final habitService = HabitService();
  
  // Criar um hábito mensal de teste
  await habitService.addHabit(
    title: 'Teste Mensal',
    categoryName: 'Teste',
    categoryIcon: Icons.star,
    categoryColor: Colors.blue,
    frequency: HabitFrequency.monthly,
    trackingType: HabitTrackingType.simOuNao,
    startDate: DateTime.now(),
    daysOfMonth: [1, 15, 30], // Dias 1, 15, 30 do mês
  );
  
  print('Hábito mensal criado');
  
  // Buscar todos os hábitos
  final habits = await habitService.getHabits();
  print('Total de hábitos: ${habits.length}');
  
  for (var habit in habits) {
    print('Hábito: ${habit.title}');
    print('  - Frequência: ${habit.frequency}');
    print('  - DaysOfMonth: ${habit.daysOfMonth}');
    print('  - isDueToday() para hoje: ${habit.isDueToday()}');
    print('  - isDueToday() para dia 1: ${habit.isDueToday(DateTime(2025, 1, 1))}');
    print('  - isDueToday() para dia 15: ${habit.isDueToday(DateTime(2025, 1, 15))}');
    print('  - isDueToday() para dia 30: ${habit.isDueToday(DateTime(2025, 1, 30))}');
    print('');
  }
}
