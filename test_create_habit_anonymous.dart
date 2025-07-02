import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/config/firebase_options.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  print('Firebase inicializado');
  
  try {
    // Fazer login anônimo
    print('Fazendo login anônimo...');
    final auth = FirebaseAuth.instance;
    UserCredential userCredential = await auth.signInAnonymously();
    print('Login anônimo bem-sucedido. UID: ${userCredential.user?.uid}');
    
    // Criar um hábito de teste
    final habit = Habit(
      id: const Uuid().v4(),
      title: 'Beber 2L de água por dia',
      description: 'Manter-se hidratado bebendo pelo menos 2 litros de água diariamente',
      category: 'Saúde',
      icon: Icons.local_drink,
      color: Colors.blue.value,
      priority: 'Alta',
      frequency: HabitFrequency.daily,
      startDate: DateTime.now(),
      targetDate: DateTime.now().add(const Duration(days: 30)),
      reminderTime: const TimeOfDay(hour: 8, minute: 0),
      notificationsEnabled: true,
      trackingType: HabitTrackingType.quantia,
      targetQuantity: 8,
      quantityUnit: 'copos',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      userId: userCredential.user!.uid,
      completionHistory: {},
      dailyProgress: {},
      streak: 0,
      longestStreak: 0,
      totalCompletions: 0,
    );
    
    print('Criando hábito: ${habit.title}');
    
    // Salvar no Firestore
    await FirebaseFirestore.instance
        .collection('habits')
        .doc(habit.id)
        .set(habit.toMap());
    
    print('✅ Hábito criado com sucesso!');
    print('ID do hábito: ${habit.id}');
    print('Título: ${habit.title}');
    print('Categoria: ${habit.category}');
    print('Tipo de tracking: ${habit.trackingType}');
    print('Meta: ${habit.targetQuantity} ${habit.quantityUnit}');
    
    // Verificar se foi salvo
    final doc = await FirebaseFirestore.instance
        .collection('habits')
        .doc(habit.id)
        .get();
    
    if (doc.exists) {
      print('✅ Hábito verificado no Firestore!');
    } else {
      print('❌ Erro: Hábito não encontrado no Firestore');
    }
    
  } catch (e) {
    print('❌ Erro ao criar hábito: $e');
  }
  
  print('\nPressione Ctrl+C para sair...');
}
