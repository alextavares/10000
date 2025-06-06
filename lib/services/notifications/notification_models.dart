import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Modelo de dados para análise de padrões de comportamento
class UserBehaviorPattern {
  final Map<int, List<TimeOfDay>> completionTimesByWeekday; // dia da semana -> horários
  final Map<String, double> categorySuccessRates; // categoria -> taxa de sucesso
  final Map<TimeOfDay, double> hourlySuccessRates; // hora -> taxa de sucesso
  final List<int> activeDaysOfWeek; // dias mais ativos
  final TimeOfDay? optimalMorningTime;
  final TimeOfDay? optimalEveningTime;
  final double overallMotivationScore;
  final String userChronotype; // 'morning_lark', 'night_owl', 'balanced'
  
  const UserBehaviorPattern({
    required this.completionTimesByWeekday,
    required this.categorySuccessRates,
    required this.hourlySuccessRates,
    required this.activeDaysOfWeek,
    this.optimalMorningTime,
    this.optimalEveningTime,
    required this.overallMotivationScore,
    required this.userChronotype,
  });
}

/// Tipos de notificação
enum NotificationType {
  reminder,          // Lembrete padrão
  motivation,        // Mensagem motivacional
  streak,           // Relacionada a sequências
  achievement,      // Nova conquista próxima
  insight,          // Insight sobre progresso
  challenge,        // Desafio do dia
  celebration,      // Celebração de conquista
  comeback,         // Incentivo para voltar
  smartSuggestion,  // Sugestão baseada em IA
}

/// Modelo de uma notificação inteligente
class SmartNotification {
  final String id;
  final String habitId;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime scheduledTime;
  final Map<String, dynamic>? metadata;
  final int priority; // 1-5, sendo 5 mais importante
  final String? actionText;
  final String? actionRoute;
  
  const SmartNotification({
    required this.id,
    required this.habitId,
    required this.title,
    required this.body,
    required this.type,
    required this.scheduledTime,
    this.metadata,
    required this.priority,
    this.actionText,
    this.actionRoute,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habitId': habitId,
      'title': title,
      'body': body,
      'type': type.toString(),
      'scheduledTime': scheduledTime.toIso8601String(),
      'metadata': metadata,
      'priority': priority,
      'actionText': actionText,
      'actionRoute': actionRoute,
    };
  }
  
  factory SmartNotification.fromMap(Map<String, dynamic> map) {
    return SmartNotification(
      id: map['id'],
      habitId: map['habitId'],
      title: map['title'],
      body: map['body'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == map['type'],
      ),
      scheduledTime: DateTime.parse(map['scheduledTime']),
      metadata: map['metadata'],
      priority: map['priority'],
      actionText: map['actionText'],
      actionRoute: map['actionRoute'],
    );
  }
}

/// Templates de mensagens motivacionais
class NotificationTemplates {
  
  // Mensagens para diferentes momentos do dia
  static const Map<String, List<String>> timeBasedMessages = {
    'morning': [
      '☀️ Bom dia! Que tal começar o dia com energia?',
      '🌅 Novo dia, novas oportunidades! Vamos lá?',
      '💪 Acorde e conquiste! Seus hábitos te esperam.',
      '🚀 Manhã é poder! Comece com o pé direito.',
      '✨ Que seu dia seja tão incrível quanto seus objetivos!',
    ],
    'afternoon': [
      '☕ Pausa para o café? Que tal um hábito rápido?',
      '🌤️ Tarde produtiva começa agora!',
      '⚡ Recarregue as energias com seus hábitos!',
      '🎯 Metade do dia, força total!',
      '💫 Continue brilhando! Você consegue!',
    ],
    'evening': [
      '🌙 Finalize o dia com chave de ouro!',
      '🌃 Noite chegando, hábitos esperando!',
      '⭐ Termine o dia sendo sua melhor versão!',
      '🏁 Reta final! Conclua seus hábitos!',
      '✅ Que tal fechar o dia com 100%?',
    ],
    'night': [
      '🌜 Última chance do dia! Não deixe para amanhã.',
      '💤 Antes de dormir, que tal completar isso?',
      '🌟 Finalize e durma com a consciência tranquila!',
      '🛌 Preparando para dormir? Hábito rápido antes!',
      '🌙 Boa noite começa com hábitos cumpridos!',
    ],
  };
  
