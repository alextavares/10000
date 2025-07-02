import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/services/habit_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:uuid/uuid.dart';

/// Script de teste para criar um novo hábito no HabitAI
/// 
/// Para executar: flutter test test_criar_habito.dart

void main() {
  test('Criar novo hábito de meditação', () async {
    // Configurar serviços necessários
    final firestore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;
    final notificationService = NotificationService();
    final achievementService = AchievementService(
      firestore: firestore,
      auth: auth,
    );
    
    final habitService = HabitService(
      firestore: firestore,
      auth: auth,
      notificationService: notificationService,
      achievementService: achievementService,
    );

    // Criar o hábito
    final uuid = const Uuid();
    final novoHabito = Habit(
      id: uuid.v4(),
      title: 'Meditar 10 minutos',
      description: 'Praticar meditação mindfulness todas as manhãs',
      category: 'Saúde',
      icon: Icons.self_improvement,
      color: Colors.deepPurple,
      priority: 'Normal',
      frequency: HabitFrequency.daily,
      trackingType: HabitTrackingType.cronometro,
      targetTime: const Duration(minutes: 10),
      startDate: DateTime.now(),
      targetDate: DateTime.now().add(const Duration(days: 21)), // 21 dias para formar o hábito
      reminderTime: const TimeOfDay(hour: 7, minute: 0), // Lembrete às 7h
      notificationsEnabled: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      userId: auth.currentUser?.uid ?? 'test-user',
      completionHistory: {},
      dailyProgress: {},
      streak: 0,
      longestStreak: 0,
      totalCompletions: 0,
    );

    try {
      // Adicionar o hábito
      await habitService.addHabit(novoHabito);
      print('✅ Hábito criado com sucesso!');
      print('ID: ${novoHabito.id}');
      print('Título: ${novoHabito.title}');
      print('Categoria: ${novoHabito.category}');
      print('Frequência: Diária');
      print('Meta: 10 minutos por dia');
      print('Lembrete: 7:00 AM');
    } catch (e) {
      print('❌ Erro ao criar hábito: $e');
    }
  });
}
