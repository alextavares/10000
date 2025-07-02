import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myapp/models/habit.dart';
import 'package:uuid/uuid.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:myapp/services/achievement_service.dart'; // Importar AchievementService
import 'package:myapp/utils/logger.dart';

class HabitService extends ChangeNotifier {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final NotificationService notificationService;
  final AchievementService achievementService; // Injetar AchievementService
  final Uuid _uuid = const Uuid();

  HabitService({
    required this.firestore,
    required this.auth,
    required this.notificationService,
    required this.achievementService, // Adicionar ao construtor
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

  Future<List<Habit>> getAllHabits() async { // Usado por CategoryService e outros
    if (_userId == null) return [];
    final snapshot = await _habitsCollection.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => Habit.fromMap(doc.data())).toList();
  }


  Future<String> addHabit(Habit habit) async {
    if (_userId == null) throw Exception("User not authenticated.");
    
    final habitWithUser = habit.copyWith(userId: _userId, id: habit.id.isEmpty ? _uuid.v4() : habit.id);
    
    try {
      await _habitsCollection.doc(habitWithUser.id).set(habitWithUser.toMap());
      Logger.info('Habit added: ${habitWithUser.title}');
      if (habitWithUser.notificationsEnabled && habitWithUser.reminderTime != null) {
        await notificationService.scheduleHabitReminder(habitWithUser);
      }
      // Verificar conquistas após adicionar hábito
      // Precisamos da lista atual de hábitos para algumas conquistas (como Mestre das Categorias ou Pioneiro)
      final allHabits = await getAllHabits();
      await achievementService.checkAchievements(allHabits);

      notifyListeners();
      return habitWithUser.id;
    } catch (e, s) {
      Logger.error('Error adding habit: $e', e, s);
      rethrow;
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
    if (_userId == null) throw Exception("User not authenticated.");
    if (habit.userId != _userId && habit.userId != null) { // Permitir atualizar hábitos antigos sem userId
      throw Exception("User not authorized to update this habit.");
    }

    final habitToUpdate = habit.copyWith(updatedAt: DateTime.now());
    try {
      await _habitsCollection.doc(habitToUpdate.id).update(habitToUpdate.toMap());
      Logger.info('Habit updated: ${habitToUpdate.title}');

      // Cancelar notificações antigas e reagendar se necessário
      await notificationService.cancelHabitReminder(habit); // Usa o ID do hábito original
      if (habitToUpdate.notificationsEnabled && habitToUpdate.reminderTime != null) {
        await notificationService.scheduleHabitReminder(habitToUpdate);
      }
      notifyListeners();
    } catch (e, s) {
      Logger.error('Error updating habit ${habit.id}: $e', e, s);
      rethrow;
    }
  }

  Future<void> deleteHabit(String id) async {
    if (_userId == null) throw Exception("User not authenticated.");
    try {
      final habit = await getHabitById(id);
      final habitToDelete = await getHabitById(id);
      if (habitToDelete != null) {
        await notificationService.cancelHabitReminder(habitToDelete);
      }
      await _habitsCollection.doc(id).delete();
      Logger.info('Habit deleted: $id');

      // Verificar conquistas após deletar hábito (pode afetar contagens)
      final allHabits = await getAllHabits();
      await achievementService.checkAchievements(allHabits);

      notifyListeners();
    } catch (e, s) {
      Logger.error('Error deleting habit $id: $e', e, s);
      rethrow;
    }
  }

  Future<void> markHabitCompletion(String habitId, DateTime date, bool completed) async {
    if (_userId == null) throw Exception("User not authenticated.");
    final habit = await getHabitById(habitId);
    if (habit != null) {
      final dateOnly = DateTime(date.year, date.month, date.day);
      Habit updatedHabit;

      if (completed) {
        // Marcar como concluído
        final newCompletionHistory = Map<DateTime, bool>.from(habit.completionHistory);
        newCompletionHistory[dateOnly] = true;

        // Atualizar dailyProgress (simplificado, assumindo Sim/Não por enquanto para este exemplo)
        final newDailyProgress = Map<DateTime, HabitDailyProgress>.from(habit.dailyProgress);
        newDailyProgress[dateOnly] = (newDailyProgress[dateOnly] ?? HabitDailyProgress(date: dateOnly))
            .copyWith(isCompleted: true);

        updatedHabit = habit.copyWith(
            completionHistory: newCompletionHistory,
            dailyProgress: newDailyProgress,
            updatedAt: DateTime.now()
        );
        updatedHabit.totalCompletions = newCompletionHistory.values.where((c) => c).length; // Recalcula
        updatedHabit.updateStreak(); // Recalcula streak

      } else {
        // Marcar como não concluído
        final newCompletionHistory = Map<DateTime, bool>.from(habit.completionHistory);
        newCompletionHistory[dateOnly] = false;

        final newDailyProgress = Map<DateTime, HabitDailyProgress>.from(habit.dailyProgress);
        newDailyProgress[dateOnly] = (newDailyProgress[dateOnly] ?? HabitDailyProgress(date: dateOnly))
            .copyWith(isCompleted: false);
        
        updatedHabit = habit.copyWith(
            completionHistory: newCompletionHistory,
            dailyProgress: newDailyProgress,
            updatedAt: DateTime.now()
        );
        updatedHabit.totalCompletions = newCompletionHistory.values.where((c) => c).length; // Recalcula
        updatedHabit.updateStreak(); // Recalcula streak
      }
      
      await updateHabit(updatedHabit); // Salva o hábito atualizado (que também reagendará notificações)
      Logger.info('Habit $habitId completion for $date marked as $completed');

      // Verificar conquistas após marcar conclusão e atualizar streak
      final finalUpdatedHabit = await getHabitById(habitId); // Pega a versão mais recente com streak atualizado
      if (finalUpdatedHabit != null) {
        final allHabits = await getAllHabits();
        await achievementService.checkAchievements(allHabits);
        await achievementService.checkAchievements(allHabits);
      }

    } else {
       Logger.warning('Habit $habitId not found for marking completion.');
    }
  }
  
  Future<void> resetHabitProgress(String habitId) async {
    if (_userId == null) throw Exception("User not authenticated.");
    final habit = await getHabitById(habitId);
    if (habit != null) {
      final resetHabit = habit.copyWith(
        completionHistory: {},
        dailyProgress: {},
        streak: 0,
        // longestStreak: 0, // Decidido manter o longestStreak
        totalCompletions: 0,
        updatedAt: DateTime.now(),
      );
      await updateHabit(resetHabit); // Salva e reagenda notificações
      Logger.info('Habit progress reset for: ${habit.title}');

      // Verificar conquistas após resetar (pode afetar streaks, etc.)
      final allHabits = await getAllHabits();
      await achievementService.checkAchievements(allHabits);

    } else {
      Logger.warning('Habit $habitId not found for progress reset.');
    }
  }
}
