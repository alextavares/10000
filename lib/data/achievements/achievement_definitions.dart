import 'package:flutter/material.dart';

/// Categoria de conquista
enum AchievementCategory {
  streak,      // Relacionadas a sequências
  completion,  // Total de conclusões
  variety,     // Diversidade de hábitos
  consistency, // Consistência ao longo do tempo
  special,     // Conquistas especiais/eventos
}

/// Modelo de uma conquista
class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final AchievementCategory category;
  final int requirement; // Valor necessário para desbloquear
  final int points;      // Pontos de gamificação
  final String? specialCondition; // Condição especial (opcional)
  final bool isSecret;   // Conquista secreta?
  
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.category,
    required this.requirement,
    required this.points,
    this.specialCondition,
    this.isSecret = false,
  });
}

/// Definições de todas as conquistas do app
class AchievementDefinitions {
  
  // 🔥 CONQUISTAS DE STREAK
  static const List<Achievement> streakAchievements = [
    Achievement(
      id: 'streak_3_days',
      title: 'Embalando no Ritmo',
      description: 'Mantenha uma sequência de 3 dias em qualquer hábito.',
      icon: Icons.whatshot_outlined, // Ícone um pouco diferente para diferenciar
      color: Colors.deepOrangeAccent,
      category: AchievementCategory.streak,
      requirement: 3,
      points: 25,
    ),
    Achievement(
      id: 'first_week', // Mantém esta como a de 7 dias
      title: 'Primeira Semana de Fogo!', // Nome um pouco mais empolgante
      description: 'Complete 7 dias seguidos em um hábito!',
      icon: Icons.local_fire_department,
      color: Colors.orange,
      category: AchievementCategory.streak,
      requirement: 7,
      points: 50,
    ),
    Achievement(
      id: 'on_fire',
      title: 'Em Chamas!',
      description: 'Mantenha uma sequência de 30 dias',
      icon: Icons.whatshot,
      color: Colors.deepOrange,
      category: AchievementCategory.streak,
      requirement: 30,
      points: 200,
    ),
    Achievement(
      id: 'unstoppable',
      title: 'Imparável',
      description: 'Sequência de 100 dias - Você é incrível!',
      icon: Icons.flash_on,
      color: Colors.amber,
      category: AchievementCategory.streak,
      requirement: 100,
      points: 500,
    ),
    Achievement(
      id: 'legend',
      title: 'Lendário',
      description: 'Um ano inteiro sem falhar!',
      icon: Icons.star,
      color: Colors.yellow,
      category: AchievementCategory.streak,
      requirement: 365,
      points: 2000,
    ),
  ];
  
  // ✅ CONQUISTAS DE CONCLUSÕES TOTAIS
  static const List<Achievement> completionAchievements = [
    Achievement(
      id: 'getting_started',
      title: 'Primeiros Passos',
      description: 'Complete seu primeiro hábito',
      icon: Icons.check_circle,
      color: Colors.green,
      category: AchievementCategory.completion,
      requirement: 1,
      points: 10,
    ),
    Achievement(
      id: 'dedicated',
      title: 'Dedicado',
      description: 'Complete 50 hábitos no total',
      icon: Icons.verified,
      color: Colors.blue,
      category: AchievementCategory.completion,
      requirement: 50,
      points: 100,
    ),
    Achievement(
      id: 'champion',
      title: 'Campeão',
      description: '500 hábitos completados!',
      icon: Icons.emoji_events,
      color: Colors.purple,
      category: AchievementCategory.completion,
      requirement: 500,
      points: 300,
    ),
    Achievement(
      id: 'master',
      title: 'Mestre dos Hábitos',
      description: '1000 conclusões - Você dominou a arte!',
      icon: Icons.workspace_premium,
      color: Colors.indigo,
      category: AchievementCategory.completion,
      requirement: 1000,
      points: 1000,
    ),
  ];
  