  // Mensagens por tipo de conquista/motivação
  static const Map<String, List<String>> achievementMessages = {
    'streak_3': [
      '🔥 3 dias seguidos! Você está pegando fogo!',
      '🎯 Três em sequência! Continue assim!',
      '⚡ 3 dias de pura dedicação! Incrível!',
    ],
    'streak_7': [
      '🏆 Uma semana completa! Você é demais!',
      '🌟 7 dias seguidos! Lendário!',
      '💪 Semana perfeita! Orgulho define!',
    ],
    'streak_30': [
      '👑 30 dias! Você é uma máquina de hábitos!',
      '🎉 Um mês inteiro! Isso é ÉPICO!',
      '🚀 30 dias de excelência! Você é inspiração!',
    ],
    'comeback': [
      '💪 Ei, sentimos sua falta! Vamos voltar com tudo?',
      '🌟 Que tal recomeçar hoje? Estamos te esperando!',
      '✨ Todo dia é uma nova chance. Vamos lá?',
      '🚀 Pronto para voltar a brilhar?',
    ],
    'almost_there': [
      '🎯 Só falta um! Você consegue!',
      '⚡ Quase lá! Mais um e você fecha o dia!',
      '💫 Tão perto! Finalize com sucesso!',
    ],
    'perfect_day': [
      '🎉 DIA PERFEITO! Todos os hábitos concluídos!',
      '⭐ 100% de sucesso hoje! Você é incrível!',
      '🏆 Dia impecável! Continue esse ritmo!',
    ],
  };
  
  // Mensagens personalizadas por categoria de hábito
  static const Map<String, List<String>> categoryMessages = {
    'Saúde': [
      '💚 Sua saúde agradece! Vamos cuidar do corpo?',
      '🏃 Mexa-se! Seu corpo precisa de você.',
      '🥗 Hábitos saudáveis, vida feliz!',
    ],
    'Produtividade': [
      '📈 Produtividade é o caminho do sucesso!',
      '⚡ Foco e ação! Vamos ser produtivos?',
      '🎯 Metas não se cumprem sozinhas!',
    ],
    'Mindfulness': [
      '🧘 Momento zen! Cuide da sua mente.',
      '🌸 Respire fundo e encontre sua paz.',
      '☮️ Equilíbrio mental é essencial!',
    ],
    'Estudos': [
      '📚 Conhecimento é poder! Vamos estudar?',
      '🎓 Cada página lida é um passo ao sucesso!',
      '💡 Alimente sua mente com sabedoria!',
    ],
    'Social': [
      '💬 Conexões importam! Cultive relacionamentos.',
      '🤝 Pessoas especiais merecem seu tempo!',
      '❤️ Fortaleça seus laços!',
    ],
  };
  
  /// Gera uma mensagem personalizada baseada no contexto
  static String generatePersonalizedMessage({
    required NotificationType type,
    required String habitTitle,
    required TimeOfDay currentTime,
    String? category,
    int? currentStreak,
    double? completionRate,
  }) {
    final random = math.Random();
    String message = '';
    
    // Determina o período do dia
    String timePeriod = 'morning';
    if (currentTime.hour >= 12 && currentTime.hour < 17) {
      timePeriod = 'afternoon';
    } else if (currentTime.hour >= 17 && currentTime.hour < 21) {
      timePeriod = 'evening';
    } else if (currentTime.hour >= 21 || currentTime.hour < 6) {
      timePeriod = 'night';
    }
    
    switch (type) {
      case NotificationType.reminder:
        final timeMessages = timeBasedMessages[timePeriod]!;
        message = timeMessages[random.nextInt(timeMessages.length)];
        break;
        
      case NotificationType.motivation:
        if (category != null && categoryMessages.containsKey(category)) {
          final catMessages = categoryMessages[category]!;
          message = catMessages[random.nextInt(catMessages.length)];
        } else {
          message = '💪 Você consegue! Mantenha o foco!';
        }
        break;
        
      case NotificationType.streak:
        if (currentStreak != null) {
          if (currentStreak >= 30) {
            message = achievementMessages['streak_30']![
              random.nextInt(achievementMessages['streak_30']!.length)
            ];
          } else if (currentStreak >= 7) {
            message = achievementMessages['streak_7']![
              random.nextInt(achievementMessages['streak_7']!.length)
            ];
          } else if (currentStreak >= 3) {
            message = achievementMessages['streak_3']![
              random.nextInt(achievementMessages['streak_3']!.length)
            ];
          }
        }
        break;
        
      case NotificationType.celebration:
        message = achievementMessages['perfect_day']![
          random.nextInt(achievementMessages['perfect_day']!.length)
        ];
        break;
        
      case NotificationType.comeback:
        message = achievementMessages['comeback']![
          random.nextInt(achievementMessages['comeback']!.length)
        ];
        break;
        
      default:
        message = '✨ Não esqueça: $habitTitle te espera!';
    }
    
    return message;
  }
  
