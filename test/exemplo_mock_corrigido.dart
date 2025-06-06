// Exemplo de como corrigir os mocks nos testes

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/models/task.dart';
import 'package:myapp/models/recurring_task.dart';
import 'package:myapp/services/habit_service.dart';
import 'package:myapp/services/task_service.dart';
import 'package:myapp/services/recurring_task_service.dart';

// Mock corrigido para HabitService
class MockHabitService extends ChangeNotifier with Mock implements HabitService {
  final List<Habit> _habits = [];
  
  @override
  List<Habit> getHabitsSync() {
    return _habits;
  }
  
  // Adicione outros métodos necessários aqui
  @override
  Future<List<Habit>> getHabits() async {
    return _habits;
  }
  
  @override
  Future<String?> addHabit(Habit habit) async {
    _habits.add(habit);
    notifyListeners();
    return habit.id;
  }
}

// Mock corrigido para TaskService
class MockTaskService extends ChangeNotifier with Mock implements TaskService {
  final List<Task> _tasks = [];
  
  @override
  List<Task> getTasksSync() {
    return _tasks;
  }
  
  @override
  Future<List<Task>> getTasks() async {
    return _tasks;
  }
  
  @override
  Future<String?> addTask(Task task) async {
    _tasks.add(task);
    notifyListeners();
    return task.id;
  }
  
  @override
  Future<bool> markTaskCompletion(String taskId, DateTime date, bool completed) async {
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      if (completed) {
        task.markCompleted(date);
      } else {
        task.markNotCompleted(date);
      }
      notifyListeners();
      return true;
    }
    return false;
  }
}

// Mock corrigido para RecurringTaskService
class MockRecurringTaskService extends ChangeNotifier with Mock implements RecurringTaskService {
  final List<RecurringTask> _recurringTasks = [];
  
  @override
  List<RecurringTask> getRecurringTasksSync() {
    return _recurringTasks;
  }
  
  @override
  Future<List<RecurringTask>> getRecurringTasks() async {
    return _recurringTasks;
  }
  
  @override
  Future<String?> addRecurringTask(RecurringTask task) async {
    _recurringTasks.add(task);
    notifyListeners();
    return task.id;
  }
}

// Exemplo de uso nos testes:
void main() {
  group('Exemplo de teste com mocks corrigidos', () {
    late MockHabitService mockHabitService;
    late MockTaskService mockTaskService;
    late MockRecurringTaskService mockRecurringTaskService;
    
    setUp(() {
      mockHabitService = MockHabitService();
      mockTaskService = MockTaskService();
      mockRecurringTaskService = MockRecurringTaskService();
    });
    
    test('Deve adicionar uma tarefa com sucesso', () async {
      final task = Task(
        id: 'test-1',
        title: 'Tarefa de Teste',
        type: TaskType.yesNo,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        notificationsEnabled: false,
        completionHistory: {},
        isCompleted: false,
      );
      
      final result = await mockTaskService.addTask(task);
      
      expect(result, equals('test-1'));
      expect(mockTaskService.getTasksSync().length, equals(1));
    });
  });
}