  // 🌈 CONQUISTAS DE VARIEDADE
  static const List<Achievement> varietyAchievements = [
     Achievement( // Nova conquista "Pioneiro dos Hábitos"
      id: 'habit_pioneer',
      title: 'Pioneiro dos Hábitos',
      description: 'Você criou seu primeiro hábito! O primeiro passo é o mais importante.',
      icon: Icons.flag_circle_outlined,
      color: Colors.lightGreen,
      category: AchievementCategory.variety, // Pode ser 'completion' ou 'special' também
      requirement: 1, // Requer 1 hábito criado/ativo
      points: 10,
      specialCondition: 'total_habits_created', // Para ajudar o service a identificar
    ),
    Achievement(
      id: 'explorer',
      title: 'Explorador de Categorias', // Nome mais específico
      description: 'Crie ou use hábitos em 3 categorias diferentes.',
      icon: Icons.explore_outlined,
      color: Colors.teal,
      category: AchievementCategory.variety,
      requirement: 3, // 3 categorias distintas
      points: 75,
      specialCondition: 'distinct_categories_used', // Para ajudar o service
    ),
    Achievement(
      id: 'balanced_life', // ID ajustado para evitar conflito com 'balanced' se existir em outro lugar
      title: 'Vida Equilibrada',
      description: 'Mantenha hábitos ativos em 5 categorias diferentes.',
      icon: Icons.eco_outlined, // Ícone alternativo
      color: Colors.cyan,
      category: AchievementCategory.variety,
      requirement: 5, // 5 categorias distintas
      points: 150,
      specialCondition: 'distinct_categories_used',
    ),
    Achievement(
      id: 'habit_collector', // Nome mais direto
      title: 'Colecionador de Hábitos',
      description: 'Tenha pelo menos 5 hábitos diferentes ativos.', // Reduzido de 10 para ser mais alcançável inicialmente
      icon: Icons.inventory_2_outlined,
      color: Colors.pink,
      category: AchievementCategory.variety,
      requirement: 5, // 5 hábitos ativos
      points: 100, // Ajuste de pontos
      specialCondition: 'total_habits_created',
    ),
  ];
  
  // 📊 CONQUISTAS DE CONSISTÊNCIA
  static const List<Achievement> consistencyAchievements = [
    Achievement(
      id: 'perfect_week',
      title: 'Semana Perfeita',
      description: 'Complete todos os hábitos por 7 dias',
      icon: Icons.star_outline,
      color: Colors.blue,
      category: AchievementCategory.consistency,
      requirement: 7,
      points: 100,
      specialCondition: 'all_habits_7_days',
    ),
    Achievement(
      id: 'perfect_month',
      title: 'Mês Impecável',
      description: '100% de conclusão em um mês inteiro',
      icon: Icons.calendar_month,
      color: Colors.green,
      category: AchievementCategory.consistency,
      requirement: 30,
      points: 500,
      specialCondition: 'perfect_month',
    ),
    Achievement(
      id: 'early_bird',
      title: 'Madrugador',
      description: 'Complete hábitos antes das 7h por 7 dias',
      icon: Icons.wb_sunny,
      color: Colors.amber,
      category: AchievementCategory.consistency,
      requirement: 7,
      points: 150,
      specialCondition: 'early_completions',
    ),
  ];
  
  // 🎉 CONQUISTAS ESPECIAIS
  static const List<Achievement> specialAchievements = [
    Achievement(
      id: 'new_year_resolution',
      title: 'Resolução de Ano Novo',
      description: 'Mantenha um hábito do dia 1º de janeiro até fevereiro',
      icon: Icons.celebration,
      color: Colors.gold,
      category: AchievementCategory.special,
      requirement: 31,
      points: 300,
      specialCondition: 'new_year',
    ),
    Achievement(
      id: 'weekend_warrior',
      title: 'Guerreiro de Fim de Semana',
      description: 'Complete todos os hábitos em 10 fins de semana seguidos',
      icon: Icons.weekend,
      color: Colors.purple,
      category: AchievementCategory.special,
      requirement: 10,
      points: 200,
      specialCondition: 'weekend_streak',
    ),
    Achievement(
      id: 'night_owl',
      title: 'Coruja Noturna',
      description: 'Complete hábitos após 22h por 7 dias',
      icon: Icons.nights_stay,
      color: Colors.indigo,
      category: AchievementCategory.special,
      requirement: 7,
      points: 150,
      specialCondition: 'late_completions',
    ),
    Achievement(
      id: 'comeback_kid',
      title: 'Retorno Triunfal',
      description: 'Volte a completar hábitos após 7 dias parado',
      icon: Icons.restart_alt,
      color: Colors.red,
      category: AchievementCategory.special,
      requirement: 1,
      points: 100,
      specialCondition: 'comeback',
      isSecret: true,
    ),
  ];
  
  /// Retorna todas as conquistas
  static List<Achievement> getAllAchievements() {
    return [
      ...streakAchievements,
      ...completionAchievements,
      ...varietyAchievements,
      ...consistencyAchievements,
      ...specialAchievements,
    ];
  }
  
  /// Retorna conquistas por categoria
  static List<Achievement> getByCategory(AchievementCategory category) {
    return getAllAchievements()
        .where((a) => a.category == category)
        .toList();
  }
  
  /// Retorna apenas conquistas não secretas
  static List<Achievement> getVisibleAchievements() {
    return getAllAchievements()
        .where((a) => !a.isSecret)
        .toList();
  }
  
  /// Busca uma conquista pelo ID
  static Achievement? getById(String id) {
    try {
      return getAllAchievements().firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
  
  /// Calcula o total de pontos possíveis
  static int getTotalPossiblePoints() {
    return getAllAchievements()
        .fold(0, (sum, achievement) => sum + achievement.points);
  }
}

// Extensão para cores especiais
extension GoldColor on Colors {
  static const gold = Color(0xFFFFD700);
}
