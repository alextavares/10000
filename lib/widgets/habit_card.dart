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

  /// Constructor for HabitCard.
  const HabitCard({
    super.key,
    required this.habit,
    required this.onTap,
    required this.onToggleCompletion,
  });

  @override
  Widget build(BuildContext context) {
    final isCompletedToday = habit.isCompletedToday();
    final streak = habit.streak;

    return Card(
      elevation: 2,
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
                        ),
                        const SizedBox(height: 4),
                        if (habit.description != null)
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

              // Bottom row with time and streak
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Time
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppTheme.subtitleColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getTimeText(),
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
                        const Icon(
                          Icons.local_fire_department,
                          size: 16,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$streak day${streak == 1 ? '' : 's'}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Gets the time text based on the habit's reminder time.
  String _getTimeText() {
    if (habit.reminderTime != null) {
      final hour = habit.reminderTime!.hour;
      final minute = habit.reminderTime!.minute;
      final period = hour < 12 ? 'AM' : 'PM';
      final displayHour = hour % 12 == 0 ? 12 : hour % 12;
      final displayMinute = minute.toString().padLeft(2, '0');
      return '$displayHour:$displayMinute $period';
    } else {
      return 'No reminder';
    }
  }

  /// Gets the icon for a habit category.
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'health':
        return Icons.favorite;
      case 'fitness':
        return Icons.fitness_center;
      case 'productivity':
        return Icons.work;
      case 'education':
        return Icons.school;
      case 'finance':
        return Icons.attach_money;
      case 'social':
        return Icons.people;
      case 'mindfulness':
        return Icons.self_improvement;
      case 'creativity':
        return Icons.brush;
      default:
        return Icons.star;
    }
  }

  /// Gets the color for a habit category.
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'health':
        return Colors.red;
      case 'fitness':
        return Colors.blue;
      case 'productivity':
        return Colors.green;
      case 'education':
        return Colors.purple;
      case 'finance':
        return Colors.amber;
      case 'social':
        return Colors.pink;
      case 'mindfulness':
        return Colors.teal;
      case 'creativity':
        return Colors.orange;
      default:
        return AppTheme.primaryColor;
    }
  }
}
