import 'package:flutter/material.dart';
import 'package:myapp/models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final Function(String, bool) onToggleCompletion;
  final VoidCallback onEdit; // Callback for edit action
  final VoidCallback onDelete; // Callback for delete action

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
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16.0),
      color: Colors.grey[850], // Use dark gray for card background
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), 
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      color: Colors.white, // White text for title
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      decoration: isCompletedToday ? TextDecoration.lineThrough : null,
                      decorationColor: Colors.white, 
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white), // White icon
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('Edit', style: TextStyle(color: Colors.white)), // White text
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete', style: TextStyle(color: Colors.redAccent)), // Red text for delete
                    ),
                  ],
                  color: Colors.grey[800], // Dark background for popup menu
                  tooltip: 'More options',
                ),
              ],
            ),
            if (task.description != null && task.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  task.description!,
                  style: TextStyle(color: Colors.grey[400], fontSize: 14), // Lighter gray for description
                ),
              ),
            if (task.dueDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.grey, size: 16), // Gray icon
                    const SizedBox(width: 4),
                    Text(
                      'Due: ${task.dueDate!.toLocal().toString().split(' ')[0]}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12), // Lighter gray for date
                    ),
                  ],
                ),
              ),
            if (task.reminderTime != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.grey, size: 16), // Gray icon
                    const SizedBox(width: 4),
                    Text(
                      'Reminder: ${task.reminderTime!.format(context)}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12), // Lighter gray for reminder
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 4), 
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    onToggleCompletion(task.id, !isCompletedToday);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCompletedToday ? Colors.pinkAccent : Colors.pinkAccent, // Use pink for button
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(isCompletedToday ? 'Marcar Incompleto' : 'Marcar Concluído', style: const TextStyle(fontSize: 12)), // Translated text
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
