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
  
  print('🙏 Criando hábito de Gratidão...\n');
  
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
  
  // Criar subtarefas
  final uuid = const Uuid();
  final subtasks = [
    HabitSubtask(id: uuid.v4(), title: 'Agradecer pela saúde'),
    HabitSubtask(id: uuid.v4(), title: 'Agradecer pela família'),
    HabitSubtask(id: uuid.v4(), title: 'Agradecer pelas oportunidades do dia'),
  ];
  
  // Criar o hábito
  final habit = Habit(
    id: uuid.v4(),
    title: 'Praticar gratidão diária',
    description: 'Escrever 3 coisas pelas quais sou grato todos os dias antes de dormir',
    category: 'Saúde',
    icon: Icons.favorite,
    color: Colors.pink,
    priority: 'Normal',
    frequency: HabitFrequency.daily,
    trackingType: HabitTrackingType.listaAtividades,
    subtasks: subtasks,
    startDate: DateTime.now(),
    targetDate: DateTime.now().add(const Duration(days: 21)), // 21 dias para formar hábito
    reminderTime: const TimeOfDay(hour: 21, minute: 0), // 21:00
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
    print('   • Tipo: Lista de ${subtasks.length} atividades');
    print('   • Frequência: Diária');
    print('   • Lembrete: 21:00');
    print('   • Meta: 21 dias\n');
    print('💡 Dica: A gratidão transforma o que temos em suficiente!');
    
  } catch (e) {
    print('❌ Erro ao criar hábito: $e');
    exit(1);
  }
  
  exit(0);
}
