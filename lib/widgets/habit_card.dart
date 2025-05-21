import 'package:flutter/material.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/theme/app_theme.dart'; // Assuming AppTheme exists for colors

class HabitCard extends StatelessWidget {
  final Habit habit;
  final Function(String habitId, bool isCompleted) onToggleCompletion;
  final DateTime selectedDate; // Add this
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onToggleCompletion,
    required this.selectedDate, // Add this
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Determine if the habit is completed for the selectedDate
    final dateOnly = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    bool isCompleted = habit.completionHistory[dateOnly] == true;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      color: AppTheme.surfaceColor, // Or any other appropriate color
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Icon for the habit
            Icon(habit.icon, color: habit.color, size: 30),
            const SizedBox(width: 16),
            // Habit title and category
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor, // Use theme color
                    ),
                  ),
                  if (habit.description != null && habit.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        habit.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.subtitleColor, // Use theme color for textSecondaryColor
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  Text(
                    habit.category,
                    style: TextStyle(
                      fontSize: 12,
                      color: habit.color.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Completion checkbox
            IconButton(
              icon: Icon(
                isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isCompleted ? AppTheme.primaryColor : Colors.grey,
                size: 30,
              ),
              onPressed: () {
                onToggleCompletion(habit.id, !isCompleted);
              },
            ),
            // Optional Edit and Delete buttons (if needed, could be in a popup menu)
            if (onEdit != null || onDelete != null)
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit' && onEdit != null) {
                    onEdit!();
                  } else if (value == 'delete' && onDelete != null) {
                    onDelete!();
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  if (onEdit != null)
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                  if (onDelete != null)
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                ],
                icon: Icon(Icons.more_vert, color: AppTheme.subtitleColor), // Use theme color for textSecondaryColor
              ),
          ],
        ),
      ),
    );
  }
}
