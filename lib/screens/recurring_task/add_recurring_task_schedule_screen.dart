import 'package:flutter/material.dart';
import 'package:myapp/models/recurring_task.dart';
import 'package:myapp/services/service_provider.dart';

class AddRecurringTaskScheduleScreen extends StatefulWidget {
  final RecurringTaskTrackingType trackingType;
  final String category;
  final String title;
  final String? description;
  final RecurringTaskFrequency frequency;
  final RecurringTask? recurringTaskToEdit;

  const AddRecurringTaskScheduleScreen({
    super.key,
    required this.trackingType,
    required this.category,
    required this.title,
    this.description,
    required this.frequency,
    this.recurringTaskToEdit,
  });

  @override
  State<AddRecurringTaskScheduleScreen> createState() => _AddRecurringTaskScheduleScreenState();
}

class _AddRecurringTaskScheduleScreenState extends State<AddRecurringTaskScheduleScreen> {
  DateTime startDate = DateTime.now();
  DateTime? targetDate;
  bool hasTargetDate = false;
  int reminderCount = 0;
  RecurringTaskPriority priority = RecurringTaskPriority.normal;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.recurringTaskToEdit != null) {
      startDate = widget.recurringTaskToEdit!.startDate;
      targetDate = widget.recurringTaskToEdit!.targetDate;
      hasTargetDate = targetDate != null;
      priority = widget.recurringTaskToEdit!.priority;
      reminderCount = widget.recurringTaskToEdit!.reminderTime != null ? 1 : 0;
    }
  }

  void _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFE91E63),
              onPrimary: Colors.white,
              surface: Color(0xFF2D2D2D),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
      });
    }
  }

  void _selectTargetDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: targetDate ?? startDate.add(const Duration(days: 30)),
      firstDate: startDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFE91E63),
              onPrimary: Colors.white,
              surface: Color(0xFF2D2D2D),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        targetDate = picked;
        hasTargetDate = true;
      });
    }
  }

  void _toggleTargetDate(bool value) {
    setState(() {
      hasTargetDate = value;
      if (!value) {
        targetDate = null;
      }
    });
  }

  void _selectPriority() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selecionar Prioridade',
                  style: TextStyle(
                    color: Color(0xFFE91E63),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                ...RecurringTaskPriority.values.map((p) => _buildPriorityOption(p)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriorityOption(RecurringTaskPriority priorityOption) {
    return ListTile(
      title: Text(
        priorityOption.name.toUpperCase(),
        style: TextStyle(
          color: _getPriorityColor(priorityOption),
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () {
        setState(() {
          priority = priorityOption;
        });
        Navigator.pop(context);
      },
    );
  }

  Color _getPriorityColor(RecurringTaskPriority priority) {
    switch (priority) {
      case RecurringTaskPriority.baixa:
        return Colors.green;
      case RecurringTaskPriority.normal:
        return Colors.blue;
      case RecurringTaskPriority.alta:
        return Colors.orange;
      case RecurringTaskPriority.urgente:
        return Colors.red;
    }
  }

  String _getPriorityDisplayName(RecurringTaskPriority priority) {
    switch (priority) {
      case RecurringTaskPriority.baixa:
        return 'Baixa';
      case RecurringTaskPriority.normal:
        return 'Normal';
      case RecurringTaskPriority.alta:
        return 'Alta';
      case RecurringTaskPriority.urgente:
        return 'Urgente';
    }
  }

  void _saveRecurringTask() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final recurringTaskService = ServiceProvider.of(context).recurringTaskService;
      
      final recurringTask = RecurringTask(
        id: widget.recurringTaskToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: widget.title,
        description: widget.description,
        category: widget.category,
        frequency: widget.frequency,
        trackingType: widget.trackingType,
        priority: priority,
        startDate: startDate,
        targetDate: targetDate,
        createdAt: widget.recurringTaskToEdit?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        completionHistory: widget.recurringTaskToEdit?.completionHistory ?? {},
        dailyProgress: widget.recurringTaskToEdit?.dailyProgress ?? {},
      );

      bool success;
      if (widget.recurringTaskToEdit != null) {
        success = await recurringTaskService.updateRecurringTask(recurringTask);
      } else {
        success = await recurringTaskService.createRecurringTask(recurringTask);
      }

      if (success) {
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.recurringTaskToEdit != null 
                  ? 'Tarefa recorrente atualizada com sucesso!'
                  : 'Tarefa recorrente criada com sucesso!',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao salvar tarefa recorrente. Tente novamente.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Quando você quer fazer isso?',
          style: TextStyle(
            color: Color(0xFFE91E63),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 32),
            Expanded(
              child: ListView(
                children: [
                  _buildScheduleItem(
                    icon: Icons.calendar_today,
                    title: 'Data de início',
                    value: 'Hoje',
                    onTap: _selectStartDate,
                  ),
                  const SizedBox(height: 16),
                  _buildScheduleItem(
                    icon: Icons.calendar_month,
                    title: 'Data alvo',
                    value: null,
                    hasToggle: true,
                    toggleValue: hasTargetDate,
                    onToggle: _toggleTargetDate,
                    onTap: hasTargetDate ? _selectTargetDate : null,
                  ),
                  const SizedBox(height: 16),
                  _buildScheduleItem(
                    icon: Icons.notifications,
                    title: 'Horário e lembretes',
                    value: reminderCount.toString(),
                    onTap: () {
                      // TODO: Implement reminder selection
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildScheduleItem(
                    icon: Icons.flag,
                    title: 'Prioridade',
                    value: _getPriorityDisplayName(priority),
                    onTap: _selectPriority,
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'ANTERIOR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE91E63),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: isLoading ? null : _saveRecurringTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'FINALIZAR',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem({
    required IconData icon,
    required String title,
    String? value,
    bool hasToggle = false,
    bool toggleValue = false,
    Function(bool)? onToggle,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: const Color(0xFFE91E63),
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (hasToggle)
                  Switch(
                    value: toggleValue,
                    onChanged: onToggle,
                    activeColor: const Color(0xFFE91E63),
                  )
                else if (value != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE91E63),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}