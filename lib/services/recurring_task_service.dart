import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:myapp/models/recurring_task.dart';

class RecurringTaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'recurring_tasks';

  /// Creates a new recurring task
  Future<bool> createRecurringTask(RecurringTask recurringTask) async {
    try {
      if (kDebugMode) {
        print('[RecurringTaskService] Creating recurring task: ${recurringTask.title}');
      }
      await _firestore.collection(_collection).doc(recurringTask.id).set(recurringTask.toMap());
      if (kDebugMode) {
        print('[RecurringTaskService] Recurring task created successfully: ${recurringTask.id}');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('[RecurringTaskService] Error creating recurring task: $e');
      }
      return false;
    }
  }

  /// Updates an existing recurring task
  Future<bool> updateRecurringTask(RecurringTask recurringTask) async {
    try {
      if (kDebugMode) {
        print('[RecurringTaskService] Updating recurring task: ${recurringTask.id}');
      }
      await _firestore.collection(_collection).doc(recurringTask.id).update(recurringTask.toMap());
      if (kDebugMode) {
        print('[RecurringTaskService] Recurring task updated successfully: ${recurringTask.id}');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('[RecurringTaskService] Error updating recurring task: $e');
      }
      return false;
    }
  }

  /// Deletes a recurring task
  Future<bool> deleteRecurringTask(String recurringTaskId) async {
    try {
      if (kDebugMode) {
        print('[RecurringTaskService] Deleting recurring task: $recurringTaskId');
      }
      await _firestore.collection(_collection).doc(recurringTaskId).delete();
      if (kDebugMode) {
        print('[RecurringTaskService] Recurring task deleted successfully: $recurringTaskId');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('[RecurringTaskService] Error deleting recurring task: $e');
      }
      return false;
    }
  }

  /// Gets all recurring tasks
  Future<List<RecurringTask>> getRecurringTasks() async {
    try {
      if (kDebugMode) {
        print('[RecurringTaskService] Fetching all recurring tasks');
      }
      final querySnapshot = await _firestore.collection(_collection).get();
      final recurringTasks = querySnapshot.docs
          .map((doc) => RecurringTask.fromMap(doc.data()))
          .toList();
      if (kDebugMode) {
        print('[RecurringTaskService] Fetched ${recurringTasks.length} recurring tasks');
      }
      return recurringTasks;
    } catch (e) {
      if (kDebugMode) {
        print('[RecurringTaskService] Error fetching recurring tasks: $e');
      }
      return [];
    }
  }

  /// Gets a specific recurring task by ID
  Future<RecurringTask?> getRecurringTask(String recurringTaskId) async {
    try {
      if (kDebugMode) {
        print('[RecurringTaskService] Fetching recurring task: $recurringTaskId');
      }
      final doc = await _firestore.collection(_collection).doc(recurringTaskId).get();
      if (doc.exists) {
        final recurringTask = RecurringTask.fromMap(doc.data()!);
        if (kDebugMode) {
          print('[RecurringTaskService] Recurring task found: ${recurringTask.title}');
        }
        return recurringTask;
      } else {
        if (kDebugMode) {
          print('[RecurringTaskService] Recurring task not found: $recurringTaskId');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('[RecurringTaskService] Error fetching recurring task: $e');
      }
      return null;
    }
  }

  /// Gets recurring tasks due today
  Future<List<RecurringTask>> getRecurringTasksDueToday() async {
    try {
      if (kDebugMode) {
        print('[RecurringTaskService] Fetching recurring tasks due today');
      }
      final allRecurringTasks = await getRecurringTasks();
      final dueToday = allRecurringTasks.where((task) => task.isDueToday()).toList();
      if (kDebugMode) {
        print('[RecurringTaskService] Found ${dueToday.length} recurring tasks due today');
      }
      return dueToday;
    } catch (e) {
      if (kDebugMode) {
        print('[RecurringTaskService] Error fetching recurring tasks due today: $e');
      }
      return [];
    }
  }

  /// Gets recurring tasks by category
  Future<List<RecurringTask>> getRecurringTasksByCategory(String category) async {
    try {
      if (kDebugMode) {
        print('[RecurringTaskService] Fetching recurring tasks for category: $category');
      }
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('category', isEqualTo: category)
          .get();
      final recurringTasks = querySnapshot.docs
          .map((doc) => RecurringTask.fromMap(doc.data()))
          .toList();
      if (kDebugMode) {
        print('[RecurringTaskService] Found ${recurringTasks.length} recurring tasks for category: $category');
      }
      return recurringTasks;
    } catch (e) {
      if (kDebugMode) {
        print('[RecurringTaskService] Error fetching recurring tasks by category: $e');
      }
      return [];
    }
  }

  /// Marks a recurring task as completed for a specific date
  Future<bool> markRecurringTaskCompletion(String recurringTaskId, DateTime date, bool completed) async {
    try {
      if (kDebugMode) {
        print('[RecurringTaskService] Marking recurring task completion: $recurringTaskId, date: $date, completed: $completed');
      }
      
      final recurringTask = await getRecurringTask(recurringTaskId);
      if (recurringTask == null) {
        if (kDebugMode) {
          print('[RecurringTaskService] Recurring task not found for completion marking: $recurringTaskId');
        }
        return false;
      }

      // Update completion history and progress
      if (completed) {
        recurringTask.markCompleted(date);
      } else {
        recurringTask.markNotCompleted(date);
      }

      // Record progress
      recurringTask.recordProgress(date, isCompleted: completed);

      // Update in Firestore
      await updateRecurringTask(recurringTask);
      
      if (kDebugMode) {
        print('[RecurringTaskService] Recurring task completion marked successfully');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('[RecurringTaskService] Error marking recurring task completion: $e');
      }
      return false;
    }
  }

  /// Records progress for a recurring task with subtasks
  Future<bool> recordRecurringTaskProgress(
    String recurringTaskId,
    DateTime date, {
    bool? isCompleted,
    List<RecurringTaskSubtask>? subtasks,
  }) async {
    try {
      if (kDebugMode) {
        print('[RecurringTaskService] Recording recurring task progress: $recurringTaskId');
      }
      
      final recurringTask = await getRecurringTask(recurringTaskId);
      if (recurringTask == null) {
        if (kDebugMode) {
          print('[RecurringTaskService] Recurring task not found for progress recording: $recurringTaskId');
        }
        return false;
      }

      // Record progress
      recurringTask.recordProgress(
        date,
        isCompleted: isCompleted,
        subtasks: subtasks,
      );

      // Update in Firestore
      await updateRecurringTask(recurringTask);
      
      if (kDebugMode) {
        print('[RecurringTaskService] Recurring task progress recorded successfully');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('[RecurringTaskService] Error recording recurring task progress: $e');
      }
      return false;
    }
  }

  /// Gets completion statistics for a recurring task
  Future<Map<String, dynamic>> getRecurringTaskStats(String recurringTaskId) async {
    try {
      if (kDebugMode) {
        print('[RecurringTaskService] Getting stats for recurring task: $recurringTaskId');
      }
      
      final recurringTask = await getRecurringTask(recurringTaskId);
      if (recurringTask == null) {
        return {};
      }

      return {
        'streak': recurringTask.streak,
        'longestStreak': recurringTask.longestStreak,
        'totalCompletions': recurringTask.totalCompletions,
        'completionRate': recurringTask.getCompletionRate(),
        'isCompletedToday': recurringTask.isCompletedToday(),
        'todaysCompletionPercentage': recurringTask.getTodaysCompletionPercentage(),
      };
    } catch (e) {
      if (kDebugMode) {
        print('[RecurringTaskService] Error getting recurring task stats: $e');
      }
      return {};
    }
  }

  /// Gets recurring tasks with completion status for a date range
  Future<Map<String, List<RecurringTask>>> getRecurringTasksForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      if (kDebugMode) {
        print('[RecurringTaskService] Getting recurring tasks for date range: $startDate to $endDate');
      }
      
      final allRecurringTasks = await getRecurringTasks();
      final Map<String, List<RecurringTask>> result = {};

      DateTime currentDate = startDate;
      while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
        final dateKey = currentDate.toIso8601String().split('T')[0];
        result[dateKey] = allRecurringTasks.where((task) => task.isDueToday(currentDate)).toList();
        currentDate = currentDate.add(const Duration(days: 1));
      }

      if (kDebugMode) {
        print('[RecurringTaskService] Retrieved recurring tasks for ${result.length} days');
      }
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('[RecurringTaskService] Error getting recurring tasks for date range: $e');
      }
      return {};
    }
  }

  /// Stream of recurring tasks for real-time updates
  Stream<List<RecurringTask>> getRecurringTasksStream() {
    try {
      if (kDebugMode) {
        print('[RecurringTaskService] Setting up recurring tasks stream');
      }
      return _firestore.collection(_collection).snapshots().map((snapshot) {
        final recurringTasks = snapshot.docs
            .map((doc) => RecurringTask.fromMap(doc.data()))
            .toList();
        if (kDebugMode) {
          print('[RecurringTaskService] Stream updated with ${recurringTasks.length} recurring tasks');
        }
        return recurringTasks;
      });
    } catch (e) {
      if (kDebugMode) {
        print('[RecurringTaskService] Error setting up recurring tasks stream: $e');
      }
      return Stream.value([]);
    }
  }

  /// Stream of recurring tasks due today for real-time updates
  Stream<List<RecurringTask>> getRecurringTasksDueTodayStream() {
    try {
      if (kDebugMode) {
        print('[RecurringTaskService] Setting up recurring tasks due today stream');
      }
      return getRecurringTasksStream().map((recurringTasks) {
        final dueToday = recurringTasks.where((task) => task.isDueToday()).toList();
        if (kDebugMode) {
          print('[RecurringTaskService] Stream updated with ${dueToday.length} recurring tasks due today');
        }
        return dueToday;
      });
    } catch (e) {
      if (kDebugMode) {
        print('[RecurringTaskService] Error setting up recurring tasks due today stream: $e');
      }
      return Stream.value([]);
    }
  }
}