  /// Gera título apropriado para a notificação
  static String generateTitle({
    required NotificationType type,
    required String habitTitle,
    int? streak,
  }) {
    switch (type) {
      case NotificationType.reminder:
        return 'Hora de $habitTitle';
      case NotificationType.streak:
        return '🔥 $streak dias de sequência!';
      case NotificationType.achievement:
        return '🏆 Nova Conquista Próxima!';
      case NotificationType.insight:
        return '💡 Insight do Dia';
      case NotificationType.challenge:
        return '🎯 Desafio Especial';
      case NotificationType.celebration:
        return '🎉 Parabéns!';
      case NotificationType.comeback:
        return '👋 Sentimos sua falta!';
      case NotificationType.smartSuggestion:
        return '🤖 Sugestão Inteligente';
      default:
        return 'HabitAI';
    }
  }
}

/// Configurações de notificação por hábito
class HabitNotificationSettings {
  final String habitId;
  final bool enabled;
  final List<TimeOfDay> reminderTimes;
  final bool smartScheduling; // IA decide melhor horário
  final bool motivationalMessages;
  final bool streakReminders;
  final Map<String, dynamic>? customSettings;
  
  const HabitNotificationSettings({
    required this.habitId,
    this.enabled = true,
    required this.reminderTimes,
    this.smartScheduling = true,
    this.motivationalMessages = true,
    this.streakReminders = true,
    this.customSettings,
  });
  
  HabitNotificationSettings copyWith({
    String? habitId,
    bool? enabled,
    List<TimeOfDay>? reminderTimes,
    bool? smartScheduling,
    bool? motivationalMessages,
    bool? streakReminders,
    Map<String, dynamic>? customSettings,
  }) {
    return HabitNotificationSettings(
      habitId: habitId ?? this.habitId,
      enabled: enabled ?? this.enabled,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      smartScheduling: smartScheduling ?? this.smartScheduling,
      motivationalMessages: motivationalMessages ?? this.motivationalMessages,
      streakReminders: streakReminders ?? this.streakReminders,
      customSettings: customSettings ?? this.customSettings,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'habitId': habitId,
      'enabled': enabled,
      'reminderTimes': reminderTimes.map((t) => '${t.hour}:${t.minute}').toList(),
      'smartScheduling': smartScheduling,
      'motivationalMessages': motivationalMessages,
      'streakReminders': streakReminders,
      'customSettings': customSettings,
    };
  }
  
  factory HabitNotificationSettings.fromMap(Map<String, dynamic> map) {
    return HabitNotificationSettings(
      habitId: map['habitId'],
      enabled: map['enabled'] ?? true,
      reminderTimes: (map['reminderTimes'] as List).map((t) {
        final parts = t.split(':');
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }).toList(),
      smartScheduling: map['smartScheduling'] ?? true,
      motivationalMessages: map['motivationalMessages'] ?? true,
      streakReminders: map['streakReminders'] ?? true,
      customSettings: map['customSettings'],
    );
  }
}
