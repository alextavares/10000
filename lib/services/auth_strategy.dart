import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/utils/logger.dart';

/// Estratégia de autenticação para produção
/// Implementa "Try First, Register Later"
class AuthStrategy {
  static const String _trialStartKey = 'trial_start_date';
  static const String _trialUsedKey = 'trial_used';
  static const String _habitsCountKey = 'local_habits_count';
  static const String _trialCompletedKey = 'trial_completed';
  static const int _maxTrialDays = 7;
  static const int _maxTrialHabits = 3;

  /// Verifica se o usuário está em período trial
  static Future<bool> isInTrialPeriod() async {
    final prefs = await SharedPreferences.getInstance();
    final trialStartString = prefs.getString(_trialStartKey);
    
    if (trialStartString == null) {
      // Primeira vez - iniciar trial
      await _startTrial();
      return true;
    }
    
    final trialStart = DateTime.parse(trialStartString);
    final daysSinceStart = DateTime.now().difference(trialStart).inDays;
    
    return daysSinceStart < _maxTrialDays;
  }

  /// Inicia o período trial
  static Future<void> _startTrial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_trialStartKey, DateTime.now().toIso8601String());
    await prefs.setBool(_trialUsedKey, true);
    Logger.info('Trial period started');
  }

  /// Verifica se pode criar mais hábitos no trial
  static Future<bool> canCreateHabitInTrial() async {
    if (!await isInTrialPeriod()) return false;
    
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_habitsCountKey) ?? 0;
    
    return currentCount < _maxTrialHabits;
  }

  /// Incrementa contador de hábitos no trial
  static Future<void> incrementTrialHabitsCount() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_habitsCountKey) ?? 0;
    await prefs.setInt(_habitsCountKey, currentCount + 1);
  }

  /// Quantos dias restam no trial
  static Future<int> trialDaysRemaining() async {
    final prefs = await SharedPreferences.getInstance();
    final trialStartString = prefs.getString(_trialStartKey);
    
    if (trialStartString == null) return _maxTrialDays;
    
    final trialStart = DateTime.parse(trialStartString);
    final daysPassed = DateTime.now().difference(trialStart).inDays;
    
    return (_maxTrialDays - daysPassed).clamp(0, _maxTrialDays);
  }

  /// Quantos hábitos ainda pode criar no trial
  static Future<int> trialHabitsRemaining() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_habitsCountKey) ?? 0;
    
    return (_maxTrialHabits - currentCount).clamp(0, _maxTrialHabits);
  }

  /// Limpa dados do trial (quando usuário se registra)
  static Future<void> clearTrialData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_trialStartKey);
    await prefs.remove(_trialUsedKey);
    await prefs.remove(_habitsCountKey);
    Logger.info('Trial data cleared - user registered');
  }

  /// Verifica se trial expirou
  static Future<bool> hasTrialExpired() async {
    final isInTrial = await isInTrialPeriod();
    final prefs = await SharedPreferences.getInstance();
    final hasUsedTrial = prefs.getBool(_trialUsedKey) ?? false;
    
    return hasUsedTrial && !isInTrial;
  }

  /// Marca trial como completado (usuário viu tela de upgrade)
  static Future<void> markTrialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_trialCompletedKey, true);
  }

  /// Verifica se deve mostrar tela de upgrade
  static Future<bool> shouldShowUpgrade() async {
    final hasExpired = await hasTrialExpired();
    final prefs = await SharedPreferences.getInstance();
    final hasCompleted = prefs.getBool(_trialCompletedKey) ?? false;
    
    return hasExpired && !hasCompleted;
  }

  /// Obtém status detalhado do trial
  static Future<TrialStatus> getTrialStatus() async {
    final isInTrial = await isInTrialPeriod();
    final hasExpired = await hasTrialExpired();
    final daysRemaining = await trialDaysRemaining();
    final habitsRemaining = await trialHabitsRemaining();
    
    return TrialStatus(
      isActive: isInTrial,
      hasExpired: hasExpired,
      daysRemaining: daysRemaining,
      habitsRemaining: habitsRemaining,
      maxHabits: _maxTrialHabits,
      maxDays: _maxTrialDays,
    );
  }

  /// Método para testing - reset trial
  static Future<void> resetTrialForTesting() async {
    if (kDebugMode) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_trialStartKey);
      await prefs.remove(_trialUsedKey);
      await prefs.remove(_habitsCountKey);
      await prefs.remove(_trialCompletedKey);
      Logger.debug('Trial reset for testing');
    }
  }
}

/// Status detalhado do trial
class TrialStatus {
  final bool isActive;
  final bool hasExpired;
  final int daysRemaining;
  final int habitsRemaining;
  final int maxHabits;
  final int maxDays;

  TrialStatus({
    required this.isActive,
    required this.hasExpired,
    required this.daysRemaining,
    required this.habitsRemaining,
    required this.maxHabits,
    required this.maxDays,
  });

  bool get canCreateHabits => isActive && habitsRemaining > 0;
  bool get isExpired => !isActive && hasExpired;
  double get progressPercentage => 1 - (daysRemaining / maxDays);

  @override
  String toString() {
    return 'TrialStatus(active: $isActive, expired: $hasExpired, days: $daysRemaining, habits: $habitsRemaining)';
  }
}
