import 'package:flutter/material.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/data/achievements/achievement_definitions.dart';
import 'package:myapp/data/achievements/user_achievement_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AchievementService extends ChangeNotifier {
  UserAchievementProfile? _userProfile;
  final List<String> _recentlyUnlocked = [];
  
  UserAchievementProfile? get userProfile => _userProfile;
  List<String> get recentlyUnlocked => List.unmodifiable(_recentlyUnlocked);
  
  /// Inicializa o serviço carregando o perfil do usuário
  Future<void> initialize(String userId) async {
    await _loadProfile(userId);
  }
  
  /// Carrega o perfil do armazenamento local
  Future<void> _loadProfile(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString('achievement_profile_$userId');
    
    if (profileJson != null) {
      final profileMap = json.decode(profileJson);
      _userProfile = UserAchievementProfile.fromMap(profileMap);
    } else {
      _userProfile = UserAchievementProfile.initial(userId);
      await _saveProfile();
    }
    
    notifyListeners();
  }
  
  /// Salva o perfil no armazenamento local
  Future<void> _saveProfile() async {
    if (_userProfile == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    final profileJson = json.encode(_userProfile!.toMap());
    await prefs.setString('achievement_profile_${_userProfile!.userId}', profileJson);
  }
  
  /// Verifica e atualiza conquistas baseado nos hábitos
  Future<List<Achievement>> checkAchievements(List<Habit> habits) async {
    if (_userProfile == null) return [];
    
    final newlyUnlocked = <Achievement>[];
    final achievements = Map<String, AchievementProgress>.from(_userProfile!.achievements);
    
    // Verificar conquistas de streak
    final maxStreak = habits.isEmpty ? 0 : 
        habits.map((h) => h.streak).reduce((a, b) => a > b ? a : b);
    final longestStreak = habits.isEmpty ? 0 : 
        habits.map((h) => h.longestStreak).reduce((a, b) => a > b ? a : b);
    
    for (final achievement in AchievementDefinitions.streakAchievements) {
      final progress = achievements[achievement.id]!;
      if (!progress.isUnlocked) {
        final currentProgress = longestStreak > maxStreak ? longestStreak : maxStreak;
        
        if (currentProgress >= achievement.requirement) {
          // Desbloqueou!
          achievements[achievement.id] = progress.copyWith(
            currentProgress: currentProgress,
            isUnlocked: true,
            unlockedAt: DateTime.now(),
            isNew: true,
          );
          newlyUnlocked.add(achievement);
          _recentlyUnlocked.add(achievement.id);
        } else {
          // Atualiza progresso
          achievements[achievement.id] = progress.copyWith(
            currentProgress: currentProgress,
          );
        }
      }
    }
    
    // Verificar conquistas de conclusões totais
    final totalCompletions = habits.fold(0, (sum, h) => sum + h.totalCompletions);
    
    for (final achievement in AchievementDefinitions.completionAchievements) {
      final progress = achievements[achievement.id]!;
      if (!progress.isUnlocked) {
        if (totalCompletions >= achievement.requirement) {
          // Desbloqueou!
          achievements[achievement.id] = progress.copyWith(
            currentProgress: totalCompletions,
            isUnlocked: true,
            unlockedAt: DateTime.now(),
            isNew: true,
          );
          newlyUnlocked.add(achievement);
          _recentlyUnlocked.add(achievement.id);
        } else {
          // Atualiza progresso
          achievements[achievement.id] = progress.copyWith(
            currentProgress: totalCompletions,
          );
        }
      }
    }
    
    // Verificar conquistas de variedade
    final uniqueCategories = habits.map((h) => h.category).toSet().length;
    final totalActiveHabits = habits.length;
    
    for (final achievement in AchievementDefinitions.varietyAchievements) {
      final progress = achievements[achievement.id]!;
      if (!progress.isUnlocked) {
        int currentProgress = 0;
        
        if (achievement.id == 'explorer' || achievement.id == 'balanced') {
          currentProgress = uniqueCategories;
        } else if (achievement.id == 'renaissance') {
          currentProgress = totalActiveHabits;
        }
        
        if (currentProgress >= achievement.requirement) {
          // Desbloqueou!
          achievements[achievement.id] = progress.copyWith(
            currentProgress: currentProgress,
            isUnlocked: true,
            unlockedAt: DateTime.now(),
            isNew: true,
          );
          newlyUnlocked.add(achievement);
          _recentlyUnlocked.add(achievement.id);
        } else {
          // Atualiza progresso
          achievements[achievement.id] = progress.copyWith(
            currentProgress: currentProgress,
          );
        }
      }
    }
    
    // Verificar conquistas especiais baseadas em condições
    await _checkSpecialAchievements(habits, achievements, newlyUnlocked);
    
    // Atualizar perfil se houver mudanças
    if (newlyUnlocked.isNotEmpty) {
      // Calcular novos pontos
      final newPoints = newlyUnlocked.fold(0, (sum, a) => sum + a.points);
      final totalPoints = _userProfile!.totalPoints + newPoints;
      final newLevel = UserAchievementProfile.calculateLevel(totalPoints);
      final newTitle = UserAchievementProfile.getLevelTitle(newLevel);
      
      _userProfile = _userProfile!.copyWith(
        achievements: achievements,
        totalPoints: totalPoints,
        level: newLevel,
        title: newTitle,
        lastUpdated: DateTime.now(),
      );
      
      await _saveProfile();
      notifyListeners();
    }
    
    return newlyUnlocked;
  }
  
  /// Verifica conquistas especiais com condições específicas
  Future<void> _checkSpecialAchievements(
    List<Habit> habits,
    Map<String, AchievementProgress> achievements,
    List<Achievement> newlyUnlocked,
  ) async {
    // Semana perfeita - todos os hábitos completados por 7 dias
    final perfectWeekAchievement = AchievementDefinitions.consistencyAchievements
        .firstWhere((a) => a.id == 'perfect_week');
    final perfectWeekProgress = achievements[perfectWeekAchievement.id]!;
    
    if (!perfectWeekProgress.isUnlocked && habits.isNotEmpty) {
      bool hasPerfectWeek = true;
      final now = DateTime.now();
      
      for (int i = 0; i < 7; i++) {
        final date = now.subtract(Duration(days: i));
        final dateKey = DateTime(date.year, date.month, date.day);
        
        for (final habit in habits) {
          if (habit.isDueToday(date) && habit.completionHistory[dateKey] != true) {
            hasPerfectWeek = false;
            break;
          }
        }
        
        if (!hasPerfectWeek) break;
      }
      
      if (hasPerfectWeek) {
        achievements[perfectWeekAchievement.id] = perfectWeekProgress.copyWith(
          currentProgress: 7,
          isUnlocked: true,
          unlockedAt: DateTime.now(),
          isNew: true,
        );
        newlyUnlocked.add(perfectWeekAchievement);
        _recentlyUnlocked.add(perfectWeekAchievement.id);
      }
    }
    
    // Outras conquistas especiais podem ser adicionadas aqui...
  }
  
  /// Marca conquistas como vistas (remove o badge "novo")
  Future<void> markAchievementsAsSeen(List<String> achievementIds) async {
    if (_userProfile == null) return;
    
    final achievements = Map<String, AchievementProgress>.from(_userProfile!.achievements);
    bool hasChanges = false;
    
    for (final id in achievementIds) {
      final progress = achievements[id];
      if (progress != null && progress.isNew) {
        achievements[id] = progress.copyWith(isNew: false);
        hasChanges = true;
        _recentlyUnlocked.remove(id);
      }
    }
    
    if (hasChanges) {
      _userProfile = _userProfile!.copyWith(
        achievements: achievements,
        lastUpdated: DateTime.now(),
      );
      await _saveProfile();
      notifyListeners();
    }
  }
  
  /// Retorna o progresso de uma conquista específica
  AchievementProgress? getAchievementProgress(String achievementId) {
    return _userProfile?.achievements[achievementId];
  }
  
  /// Retorna conquistas por categoria com progresso
  List<(Achievement, AchievementProgress)> getAchievementsByCategory(
    AchievementCategory category
  ) {
    if (_userProfile == null) return [];
    
    final achievements = AchievementDefinitions.getByCategory(category);
    final result = <(Achievement, AchievementProgress)>[];
    
    for (final achievement in achievements) {
      final progress = _userProfile!.achievements[achievement.id];
      if (progress != null) {
        result.add((achievement, progress));
      }
    }
    
    return result;
  }
  
  /// Limpa conquistas recentemente desbloqueadas
  void clearRecentlyUnlocked() {
    _recentlyUnlocked.clear();
    notifyListeners();
  }
}
