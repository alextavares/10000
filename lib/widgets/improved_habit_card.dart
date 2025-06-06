import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/theme/app_theme.dart';

class ImprovedHabitCard extends StatelessWidget {
  final Habit habit;
  final DateTime selectedDate;
  final VoidCallback onTap;
  final Function(bool) onToggleCompletion;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onStats;

  const ImprovedHabitCard({
    super.key,
    required this.habit,
    required this.selectedDate,
    required this.onTap,
    required this.onToggleCompletion,
    required this.onDelete,
    required this.onEdit,
    required this.onStats,
  });

  List<int> _getLastSevenDays() {
    List<int> days = [];
    for (int i = 6; i >= 0; i--) {
      days.add(selectedDate.subtract(Duration(days: i)).day);
    }
    return days;
  }

  List<bool> _getCompletionStatusForWeek() {
    List<bool> completions = [];
    for (int i = 6; i >= 0; i--) {
      DateTime day = selectedDate.subtract(Duration(days: i));
      DateTime dateOnly = DateTime(day.year, day.month, day.day);
      completions.add(habit.completionHistory[dateOnly] ?? false);
    }
    return completions;
  }

  String _getFrequencyText() {
    switch (habit.frequency) {
      case HabitFrequency.daily:
        return 'Todos os dias';
      case HabitFrequency.weekly:
        if (habit.daysOfWeek != null && habit.daysOfWeek!.isNotEmpty) {
          return '${habit.daysOfWeek!.length}x por semana';
        }
        return 'Semanal';
      case HabitFrequency.monthly:
        if (habit.daysOfMonth != null && habit.daysOfMonth!.isNotEmpty) {
          return 'Dias do mês: ${habit.daysOfMonth!.join(', ')}';
        }
        return 'Mensal';
      default:
        return 'Personalizado';
    }
  }

  int _getCompletionPercentage() {
    if (habit.completionHistory.isEmpty) return 0;
    
    // Calculate for last 30 days
    int completedDays = 0;
    int totalDays = 0;
    
    for (int i = 0; i < 30; i++) {
      DateTime day = DateTime.now().subtract(Duration(days: i));
      DateTime dateOnly = DateTime(day.year, day.month, day.day);
      
      // Check if habit should be done on this day
      bool shouldBeDone = false;
      if (habit.frequency == HabitFrequency.daily) {
        shouldBeDone = true;
      } else if (habit.frequency == HabitFrequency.weekly && habit.daysOfWeek != null) {
        shouldBeDone = habit.daysOfWeek!.contains(day.weekday);
      } else if (habit.frequency == HabitFrequency.monthly && habit.daysOfMonth != null) {
        shouldBeDone = habit.daysOfMonth!.contains(day.day);
      }
      
      if (shouldBeDone) {
        totalDays++;
        if (habit.completionHistory[dateOnly] ?? false) {
          completedDays++;
        }
      }
    }
    
    if (totalDays == 0) return 0;
    return ((completedDays / totalDays) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompletedToday = habit.completionHistory[
      DateTime(selectedDate.year, selectedDate.month, selectedDate.day)
    ] ?? false;
    
    final lastSevenDays = _getLastSevenDays();
    final weekCompletions = _getCompletionStatusForWeek();
    final completionPercentage = _getCompletionPercentage();
    
    // Get weekday names in Portuguese
    final weekDays = ['Sex', 'Sáb', 'Dom', 'Seg', 'Ter', 'Qua', 'Qui'];
    final todayWeekday = selectedDate.weekday;
    List<String> orderedWeekDays = [];
    for (int i = 6; i >= 0; i--) {
      int weekdayIndex = (todayWeekday - i - 1) % 7;
      if (weekdayIndex < 0) weekdayIndex += 7;
      orderedWeekDays.add(weekDays[weekdayIndex]);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Slidable(
        key: Key(habit.id),
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onStats(),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.bar_chart,
              label: 'Estatísticas',
            ),
            SlidableAction(
              onPressed: (_) => onEdit(),
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              icon: Icons.edit,
              label: 'Editar',
            ),
            SlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Excluir',
            ),
          ],
        ),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCompletedToday 
                    ? habit.color.withOpacity(0.5) 
                    : Colors.grey.withOpacity(0.2),
                width: isCompletedToday ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                // Main content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Title and checkbox row
                      Row(
                        children: [
                          // Icon with colored background
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: habit.color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              habit.icon,
                              color: habit.color,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Title and frequency
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  habit.title,
                                  style: TextStyle(
                                    color: AppTheme.textColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getFrequencyText(),
                                  style: TextStyle(
                                    color: habit.color,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Checkbox
                          Transform.scale(
                            scale: 1.2,
                            child: Checkbox(
                              value: isCompletedToday,
                              onChanged: (value) => onToggleCompletion(value ?? false),
                              activeColor: habit.color,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Week progress
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(7, (index) {
                            final isCompleted = weekCompletions[index];
                            final isToday = index == 6;
                            
                            return Column(
                              children: [
                                Text(
                                  orderedWeekDays[index],
                                  style: TextStyle(
                                    color: isToday ? habit.color : Colors.grey[600],
                                    fontSize: 12,
                                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: isCompleted 
                                        ? habit.color 
                                        : Colors.grey.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                    border: isToday
                                        ? Border.all(
                                            color: habit.color,
                                            width: 2,
                                          )
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      lastSevenDays[index].toString(),
                                      style: TextStyle(
                                        color: isCompleted 
                                            ? Colors.white 
                                            : Colors.grey[600],
                                        fontSize: 14,
                                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                // Bottom stats row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Streak
                      Row(
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            habit.streak.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      // Completion percentage
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$completionPercentage%',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      // More options
                      IconButton(
                        icon: Icon(
                          Icons.more_vert,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                        onPressed: onTap,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
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
