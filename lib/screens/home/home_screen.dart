import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:myapp/models/habit.dart'; // Add this
import 'package:myapp/models/task.dart'; // Import Task model
import 'package:myapp/screens/task/add_task_screen.dart'; // Import AddTaskScreen
import 'package:myapp/services/service_provider.dart'; // Import ServiceProvider
import 'package:myapp/widgets/habit_card.dart'; // Add this
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
  late Future<List<Habit>> _habitsFuture; // Add this

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _weekDays = [];
    _generateWeekDays();
    _tasksFuture = _fetchTasksForSelectedDate(); // Initialize tasks future
    _habitsFuture = _fetchHabitsForSelectedDate(); // Add this

    initializeDateFormatting('pt_BR', null).then((_) {
      if (mounted) {
        setState(() {
          // Ensure _selectedDate is initialized before _generateWeekDays
          _selectedDate = DateTime.now();
          _generateWeekDays(); // This will set _selectedDate based on _selectedDayIndex
          _tasksFuture = _fetchTasksForSelectedDate(); // Refresh tasks on init
          _habitsFuture = _fetchHabitsForSelectedDate(); // Add this also
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
      _habitsFuture = _fetchHabitsForSelectedDate(); // Add this
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

  Future<List<Habit>> _fetchHabitsForSelectedDate() async {
    if (kDebugMode) {
      print('[HomeScreen] Fetching habits for selected date: $_selectedDate');
    }
    final habitService = ServiceProvider.of(context).habitService;
  
    // Option 1: Use getHabitsDueToday() if it aligns with selectedDate logic
    // This might fetch only for DateTime.now(), so care is needed.
    // For now, let's fetch all and filter, similar to tasks.
    // final allHabits = await habitService.getHabits();
    
    // Option 2: More robustly, get all habits and filter by _selectedDate
    // This ensures habits for any selected day are shown, not just "today".
    final allHabits = await habitService.getHabits();
    final selectedDateOnly = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    return allHabits.where((habit) {
      // Use the habit's isDueOnDate logic if available, or implement here
      // For simplicity, let's adapt isDueToday from Habit model or re-implement
      if (habit.frequency == HabitFrequency.daily) {
        return true;
      } else if (habit.frequency == HabitFrequency.weekly) {
        // Ensure daysOfWeek is 1-7 (Mon-Sun) matching DateTime.weekday
        return habit.daysOfWeek?.contains(selectedDateOnly.weekday) ?? false;
      } else if (habit.frequency == HabitFrequency.monthly) {
        return habit.createdAt.day == selectedDateOnly.day;
      }
      // Add other frequencies if necessary
      return false; 
    }).toList();
  }

  void refreshHabits() { 
    if (kDebugMode) {
      print('[HomeScreen] refreshHabits: Refreshing habits for $_selectedDate');
    }
    setState(() {
      _habitsFuture = _fetchHabitsForSelectedDate();
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
    
    return Column( // Main column for calendar, tasks, and habits
      children: [
        // Calendar part (existing code)
        Container(
          height: 100,
          color: Colors.black,
          // ... (rest of calendar code remains the same) ...
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

        // Section for Tasks
        Padding(
          padding: const EdgeInsets.all(16.0).copyWith(bottom: 8.0),
          child: Text(
            'Tarefas',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.black,
            child: FutureBuilder<List<Task>>(
              future: _tasksFuture,
              builder: (context, snapshot) {
                // ... (existing task FutureBuilder code remains the same) ...
                // Make sure the empty state for tasks is distinct or handled if no tasks AND no habits.
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading tasks: ${snapshot.error}', style: TextStyle(color: Colors.white)));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Text('Nenhuma tarefa para hoje.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    )
                  ); // Simplified empty state for tasks
                } else {
                  final tasks = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return TaskCard(
                        task: task,
                        onToggleCompletion: (taskId, completed) {
                          ServiceProvider.of(context).taskService.markTaskCompletion(taskId, _selectedDate, completed);
                          refreshTasks();
                        },
                        onEdit: () => _handleEditTask(task),
                        onDelete: () => _handleDeleteTask(task.id),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ),

        // Section for Habits
        Padding(
          padding: const EdgeInsets.all(16.0).copyWith(top:8.0, bottom: 8.0),
          child: Text(
            'Hábitos',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.black,
            child: FutureBuilder<List<Habit>>(
              future: _habitsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading habits: ${snapshot.error}', style: TextStyle(color: Colors.white)));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  // Empty state UI for habits (can be similar to tasks or specific)
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0), // Added padding
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // You can reuse or adapt the nice empty state from original task list if you prefer
                          Icon(Icons.emoji_nature, color: Colors.grey.withOpacity(0.5), size: 60),
                          const SizedBox(height: 10),
                          const Text(
                            'Nenhum hábito para hoje.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                           const SizedBox(height: 5),
                          Text(
                            'Adicione novos hábitos para começar!', // Call to action
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  final habits = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: habits.length,
                    itemBuilder: (context, index) {
                      final habit = habits[index];
                      return HabitCard(
                        habit: habit,
                        selectedDate: _selectedDate, // Pass the selectedDate
                        onToggleCompletion: (habitId, isCompleted) async {
                          if (kDebugMode) {
                            print('[HomeScreen] Toggling habit $habitId completion to $isCompleted for date $_selectedDate');
                          }
                          final habitService = ServiceProvider.of(context).habitService;
                          bool success = false;

                          // Important: The `isCompleted` parameter here means the *new* desired state.
                          // If `isCompleted` is true, it means the user wants to mark it as completed.
                          // If `isCompleted` is false, it means the user wants to mark it as not completed.

                          final dateToMark = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

                          if (isCompleted) {
                            success = await habitService.markHabitCompleted(habitId, dateToMark);
                          } else {
                            success = await habitService.markHabitNotCompleted(habitId, dateToMark);
                          }

                          if (success) {
                            if (kDebugMode) {
                              print('[HomeScreen] Habit $habitId completion status updated successfully.');
                            }
                            // Refresh the habits list to show the change
                            refreshHabits(); 
                            // Optionally, also refresh tasks if there's any cross-dependency, though unlikely for habits.
                          } else {
                            if (kDebugMode) {
                              print('[HomeScreen] Failed to update habit $habitId completion status.');
                            }
                            // Show a snackbar or some error message to the user if desired
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to update habit status. Please try again.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        // onEdit and onDelete can be added later if needed for habits on home screen
                      );
                    },
                  );
                }
              },
            ),
          ),
        ),
        
        // Premium banner (existing code)
        Container(
          // ... (rest of premium banner code remains the same) ...
          color: Colors.black,
          padding: const EdgeInsets.only(left: 20, bottom: 20, right: 20, top: 10), // Added top padding
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
