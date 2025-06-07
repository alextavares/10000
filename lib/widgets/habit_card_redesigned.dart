import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/models/category.dart';
import 'package:myapp/screens/habit/habit_details_screen.dart';
import 'package:myapp/theme/category_colors.dart';
import 'package:myapp/services/category_service.dart';
import 'package:myapp/services/service_provider.dart';

class HabitCardRedesigned extends StatelessWidget {
  final Habit habit;
  final Function()? onTap;
  final Function(bool? value)? onToggleCompletion;
  final Function()? onDelete;
  final VoidCallback? onShowQuickActions;

  const HabitCardRedesigned({
    super.key,
    required this.habit,
    this.onTap,
    this.onToggleCompletion,
    this.onDelete,
    this.onShowQuickActions,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // O Habit já tem a cor diretamente
    final categoryColor = habit.color;
    
    return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode 
                  ? Colors.grey[900] 
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode 
                      ? Colors.black.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onShowQuickActions ?? () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => HabitDetailsScreen(habitId: habit.id),
                    ),
                  );
                },
                onLongPress: () {
                  // Haptic feedback
                  HapticFeedback.mediumImpact();
                  onShowQuickActions?.call();
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Ícone colorido com background
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          habit.icon,
                          color: categoryColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Conteúdo principal
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Título
                            Text(
                              habit.title,
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            
                            // Categoria e tipo
                            Row(
                              children: [
                                // Tag de categoria
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: categoryColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    habit.category,
                                    style: TextStyle(
                                      color: categoryColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                
                                // Tipo (Hábito)
                                Text(
                                  'Hábito',
                                  style: TextStyle(
                                    color: isDarkMode 
                                        ? Colors.grey[400] 
                                        : Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            
                            // Frequência
                            if (_getFrequencyText(habit).isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                _getFrequencyText(habit),
                                style: TextStyle(
                                  color: isDarkMode 
                                      ? Colors.grey[500] 
                                      : Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      // Checkbox circular animado
                      if (onToggleCompletion != null)
                        _AnimatedCircularCheckbox(
                          value: habit.isCompletedToday(),
                          onChanged: onToggleCompletion,
                          color: categoryColor,
                        ),
                      
                      // Streak indicator
                      if (habit.streak > 0 && onToggleCompletion == null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.local_fire_department,
                                size: 16,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${habit.streak}',
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
  }

  String _getFrequencyText(Habit habit) {
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
          return '${habit.daysOfMonth!.length}x por mês';
        }
        return 'Mensal';
      case HabitFrequency.someTimesPerPeriod:
        if (habit.timesPerPeriod != null && habit.periodType != null) {
          final period = habit.periodType == 'SEMANA' ? 'semana' : 
                         habit.periodType == 'MÊS' ? 'mês' : 'ano';
          return '${habit.timesPerPeriod}x por $period';
        }
        return 'Personalizado';
      case HabitFrequency.repeat:
        if (habit.repeatEveryDays != null) {
          return 'A cada ${habit.repeatEveryDays} dias';
        }
        if (habit.alternateDays == true) {
          return 'Dias alternados';
        }
        return 'Repetir';
      default:
        return '';
    }
  }
}

// Widget de checkbox circular animado
class _AnimatedCircularCheckbox extends StatefulWidget {
  final bool value;
  final Function(bool?)? onChanged;
  final Color color;

  const _AnimatedCircularCheckbox({
    required this.value,
    required this.onChanged,
    required this.color,
  });

  @override
  State<_AnimatedCircularCheckbox> createState() => _AnimatedCircularCheckboxState();
}

class _AnimatedCircularCheckboxState extends State<_AnimatedCircularCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onChanged?.call(!widget.value);
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.value 
                    ? widget.color 
                    : Colors.transparent,
                border: Border.all(
                  color: widget.color,
                  width: 2.5,
                ),
              ),
              child: widget.value
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}