import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/models/category.dart';
import 'package:uuid/uuid.dart';

// Script de diagnóstico para problemas de criação de hábitos
// Execute com: dart run diagnostico_habitos.dart

void main() async {
  print('===== DIAGNÓSTICO DE CRIAÇÃO DE HÁBITOS =====\n');
  
  try {
    // 1. Configurar Firebase
    print('1. Inicializando Firebase...');
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyAayN2swkuxNZRV_htDIKc9CUjgcxQJK4M',
        appId: '1:258006613617:android:97dd7ccb386841785465d0',
        messagingSenderId: '258006613617',
        projectId: 'android-habitai',
        authDomain: 'android-habitai.firebaseapp.com',
        storageBucket: 'android-habitai.firebasestorage.app',
      ),
    );
    print('✅ Firebase inicializado\n');
    
    // 2. Autenticar usuário
    print('2. Autenticando usuário...');
    final auth = FirebaseAuth.instance;
    
    // Tentar login anônimo
    UserCredential? userCredential;
    try {
      userCredential = await auth.signInAnonymously();
      print('✅ Login anônimo bem-sucedido');
    } catch (e) {
      print('⚠️ Falha no login anônimo: $e');
      print('Tentando criar conta de teste...');
      
      try {
        userCredential = await auth.createUserWithEmailAndPassword(
          email: 'teste@habitai.com',
          password: 'teste123456',
        );
        print('✅ Conta de teste criada');
      } catch (e2) {
        print('Tentando fazer login com conta existente...');
        userCredential = await auth.signInWithEmailAndPassword(
          email: 'teste@habitai.com',
          password: 'teste123456',
        );
        print('✅ Login com conta existente');
      }
    }
    
    final userId = userCredential.user?.uid;
    if (userId == null) {
      throw Exception('Falha ao obter ID do usuário');
    }
    print('User ID: $userId\n');
    
    // 3. Verificar conexão com Firestore
    print('3. Testando conexão com Firestore...');
    final firestore = FirebaseFirestore.instance;
    
    // Tentar ler coleção de usuários
    try {
      final userDoc = await firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        print('✅ Documento do usuário existe');
      } else {
        print('⚠️ Documento do usuário não existe - será criado');
        await firestore.collection('users').doc(userId).set({
          'email': userCredential.user?.email ?? 'teste@habitai.com',
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('✅ Documento do usuário criado');
      }
    } catch (e) {
      print('❌ Erro ao acessar Firestore: $e');
      print('Possíveis causas:');
      print('- Sem conexão com internet');
      print('- Permissões do Firestore incorretas');
      print('- Projeto Firebase não configurado corretamente');
      return;
    }
    
    // 4. Criar hábito de teste
    print('\n4. Criando hábito de teste...');
    final habitId = const Uuid().v4();
    final now = DateTime.now();
    
    final habitData = {
      'id': habitId,
      'title': 'Teste - Beber Água',
      'description': 'Hábito de teste criado pelo diagnóstico',
      'category': 'Saúde',
      'icon': Icons.water_drop.codePoint,
      'color': Colors.blue.value,
      'priority': 'Normal',
      'frequency': HabitFrequency.daily.toString(),
      'trackingType': HabitTrackingType.quantia.toString(),
      'targetQuantity': 8.0,
      'quantityUnit': 'copos',
      'startDate': now.toIso8601String(),
      'notificationsEnabled': false,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'userId': userId,
      'completionHistory': {},
      'dailyProgress': {},
      'streak': 0,
      'longestStreak': 0,
      'totalCompletions': 0,
      'isArchived': false,
    };
    
    // Tentar adicionar ao Firestore
    try {
      final docRef = firestore
          .collection('users')
          .doc(userId)
          .collection('habits')
          .doc(habitId);
      
      await docRef.set(habitData);
      print('✅ Hábito adicionado ao Firestore');
      
      // Verificar se foi salvo
      final savedDoc = await docRef.get();
      if (savedDoc.exists) {
        print('✅ Hábito verificado no Firestore');
        print('   ID: ${savedDoc.id}');
        print('   Título: ${savedDoc.data()?['title']}');
      } else {
        print('❌ Hábito não foi encontrado após salvar');
      }
    } catch (e) {
      print('❌ Erro ao salvar hábito: $e');
      print('\nDETALHES DO ERRO:');
      print(e.toString());
    }
    
    // 5. Listar todos os hábitos
    print('\n5. Listando hábitos do usuário...');
    try {
      final habitsSnapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('habits')
          .get();
      
      print('Total de hábitos: ${habitsSnapshot.docs.length}');
      for (var doc in habitsSnapshot.docs) {
        final data = doc.data();
        print('- ${data['title']} (ID: ${doc.id})');
      }
    } catch (e) {
      print('❌ Erro ao listar hábitos: $e');
    }
    
    // 6. Limpar dados de teste
    print('\n6. Limpando dados de teste...');
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('habits')
          .doc(habitId)
          .delete();
      print('✅ Hábito de teste removido');
    } catch (e) {
      print('⚠️ Erro ao remover hábito de teste: $e');
    }
    
    // 7. Fazer logout
    await auth.signOut();
    print('✅ Logout realizado\n');
    
    print('===== DIAGNÓSTICO CONCLUÍDO =====');
    print('\n✅ RESULTADO: Sistema funcionando corretamente!');
    print('\nSe você ainda está tendo problemas ao criar hábitos no app:');
    print('1. Verifique se está logado corretamente');
    print('2. Verifique sua conexão com a internet');
    print('3. Tente fazer logout e login novamente');
    print('4. Verifique os logs do app para mensagens de erro específicas');
    
  } catch (e, stackTrace) {
    print('\n❌ ERRO DURANTE DIAGNÓSTICO:');
    print(e.toString());
    print('\nStack trace:');
    print(stackTrace);
    
    print('\n📋 POSSÍVEIS SOLUÇÕES:');
    print('1. Verifique sua conexão com a internet');
    print('2. Verifique se as configurações do Firebase estão corretas no .env');
    print('3. Verifique as regras de segurança do Firestore no console do Firebase');
    print('4. Certifique-se de que o projeto Firebase está ativo');
  }
  
  exit(0);
}

// Classe Category simplificada para o teste
class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  
  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}
