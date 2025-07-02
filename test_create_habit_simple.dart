import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/services/habit_service.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:myapp/config/firebase_options.dart';
import 'package:myapp/config/app_config.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar configurações
  await AppConfig.initialize();
  
  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Fazer login anônimo
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
  
  final achievementService = AchievementService();
  await achievementService.initialize(auth.currentUser!.uid);
  
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
    title: 'Meditar 🧘',
    description: 'Praticar meditação por 10 minutos',
    category: 'Bem-estar',
    frequency: HabitFrequency.daily,
    reminderTime: TimeOfDay(hour: 8, minute: 0),
    notificationsEnabled: true,
    color: Colors.purple.value,
    icon: Icons.self_improvement.codePoint,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    completionHistory: {},
    dailyProgress: {},
    startDate: DateTime.now(),
    priority: 'Alta',
  );
  
  try {
    print('\n🎯 Criando hábito de teste...\n');
    final habitId = await habitService.addHabit(testHabit);
    print('✅ Hábito criado com sucesso!');
    print('📋 ID: $habitId');
    print('📌 Título: ${testHabit.title}');
    print('🏷️ Categoria: ${testHabit.category}');
    print('⏰ Lembrete: ${testHabit.reminderTime?.format(BuildContext())}\n');
    
    // Buscar todos os hábitos
    final habits = await habitService.getAllHabits();
    print('📊 Total de hábitos do usuário: ${habits.length}\n');
    
    print('Lista de hábitos:');
    for (var habit in habits) {
      print('  • ${habit.title} (${habit.category}) - ${habit.frequency.name}');
    }
    
  } catch (e) {
    print('❌ Erro ao criar hábito: $e');
  }
  
  print('\n✨ Teste concluído! Verifique o app no emulador.');
  
  // Aguardar um pouco antes de sair
  await Future.delayed(Duration(seconds: 2));
  exit(0);
}
