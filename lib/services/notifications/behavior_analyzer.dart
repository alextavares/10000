import 'package:flutter/material.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/services/notifications/notification_models.dart';
import 'dart:math' as math;

/// Analisador de comportamento do usuário usando ML básico
class BehaviorAnalyzer {
  
  /// Analisa padrões de comportamento do usuário
  Future<UserBehaviorPattern> analyzePatterns(List<Habit> habits) async {
    final completionTimesByWeekday = <int, List<TimeOfDay>>{};
    final categorySuccessRates = <String, double>{};
    final hourlySuccessRates = <TimeOfDay, double>{};
    final activeDaysOfWeek = <int>[];
    
    // Inicializar estruturas de dados
    for (int i = 1; i <= 7; i++) {
      completionTimesByWeekday[i] = [];
    }
    
    // Analisar cada hábito
    for (final habit in habits) {
      // Calcular taxa de sucesso por categoria
      final category = habit.category;
      final rate = habit.getCompletionRate();
      
      if (categorySuccessRates.containsKey(category)) {
        categorySuccessRates[category] = 
            (categorySuccessRates[category]! + rate) / 2;
      } else {
        categorySuccessRates[category] = rate;
      }
      
      // Analisar horários de conclusão
      habit.completionHistory.forEach((date, completed) {
        if (completed) {
          final weekday = date.weekday;
          
          // Estimar horário baseado em padrões (simulado)
          final estimatedTime = _estimateCompletionTime(habit, date);
          completionTimesByWeekday[weekday]!.add(estimatedTime);
          
          // Calcular taxa de sucesso por hora
          if (!hourlySuccessRates.containsKey(estimatedTime)) {
            hourlySuccessRates[estimatedTime] = 0;
          }
          hourlySuccessRates[estimatedTime] = 
              hourlySuccessRates[estimatedTime]! + 1;
        }
      });
    }
    
    // Identificar dias mais ativos
    completionTimesByWeekday.forEach((weekday, times) {
      if (times.length > habits.length * 0.5) {
        activeDaysOfWeek.add(weekday);
      }
    });
    
    // Normalizar taxas de sucesso por hora
    final maxCount = hourlySuccessRates.values.isEmpty ? 1.0 :
        hourlySuccessRates.values.reduce(math.max);
    
    hourlySuccessRates.updateAll((key, value) => value / maxCount);
    
    // Identificar horários ótimos
    final optimalTimes = _identifyOptimalTimes(hourlySuccessRates);
    
    // Determinar cronotipo do usuário
    final chronotype = _determineChronotype(completionTimesByWeekday);
    
    // Calcular score de motivação geral
    final motivationScore = _calculateMotivationScore(habits);
    
    return UserBehaviorPattern(
      completionTimesByWeekday: completionTimesByWeekday,
      categorySuccessRates: categorySuccessRates,
      hourlySuccessRates: hourlySuccessRates,
      activeDaysOfWeek: activeDaysOfWeek,
      optimalMorningTime: optimalTimes['morning'],
      optimalEveningTime: optimalTimes['evening'],
      overallMotivationScore: motivationScore,
      userChronotype: chronotype,
    );
  }
  
