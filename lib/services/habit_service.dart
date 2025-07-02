import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/models/habit.dart';
import 'package:uuid/uuid.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:myapp/services/auth_strategy.dart';
import 'package:myapp/utils/logger.dart';

class HabitService extends ChangeNotifier {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final NotificationService notificationService;
  final AchievementService achievementService;
  final Uuid _uuid = const Uuid();

  HabitService({
    required this.firestore,
    required this.auth,
    required this.notificationService,
    required this.achievementService,
  });

  String? get _userId => auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _habitsCollection {
    if (_userId == null) {
      throw Exception("User not authenticated to access habits.");
    }
    return firestore.collection('users').doc(_userId).collection('habits');
  }

  // Getter para acessar a lista de hábitos (agora busca do Firestore)
  Stream<List<Habit>> getHabits() {
    if (_userId == null) return Stream.value([]);
    return _habitsCollection.orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Habit.fromMap(doc.data())).toList();
    });
  }

  Future<List<Habit>> getAllHabits() async {
    if (_userId == null) return [];
    final snapshot = await _habitsCollection.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => Habit.fromMap(doc.data())).toList();
  }

  Future<String> addHabit(Habit habit) async {
    Logger.debug('=== HabitService.addHabit INICIADO ===');
    
    if (_userId == null) {
      Logger.error("User not authenticated when trying to add habit");
      throw Exception("User not authenticated.");
    }
    
    Logger.debug('User ID confirmado: $_userId');
    
    // Verificar limites do trial para usuários anônimos
    final currentUser = auth.currentUser;
    if (currentUser != null && currentUser.isAnonymous) {
      final canCreate = await AuthStrategy.canCreateHabitInTrial();
      if (!canCreate) {
        final trialStatus = await AuthStrategy.getTrialStatus();
        if (trialStatus.isExpired) {
          throw TrialExpiredException('Período de teste expirou. Faça upgrade para continuar criando hábitos.');
        } else {
          throw HabitLimitException('Limite de ${trialStatus.maxHabits} hábitos atingido no período de teste.');
        }
      }
    }
    
    // Garantir que o hábito tenha um ID válido
    final habitId = habit.id.isEmpty ? _uuid.v4() : habit.id;
    Logger.debug('Habit ID: $habitId');
    
    // Criar hábito com todos os campos obrigatórios
    final now = DateTime.now();
    final habitWithUser = habit.copyWith(
      id: habitId,
      userId: _userId,
      createdAt: habit.createdAt ?? now,
      updatedAt: now,
      // Garantir valores padrão para campos obrigatórios
      completionHistory: habit.completionHistory ?? {},
      dailyProgress: habit.dailyProgress ?? {},
      streak: habit.streak ?? 0,
      longestStreak: habit.longestStreak ?? 0,
      totalCompletions: habit.totalCompletions ?? 0,
    );
    
    Logger.debug('Hábito preparado para salvar:');
    Logger.debug('- Title: ${habitWithUser.title}');
    Logger.debug('- Category: ${habitWithUser.category}');
    Logger.debug('- UserId: ${habitWithUser.userId}');
    
    try {
      Logger.info('Salvando hábito no Firestore...');
      Logger.debug('Collection path: users/$_userId/habits');
      Logger.debug('Document ID: $habitId');
      
      // Usar set ao invés de add para garantir que temos controle sobre o ID
      await _habitsCollection.doc(habitId).set(habitWithUser.toMap());
      
      Logger.info('✅ Hábito salvo no Firestore com sucesso!');
      Logger.info('Habit added successfully: ${habitWithUser.title}');
      
      // Agendar notificação se habilitada
      if (habitWithUser.notificationsEnabled && habitWithUser.reminderTime != null) {
        try {
          Logger.debug('Agendando notificação...');
          await notificationService.scheduleHabitReminder(habitWithUser);
          Logger.info('Reminder scheduled for habit: ${habitWithUser.title}');
        } catch (e) {
          Logger.error('Error scheduling reminder: $e');
          // Não falhar a criação do hábito por causa de erro na notificação
        }
      }
      
      // Verificar conquistas
      try {
        Logger.debug('Verificando conquistas...');
        final allHabits = await getAllHabits();
        await achievementService.checkAchievements(allHabits);
      } catch (e) {
        Logger.error('Error checking achievements: $e');
        // Não falhar a criação do hábito por causa de erro nas conquistas
      }

      // Incrementar contador de hábitos do trial para usuários anônimos
      final currentUser = auth.currentUser;
      if (currentUser != null && currentUser.isAnonymous) {
        await AuthStrategy.incrementTrialHabitsCount();
        Logger.debug('Trial habits count incremented');
      }

      notifyListeners();
      Logger.debug('=== HabitService.addHabit CONCLUÍDO COM SUCESSO ===');
      return habitId;
    } catch (e, s) {
      Logger.error('=== ERRO NO FIRESTORE ===');
      Logger.error('Error adding habit to Firestore: $e', e, s);
      Logger.error('Tipo do erro: ${e.runtimeType}');
      throw Exception('Failed to add habit: ${e.toString()}');
    }
  }

  Future<Habit?> getHabitById(String id) async {
    if (_userId == null) return null;
    try {
      final doc = await _habitsCollection.doc(id).get();
      if (doc.exists) {
        return Habit.fromMap(doc.data()!);
      }
      return null;
    } catch (e, s) {
      Logger.error('Error fetching habit by ID $id: $e', e, s);
      return null;
    }
  }

  Future<List<Habit>> getHabitsByCategory(String categoryName) async {
    if (_userId == null) return [];
    try {
      final snapshot = await _habitsCollection
          .where('category', isEqualTo: categoryName)
          .get();
      return snapshot.docs.map((doc) => Habit.fromMap(doc.data())).toList();
    } catch (e, s) {
      Logger.error('Error fetching habits by category $categoryName: $e', e, s);
      return [];
    }
  }

  Future<void> updateHabit(Habit habit) async {
    if (_userId == null) {
      Logger.error("User not authenticated when trying to update habit");
      throw Exception("User not authenticated.");
    }
    
    if (habit.userId != _userId && habit.userId != null) {
      Logger.error("User not authorized to update habit: ${habit.id}");
      throw Exception("User not authorized to update this habit.");
    }

    final habitToUpdate = habit.copyWith(updatedAt: DateTime.now());
    
    try {
      Logger.info('Updating habit: ${habitToUpdate.id}');
      
      await _habitsCollection.doc(habitToUpdate.id).update(habitToUpdate.toMap());
      
      Logger.info('Habit updated successfully: ${habitToUpdate.title}');

      // Cancelar notificações antigas e reagendar se necessário
      try {
        await notificationService.cancelHabitReminder(habit);
        if (habitToUpdate.notificationsEnabled && habitToUpdate.reminderTime != null) {
          await notificationService.scheduleHabitReminder(habitToUpdate);
          Logger.info('Reminder rescheduled for habit: ${habitToUpdate.title}');
        }
      } catch (e) {
        Logger.error('Error managing reminders: $e');
        // Não falhar a atualização por causa de erro nas notificações
      }
      
      notifyListeners();
    } catch (e, s) {
      Logger.error('Error updating habit ${habit.id}: $e', e, s);
      throw Exception('Failed to update habit: ${e.toString()}');
    }
  }

  Future<void> deleteHabit(String id) async {
    if (_userId == null) {
      Logger.error("User not authenticated when trying to delete habit");
      throw Exception("User not authenticated.");
    }
    
    try {
      Logger.info('Deleting habit: $id');
      
      final habitToDelete = await getHabitById(id);
      if (habitToDelete != null) {
        // Cancelar notificações
        try {
          await notificationService.cancelHabitReminder(habitToDelete);
        } catch (e) {
          Logger.error('Error canceling reminder: $e');
          // Continuar com a exclusão mesmo se falhar ao cancelar notificação
        }
      }
      
      await _habitsCollection.doc(id).delete();
      Logger.info('Habit deleted successfully: $id');

      // Verificar conquistas
      try {
        final allHabits = await getAllHabits();
        await achievementService.checkAchievements(allHabits);
      } catch (e) {
        Logger.error('Error checking achievements after delete: $e');
      }

      notifyListeners();
    } catch (e, s) {
      Logger.error('Error deleting habit $id: $e', e, s);
      throw Exception('Failed to delete habit: ${e.toString()}');
    }
  }

  Future<void> markHabitCompletion(String habitId, DateTime date, bool completed) async {
    if (_userId == null) {
      Logger.error("User not authenticated when trying to mark completion");
      throw Exception("User not authenticated.");
    }
    
    final habit = await getHabitById(habitId);
    if (habit == null) {
      Logger.warning('Habit $habitId not found for marking completion.');
      return;
    }
    
    try {
      final dateOnly = DateTime(date.year, date.month, date.day);
      Habit updatedHabit;

      if (completed) {
        // Marcar como concluído
        final newCompletionHistory = Map<DateTime, bool>.from(habit.completionHistory);
        newCompletionHistory[dateOnly] = true;

        // Atualizar dailyProgress
        final newDailyProgress = Map<DateTime, HabitDailyProgress>.from(habit.dailyProgress);
        newDailyProgress[dateOnly] = (newDailyProgress[dateOnly] ?? HabitDailyProgress(date: dateOnly))
            .copyWith(isCompleted: true);

        updatedHabit = habit.copyWith(
          completionHistory: newCompletionHistory,
          dailyProgress: newDailyProgress,
          updatedAt: DateTime.now()
        );
        updatedHabit.totalCompletions = newCompletionHistory.values.where((c) => c).length;
        updatedHabit.updateStreak();

      } else {
        // Marcar como não concluído
        final newCompletionHistory = Map<DateTime, bool>.from(habit.completionHistory);
        newCompletionHistory.remove(dateOnly); // Remover ao invés de marcar como false
        
        final newDailyProgress = Map<DateTime, HabitDailyProgress>.from(habit.dailyProgress);
        if (newDailyProgress.containsKey(dateOnly)) {
          newDailyProgress[dateOnly] = newDailyProgress[dateOnly]!.copyWith(isCompleted: false);
        }
        
        updatedHabit = habit.copyWith(
          completionHistory: newCompletionHistory,
          dailyProgress: newDailyProgress,
          updatedAt: DateTime.now()
        );
        updatedHabit.totalCompletions = newCompletionHistory.values.where((c) => c).length;
        updatedHabit.updateStreak();
      }
      
      await updateHabit(updatedHabit);
      Logger.info('Habit $habitId completion for $date marked as $completed');

      // Verificar conquistas
      try {
        final allHabits = await getAllHabits();
        await achievementService.checkAchievements(allHabits);
      } catch (e) {
        Logger.error('Error checking achievements after completion: $e');
      }
      
    } catch (e, s) {
      Logger.error('Error marking habit completion: $e', e, s);
      throw Exception('Failed to mark habit completion: ${e.toString()}');
    }
  }
  
  Future<void> resetHabitProgress(String habitId) async {
    if (_userId == null) {
      Logger.error("User not authenticated when trying to reset progress");
      throw Exception("User not authenticated.");
    }
    
    final habit = await getHabitById(habitId);
    if (habit == null) {
      Logger.warning('Habit $habitId not found for progress reset.');
      return;
    }
    
    try {
      final resetHabit = habit.copyWith(
        completionHistory: {},
        dailyProgress: {},
        streak: 0,
        totalCompletions: 0,
        updatedAt: DateTime.now(),
      );
      
      await updateHabit(resetHabit);
      Logger.info('Habit progress reset for: ${habit.title}');

      // Verificar conquistas
      try {
        final allHabits = await getAllHabits();
        await achievementService.checkAchievements(allHabits);
      } catch (e) {
        Logger.error('Error checking achievements after reset: $e');
      }
      
    } catch (e, s) {
      Logger.error('Error resetting habit progress: $e', e, s);
      throw Exception('Failed to reset habit progress: ${e.toString()}');
    }
  }
}
