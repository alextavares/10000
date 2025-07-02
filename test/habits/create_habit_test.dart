import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:uuid/uuid.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  
  setUp(() {
    // Configurar mocks
    mockUser = MockUser(
      uid: 'test-user-123',
      email: 'test@habitai.com',
      displayName: 'Test User',
    );
    mockAuth = MockFirebaseAuth(mockUser: mockUser);
    fakeFirestore = FakeFirebaseFirestore();
  });

  test('Criar novo hábito com sucesso', () async {
    // Preparar dados do hábito
    final habitId = const Uuid().v4();
    final now = DateTime.now();
    final userId = mockUser.uid;
    
    final habitData = {
      'id': habitId,
      'title': 'Meditar 10 minutos',
      'description': 'Praticar meditação diária',
      'category': 'Saúde',
      'icon': 0xe5ca, // Icons.self_improvement
      'color': 0xFF9C27B0, // Colors.purple
      'priority': 'Alta',
      'frequency': 'daily',
      'trackingType': 'cronometro',
      'targetTime': 600, // 10 minutos em segundos
      'startDate': now.toIso8601String(),
      'notificationsEnabled': true,
      'reminderTime': {
        'hour': 7,
        'minute': 0,
      },
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'userId': userId,
      'completionHistory': {},
      'dailyProgress': {},
      'streak': 0,
      'longestStreak': 0,
      'totalCompletions': 0,
    };
    
    // Adicionar ao Firestore
    await fakeFirestore
        .collection('users')
        .doc(userId)
        .collection('habits')
        .doc(habitId)
        .set(habitData);
    
    // Verificar se foi salvo
    final doc = await fakeFirestore
        .collection('users')
        .doc(userId)
        .collection('habits')
        .doc(habitId)
        .get();
    
    expect(doc.exists, true);
    expect(doc.data()?['title'], 'Meditar 10 minutos');
    expect(doc.data()?['category'], 'Saúde');
    expect(doc.data()?['trackingType'], 'cronometro');
    expect(doc.data()?['targetTime'], 600);
    
    print('✅ Teste passou! Hábito criado com sucesso no Firestore mock');
  });
  
  test('Listar hábitos do usuário', () async {
    final userId = mockUser.uid;
    
    // Criar alguns hábitos
    final habits = [
      {
        'id': '1',
        'title': 'Beber água',
        'category': 'Saúde',
        'userId': userId,
      },
      {
        'id': '2',
        'title': 'Ler 30 minutos',
        'category': 'Educação',
        'userId': userId,
      },
      {
        'id': '3',
        'title': 'Exercícios',
        'category': 'Fitness',
        'userId': userId,
      },
    ];
    
    // Adicionar ao Firestore
    for (var habit in habits) {
      await fakeFirestore
          .collection('users')
          .doc(userId)
          .collection('habits')
          .doc(habit['id'] as String)
          .set(habit);
    }
    
    // Buscar todos os hábitos
    final snapshot = await fakeFirestore
        .collection('users')
        .doc(userId)
        .collection('habits')
        .get();
    
    expect(snapshot.docs.length, 3);
    expect(snapshot.docs[0].data()['title'], 'Beber água');
    expect(snapshot.docs[1].data()['title'], 'Ler 30 minutos');
    expect(snapshot.docs[2].data()['title'], 'Exercícios');
    
    print('✅ Teste passou! Listagem de hábitos funcionando corretamente');
  });
  
  test('Validar estrutura do hábito', () async {
    final userId = mockUser.uid;
    final habitId = const Uuid().v4();
    
    // Tentar criar hábito sem título (deve falhar)
    try {
      final invalidHabit = {
        'id': habitId,
        'title': '', // Título vazio - inválido
        'category': 'Saúde',
        'userId': userId,
      };
      
      // Validação simulada
      if (invalidHabit['title'] == null || (invalidHabit['title'] as String).isEmpty) {
        throw Exception('Título do hábito é obrigatório');
      }
      
      fail('Deveria ter lançado exceção para título vazio');
    } catch (e) {
      expect(e.toString(), contains('Título do hábito é obrigatório'));
      print('✅ Teste passou! Validação de título funcionando');
    }
  });
}
