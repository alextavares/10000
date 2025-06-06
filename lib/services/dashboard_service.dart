import 'package:myapp/models/habit.dart';
import 'dart:math' as math;

/// Modelo para estatísticas do dashboard
class DashboardStats {
  final int totalHabits;
  final int completedToday;
  final int currentStreak;
  final int longestStreak;
  final double overallCompletionRate;
  final double weeklyCompletionRate;
  final double monthlyCompletionRate;
  final Map<String, int> habitsByCategory;
  final Map<DateTime, double> dailyCompletionRates;
  final List<HabitPerformance> topHabits;
  final List<HabitPerformance> strugglingHabits;
  final Map<int, Map<int, double>> yearHeatmap; // month -> day -> completion
  final List<String> insights;
  final DateTime calculatedAt;
  
  const DashboardStats({
    required this.totalHabits,
    required this.completedToday,
    required this.currentStreak,
    required this.longestStreak,
    required this.overallCompletionRate,
    required this.weeklyCompletionRate,
    required this.monthlyCompletionRate,
    required this.habitsByCategory,
    required this.dailyCompletionRates,
    required this.topHabits,
    required this.strugglingHabits,
    required this.yearHeatmap,
    required this.insights,
    required this.calculatedAt,
  });
}

/// Performance de um hábito específico
class HabitPerformance {
  final Habit habit;
  final double completionRate;
  final int currentStreak;
  final int totalCompletions;
  final String trend; // 'improving', 'stable', 'declining'
  
  const HabitPerformance({
    required this.habit,
    required this.completionRate,
    required this.currentStreak,
    required this.totalCompletions,
    required this.trend,
  });
}

/// Serviço para calcular estatísticas do dashboard
class DashboardService {
  
  /// Calcula todas as estatísticas do dashboard
  static DashboardStats calculateStats(List<Habit> habits) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Estatísticas básicas
    final totalHabits = habits.length;
    int completedToday = 0;
    int currentStreak = 0;
    int longestStreak = 0;
    
    // Calcular hábitos completados hoje
    for (final habit in habits) {
      if (habit.isDueToday() && habit.isCompletedToday()) {
        completedToday++;
      }
      currentStreak = math.max(currentStreak, habit.streak);
      longestStreak = math.max(longestStreak, habit.longestStreak);
    }
    
    // Taxas de conclusão
    final overallCompletionRate = _calculateOverallCompletionRate(habits);
    final weeklyCompletionRate = _calculatePeriodCompletionRate(habits, 7);
    final monthlyCompletionRate = _calculatePeriodCompletionRate(habits, 30);
    
    // Hábitos por categoria
    final habitsByCategory = _groupHabitsByCategory(habits);
    
    // Taxas diárias (últimos 30 dias)
    final dailyCompletionRates = _calculateDailyRates(habits, 30);
    
    // Top e struggling habits
    final performances = _calculateHabitPerformances(habits);
    final topHabits = _getTopHabits(performances, 5);
    final strugglingHabits = _getStrugglingHabits(performances, 5);
    
    // Heatmap do ano
    final yearHeatmap = _generateYearHeatmap(habits);
    
    // Gerar insights
    final insights = _generateInsights(
      habits,
      completedToday,
      totalHabits,
      weeklyCompletionRate,
      monthlyCompletionRate,
      topHabits,
      strugglingHabits,
    );
    
