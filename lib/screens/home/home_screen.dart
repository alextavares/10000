import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:myapp/models/task.dart'; // Import Task model
import 'package:myapp/screens/task/add_task_screen.dart'; // Import AddTaskScreen
import 'package:myapp/services/service_provider.dart'; // Import ServiceProvider
import 'package:myapp/widgets/task_card.dart'; // Assuming TaskCard is a reusable widget

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState(); // Updated to public state class
}

class HomeScreenState extends State<HomeScreen> { // Made public
  late DateTime _selectedDate;
  late List<DateTime> _weekDays;
  int _selectedDayIndex = 0;
  late Future<List<Task>> _tasksFuture; // Add Future for tasks

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _weekDays = [];
    _generateWeekDays();
    _tasksFuture = _fetchTasksForSelectedDate(); // Initialize tasks future

    initializeDateFormatting('pt_BR', null).then((_) {
      if (mounted) {
        setState(() {
          // Ensure _selectedDate is initialized before _generateWeekDays
          _selectedDate = DateTime.now();
          _generateWeekDays(); // This will set _selectedDate based on _selectedDayIndex
          _tasksFuture = _fetchTasksForSelectedDate(); // Refresh tasks on init
        });
      }
    });
  }

  void _generateWeekDays() {
    DateTime now = _selectedDate; // Use _selectedDate for consistent week generation
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Monday as start of week
    _weekDays = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
    
    _selectedDayIndex = _weekDays.indexWhere((date) =>
      date.year == _selectedDate.year &&
      date.month == _selectedDate.month &&
      date.day == _selectedDate.day
    );
    // If _selectedDate is not in the generated week (e.g. on app start if logic changes),
    // default to showing the current day or the first day of the generated week.
    if (_selectedDayIndex == -1) {
        // Find today in the list or default
        int todayIndex = _weekDays.indexWhere((d) => d.day == DateTime.now().day && d.month == DateTime.now().month && d.year == DateTime.now().year);
        if (todayIndex != -1) {
            _selectedDayIndex = todayIndex;
            _selectedDate = _weekDays[todayIndex];
        } else {
            _selectedDayIndex = 0; // Default to the first day in the list
            _selectedDate = _weekDays.isNotEmpty ? _weekDays[0] : DateTime.now();
        }
    }
  }

  void _selectDay(int index) {
    setState(() {
      _selectedDayIndex = index;
      _selectedDate = _weekDays[index];
      _tasksFuture = _fetchTasksForSelectedDate(); // Fetch tasks for new selected date
    });
  }

  Future<List<Task>> _fetchTasksForSelectedDate() async {
    if (kDebugMode) {
      print('[HomeScreen] Fetching tasks for selected date: $_selectedDate');
    }
    final taskService = ServiceProvider.of(context).taskService;

    final allTasks = await taskService.getTasks(); 
    final selectedDateOnly = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    return allTasks.where((task) {
      if (task.dueDate == null) {
        return false;
      }
      final taskDueDateOnly = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
      return taskDueDateOnly.isAtSameMomentAs(selectedDateOnly);
    }).toList();
  }

  void refreshTasks() { 
    if (kDebugMode) {
      print('[HomeScreen] refreshTasks: Refreshing tasks for $_selectedDate');
    }
    setState(() {
      _tasksFuture = _fetchTasksForSelectedDate();
    });
  }

  void _handleEditTask(Task task) async {
    if (kDebugMode) {
      print('[HomeScreen] _handleEditTask: Editing task ID: ${task.id}');
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
      print('[HomeScreen] _handleDeleteTask: Deleting task ID: $taskId');
    }
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
      if (success) {
        refreshTasks();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task deleted successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete task')),
          );
        }
      }
    }
  }

  String _getDayName(int weekday) {
    // Consistent with pt_BR locale where Monday is 1
    switch (weekday) {
      case DateTime.monday: return 'Seg';
      case DateTime.tuesday: return 'Ter';
      case DateTime.wednesday: return 'Qua';
      case DateTime.thursday: return 'Qui';
      case DateTime.friday: return 'Sex';
      case DateTime.saturday: return 'Sáb';
      case DateTime.sunday: return 'Dom';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_weekDays.isEmpty) {
      return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63))));
    }
    
    return Column(
      children: [
        Container(
          height: 100,
          color: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _weekDays.length,
            itemBuilder: (context, index) {
              final day = _weekDays[index];
              final isSelected = index == _selectedDayIndex;
              
              return GestureDetector(
                onTap: () => _selectDay(index),
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFE91E63) : const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getDayName(day.weekday),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        day.day.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.black,
            child: FutureBuilder<List<Task>>(
              future: _tasksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  // Empty state UI from the screenshot
                  return SingleChildScrollView(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 50.0), // Added padding
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Opacity(
                              opacity: 0.1,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(60),
                                ),
                              ),
                            ),
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE91E63).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const Icon(
                                    Icons.calendar_today,
                                    size: 60,
                                    color: Color(0xFFE91E63),
                                  ),
                                ),
                                Positioned(
                                  right: -10,
                                  bottom: -10,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF00BFA5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            const Text(
                              'Não há nada programado',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Adicionar novas atividades',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  final tasks = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return TaskCard(
                        task: task,
                        onToggleCompletion: (taskId, completed) {
                          ServiceProvider.of(context).taskService.markTaskCompletion(taskId, _selectedDate, completed);
                          refreshTasks();
                        },
                        onEdit: () => _handleEditTask(task), // Pass edit handler
                        onDelete: () => _handleDeleteTask(task.id), // Pass delete handler
                      );
                    },
                  );
                }
              },
            ),
          ),
        ),
        Container(
          color: Colors.black,
          padding: const EdgeInsets.only(left: 20, bottom: 20, right: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE91E63), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.star,
                    color: Color(0xFFE91E63),
                    size: 20,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Premium',
                    style: TextStyle(
                      color: Color(0xFFE91E63),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
