import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/services/habit_service.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:myapp/config/firebase_options.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('💪 Criando hábito de Exercício...\n');
  
  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Verificar autenticação
  final auth = FirebaseAuth.instance;
  final user = auth.currentUser;
  
  if (user == null) {
    print('❌ Erro: Usuário não está autenticado');
    print('Por favor, faça login no app primeiro');
    exit(1);
  }
  
  print('👤 Usuário: ${user.email}\n');
  
  // Configurar serviços
  final firestore = FirebaseFirestore.instance;
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
  final habit = Habit(
    id: const Uuid().v4(),
    title: 'Fazer exercícios físicos',
    description: 'Manter o corpo ativo e saudável com exercícios regulares',
    category: 'Fitness',
    icon: Icons.fitness_center,
    color: Colors.orange,
    priority: 'Alta',
    frequency: HabitFrequency.weekly,
    daysOfWeek: [1, 3, 5], // Segunda, Quarta e Sexta
    trackingType: HabitTrackingType.simOuNao,
    startDate: DateTime.now(),
    targetDate: DateTime.now().add(const Duration(days: 90)), // 3 meses
    reminderTime: const TimeOfDay(hour: 18, minute: 0), // 18:00
    notificationsEnabled: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    userId: user.uid,
    completionHistory: {},
    dailyProgress: {},
    streak: 0,
    longestStreak: 0,
    totalCompletions: 0,
  );
  
  try {
    final habitId = await habitService.addHabit(habit);
    
    print('✅ Hábito criado com sucesso!\n');
    print('📋 Detalhes:');
    print('   • Título: ${habit.title}');
    print('   • Tipo: Sim ou Não (marcar quando concluído)');
    print('   • Frequência: Segunda, Quarta e Sexta');
    print('   • Lembrete: 18:00');
    print('   • Meta: 3 meses\n');
    print('💡 Benefícios do exercício regular:');
    print('   • Melhora a saúde cardiovascular');
    print('   • Aumenta a energia e disposição');
    print('   • Reduz o estresse e ansiedade');
    print('   • Melhora a qualidade do sono');
    
  } catch (e) {
    print('❌ Erro ao criar hábito: $e');
    exit(1);
  }
  
  exit(0);
}
