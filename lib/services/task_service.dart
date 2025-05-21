import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // Import for kDebugMode
import 'package:myapp/models/task.dart'; // Import the new Task model

/// Service for handling task data storage and retrieval.
class TaskService {
  /// Firestore instance.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Firebase Auth instance.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Gets the current user ID.
  String? get _userId => _auth.currentUser?.uid;

  /// Gets the collection reference for tasks.
  CollectionReference get _tasksCollection =>
      _firestore.collection('users').doc(_userId).collection('tasks');

  /// Fetches all tasks for the current user.
  Future<List<Task>> getTasks() async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      final snapshot = await _tasksCollection.get();
      final tasks = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Task.fromMap({...data, 'id': doc.id});
      }).toList();

      if (kDebugMode) {
        print('[TaskService] getTasks: Fetched ${tasks.length} tasks.');
        for (var task in tasks) {
          print('[TaskService] getTasks: Task ID: ${task.id}, Title: ${task.title}');
        }
      }
      return tasks;
    } catch (e) {
      if (kDebugMode) {
        print('[TaskService] Error fetching tasks: $e');
      }
      return [];
    }
  }

  /// Fetches a single task by ID.
  Future<Task?> getTask(String taskId) async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      final doc = await _tasksCollection.doc(taskId).get();
      if (!doc.exists) {
        return null;
      }

      final data = doc.data() as Map<String, dynamic>;
      return Task.fromMap({...data, 'id': doc.id});
    } catch (e) {
      if (kDebugMode) {
        print('[TaskService] Error fetching task: $e');
      }
      return null;
    }
  }

  /// Adds a new task.
  Future<String?> addTask(Task task) async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      if (kDebugMode) {
        print('[TaskService] addTask: Adding task: ${task.toMap()}');
      }

      final docRef = await _tasksCollection.add(task.toMap());

      if (kDebugMode) {
        print('[TaskService] addTask: Task added with ID: ${docRef.id}');
      }
      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        print('[TaskService] Error adding task: $e');
      }
      return null;
    }
  }

  /// Updates an existing task.
  Future<bool> updateTask(Task task) async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      await _tasksCollection.doc(task.id).update(task.toMap());
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('[TaskService] Error updating task: $e');
      }
      return false;
    }
  }

  /// Deletes a task.
  Future<bool> deleteTask(String taskId) async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      await _tasksCollection.doc(taskId).delete();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('[TaskService] Error deleting task: $e');
      }
      return false;
    }
  }

  /// Marks a task as completed or not completed for the given date.
  Future<bool> markTaskCompletion(String taskId, DateTime date, bool completed) async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      final task = await getTask(taskId);
      if (task == null) {
        return false;
      }

      final dateOnly = DateTime(date.year, date.month, date.day);
      final updatedCompletionHistory = Map<DateTime, bool>.from(task.completionHistory);
      updatedCompletionHistory[dateOnly] = completed;

      final updatedTask = task.copyWith(
        completionHistory: updatedCompletionHistory,
        updatedAt: DateTime.now(),
      );

      return await updateTask(updatedTask);
    } catch (e) {
      if (kDebugMode) {
        print('[TaskService] Error marking task completion: $e');
      }
      return false;
    }
  }

  /// Gets tasks due today.
  Future<List<Task>> getTasksDueToday() async {
    try {
      final tasks = await getTasks();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final tasksDueToday = tasks.where((task) {
        if (task.dueDate == null) {
          return false; // Tasks without a due date are not "due today"
        }
        final taskDueDate = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
        final isDueToday = taskDueDate.isAtSameMomentAs(today);
        final isNotCompletedToday = !task.isCompletedToday();
        if (kDebugMode) {
          print('[TaskService] getTasksDueToday: Task: ${task.title}, DueDate: ${task.dueDate}, isDueToday: $isDueToday, isNotCompletedToday: $isNotCompletedToday');
        }
        return isDueToday && isNotCompletedToday;
      }).toList();
      if (kDebugMode) {
        print('[TaskService] getTasksDueToday: Tasks due today count: ${tasksDueToday.length}');
      }
      return tasksDueToday;
    } catch (e) {
      if (kDebugMode) {
        print('[TaskService] Error fetching tasks due today: $e');
      }
      return [];
    }
  }
}