import 'package:flutter/material.dart';
import 'package:myapp/models/habit.dart'; 
import 'package:uuid/uuid.dart';
import 'package:myapp/services/notifications/smart_notification_service.dart';
import 'package:myapp/services/notifications/behavior_analyzer.dart';

class HabitService extends ChangeNotifier {
  final List<Habit> _habits = [];
  final _uuid = const Uuid();
  final _notificationService = SmartNotificationService();
  final _behaviorAnalyzer = BehaviorAnalyzer();
  
  // Getter para acessar a lista de hábitos
  List<Habit> get habits => List<Habit>.from(_habits);

  Future<List<Habit>> getHabits() async {
    return List<Habit>.from(_habits);
  }

  // Método síncrono para uso com Consumer
  List<Habit> getHabitsSync() {
    return List<Habit>.from(_habits);
  }
  
  // Método para obter todos os hábitos (alias para getHabits)
  Future<List<Habit>> getAllHabits() async {
    return getHabits();
  }

  Future<void> addHabit({
    required String title,
    required String categoryName,
    required IconData categoryIcon,
    required Color categoryColor,
    required HabitFrequency frequency, 
    required HabitTrackingType trackingType, 
    required DateTime startDate, 
    List<int>? daysOfWeek,
    List<int>? daysOfMonth, // Added daysOfMonth
    List<DateTime>? specificYearDates, // Added specificYearDates
    int? timesPerPeriod,
    String? periodType,
    int? repeatEveryDays,
    bool? isFlexible,
    bool? alternateDays,
    DateTime? targetDate,
    TimeOfDay? reminderTime,
    bool notificationsEnabled = false,
    String priority = 'Normal', 
    String? description,
  }) async {
    final newHabit = Habit(
      id: _uuid.v4(),
      title: title,
      description: description,
      category: categoryName,
      icon: categoryIcon,
      color: categoryColor,
      frequency: frequency, 
      trackingType: trackingType, 
      daysOfWeek: daysOfWeek,
      // Pass daysOfMonth to Habit constructor (ensure Habit model is updated)
      daysOfMonth: daysOfMonth,
      specificYearDates: specificYearDates, // Pass specificYearDates to Habit constructor
      timesPerPeriod: timesPerPeriod,
      periodType: periodType,
      repeatEveryDays: repeatEveryDays,
      isFlexible: isFlexible,
      alternateDays: alternateDays,
      reminderTime: reminderTime,
      notificationsEnabled: notificationsEnabled,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      streak: 0,
      longestStreak: 0,
      totalCompletions: 0,
      completionHistory: {},
      dailyProgress: {}, 
      startDate: startDate, 
      targetDate: targetDate,
      priority: priority, 
    );

    _habits.add(newHabit);
    notifyListeners(); // Notifica as telas que escutam mudanças
    
    // Agendar notificações inteligentes se habilitadas
    if (notificationsEnabled) {
      await _notificationService.scheduleSmartNotifications(newHabit);
      debugPrint('Smart notifications scheduled for: ${newHabit.title}');
    }
    
    debugPrint('Habit added: ${newHabit.title}, ID: ${newHabit.id}, Tracking: ${newHabit.trackingType}, Freq: ${newHabit.frequency}');
    if (newHabit.daysOfWeek != null) {
      debugPrint('Days of Week: ${newHabit.daysOfWeek!.join(', ')}');
    }
    if (newHabit.daysOfMonth != null) {
      debugPrint('Days of Month: ${newHabit.daysOfMonth!.join(', ')}');
    }
    debugPrint('Total habits: ${_habits.length}');
  }

  Future<Habit?> getHabitById(String id) async {
    try {
      return _habits.firstWhere((habit) => habit.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateHabit(Habit habitToUpdate) async {
    final index = _habits.indexWhere((h) => h.id == habitToUpdate.id);
    if (index != -1) {
      _habits[index] = habitToUpdate.copyWith(updatedAt: DateTime.now());
      notifyListeners(); // Notifica as telas que escutam mudanças
      debugPrint('Habit updated: ${habitToUpdate.title}');
    } else {
      debugPrint('Habit with id ${habitToUpdate.id} not found for update.');
    }
  }

  Future<void> deleteHabit(String id) async {
    final initialLength = _habits.length;
    _habits.removeWhere((habit) => habit.id == id);
    if (_habits.length < initialLength) {
      notifyListeners(); // Notifica as telas que escutam mudanças
      debugPrint('Habit deleted: $id');
    } else {
      debugPrint('Habit with id $id not found for deletion.');
    }
  }

  Future<void> markHabitCompletion(String habitId, DateTime date, bool completed) async {
    final habit = await getHabitById(habitId);
    if (habit != null) {
      habit.recordProgress(date, isCompleted: completed); 
      notifyListeners(); // Notifica as telas que escutam mudanças
      
      // Registrar comportamento para análise
      if (completed) {
        await _behaviorAnalyzer.recordCompletion(
          habitId: habitId,
          timestamp: DateTime.now(),
        );
        
        // Re-analisar e ajustar notificações periodicamente
        if (_shouldReanalyze()) {
          await _reanalyzeAndAdjustNotifications();
        }
      }
      
      debugPrint('Habit $habitId completion for $date marked as $completed');
    } else {
       debugPrint('Habit $habitId not found for marking completion.');
    }
  }
  
  // Verifica se deve re-analisar padrões
  bool _shouldReanalyze() {
    final completions = getTotalCompletionsThisWeek();
    return completions % 7 == 0 || DateTime.now().weekday == DateTime.sunday;
  }
  
  // Re-analisa padrões e ajusta notificações
  Future<void> _reanalyzeAndAdjustNotifications() async {
    final analysis = await _behaviorAnalyzer.analyzeUserBehavior(_habits);
    
    for (final habit in _habits) {
      if (habit.notificationsEnabled) {
        final optimalTimes = await _behaviorAnalyzer.predictOptimalTimes(habit);
        await _notificationService.scheduleSmartNotifications(habit, customTimes: optimalTimes);
      }
    }
  }
  
  // Obtém total de conclusões esta semana
  int getTotalCompletionsThisWeek() {
    int total = 0;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    for (final habit in _habits) {
      for (final entry in habit.completionHistory.entries) {
        if (entry.key.isAfter(startOfWeek) && entry.value) {
          total++;
        }
      }
    }
    
    return total;
  }
  
  // Reinicia o progresso de um hábito
  Future<void> resetHabitProgress(String habitId) async {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index != -1) {
      final habit = _habits[index];
      
      // Limpar histórico de conclusões
      habit.completionHistory.clear();
      habit.dailyProgress.clear();
      
      // Resetar estatísticas
      habit.streak = 0;
      habit.longestStreak = 0;
      habit.totalCompletions = 0;
      
      // Criar uma nova instância do hábito com updatedAt atualizado
      _habits[index] = habit.copyWith(
        updatedAt: DateTime.now(),
        streak: 0,
        longestStreak: 0,
        totalCompletions: 0,
        completionHistory: {},
        dailyProgress: {},
      );
      
      notifyListeners(); // Notifica as telas que escutam mudanças
      debugPrint('Habit progress reset for: ${habit.title}');
    } else {
      debugPrint('Habit $habitId not found for progress reset.');
    }
  }
}