  /// Prevê os melhores horários para notificar sobre um hábito específico
  List<TimeOfDay> predictOptimalNotificationTimes(
    Habit habit,
    UserBehaviorPattern pattern,
  ) {
    final times = <TimeOfDay>[];
    
    // 1. Baseado no horário definido pelo usuário (se houver)
    if (habit.reminderTime != null) {
      // Ajustar ligeiramente baseado no padrão de sucesso
      final adjustedTime = _adjustTimeBasedOnPattern(
        habit.reminderTime!,
        pattern,
      );
      times.add(adjustedTime);
    }
    
    // 2. Baseado no cronotipo e categoria
    else {
      // Morning person + hábito de saúde/exercício = notificar cedo
      if (pattern.userChronotype == 'morning_lark' && 
          (habit.category == 'Saúde' || habit.category == 'Fitness')) {
        times.add(const TimeOfDay(hour: 6, minute: 30));
      }
      
      // Night owl + hábito de estudo/trabalho = notificar mais tarde
      else if (pattern.userChronotype == 'night_owl' && 
               (habit.category == 'Estudos' || habit.category == 'Produtividade')) {
        times.add(const TimeOfDay(hour: 20, minute: 0));
      }
      
      // Padrão: usar horários ótimos identificados
      else {
        if (pattern.optimalMorningTime != null) {
          times.add(pattern.optimalMorningTime!);
        }
        if (pattern.optimalEveningTime != null && 
            habit.frequency == HabitFrequency.daily) {
          times.add(pattern.optimalEveningTime!);
        }
      }
    }
    
    // 3. Adicionar notificação estratégica baseada em performance
    if (habit.getCompletionRate() < 0.5) {
      // Hábito com baixa taxa - adicionar lembrete extra
      final extraTime = _calculateStrategicReminderTime(habit, pattern);
      if (extraTime != null && !times.contains(extraTime)) {
        times.add(extraTime);
      }
    }
    
    // Limitar a no máximo 3 notificações por dia
    return times.take(3).toList();
  }
  
  /// Estima o horário de conclusão de um hábito
  TimeOfDay _estimateCompletionTime(Habit habit, DateTime date) {
    // Se temos o horário de lembrete, usar como base
    if (habit.reminderTime != null) {
      // Adicionar variação aleatória de +/- 1 hora
      final random = math.Random(date.millisecondsSinceEpoch);
      final variation = random.nextInt(120) - 60; // -60 a +60 minutos
      
      final totalMinutes = habit.reminderTime!.hour * 60 + 
                          habit.reminderTime!.minute + 
                          variation;
      
      return TimeOfDay(
        hour: (totalMinutes ~/ 60).clamp(0, 23),
        minute: totalMinutes % 60,
      );
    }
    
    // Caso contrário, estimar baseado na categoria
    switch (habit.category) {
      case 'Saúde':
      case 'Fitness':
        return const TimeOfDay(hour: 7, minute: 0);
      case 'Produtividade':
      case 'Estudos':
        return const TimeOfDay(hour: 9, minute: 0);
      case 'Mindfulness':
        return const TimeOfDay(hour: 19, minute: 0);
      default:
        return const TimeOfDay(hour: 18, minute: 0);
    }
  }
  
  /// Identifica horários ótimos baseado nas taxas de sucesso
  Map<String, TimeOfDay?> _identifyOptimalTimes(
    Map<TimeOfDay, double> hourlyRates,
  ) {
    TimeOfDay? morningTime;
    TimeOfDay? eveningTime;
    
    double maxMorningRate = 0;
    double maxEveningRate = 0;
    
    hourlyRates.forEach((time, rate) {
      if (time.hour >= 5 && time.hour < 12) {
        // Manhã
        if (rate > maxMorningRate) {
          maxMorningRate = rate;
          morningTime = time;
        }
      } else if (time.hour >= 17 && time.hour < 22) {
        // Noite
        if (rate > maxEveningRate) {
          maxEveningRate = rate;
          eveningTime = time;
        }
      }
    });
    
    return {
      'morning': morningTime,
      'evening': eveningTime,
    };
  }
  
  /// Determina o cronotipo do usuário
  String _determineChronotype(Map<int, List<TimeOfDay>> completionTimes) {
    int morningCount = 0;
    int eveningCount = 0;
    int totalCount = 0;
    
    completionTimes.forEach((_, times) {
      for (final time in times) {
        totalCount++;
        if (time.hour < 10) {
          morningCount++;
        } else if (time.hour >= 20) {
          eveningCount++;
        }
      }
    });
    
    if (totalCount == 0) return 'balanced';
    
    final morningRatio = morningCount / totalCount;
    final eveningRatio = eveningCount / totalCount;
    
    if (morningRatio > 0.4) return 'morning_lark';
    if (eveningRatio > 0.4) return 'night_owl';
    return 'balanced';
  }
  
