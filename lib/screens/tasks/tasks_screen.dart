import 'package:flutter/foundation.dart'; // Import for kDebugMode
import 'package:flutter/material.dart';
import 'package:myapp/models/task.dart';
import 'package:myapp/screens/task/add_task_screen.dart'; // Import AddTaskScreen
import 'package:myapp/screens/recurring_task/add_recurring_task_screen.dart'; // Import AddRecurringTaskScreen
import 'package:myapp/services/service_provider.dart';
import 'package:myapp/widgets/task_card.dart'; // Import the new TaskCard
import 'package:myapp/widgets/recurring_task_card.dart'; // Import the new RecurringTaskCard
import 'package:myapp/screens/habit/add_habit_screen.dart'; // Added import
import 'package:myapp/models/recurring_task.dart';

class TasksScreen extends StatefulWidget {
  final TabController tabController; // Accept TabController

  const TasksScreen({super.key, required this.tabController});

  @override
  State<TasksScreen> createState() => TasksScreenState();
}

class TasksScreenState extends State<TasksScreen> { // Made public
  late Future<List<Task>> _tasksFuture;
  late Future<List<RecurringTask>> _recurringTasksFuture;

  @override
  void initState() {
    super.initState();
    _tasksFuture = Future.value([]);
    _recurringTasksFuture = Future.value([]);
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
    _recurringTasksFuture = _fetchRecurringTasks();
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

  Future<List<RecurringTask>> _fetchRecurringTasks() async {
    if (kDebugMode) {
      print('[TasksScreen] _fetchRecurringTasks: Attempting to fetch recurring tasks.');
    }
    // Ensure context is valid and mounted before accessing ServiceProvider
    if (!mounted) return [];
    final recurringTaskService = ServiceProvider.of(context).recurringTaskService;
    final recurringTasks = await recurringTaskService.getRecurringTasks();
    if (kDebugMode) {
      print('[TasksScreen] _fetchRecurringTasks: Fetched ${recurringTasks.length} recurring tasks.');
    }
    return recurringTasks;
  }

  void refreshTasks() {
    if (kDebugMode) {
      print('[TasksScreen] refreshTasks: Refreshing tasks.');
    }
    setState(() {
      _tasksFuture = _fetchTasks();
      _recurringTasksFuture = _fetchRecurringTasks();
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

  void _handleEditRecurringTask(RecurringTask recurringTask) async {
    if (kDebugMode) {
      print('[TasksScreen] _handleEditRecurringTask: Editing recurring task ID: ${recurringTask.id}');
    }
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddRecurringTaskScreen(recurringTaskToEdit: recurringTask),
      ),
    );
    if (result == true) {
      refreshTasks();
    }
  }

  void _handleDeleteRecurringTask(String recurringTaskId) async {
    if (kDebugMode) {
      print('[TasksScreen] _handleDeleteRecurringTask: Deleting recurring task ID: $recurringTaskId');
    }
    // Ensure context is valid and mounted
    if (!mounted) return;
    final recurringTaskService = ServiceProvider.of(context).recurringTaskService;

    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text('Tem certeza de que deseja excluir esta tarefa recorrente?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      final success = await recurringTaskService.deleteRecurringTask(recurringTaskId);
      // Ensure context is valid and mounted for ScaffoldMessenger
      if (!mounted) return;
      if (success) {
        refreshTasks();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tarefa recorrente excluída com sucesso')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Falha ao excluir tarefa recorrente')),
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
                onTap: () async {
                  Navigator.of(context).pop();
                  if (kDebugMode) {
                    print('[TasksScreen] _showAddTaskOptions: Navigating to AddRecurringTaskScreen.');
                  }
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AddRecurringTaskScreen()),
                  );
                  if (result == true) {
                    refreshTasks();
                  }
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
          // FloatingActionButton REMOVED from here
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
            padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 150.0), // Increased bottom padding to prevent overlap
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
  
  // Dedicated view for recurring tasks
  Widget _buildRecurringTasksView() {
    if (kDebugMode) {
      print('[TasksScreen] _buildRecurringTasksView: Building recurring tasks view.');
    }
    return FutureBuilder<List<RecurringTask>>(
      future: _recurringTasksFuture,
      builder: (context, snapshot) {
        if (kDebugMode) {
          print('[TasksScreen] FutureBuilder (Recurring): Connection state: ${snapshot.connectionState}');
          if (snapshot.hasData) {
            print('[TasksScreen] FutureBuilder (Recurring): Has data: ${snapshot.data!.length} recurring tasks.');
          }
          if (snapshot.hasError) {
            print('[TasksScreen] FutureBuilder (Recurring): Has error: ${snapshot.error}');
          }
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          if (kDebugMode) {
            print('[TasksScreen] FutureBuilder (Recurring): No recurring tasks found or data is empty.');
          }
          return _buildEmptyState(
            message: 'Sem tarefas recorrentes pendentes',
            subMessage: 'Adicione suas tarefas recorrentes aqui.',
          );
        } else {
          final recurringTasks = snapshot.data!;
          if (kDebugMode) {
            print('[TasksScreen] FutureBuilder (Recurring): Displaying ${recurringTasks.length} recurring tasks.');
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 150.0),
            itemCount: recurringTasks.length,
            itemBuilder: (context, index) {
              final recurringTask = recurringTasks[index];
              return RecurringTaskCard(
                recurringTask: recurringTask,
                onToggleCompletion: (recurringTaskId, completed) {
                  if (kDebugMode) {
                    print('[TasksScreen] RecurringTaskCard: Toggling completion for recurring task ID: $recurringTaskId to $completed');
                  }
                  ServiceProvider.of(context).recurringTaskService.markRecurringTaskCompletion(recurringTaskId, DateTime.now(), completed);
                  refreshTasks();
                },
                onEdit: () => _handleEditRecurringTask(recurringTask),
                onDelete: () => _handleDeleteRecurringTask(recurringTask.id),
              );
            },
          );
        }
      },
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
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE91E63).withOpacity(0.8), // Pink color
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (kDebugMode) {
              print('[TasksScreen] Premium button pressed.');
            }
            // TODO: Implement premium functionality or navigation
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.check_circle, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'Premium',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
