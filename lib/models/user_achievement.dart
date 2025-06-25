import 'package:cloud_firestore/cloud_firestore.dart';

class UserAchievement {
  final String userId; // Para identificar o usuário no Firestore (se armazenado em coleção global)
  final String achievementId; // ID da AchievementDefinition
  final DateTime unlockedAt;
  final int currentProgress; // Para conquistas baseadas em contagem (ex: completar X hábitos)
  final int targetProgress;  // Valor alvo para a conquista (vindo da AchievementDefinition.criteriaValue)

  UserAchievement({
    required this.userId,
    required this.achievementId,
    required this.unlockedAt,
    this.currentProgress = 0, // Progresso inicial
    required this.targetProgress,
  });

  bool get isUnlocked => currentProgress >= targetProgress;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'achievementId': achievementId,
      'unlockedAt': Timestamp.fromDate(unlockedAt),
      'currentProgress': currentProgress,
      'targetProgress': targetProgress,
      'isUnlocked': isUnlocked, // Pode ser útil armazenar o estado de desbloqueio
    };
  }

  factory UserAchievement.fromMap(Map<String, dynamic> map, String docId) {
    // O docId do Firestore pode ser o achievementId ou um ID composto.
    // Se o docId for apenas o achievementId, então userId vem do caminho da coleção ou do próprio doc.
    return UserAchievement(
      userId: map['userId'] ?? '', // Garantir que userId esteja presente
      achievementId: map['achievementId'] ?? docId, // Usar docId como fallback para achievementId
      unlockedAt: (map['unlockedAt'] as Timestamp).toDate(),
      currentProgress: map['currentProgress'] ?? 0,
      targetProgress: map['targetProgress'] ?? 1, // Default target, deve vir da definition
    );
  }

  UserAchievement copyWith({
    String? userId,
    String? achievementId,
    DateTime? unlockedAt,
    int? currentProgress,
    int? targetProgress,
  }) {
    return UserAchievement(
      userId: userId ?? this.userId,
      achievementId: achievementId ?? this.achievementId,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      currentProgress: currentProgress ?? this.currentProgress,
      targetProgress: targetProgress ?? this.targetProgress,
    );
  }
}
