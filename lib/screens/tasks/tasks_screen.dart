import 'package:flutter/foundation.dart'; // Import for kDebugMode
import 'package:flutter/material.dart';
import 'package:myapp/models/task.dart';
import 'package:myapp/screens/task/add_task_screen.dart'; // Import AddTaskScreen
import 'package:myapp/services/service_provider.dart';
import 'package:myapp/widgets/task_card.dart'; // Import the new TaskCard
import 'package:myapp/screens/habit/add_habit_screen.dart'; // Added import

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
    // Ensure context is valid and mounted before accessing ServiceProvider
    if (!mounted) return [];
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

  void _handleEditTask(Task task) async {
    if (kDebugMode) {
      print('[TasksScreen] _handleEditTask: Editing task ID: ${task.id}');
    }
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(taskToEdit: task),
      ),
    );
    if (result == true) {
      refreshTasks();
    }
  }

  void _handleDeleteTask(String taskId) async {
    if (kDebugMode) {
      print('[TasksScreen] _handleDeleteTask: Deleting task ID: $taskId');
    }
    // Ensure context is valid and mounted
    if (!mounted) return;
    final taskService = ServiceProvider.of(context).taskService;

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
      // Ensure context is valid and mounted for ScaffoldMessenger
      if (!mounted) return;
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

  void _showAddTaskOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900], // Dark background for the modal
      shape: const RoundedRectangleBorder( // Optional: to get rounded top corners
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.fitness_center, color: Colors.pinkAccent[100]), // Adjusted icon color
                title: const Text('Hábito', style: TextStyle(color: Colors.white)),
                subtitle: Text('Atividade que se repete ao longo do tempo. Possui rastreamento detalhado e estatísticas.', style: TextStyle(color: Colors.grey[400])),
                onTap: () {
                  Navigator.of(context).pop(); // Close the modal
                  if (kDebugMode) {
                    print('[TasksScreen] _showAddTaskOptions: Navigating to AddHabitScreen.');
                  }
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddHabitScreen())); // Navigate to AddHabitScreen
                },
              ),
              ListTile(
                leading: Icon(Icons.repeat, color: Colors.blueAccent[100]), // Adjusted icon color
                title: const Text('Tarefa recorrente', style: TextStyle(color: Colors.white)),
                subtitle: Text('Atividade que se repete ao longo do tempo, sem rastreamento ou estatísticas.', style: TextStyle(color: Colors.grey[400])),
                onTap: () {
                  Navigator.of(context).pop();
                  if (kDebugMode) {
                    print('[TasksScreen] _showAddTaskOptions: Navigating to Add Recurring Task (Not Implemented).');
                  }
                  // TODO: Navigate to the screen for adding a recurring task
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Navegação para Adicionar Tarefa Recorrente pendente.')),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.check_circle_outline, color: Colors.greenAccent[100]), // Adjusted icon color
                title: const Text('Tarefa', style: TextStyle(color: Colors.white)),
                subtitle: Text('Atividade de instância única sem rastreamento ao longo do tempo.', style: TextStyle(color: Colors.grey[400])),
                onTap: () async {
                  Navigator.of(context).pop();
                  if (kDebugMode) {
                    print('[TasksScreen] _showAddTaskOptions: Navigating to AddTaskScreen.');
                  }
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AddTaskScreen()),
                  );
                  if (result == true) {
                    refreshTasks();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
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
              _buildRecurringTasksView(), // Changed to a dedicated view for recurring tasks
            ],
          ),
          Positioned(
            left: 16,
            bottom: 76, 
            child: _buildPremiumButton(),
          ),
          Positioned(
            right: 24, // Adjusted for better visual balance with bottom nav
            bottom: 90, // Adjusted to be above the navigation bar if present
            child: FloatingActionButton(
              onPressed: () {
                _showAddTaskOptions(context);
              },
              backgroundColor: const Color(0xFFE91E63), // Pink color from the image
              foregroundColor: Colors.white,
              heroTag: 'tasksFab', // Icon color
              child: const Icon(Icons.add), // Added a unique heroTag
            ),
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
            print('[TasksScreen] FutureBuilder: No tasks found or data is empty for simple tasks.');
          }
          return _buildEmptyState(
            message: 'Sem tarefas simples pendentes',
            subMessage: 'Adicione algumas tarefas para começar!',
          );
        } else {
          final tasks = snapshot.data!;
          if (kDebugMode) {
            print('[TasksScreen] FutureBuilder: Displaying ${tasks.length} tasks.');
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 80.0), // Added bottom padding
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
                onEdit: () => _handleEditTask(task),
                onDelete: () => _handleDeleteTask(task.id),
              );
            },
          );
        }
      },
    );
  }
  
  // Dedicated view for recurring tasks, can be expanded later
  Widget _buildRecurringTasksView() {
    if (kDebugMode) {
      print('[TasksScreen] _buildRecurringTasksView: Building recurring tasks view (currently empty).');
    }
    // For now, shows the same empty state, but can be customized
    return _buildEmptyState(
      message: 'Sem tarefas recorrentes pendentes',
      subMessage: 'Adicione suas tarefas recorrentes aqui.',
    );
  }

  Widget _buildEmptyState({required String message, required String subMessage}) {
    if (kDebugMode) {
      print('[TasksScreen] _buildEmptyState: Building empty state: $message');
    }
    return Center( // Ensures the content is centered
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            'assets/images/calendar_icon.png', // Make sure this asset exists
            height: 100,
            width: 100,
            errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
              if (kDebugMode) {
                print('[TasksScreen] _buildEmptyState: Error loading calendar icon: $error');
              }
              return const Icon(Icons.error_outline, color: Colors.red, size: 50);
            },
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            subMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }


  Widget _buildPremiumButton() {
    return ElevatedButton.icon(
      onPressed: () {
        if (kDebugMode) {
          print('[TasksScreen] Premium button pressed.');
        }
        // TODO: Implement premium functionality or navigation
      },
      icon: const Icon(Icons.check_circle, color: Colors.white), // Pink icon from image
      label: const Text('Premium', style: TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE91E63).withOpacity(0.8), // Pink color
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
