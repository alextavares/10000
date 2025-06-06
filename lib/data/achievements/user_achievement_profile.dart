import 'achievement_definitions.dart';

/// Progresso de uma conquista específica
class AchievementProgress {
  final String achievementId;
  final int currentProgress;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final bool isNew; // Para mostrar notificação
  
  const AchievementProgress({
    required this.achievementId,
    required this.currentProgress,
    required this.isUnlocked,
    this.unlockedAt,
    this.isNew = false,
  });
  
  AchievementProgress copyWith({
    String? achievementId,
    int? currentProgress,
    bool? isUnlocked,
    DateTime? unlockedAt,
    bool? isNew,
  }) {
    return AchievementProgress(
      achievementId: achievementId ?? this.achievementId,
      currentProgress: currentProgress ?? this.currentProgress,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      isNew: isNew ?? this.isNew,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'achievementId': achievementId,
      'currentProgress': currentProgress,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'isNew': isNew,
    };
  }
  
  factory AchievementProgress.fromMap(Map<String, dynamic> map) {
    return AchievementProgress(
      achievementId: map['achievementId'],
      currentProgress: map['currentProgress'] ?? 0,
      isUnlocked: map['isUnlocked'] ?? false,
      unlockedAt: map['unlockedAt'] != null 
          ? DateTime.parse(map['unlockedAt']) 
          : null,
      isNew: map['isNew'] ?? false,
    );
  }
}

/// Perfil de gamificação do usuário
class UserAchievementProfile {
  final String userId;
  final Map<String, AchievementProgress> achievements;
  final int totalPoints;
  final int level;
  final String title; // Título baseado no nível
  final DateTime lastUpdated;
  
  const UserAchievementProfile({
    required this.userId,
    required this.achievements,
    required this.totalPoints,
    required this.level,
    required this.title,
    required this.lastUpdated,
  });
  
  /// Calcula o nível baseado nos pontos
  static int calculateLevel(int points) {
    // Sistema de níveis progressivo
    if (points < 50) return 1;
    if (points < 150) return 2;
    if (points < 300) return 3;
    if (points < 500) return 4;
    if (points < 800) return 5;
    if (points < 1200) return 6;
    if (points < 1700) return 7;
    if (points < 2500) return 8;
    if (points < 3500) return 9;
    if (points < 5000) return 10;
    if (points < 7000) return 11;
    if (points < 10000) return 12;
    return 13; // Nível máximo
  }
  
  /// Retorna o título baseado no nível
  static String getLevelTitle(int level) {
    const titles = {
      1: 'Iniciante',
      2: 'Aprendiz',
      3: 'Praticante',
      4: 'Dedicado',
      5: 'Experiente',
      6: 'Veterano',
      7: 'Expert',
      8: 'Mestre',
      9: 'Grão-Mestre',
      10: 'Campeão',
      11: 'Lenda',
      12: 'Mítico',
      13: 'Transcendente',
    };
    return titles[level] ?? 'Iniciante';
  }
  
  /// Calcula quantos pontos faltam para o próximo nível
  static int pointsToNextLevel(int currentPoints) {
    final levelThresholds = [
      0, 50, 150, 300, 500, 800, 1200, 1700, 2500, 3500, 5000, 7000, 10000
    ];
    
    for (int i = 1; i < levelThresholds.length; i++) {
      if (currentPoints < levelThresholds[i]) {
        return levelThresholds[i] - currentPoints;
      }
    }
    return 0; // Nível máximo
  }
  
  /// Retorna conquistas desbloqueadas
  List<String> getUnlockedAchievementIds() {
    return achievements.entries
        .where((e) => e.value.isUnlocked)
        .map((e) => e.key)
        .toList();
  }
  
  /// Retorna conquistas novas (não vistas)
  List<String> getNewAchievementIds() {
    return achievements.entries
        .where((e) => e.value.isNew)
        .map((e) => e.key)
        .toList();
  }
  
  /// Calcula a porcentagem de conclusão
  double getCompletionPercentage() {
    final total = AchievementDefinitions.getAllAchievements().length;
    final unlocked = achievements.values.where((a) => a.isUnlocked).length;
    return total > 0 ? (unlocked / total) : 0.0;
  }
  
  UserAchievementProfile copyWith({
    String? userId,
    Map<String, AchievementProgress>? achievements,
    int? totalPoints,
    int? level,
    String? title,
    DateTime? lastUpdated,
  }) {
    return UserAchievementProfile(
      userId: userId ?? this.userId,
      achievements: achievements ?? this.achievements,
      totalPoints: totalPoints ?? this.totalPoints,
      level: level ?? this.level,
      title: title ?? this.title,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'achievements': achievements.map(
        (key, value) => MapEntry(key, value.toMap())
      ),
      'totalPoints': totalPoints,
      'level': level,
      'title': title,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
  
  factory UserAchievementProfile.fromMap(Map<String, dynamic> map) {
    return UserAchievementProfile(
      userId: map['userId'],
      achievements: (map['achievements'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key, 
          AchievementProgress.fromMap(value as Map<String, dynamic>)
        ),
      ),
      totalPoints: map['totalPoints'] ?? 0,
      level: map['level'] ?? 1,
      title: map['title'] ?? 'Iniciante',
      lastUpdated: DateTime.parse(map['lastUpdated']),
    );
  }
  
  /// Cria um perfil inicial vazio
  factory UserAchievementProfile.initial(String userId) {
    final achievements = <String, AchievementProgress>{};
    
    // Inicializa todas as conquistas como não desbloqueadas
    for (final achievement in AchievementDefinitions.getAllAchievements()) {
      achievements[achievement.id] = AchievementProgress(
        achievementId: achievement.id,
        currentProgress: 0,
        isUnlocked: false,
      );
    }
    
    return UserAchievementProfile(
      userId: userId,
      achievements: achievements,
      totalPoints: 0,
      level: 1,
      title: 'Iniciante',
      lastUpdated: DateTime.now(),
    );
  }
}
