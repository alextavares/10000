import 'package:flutter/material.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/theme/app_theme.dart';

class HabitStatisticsTab extends StatefulWidget {
  final Habit habit;

  const HabitStatisticsTab({
    super.key,
    required this.habit,
  });

  @override
  State<HabitStatisticsTab> createState() => _HabitStatisticsTabState();
}

class _HabitStatisticsTabState extends State<HabitStatisticsTab> {
  String _selectedPeriod = 'Mês';
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Habit score
          _buildHabitScore(),
          
          const SizedBox(height: 24),
          
          // Streak comparison
          _buildStreakComparison(),
          
          const SizedBox(height: 24),
          
          // Completion times
          _buildCompletionTimes(),
          
          const SizedBox(height: 24),
          
          // Success chart (placeholder)
          _buildSuccessChart(),
          
          const SizedBox(height: 24),
          
          // Streak challenges
          _buildStreakChallenges(),
        ],
      ),
    );
  }
  
  Widget _buildHabitScore() {
    final completionRate = widget.habit.getCompletionRate() * 100;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events,
                color: widget.habit.color,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Pontuação de hábito',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Circular progress indicator
          SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              children: [
                CircularProgressIndicator(
                  value: completionRate / 100,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(widget.habit.color),
                ),
                Center(
                  child: Text(
                    '${completionRate.toInt()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStreakComparison() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_fire_department,
                color: widget.habit.color,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Série',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const Text(
                    'Atual',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.habit.streak} DIAS',
                    style: TextStyle(
                      color: widget.habit.color,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.grey[800],
              ),
              Column(
                children: [
                  const Text(
                    'Melhor',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.habit.longestStreak} DIA${widget.habit.longestStreak != 1 ? 'S' : ''}',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildCompletionTimes() {
    final now = DateTime.now();
    final thisWeek = _getCompletionsThisWeek();
    final thisMonth = _getCompletionsThisMonth();
    final thisYear = _getCompletionsThisYear();
    final total = widget.habit.completionHistory.values.where((v) => v).length;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                color: widget.habit.color,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Vezes concluída',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildCompletionRow('Esta semana', thisWeek),
          const SizedBox(height: 12),
          _buildCompletionRow('Este mês', thisMonth),
          const SizedBox(height: 12),
          _buildCompletionRow('Este ano', thisYear),
          const SizedBox(height: 12),
          _buildCompletionRow('Total', total),
        ],
      ),
    );
  }
  
  Widget _buildCompletionRow(String label, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
        Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSuccessChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Period selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPeriodButton('Semana'),
              const SizedBox(width: 16),
              _buildPeriodButton('Mês'),
              const SizedBox(width: 16),
              _buildPeriodButton('Ano'),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pie_chart_outline,
                color: widget.habit.color,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Sucesso / Falha',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Placeholder for chart
          Container(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.donut_large,
                    size: 80,
                    color: widget.habit.color.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Gráfico em desenvolvimento',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPeriodButton(String period) {
    final isSelected = _selectedPeriod == period;
    
    return GestureDetector(
      onTap: () {
        setState(() => _selectedPeriod = period);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? widget.habit.color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? widget.habit.color : Colors.grey[700]!,
          ),
        ),
        child: Text(
          period,
          style: TextStyle(
            color: isSelected ? widget.habit.color : Colors.grey[400],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
  
  Widget _buildStreakChallenges() {
    final challenges = [
      {'days': 1, 'completed': widget.habit.longestStreak >= 1},
      {'days': 7, 'completed': widget.habit.longestStreak >= 7},
      {'days': 15, 'completed': widget.habit.longestStreak >= 15},
      {'days': 30, 'completed': widget.habit.longestStreak >= 30},
      {'days': 60, 'completed': widget.habit.longestStreak >= 60},
    ];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.military_tech,
                color: widget.habit.color,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Desafio de série',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: challenges.map((challenge) {
              final isCompleted = challenge['completed'] as bool;
              final days = challenge['days'] as int;
              
              return Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isCompleted 
                          ? widget.habit.color.withOpacity(0.2)
                          : Colors.grey[800],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted ? widget.habit.color : Colors.grey[700]!,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        isCompleted ? Icons.star : Icons.lock_outline,
                        color: isCompleted ? widget.habit.color : Colors.grey[600],
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$days dia${days > 1 ? 's' : ''}',
                    style: TextStyle(
                      color: isCompleted ? Colors.white : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  int _getCompletionsThisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    int count = 0;
    
    widget.habit.completionHistory.forEach((date, completed) {
      if (completed && date.isAfter(startOfWeek.subtract(const Duration(days: 1)))) {
        count++;
      }
    });
    
    return count;
  }
  
  int _getCompletionsThisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    int count = 0;
    
    widget.habit.completionHistory.forEach((date, completed) {
      if (completed && date.isAfter(startOfMonth.subtract(const Duration(days: 1)))) {
        count++;
      }
    });
    
    return count;
  }
  
  int _getCompletionsThisYear() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    int count = 0;
    
    widget.habit.completionHistory.forEach((date, completed) {
      if (completed && date.isAfter(startOfYear.subtract(const Duration(days: 1)))) {
        count++;
      }
    });
    
    return count;
  }
}
