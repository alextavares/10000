import 'package:flutter/material.dart';
import 'package:myapp/models/task.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final Function(String, bool) onToggleCompletion;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggleCompletion,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isCompletedToday = task.isCompletedToday();
    
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
                        task.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          decoration: isCompletedToday ? TextDecoration.lineThrough : null,
                          decorationColor: Colors.white,
                        ),
                      ),
                      if (task.dueDate != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            'Due: ${DateFormat('dd/MM/yy').format(task.dueDate!)}',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
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
                  onToggleCompletion(task.id, !isCompletedToday);
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
                  isCompletedToday ? 'Marcar como Pendente' : 'Marcar Concluído',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
