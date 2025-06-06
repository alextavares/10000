import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/task.dart' as task_model;
import 'package:myapp/models/habit.dart' as habit_model;
import 'package:myapp/screens/task/add_task_screen.dart';
import 'package:myapp/services/service_provider.dart';
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
  Future<List<TodayListItem>>? _todayItemsFuture;
  Map<DateTime, int> _weekCompletions = {};

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
          // Inicializa o Future aqui
          _todayItemsFuture = _fetchDataForSelectedDate();
          _loadWeekCompletions();
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
      _loadWeekCompletions();
    });
  }

  void _navigateToPreviousWeek() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 7));
      _generateWeekDays();
      _loadWeekCompletions();
    });
  }

  Future<void> _loadWeekCompletions() async {
    if (!mounted) return;
    
    final habitService = ServiceProvider.of(context).habitService;
    try {
      final habits = await habitService.getHabits();
      
      Map<DateTime, int> completions = {};
      
      for (var day in _weekDays) {
        int count = 0;
        // Normaliza a data para comparação
        final dayKey = DateTime(day.year, day.month, day.day);
        
        for (var habit in habits) {
          // Verifica se o hábito deve aparecer no dia
          if (habit.isDueToday(day) && habit.completionHistory[dayKey] == true) {
            count++;
          }
        }
        if (count > 0) {
          completions[dayKey] = count;
        }
      }
      
      if (mounted) {
        setState(() {
          _weekCompletions = completions;
        });
      }
    } catch (e) {
      print('[HomeScreen] Error loading week completions: $e');
    }
  }

  Future<List<TodayListItem>> _fetchDataForSelectedDate() async {
    if (!mounted) return [];

    try {
      final taskService = ServiceProvider.of(context).taskService;
      final habitService = ServiceProvider.of(context).habitService;
      List<TodayListItem> items = [];

      // Buscar tarefas
      final allTasks = await taskService.getTasks();
      print('[DEBUG] Total tasks: ${allTasks.length}');
      print('[DEBUG] Selected date: $_selectedDate');
      
      final selectedDateOnly = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      
      final tasksForDay = allTasks.where((task) {
        if (task.dueDate == null) return false;
        final taskDueDateOnly = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
        print('[DEBUG] Task ${task.title} due date: ${task.dueDate}, matches: ${taskDueDateOnly.isAtSameMomentAs(selectedDateOnly)}');
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

      // Buscar hábitos
      final allHabits = await habitService.getHabits();
      print('[DEBUG] Total habits: ${allHabits.length}');
      
      final habitsForDay = allHabits.where((habit) {
        print('[DEBUG] Checking habit: ${habit.title}, freq: ${habit.frequency}, startDate: ${habit.startDate}');
        
        // Verifica se a data selecionada está dentro do período do hábito
        final selectedDateOnly = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
        final startDateOnly = DateTime(habit.startDate.year, habit.startDate.month, habit.startDate.day);
        
        if (startDateOnly.isAfter(selectedDateOnly)) {
          print('[DEBUG] Habit ${habit.title} - start date is after selected date');
          return false; 
        }
        
        if (habit.targetDate != null) {
          final targetDateOnly = DateTime(habit.targetDate!.year, habit.targetDate!.month, habit.targetDate!.day);
          if (targetDateOnly.isBefore(selectedDateOnly)) {
            return false; 
          }
        }

        // Verifica frequência
        if (habit.frequency == habit_model.HabitFrequency.daily) {
          print('[DEBUG] Habit ${habit.title} - is daily, will show: true');
          return true;
        } else if (habit.frequency == habit_model.HabitFrequency.weekly) {
          bool show = habit.daysOfWeek?.contains(_selectedDate.weekday) ?? false;
          print('[DEBUG] Habit ${habit.title} - is weekly, daysOfWeek: ${habit.daysOfWeek}, selectedWeekday: ${_selectedDate.weekday}, will show: $show');
          return show;
        } else if (habit.frequency == habit_model.HabitFrequency.monthly) {
          bool isSelectedDay = habit.daysOfMonth?.contains(_selectedDate.day) ?? false;
          // Verifica último dia do mês
          if (!isSelectedDay && (habit.daysOfMonth?.contains(0) ?? false)) {
            final lastDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
            isSelectedDay = _selectedDate.day == lastDayOfMonth;
          }
          return isSelectedDay;
        } else if (habit.frequency == habit_model.HabitFrequency.specificDaysOfYear) {
          return habit.specificYearDates?.any((date) =>
            date.year == _selectedDate.year &&
            date.month == _selectedDate.month &&
            date.day == _selectedDate.day
          ) ?? false;
        }
        
        // Para outras frequências, mostra sempre por enquanto
        print('[DEBUG] Habit ${habit.title} - will show: true (other frequency)');
        return true;
      }).toList();
      
      print('[DEBUG] Habits for day: ${habitsForDay.length}');

      for (var habit in habitsForDay) {
        items.add(TodayListItem(
          item: habit,
          type: TodayItemType.habit,
          sortDate: _selectedDate, 
          timeOfDay: habit.reminderTime
        ));
      }

      items.sort();
      print('[DEBUG] Total items for display: ${items.length} (${tasksForDay.length} tasks, ${habitsForDay.length} habits)');
      return items;
    } catch (e) {
      print('[HomeScreen] Error in _fetchDataForSelectedDate: $e');
      return [];
    }
  }

  void refreshScreenData() {
    if (kDebugMode) {
      print('[HomeScreen] refreshScreenData: Refreshing items for $_selectedDate');
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
      _loadWeekCompletions(); // Atualiza indicadores de progresso
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

  Widget _buildCalendarHeader() {
    final monthYear = DateFormat('MMMM yyyy', 'pt_BR').format(_selectedDate);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        border: Border(
          bottom: BorderSide(color: Colors.grey[800]!, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botão "Hoje"
          TextButton(
            onPressed: () {
              setState(() {
                _selectedDate = DateTime.now();
                _generateWeekDays();
                _todayItemsFuture = _fetchDataForSelectedDate();
                _loadWeekCompletions();
              });
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              backgroundColor: const Color(0xFFE91E63).withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: const Color(0xFFE91E63).withOpacity(0.3),
                ),
              ),
            ),
            child: const Text(
              'Hoje',
              style: TextStyle(
                color: Color(0xFFE91E63),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          
          // Mês e Ano
          Column(
            children: [
              Text(
                monthYear.split(' ')[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                monthYear.split(' ')[1],
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          
          // Ícone de calendário para seletor de data
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE91E63).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFE91E63).withOpacity(0.3),
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.calendar_month, color: Color(0xFFE91E63)),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData.dark().copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: Color(0xFFE91E63),
                          surface: Color(0xFF1E1E1E),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                    _generateWeekDays();
                    _todayItemsFuture = _fetchDataForSelectedDate();
                    _loadWeekCompletions();
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_weekDays.isEmpty) {
      return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63))));
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header com mês/ano
            _buildCalendarHeader(),
            
            // Calendário semanal
            Container(
              height: 80,
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.white, size: 16), 
                    onPressed: _navigateToPreviousWeek,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _weekDays.length,
                      itemBuilder: (context, index) {
                        final day = _weekDays[index];
                        final isSelected = index == _selectedDayIndex;
                        final isToday = day.year == DateTime.now().year && 
                                       day.month == DateTime.now().month && 
                                       day.day == DateTime.now().day;
                        // Buscar completions para o dia
                        final dateKey = DateTime(day.year, day.month, day.day);
                        final hasCompletions = _weekCompletions[dateKey] ?? 0;
                        final maxCompletions = _weekCompletions.values.isEmpty 
                            ? 1 
                            : _weekCompletions.values.reduce((a, b) => a > b ? a : b);
                        final completionRate = maxCompletions > 0 ? hasCompletions / maxCompletions : 0.0;
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: GestureDetector(
                            onTap: () => _selectDay(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 56,
                              height: 70,
                              decoration: BoxDecoration(
                                gradient: isSelected 
                                    ? LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          const Color(0xFFE91E63),
                                          const Color(0xFFE91E63).withOpacity(0.8),
                                        ],
                                      )
                                    : null,
                                color: !isSelected ? const Color(0xFF1E1E1E) : null,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isToday && !isSelected
                                      ? const Color(0xFFE91E63).withOpacity(0.5)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFFE91E63).withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _getDayName(day.weekday).toUpperCase(),
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.grey[500],
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    day.day.toString(),
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.white70,
                                      fontSize: isSelected ? 22 : 18,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  
                                  // Indicador de progresso
                                  if (hasCompletions > 0)
                                    Container(
                                      height: 4,
                                      width: 28,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(2),
                                        color: Colors.grey[800],
                                      ),
                                      child: Stack(
                                        children: [
                                          AnimatedContainer(
                                            duration: const Duration(milliseconds: 500),
                                            height: 4,
                                            width: 28 * completionRate,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(2),
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.green[400]!,
                                                  Colors.green[600]!,
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else if (isToday && !isSelected)
                                    Container(
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE91E63),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFE91E63).withOpacity(0.5),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    const SizedBox(height: 4),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.white, size: 16), 
                    onPressed: _navigateToNextWeek,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.black, 
                child: _todayItemsFuture == null 
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
                      ),
                    )
                  : FutureBuilder<List<TodayListItem>>(
                  future: _todayItemsFuture, // Usa a variável de instância
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Carregando...',
                              style: TextStyle(color: Colors.grey[400], fontSize: 14),
                            ),
                          ],
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                            const SizedBox(height: 16),
                            Text(
                              'Oops! Algo deu errado',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Erro: ${snapshot.error}',
                              style: TextStyle(color: Colors.grey[400], fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () => setState(() {
                                _todayItemsFuture = _fetchDataForSelectedDate();
                              }),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE91E63),
                              ),
                              child: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                       return Center(
                         child: SingleChildScrollView(
                           child: Padding(
                             padding: const EdgeInsets.all(32.0),
                             child: Column(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 Container(
                                   width: 100,
                                   height: 100,
                                   decoration: BoxDecoration(
                                     shape: BoxShape.circle,
                                     gradient: LinearGradient(
                                       begin: Alignment.topLeft,
                                       end: Alignment.bottomRight,
                                       colors: [
                                         const Color(0xFFE91E63).withOpacity(0.1),
                                         const Color(0xFFE91E63).withOpacity(0.05),
                                       ],
                                     ),
                                     border: Border.all(
                                       color: const Color(0xFFE91E63).withOpacity(0.2),
                                       width: 2,
                                     ),
                                   ),
                                   child: Icon(
                                     Icons.spa_outlined,
                                     size: 50,
                                     color: const Color(0xFFE91E63).withOpacity(0.8),
                                   ),
                                 ),
                                 const SizedBox(height: 24),
                                 Text(
                                   _selectedDate.day == DateTime.now().day 
                                     ? "Seu dia está livre!" 
                                     : "Nada programado",
                                   style: const TextStyle(
                                     color: Colors.white,
                                     fontSize: 22,
                                     fontWeight: FontWeight.bold,
                                   ),
                                 ),
                                 const SizedBox(height: 8),
                                 Text(
                                   "Que tal adicionar um novo hábito\nou tarefa para melhorar sua rotina?",
                                   style: TextStyle(
                                     color: Colors.grey[400],
                                     fontSize: 14,
                                     height: 1.4,
                                   ),
                                   textAlign: TextAlign.center,
                                 ),
                                 const SizedBox(height: 24),
                                 Container(
                                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                   decoration: BoxDecoration(
                                     color: const Color(0xFF1E1E1E),
                                     borderRadius: BorderRadius.circular(20),
                                     border: Border.all(
                                       color: Colors.grey[800]!,
                                       width: 1,
                                     ),
                                   ),
                                   child: Row(
                                     mainAxisSize: MainAxisSize.min,
                                     children: [
                                       Icon(Icons.lightbulb_outline, 
                                         color: Colors.amber[400], 
                                         size: 18
                                       ),
                                       const SizedBox(width: 6),
                                       Text(
                                         "Dica: Use o botão + abaixo",
                                         style: TextStyle(
                                           color: Colors.grey[300],
                                           fontSize: 13,
                                         ),
                                       ),
                                     ],
                                   ),
                                 ),
                               ],
                             ),
                           ),
                         ),
                       );
                    }
                    final items = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Reduzindo padding vertical
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
  }
}
