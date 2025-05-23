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
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late DateTime _selectedDate;
  late List<DateTime> _weekDays;
  int _selectedDayIndex = 0;
  late Future<List<Task>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _weekDays = [];
    // _generateWeekDays() é chamado dentro de initializeDateFormatting
    // _tasksFuture = _fetchTasksForSelectedDate(); // É chamado em _generateWeekDays ou _selectDay

    initializeDateFormatting('pt_BR', null).then((_) {
      if (mounted) {
        setState(() {
          _selectedDate = DateTime.now();
          _generateWeekDays(); 
          // _tasksFuture já é atualizado por _generateWeekDays indiretamente ou por _selectDay
        });
      }
    });
  }

  void _generateWeekDays() {
    DateTime now = _selectedDate; 
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Segunda como início da semana
    _weekDays = List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
    
    int potentialIndex = _weekDays.indexWhere((date) =>
      date.year == _selectedDate.year &&
      date.month == _selectedDate.month &&
      date.day == _selectedDate.day
    );

    if (potentialIndex != -1) {
      _selectedDayIndex = potentialIndex;
    } else {
      // Se a _selectedDate exata não estiver na nova semana (pode acontecer ao navegar)
      // seleciona o primeiro dia da semana gerada como padrão para a navegação.
      _selectedDayIndex = 0; 
      _selectedDate = _weekDays.isNotEmpty ? _weekDays[0] : DateTime.now();
    }
    // Garante que as tarefas sejam buscadas para a data selecionada após gerar os dias da semana
    _tasksFuture = _fetchTasksForSelectedDate(); 
  }

  void _selectDay(int index) {
    setState(() {
      _selectedDayIndex = index;
      _selectedDate = _weekDays[index];
      _tasksFuture = _fetchTasksForSelectedDate(); 
    });
  }

  void _navigateToNextWeek() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 7));
      _generateWeekDays(); 
      // _tasksFuture é atualizado por _generateWeekDays
    });
  }

  void _navigateToPreviousWeek() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 7));
      _generateWeekDays();
      // _tasksFuture é atualizado por _generateWeekDays
    });
  }

  Future<List<Task>> _fetchTasksForSelectedDate() async {
    if (kDebugMode) {
      print('[HomeScreen] Fetching tasks for selected date: $_selectedDate');
    }
    // Garante que ServiceProvider seja acessado com um contexto válido
    if (!mounted) return [];
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
          title: const Text('Confirmar Exclusão'),
          content: const Text('Você tem certeza que deseja excluir esta tarefa?'),
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
      final success = await taskService.deleteTask(taskId);
      if (success) {
        refreshTasks();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tarefa excluída com sucesso')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Falha ao excluir tarefa')),
          );
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
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Hoje',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () { /* TODO: Implementar busca */ },
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () { /* TODO: Implementar menu lateral ou drawer */ },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () { /* TODO: Implementar ir para data específica */ },
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () { /* TODO: Implementar tela de ajuda */ },
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar week view
          Container(
            height: 100,
            color: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
                  onPressed: _navigateToPreviousWeek,
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(_weekDays.length, (index) {
                      final day = _weekDays[index];
                      final isSelected = index == _selectedDayIndex;
                      
                      return GestureDetector(
                        onTap: () => _selectDay(index),
                        child: Container(
                          width: 38, // Largura REDUZIDA de 45 para 38
                          height: 70,
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFE91E63) : const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _getDayName(day.weekday),
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                day.day.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
                  onPressed: _navigateToNextWeek,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.black,
              child: FutureBuilder<List<Task>>(
                future: _tasksFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && _weekDays.isEmpty) {
                     // Mostra o indicator apenas se os weekDays ainda não foram carregados também.
                    return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63))));
                  } else if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63))));
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erro: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return SingleChildScrollView(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 50.0),
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
                                        color: Color(0xFF00BFA5), // Cor do FAB no screenshot
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
                             // Idealmente, markTaskCompletion deveria retornar um Future<bool> para sabermos se foi sucesso
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
          // Seção Premium (mantida como no original)
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
      ),
    );
  }
}
