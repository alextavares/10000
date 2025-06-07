import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/models/task.dart';
import 'package:myapp/services/service_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

enum TaskPriority { high, normal, low }

class AddTaskScreen extends StatefulWidget {
  final Task? taskToEdit;

  const AddTaskScreen({super.key, this.taskToEdit});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  
  String? _selectedCategory;
  DateTime? _selectedDueDate;
  TimeOfDay? _selectedReminderTime;
  bool _notificationsEnabled = false;
  TaskPriority _priority = TaskPriority.normal;
  bool _isPending = false;

  final List<String> _subitems = [];

  bool _isLoading = false;
  String? _errorMessage;

  bool get _isEditing => widget.taskToEdit != null;
  final Uuid uuid = const Uuid();

  final List<String> _taskCategories = [
    'Trabalho',
    'Pessoal',
    'Estudo',
    'Saúde',
    'Finanças',
    'Casa',
    'Tarefa',
    'Outros'
  ];

  @override
  void initState() {
    super.initState();
    if (_isEditing && widget.taskToEdit != null) {
      final task = widget.taskToEdit!;
      _titleController = TextEditingController(text: task.title);
      _notesController = TextEditingController(text: task.description ?? '');
      _selectedCategory = task.category ?? 'Tarefa';
      _selectedDueDate = task.dueDate;
      _selectedReminderTime = task.reminderTime;
      _notificationsEnabled = task.notificationsEnabled;
      _isPending = !task.isCompleted;
      // TODO: Load priority from task when model supports it
    } else {
      _titleController = TextEditingController();
      _notesController = TextEditingController();
      _selectedDueDate = DateTime.now();
      _selectedCategory = 'Tarefa';
      _isPending = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
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
    // Verifica o formulário
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos obrigatórios'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // Validação adicional do título
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O nome da tarefa não pode estar vazio'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Busca o ServiceProvider diretamente da árvore de widgets
      final serviceProvider = context.dependOnInheritedWidgetOfExactType<ServiceProvider>();
      if (serviceProvider == null) {
        throw Exception('ServiceProvider não encontrado. Verifique se o app está configurado corretamente.');
      }
      
      final taskService = serviceProvider.taskService;
      final now = DateTime.now();

      if (_isEditing) {
        final updatedTask = widget.taskToEdit!.copyWith(
          title: _titleController.text.trim(),
          category: _selectedCategory,
          dueDate: _selectedDueDate,
          reminderTime: _notificationsEnabled ? _selectedReminderTime : null,
          notificationsEnabled: _notificationsEnabled,
          updatedAt: now,
          description: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          type: TaskType.yesNo,
          isCompleted: !_isPending,
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
          isCompleted: !_isPending,
          completionHistory: {},
          description: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
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
      debugPrint('Error saving task: $e');
      debugPrint('Stack trace: $s');
      if (mounted) {
        setState(() {
          _errorMessage = 'Falha ao salvar tarefa: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteTask() async {
    if (!_isEditing || widget.taskToEdit == null) return;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text('Excluir tarefa?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Esta ação não pode ser desfeita.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('EXCLUIR', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _isLoading = true);
      try {
        // Usar a extensão do ServiceProvider
        final taskService = context.taskService;
        final success = await taskService.deleteTask(widget.taskToEdit!.id);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tarefa excluída!'), backgroundColor: Colors.red),
          );
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Editar tarefa' : 'Nova tarefa',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
              ),
            )
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                        // Task Title Input
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              const Icon(Icons.edit, color: Colors.pinkAccent, size: 24),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                controller: _titleController,
                                style: const TextStyle(color: Colors.white, fontSize: 18),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Nome da tarefa',
                                  hintStyle: TextStyle(color: Colors.grey),
                                ),
                                autofocus: !_isEditing,
                                // Configurações para permitir caracteres especiais
                                enableSuggestions: true,
                                autocorrect: true,
                                textCapitalization: TextCapitalization.sentences,
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'O nome da tarefa é obrigatório';
                                  }
                                  return null;
                                },
                              ),
                              ),
                            ],
                          ),
                        ),
                        Divider(color: Colors.grey[800], height: 1),
                        const SizedBox(height: 8),

                        // Category
                        _buildOptionTile(
                          icon: Icons.category,
                          iconColor: Colors.pinkAccent,
                          title: 'Categoria',
                          value: Row(
                            children: [
                              Text(
                                _selectedCategory ?? 'Tarefa',
                                style: const TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.pinkAccent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Tarefa',
                                      style: TextStyle(color: Colors.white, fontSize: 14),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Icon(
                                        Icons.access_time,
                                        color: Colors.pinkAccent,
                                        size: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          onTap: _showCategorySelectionDialog,
                        ),

                        // Date
                        _buildOptionTile(
                          icon: Icons.calendar_today,
                          iconColor: Colors.pinkAccent,
                          title: 'Data',
                          value: Text(
                            _selectedDueDate == null
                                ? 'Hoje'
                                : DateFormat('dd/MM/yyyy').format(_selectedDueDate!),
                            style: const TextStyle(
                              color: Colors.pinkAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () => _selectDueDate(context),
                        ),

                        // Reminder
                        _buildOptionTile(
                          icon: Icons.notifications_outlined,
                          iconColor: Colors.pinkAccent,
                          title: 'Horário e lembretes',
                          value: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _notificationsEnabled && _selectedReminderTime != null ? '1' : '0',
                              style: const TextStyle(
                                color: Colors.pinkAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          onTap: () => _selectReminderTime(context),
                        ),

                        // Subitems
                        _buildOptionTile(
                          icon: Icons.checklist,
                          iconColor: Colors.pinkAccent,
                          title: 'Subitens',
                          subtitle: _isEditing ? 'Funcionalidade Premium' : null,
                          value: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _subitems.length.toString(),
                              style: const TextStyle(
                                color: Colors.pinkAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Funcionalidade Premium!'),
                                backgroundColor: Colors.pinkAccent,
                              ),
                            );
                          },
                        ),

                        // Only show these fields in edit mode
                        if (_isEditing) ...[
                          // Priority
                          _buildOptionTile(
                            icon: Icons.flag_outlined,
                            iconColor: Colors.pinkAccent,
                            title: 'Prioridade',
                            value: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getPriorityColor().withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _getPriorityText(),
                                style: TextStyle(
                                  color: _getPriorityColor(),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            onTap: _showPriorityDialog,
                          ),

                          // Notes
                          _buildOptionTile(
                            icon: Icons.comment_outlined,
                            iconColor: Colors.pinkAccent,
                            title: 'Anotação',
                            value: _notesController.text.isNotEmpty
                                ? const Icon(Icons.check, color: Colors.pinkAccent, size: 20)
                                : null,
                            onTap: _showNotesDialog,
                          ),

                          const SizedBox(height: 24),

                          // Pending Task Toggle
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_box_outlined,
                                      color: _isPending ? Colors.pinkAccent : Colors.grey,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 16),
                                    const Expanded(
                                      child: Text(
                                        'Tarefa pendente',
                                        style: TextStyle(color: Colors.white, fontSize: 16),
                                      ),
                                    ),
                                    Transform.scale(
                                      scale: 0.8,
                                      child: Switch(
                                        value: _isPending,
                                        onChanged: (value) {
                                          setState(() {
                                            _isPending = value;
                                          });
                                        },
                                        activeColor: Colors.pinkAccent,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Será exibida todos os dias até ser concluída.',
                                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Delete Button
                          InkWell(
                            onTap: _deleteTask,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, color: Colors.red[400], size: 24),
                                  const SizedBox(width: 16),
                                  Text(
                                    'Excluir',
                                    style: TextStyle(color: Colors.red[400], fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // Bottom Buttons (only for new task)
                if (!_isEditing)
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: _isLoading
                                ? null
                                : () => Navigator.of(context).pop(false),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'CANCELAR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveTask,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pinkAccent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'CONFIRME',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: _isEditing
          ? FloatingActionButton(
              onPressed: _isLoading ? null : _saveTask,
              backgroundColor: Colors.pinkAccent,
              child: const Icon(Icons.check, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Color? subtitleColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: subtitleColor ?? Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.pinkAccent,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
            if (value != null) value,
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor() {
    switch (_priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.normal:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }

  String _getPriorityText() {
    switch (_priority) {
      case TaskPriority.high:
        return 'Alta';
      case TaskPriority.normal:
        return 'Normal';
      case TaskPriority.low:
        return 'Baixa';
    }
  }

  void _showPriorityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text('Prioridade', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPriorityOption(TaskPriority.high, 'Alta', Colors.red),
            _buildPriorityOption(TaskPriority.normal, 'Normal', Colors.orange),
            _buildPriorityOption(TaskPriority.low, 'Baixa', Colors.green),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('FECHAR', style: TextStyle(color: Colors.pinkAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityOption(TaskPriority priority, String label, Color color) {
    return ListTile(
      leading: Icon(Icons.flag, color: color),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: _priority == priority
          ? const Icon(Icons.check, color: Colors.pinkAccent)
          : null,
      onTap: () {
        setState(() {
          _priority = priority;
        });
        Navigator.of(context).pop();
      },
    );
  }

  void _showNotesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text('Anotação', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _notesController,
          maxLines: 5,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Digite suas anotações aqui...',
            hintStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.multiline,
          enableSuggestions: true,
          autocorrect: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              setState(() {});
              Navigator.of(context).pop();
            },
            child: const Text('SALVAR', style: TextStyle(color: Colors.pinkAccent)),
          ),
        ],
      ),
    );
  }
}
