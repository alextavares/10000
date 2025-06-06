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
      id: 'first_week',
      title: 'Primeira Semana',
      description: 'Complete 7 dias seguidos!',
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
    Achievement(
      id: 'explorer',
      title: 'Explorador',
      description: 'Crie hábitos em 3 categorias diferentes',
      icon: Icons.explore,
      color: Colors.teal,
      category: AchievementCategory.variety,
      requirement: 3,
      points: 75,
    ),
    Achievement(
      id: 'balanced',
      title: 'Vida Equilibrada',
      description: 'Mantenha hábitos ativos em 5 categorias',
      icon: Icons.balance,
      color: Colors.cyan,
      category: AchievementCategory.variety,
      requirement: 5,
      points: 150,
    ),
    Achievement(
      id: 'renaissance',
      title: 'Renascentista',
      description: 'Tenha pelo menos 10 hábitos diferentes ativos',
      icon: Icons.palette,
      color: Colors.pink,
      category: AchievementCategory.variety,
      requirement: 10,
      points: 250,
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
