import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/services/habit_service.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/utils/logger.dart';
import 'package:myapp/widgets/custom_text_field.dart';
import 'package:myapp/widgets/custom_button.dart';

class EditHabitScreen extends StatefulWidget {
  final Habit habit;

  const EditHabitScreen({
    super.key,
    required this.habit,
  });

  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late HabitFrequency _frequency;
  late List<int> _selectedDaysOfWeek;
  late List<int> _selectedDaysOfMonth;
  late TimeOfDay? _reminderTime;
  late bool _notificationsEnabled;
  late Color _selectedColor;
  late IconData _selectedIcon;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.habit.title);
    _descriptionController = TextEditingController(text: widget.habit.description);
    _frequency = widget.habit.frequency;
    _selectedDaysOfWeek = List.from(widget.habit.daysOfWeek ?? []);
    _selectedDaysOfMonth = List.from(widget.habit.daysOfMonth ?? []);
    _reminderTime = widget.habit.reminderTime;
    _notificationsEnabled = widget.habit.notificationsEnabled;
    _selectedColor = widget.habit.color;
    _selectedIcon = widget.habit.icon;
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

    setState(() {
      _isLoading = true;
    });

    try {
      final habitService = context.read<HabitService>();
      
      // Create updated habit
      final updatedHabit = Habit(
        id: widget.habit.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        frequency: _frequency,
        daysOfWeek: _frequency == HabitFrequency.weekly || _frequency == HabitFrequency.custom
            ? _selectedDaysOfWeek
            : null,
        daysOfMonth: _frequency == HabitFrequency.monthly ? _selectedDaysOfMonth : null,
        reminderTime: _reminderTime,
        notificationsEnabled: _notificationsEnabled,
        color: _selectedColor,
        icon: _selectedIcon,
        category: widget.habit.category,
        priority: widget.habit.priority,
        trackingType: widget.habit.trackingType,
        completionHistory: widget.habit.completionHistory,
        createdAt: widget.habit.createdAt,
        updatedAt: DateTime.now(),
        userId: widget.habit.userId,
        isArchived: widget.habit.isArchived,
        streak: widget.habit.streak,
        longestStreak: widget.habit.longestStreak,
        totalCompletions: widget.habit.totalCompletions,
        targetQuantity: widget.habit.targetQuantity,
        quantityUnit: widget.habit.quantityUnit,
        targetTime: widget.habit.targetTime,
        subtasks: widget.habit.subtasks,
        dailyProgress: widget.habit.dailyProgress,
        startDate: widget.habit.startDate,
        targetDate: widget.habit.targetDate,
        timesPerPeriod: widget.habit.timesPerPeriod,
        periodType: widget.habit.periodType,
        repeatEveryDays: widget.habit.repeatEveryDays,
        isFlexible: widget.habit.isFlexible,
        alternateDays: widget.habit.alternateDays,
        specificYearDates: widget.habit.specificYearDates,
        aiSuggestions: widget.habit.aiSuggestions,
      );

      await habitService.updateHabit(updatedHabit);

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      Logger.error('Error updating habit: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar hábito: $e')),
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
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: const Text(
          'Editar Hábito',
          style: TextStyle(color: AppTheme.textColor),
        ),
        iconTheme: const IconThemeData(color: AppTheme.textColor),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveChanges,
            child: const Text(
              'Salvar',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Field
                  CustomTextField(
                    controller: _titleController,
                    label: 'Nome do hábito',
                    placeholder: 'Ex: Beber água',
                    prefixIcon: Icons.edit,
                  ),
                  const SizedBox(height: 16),

                  // Description Field
                  CustomTextField(
                    controller: _descriptionController,
                    label: 'Descrição (opcional)',
                    placeholder: 'Ex: Beber 2 litros de água por dia',
                    prefixIcon: Icons.description,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Frequency Section
                  Text(
                    'Frequência',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFrequencySelector(),
                  const SizedBox(height: 24),

                  // Days Selection (if applicable)
                  if (_frequency == HabitFrequency.weekly ||
                      _frequency == HabitFrequency.custom)
                    _buildWeekDaysSelector(),
                  
                  if (_frequency == HabitFrequency.monthly)
                    _buildMonthDaysSelector(),

                  const SizedBox(height: 24),

                  // Reminder Section
                  _buildReminderSection(),
                  const SizedBox(height: 24),

                  // Color and Icon Section
                  _buildColorAndIconSection(),
                  const SizedBox(height: 32),

                  // Delete Button
                  CustomButton(
                    text: 'Excluir Hábito',
                    onPressed: _deleteHabit,
                    backgroundColor: AppTheme.errorColor,
                    textColor: Colors.white,
                    icon: Icons.delete_outline,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFrequencySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildFrequencyChip('Diário', HabitFrequency.daily),
        _buildFrequencyChip('Semanal', HabitFrequency.weekly),
        _buildFrequencyChip('Mensal', HabitFrequency.monthly),
        _buildFrequencyChip('Personalizado', HabitFrequency.custom),
      ],
    );
  }

  Widget _buildFrequencyChip(String label, HabitFrequency frequency) {
    final isSelected = _frequency == frequency;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _frequency = frequency;
          });
        }
      },
      selectedColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.textColor,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: AppTheme.surfaceColor,
    );
  }

  Widget _buildWeekDaysSelector() {
    final days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dias da semana',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: List.generate(7, (index) {
            final dayNumber = index + 1;
            final isSelected = _selectedDaysOfWeek.contains(dayNumber);
            return FilterChip(
              label: Text(days[index]),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedDaysOfWeek.add(dayNumber);
                  } else {
                    _selectedDaysOfWeek.remove(dayNumber);
                  }
                  _selectedDaysOfWeek.sort();
                });
              },
              selectedColor: AppTheme.primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textColor,
              ),
              backgroundColor: AppTheme.surfaceColor,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMonthDaysSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dias do mês',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: 31,
            itemBuilder: (context, index) {
              final day = index + 1;
              final isSelected = _selectedDaysOfMonth.contains(day);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedDaysOfMonth.remove(day);
                    } else {
                      _selectedDaysOfMonth.add(day);
                    }
                    _selectedDaysOfMonth.sort();
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryColor : Colors.grey.withOpacity(0.3),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      day.toString(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textColor,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReminderSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.notifications_outlined, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Lembretes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
                activeColor: AppTheme.primaryColor,
              ),
            ],
          ),
          if (_notificationsEnabled) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: _selectTime,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _reminderTime != null
                          ? 'Horário: ${_reminderTime!.format(context)}'
                          : 'Selecionar horário',
                      style: TextStyle(color: AppTheme.textColor),
                    ),
                    Icon(Icons.access_time, color: AppTheme.primaryColor),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildColorAndIconSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.palette_outlined, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Personalização',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _selectedIcon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  children: [
                    Colors.pink,
                    Colors.purple,
                    Colors.blue,
                    Colors.green,
                    Colors.orange,
                    Colors.red,
                  ].map((color) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: _selectedColor == color
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.primaryColor,
              surface: AppTheme.surfaceColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  Future<void> _deleteHabit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(
          'Excluir Hábito',
          style: TextStyle(color: AppTheme.textColor),
        ),
        content: Text(
          'Tem certeza que deseja excluir "${widget.habit.title}"?',
          style: TextStyle(color: AppTheme.textColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final habitService = context.read<HabitService>();
        await habitService.deleteHabit(widget.habit.id);
        
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } catch (e) {
        Logger.error('Error deleting habit: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir hábito: $e')),
          );
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
