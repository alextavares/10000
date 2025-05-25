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
  final VoidCallback onDelete;

  /// Constructor for HabitCard.
  const HabitCard({
    super.key,
    required this.habit,
    required this.onTap,
    required this.onToggleCompletion,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isCompletedToday = habit.isCompletedToday();
    final streak = habit.streak;
    final cardColor = Theme.of(context).cardColor; // Use theme color
    final textColor = AppTheme.adaptiveTextColor(cardColor); // Adaptive text color
    final subtitleColor = textColor.withOpacity(0.7); // Lighter subtitle

    return Card(
      color: cardColor, // Use theme card color
      elevation: 0, // Adjusted to match reference image (flatter look)
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Adjusted margin for better spacing
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Consistent with AppTheme
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Make card height content-dependent
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center, // Center align icon and text vertically
                children: [
                  // Category icon
                  Container(
                    width: 40, // Slightly smaller icon container
                    height: 40,
                    decoration: BoxDecoration(
                      color: habit.color.withOpacity(0.2), // Use habit color
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        habit.icon, // Use habit icon
                        color: habit.color, // Use habit color
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Habit details
                  Expanded(
                    child: Text(
                      habit.title,
                      style: TextStyle(
                        fontSize: 16, // Adjusted font size
                        fontWeight: FontWeight.w600, // Adjusted font weight
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Completion checkbox
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: isCompletedToday,
                      onChanged: (value) {
                        onToggleCompletion(value ?? false);
                      },
                      activeColor: AppTheme.primaryColor,
                      checkColor: cardColor, // Make check mark contrast with activeColor
                      side: BorderSide(color: subtitleColor, width: 1.5),
                      visualDensity: VisualDensity.compact, // Reduce checkbox size
                    ),
                  ),
                ],
              ),
              // Only show divider and bottom row if there's content for it
              if (habit.description != null && habit.description!.isNotEmpty || streak > 0 || habit.reminderTime != null)
                const SizedBox(height: 8),
              if (habit.description != null && habit.description!.isNotEmpty || streak > 0 || habit.reminderTime != null)
                Divider(color: subtitleColor.withOpacity(0.5)),
              if (habit.description != null && habit.description!.isNotEmpty || streak > 0 || habit.reminderTime != null)
                const SizedBox(height: 8),

              // Bottom row with time, streak, and delete icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Time or Frequency
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          habit.reminderTime != null ? Icons.access_time_outlined : Icons.event_repeat_outlined,
                          size: 16,
                          color: subtitleColor,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _getTimeOrFrequencyText(context),
                            style: TextStyle(
                              fontSize: 13, // Adjusted font size
                              color: subtitleColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Streak
                  if (streak > 0)
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department_outlined,
                          size: 16,
                          color: Colors.orange[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$streak day${streak == 1 ? '' : 's'}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.orange[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8), // Space before delete icon
                      ],
                    ),

                  // Delete Button
                  InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(24),
                    child: Icon(Icons.delete_outline, color: Colors.red[700], size: 20),
                  ),
                ],
              ),
              if (habit.description != null && habit.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0), // Add some space if description exists
                  child: Text(
                    habit.description!,
                    style: TextStyle(
                      fontSize: 13,
                      color: subtitleColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
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
          return 'Todos os dias'; // Changed to Portuguese
        case HabitFrequency.weekly:
          if (habit.daysOfWeek != null && habit.daysOfWeek!.isNotEmpty) {
            List<String> dayAbbreviations = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom']; // Portuguese
            String selectedDays = habit.daysOfWeek!.map((d) => dayAbbreviations[d-1]).join(', ');
            return selectedDays; // Simplified to show only days
          }
          return 'Semanalmente'; // Changed to Portuguese
        case HabitFrequency.monthly:
           return 'Mensalmente (Dia ${habit.createdAt.day})'; // Changed to Portuguese
        case HabitFrequency.specificDaysOfYear:
          return 'Datas específicas do ano';
        case HabitFrequency.someTimesPerPeriod:
          if (habit.timesPerPeriod != null && habit.periodType != null) {
            return '${habit.timesPerPeriod}x por ${habit.periodType!.toLowerCase()}';
          }
          return 'Algumas vezes por período';
        case HabitFrequency.repeat:
          if (habit.isFlexible == true) {
            return 'Flexível';
          } else if (habit.alternateDays == true) {
            return 'Alternar dias';
          } else if (habit.repeatEveryDays != null) {
            return 'A cada ${habit.repeatEveryDays} dias';
          }
          return 'Repetir';
        case HabitFrequency.custom:
          if (habit.daysOfWeek != null && habit.daysOfWeek!.isNotEmpty) {
            List<String> dayAbbreviations = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom']; // Portuguese
            String selectedDays = habit.daysOfWeek!.map((d) => dayAbbreviations[d-1]).join(', ');
            return 'Personalizado ($selectedDays)'; // Changed to Portuguese
          }
          return 'Personalizado'; // Changed to Portuguese
      }
    }
  }

  // Removed _getCategoryIcon and _getCategoryColor as habit.icon and habit.color are used directly
}
