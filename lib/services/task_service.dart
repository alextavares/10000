import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // Import for kDebugMode and ChangeNotifier
import 'package:myapp/models/task.dart'; // Import the new Task model
import 'package:myapp/utils/logger.dart';

/// Service for handling task data storage and retrieval.
class TaskService extends ChangeNotifier {
  /// Firestore instance.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Firebase Auth instance.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Gets the current user ID.
  String? get _userId => _auth.currentUser?.uid;

  /// Gets the collection reference for tasks.
  CollectionReference get _tasksCollection =>
      _firestore.collection('users').doc(_userId).collection('tasks');

  /// Local cache of tasks
  List<Task> _tasksCache = [];
  bool _isInitialized = false;

  TaskService() {
    // Initialize tasks on service creation
    _initializeTasks();
  }

  Future<void> _initializeTasks() async {
    await getTasks();
  }

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
        Logger.debug('[TaskService] getTasks: Fetched ${tasks.length} tasks.');
        for (var task in tasks) {
          Logger.debug('[TaskService] getTasks: Task ID: ${task.id}, Title: ${task.title}');
        }
      }
      
      // Update cache
      _tasksCache = tasks;
      _isInitialized = true;
      notifyListeners();
      
      return tasks;
    } catch (e, s) { // Added stack trace parameter 's'
      if (kDebugMode) {
        Logger.error('[TaskService] Error fetching tasks: $e');
        Logger.debug('[TaskService] Stack trace for fetching tasks: $s'); // Added stack trace
      }
      return _tasksCache; // Return cache on error
    }
  }

  /// Synchronous method to get tasks from cache
  List<Task> getTasksSync() {
    if (!_isInitialized) {
      // If not initialized, trigger async load
      getTasks();
    }
    return List<Task>.from(_tasksCache);
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
    } catch (e, s) { // Added stack trace parameter 's'
      if (kDebugMode) {
        Logger.error('[TaskService] Error fetching task: $e');
        Logger.debug('[TaskService] Stack trace for fetching task: $s'); // Added stack trace
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
        Logger.debug('[TaskService] addTask: Adding task: ${task.toMap()}');
      }

      final docRef = await _tasksCollection.add(task.toMap());

      if (kDebugMode) {
        Logger.debug('[TaskService] addTask: Task added with ID: ${docRef.id}');
      }
      
      // Update cache
      final newTask = task.copyWith(id: docRef.id);
      _tasksCache.add(newTask);
      notifyListeners();
      
      return docRef.id;
    } catch (e, s) { // MODIFIED: Added stack trace parameter 's'
      if (kDebugMode) {
        Logger.error('[TaskService] Error adding task: $e');
        Logger.debug('[TaskService] Stack trace for adding task: $s'); // MODIFIED: Added stack trace logging
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
      
      // Update cache
      final index = _tasksCache.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasksCache[index] = task;
        notifyListeners();
      }
      
      return true;
    } catch (e, s) { // Added stack trace parameter 's'
      if (kDebugMode) {
        Logger.error('[TaskService] Error updating task: $e');
        Logger.debug('[TaskService] Stack trace for updating task: $s'); // Added stack trace
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
      
      // Update cache
      _tasksCache.removeWhere((t) => t.id == taskId);
      notifyListeners();
      
      return true;
    } catch (e, s) { // Added stack trace parameter 's'
      if (kDebugMode) {
        Logger.error('[TaskService] Error deleting task: $e');
        Logger.debug('[TaskService] Stack trace for deleting task: $s'); // Added stack trace
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

      final result = await updateTask(updatedTask);
      // updateTask já chama notifyListeners()
      return result;
    } catch (e, s) { // Added stack trace parameter 's'
      if (kDebugMode) {
        Logger.error('[TaskService] Error marking task completion: $e');
        Logger.debug('[TaskService] Stack trace for marking task completion: $s'); // Added stack trace
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
          Logger.info('[TaskService] getTasksDueToday: Task: ${task.title}, DueDate: ${task.dueDate}, isDueToday: $isDueToday, isNotCompletedToday: $isNotCompletedToday');
        }
        return isDueToday && isNotCompletedToday;
      }).toList();
      if (kDebugMode) {
        Logger.debug('[TaskService] getTasksDueToday: Tasks due today count: ${tasksDueToday.length}');
      }
      return tasksDueToday;
    } catch (e, s) { // Added stack trace parameter 's'
      if (kDebugMode) {
        Logger.error('[TaskService] Error fetching tasks due today: $e');
        Logger.debug('[TaskService] Stack trace for fetching tasks due today: $s'); // Added stack trace
      }
      return [];
    }
  }
}