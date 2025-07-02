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
  
  print('💧 Criando hábito de Beber Água...\n');
  
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
    title: 'Beber água suficiente',
    description: 'Manter o corpo hidratado bebendo pelo menos 8 copos de água por dia',
    category: 'Saúde',
    icon: Icons.water_drop,
    color: Colors.blue,
    priority: 'Alta',
    frequency: HabitFrequency.daily,
    trackingType: HabitTrackingType.quantia,
    targetQuantity: 8,
    quantityUnit: 'copos',
    startDate: DateTime.now(),
    targetDate: DateTime.now().add(const Duration(days: 30)),
    reminderTime: const TimeOfDay(hour: 8, minute: 0), // 8:00 da manhã
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
    print('   • Meta: ${habit.targetQuantity} ${habit.quantityUnit} por dia');
    print('   • Frequência: Diária');
    print('   • Lembrete: 8:00 da manhã');
    print('   • Duração: 30 dias\n');
    print('💡 Dica: Comece o dia com um copo de água!');
    print('   A hidratação adequada melhora o foco e a energia.');
    
  } catch (e) {
    print('❌ Erro ao criar hábito: $e');
    exit(1);
  }
  
  exit(0);
}
