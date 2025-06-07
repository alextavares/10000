import 'package:flutter/material.dart';
import 'package:myapp/models/recurring_task.dart';
import 'package:intl/intl.dart';

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
    
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12.0),
      color: Colors.grey[900], // Cor de fundo mais escura
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recurringTask.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                          decorationColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getFrequencyDisplayText(),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit?.call();
                    } else if (value == 'delete') {
                      onDelete?.call();
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('Editar', style: TextStyle(color: Colors.white)),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Excluir', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                  color: Colors.grey[800],
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  onToggleCompletion(recurringTask.id, !isCompleted);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63), // Rosa como no concorrente
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  isCompleted ? 'Marcar como Pendente' : 'Marcar Concluído',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
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