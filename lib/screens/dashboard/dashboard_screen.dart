import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:myapp/services/habit_service.dart';
import 'package:myapp/services/dashboard_service.dart';
import 'package:myapp/widgets/dashboard_widgets.dart';
import 'package:myapp/screens/achievements/achievements_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  DashboardStats? _stats;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _loadStats();
  }
  
  Future<void> _loadStats() async {
    final habitService = context.read<HabitService>();
    final habits = await habitService.getAllHabits();
    
    setState(() {
      _stats = DashboardService.calculateStats(habits);
      _isLoading = false;
    });
    
    _fadeController.forward();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading || _stats == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            slivers: [
              // Header com gradiente
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              _getGreeting(),
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getMotivationalMessage(),
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  title: const Text('Dashboard'),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.emoji_events),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AchievementsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              
              // Cards de estatísticas principais
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildListDelegate([
                    AnimatedStatCard(
                      title: 'Completos Hoje',
                      value: '${_stats!.completedToday}/${_stats!.totalHabits}',
                      icon: Icons.check_circle,
                      color: Colors.green,
                      subtitle: '${(_getCompletionPercentageToday() * 100).toInt()}% concluído',
                    ),
                    AnimatedStatCard(
                      title: 'Sequência Atual',
                      value: '${_stats!.currentStreak}',
                      icon: Icons.local_fire_department,
                      color: Colors.orange,
                      subtitle: 'dias seguidos',
                    ),
                    AnimatedStatCard(
                      title: 'Taxa Semanal',
                      value: '${(_stats!.weeklyCompletionRate * 100).toInt()}%',
                      icon: Icons.trending_up,
                      color: Colors.blue,
                      subtitle: _getTrendText(_stats!.weeklyCompletionRate, _stats!.monthlyCompletionRate),
                    ),
                    AnimatedStatCard(
                      title: 'Total de Hábitos',
                      value: '${_stats!.totalHabits}',
                      icon: Icons.category,
                      color: Colors.purple,
                      subtitle: '${_stats!.habitsByCategory.length} categorias',
                      onTap: () => _showCategoryBreakdown(),
                    ),
                  ]),
                ),
              ),
              
              // Insights
              if (_stats!.insights.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildInsightsSection(),
                ),
              
              // Tabs para diferentes visualizações
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Theme.of(context).primaryColor,
                    tabs: const [
                      Tab(text: 'Progresso'),
                      Tab(text: 'Hábitos'),
                      Tab(text: 'Histórico'),
                    ],
                  ),
                ),
              ),
              
              // Conteúdo das tabs
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProgressTab(),
                    _buildHabitsTab(),
                    _buildHistoryTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia!';
    if (hour < 18) return 'Boa tarde!';
    return 'Boa noite!';
  }
  
  String _getMotivationalMessage() {
    final percentage = _getCompletionPercentageToday();
    if (percentage == 1.0) {
      return '🎉 Incrível! Você completou todos os hábitos!';
    } else if (percentage >= 0.7) {
      return '💪 Você está quase lá! Continue assim!';
    } else if (percentage >= 0.3) {
      return '🚀 Bom progresso! Cada hábito conta!';
    } else if (_stats!.completedToday > 0) {
      return '✨ Ótimo começo! Mantenha o ritmo!';
    } else {
      return '🌟 Que tal começar com um hábito simples?';
    }
  }
  
  double _getCompletionPercentageToday() {
    if (_stats!.totalHabits == 0) return 0.0;
    return _stats!.completedToday / _stats!.totalHabits;
  }
  
  String _getTrendText(double current, double previous) {
    final diff = current - previous;
    if (diff > 0.1) {
      return '↑ ${(diff * 100).toInt()}% melhor';
    } else if (diff < -0.1) {
      return '↓ ${(-diff * 100).toInt()}% menor';
    } else {
      return '→ Estável';
    }
  }
  
  Widget _buildInsightsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💡 Insights',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ..._stats!.insights.map((insight) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    insight,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  Widget _buildProgressTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progresso geral circular
          Center(
            child: AnimatedCircularProgress(
              value: _stats!.overallCompletionRate,
              color: Theme.of(context).primaryColor,
              size: 150,
              centerText: '${(_stats!.overallCompletionRate * 100).toInt()}%',
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Taxa de Conclusão Geral',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Gráfico de linha - últimos 30 dias
          AnimatedLineChart(
            title: 'Progresso dos Últimos 30 Dias',
            data: _stats!.dailyCompletionRates,
            lineColor: Theme.of(context).primaryColor,
            height: 200,
          ),
          
          const SizedBox(height: 32),
          
          // Breakdown por categoria
          const Text(
            'Por Categoria',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._buildCategoryBars(),
        ],
      ),
    );
  }
  
  Widget _buildHabitsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top performers
          if (_stats!.topHabits.isNotEmpty) ...[
            const Text(
              '⭐ Melhores Hábitos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._stats!.topHabits.map((performance) => _buildHabitPerformanceCard(
              performance,
              isTop: true,
            )),
            const SizedBox(height: 24),
          ],
          
          // Struggling habits
          if (_stats!.strugglingHabits.isNotEmpty) ...[
            const Text(
              '🎯 Precisam de Atenção',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._stats!.strugglingHabits.map((performance) => _buildHabitPerformanceCard(
              performance,
              isTop: false,
            )),
          ],
        ],
      ),
    );
  }
  
  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📅 Mapa de Atividades',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sua consistência ao longo do ano',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          
          // Heatmap
          YearHeatmap(
            data: _stats!.yearHeatmap,
            baseColor: Theme.of(context).primaryColor,
          ),
          
          const SizedBox(height: 24),
          
          // Legenda
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeatmapLegend('Menos', Colors.grey[200]!),
              _buildHeatmapLegend('', Theme.of(context).primaryColor.withValues(alpha: 0.3)),
              _buildHeatmapLegend('', Theme.of(context).primaryColor.withValues(alpha: 0.5)),
              _buildHeatmapLegend('', Theme.of(context).primaryColor.withValues(alpha: 0.7)),
              _buildHeatmapLegend('Mais', Theme.of(context).primaryColor),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Estatísticas do histórico
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildHistoryStat(
                'Maior Sequência',
                '${_stats!.longestStreak} dias',
                Icons.emoji_events,
                Colors.amber,
              ),
              _buildHistoryStat(
                'Dias Ativos',
                '${_countActiveDays()}',
                Icons.calendar_today,
                Colors.blue,
              ),
              _buildHistoryStat(
                'Melhor Mês',
                _getBestMonth(),
                Icons.star,
                Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  List<Widget> _buildCategoryBars() {
    final categories = _stats!.habitsByCategory.entries.toList();
    final maxCount = categories.isEmpty ? 1 : 
        categories.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    
    return categories.map((entry) {
      final percentage = entry.value / maxCount;
      
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  '${entry.value} hábitos',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
  
  Widget _buildHabitPerformanceCard(HabitPerformance performance, {required bool isTop}) {
    final trendIcon = performance.trend == 'improving' ? Icons.trending_up :
                      performance.trend == 'declining' ? Icons.trending_down :
                      Icons.trending_flat;
    
    final trendColor = performance.trend == 'improving' ? Colors.green :
                       performance.trend == 'declining' ? Colors.red :
                       Colors.orange;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: performance.habit.color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            performance.habit.icon,
            color: performance.habit.color,
          ),
        ),
        title: Text(
          performance.habit.title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Row(
          children: [
            Text(
              '${(performance.completionRate * 100).toInt()}%',
              style: TextStyle(
                color: isTop ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              trendIcon,
              size: 16,
              color: trendColor,
            ),
            const SizedBox(width: 4),
            if (performance.currentStreak > 0)
              Text(
                '🔥 ${performance.currentStreak}',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 16),
          onPressed: () {
            // Navegar para detalhes do hábito
            HapticFeedback.lightImpact();
          },
        ),
      ),
    );
  }
  
  Widget _buildHeatmapLegend(String label, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildHistoryStat(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  int _countActiveDays() {
    final activeDays = <DateTime>{};
    final habits = context.read<HabitService>().habits;
    
    for (final habit in habits) {
      activeDays.addAll(
        habit.completionHistory.entries
            .where((e) => e.value)
            .map((e) => e.key)
      );
    }
    
    return activeDays.length;
  }
  
  String _getBestMonth() {
    // Simplified - in real app would calculate properly
    return 'Janeiro';
  }
  
  void _showCategoryBreakdown() {
    HapticFeedback.lightImpact();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            const Text(
              'Hábitos por Categoria',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ..._buildCategoryBars(),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  
  _SliverTabBarDelegate(this.tabBar);
  
  @override
  double get minExtent => tabBar.preferredSize.height;
  
  @override
  double get maxExtent => tabBar.preferredSize.height;
  
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }
  
  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
