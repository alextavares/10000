import 'package:flutter/material.dart';

class HabitSuggestion {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final double? targetValue;
  final String? unit;
  final String category;
  final Map<String, dynamic>? defaultFrequency;
  final double? defaultTarget;
  final TimeOfDay? defaultReminder;

  const HabitSuggestion({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.targetValue,
    this.unit,
    required this.category,
    this.defaultFrequency,
    this.defaultTarget,
    this.defaultReminder,
  });
  
  // Getters adicionais para compatibilidade
  String get name => title;
}

class HabitSuggestions {
  static const Map<String, List<HabitSuggestion>> suggestions = {
    'Saúde e Fitness': [
      HabitSuggestion(
        title: 'Beber água',
        description: 'Manter-se hidratado ao longo do dia',
        icon: Icons.water_drop,
        color: Colors.blue,
        targetValue: 8,
        unit: 'copos',
        category: 'Saúde e Fitness',
        defaultFrequency: {'type': 'daily'},
        defaultTarget: 8,
      ),
      HabitSuggestion(
        title: 'Fazer exercícios',
        description: 'Atividade física regular',
        icon: Icons.fitness_center,
        color: Colors.orange,
        targetValue: 30,
        unit: 'minutos',
        category: 'Saúde e Fitness',
        defaultFrequency: {'type': 'daily'},
        defaultTarget: 30,
      ),
      HabitSuggestion(
        title: 'Dormir cedo',
        description: 'Melhorar qualidade do sono',
        icon: Icons.bedtime,
        color: Colors.indigo,
        targetValue: 23,
        unit: 'horas',
        category: 'Saúde e Fitness',
        defaultFrequency: {'type': 'daily'},
        defaultTarget: 1,
        defaultReminder: TimeOfDay(hour: 22, minute: 30),
      ),
      HabitSuggestion(
        title: 'Meditar',
        description: 'Praticar mindfulness diariamente',
        icon: Icons.self_improvement,
        color: Colors.purple,
        targetValue: 10,
        unit: 'minutos',
        category: 'Saúde e Fitness',
        defaultFrequency: {'type': 'daily'},
        defaultTarget: 10,
      ),
    ],
    'Produtividade': [
      HabitSuggestion(
        title: 'Planejar o dia',
        description: 'Organizar tarefas pela manhã',
        icon: Icons.checklist,
        color: Colors.teal,
        targetValue: 1,
        unit: 'vez',
        category: 'Produtividade',
        defaultFrequency: {'type': 'daily'},
        defaultTarget: 1,
        defaultReminder: TimeOfDay(hour: 7, minute: 0),
      ),
      HabitSuggestion(
        title: 'Ler',
        description: 'Leitura diária para conhecimento',
        icon: Icons.menu_book,
        color: Colors.deepOrange,
        targetValue: 20,
        unit: 'páginas',
        category: 'Produtividade',
        defaultFrequency: {'type': 'daily'},
        defaultTarget: 20,
      ),
      HabitSuggestion(
        title: 'Estudar',
        description: 'Aprender algo novo',
        icon: Icons.school,
        color: Colors.blue,
        targetValue: 30,
        unit: 'minutos',
        category: 'Produtividade',
        defaultFrequency: {'type': 'daily'},
        defaultTarget: 30,
      ),
      HabitSuggestion(
        title: 'Sem celular',
        description: 'Reduzir tempo de tela',
        icon: Icons.phone_disabled,
        color: Colors.red,
        targetValue: 2,
        unit: 'horas',
        category: 'Produtividade',
        defaultFrequency: {'type': 'daily'},
        defaultTarget: 2,
      ),
    ],
    'Alimentação': [
      HabitSuggestion(
        title: 'Comer frutas',
        description: 'Incluir frutas na dieta',
        icon: Icons.apple,
        color: Colors.red,
        targetValue: 3,
        unit: 'porções',
        category: 'Alimentação',
        defaultFrequency: {'type': 'daily'},
        defaultTarget: 3,
      ),
      HabitSuggestion(
        title: 'Evitar açúcar',
        description: 'Reduzir consumo de doces',
        icon: Icons.cake_outlined,
        color: Colors.pink,
        category: 'Alimentação',
        defaultFrequency: {'type': 'daily'},
        defaultTarget: 1,
      ),
      HabitSuggestion(
        title: 'Cozinhar em casa',
        description: 'Preparar refeições saudáveis',
        icon: Icons.restaurant,
        color: Colors.amber,
        targetValue: 1,
        unit: 'refeição',
        category: 'Alimentação',
        defaultFrequency: {'type': 'daily'},
        defaultTarget: 1,
      ),
    ],
    'Bem-estar': [
      HabitSuggestion(
        title: 'Gratidão',
        description: 'Escrever 3 coisas pelas quais é grato',
        icon: Icons.favorite,
        color: Colors.pink,
        targetValue: 3,
        unit: 'itens',
        category: 'Bem-estar',
        defaultFrequency: {'type': 'daily'},
        defaultTarget: 3,
      ),
      HabitSuggestion(
        title: 'Respiração profunda',
        description: 'Exercícios de respiração',
        icon: Icons.air,
        color: Colors.lightBlue,
        targetValue: 5,
        unit: 'minutos',
        category: 'Bem-estar',
        defaultFrequency: {'type': 'daily'},
        defaultTarget: 5,
      ),
      HabitSuggestion(
        title: 'Contato com natureza',
        description: 'Passar tempo ao ar livre',
        icon: Icons.park,
        color: Colors.green,
        targetValue: 15,
        unit: 'minutos',
        category: 'Bem-estar',
        defaultFrequency: {'type': 'daily'},
        defaultTarget: 15,
      ),
    ],
    'Social': [
      HabitSuggestion(
        title: 'Ligar para família',
        description: 'Manter contato com entes queridos',
        icon: Icons.phone,
        color: Colors.blue,
        targetValue: 1,
        unit: 'ligação',
        category: 'Social',
        defaultFrequency: {'type': 'weekly', 'daysOfWeek': [1, 4]},
        defaultTarget: 1,
      ),
      HabitSuggestion(
        title: 'Ajudar alguém',
        description: 'Fazer uma boa ação diária',
        icon: Icons.volunteer_activism,
        color: Colors.red,
        targetValue: 1,
        unit: 'ação',
        category: 'Social',
        defaultFrequency: {'type': 'daily'},
        defaultTarget: 1,
      ),
    ],
  };

  // Método para obter todas as sugestões em uma lista
  static List<HabitSuggestion> get allSuggestions {
    final List<HabitSuggestion> all = [];
    suggestions.forEach((category, habits) {
      all.addAll(habits);
    });
    return all;
  }

  // Método para buscar sugestões por nome
  static List<HabitSuggestion> searchSuggestions(String query) {
    final lowerQuery = query.toLowerCase();
    return allSuggestions.where((habit) {
      return habit.title.toLowerCase().contains(lowerQuery) ||
          habit.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }
  
  /// Retorna todas as sugestões de hábitos
  static List<HabitSuggestion> getAllSuggestions() {
    List<HabitSuggestion> allSuggestions = [];
    suggestions.forEach((category, habits) {
      allSuggestions.addAll(habits);
    });
    return allSuggestions;
  }
  
  /// Retorna todas as categorias disponíveis
  static List<String> getCategories() {
    return suggestions.keys.toList();
  }
}