import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/models/habit.dart';

/// Service for handling habit data storage and retrieval.
class HabitService {
  /// Firestore instance.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Firebase Auth instance.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Gets the current user ID.
  String? get _userId => _auth.currentUser?.uid;

  /// Gets the collection reference for habits.
  CollectionReference get _habitsCollection => 
      _firestore.collection('users').doc(_userId).collection('habits');

  /// Fetches all habits for the current user.
  Future<List<Habit>> getHabits() async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      final snapshot = await _habitsCollection.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Habit.fromMap({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      print('Error fetching habits: $e');
      return [];
    }
  }

  /// Fetches a single habit by ID.
  Future<Habit?> getHabit(String habitId) async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      final doc = await _habitsCollection.doc(habitId).get();
      if (!doc.exists) {
        return null;
      }

      final data = doc.data() as Map<String, dynamic>;
      return Habit.fromMap({...data, 'id': doc.id});
    } catch (e) {
      print('Error fetching habit: $e');
      return null;
    }
  }

  /// Adds a new habit.
  Future<String?> addHabit(Habit habit) async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      final docRef = await _habitsCollection.add(habit.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding habit: $e');
      return null;
    }
  }

  /// Updates an existing habit.
  Future<bool> updateHabit(Habit habit) async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      await _habitsCollection.doc(habit.id).update(habit.toMap());
      return true;
    } catch (e) {
      print('Error updating habit: $e');
      return false;
    }
  }

  /// Deletes a habit.
  Future<bool> deleteHabit(String habitId) async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      await _habitsCollection.doc(habitId).delete();
      return true;
    } catch (e) {
      print('Error deleting habit: $e');
      return false;
    }
  }

  /// Marks a habit as completed for the given date.
  Future<bool> markHabitCompleted(String habitId, DateTime date) async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      final habit = await getHabit(habitId);
      if (habit == null) {
        return false;
      }

      // Create a copy of the habit with updated completion history
      final dateOnly = DateTime(date.year, date.month, date.day);
      final updatedCompletionHistory = Map<DateTime, bool>.from(habit.completionHistory);
      updatedCompletionHistory[dateOnly] = true;

      final updatedHabit = habit.copyWith(
        completionHistory: updatedCompletionHistory,
        totalCompletions: habit.totalCompletions + 1,
        updatedAt: DateTime.now(),
      );

      // Update streak
      updatedHabit.updateStreak();

      return await updateHabit(updatedHabit);
    } catch (e) {
      print('Error marking habit as completed: $e');
      return false;
    }
  }

  /// Marks a habit as not completed for the given date.
  Future<bool> markHabitNotCompleted(String habitId, DateTime date) async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      final habit = await getHabit(habitId);
      if (habit == null) {
        return false;
      }

      // Create a copy of the habit with updated completion history
      final dateOnly = DateTime(date.year, date.month, date.day);
      final updatedCompletionHistory = Map<DateTime, bool>.from(habit.completionHistory);
      updatedCompletionHistory[dateOnly] = false;

      final updatedHabit = habit.copyWith(
        completionHistory: updatedCompletionHistory,
        totalCompletions: habit.totalCompletions > 0 ? habit.totalCompletions - 1 : 0,
        updatedAt: DateTime.now(),
      );

      // Update streak
      updatedHabit.updateStreak();

      return await updateHabit(updatedHabit);
    } catch (e) {
      print('Error marking habit as not completed: $e');
      return false;
    }
  }

  /// Gets habits due today.
  Future<List<Habit>> getHabitsDueToday() async {
    try {
      final habits = await getHabits();
      return habits.where((habit) => habit.isDueToday()).toList();
    } catch (e) {
      print('Error fetching habits due today: $e');
      return [];
    }
  }

  /// Gets habits by category.
  Future<List<Habit>> getHabitsByCategory(String category) async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      final snapshot = await _habitsCollection
          .where('category', isEqualTo: category)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Habit.fromMap({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      print('Error fetching habits by category: $e');
      return [];
    }
  }

  /// Gets all unique categories from the user's habits.
  Future<List<String>> getCategories() async {
    try {
      final habits = await getHabits();
      final categories = habits.map((habit) => habit.category).toSet().toList();
      return categories;
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  /// Gets the user's habit statistics.
  Future<Map<String, dynamic>> getHabitStatistics() async {
    try {
      final habits = await getHabits();
      
      if (habits.isEmpty) {
        return {
          'totalHabits': 0,
          'completedToday': 0,
          'averageCompletionRate': 0.0,
          'longestStreak': 0,
          'totalCompletions': 0,
        };
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      int completedToday = 0;
      int totalCompletions = 0;
      int longestStreak = 0;
      double totalCompletionRate = 0.0;

      for (final habit in habits) {
        if (habit.isCompletedToday()) {
          completedToday++;
        }
        
        totalCompletions += habit.totalCompletions;
        
        if (habit.longestStreak > longestStreak) {
          longestStreak = habit.longestStreak;
        }
        
        totalCompletionRate += habit.getCompletionRate();
      }

      final averageCompletionRate = totalCompletionRate / habits.length;

      return {
        'totalHabits': habits.length,
        'completedToday': completedToday,
        'averageCompletionRate': averageCompletionRate,
        'longestStreak': longestStreak,
        'totalCompletions': totalCompletions,
      };
    } catch (e) {
      print('Error calculating habit statistics: $e');
      return {
        'totalHabits': 0,
        'completedToday': 0,
        'averageCompletionRate': 0.0,
        'longestStreak': 0,
        'totalCompletions': 0,
      };
    }
  }
}
