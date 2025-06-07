// Teste da tela de categorias no HabitAi
// Este arquivo pode ser usado para testar rapidamente a funcionalidade de categorias

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/categories/categories_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Login anônimo para teste
  try {
    await FirebaseAuth.instance.signInAnonymously();
  } catch (e) {
    print('Erro no login anônimo: $e');
  }
  
  runApp(const TestCategoriesApp());
}

class TestCategoriesApp extends StatelessWidget {
  const TestCategoriesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teste Categorias HabitAi',
      theme: AppTheme.darkTheme,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Categorias'),
          backgroundColor: const Color(0xFF121212),
        ),
        body: const CategoriesScreen(),
      ),
    );
  }
}
