// Script para criar um novo hábito no HabitAI usando Desktop Commander
// Este script demonstra como automatizar a criação de um hábito

import { execSync } from 'child_process';
import path from 'path';

// Configurações do projeto
const PROJECT_ROOT = 'C:\\codigos\\habitai2406\\10000';
const HABIT_DATA = {
  title: 'Praticar gratidão',
  description: 'Escrever 3 coisas pelas quais sou grato todos os dias',
  category: 'Saúde',
  icon: 'sentiment_satisfied_alt',
  trackingType: 'listaAtividades',
  subtasks: [
    'Agradecer pela saúde',
    'Agradecer pela família',
    'Agradecer pelas oportunidades'
  ],
  reminderTime: '21:00',
  priority: 'Normal'
};

console.log('🚀 Iniciando criação de novo hábito no HabitAI...\n');

// Função para executar comandos
function runCommand(command, description) {
  console.log(`📌 ${description}...`);
  try {
    execSync(command, { 
      cwd: PROJECT_ROOT, 
      stdio: 'inherit' 
    });
    console.log('✅ Concluído!\n');
    return true;
  } catch (error) {
    console.error(`❌ Erro: ${error.message}\n`);
    return false;
  }
}

// 1. Verificar se o Flutter está instalado
if (!runCommand('flutter --version', 'Verificando instalação do Flutter')) {
  console.error('Flutter não está instalado ou não está no PATH');
  process.exit(1);
}

// 2. Criar arquivo Dart temporário com o código do hábito
const dartCode = `
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
    return;
  }
  
  print('👤 Usuário autenticado: \${user.email}');
  
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
    HabitSubtask(id: uuid.v4(), title: '${HABIT_DATA.subtasks[0]}'),
    HabitSubtask(id: uuid.v4(), title: '${HABIT_DATA.subtasks[1]}'),
    HabitSubtask(id: uuid.v4(), title: '${HABIT_DATA.subtasks[2]}'),
  ];
  
  // Criar o hábito
  final novoHabito = Habit(
    id: uuid.v4(),
    title: '${HABIT_DATA.title}',
    description: '${HABIT_DATA.description}',
    category: '${HABIT_DATA.category}',
    icon: Icons.${HABIT_DATA.icon},
    color: Colors.amber,
    priority: '${HABIT_DATA.priority}',
    frequency: HabitFrequency.daily,
    trackingType: HabitTrackingType.${HABIT_DATA.trackingType},
    subtasks: subtasks,
    startDate: DateTime.now(),
    targetDate: DateTime.now().add(const Duration(days: 30)),
    reminderTime: TimeOfDay(
      hour: int.parse('${HABIT_DATA.reminderTime}'.split(':')[0]),
      minute: int.parse('${HABIT_DATA.reminderTime}'.split(':')[1])
    ),
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
    // Adicionar o hábito
    final habitId = await habitService.addHabit(novoHabito);
    
    print('\\n✅ Hábito criado com sucesso!');
    print('📋 Detalhes do hábito:');
    print('   ID: \$habitId');
    print('   Título: ${HABIT_DATA.title}');
    print('   Categoria: ${HABIT_DATA.category}');
    print('   Tipo: Lista de Atividades');
    print('   Subtarefas:');
    for (var subtask in subtasks) {
      print('     - \${subtask.title}');
    }
    print('   Lembrete: ${HABIT_DATA.reminderTime}');
    print('   Prioridade: ${HABIT_DATA.priority}');
    print('\\n🎉 Abra o app para ver seu novo hábito!');
    
  } catch (e) {
    print('❌ Erro ao criar hábito: \$e');
  }
  
  // Finalizar
  exit(0);
}
`;

// 3. Salvar código em arquivo temporário
console.log('📝 Criando script de automação...');
const fs = require('fs');
const scriptPath = path.join(PROJECT_ROOT, 'temp_create_habit.dart');
fs.writeFileSync(scriptPath, dartCode);
console.log('✅ Script criado!\n');

// 4. Executar o script
runCommand('dart run temp_create_habit.dart', 'Executando criação do hábito');

// 5. Limpar arquivo temporário
console.log('🧹 Limpando arquivos temporários...');
try {
  fs.unlinkSync(scriptPath);
  console.log('✅ Limpeza concluída!\n');
} catch (error) {
  console.log('⚠️  Não foi possível remover arquivo temporário\n');
}

console.log('🏁 Processo finalizado!');