    return DashboardStats(
      totalHabits: totalHabits,
      completedToday: completedToday,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      overallCompletionRate: overallCompletionRate,
      weeklyCompletionRate: weeklyCompletionRate,
      monthlyCompletionRate: monthlyCompletionRate,
      habitsByCategory: habitsByCategory,
      dailyCompletionRates: dailyCompletionRates,
      topHabits: topHabits,
      strugglingHabits: strugglingHabits,
      yearHeatmap: yearHeatmap,
      insights: insights,
      calculatedAt: now,
    );
  }
  
  /// Calcula taxa de conclusão geral
  static double _calculateOverallCompletionRate(List<Habit> habits) {
    if (habits.isEmpty) return 0.0;
    
    int totalDue = 0;
    int totalCompleted = 0;
    
    for (final habit in habits) {
      habit.completionHistory.forEach((date, completed) {
        if (habit.isDueToday(date)) {
          totalDue++;
          if (completed) totalCompleted++;
        }
      });
    }
    
    return totalDue > 0 ? totalCompleted / totalDue : 0.0;
  }
  
  /// Calcula taxa de conclusão para um período específico
  static double _calculatePeriodCompletionRate(List<Habit> habits, int days) {
    if (habits.isEmpty) return 0.0;
    
    final now = DateTime.now();
    int totalDue = 0;
    int totalCompleted = 0;
    
    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey = DateTime(date.year, date.month, date.day);
      
      for (final habit in habits) {
        if (habit.isDueToday(date)) {
          totalDue++;
          if (habit.completionHistory[dateKey] == true) {
            totalCompleted++;
          }
        }
      }
    }
    
    return totalDue > 0 ? totalCompleted / totalDue : 0.0;
  }
  
  /// Agrupa hábitos por categoria
  static Map<String, int> _groupHabitsByCategory(List<Habit> habits) {
    final categoryCount = <String, int>{};
    
    for (final habit in habits) {
      categoryCount[habit.category] = (categoryCount[habit.category] ?? 0) + 1;
    }
    
    return categoryCount;
  }
  
  /// Calcula taxas diárias de conclusão
  static Map<DateTime, double> _calculateDailyRates(List<Habit> habits, int days) {
    final rates = <DateTime, double>{};
    final now = DateTime.now();
    
    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey = DateTime(date.year, date.month, date.day);
      
      int due = 0;
      int completed = 0;
      
      for (final habit in habits) {
        if (habit.isDueToday(date)) {
          due++;
          if (habit.completionHistory[dateKey] == true) {
            completed++;
          }
        }
      }
      
      rates[dateKey] = due > 0 ? completed / due : 0.0;
    }
    
    return rates;
  }
  
  /// Calcula performance de cada hábito
  static List<HabitPerformance> _calculateHabitPerformances(List<Habit> habits) {
    final performances = <HabitPerformance>[];
    
    for (final habit in habits) {
      final rate = habit.getCompletionRate();
      final recentRate = _calculatePeriodCompletionRateForHabit(habit, 7);
      final olderRate = _calculatePeriodCompletionRateForHabit(habit, 14, 7);
      
      String trend = 'stable';
      if (recentRate > olderRate + 0.1) {
        trend = 'improving';
      } else if (recentRate < olderRate - 0.1) {
        trend = 'declining';
      }
      
      performances.add(HabitPerformance(
        habit: habit,
        completionRate: rate,
        currentStreak: habit.streak,
        totalCompletions: habit.totalCompletions,
        trend: trend,
      ));
    }
    
    return performances;
  }
  
  /// Calcula taxa de conclusão de um hábito em período específico
  static double _calculatePeriodCompletionRateForHabit(
    Habit habit, 
    int days, 
    [int offset = 0]
  ) {
    final now = DateTime.now();
    int due = 0;
    int completed = 0;
    
    for (int i = offset; i < offset + days; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey = DateTime(date.year, date.month, date.day);
      
      if (habit.isDueToday(date)) {
        due++;
        if (habit.completionHistory[dateKey] == true) {
          completed++;
        }
      }
    }
    
    return due > 0 ? completed / due : 0.0;
  }
  
  /// Obtém os hábitos com melhor performance
  static List<HabitPerformance> _getTopHabits(
    List<HabitPerformance> performances, 
    int count
  ) {
    final sorted = List<HabitPerformance>.from(performances)
      ..sort((a, b) => b.completionRate.compareTo(a.completionRate));
    
    return sorted.take(count).where((p) => p.completionRate > 0.7).toList();
  }
  
  /// Obtém os hábitos com dificuldades
  static List<HabitPerformance> _getStrugglingHabits(
    List<HabitPerformance> performances, 
    int count
  ) {
    final sorted = List<HabitPerformance>.from(performances)
      ..sort((a, b) => a.completionRate.compareTo(b.completionRate));
    
    return sorted.take(count).where((p) => p.completionRate < 0.5).toList();
  }
  
  /// Gera heatmap do ano (últimos 365 dias)
  static Map<int, Map<int, double>> _generateYearHeatmap(List<Habit> habits) {
    final heatmap = <int, Map<int, double>>{};
    final now = DateTime.now();
    
    for (int i = 0; i < 365; i++) {
      final date = now.subtract(Duration(days: i));
      final month = date.month;
      final day = date.day;
      
      if (!heatmap.containsKey(month)) {
        heatmap[month] = {};
      }
      
      int due = 0;
      int completed = 0;
      
      for (final habit in habits) {
        if (habit.isDueToday(date)) {
          due++;
          final dateKey = DateTime(date.year, date.month, date.day);
          if (habit.completionHistory[dateKey] == true) {
            completed++;
          }
        }
      }
      
      heatmap[month]![day] = due > 0 ? completed / due : 0.0;
    }
    
    return heatmap;
  }
  
  /// Gera insights personalizados
  static List<String> _generateInsights(
    List<Habit> habits,
    int completedToday,
    int totalHabits,
    double weeklyRate,
    double monthlyRate,
    List<HabitPerformance> topHabits,
    List<HabitPerformance> strugglingHabits,
  ) {
    final insights = <String>[];
    
    // Insight sobre hoje
    if (completedToday == totalHabits && totalHabits > 0) {
      insights.add('🎉 Parabéns! Você completou todos os hábitos hoje!');
    } else if (completedToday == 0 && totalHabits > 0) {
      insights.add('💪 Que tal começar com um hábito simples hoje?');
    }
    
    // Insight sobre tendência
    if (weeklyRate > monthlyRate + 0.1) {
      insights.add('📈 Sua performance melhorou ${((weeklyRate - monthlyRate) * 100).toInt()}% esta semana!');
    } else if (weeklyRate < monthlyRate - 0.1) {
      insights.add('📊 Sua taxa de conclusão caiu um pouco. Foque nos hábitos mais importantes.');
    }
    
    // Insight sobre melhor hábito
    if (topHabits.isNotEmpty) {
      final best = topHabits.first;
      insights.add('⭐ "${best.habit.title}" é seu hábito mais consistente com ${(best.completionRate * 100).toInt()}% de conclusão!');
    }
    
    // Insight sobre hábito com dificuldade
    if (strugglingHabits.isNotEmpty) {
      final struggling = strugglingHabits.first;
      if (struggling.trend == 'improving') {
        insights.add('💡 "${struggling.habit.title}" está melhorando! Continue assim!');
      } else {
        insights.add('🎯 Considere ajustar a meta de "${struggling.habit.title}" para torná-la mais alcançável.');
      }
    }
    
    // Insights sobre horários
    final morningHabits = habits.where((h) => 
      h.reminderTime != null && h.reminderTime!.hour < 12
    ).length;
    
    if (morningHabits > habits.length / 2) {
      insights.add('🌅 Você é uma pessoa matinal! A maioria dos seus hábitos são pela manhã.');
    }
    
    // Insight motivacional baseado no dia da semana
    final weekday = DateTime.now().weekday;
    if (weekday == DateTime.monday) {
      insights.add('🚀 Nova semana, novas oportunidades! Comece com força total!');
    } else if (weekday == DateTime.friday) {
      insights.add('🎊 Sexta-feira! Mantenha o foco para terminar a semana bem!');
    }
    
    return insights;
  }
}
