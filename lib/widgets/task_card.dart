import 'package:flutter/material.dart';
import 'package:myapp/models/task.dart';
// Import AppTheme

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
      color: Theme.of(context).cardTheme.color, // Use theme color
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Match HabitCard
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), // Reduced padding
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
                      color: Theme.of(context).textTheme.titleLarge?.color, // Use theme color
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      decoration: isCompletedToday ? TextDecoration.lineThrough : null,
                      decorationColor: Theme.of(context).textTheme.titleLarge?.color, // Use theme color
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Theme.of(context).iconTheme.color), // Use theme color
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
                      child: Text('Edit', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                    ),
                  ],
                  color: Theme.of(context).cardColor, // Use theme color
                  tooltip: 'More options',
                ),
              ],
            ),
            if (task.description != null && task.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  task.description!,
                  style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 14), // Use theme color
                ),
              ),
            if (task.dueDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Theme.of(context).iconTheme.color, size: 16), // Use theme color
                    const SizedBox(width: 4),
                    Text(
                      'Due: ${task.dueDate!.toLocal().toString().split(' ')[0]}',
                      style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12), // Use theme color
                    ),
                  ],
                ),
              ),
            if (task.reminderTime != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: Theme.of(context).iconTheme.color, size: 16), // Use theme color
                    const SizedBox(width: 4),
                    Text(
                      'Reminder: ${task.reminderTime!.format(context)}',
                      style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12), // Use theme color
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 4), // Reduced height
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    onToggleCompletion(task.id, !isCompletedToday);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCompletedToday ? Colors.grey : Theme.of(context).primaryColor, // Use theme primary color
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Reduced padding
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(isCompletedToday ? 'Mark Incomplete' : 'Mark Complete', style: const TextStyle(fontSize: 12)), // Reduced font size
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
