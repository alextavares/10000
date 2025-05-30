import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:myapp/models/task.dart' as task_model;
import 'package:myapp/models/habit.dart' as habit_model;
import 'package:myapp/screens/task/add_task_screen.dart';
import 'package:myapp/services/service_provider.dart';
import 'package:myapp/services/habit_service.dart';
import 'package:myapp/widgets/task_card.dart';
import 'package:myapp/widgets/habit_card.dart'; // Adicionar import do HabitCard

// Classe Wrapper para itens da lista "Hoje"
enum TodayItemType { habit, task }

class TodayListItem implements Comparable<TodayListItem> {
  final dynamic item; // Pode ser Habit ou Task
  final TodayItemType type;
  final DateTime sortDate; // Data para ordenação (dueDate para task, _selectedDate para habit)
  final TimeOfDay? timeOfDay; // Para ordenação mais granular se disponível

  TodayListItem({
    required this.item,
    required this.type,
    required this.sortDate,
    this.timeOfDay,
  });

  @override
  int compareTo(TodayListItem other) {
    int dateCompare = sortDate.compareTo(other.sortDate);
    if (dateCompare != 0) return dateCompare;

    if (timeOfDay != null && other.timeOfDay != null) {
      int hourCompare = timeOfDay!.hour.compareTo(other.timeOfDay!.hour);
      if (hourCompare != 0) return hourCompare;
      int minuteCompare = timeOfDay!.minute.compareTo(other.timeOfDay!.minute);
      if (minuteCompare != 0) return minuteCompare;
    } else if (timeOfDay != null) {
      return -1; 
    } else if (other.timeOfDay != null) {
      return 1; 
    }
    
    if (type == TodayItemType.task && other.type == TodayItemType.habit) {
      return -1; 
    }
    if (type == TodayItemType.habit && other.type == TodayItemType.task) {
      return 1; 
    }
    return 0;
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late DateTime _selectedDate;
  late List<DateTime> _weekDays;
  int _selectedDayIndex = 0;
  late Future<List<TodayListItem>> _todayItemsFuture;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _weekDays = [];
    initializeDateFormatting('pt_BR', null).then((_) {
      if (mounted) {
        setState(() {
          _selectedDate = DateTime.now();
          _generateWeekDays();
        });
      }
    });
  }

  void _generateWeekDays() {
    DateTime now = _selectedDate;
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    _weekDays = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
    int potentialIndex = _weekDays.indexWhere((date) =>
        date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day);
    if (potentialIndex != -1) {
      _selectedDayIndex = potentialIndex;
    } else {
      _selectedDayIndex = 0; 
      _selectedDate = _weekDays.isNotEmpty ? _weekDays[0] : DateTime.now();
    }
    _todayItemsFuture = _fetchDataForSelectedDate();
  }

  void _selectDay(int index) {
    setState(() {
      _selectedDayIndex = index;
      _selectedDate = _weekDays[index];
      _todayItemsFuture = _fetchDataForSelectedDate();
    });
  }

