import 'package:flutter/foundation.dart'; // Import for kDebugMode
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/models/task.dart';
import 'package:myapp/screens/task/add_task_screen.dart'; // Import AddTaskScreen
import 'package:myapp/screens/recurring_task/add_recurring_task_screen.dart'; // Import AddRecurringTaskScreen
import 'package:myapp/services/service_provider.dart';
import 'package:myapp/services/task_service.dart';
import 'package:myapp/services/recurring_task_service.dart';
import 'package:myapp/widgets/task_card.dart'; // Import the new TaskCard
import 'package:myapp/widgets/recurring_task_card.dart'; // Import the new RecurringTaskCard
import 'package:myapp/screens/habit/add_habit_screen.dart'; // Added import
import 'package:myapp/models/recurring_task.dart';
import 'package:myapp/utils/logger.dart';

class TasksScreen extends StatefulWidget {
  final TabController tabController; // Accept TabController

  const TasksScreen({super.key, required this.tabController});

  @override
  State<TasksScreen> createState() => TasksScreenState();
}

class TasksScreenState extends State<TasksScreen> { // Made public

  void _handleEditTask(Task task) async {
    if (kDebugMode) {
      Logger.debug('[TasksScreen] _handleEditTask: Editing task ID: ${task.id}');
    }
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(taskToEdit: task),
      ),
    );
    // TaskService will notify listeners automatically
  }

  void _handleDeleteTask(String taskId) async {
    if (kDebugMode) {
      Logger.debug('[TasksScreen] _handleDeleteTask: Deleting task ID: $taskId');
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
        // TaskService will notify listeners automatically
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
      Logger.debug('[TasksScreen] _handleEditRecurringTask: Editing recurring task ID: ${recurringTask.id}');
    }
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddRecurringTaskScreen(recurringTaskToEdit: recurringTask),
      ),
    );
    // RecurringTaskService will notify listeners automatically
  }

  void _handleDeleteRecurringTask(String recurringTaskId) async {
    if (kDebugMode) {
      Logger.debug('[TasksScreen] _handleDeleteRecurringTask: Deleting recurring task ID: $recurringTaskId');
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
        // RecurringTaskService will notify listeners automatically
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
                    Logger.debug('[TasksScreen] _showAddTaskOptions: Navigating to AddHabitScreen.');
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
                    Logger.debug('[TasksScreen] _showAddTaskOptions: Navigating to AddRecurringTaskScreen.');
                  }
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AddRecurringTaskScreen()),
                  );
                  // RecurringTaskService will notify listeners automatically
                },
              ),
              ListTile(
                leading: Icon(Icons.check_circle_outline, color: Colors.greenAccent[100]), // Adjusted icon color
                title: const Text('Tarefa', style: TextStyle(color: Colors.white)),
                subtitle: Text('Atividade de instância única sem rastreamento ao longo do tempo.', style: TextStyle(color: Colors.grey[400])),
                onTap: () async {
                  Navigator.of(context).pop();
                  if (kDebugMode) {
                    Logger.debug('[TasksScreen] _showAddTaskOptions: Navigating to AddTaskScreen.');
                  }
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AddTaskScreen()),
                  );
                  // TaskService will notify listeners automatically
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
      Logger.debug('[TasksScreen] build: Building TasksScreen.');
    }
    return Consumer<TaskService>(
      builder: (context, taskService, child) {
        return Container(
      color: Colors.black, 
      child: Stack(
        children: [
          TabBarView(
            controller: widget.tabController,
            children: [
              _buildSimpleTasksView(),
              _buildRecurringTasksView(),
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
      },
    );
  }

  Widget _buildSimpleTasksView() {
    if (kDebugMode) {
      Logger.debug('[TasksScreen] _buildSimpleTasksView: Building simple tasks view.');
    }
    return Consumer<TaskService>(
      builder: (context, taskService, child) {
        final tasks = taskService.getTasksSync();
        if (kDebugMode) {
          Logger.debug('[TasksScreen] Tasks count: ${tasks.length}');
        }
        if (tasks.isEmpty) {
          if (kDebugMode) {
            Logger.debug('[TasksScreen] No tasks found.');
          }
          return _buildEmptyState(
            message: 'Sem tarefas simples pendentes',
            subMessage: 'Adicione algumas tarefas para começar!',
          );
        } else {
          if (kDebugMode) {
            Logger.debug('[TasksScreen] Displaying ${tasks.length} tasks.');
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
                    Logger.info('[TasksScreen] TaskCard: Toggling completion for task ID: $taskId to $completed');
                  }
                  ServiceProvider.of(context).taskService.markTaskCompletion(taskId, DateTime.now(), completed);
                  // TaskService will notify listeners automatically 
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
  
  // Public method to refresh screen data
  void refreshScreenData() {
    if (kDebugMode) {
      Logger.debug('[TasksScreen] refreshScreenData: Refreshing screen data.');
    }
    // Both Tasks and RecurringTasks will be updated automatically via Consumer
    // Nothing to do here anymore
  }
  
  // Dedicated view for recurring tasks
  Widget _buildRecurringTasksView() {
    if (kDebugMode) {
      Logger.debug('[TasksScreen] _buildRecurringTasksView: Building recurring tasks view.');
    }
    return Consumer<RecurringTaskService>(
      builder: (context, recurringTaskService, child) {
        final recurringTasks = recurringTaskService.getRecurringTasksSync();
        if (kDebugMode) {
          Logger.debug('[TasksScreen] Recurring tasks count: ${recurringTasks.length}');
        }
        if (recurringTasks.isEmpty) {
          if (kDebugMode) {
            Logger.debug('[TasksScreen] No recurring tasks found.');
          }
          return _buildEmptyState(
            message: 'Sem tarefas recorrentes pendentes',
            subMessage: 'Adicione suas tarefas recorrentes aqui.',
          );
        } else {
          if (kDebugMode) {
            Logger.debug('[TasksScreen] Displaying ${recurringTasks.length} recurring tasks.');
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
                    Logger.info('[TasksScreen] RecurringTaskCard: Toggling completion for recurring task ID: $recurringTaskId to $completed');
                  }
                  ServiceProvider.of(context).recurringTaskService.markRecurringTaskCompletion(recurringTaskId, DateTime.now(), completed);
                  // RecurringTaskService will notify listeners automatically
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
      Logger.debug('[TasksScreen] _buildEmptyState: Building empty state: $message');
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.grey[700],
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[300],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subMessage,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumButton() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE91E63).withValues(alpha: 0.8), // Pink color
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (kDebugMode) {
              Logger.debug('[TasksScreen] Premium button pressed.');
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
