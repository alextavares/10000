import 'package:flutter/material.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/models/category.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

/// Script para criar um hábito de exemplo
/// Execute com: dart run criar_habito_exemplo.dart

void main() {
  print('===== Criando Hábito de Exemplo =====\n');
  
  // 1. Criar categoria
  final categoria = Category(
    id: const Uuid().v4(),
    name: 'Saúde',
    icon: Icons.favorite,
    color: Colors.red,
  );
  print('✅ Categoria criada: ${categoria.name}');
  
  // 2. Criar hábito de beber água
  final habit = Habit(
    id: const Uuid().v4(),
    title: 'Beber 8 copos de água',
    description: 'Manter-se hidratado ao longo do dia',
    category: categoria.name,
    icon: categoria.icon,
    color: categoria.color,
    priority: 'Alta',
    frequency: HabitFrequency.daily,
    trackingType: HabitTrackingType.quantia,
    targetQuantity: 8,
    quantityUnit: 'copos',
    startDate: DateTime.now(),
    targetDate: DateTime.now().add(const Duration(days: 30)),
    reminderTime: const TimeOfDay(hour: 8, minute: 0),
    notificationsEnabled: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    userId: 'test-user',
    completionHistory: {},
    dailyProgress: {},
    streak: 0,
    longestStreak: 0,
    totalCompletions: 0,
  );
  
  print('\n✅ Hábito criado com sucesso!');
  print('   ID: ${habit.id}');
  print('   Título: ${habit.title}');
  print('   Descrição: ${habit.description}');
  print('   Categoria: ${habit.category}');
  print('   Prioridade: ${habit.priority}');
  print('   Frequência: ${habit.frequency}');
  print('   Tipo: ${habit.trackingType}');
  print('   Meta: ${habit.targetQuantity} ${habit.quantityUnit}');
  print('   Data início: ${habit.startDate}');
  print('   Data alvo: ${habit.targetDate}');
  print('   Lembrete: ${habit.reminderTime?.format(MaterialLocalizations.of(BuildContext as BuildContext))}');
  
  // 3. Converter para JSON
  final habitJson = habit.toMap();
  print('\n📄 JSON do hábito:');
  print(const JsonEncoder.withIndent('  ').convert(habitJson));
  
  // 4. Instruções para uso
  print('\n📌 Para usar este hábito no app:');
  print('1. Copie o JSON acima');
  print('2. Abra o Firebase Console');
  print('3. Vá para Firestore Database');
  print('4. Navegue até: users/{seu-user-id}/habits');
  print('5. Clique em "Add document"');
  print('6. Use o ID: ${habit.id}');
  print('7. Cole os campos do JSON');
  
  print('\n✨ Ou use o script automatizado:');
  print('   dart run scripts/criar_habito_agua.dart');
  
  print('\n===== Fim do Script =====');
}

// Extensão para formatar TimeOfDay sem BuildContext
extension TimeOfDayFormat on TimeOfDay {
  String get formatted => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
