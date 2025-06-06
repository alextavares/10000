import 'package:flutter/material.dart';
import 'package:myapp/models/task.dart'; // Ensure Task and TaskType are correctly defined
import 'package:myapp/services/service_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart'; // Added import for DateFormat

class AddTaskScreen extends StatefulWidget {
  final Task? taskToEdit;

  const AddTaskScreen({super.key, this.taskToEdit});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  
  String? _selectedCategory;
  DateTime? _selectedDueDate;
  TimeOfDay? _selectedReminderTime;
  bool _notificationsEnabled = false;

  final List<String> _subitems = []; // Placeholder for subitems

  bool _isLoading = false;
  String? _errorMessage;

  bool get _isEditing => widget.taskToEdit != null;
  final Uuid uuid = const Uuid();

  // Define some default categories
  final List<String> _taskCategories = [
    'Trabalho',
    'Pessoal',
    'Estudo',
    'Saúde',
    'Finanças',
    'Casa',
    'Outros'
  ];


  @override
  void initState() {
    super.initState();
    if (_isEditing && widget.taskToEdit != null) {
      final task = widget.taskToEdit!;
      _titleController = TextEditingController(text: task.title);
      _selectedCategory = task.category;
      _selectedDueDate = task.dueDate;
      _selectedReminderTime = task.reminderTime;
      _notificationsEnabled = task.notificationsEnabled;
      // TODO: Initialize _subitems from task.subtasks if Task model supports it
    } else {
      _titleController = TextEditingController();
      _selectedDueDate = DateTime.now(); // Default to today for new tasks
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate(BuildContext context) async {
    if (!mounted) return;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)), // 5 years back
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)), // 10 years forward
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.pinkAccent, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black87, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.pinkAccent, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDueDate) {
      if (!mounted) return;
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  Future<void> _selectReminderTime(BuildContext context) async {
    if (!mounted) return;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedReminderTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.pinkAccent,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
              surface: Colors.white,
            ),
            timePickerTheme: TimePickerThemeData(
                backgroundColor: Colors.grey[900],
                hourMinuteTextColor: WidgetStateColor.resolveWith((states) =>
                    states.contains(WidgetState.selected)
                        ? Colors.pinkAccent
                        : Colors.white70),
                hourMinuteColor: WidgetStateColor.resolveWith((states) =>
                    states.contains(WidgetState.selected)
                        ? Colors.pinkAccent.withAlpha(38)
                        : Colors.grey[800]!),
                dayPeriodTextColor: WidgetStateColor.resolveWith((states) =>
                    states.contains(WidgetState.selected)
                        ? Colors.pinkAccent
                        : Colors.white70),
                dayPeriodColor: WidgetStateColor.resolveWith((states) =>
                    states.contains(WidgetState.selected)
                        ? Colors.pinkAccent.withAlpha(38)
                        : Colors.grey[800]!),
                dialHandColor: Colors.pinkAccent,
                dialTextColor: WidgetStateColor.resolveWith((states) =>
                    states.contains(WidgetState.selected)
                        ? Colors.white
                        : Colors.pinkAccent.withAlpha(178)),
                entryModeIconColor: Colors.pinkAccent,
                dialBackgroundColor: Colors.grey[850],
                helpTextStyle: const TextStyle(color: Colors.white70)),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.pinkAccent,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedReminderTime) {
      if (!mounted) return;
      setState(() {
        _selectedReminderTime = picked;
        _notificationsEnabled = true; // Enable notifications if time is set
      });
    }
  }

  void _showCategorySelectionDialog() {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: const Text('Selecione uma Categoria', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _taskCategories.map((category) {
                return ListTile(
                  title: Text(category, style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar', style: TextStyle(color: Colors.pinkAccent)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final taskService = ServiceProvider.of(context).taskService;
      final now = DateTime.now();
      // Removed taskIdForNotifications as it's not used

      if (_isEditing) {
        final updatedTask = widget.taskToEdit!.copyWith(
          title: _titleController.text.trim(),
          category: _selectedCategory,
          dueDate: _selectedDueDate,
          reminderTime: _notificationsEnabled ? _selectedReminderTime : null,
          notificationsEnabled: _notificationsEnabled,
          updatedAt: now,
          description: null,
          type: TaskType.yesNo, 
        );
        final success = await taskService.updateTask(updatedTask);
        if (!success) {
          throw Exception('Failed to update task.');
        }
      } else {
        final newTaskData = Task(
          id: uuid.v4(),
          title: _titleController.text.trim(),
          category: _selectedCategory,
          dueDate: _selectedDueDate,
          reminderTime: _notificationsEnabled ? _selectedReminderTime : null,
          notificationsEnabled: _notificationsEnabled,
          createdAt: now,
          updatedAt: now,
          isCompleted: false,
          completionHistory: {},
          description: null,
          type: TaskType.yesNo, 
        );
        final String? firestoreDocId = await taskService.addTask(newTaskData);
        if (firestoreDocId == null) {
          throw Exception("Failed to add task: Firestore did not return an ID.");
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditing ? 'Tarefa atualizada!' : 'Tarefa adicionada!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e, s) {
      debugPrint('Error saving task: $e'); // Changed print to debugPrint
      debugPrint('Stack trace: $s'); // Changed print to debugPrint
      if (mounted) {
        setState(() {
          _errorMessage = 'Falha ao salvar tarefa: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, 
      appBar: AppBar(
        title: const Text('Nova tarefa',
            style: TextStyle(
                color: Colors.pinkAccent,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.black, 
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), 
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.pinkAccent)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.redAccent.shade100, fontWeight: FontWeight.bold),
                        ),
                      ),
                    // Task Title Input
                    TextFormField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                      decoration: InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.pinkAccent.withValues(alpha: 0.5)),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.pinkAccent, width: 2),
                        ),
                        labelText: 'Tarefa',
                        labelStyle: TextStyle(color: Colors.grey[400]),
                        floatingLabelStyle: const TextStyle(color: Colors.pinkAccent),
                        suffixIcon: const Icon(Icons.edit, color: Colors.grey),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, insira um título para a tarefa';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Category
                    ListTile(
                      leading: const Icon(Icons.grid_on, color: Colors.pinkAccent),
                      title: const Text('Categoria', style: TextStyle(color: Colors.white)),
                      subtitle: Text(
                        _selectedCategory ?? 'Não definido',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      trailing: const Text(
                        'Tarefa', 
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      onTap: _showCategorySelectionDialog,
                      tileColor: Colors.grey[850],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    const SizedBox(height: 10),

                    // Date
                    ListTile(
                      leading: const Icon(Icons.calendar_month, color: Colors.pinkAccent),
                      title: const Text('Data', style: TextStyle(color: Colors.white)),
                      subtitle: Text(
                        _selectedDueDate == null
                            ? 'Não definida'
                            : DateFormat('dd/MM/yyyy').format(_selectedDueDate!),
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedDueDate = DateTime.now();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Hoje'),
                      ),
                      onTap: () => _selectDueDate(context), // Corrected: wrapped in an anonymous function
                      tileColor: Colors.grey[850],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    const SizedBox(height: 10),

                    // Reminder
                    ListTile(
                      leading: const Icon(Icons.notifications_none, color: Colors.pinkAccent),
                      title: const Text('Horário e lembretes', style: TextStyle(color: Colors.white)),
                      subtitle: Text(
                        _selectedReminderTime == null
                            ? 'Não definido'
                            : MaterialLocalizations.of(context).formatTimeOfDay(_selectedReminderTime!),
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.pinkAccent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _notificationsEnabled && _selectedReminderTime != null ? '1' : '0',
                          style: const TextStyle(color: Colors.pinkAccent, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      onTap: () => _selectReminderTime(context), // Corrected: wrapped in an anonymous function
                      tileColor: Colors.grey[850],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    const SizedBox(height: 10),

                    // Subitems
                    ListTile(
                      leading: const Icon(Icons.checklist, color: Colors.pinkAccent),
                      title: const Text('Subitens', style: TextStyle(color: Colors.white)),
                      trailing: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.pinkAccent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _subitems.length.toString(),
                          style: const TextStyle(color: Colors.pinkAccent, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      onTap: () {
                        // TODO: Implement navigation to a subitem management screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Funcionalidade de subitens em desenvolvimento!')),
                        );
                      },
                      tileColor: Colors.grey[850],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    const SizedBox(height: 32),

                    // Bottom Buttons (CANCELAR and CONFIRME)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    Navigator.of(context).pop(false); // Indicate cancellation
                                  },
                            child: const Text('CANCELAR',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveTask,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pinkAccent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              disabledBackgroundColor: Colors.grey[700],
                              disabledForegroundColor: Colors.grey[400],
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : const Text('CONFIRME', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
