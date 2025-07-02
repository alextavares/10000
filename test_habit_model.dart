import 'package:myapp/models/habit.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

void main() {
  // Criar um hábito de exemplo sem Firebase
  final habit = Habit(
    id: const Uuid().v4(),
    title: 'Beber 2L de água por dia',
    description: 'Manter-se hidratado bebendo pelo menos 2 litros de água diariamente',
    category: 'Saúde',
    icon: Icons.local_drink,
    color: Colors.blue.value,
    priority: 'Alta',
    frequency: HabitFrequency.daily,
    startDate: DateTime.now(),
    targetDate: DateTime.now().add(const Duration(days: 30)),
    reminderTime: const TimeOfDay(hour: 8, minute: 0),
    notificationsEnabled: true,
    trackingType: HabitTrackingType.quantia,
    targetQuantity: 8,
    quantityUnit: 'copos',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    userId: 'anonymous_user',
    completionHistory: {},
    dailyProgress: {},
    streak: 0,
    longestStreak: 0,
    totalCompletions: 0,
  );
  
  print('Hábito criado:');
  print('- ID: ${habit.id}');
  print('- Título: ${habit.title}');
  print('- Descrição: ${habit.description}');
  print('- Categoria: ${habit.category}');
  print('- Prioridade: ${habit.priority}');
  print('- Frequência: ${habit.frequency}');
  print('- Meta: ${habit.targetQuantity} ${habit.quantityUnit}');
  print('- Tipo de tracking: ${habit.trackingType}');
  print('\nHábito criado com sucesso!');
}
