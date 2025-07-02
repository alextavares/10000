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
    
    // Calcular valores agregados uma vez
    final int maxStreakOverall = habits.isEmpty ? 0 : habits.map((h) => h.streak).reduce((a, b) => a > b ? a : b);
    final int longestStreakOverall = habits.isEmpty ? 0 : habits.map((h) => h.longestStreak).reduce((a, b) => a > b ? a : b);
    final int totalCompletionsAllHabits = habits.fold(0, (sum, h) => sum + h.totalCompletions);
    final int uniqueCategoriesCount = habits.map((h) => h.category.toLowerCase()).toSet().length;
    final int totalActiveHabitsCount = habits.length;

    // Verificar conquistas de streak
    for (final achievement in AchievementDefinitions.streakAchievements) {
      final progress = achievements[achievement.id];
      if (progress != null && !progress.isUnlocked) {
        // Verifica se ALGUM hábito atingiu o streak necessário
        bool achievedByAnyHabit = false;
        int currentMaxStreakForThis = 0;
        for (final habit in habits) {
          if (habit.streak >= achievement.requirement) {
            achievedByAnyHabit = true;
          }
          if (habit.longestStreak > currentMaxStreakForThis) { // Usar longestStreak para o progresso visual
            currentMaxStreakForThis = habit.longestStreak;
          }
        }
        // Se nenhum hábito tem streak, usar o streak geral para progresso
        if (currentMaxStreakForThis == 0 && longestStreakOverall > currentMaxStreakForThis) {
            currentMaxStreakForThis = longestStreakOverall;
        }


        if (achievedByAnyHabit) {
          achievements[achievement.id] = progress.copyWith(
            currentProgress: currentMaxStreakForThis, // Pode ser o streak do hábito específico ou o geral
            isUnlocked: true,
            unlockedAt: DateTime.now(),
            isNew: true,
          );
          newlyUnlocked.add(achievement);
          _recentlyUnlocked.add(achievement.id);
        } else if (currentMaxStreakForThis > progress.currentProgress) {
          achievements[achievement.id] = progress.copyWith(currentProgress: currentMaxStreakForThis);
        }
      }
    }
    
    // Verificar conquistas de conclusões totais
    for (final achievement in AchievementDefinitions.completionAchievements) {
      final progress = achievements[achievement.id];
      if (progress != null && !progress.isUnlocked) {
        if (totalCompletionsAllHabits >= achievement.requirement) {
          achievements[achievement.id] = progress.copyWith(
            currentProgress: totalCompletionsAllHabits,
            isUnlocked: true,
            unlockedAt: DateTime.now(),
            isNew: true,
          );
          newlyUnlocked.add(achievement);
          _recentlyUnlocked.add(achievement.id);
        } else if (totalCompletionsAllHabits > progress.currentProgress) {
          achievements[achievement.id] = progress.copyWith(currentProgress: totalCompletionsAllHabits);
        }
      }
    }
    
    // Verificar conquistas de variedade
    for (final achievement in AchievementDefinitions.varietyAchievements) {
      final progress = achievements[achievement.id];
      if (progress != null && !progress.isUnlocked) {
        int currentProgressValue = 0;
        bool conditionMet = false;

        if (achievement.specialCondition == 'distinct_categories_used') {
          currentProgressValue = uniqueCategoriesCount;
        } else if (achievement.specialCondition == 'total_habits_created') {
          currentProgressValue = totalActiveHabitsCount;
        }
        // Adicione mais casos para outros specialCondition se necessário
        
        if (currentProgressValue >= achievement.requirement) {
          conditionMet = true;
        }
        
        if (conditionMet) {
          achievements[achievement.id] = progress.copyWith(
            currentProgress: currentProgressValue,
            isUnlocked: true,
            unlockedAt: DateTime.now(),
            isNew: true,
          );
          newlyUnlocked.add(achievement);
          _recentlyUnlocked.add(achievement.id);
        } else {
          // Atualiza progresso
          achievements[achievement.id] = progress.copyWith(
            currentProgress: currentProgressValue,
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
    Map<String, AchievementProgress> achievements, // progresso atual
    List<Achievement> newlyUnlocked, // lista para adicionar novas desbloqueadas
  ) async {
    if (_userProfile == null) return;

    // Semana Impecável (um hábito diário com streak de 7 dias)
    final perfectWeekDailyAchievement = AchievementDefinitions.getById('perfect_week');
    if (perfectWeekDailyAchievement != null &&
        perfectWeekDailyAchievement.specialCondition == 'perfect_week_daily_habit') {
      final progress = achievements[perfectWeekDailyAchievement.id];
      if (progress != null && !progress.isUnlocked) {
        int maxStreakForThis = 0;
        bool achieved = false;
        for (final habit in habits) {
          if (habit.frequency == HabitFrequency.daily && habit.streak >= perfectWeekDailyAchievement.requirement) {
            achieved = true;
            if (habit.streak > maxStreakForThis) maxStreakForThis = habit.streak;
          } else if (habit.frequency == HabitFrequency.daily && habit.streak > maxStreakForThis) {
             maxStreakForThis = habit.streak;
          }
        }
        if (achieved) {
          achievements[perfectWeekDailyAchievement.id] = progress.copyWith(
            currentProgress: maxStreakForThis, // Usa o maior streak que ativou ou o requirement
            isUnlocked: true,
            unlockedAt: DateTime.now(),
            isNew: true,
          );
          newlyUnlocked.add(perfectWeekDailyAchievement);
          _recentlyUnlocked.add(perfectWeekDailyAchievement.id);
        } else if (maxStreakForThis > progress.currentProgress) {
           achievements[perfectWeekDailyAchievement.id] = progress.copyWith(currentProgress: maxStreakForThis);
        }
      }
    }

    // Mês Impecável (um hábito diário com streak de 30 dias)
    final perfectMonthDailyAchievement = AchievementDefinitions.getById('perfect_month');
    if (perfectMonthDailyAchievement != null &&
        perfectMonthDailyAchievement.specialCondition == 'perfect_month_daily_habit') {
      final progress = achievements[perfectMonthDailyAchievement.id];
      if (progress != null && !progress.isUnlocked) {
         int maxStreakForThis = 0;
         bool achieved = false;
        for (final habit in habits) {
          if (habit.frequency == HabitFrequency.daily && habit.streak >= perfectMonthDailyAchievement.requirement) {
            achieved = true;
            if (habit.streak > maxStreakForThis) maxStreakForThis = habit.streak;
          } else if (habit.frequency == HabitFrequency.daily && habit.streak > maxStreakForThis) {
             maxStreakForThis = habit.streak;
          }
        }
         if (achieved) {
          achievements[perfectMonthDailyAchievement.id] = progress.copyWith(
            currentProgress: maxStreakForThis,
          isUnlocked: true,
          unlockedAt: DateTime.now(),
          isNew: true,
        );
        newlyUnlocked.add(perfectMonthDailyAchievement);
        _recentlyUnlocked.add(perfectMonthDailyAchievement.id);
        }
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
