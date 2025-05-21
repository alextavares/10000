import 'package:flutter/foundation.dart'; // Import for kDebugMode
import 'package:flutter/material.dart';
import 'package:myapp/models/task.dart';
import 'package:myapp/screens/task/add_task_screen.dart'; // Import AddTaskScreen
import 'package:myapp/services/service_provider.dart';
import 'package:myapp/widgets/task_card.dart'; // Import the new TaskCard

class TasksScreen extends StatefulWidget {
  final TabController tabController; // Accept TabController

  const TasksScreen({super.key, required this.tabController});

  @override
  State<TasksScreen> createState() => TasksScreenState();
}

class TasksScreenState extends State<TasksScreen> { // Made public
  late Future<List<Task>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _tasksFuture = Future.value([]); 
    if (kDebugMode) {
      print('[TasksScreen] initState: Initialized.');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (kDebugMode) {
      print('[TasksScreen] didChangeDependencies: Fetching tasks.');
    }
    _tasksFuture = _fetchTasks();
  }

  Future<List<Task>> _fetchTasks() async {
    if (kDebugMode) {
      print('[TasksScreen] _fetchTasks: Attempting to fetch tasks.');
    }
    final taskService = ServiceProvider.of(context).taskService;
    final tasks = await taskService.getTasks();
    if (kDebugMode) {
      print('[TasksScreen] _fetchTasks: Fetched ${tasks.length} tasks.');
    }
    return tasks;
  }

  void refreshTasks() { 
    if (kDebugMode) {
      print('[TasksScreen] refreshTasks: Refreshing tasks.');
    }
    setState(() {
      _tasksFuture = _fetchTasks();
    });
  }

  // Handler for editing a task
  void _handleEditTask(Task task) async {
    if (kDebugMode) {
      print('[TasksScreen] _handleEditTask: Editing task ID: ${task.id}');
    }
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(taskToEdit: task), // Pass the task to edit
      ),
    );
    if (result == true) {
      refreshTasks(); // Refresh if the task was updated
    }
  }

  // Handler for deleting a task
  void _handleDeleteTask(String taskId) async {
    if (kDebugMode) {
      print('[TasksScreen] _handleDeleteTask: Deleting task ID: $taskId');
    }
    final taskService = ServiceProvider.of(context).taskService;

    // Optional: Show a confirmation dialog
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      final success = await taskService.deleteTask(taskId);
      if (success) {
        refreshTasks();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete task')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('[TasksScreen] build: Building TasksScreen.');
    }
    return Container(
      color: Colors.black, 
      child: Stack(
        children: [
          TabBarView(
            controller: widget.tabController, 
            children: [
              _buildSimpleTasksView(),
              _buildEmptyTasksView(), 
            ],
          ),
          Positioned(
            left: 16,
            bottom: 76, 
            child: _buildPremiumButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleTasksView() {
    if (kDebugMode) {
      print('[TasksScreen] _buildSimpleTasksView: Building simple tasks view.');
    }
    return FutureBuilder<List<Task>>(
      future: _tasksFuture,
      builder: (context, snapshot) {
        if (kDebugMode) {
          print('[TasksScreen] FutureBuilder: Connection state: ${snapshot.connectionState}');
          if (snapshot.hasData) {
            print('[TasksScreen] FutureBuilder: Has data: ${snapshot.data!.length} tasks.');
          }
          if (snapshot.hasError) {
            print('[TasksScreen] FutureBuilder: Has error: ${snapshot.error}');
          }
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          if (kDebugMode) {
            print('[TasksScreen] FutureBuilder: No tasks found or data is empty.');
          }
          return _buildEmptyTasksView();
        } else {
          final tasks = snapshot.data!;
          if (kDebugMode) {
            print('[TasksScreen] FutureBuilder: Displaying ${tasks.length} tasks.');
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskCard(
                task: task,
                onToggleCompletion: (taskId, completed) {
                  if (kDebugMode) {
                    print('[TasksScreen] TaskCard: Toggling completion for task ID: $taskId to $completed');
                  }
                  ServiceProvider.of(context).taskService.markTaskCompletion(taskId, DateTime.now(), completed);
                  refreshTasks(); 
                },
                onEdit: () => _handleEditTask(task), // Pass edit handler
                onDelete: () => _handleDeleteTask(task.id), // Pass delete handler
              );
            },
          );
        }
      },
    );
  }

  Widget _buildEmptyTasksView() {
    if (kDebugMode) {
      print('[TasksScreen] _buildEmptyTasksView: Building empty tasks view.');
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Image.asset(
          'assets/images/calendar_icon.png',
          height: 100,
          width: 100,
          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
            if (kDebugMode) {
              print('[TasksScreen] _buildEmptyTasksView: Error loading calendar icon: $error');
            }
            return const Icon(Icons.error_outline, color: Colors.red, size: 50);
          },
        ),
        const SizedBox(height: 20),
        const Text(
          'Sem tarefas pendentes',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 10),
        const Text(
          'Você pode adicionar quantos quiser',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildPremiumButton() {
    return ElevatedButton.icon(
      onPressed: () {
        // TODO: Implement premium functionality or navigation
      },
      icon: const Icon(Icons.check_circle, color: Colors.white),
      label: const Text('Premium', style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE91E63).withOpacity(0.8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
