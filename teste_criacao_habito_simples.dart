import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

// Modelo simplificado do Habit
class Habit {
  final String id;
  final String title;
  final String category;
  final String? description;
  final IconData icon;
  final Color color;
  final String frequency;
  final String trackingType;
  final DateTime startDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> completionHistory;
  final Map<String, dynamic> dailyProgress;
  final int streak;
  final int longestStreak;
  final int totalCompletions;
  final String? userId;

  Habit({
    required this.id,
    required this.title,
    required this.category,
    this.description,
    required this.icon,
    required this.color,
    required this.frequency,
    required this.trackingType,
    required this.startDate,
    required this.createdAt,
    required this.updatedAt,
    required this.completionHistory,
    required this.dailyProgress,
    this.streak = 0,
    this.longestStreak = 0,
    this.totalCompletions = 0,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'description': description ?? '',
      'icon': icon.codePoint,
      'color': color.value,
      'frequency': frequency,
      'trackingType': trackingType,
      'startDate': startDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'completionHistory': completionHistory,
      'dailyProgress': dailyProgress,
      'streak': streak,
      'longestStreak': longestStreak,
      'totalCompletions': totalCompletions,
      'userId': userId ?? 'test-user',
    };
  }
}

void main() {
  print('===== TESTE DE CRIAÇÃO DE HÁBITO SIMPLES =====\n');

  // Criar um hábito de teste
  final uuid = const Uuid();
  final now = DateTime.now();
  
  final habit = Habit(
    id: uuid.v4(),
    title: 'Beber 8 copos de água',
    category: 'Saúde',
    description: 'Manter-se hidratado ao longo do dia',
    icon: Icons.water_drop,
    color: Colors.blue,
    frequency: 'daily',
    trackingType: 'quantity',
    startDate: now,
    createdAt: now,
    updatedAt: now,
    completionHistory: {},
    dailyProgress: {},
    userId: 'test-user-123',
  );

  print('1. Hábito criado localmente:');
  print('   ID: ${habit.id}');
  print('   Título: ${habit.title}');
  print('   Categoria: ${habit.category}');
  print('   Descrição: ${habit.description}');
  print('   Frequência: ${habit.frequency}');
  print('   Tipo: ${habit.trackingType}');
  print('   Data de início: ${habit.startDate}');
  
  print('\n2. Convertendo para Map (simulando salvamento):');
  final habitMap = habit.toMap();
  print('   Map criado com ${habitMap.keys.length} campos');
  
  print('\n3. Validando campos obrigatórios:');
  final requiredFields = ['id', 'title', 'category', 'icon', 'color', 'frequency', 
                         'trackingType', 'startDate', 'createdAt', 'updatedAt', 
                         'userId', 'completionHistory', 'dailyProgress'];
  
  bool allFieldsPresent = true;
  for (final field in requiredFields) {
    if (!habitMap.containsKey(field)) {
      print('   ❌ Campo obrigatório ausente: $field');
      allFieldsPresent = false;
    }
  }
  
  if (allFieldsPresent) {
    print('   ✅ Todos os campos obrigatórios estão presentes');
  }
  
  print('\n4. Simulando validação de dados:');
  if (habit.title.isEmpty) {
    print('   ❌ Título não pode estar vazio');
  } else {
    print('   ✅ Título válido');
  }
  
  if (habit.category.isEmpty) {
    print('   ❌ Categoria não pode estar vazia');
  } else {
    print('   ✅ Categoria válida');
  }
  
  if (habit.id.isEmpty) {
    print('   ❌ ID não pode estar vazio');
  } else {
    print('   ✅ ID válido (UUID)');
  }
  
  print('\n===== TESTE CONCLUÍDO =====');
  print('\nSe este teste passou, o problema está na comunicação com o Firebase.');
  print('Possíveis causas:');
  print('1. Usuário não autenticado');
  print('2. Permissões do Firestore incorretas');
  print('3. Configuração do Firebase incorreta');
  print('4. Sem conexão com a internet');
  
  exit(0);
}
