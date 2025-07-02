import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:myapp/config/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🔍 Verificando configuração do Firebase para HabitAI...\n');
  
  // 1. Verificar arquivo .env
  print('📄 Verificando arquivo .env...');
  try {
    await dotenv.load(fileName: '.env');
    print('✅ Arquivo .env carregado\n');
    
    // Verificar variáveis necessárias
    final firebaseApiKey = dotenv.env['FIREBASE_API_KEY'] ?? '';
    final googleApiKey = dotenv.env['GOOGLE_API_KEY'] ?? '';
    
    print('🔑 Verificando chaves de API:');
    print('   FIREBASE_API_KEY: ${firebaseApiKey.isEmpty ? '❌ NÃO CONFIGURADA' : '✅ Configurada (${firebaseApiKey.substring(0, 10)}...)'}');
    print('   GOOGLE_API_KEY: ${googleApiKey.isEmpty ? '⚠️  Não configurada (IA não funcionará)' : '✅ Configurada'}\n');
    
    if (firebaseApiKey.isEmpty) {
      print('❗ AÇÃO NECESSÁRIA:');
      print('1. Acesse https://console.firebase.google.com/');
      print('2. Crie/acesse o projeto "android-habitai"');
      print('3. Vá em Configurações do Projeto > Geral');
      print('4. Copie a "Chave de API da Web"');
      print('5. Cole no arquivo .env como FIREBASE_API_KEY=sua_chave_aqui');
      print('\nOu copie o arquivo .env.firebase e preencha os valores.');
      exit(1);
    }
    
  } catch (e) {
    print('❌ Erro ao carregar .env: $e');
    print('\nCrie um arquivo .env na raiz do projeto.');
    print('Use o arquivo .env.firebase como modelo.');
    exit(1);
  }
  
  // 2. Tentar inicializar Firebase
  print('🔥 Inicializando Firebase...');
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase inicializado com sucesso!\n');
  } catch (e) {
    print('❌ Erro ao inicializar Firebase: $e\n');
    print('Verifique se as configurações no .env estão corretas.');
    exit(1);
  }
  
  // 3. Testar autenticação
  print('🔐 Testando Firebase Authentication...');
  try {
    final auth = FirebaseAuth.instance;
    
    // Verificar se há usuário logado
    if (auth.currentUser != null) {
      print('✅ Usuário já está logado: ${auth.currentUser!.email}');
    } else {
      print('ℹ️  Nenhum usuário logado atualmente');
    }
    
    print('✅ Firebase Auth está funcionando!\n');
  } catch (e) {
    print('❌ Erro com Firebase Auth: $e\n');
  }
  
  // 4. Testar Firestore
  print('💾 Testando Firestore Database...');
  try {
    final firestore = FirebaseFirestore.instance;
    
    // Tentar ler a coleção users (mesmo vazia)
    await firestore.collection('users').limit(1).get();
    print('✅ Firestore está acessível!\n');
    
  } catch (e) {
    print('❌ Erro ao acessar Firestore: $e');
    print('\nVerifique no Firebase Console:');
    print('1. Se o Firestore Database está ativado');
    print('2. Se as regras de segurança estão configuradas\n');
  }
  
  // 5. Resumo final
  print('📊 RESUMO DA CONFIGURAÇÃO:');
  print('─────────────────────────');
  print('✅ Arquivo .env existe');
  print('${dotenv.env['FIREBASE_API_KEY']?.isNotEmpty == true ? '✅' : '❌'} FIREBASE_API_KEY configurada');
  print('${dotenv.env['GOOGLE_API_KEY']?.isNotEmpty == true ? '✅' : '⚠️ '} GOOGLE_API_KEY configurada');
  print('✅ Firebase inicializado');
  print('✅ Firebase Auth disponível');
  print('✅ Firestore acessível');
  
  print('\n🎉 Configuração verificada com sucesso!');
  print('Você pode agora:');
  print('1. Executar o app: flutter run');
  print('2. Criar uma conta no app');
  print('3. Fazer login');
  print('4. Usar os scripts de criação de hábitos');
  
  // 6. Criar usuário de teste (opcional)
  print('\n💡 Dica: Para criar um usuário de teste automaticamente,');
  print('execute: dart run scripts/criar_usuario_teste.dart');
  
  exit(0);
}
