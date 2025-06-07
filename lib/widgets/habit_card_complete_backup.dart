import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/screens/habit/habit_details_screen.dart';
import 'package:myapp/theme/category_colors.dart';
import 'package:myapp/utils/responsive/responsive.dart';
import 'package:intl/intl.dart';

class HabitCardComplete extends StatelessWidget {
  final Habit habit;
  final DateTime selectedDate;
  final Function(bool completed, DateTime date)? onToggleCompletion;
  final Function()? onDelete;
  final VoidCallback? onCalendarTap;
  final VoidCallback? onStatsTap;
  final VoidCallback? onMoreTap;

  const HabitCardComplete({
    super.key,
    required this.habit,
    required this.selectedDate,
    this.onToggleCompletion,
    this.onDelete,
    this.onCalendarTap,
    this.onStatsTap,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final categoryColor = CategoryColors.getCategoryColor(
      habit.category, 
      isDarkMode
    );
    
    // Calcular porcentagem de conclusão
    final completionPercentage = _calculateCompletionPercentage();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              // Área do calendário (não clicável como container, mas cada dia é clicável)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // Header com título e ícone
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              habit.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getFrequencyText(),
                              style: TextStyle(
                                color: categoryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            if (_getAdditionalInfo().isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                _getAdditionalInfo(),
                                style: TextStyle(
                                  color: categoryColor.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
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
                    ],
                  ),
                  
                    const SizedBox(height: 12),
                    
                    // Calendário semanal inline
                    Container(
                      height: 65,
                      child: Row(
                        children: _buildWeekCalendar(context),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Área inferior clicável
              InkWell(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                onTap: () => _showHabitOptions(context),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      // Indicador de streak
                      Icon(
                        Icons.local_fire_department,
                        color: const Color(0xFFFF6B6B),
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${habit.streak}',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Indicador de conclusão
                      Icon(
                        Icons.check_circle,
                        color: const Color(0xFF4CAF50),
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${completionPercentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Botões de ação
                      IconButton(
                        icon: Icon(
                          Icons.calendar_today,
                          color: const Color(0xFF2196F3),
                          size: 20,
                        ),
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                        onPressed: onCalendarTap ?? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HabitDetailsScreen(
                                habitId: habit.id,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.bar_chart,
                          color: const Color(0xFF9C27B0),
                          size: 20,
                        ),
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                        onPressed: onStatsTap ?? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HabitDetailsScreen(
                                habitId: habit.id,
                                focusOnStats: true,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.more_vert,
                          color: const Color(0xFF757575),
                          size: 20,
                        ),
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                        onPressed: onMoreTap ?? () {
                          _showMoreOptions(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildWeekCalendar(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    
    final weekDays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    final widgets = <Widget>[];
    
    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final isToday = date.day == today.day && 
                      date.month == today.month && 
                      date.year == today.year;
      final dateOnly = DateTime(date.year, date.month, date.day);
      final isCompleted = habit.completionHistory[dateOnly] == true;
      final isSelected = date.day == selectedDate.day &&
                        date.month == selectedDate.month &&
                        date.year == selectedDate.year;
      
      widgets.add(
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                if (onToggleCompletion != null) {
                  HapticFeedback.lightImpact();
                  onToggleCompletion!(!isCompleted, date);
                }
              },
              child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weekDays[date.weekday % 7],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? _getCompletionColor(date)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: (isToday && !isCompleted)
                          ? Border.all(
                              color: Colors.grey[600]!,
                              width: 1,
                            )
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          color: isCompleted
                              ? Colors.black
                              : isToday
                                  ? Colors.white
                                  : Colors.grey[500],
                          fontSize: 14,
                          fontWeight: isCompleted || isToday
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    return widgets;
  }

  double _calculateCompletionPercentage() {
    final now = DateTime.now();
    int daysInPeriod = 0;
    int completedDays = 0;
    
    // Calcular para os últimos 7 dias
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      if (_shouldShowOnDate(date)) {
        daysInPeriod++;
        final dateOnly = DateTime(date.year, date.month, date.day);
        if (habit.completionHistory[dateOnly] == true) {
          completedDays++;
        }
      }
    }
    
    if (daysInPeriod == 0) return 0;
    return (completedDays / daysInPeriod) * 100;
  }

  bool _shouldShowOnDate(DateTime date) {
    switch (habit.frequency) {
      case HabitFrequency.daily:
        return true;
      case HabitFrequency.weekly:
        return habit.daysOfWeek?.contains(date.weekday) ?? false;
      case HabitFrequency.monthly:
        return habit.daysOfMonth?.contains(date.day) ?? false;
      default:
        return true;
    }
  }

  String _getFrequencyText() {
    switch (habit.frequency) {
      case HabitFrequency.daily:
        return 'Todos os dias';
      case HabitFrequency.weekly:
        if (habit.daysOfWeek != null && habit.daysOfWeek!.isNotEmpty) {
          if (habit.daysOfWeek!.length == 7) {
            return 'Todos os dias';
          }
          return 'Semanal';
        }
        return 'Semanal';
      case HabitFrequency.monthly:
        return 'Mensal';
      default:
        return 'Personalizado';
    }
  }

  String _getAdditionalInfo() {
    switch (habit.frequency) {
      case HabitFrequency.weekly:
        if (habit.daysOfWeek != null && habit.daysOfWeek!.isNotEmpty && habit.daysOfWeek!.length < 7) {
          final days = habit.daysOfWeek!.map((d) {
            switch (d) {
              case 1: return 'Seg';
              case 2: return 'Ter';
              case 3: return 'Qua';
              case 4: return 'Qui';
              case 5: return 'Sex';
              case 6: return 'Sáb';
              case 7: return 'Dom';
              default: return '';
            }
          }).join(', ');
          return 'Dias: $days';
        }
        return '';
      case HabitFrequency.monthly:
        if (habit.daysOfMonth != null && habit.daysOfMonth!.isNotEmpty) {
          return 'Dias do mês: ${habit.daysOfMonth!.join(", ")}';
        }
        return '';
      default:
        return '';
    }
  }

  Color _getCompletionColor(DateTime date) {
    // Cores diferentes para cada dia da semana como no app de referência
    final colors = [
      const Color(0xFFFFB300), // Dourado
      const Color(0xFFE91E63), // Rosa
      const Color(0xFF4CAF50), // Verde
      const Color(0xFF2196F3), // Azul
      const Color(0xFFFF5722), // Laranja
      const Color(0xFF9C27B0), // Roxo
      const Color(0xFF00BCD4), // Ciano
    ];
    return colors[date.weekday % 7];
  }

  void _showHabitOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E1E1E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header com título do hábito
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        habit.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getAdditionalInfo().isNotEmpty ? _getAdditionalInfo() : _getFrequencyText(),
                        style: TextStyle(
                          color: CategoryColors.getCategoryColor(habit.category, true),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.grey, height: 1),
                // Opções
                ListTile(
                  leading: Icon(Icons.calendar_today, color: Colors.grey[400]),
                  title: const Text('Calendário', style: TextStyle(color: Colors.white, fontSize: 18)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HabitDetailsScreen(
                          habitId: habit.id,
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.bar_chart, color: Colors.grey[400]),
                  title: const Text('Estatísticas', style: TextStyle(color: Colors.white, fontSize: 18)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HabitDetailsScreen(
                          habitId: habit.id,
                          focusOnStats: true,
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.edit, color: Colors.grey[400]),
                  title: const Text('Editar', style: TextStyle(color: Colors.white, fontSize: 18)),
                  onTap: () {
                    Navigator.pop(context);
                    // Navegar para tela de edição
                  },
                ),
                ListTile(
                  leading: Icon(Icons.archive, color: Colors.grey[400]),
                  title: const Text('Arquive', style: TextStyle(color: Colors.white, fontSize: 18)),
                  onTap: () {
                    Navigator.pop(context);
                    // Implementar arquivamento
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.grey[400]),
                  title: const Text('Excluir', style: TextStyle(color: Colors.white, fontSize: 18)),
                  onTap: () {
                    Navigator.pop(context);
                    onDelete?.call();
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMoreOptions(BuildContext context) {
    _showHabitOptions(context);
  }
}