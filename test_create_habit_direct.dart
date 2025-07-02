import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

// Configuração do Firebase
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => const FirebaseOptions(
    apiKey: 'AIzaSyAayN2swkuxNZRV_htDIKc9CUjgcxQJK4M',
    appId: '1:258006613617:android:97dd7ccb386841785465d0',
    messagingSenderId: '258006613617',
    projectId: 'android-habitai',
    authDomain: 'android-habitai.firebaseapp.com',
    storageBucket: 'android-habitai.firebasestorage.app',
  );
}

void main() async {
  print('Iniciando teste de criação de hábito...\n');
  
  try {
    // Inicializar Firebase
    print('1. Inicializando Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase inicializado com sucesso!\n');
    
    // Fazer login anônimo para teste
    print('2. Fazendo login anônimo...');
    final auth = FirebaseAuth.instance;
    final userCredential = await auth.signInAnonymously();
    final userId = userCredential.user?.uid;
    print('✅ Login bem-sucedido! UserID: $userId\n');
    
    if (userId == null) {
      throw Exception('Falha ao obter UserID');
    }
    
    // Criar hábito
    print('3. Criando novo hábito...');
    final firestore = FirebaseFirestore.instance;
    final habitsCollection = firestore
        .collection('users')
        .doc(userId)
        .collection('habits');
    
    final habitId = const Uuid().v4();
    final now = DateTime.now();
    
    final habitData = {
      'id': habitId,
      'title': 'Beber 8 copos de água',
      'description': 'Manter-se hidratado ao longo do dia',
      'category': 'Saúde',
      'icon': 0xe156, // Icons.water_drop codePoint
      'color': 0xFF2196F3, // Colors.blue value
      'priority': 'Normal',
      'frequency': 'daily',
      'trackingType': 'quantia',
      'targetQuantity': 8.0,
      'quantityUnit': 'copos',
      'startDate': now.toIso8601String(),
      'notificationsEnabled': true,
      'reminderTime': {
        'hour': 8,
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
    await habitsCollection.doc(habitId).set(habitData);
    print('✅ Hábito criado com sucesso!');
    print('   ID: $habitId');
    print('   Título: ${habitData['title']}');
    print('   Categoria: ${habitData['category']}');
    print('   Tipo: ${habitData['trackingType']}');
    print('   Meta: ${habitData['targetQuantity']} ${habitData['quantityUnit']}\n');
    
    // Verificar se foi salvo
    print('4. Verificando se o hábito foi salvo...');
    final doc = await habitsCollection.doc(habitId).get();
    if (doc.exists) {
      print('✅ Hábito encontrado no Firestore!');
      print('   Dados salvos: ${doc.data()}\n');
    } else {
      print('❌ Erro: Hábito não foi encontrado no Firestore\n');
    }
    
    // Listar todos os hábitos do usuário
    print('5. Listando todos os hábitos do usuário...');
    final snapshot = await habitsCollection.get();
    print('   Total de hábitos: ${snapshot.docs.length}');
    for (var doc in snapshot.docs) {
      final data = doc.data();
      print('   - ${data['title']} (${data['category']})');
    }
    
    // Limpar teste - deletar o hábito criado
    print('\n6. Limpando dados de teste...');
    await habitsCollection.doc(habitId).delete();
    print('✅ Hábito de teste deletado\n');
    
    // Fazer logout
    await auth.signOut();
    print('✅ Logout realizado com sucesso!');
    print('\n🎉 TESTE CONCLUÍDO COM SUCESSO! 🎉');
    
  } catch (e, stackTrace) {
    print('❌ ERRO: $e');
    print('\nStackTrace:');
    print(stackTrace);
  }
  
  exit(0);
}
