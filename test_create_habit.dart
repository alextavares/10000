import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/services/habit_service.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:myapp/config/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:myapp/config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar configurações
  await AppConfig.initialize();
  
  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Fazer login anônimo se não estiver logado
  final auth = FirebaseAuth.instance;
  if (auth.currentUser == null) {
    print('Fazendo login anônimo...');
    await auth.signInAnonymously();
  }
  
  print('Usuário autenticado: ${auth.currentUser?.uid}');
  
  // Criar serviços
  final firestore = FirebaseFirestore.instance;
  final notificationService = NotificationService();
  await notificationService.initialize();
  
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
  
  // Criar um hábito de teste
  final testHabit = Habit(
    id: '',
    userId: auth.currentUser!.uid,
    title: 'Meditar',
    description: 'Meditar por 10 minutos todos os dias',
    category: 'Bem-estar',
    frequency: HabitFrequency.daily,
    dailyGoal: 1,
    reminderTime: TimeOfDay(hour: 8, minute: 0),
    notificationsEnabled: true,
    color: Colors.blue.value,
    icon: Icons.self_improvement.codePoint,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    isActive: true,
    tags: ['saúde', 'mindfulness'],
    difficulty: HabitDifficulty.medium,
    completionHistory: {},
    dailyProgress: {},
    streak: 0,
    longestStreak: 0,
    totalCompletions: 0,
  );
  
  try {
    print('Criando hábito...');
    final habitId = await habitService.addHabit(testHabit);
    print('✅ Hábito criado com sucesso! ID: $habitId');
    
    // Buscar todos os hábitos para verificar
    final habits = await habitService.getAllHabits();
    print('Total de hábitos: ${habits.length}');
    
    for (var habit in habits) {
      print('- ${habit.title} (${habit.category})');
    }
    
  } catch (e) {
    print('❌ Erro ao criar hábito: $e');
  }
  
  // Finalizar
  print('\nTeste concluído!');
  exit(0);
}
