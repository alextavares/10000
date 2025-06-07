import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/models/task.dart';
import 'package:myapp/models/category.dart';
import 'package:myapp/services/service_provider.dart';
import 'package:myapp/services/category_service.dart';
import 'package:myapp/theme/category_colors.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

enum TaskPriority { high, normal, low }

class AddTaskScreenRedesigned extends StatefulWidget {
  final Task? taskToEdit;

  const AddTaskScreenRedesigned({super.key, this.taskToEdit});

  @override
  State<AddTaskScreenRedesigned> createState() => _AddTaskScreenRedesignedState();
}

class _AddTaskScreenRedesignedState extends State<AddTaskScreenRedesigned> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  
  String? _selectedCategoryId;
  DateTime? _selectedDueDate;
  TimeOfDay? _selectedReminderTime;
  bool _notificationsEnabled = false;
  TaskPriority _priority = TaskPriority.normal;
  bool _isPending = true;
  bool _showSubitems = false;
  
  final List<String> _subitems = [];
  List<Category> _categories = [];

  bool _isLoading = false;
  final Uuid uuid = const Uuid();

  bool get _isEditing => widget.taskToEdit != null;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    
    if (_isEditing && widget.taskToEdit != null) {
      final task = widget.taskToEdit!;
      _titleController = TextEditingController(text: task.title);
      _notesController = TextEditingController(text: task.description ?? '');
      _selectedCategoryId = task.categoryId;
      _selectedDueDate = task.dueDate;
      _selectedReminderTime = task.reminderTime;
      _notificationsEnabled = task.notificationsEnabled;
      _isPending = !task.isCompleted;
    } else {
      _titleController = TextEditingController();
      _notesController = TextEditingController();
      _selectedDueDate = DateTime.now();
      _isPending = true;
    }
  }

  Future<void> _loadCategories() async {
    final categoryService = ServiceProvider.of<CategoryService>(context);
    final categories = await categoryService.getAllCategories();
    if (mounted) {
      setState(() {
        _categories = categories;
        // Seleciona categoria "Tarefa" por padrão se não estiver editando
        if (!_isEditing && _selectedCategoryId == null) {
          final tarefaCategory = categories.firstWhere(
            (cat) => cat.name == 'Tarefa',
            orElse: () => categories.first,
          );
          _selectedCategoryId = tarefaCategory.id;
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF6B6B),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  Future<void> _selectReminderTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedReminderTime ?? TimeOfDay.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedReminderTime = picked;
        _notificationsEnabled = true;
      });
    }
  }

  Widget _buildFormField({
    required IconData icon,
    required String label,
    required Widget child,
    Color? iconColor,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: (iconColor ?? const Color(0xFFFF6B6B)).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor ?? const Color(0xFFFF6B6B),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final taskService = ServiceProvider.of(context).taskService;
      final task = Task(
        id: _isEditing ? widget.taskToEdit!.id : uuid.v4(),
        title: _titleController.text.trim(),
        description: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        categoryId: _selectedCategoryId,
        category: _categories.firstWhere((cat) => cat.id == _selectedCategoryId).name,
        dueDate: _selectedDueDate,
        reminderTime: _selectedReminderTime,
        notificationsEnabled: _notificationsEnabled,
        isCompleted: !_isPending,
        createdAt: _isEditing ? widget.taskToEdit!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (_isEditing) {
        await taskService.updateTask(task);
      } else {
        await taskService.addTask(task);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar tarefa: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final selectedCategory = _categories.firstWhereOrNull(
      (cat) => cat.id == _selectedCategoryId
    );
    final categoryColor = selectedCategory != null
        ? CategoryColors.getCategoryColor(selectedCategory.name, isDarkMode)
        : const Color(0xFFFF6B6B);

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isEditing ? 'Editar tarefa' : 'Nova tarefa',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Campo de título
              _buildFormField(
                icon: Icons.edit,
                label: 'Título',
                child: TextFormField(
                  controller: _titleController,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Digite o título da tarefa',
                    hintStyle: TextStyle(
                      color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                    ),
                    border: InputBorder.none,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, insira um título';
                    }
                    return null;
                  },
                ),
              ),

              // Categoria
              _buildFormField(
                icon: Icons.category,
                label: 'Categoria',
                iconColor: categoryColor,
                child: InkWell(
                  onTap: () => _showCategoryPicker(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: categoryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        if (selectedCategory != null) ...[
                          Icon(
                            selectedCategory.icon,
                            color: categoryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          selectedCategory?.name ?? 'Selecionar categoria',
                          style: TextStyle(
                            color: categoryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Data
              _buildFormField(
                icon: Icons.calendar_today,
                label: 'Data',
                child: InkWell(
                  onTap: () => _selectDueDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      _selectedDueDate != null
                          ? DateFormat('dd/MM/yyyy').format(_selectedDueDate!)
                          : 'Selecionar data',
                      style: TextStyle(
                        color: const Color(0xFFFF6B6B),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),

              // Horário e lembretes
              _buildFormField(
                icon: Icons.notifications_outlined,
                label: 'Horário e lembretes',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _notificationsEnabled && _selectedReminderTime != null
                          ? _selectedReminderTime!.format(context)
                          : 'Desativado',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                    InkWell(
                      onTap: () => _selectReminderTime(context),
                      child: Container(
                        width: 48,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _notificationsEnabled 
                              ? const Color(0xFFFF6B6B) 
                              : Colors.grey[600],
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            _notificationsEnabled ? '1' : '0',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Subitens (Premium)
              _buildFormField(
                icon: Icons.checklist,
                label: 'Subitens',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Funcionalidade Premium',
                          style: TextStyle(
                            color: const Color(0xFFFF6B6B),
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '0 subitens',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 48,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text(
                          '0',
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

              // Prioridade
              _buildFormField(
                icon: Icons.flag_outlined,
                label: 'Prioridade',
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getPriorityColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getPriorityColor().withOpacity(0.3),
                    ),
                  ),
                  child: DropdownButton<TaskPriority>(
                    value: _priority,
                    isExpanded: true,
                    underline: const SizedBox(),
                    dropdownColor: isDarkMode ? Colors.grey[900] : Colors.white,
                    style: TextStyle(
                      color: _getPriorityColor(),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    items: TaskPriority.values.map((priority) {
                      return DropdownMenuItem(
                        value: priority,
                        child: Text(_getPriorityText(priority)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _priority = value;
                        });
                      }
                    },
                  ),
                ),
              ),

              // Anotação
              _buildFormField(
                icon: Icons.note_outlined,
                label: 'Anotação',
                child: TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Adicionar anotação...',
                    hintStyle: TextStyle(
                      color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFFF6B6B),
                      ),
                    ),
                  ),
                ),
              ),

              // Tarefa pendente
              _buildFormField(
                icon: Icons.check_box_outlined,
                label: 'Tarefa pendente',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Será exibida todos os dias até ser concluída.',
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Switch(
                      value: _isPending,
                      onChanged: (value) {
                        setState(() {
                          _isPending = value;
                        });
                      },
                      activeColor: const Color(0xFFFF6B6B),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Botão Excluir (apenas quando editando)
              if (_isEditing) ...[
                InkWell(
                  onTap: () => _deleteTask(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Excluir',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _saveTask,
        backgroundColor: const Color(0xFFFF6B6B),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.check, color: Colors.white),
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

  String _getPriorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return 'Alta';
      case TaskPriority.normal:
        return 'Normal';
      case TaskPriority.low:
        return 'Baixa';
    }
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        
        return Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[900] : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Selecionar Categoria',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final color = CategoryColors.getCategoryColor(
                      category.name, 
                      isDarkMode
                    );
                    
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          category.icon,
                          color: color,
                          size: 20,
                        ),
                      ),
                      title: Text(category.name),
                      trailing: _selectedCategoryId == category.id
                          ? Icon(Icons.check, color: color)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedCategoryId = category.id;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteTask() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir tarefa'),
        content: const Text('Tem certeza que deseja excluir esta tarefa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() {
        _isLoading = true;
      });

      try {
        final taskService = ServiceProvider.of(context).taskService;
        await taskService.deleteTask(widget.taskToEdit!.id);
        
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir tarefa: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}

// Extension para firstWhereOrNull
extension ListExtension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}