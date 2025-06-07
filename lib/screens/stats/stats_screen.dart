import 'package:flutter/material.dart';
import 'package:myapp/services/service_provider.dart';

class StatsData {
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final int overdueTasks;
  final int totalHabits;
  final int activeHabits;
  final int totalRecurringTasks;
  final int completedRecurringTasks;
  final double completionRate;
  final Map<String, int> categoryStats;
  final List<DateTime> recentCompletions;

  StatsData({
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.overdueTasks,
    required this.totalHabits,
    required this.activeHabits,
    required this.totalRecurringTasks,
    required this.completedRecurringTasks,
    required this.completionRate,
    required this.categoryStats,
    required this.recentCompletions,
  });
}

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late Future<StatsData> _statsFuture;
  String _selectedPeriod = 'Esta semana';

  final List<String> _periods = [
    'Hoje',
    'Esta semana',
    'Este mês',
    'Este ano',
    'Todos os tempos'
  ];

  @override
  void initState() {
    super.initState();
    _statsFuture = _loadStats();
  }

  Future<StatsData> _loadStats() async {
    try {
      final taskService = ServiceProvider.of(context).taskService;
      final habitService = ServiceProvider.of(context).habitService;
      final recurringTaskService = ServiceProvider.of(context).recurringTaskService;

      final tasks = await taskService.getTasks();
      final habits = await habitService.getHabits();
      final recurringTasks = await recurringTaskService.getRecurringTasks();

      // Calculate date range based on selected period
      final now = DateTime.now();
      DateTime startDate;
      
      switch (_selectedPeriod) {
        case 'Hoje':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'Esta semana':
          startDate = now.subtract(Duration(days: now.weekday - 1));
          break;
        case 'Este mês':
          startDate = DateTime(now.year, now.month, 1);
          break;
        case 'Este ano':
          startDate = DateTime(now.year, 1, 1);
          break;
        default:
          startDate = DateTime(2020, 1, 1); // Far back date for "all time"
      }

      // Filter tasks by period
      final filteredTasks = tasks.where((task) {
        return task.createdAt.isAfter(startDate) || 
               (task.dueDate != null && task.dueDate!.isAfter(startDate));
      }).toList();

      // Calculate task stats
      final completedTasks = filteredTasks.where((task) => task.isCompleted).length;
      final pendingTasks = filteredTasks.where((task) => !task.isCompleted).length;
      final overdueTasks = filteredTasks.where((task) {
        if (task.dueDate == null || task.isCompleted) return false;
        return task.dueDate!.isBefore(now);
      }).length;

      // Calculate habit stats
      final activeHabits = habits.where((habit) {
        return habit.startDate.isBefore(now) && 
               (habit.targetDate == null || habit.targetDate!.isAfter(now));
      }).length;

      // Calculate recurring task stats
      final completedRecurringTasks = recurringTasks.where((rt) {
        // Check if completed today (simplified logic)
        final today = DateTime(now.year, now.month, now.day);
        return rt.completionHistory.containsKey(today) && rt.completionHistory[today] == true;
      }).length;

      // Calculate completion rate
      final totalItems = filteredTasks.length + habits.length + recurringTasks.length;
      final completedItems = completedTasks + 
                           habits.where((h) => h.isCompletedToday()).length +
                           completedRecurringTasks;
      final completionRate = totalItems > 0 ? (completedItems / totalItems) * 100 : 0.0;

      // Calculate category stats
      final Map<String, int> categoryStats = {};
      for (var task in filteredTasks) {
        final category = task.category ?? 'Sem categoria';
        categoryStats[category] = (categoryStats[category] ?? 0) + 1;
      }
      for (var habit in habits) {
        final category = habit.category ?? 'Sem categoria';
        categoryStats[category] = (categoryStats[category] ?? 0) + 1;
      }

      // Get recent completions (last 7 days)
      final recentCompletions = <DateTime>[];
      for (int i = 0; i < 7; i++) {
        final date = now.subtract(Duration(days: i));
        final dateOnly = DateTime(date.year, date.month, date.day);
        
        final dayCompletions = tasks.where((task) {
          return task.completionHistory.containsKey(dateOnly) && 
                 task.completionHistory[dateOnly] == true;
        }).length;
        
        if (dayCompletions > 0) {
          recentCompletions.add(dateOnly);
        }
      }

      return StatsData(
        totalTasks: filteredTasks.length,
        completedTasks: completedTasks,
        pendingTasks: pendingTasks,
        overdueTasks: overdueTasks,
        totalHabits: habits.length,
        activeHabits: activeHabits,
        totalRecurringTasks: recurringTasks.length,
        completedRecurringTasks: completedRecurringTasks,
        completionRate: completionRate,
        categoryStats: categoryStats,
        recentCompletions: recentCompletions,
      );
    } catch (e) {
      throw Exception('Erro ao carregar estatísticas: $e');
    }
  }

  void _onPeriodChanged(String period) {
    setState(() {
      _selectedPeriod = period;
      _statsFuture = _loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Estatísticas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Period selector
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _periods.length,
              itemBuilder: (context, index) {
                final period = _periods[index];
                final isSelected = _selectedPeriod == period;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(period),
                    selected: isSelected,
                    onSelected: (selected) => _onPeriodChanged(period),
                    backgroundColor: Colors.grey[800],
                    selectedColor: const Color(0xFFE91E63),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[300],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    checkmarkColor: Colors.white,
                  ),
                );
              },
            ),
          ),
          
          // Stats content
          Expanded(
            child: FutureBuilder<StatsData>(
              future: _statsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
                    ),
                  );
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Erro ao carregar estatísticas',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                
                if (!snapshot.hasData) {
                  return Center(
                    child: Text(
                      'Nenhum dado disponível',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                    ),
                  );
                }
                
                final stats = snapshot.data!;
                return _buildStatsContent(stats);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsContent(StatsData stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview cards
          _buildOverviewSection(stats),
          const SizedBox(height: 24),
          
          // Completion rate
          _buildCompletionRateSection(stats),
          const SizedBox(height: 24),
          
          // Category breakdown
          _buildCategorySection(stats),
          const SizedBox(height: 24),
          
          // Recent activity
          _buildRecentActivitySection(stats),
        ],
      ),
    );
  }

  Widget _buildOverviewSection(StatsData stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Visão Geral',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildStatCard('Tarefas', stats.totalTasks.toString(), Icons.task_alt, Colors.blue)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Hábitos', stats.totalHabits.toString(), Icons.star, Colors.amber)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard('Concluídas', stats.completedTasks.toString(), Icons.check_circle, Colors.green)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Pendentes', stats.pendingTasks.toString(), Icons.pending, Colors.orange)),
          ],
        ),
        if (stats.overdueTasks > 0) ...[
          const SizedBox(height: 12),
          _buildStatCard('Atrasadas', stats.overdueTasks.toString(), Icons.warning, Colors.red),
        ],
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionRateSection(StatsData stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Taxa de Conclusão',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${stats.completionRate.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Color(0xFFE91E63),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'de conclusão $_selectedPeriod',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: stats.completionRate / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey[700],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(StatsData stats) {
    if (stats.categoryStats.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Por Categoria',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...stats.categoryStats.entries.map((entry) {
          final total = stats.categoryStats.values.reduce((a, b) => a + b);
          final percentage = (entry.value / total * 100).toStringAsFixed(1);
          
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    entry.key,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                Text(
                  '${entry.value} ($percentage%)',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRecentActivitySection(StatsData stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Atividade Recente',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(12),
          ),
          child: stats.recentCompletions.isEmpty
              ? Text(
                  'Nenhuma atividade recente',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                )
              : Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.trending_up, color: Color(0xFFE91E63)),
                        const SizedBox(width: 8),
                        Text(
                          '${stats.recentCompletions.length} dias ativos nos últimos 7 dias',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(7, (index) {
                        final date = DateTime.now().subtract(Duration(days: 6 - index));
                        final hasActivity = stats.recentCompletions.any((d) =>
                            d.year == date.year && d.month == date.month && d.day == date.day);
                        
                        return Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: hasActivity ? const Color(0xFFE91E63) : Colors.grey[700],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              date.day.toString(),
                              style: TextStyle(
                                color: hasActivity ? Colors.white : Colors.grey[400],
                                fontSize: 12,
                                fontWeight: hasActivity ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
