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
  
  print('🧘 Criando hábito de Meditação...\n');
  
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
    title: 'Meditar diariamente',
    description: 'Praticar meditação mindfulness para reduzir o estresse e aumentar o foco',
    category: 'Saúde',
    icon: Icons.self_improvement,
    color: Colors.deepPurple,
    priority: 'Normal',
    frequency: HabitFrequency.daily,
    trackingType: HabitTrackingType.cronometro,
    targetTime: const Duration(minutes: 10), // 10 minutos
    startDate: DateTime.now(),
    targetDate: DateTime.now().add(const Duration(days: 21)), // 21 dias
    reminderTime: const TimeOfDay(hour: 6, minute: 30), // 6:30 da manhã
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
    print('   • Meta: ${habit.targetTime!.inMinutes} minutos por dia');
    print('   • Frequência: Diária');
    print('   • Lembrete: 6:30 da manhã');
    print('   • Duração: 21 dias\n');
    print('💡 Dicas para meditar:');
    print('   • Encontre um lugar calmo e confortável');
    print('   • Foque na respiração');
    print('   • Seja gentil consigo mesmo');
    print('   • Comece com sessões curtas e aumente gradualmente');
    
  } catch (e) {
    print('❌ Erro ao criar hábito: $e');
    exit(1);
  }
  
  exit(0);
}
