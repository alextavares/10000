import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/services/habit_service.dart';
import 'package:myapp/services/notifications/smart_notification_service.dart';
import 'package:myapp/services/notifications/notification_models.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});
  
  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen>
    with TickerProviderStateMixin {
  final SmartNotificationService _notificationService = SmartNotificationService();
  late TabController _tabController;
  late AnimationController _animationController;
  
  bool _globalNotifications = true;
  bool _smartScheduling = true;
  bool _motivationalMessages = true;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
    _loadGlobalSettings();
  }
  
  Future<void> _loadGlobalSettings() async {
    // Carregar configurações globais do SharedPreferences
    setState(() {
      // Valores padrão por enquanto
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header animado
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, -1),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _animationController,
                            curve: Curves.easeOut,
                          )),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications_active,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeTransition(
                          opacity: _animationController,
                          child: const Text(
                            'Notificações Inteligentes',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        FadeTransition(
                          opacity: _animationController,
                          child: Text(
                            'Receba lembretes no momento perfeito',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              title: const Text('Notificações'),
            ),
          ),
          
          // Configurações globais
          SliverToBoxAdapter(
            child: _buildGlobalSettings(),
          ),
          
          // Tabs
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: Theme.of(context).primaryColor,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.schedule),
                    text: 'Por Hábito',
                  ),
                  Tab(
                    icon: Icon(Icons.insights),
                    text: 'Inteligência',
                  ),
                ],
              ),
            ),
          ),
          
          // Conteúdo das tabs
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildHabitSettingsTab(),
                _buildIntelligenceTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGlobalSettings() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configurações Gerais',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Switch principal
          _buildAnimatedSwitch(
            title: 'Notificações Ativas',
            subtitle: 'Receber lembretes e motivação',
            value: _globalNotifications,
            onChanged: (value) {
              setState(() => _globalNotifications = value);
              HapticFeedback.lightImpact();
            },
            icon: Icons.notifications,
            color: Theme.of(context).primaryColor,
          ),
          
          const SizedBox(height: 12),
          
          // Agendamento inteligente
          AnimatedOpacity(
            opacity: _globalNotifications ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 300),
            child: _buildAnimatedSwitch(
              title: 'Agendamento Inteligente',
              subtitle: 'IA decide os melhores horários',
              value: _smartScheduling && _globalNotifications,
              onChanged: _globalNotifications ? (value) {
                setState(() => _smartScheduling = value);
                HapticFeedback.lightImpact();
              } : null,
              icon: Icons.auto_awesome,
              color: Colors.purple,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Mensagens motivacionais
          AnimatedOpacity(
            opacity: _globalNotifications ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 300),
            child: _buildAnimatedSwitch(
              title: 'Mensagens Motivacionais',
              subtitle: 'Incentivos personalizados',
              value: _motivationalMessages && _globalNotifications,
              onChanged: _globalNotifications ? (value) {
                setState(() => _motivationalMessages = value);
                HapticFeedback.lightImpact();
              } : null,
              icon: Icons.favorite,
              color: Colors.red,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Botão de teste
          Center(
            child: ElevatedButton.icon(
              onPressed: _globalNotifications ? _sendTestNotification : null,
              icon: const Icon(Icons.send),
              label: const Text('Enviar Notificação Teste'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnimatedSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
    required IconData icon,
    required Color color,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value ? 1 : 0),
      duration: const Duration(milliseconds: 300),
      builder: (context, animation, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1 * animation),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.3 * animation),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
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
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: color,
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildHabitSettingsTab() {
    return Consumer<HabitService>(
      builder: (context, habitService, _) {
        final habits = habitService.habits;
        
        if (habits.isEmpty) {
          return const Center(
            child: Text('Nenhum hábito criado ainda'),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: habits.length,
          itemBuilder: (context, index) {
            final habit = habits[index];
            return _buildHabitSettingCard(habit);
          },
        );
      },
    );
  }
  
  Widget _buildHabitSettingCard(Habit habit) {
    final settings = _notificationService.getHabitSettings(habit.id) ??
        HabitNotificationSettings(
          habitId: habit.id,
          reminderTimes: habit.reminderTime != null ? [habit.reminderTime!] : [],
        );
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: habit.color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            habit.icon,
            color: habit.color,
          ),
        ),
        title: Text(
          habit.title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          settings.enabled 
              ? '${settings.reminderTimes.length} lembretes ativos'
              : 'Notificações desativadas',
          style: TextStyle(
            color: settings.enabled ? Colors.green : Colors.grey,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Toggle de ativação
                SwitchListTile(
                  title: const Text('Ativar Notificações'),
                  subtitle: const Text('Receber lembretes para este hábito'),
                  value: settings.enabled,
                  onChanged: (value) async {
                    final newSettings = settings.copyWith(enabled: value);
                    await _notificationService.updateHabitSettings(
                      habit.id,
                      newSettings,
                    );
                    
                    if (value) {
                      await _notificationService.scheduleSmartNotifications(habit);
                    } else {
                      await _notificationService.cancelHabitNotifications(habit.id);
                    }
                    
                    setState(() {});
                    HapticFeedback.lightImpact();
                  },
                ),
                
                if (settings.enabled) ...[
                  const Divider(),
                  
                  // Horários de lembrete
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Horários de Lembrete'),
                    subtitle: settings.reminderTimes.isEmpty
                        ? const Text('Nenhum horário definido')
                        : Wrap(
                            spacing: 8,
                            children: settings.reminderTimes.map((time) {
                              return Chip(
                                label: Text(time.format(context)),
                                onDeleted: () => _removeReminderTime(
                                  habit,
                                  settings,
                                  time,
                                ),
                              );
                            }).toList(),
                          ),
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _addReminderTime(habit, settings),
                    ),
                  ),
                  
                  // Opções avançadas
                  SwitchListTile(
                    title: const Text('Agendamento Inteligente'),
                    subtitle: const Text('Deixar a IA escolher os melhores horários'),
                    value: settings.smartScheduling,
                    onChanged: (value) async {
                      final newSettings = settings.copyWith(
                        smartScheduling: value,
                      );
                      await _notificationService.updateHabitSettings(
                        habit.id,
                        newSettings,
                      );
                      await _notificationService.scheduleSmartNotifications(habit);
                      setState(() {});
                    },
                  ),
                  
                  SwitchListTile(
                    title: const Text('Mensagens Motivacionais'),
                    subtitle: const Text('Receber incentivos personalizados'),
                    value: settings.motivationalMessages,
                    onChanged: (value) async {
                      final newSettings = settings.copyWith(
                        motivationalMessages: value,
                      );
                      await _notificationService.updateHabitSettings(
                        habit.id,
                        newSettings,
                      );
                      setState(() {});
                    },
                  ),
                  
                  SwitchListTile(
                    title: const Text('Lembretes de Sequência'),
                    subtitle: const Text('Notificar sobre streaks em risco'),
                    value: settings.streakReminders,
                    onChanged: (value) async {
                      final newSettings = settings.copyWith(
                        streakReminders: value,
                      );
                      await _notificationService.updateHabitSettings(
                        habit.id,
                        newSettings,
                      );
                      setState(() {});
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildIntelligenceTab() {
    final pattern = _notificationService.userPattern;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status da análise
          _buildAnalysisStatus(pattern),
          
          const SizedBox(height: 24),
          
          // Insights do comportamento
          if (pattern != null) ...[
            _buildBehaviorInsights(pattern),
            const SizedBox(height: 24),
            _buildOptimalTimesCard(pattern),
            const SizedBox(height: 24),
            _buildChronotypeCard(pattern),
          ],
          
          // Botão para forçar análise
          Center(
            child: ElevatedButton.icon(
              onPressed: _runBehaviorAnalysis,
              icon: const Icon(Icons.psychology),
              label: const Text('Analisar Meu Comportamento'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnalysisStatus(UserBehaviorPattern? pattern) {
    final hasAnalysis = pattern != null;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasAnalysis
              ? [Colors.green.withValues(alpha: 0.1), Colors.green.withValues(alpha: 0.05)]
              : [Colors.orange.withValues(alpha: 0.1), Colors.orange.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasAnalysis ? Colors.green : Colors.orange,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: hasAnalysis ? Colors.green : Colors.orange,
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasAnalysis ? Icons.check : Icons.info_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasAnalysis ? 'Análise Completa' : 'Análise Pendente',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasAnalysis
                      ? 'A IA está otimizando seus lembretes'
                      : 'Complete mais hábitos para análise precisa',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBehaviorInsights(UserBehaviorPattern pattern) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🧠 Insights do Seu Comportamento',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Score de motivação
        _buildInsightCard(
          icon: Icons.trending_up,
          title: 'Motivação Geral',
          value: '${(pattern.overallMotivationScore * 100).toInt()}%',
          color: _getColorForScore(pattern.overallMotivationScore),
          subtitle: _getMotivationMessage(pattern.overallMotivationScore),
        ),
        
        const SizedBox(height: 12),
        
        // Dias mais ativos
        _buildInsightCard(
          icon: Icons.calendar_today,
          title: 'Dias Mais Ativos',
          value: _formatActiveDays(pattern.activeDaysOfWeek),
          color: Colors.blue,
          subtitle: 'Seus melhores dias para hábitos',
        ),
        
        const SizedBox(height: 12),
        
        // Categoria de maior sucesso
        if (pattern.categorySuccessRates.isNotEmpty) ...[
          _buildInsightCard(
            icon: Icons.star,
            title: 'Melhor Categoria',
            value: _getBestCategory(pattern.categorySuccessRates),
            color: Colors.purple,
            subtitle: 'Onde você tem mais sucesso',
          ),
        ],
      ],
    );
  }
  
  Widget _buildOptimalTimesCard(UserBehaviorPattern pattern) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.indigo.withValues(alpha: 0.1),
            Colors.indigo.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.indigo.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.access_time_filled,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Horários Ótimos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (pattern.optimalMorningTime != null)
            _buildTimeRow(
              'Manhã',
              pattern.optimalMorningTime!,
              Icons.wb_sunny,
              Colors.orange,
            ),
          
          if (pattern.optimalEveningTime != null)
            _buildTimeRow(
              'Noite',
              pattern.optimalEveningTime!,
              Icons.nights_stay,
              Colors.deepPurple,
            ),
          
          if (pattern.optimalMorningTime == null && 
              pattern.optimalEveningTime == null)
            const Text(
              'Continue usando o app para descobrir seus horários ideais',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildChronotypeCard(UserBehaviorPattern pattern) {
    final chronotypeData = _getChronotypeData(pattern.userChronotype);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            chronotypeData['color'].withValues(alpha: 0.1),
            chronotypeData['color'].withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: chronotypeData['color'].withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              chronotypeData['icon'],
              color: chronotypeData['color'],
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Você é ${chronotypeData['title']}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  chronotypeData['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInsightCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
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
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTimeRow(String label, TimeOfDay time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              time.format(context),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Helpers
  
  Future<void> _sendTestNotification() async {
    await _notificationService.sendInstantNotification(
      title: '🎯 Teste de Notificação',
      body: 'Suas notificações estão funcionando perfeitamente!',
      type: NotificationType.motivation,
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notificação teste enviada!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  
  Future<void> _addReminderTime(
    Habit habit,
    HabitNotificationSettings settings,
  ) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    
    if (time != null) {
      final newTimes = [...settings.reminderTimes, time];
      final newSettings = settings.copyWith(reminderTimes: newTimes);
      
      await _notificationService.updateHabitSettings(habit.id, newSettings);
      await _notificationService.scheduleSmartNotifications(habit);
      
      setState(() {});
      HapticFeedback.lightImpact();
    }
  }
  
  Future<void> _removeReminderTime(
    Habit habit,
    HabitNotificationSettings settings,
    TimeOfDay time,
  ) async {
    final newTimes = settings.reminderTimes.where((t) => t != time).toList();
    final newSettings = settings.copyWith(reminderTimes: newTimes);
    
    await _notificationService.updateHabitSettings(habit.id, newSettings);
    await _notificationService.scheduleSmartNotifications(habit);
    
    setState(() {});
    HapticFeedback.lightImpact();
  }
  
  Future<void> _runBehaviorAnalysis() async {
    final habitService = context.read<HabitService>();
    final habits = await habitService.getAllHabits();
    
    setState(() {
      // Mostrar loading
    });
    
    await _notificationService.analyzeUserBehavior(habits);
    
    setState(() {
      // Análise completa
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Análise de comportamento concluída!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  
  Color _getColorForScore(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.blue;
    if (score >= 0.4) return Colors.orange;
    return Colors.red;
  }
  
  String _getMotivationMessage(double score) {
    if (score >= 0.8) return 'Excelente! Continue assim!';
    if (score >= 0.6) return 'Muito bom! Há espaço para melhorar';
    if (score >= 0.4) return 'Regular. Vamos melhorar juntos!';
    return 'Precisamos trabalhar sua motivação';
  }
  
  String _formatActiveDays(List<int> days) {
    if (days.isEmpty) return 'Nenhum ainda';
    
    const weekDays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    return days.map((d) => weekDays[d - 1]).join(', ');
  }
  
  String _getBestCategory(Map<String, double> rates) {
    if (rates.isEmpty) return '-';
    
    String bestCategory = '';
    double bestRate = 0;
    
    rates.forEach((category, rate) {
      if (rate > bestRate) {
        bestRate = rate;
        bestCategory = category;
      }
    });
    
    return bestCategory;
  }
  
  Map<String, dynamic> _getChronotypeData(String chronotype) {
    switch (chronotype) {
      case 'morning_lark':
        return {
          'title': 'uma Pessoa Matinal',
          'description': 'Você é mais produtivo pela manhã',
          'icon': Icons.wb_sunny,
          'color': Colors.orange,
        };
      case 'night_owl':
        return {
          'title': 'uma Pessoa Noturna',
          'description': 'Você rende mais à noite',
          'icon': Icons.nights_stay,
          'color': Colors.deepPurple,
        };
      default:
        return {
          'title': 'Equilibrado',
          'description': 'Você se adapta bem a diferentes horários',
          'icon': Icons.balance,
          'color': Colors.blue,
        };
    }
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