  /// Calcula score de motivação geral
  double _calculateMotivationScore(List<Habit> habits) {
    if (habits.isEmpty) return 0.5;
    
    double totalScore = 0;
    int validHabits = 0;
    
    for (final habit in habits) {
      if (habit.completionHistory.length >= 7) {
        validHabits++;
        
        // Fatores que influenciam motivação
        final completionRate = habit.getCompletionRate();
        final streakBonus = math.min(habit.streak / 30, 1.0) * 0.3;
        final consistencyBonus = _calculateConsistencyBonus(habit) * 0.2;
        
        totalScore += (completionRate * 0.5 + streakBonus + consistencyBonus);
      }
    }
    
    return validHabits > 0 ? (totalScore / validHabits).clamp(0.0, 1.0) : 0.5;
  }
  
  /// Calcula bônus de consistência
  double _calculateConsistencyBonus(Habit habit) {
    final history = habit.completionHistory.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    
    if (history.length < 7) return 0;
    
    // Verificar últimos 7 dias
    int consistentDays = 0;
    for (int i = history.length - 7; i < history.length; i++) {
      if (history[i].value) consistentDays++;
    }
    
    return consistentDays / 7;
  }
  
  /// Ajusta horário baseado no padrão de sucesso
  TimeOfDay _adjustTimeBasedOnPattern(
    TimeOfDay originalTime,
    UserBehaviorPattern pattern,
  ) {
    // Se o usuário tem alta taxa de sucesso neste horário, manter
    final successRate = pattern.hourlySuccessRates[originalTime] ?? 0;
    if (successRate > 0.7) return originalTime;
    
    // Caso contrário, ajustar para o horário ótimo mais próximo
    TimeOfDay? bestTime = originalTime;
    double minDifference = double.infinity;
    
    pattern.hourlySuccessRates.forEach((time, rate) {
      if (rate > 0.5) {
        final diff = (time.hour - originalTime.hour).abs() + 
                    (time.minute - originalTime.minute).abs() / 60;
        if (diff < minDifference) {
          minDifference = diff;
          bestTime = time;
        }
      }
    });
    
    return bestTime ?? originalTime;
  }
  
  /// Calcula horário estratégico para lembrete extra
  TimeOfDay? _calculateStrategicReminderTime(
    Habit habit,
    UserBehaviorPattern pattern,
  ) {
    // Para hábitos com baixa performance, enviar lembrete estratégico
    
    // Se é um hábito matinal que está falhando, lembrar na noite anterior
    if (habit.reminderTime != null && habit.reminderTime!.hour < 12) {
      return const TimeOfDay(hour: 21, minute: 0);
    }
    
    // Se é um hábito noturno que está falhando, lembrar no meio do dia
    if (habit.reminderTime != null && habit.reminderTime!.hour >= 18) {
      return const TimeOfDay(hour: 14, minute: 0);
    }
    
    // Padrão: lembrar em um horário de alta motivação
    if (pattern.overallMotivationScore > 0.7) {
      return pattern.optimalMorningTime ?? const TimeOfDay(hour: 10, minute: 0);
    }
    
    return null;
  }
  