  void _navigateToNextWeek() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 7));
      _generateWeekDays();
    });
  }

  void _navigateToPreviousWeek() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 7));
      _generateWeekDays();
    });
  }

  Future<List<TodayListItem>> _fetchDataForSelectedDate() async {
    if (kDebugMode) {
      // print('[HomeScreen] Fetching data for selected date: $_selectedDate');
    }
    if (!mounted) return [];

    final taskService = ServiceProvider.of(context).taskService;
    final habitService = ServiceProvider.of(context).habitService;
    List<TodayListItem> items = [];

    final allTasks = await taskService.getTasks();
    final selectedDateOnly = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final tasksForDay = allTasks.where((task) {
      if (task.dueDate == null) return false;
      final taskDueDateOnly = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
      return taskDueDateOnly.isAtSameMomentAs(selectedDateOnly);
    }).toList();

    for (var task in tasksForDay) {
      items.add(TodayListItem(
        item: task,
        type: TodayItemType.task,
        sortDate: task.dueDate!,
        timeOfDay: null, 
      ));
    }

    final allHabits = await habitService.getHabits();
    final habitsForDay = allHabits.where((habit) {
      bool showHabit = false;
      if (habit.startDate.isAfter(_selectedDate)) {
        return false; 
      }
      if (habit.targetDate != null && habit.targetDate!.isBefore(_selectedDate)) {
        return false; 
      }

      if (habit.frequency == habit_model.HabitFrequency.daily) {
        showHabit = true;
      } else if (habit.frequency == habit_model.HabitFrequency.weekly || habit.frequency == habit_model.HabitFrequency.custom) {
        print('Home: Weekly habit ${habit.title}, daysOfWeek: ${habit.daysOfWeek}, selectedWeekday: ${_selectedDate.weekday}');
        if (habit.daysOfWeek != null && habit.daysOfWeek!.contains(_selectedDate.weekday)) {
          showHabit = true;
          print('Home: Showing weekly habit ${habit.title}');
        } else {
          print('Home: NOT showing weekly habit ${habit.title}');
        }
      } else if (habit.frequency == habit_model.HabitFrequency.monthly) {
        print('Home: Monthly habit ${habit.title}, daysOfMonth: ${habit.daysOfMonth}, selectedDay: ${_selectedDate.day}');
        if (habit.daysOfMonth != null && habit.daysOfMonth!.contains(_selectedDate.day)) {
          showHabit = true;
          print('Home: Showing monthly habit ${habit.title} - day match');
        } else if (habit.daysOfMonth != null && habit.daysOfMonth!.contains(0)) {
          // Check if today is the last day of the month
          final lastDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
          if (_selectedDate.day == lastDayOfMonth) {
            showHabit = true;
            print('Home: Showing monthly habit ${habit.title} - last day of month');
          }
        }
        print('Home: Monthly habit ${habit.title} - SHOWING: $showHabit');
      } else if (habit.frequency == habit_model.HabitFrequency.specificDaysOfYear) {
        if (habit.specificYearDates != null) {
          showHabit = habit.specificYearDates!.any((date) =>
            date.year == _selectedDate.year &&
            date.month == _selectedDate.month &&
            date.day == _selectedDate.day
          );
        }
      } else if (habit.frequency == habit_model.HabitFrequency.someTimesPerPeriod) {
        showHabit = true; // Para "algumas vezes por período", sempre mostra
      } else if (habit.frequency == habit_model.HabitFrequency.repeat) {
        showHabit = true; // Para "repetir", sempre mostra por enquanto
      }
      return showHabit;
    }).toList();

    for (var habit in habitsForDay) {
      items.add(TodayListItem(
        item: habit,
        type: TodayItemType.habit,
        sortDate: _selectedDate, 
        timeOfDay: habit.reminderTime
      ));
    }

    items.sort();
    return items;
  }

  void refreshScreenData() {
    if (kDebugMode) {
      // print('[HomeScreen] refreshScreenData: Refreshing items for $_selectedDate');
    }
    setState(() {
      _todayItemsFuture = _fetchDataForSelectedDate();
    });
  }

  void _handleEditTask(task_model.Task task) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(taskToEdit: task),
      ),
    );
    if (result == true) {
      refreshScreenData();
    }
  }

  void _handleDeleteTask(String taskId) async {
    final taskService = ServiceProvider.of(context).taskService;
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text('Você tem certeza que deseja excluir esta tarefa?'),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Excluir', style: TextStyle(color: Colors.red))),
          ],
        );
      },
    );
    if (confirmDelete == true) {
      final success = await taskService.deleteTask(taskId);
      if (success) {
        refreshScreenData();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tarefa excluída com sucesso')));
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Falha ao excluir tarefa')));
      }
    }
  }
  
  Future<void> _toggleHabitCompletion(habit_model.Habit habit, bool completed) async {
    if (!mounted) return;
    final habitService = ServiceProvider.of(context).habitService;
    try {
      await habitService.markHabitCompletion(habit.id, _selectedDate, completed);
      refreshScreenData();
    } catch (e) {
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao marcar hábito: $e')));
      }
    }
  }

  Future<void> _deleteHabit(String habitId) async {
    if (!mounted) return;
    final habitService = ServiceProvider.of(context).habitService;
    final confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
            return AlertDialog(
                title: const Text('Confirmar Exclusão'),
                content: const Text('Você tem certeza que deseja excluir este hábito?'),
                actions: <Widget>[
                    TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
                    TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Excluir', style: TextStyle(color: Colors.red))),
                ],
            );
        },
    );
    if (confirm == true) {
        try {
            await habitService.deleteHabit(habitId);
            refreshScreenData(); 
            if(mounted){
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hábito excluído com sucesso.')));
            }
        } catch (e) {
            if(mounted){
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao excluir hábito: $e')));
            }
        }
    }
  }


  String _getDayName(int weekday) {
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
    return Consumer<HabitService>(
      builder: (context, habitService, child) {
        return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // REMOVED Custom AppBar Container
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0), 
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18), onPressed: _navigateToPreviousWeek),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(_weekDays.length, (index) {
                        final day = _weekDays[index];
                        final isSelected = index == _selectedDayIndex;
                        return GestureDetector(
                          onTap: () => _selectDay(index),
                          child: Container(
                            width: 38,
                            height: 70,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFE91E63) : const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Text(_getDayName(day.weekday), style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              Text(day.day.toString(), style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                            ]),
                          ),
                        );
                      }),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18), onPressed: _navigateToNextWeek),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.black, 
                child: FutureBuilder<List<TodayListItem>>(
                  future: _todayItemsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63))));
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Erro: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                       return const Center(child: Text("Não há nada programado para hoje.", style: TextStyle(color: Colors.white, fontSize: 16)));
                    }
                    final items = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final todayItem = items[index];
                        if (todayItem.type == TodayItemType.task) {
                          final task = todayItem.item as task_model.Task;
                          return TaskCard(
                            task: task,
                            onToggleCompletion: (taskId, completed) {
                              ServiceProvider.of(context).taskService.markTaskCompletion(taskId, _selectedDate, completed);
                              refreshScreenData();
                            },
                            onEdit: () => _handleEditTask(task),
                            onDelete: () => _handleDeleteTask(task.id),
                          );
                        } else if (todayItem.type == TodayItemType.habit) {
                          final habit = todayItem.item as habit_model.Habit;
                          return HabitCard(
                            habit: habit,
                            // selectedDate: _selectedDate, // This line was already commented out from previous step, ensuring it remains so.
                            onTap: () {
                              if (kDebugMode) {
                                // print('Habit tapped: ${habit.title}');
                              }
                            },
                            onToggleCompletion: (completed) { 
                              _toggleHabitCompletion(habit, completed);
                            },
                            onDelete: () {
                              _deleteHabit(habit.id);
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
      },
    );
  }
}
