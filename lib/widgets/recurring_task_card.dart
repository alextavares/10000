import 'package:flutter/material.dart';
import 'package:myapp/models/recurring_task.dart';

class RecurringTaskCard extends StatelessWidget {
  final RecurringTask recurringTask;
  final Function(String, bool) onToggleCompletion;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const RecurringTaskCard({
    super.key,
    required this.recurringTask,
    required this.onToggleCompletion,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = recurringTask.isCompletedToday();
    final completionPercentage = recurringTask.getTodaysCompletionPercentage();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: isCompleted 
          ? Border.all(color: Colors.green, width: 1)
          : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onToggleCompletion(recurringTask.id, !isCompleted),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Completion indicator
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCompleted ? Colors.green : Colors.grey,
                          width: 2,
                        ),
                        color: isCompleted ? Colors.green : Colors.transparent,
                      ),
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    // Task title and category
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recurringTask.title,
                            style: TextStyle(
                              color: isCompleted ? Colors.grey : Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              decoration: isCompleted 
                                ? TextDecoration.lineThrough 
                                : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: recurringTask.getPriorityColor().withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  recurringTask.category,
                                  style: TextStyle(
                                    color: recurringTask.getPriorityColor(),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE91E63).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Recorrente',
                                  style: const TextStyle(
                                    color: Color(0xFFE91E63),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Priority indicator
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: recurringTask.getPriorityColor(),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // More options
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.grey),
                      color: Colors.grey[800],
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit?.call();
                            break;
                          case 'delete':
                            onDelete?.call();
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text('Editar', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text('Excluir', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (recurringTask.description != null && recurringTask.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    recurringTask.description!,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                // Progress bar for tracking types that support it
                if (recurringTask.trackingType == RecurringTaskTrackingType.listaAtividades) ...[
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: completionPercentage,
                          backgroundColor: Colors.grey[700],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            completionPercentage == 1.0 ? Colors.green : const Color(0xFFE91E63),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(completionPercentage * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
                // Frequency info
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.repeat,
                      color: Colors.grey[400],
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getFrequencyDisplayText(),
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    if (recurringTask.streak > 0) ...[
                      Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${recurringTask.streak}',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getFrequencyDisplayText() {
    switch (recurringTask.frequency) {
      case RecurringTaskFrequency.daily:
        return 'Todos os dias';
      case RecurringTaskFrequency.someDaysOfWeek:
        return 'Alguns dias da semana';
      case RecurringTaskFrequency.specificDaysOfMonth:
        return 'Dias específicos do mês';
      case RecurringTaskFrequency.specificDaysOfYear:
        return 'Dias específicos do ano';
      case RecurringTaskFrequency.someTimesPerPeriod:
        return 'Algumas vezes por período';
      case RecurringTaskFrequency.repeat:
        return 'Repetir';
    }
  }
}