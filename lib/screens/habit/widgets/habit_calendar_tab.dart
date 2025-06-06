import 'package:flutter/material.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:intl/intl.dart';

class HabitCalendarTab extends StatefulWidget {
  final Habit habit;
  final Function(DateTime, bool) onToggleCompletion;

  const HabitCalendarTab({
    super.key,
    required this.habit,
    required this.onToggleCompletion,
  });

  @override
  State<HabitCalendarTab> createState() => _HabitCalendarTabState();
}

class _HabitCalendarTabState extends State<HabitCalendarTab> {
  DateTime _currentMonth = DateTime.now();
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Calendar view
          _buildCalendarView(),
          
          const SizedBox(height: 24),
          
          // Streak info
          _buildStreakInfo(),
          
          const SizedBox(height: 24),
          
          // Annotations section (placeholder for future)
          _buildAnnotationsSection(),
        ],
      ),
    );
  }
  
  Widget _buildCalendarView() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: widget.habit.color),
                onPressed: () {
                  setState(() {
                    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
                  });
                },
              ),
              Text(
                DateFormat('MMMM yyyy', 'pt_BR').format(_currentMonth),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: widget.habit.color),
                onPressed: () {
                  setState(() {
                    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
                  });
                },
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Calendar grid
          _buildCalendarGrid(),
        ],
      ),
    );
  }
  
  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;
    
    // Days of week headers
    final dayHeaders = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    
    List<Widget> dayCells = [];
    
    // Add day headers
    for (String day in dayHeaders) {
      dayCells.add(
        Center(
          child: Text(
            day,
            style: TextStyle(
              color: widget.habit.color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      );
    }
    
    // Add empty cells for padding
    for (int i = 0; i < firstWeekday % 7; i++) {
      dayCells.add(Container());
    }
    
    // Add day cells
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final dateOnly = DateTime(date.year, date.month, date.day);
      final isCompleted = widget.habit.completionHistory[dateOnly] ?? false;
      final isToday = _isToday(date);
      final isSelected = isCompleted;
      
      dayCells.add(
        GestureDetector(
          onTap: () => widget.onToggleCompletion(dateOnly, !isCompleted),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected ? widget.habit.color : Colors.transparent,
              border: isToday 
                  ? Border.all(color: widget.habit.color, width: 2)
                  : Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1,
      children: dayCells,
    );
  }
  
  Widget _buildStreakInfo() {
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
                size: 32,
              ),
              const SizedBox(width: 12),
              const Text(
                'Série',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${widget.habit.streak} DIAS',
            style: TextStyle(
              color: widget.habit.color,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnnotationsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.note_alt_outlined,
                color: widget.habit.color,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Anotações',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Em breve você poderá adicionar notas sobre seu progresso diário.',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}
