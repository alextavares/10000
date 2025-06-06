import 'package:flutter/material.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/services/habit_service.dart';
import 'package:provider/provider.dart';
import 'package:myapp/utils/logger.dart';

class HabitEditTab extends StatefulWidget {
  final Habit habit;
  final VoidCallback onHabitUpdated;

  const HabitEditTab({
    super.key,
    required this.habit,
    required this.onHabitUpdated,
  });

  @override
  State<HabitEditTab> createState() => _HabitEditTabState();
}

class _HabitEditTabState extends State<HabitEditTab> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _selectedCategory;
  late String _selectedPriority;
  late HabitFrequency _selectedFrequency;
  late DateTime _startDate;
  DateTime? _targetDate;
  bool _hasReminder = false;
  TimeOfDay? _reminderTime;
  bool _isLoading = false;

  // Priority options
  final List<String> _priorities = ['Baixa', 'Normal', 'Alta'];
  
  // Category options (matching existing categories)
  final Map<String, IconData> _categories = {
    'Saúde': Icons.favorite,
    'Trabalho': Icons.work,
    'Pessoal': Icons.person,
    'Fitness': Icons.fitness_center,
    'Educação': Icons.school,
    'Social': Icons.people,
    'Arte': Icons.palette,
    'Finanças': Icons.attach_money,
    'Outro': Icons.more_horiz,
  };

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.habit.title);
    _descriptionController = TextEditingController(text: widget.habit.description ?? '');
    _selectedCategory = widget.habit.category ?? 'Outro';
    _selectedPriority = widget.habit.priority ?? 'Normal';
    _selectedFrequency = widget.habit.frequency;
    _startDate = widget.habit.startDate;
    _targetDate = widget.habit.targetDate;
    _hasReminder = widget.habit.reminderTime != null;
    _reminderTime = widget.habit.reminderTime;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O título não pode estar vazio')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final habitService = context.read<HabitService>();
      
      // Create updated habit
      final updatedHabit = widget.habit.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        category: _selectedCategory,
        priority: _selectedPriority,
        frequency: _selectedFrequency,
        startDate: _startDate,
        targetDate: _targetDate,
        reminderTime: _hasReminder ? _reminderTime : null,
        notificationsEnabled: _hasReminder,
      );

      await habitService.updateHabit(updatedHabit);
      
      if (mounted) {
        widget.onHabitUpdated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hábito atualizado com sucesso!')),
        );
      }
    } catch (e) {
      Logger.error('Error saving habit changes: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context, bool isTargetDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isTargetDate ? (_targetDate ?? DateTime.now()) : _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: widget.habit.color,
              onPrimary: Colors.white,
              surface: AppTheme.surfaceColor,
              onSurface: AppTheme.textColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        if (isTargetDate) {
          _targetDate = picked;
        } else {
          _startDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: widget.habit.color,
              onPrimary: Colors.white,
              surface: AppTheme.surfaceColor,
              onSurface: AppTheme.textColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nome do hábito
          _buildEditItem(
            icon: Icons.edit,
            iconColor: widget.habit.color,
            label: 'Nome do hábito',
            child: TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Digite o nome do hábito',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Categoria
          _buildEditItem(
            icon: Icons.category,
            iconColor: widget.habit.color,
            label: 'Categoria',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                dropdownColor: AppTheme.surfaceColor,
                style: const TextStyle(color: Colors.white),
                underline: Container(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() => _selectedCategory = newValue);
                  }
                },
                items: _categories.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Row(
                      children: [
                        Icon(entry.value, color: widget.habit.color, size: 20),
                        const SizedBox(width: 12),
                        Text(entry.key),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Descrição
          _buildEditItem(
            icon: Icons.info_outline,
            iconColor: widget.habit.color,
            label: 'Descrição',
            child: TextField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Adicione uma descrição (opcional)',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Horário e lembretes
          _buildEditItem(
            icon: Icons.notifications_outlined,
            iconColor: widget.habit.color,
            label: 'Horário e lembretes',
            trailing: Switch(
              value: _hasReminder,
              onChanged: (value) {
                setState(() => _hasReminder = value);
                if (value && _reminderTime == null) {
                  _selectTime(context);
                }
              },
              activeColor: widget.habit.color,
            ),
            child: _hasReminder && _reminderTime != null
                ? GestureDetector(
                    onTap: () => _selectTime(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text(
                        _reminderTime!.format(context),
                        style: TextStyle(color: widget.habit.color, fontSize: 16),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          
          const SizedBox(height: 16),
          
          // Prioridade
          _buildEditItem(
            icon: Icons.flag_outlined,
            iconColor: widget.habit.color,
            label: 'Prioridade',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: DropdownButton<String>(
                value: _selectedPriority,
                isExpanded: true,
                dropdownColor: AppTheme.surfaceColor,
                style: const TextStyle(color: Colors.white),
                underline: Container(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() => _selectedPriority = newValue);
                  }
                },
                items: _priorities.map((priority) {
                  Color priorityColor = Colors.grey;
                  if (priority == 'Alta') priorityColor = Colors.red;
                  else if (priority == 'Normal') priorityColor = widget.habit.color;
                  else if (priority == 'Baixa') priorityColor = Colors.green;
                  
                  return DropdownMenuItem<String>(
                    value: priority,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: priorityColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            priority,
                            style: TextStyle(color: priorityColor),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Frequência
          _buildEditItem(
            icon: Icons.repeat,
            iconColor: widget.habit.color,
            label: 'Frequência',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                _getFrequencyText(),
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Data de início
          _buildEditItem(
            icon: Icons.calendar_today,
            iconColor: widget.habit.color,
            label: 'Data de início',
            child: GestureDetector(
              onTap: () => _selectDate(context, false),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  '${_startDate.day.toString().padLeft(2, '0')}/${_startDate.month.toString().padLeft(2, '0')}/${_startDate.year}',
                  style: TextStyle(color: widget.habit.color, fontSize: 16),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Data alvo
          _buildEditItem(
            icon: Icons.flag,
            iconColor: widget.habit.color,
            label: 'Data alvo',
            trailing: IconButton(
              icon: Icon(
                _targetDate != null ? Icons.clear : Icons.add,
                color: widget.habit.color,
              ),
              onPressed: () {
                if (_targetDate != null) {
                  setState(() => _targetDate = null);
                } else {
                  _selectDate(context, true);
                }
              },
            ),
            child: _targetDate != null
                ? GestureDetector(
                    onTap: () => _selectDate(context, true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text(
                        '${_targetDate!.day.toString().padLeft(2, '0')}/${_targetDate!.month.toString().padLeft(2, '0')}/${_targetDate!.year}',
                        style: TextStyle(color: widget.habit.color, fontSize: 16),
                      ),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text(
                      '-',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ),
          ),
          
          const SizedBox(height: 32),
          
          // Botão salvar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.habit.color,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Salvar Alterações',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEditItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
  
  String _getFrequencyText() {
    switch (_selectedFrequency) {
      case HabitFrequency.daily:
        return 'Todos os dias';
      case HabitFrequency.weekly:
        if (widget.habit.daysOfWeek != null && widget.habit.daysOfWeek!.isNotEmpty) {
          return '${widget.habit.daysOfWeek!.length}x por semana';
        }
        return 'Semanal';
      case HabitFrequency.monthly:
        if (widget.habit.daysOfMonth != null && widget.habit.daysOfMonth!.isNotEmpty) {
          return 'Dias do mês: ${widget.habit.daysOfMonth!.join(', ')}';
        }
        return 'Mensal';
      default:
        return 'Personalizado';
    }
  }
}