  /// Analisa tendências de comportamento ao longo do tempo
  Map<String, dynamic> analyzeTrends(List<Habit> habits, int days) {
    final trends = <String, dynamic>{};
    
    // Analisar tendência de conclusão
    double recentRate = 0;
    double olderRate = 0;
    int recentCount = 0;
    int olderCount = 0;
    
    final now = DateTime.now();
    final midPoint = now.subtract(Duration(days: days ~/ 2));
    
    for (final habit in habits) {
      habit.completionHistory.forEach((date, completed) {
        if (date.isAfter(midPoint)) {
          recentCount++;
          if (completed) recentRate++;
        } else if (date.isAfter(now.subtract(Duration(days: days)))) {
          olderCount++;
          if (completed) olderRate++;
        }
      });
    }
    
    if (recentCount > 0) recentRate /= recentCount;
    if (olderCount > 0) olderRate /= olderCount;
    
    trends['completionTrend'] = recentRate > olderRate + 0.1 ? 'improving' :
                                recentRate < olderRate - 0.1 ? 'declining' : 
                                'stable';
    
    trends['recentCompletionRate'] = recentRate;
    trends['improvement'] = recentRate - olderRate;
    
    // Identificar hábitos em risco
    final atRiskHabits = <Habit>[];
    for (final habit in habits) {
      if (habit.streak == 0 && habit.longestStreak > 7) {
        // Perdeu uma boa sequência
        atRiskHabits.add(habit);
      } else if (habit.getCompletionRate() < 0.3) {
        // Taxa muito baixa
        atRiskHabits.add(habit);
      }
    }
    
    trends['atRiskHabits'] = atRiskHabits;
    trends['riskCount'] = atRiskHabits.length;
    
    return trends;
  }
  
  /// Registra uma conclusão de hábito para análise futura
  Future<void> recordCompletion({
    required String habitId,
    required DateTime timestamp,
  }) async {
    // Por enquanto, apenas registra o evento
    // Em uma implementação real, salvaria em banco de dados
    print('Recorded completion for habit $habitId at $timestamp');
  }
  
  /// Analisa o comportamento do usuário baseado nos hábitos
  Future<UserBehaviorAnalysis> analyzeUserBehavior(List<Habit> habits) async {
    final pattern = await analyzePatterns(habits);
    final insights = <String>[];
    
    // Gerar insights baseados no padrão
    if (pattern.userChronotype == 'morning_lark') {
      insights.add('Você é mais produtivo pela manhã! Tente agendar hábitos importantes cedo.');
    } else if (pattern.userChronotype == 'night_owl') {
      insights.add('Você funciona melhor à noite! Considere mover alguns hábitos para mais tarde.');
    }
    
    // Insights sobre categorias
    pattern.categorySuccessRates.forEach((category, rate) {
      if (rate > 0.8) {
        insights.add('Excelente performance em $category! Continue assim!');
      } else if (rate < 0.3) {
        insights.add('$category precisa de atenção. Que tal simplificar os hábitos desta categoria?');
      }
    });
    
    // Insights sobre dias da semana
    if (pattern.activeDaysOfWeek.length < 3) {
      insights.add('Você está focado em poucos dias. Tente distribuir melhor seus hábitos na semana.');
    }
    
    return UserBehaviorAnalysis(
      pattern: pattern,
      insights: insights,
      successRateByHour: pattern.hourlySuccessRates.map((time, rate) => 
        MapEntry(time.hour, rate),
      ),
    );
  }
  
  /// Prevê os melhores horários para um hábito específico
  Future<List<DateTime>> predictOptimalTimes(Habit habit) async {
    final now = DateTime.now();
    final times = <DateTime>[];
    
    // Por padrão, sugerir 3 horários ao longo do dia
    times.add(DateTime(now.year, now.month, now.day, 8, 0)); // Manhã
    times.add(DateTime(now.year, now.month, now.day, 14, 0)); // Tarde
    times.add(DateTime(now.year, now.month, now.day, 20, 0)); // Noite
    
    // Filtrar apenas horários futuros
    return times.where((time) => time.isAfter(now)).toList();
  }
}

/// Classe para representar a análise de comportamento
class UserBehaviorAnalysis {
  final UserBehaviorPattern pattern;
  final List<String> insights;
  final Map<int, double> successRateByHour;
  
  UserBehaviorAnalysis({
    required this.pattern,
    required this.insights,
    required this.successRateByHour,
  });
}
