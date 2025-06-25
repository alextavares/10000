import 'package:flutter/material.dart';

import 'package:myapp/models/habit.dart'; // Importar HabitFrequency

enum AchievementCriteriaType {
  HABIT_CREATED_COUNT,    // Número de hábitos criados
  HABIT_COMPLETED_ONCE,   // Qualquer hábito completado pela primeira vez
  TOTAL_COMPLETIONS_ANY,  // Total de conclusões em qualquer hábito
  TOTAL_COMPLETIONS_SPECIFIC_HABIT, // Total de conclusões para um hábito específico (mais complexo, adiar)
  STREAK_ACHIEVED,        // Atingir uma certa streak em qualquer hábito
  STREAK_ACHIEVED_DAILY_HABIT, // Atingir streak em hábito diário
  DISTINCT_CATEGORIES_USED, // Usar X categorias distintas
  // Adicionar mais tipos conforme necessário
}

class AchievementDefinition {
  final String id;
  final String name;
  final String description;
  final IconData icon; // Usar IconData diretamente para simplificar
  final Color iconColor;
  final AchievementCriteriaType criteriaType;
  final int criteriaValue; // Valor numérico para o critério (ex: contagem, dias de streak)
  final String? relatedCategory; // Para conquistas específicas de categoria
  final HabitFrequency? relatedFrequency; // Para conquistas específicas de frequência

  const AchievementDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.iconColor = Colors.amber, // Cor padrão para o ícone da conquista
    required this.criteriaType,
    required this.criteriaValue,
    this.relatedCategory,
    this.relatedFrequency,
  });
}

// Lista estática de definições de conquistas
class DefaultAchievements {
  static final List<AchievementDefinition> definitions = [
    const AchievementDefinition(
      id: 'pioneiro_habitos',
      name: 'Pioneiro dos Hábitos',
      description: 'Você criou seu primeiro hábito! O primeiro passo é o mais importante.',
      icon: Icons.flag_outlined,
      iconColor: Colors.lightGreenAccent,
      criteriaType: AchievementCriteriaType.HABIT_CREATED_COUNT,
      criteriaValue: 1,
    ),
    const AchievementDefinition(
      id: 'primeira_missao_cumprida',
      name: 'Primeira Missão Cumprida',
      description: 'Você marcou um hábito como concluído pela primeira vez! Continue assim.',
      icon: Icons.check_circle_outline,
      iconColor: Colors.blueAccent,
      criteriaType: AchievementCriteriaType.HABIT_COMPLETED_ONCE,
      criteriaValue: 1, // O valor aqui é simbólico, a lógica verificará qualquer primeira conclusão
    ),
    const AchievementDefinition(
      id: 'embalando_no_ritmo_3',
      name: 'Embalando no Ritmo (3 dias)',
      description: 'Manteve uma sequência de 3 dias em qualquer hábito.',
      icon: Icons.local_fire_department_outlined,
      iconColor: Colors.orangeAccent,
      criteriaType: AchievementCriteriaType.STREAK_ACHIEVED,
      criteriaValue: 3,
    ),
     const AchievementDefinition(
      id: 'semana_impecavel_7',
      name: 'Semana Impecável (7 dias)',
      description: 'Concluiu um hábito diário todos os dias por 7 dias seguidos.',
      icon: Icons.star_outline,
      iconColor: Colors.yellowAccent,
      criteriaType: AchievementCriteriaType.STREAK_ACHIEVED_DAILY_HABIT,
      criteriaValue: 7,
      relatedFrequency: HabitFrequency.daily,
    ),
    const AchievementDefinition(
      id: 'mestre_categorias_3',
      name: 'Mestre das Categorias',
      description: 'Criou hábitos em 3 categorias diferentes.',
      icon: Icons.category_outlined,
      iconColor: Colors.purpleAccent,
      criteriaType: AchievementCriteriaType.DISTINCT_CATEGORIES_USED,
      criteriaValue: 3,
    ),
    const AchievementDefinition(
      id: 'foguete_nao_tem_re_10',
      name: 'Foguete Não Tem Ré (Streak 10)',
      description: 'Incrível! Você manteve uma sequência de 10 dias em um hábito.',
      icon: Icons.rocket_launch_outlined,
      iconColor: Colors.redAccent,
      criteriaType: AchievementCriteriaType.STREAK_ACHIEVED,
      criteriaValue: 10,
    ),
     const AchievementDefinition(
      id: 'habito_e_tudo_30',
      name: 'Hábito é Tudo (Streak 30)',
      description: 'Uau! 30 dias de consistência. Você é uma inspiração!',
      icon: Icons.auto_awesome,
      iconColor: Colors.cyanAccent,
      criteriaType: AchievementCriteriaType.STREAK_ACHIEVED,
      criteriaValue: 30,
    ),
  ];

  static AchievementDefinition? getById(String id) {
    try {
      return definitions.firstWhere((def) => def.id == id);
    } catch (e) {
      return null;
    }
  }
}
