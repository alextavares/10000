import 'package:flutter/material.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/models/habit.dart';

/// A card widget that displays a habit.
class HabitCard extends StatelessWidget {
  /// The habit to display.
  final Habit habit;

  /// Callback when the card is tapped.
  final VoidCallback onTap;

  /// Callback when the completion status is toggled.
  final Function(bool completed) onToggleCompletion;

  /// Callback when the delete action is triggered.
  final VoidCallback onDelete; // Added onDelete callback

  /// Constructor for HabitCard.
  const HabitCard({
    super.key,
    required this.habit,
    required this.onTap,
    required this.onToggleCompletion,
    required this.onDelete, // Added onDelete to constructor
    // required DateTime selectedDate, // Removed selectedDate parameter
  });

  @override
  Widget build(BuildContext context) {
    final isCompletedToday = habit.isCompletedToday();
    final streak = habit.streak;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Added margin
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(habit.category).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        _getCategoryIcon(habit.category),
                        color: _getCategoryColor(habit.category),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Habit details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColor,
                          ),
                          maxLines: 1, // Ensure title doesn't wrap too much
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (habit.description != null && habit.description!.isNotEmpty)
                          Text(
                            habit.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.subtitleColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),

                  // Completion checkbox
                  Checkbox(
                    value: isCompletedToday,
                    onChanged: (value) {
                      onToggleCompletion(value ?? false);
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),

              // Bottom row with time, streak, and delete icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Time or Frequency
                  Row(
                    children: [
                      Icon(
                        habit.reminderTime != null ? Icons.access_time : Icons.event_repeat,
                        size: 16,
                        color: AppTheme.subtitleColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getTimeOrFrequencyText(context),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.subtitleColor,
                        ),
                      ),
                    ],
                  ),

                  // Streak
                  if (streak > 0)
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          size: 16,
                          color: Colors.orange[700], // Darker orange
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$streak day${streak == 1 ? '' : 's'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange[700], // Darker orange
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                  // Delete Button
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red[700]),
                    onPressed: onDelete,
                    tooltip: 'Delete Habit',
                    padding: EdgeInsets.zero, // Reduce padding to make it more compact
                    constraints: const BoxConstraints(), // Reduce constraints
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeOrFrequencyText(BuildContext context) {
    if (habit.reminderTime != null) {
      final localizations = MaterialLocalizations.of(context);
      return localizations.formatTimeOfDay(habit.reminderTime!, alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat);
    } else {
      switch(habit.frequency) {
        case HabitFrequency.daily:
          return 'Daily';
        case HabitFrequency.weekly:
          // Show selected days for weekly
          if (habit.daysOfWeek != null && habit.daysOfWeek!.isNotEmpty) {
            List<String> dayAbbreviations = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
            String selectedDays = habit.daysOfWeek!.map((d) => dayAbbreviations[d-1]).join(', ');
            return 'Weekly ($selectedDays)';
          }
          return 'Weekly';
        case HabitFrequency.monthly:
           return 'Monthly (Day ${habit.createdAt.day})'; // Example: Monthly (Day 15)
        case HabitFrequency.custom:
          // Similar to weekly, show selected days for custom
          if (habit.daysOfWeek != null && habit.daysOfWeek!.isNotEmpty) {
            List<String> dayAbbreviations = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
            String selectedDays = habit.daysOfWeek!.map((d) => dayAbbreviations[d-1]).join(', ');
            return 'Custom ($selectedDays)';
          }
          return 'Custom';
        default:
          return 'No reminder';
      }
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'health':
        return Icons.favorite_border;
      case 'fitness':
        return Icons.fitness_center;
      case 'productivity':
        return Icons.work_outline;
      case 'education':
        return Icons.school_outlined;
      case 'finance':
        return Icons.attach_money;
      case 'social':
        return Icons.people_outline;
      case 'mindfulness':
        return Icons.self_improvement_outlined;
      case 'creativity':
        return Icons.brush_outlined;
      default:
        return Icons.star_border;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'health':
        return Colors.redAccent;
      case 'fitness':
        return Colors.lightBlueAccent;
      case 'productivity':
        return Colors.greenAccent;
      case 'education':
        return Colors.purpleAccent;
      case 'finance':
        return Colors.amberAccent;
      case 'social':
        return Colors.pinkAccent;
      case 'mindfulness':
        return Colors.tealAccent;
      case 'creativity':
        return Colors.orangeAccent;
      default:
        return AppTheme.primaryColor;
    }
  }
}
