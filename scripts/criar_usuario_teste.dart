import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:myapp/config/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('👤 Criando usuário de teste no HabitAI...\n');
  
  // Carregar configurações
  await dotenv.load(fileName: '.env');
  
  // Inicializar Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('❌ Erro ao inicializar Firebase: $e');
    print('Execute primeiro: dart run verificar_firebase_config.dart');
    exit(1);
  }
  
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  
  // Dados do usuário de teste
  const testEmail = 'teste@habitai.com';
  const testPassword = 'habitai123';
  const testName = 'Usuário Teste';
  
  print('📝 Criando conta de teste:');
  print('   Email: $testEmail');
  print('   Senha: $testPassword');
  print('   Nome: $testName\n');
  
  try {
    // Tentar fazer logout primeiro (caso alguém esteja logado)
    if (auth.currentUser != null) {
      print('🔓 Fazendo logout do usuário atual...');
      await auth.signOut();
    }
    
    // Tentar fazer login primeiro (caso o usuário já exista)
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      );
      print('✅ Usuário de teste já existe! Login realizado.');
      print('   UID: ${credential.user!.uid}');
    } catch (e) {
      // Se falhar, criar novo usuário
      print('👤 Criando novo usuário...');
      
      final credential = await auth.createUserWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      );
      
      final user = credential.user!;
      print('✅ Usuário criado com sucesso!');
      print('   UID: ${user.uid}');
      
      // Atualizar nome do usuário
      await user.updateDisplayName(testName);
      
      // Criar documento do usuário no Firestore
      print('\n💾 Criando perfil no Firestore...');
      await firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': testEmail,
        'displayName': testName,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'onboardingCompleted': true,
        'notificationsEnabled': true,
        'theme': 'dark',
        'language': 'pt_BR',
      });
      
      print('✅ Perfil criado no Firestore!');
    }
    
    // Verificar se está logado
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      print('\n🎉 Usuário de teste está pronto!');
      print('─────────────────────────────');
      print('Email: ${currentUser.email}');
      print('Nome: ${currentUser.displayName ?? testName}');
      print('UID: ${currentUser.uid}');
      print('Verificado: ${currentUser.emailVerified ? 'Sim' : 'Não'}');
      
      print('\n📱 Como usar:');
      print('1. Abra o app: flutter run');
      print('2. Na tela de login, use:');
      print('   Email: $testEmail');
      print('   Senha: $testPassword');
      print('\n💡 Ou execute os scripts de criação de hábitos!');
      print('   Os hábitos serão criados para este usuário.');
    }
    
  } catch (e) {
    print('❌ Erro ao criar usuário: $e');
    
    if (e.toString().contains('email-already-in-use')) {
      print('\nO email já está em uso. Tente fazer login com:');
      print('Email: $testEmail');
      print('Senha: $testPassword');
    } else if (e.toString().contains('weak-password')) {
      print('\nA senha é muito fraca. Use uma senha mais forte.');
    } else if (e.toString().contains('network-request-failed')) {
      print('\nErro de rede. Verifique sua conexão com a internet.');
    }
  }
  
  exit(0);
}
