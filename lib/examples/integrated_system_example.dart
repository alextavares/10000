import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/services/habit_service.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:myapp/services/notifications/smart_notification_service.dart';
import 'package:myapp/services/notifications/notification_models.dart';
import 'package:myapp/services/notifications/behavior_analyzer.dart';
import 'package:myapp/widgets/in_app_notification.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/models/achievement.dart';

/// Exemplo de integração completa entre todos os sistemas do HabitAI
class IntegratedSystemExample extends StatefulWidget {
  const IntegratedSystemExample({super.key});
  
  @override
  State<IntegratedSystemExample> createState() => _IntegratedSystemExampleState();
}

class _IntegratedSystemExampleState extends State<IntegratedSystemExample> {
  final _habitService = HabitService();
  final _achievementService = AchievementService();
  final _notificationService = SmartNotificationService();
  final _behaviorAnalyzer = BehaviorAnalyzer();
  
  @override
  void initState() {
    super.initState();
    _initializeIntegration();
  }
  
  /// Inicializa a integração entre os sistemas
  Future<void> _initializeIntegration() async {
    // 1. Configurar listeners para mudanças de hábitos
    _habitService.addListener(_onHabitChanged);
    
    // 2. Configurar listeners para conquistas
    _achievementService.addListener(_onAchievementUnlocked);
    
    // 3. Analisar comportamento inicial
    await _analyzeInitialBehavior();
    
    // 4. Agendar notificações inteligentes
    await _scheduleSmartNotifications();
  }
  
  /// Quando um hábito é completado/atualizado
  void _onHabitChanged() async {
    final habits = _habitService.habits;
    
    for (final habit in habits) {
      // Se o hábito foi completado hoje
      if (habit.isCompletedToday) {
        // 1. Atualizar análise de comportamento
        await _behaviorAnalyzer.recordCompletion(
          habitId: habit.id,
          timestamp: DateTime.now(),
        );
        
        // 2. Verificar se desbloqueou conquista
        final newAchievements = await _achievementService.checkAchievements(habit);
        
        // 3. Mostrar notificação in-app de sucesso
        if (mounted) {
          InAppNotificationManager().showNotification(
            context,
            title: '✅ ${habit.name} Concluído!',
            message: _getCompletionMessage(habit),
            icon: Icons.check_circle,
            color: Colors.green,
            onTap: () => _showHabitDetails(habit),
          );
        }
        
        // 4. Se mantendo streak, agendar notificação motivacional
        if (habit.currentStreak > 3) {
          await _scheduleStreakProtectionNotification(habit);
        }
      }
    }
    
    // 5. Re-analisar padrões se necessário
    if (_shouldReanalyze()) {
      await _reanalyzePatterns();
    }
  }
  
  /// Quando uma conquista é desbloqueada
  void _onAchievementUnlocked(Achievement achievement) async {
    // 1. Mostrar notificação especial in-app
    if (mounted) {
      InAppNotificationManager().showNotification(
        context,
        title: '🏆 Conquista Desbloqueada!',
        message: achievement.description,
        icon: Icons.emoji_events,
        color: Colors.amber,
        duration: const Duration(seconds: 6),
        onTap: () => _showAchievementDetails(achievement),
      );
    }
    
    // 2. Agendar notificação de follow-up
    await _notificationService.scheduleNotification(
      id: achievement.id.hashCode,
      title: 'Continue assim! 🎯',
      body: 'Você desbloqueou "${achievement.name}". Que tal buscar a próxima?',
      scheduledDate: DateTime.now().add(const Duration(days: 1)),
      type: NotificationType.motivation,
    );
    
    // 3. Atualizar perfil de gamificação
    _updateGamificationProfile(achievement);
  }
  
  /// Analisa comportamento inicial do usuário
  Future<void> _analyzeInitialBehavior() async {
    final habits = _habitService.habits;
    final analysis = await _behaviorAnalyzer.analyzeUserBehavior(habits);
    
    if (analysis.insights.isNotEmpty && mounted) {
      // Mostrar insight principal
      InAppNotificationManager().showNotification(
        context,
        title: '💡 Insight Descoberto',
        message: analysis.insights.first,
        icon: Icons.lightbulb_outline,
        color: Colors.blue,
        duration: const Duration(seconds: 5),
      );
    }
  }
  
  /// Agenda notificações inteligentes para todos os hábitos
  Future<void> _scheduleSmartNotifications() async {
    final habits = _habitService.habits;
    
    for (final habit in habits) {
      // Usar IA para determinar melhores horários
      final optimalTimes = await _behaviorAnalyzer.predictOptimalTimes(habit);
      
      // Agendar notificações nos horários ótimos
      await _notificationService.scheduleSmartNotifications(
        habit,
        customTimes: optimalTimes,
      );
    }
  }
  
  /// Protege streak em risco
  Future<void> _scheduleStreakProtectionNotification(Habit habit) async {
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 0);
    
    await _notificationService.scheduleNotification(
      id: 'streak_${habit.id}'.hashCode,
      title: '🔥 Proteja sua sequência!',
      body: 'Você tem ${habit.currentStreak} dias de ${habit.name}. Não pare agora!',
      scheduledDate: endOfDay.subtract(const Duration(hours: 2)),
      type: NotificationType.streakAlert,
      payload: habit.id,
    );
  }
  
  /// Mensagem personalizada de conclusão
  String _getCompletionMessage(Habit habit) {
    if (habit.currentStreak > 30) {
      return 'Incrível! ${habit.currentStreak} dias seguidos! 🔥';
    } else if (habit.currentStreak > 7) {
      return 'Ótimo trabalho! Sequência de ${habit.currentStreak} dias!';
    } else if (habit.completionRate > 0.8) {
      return 'Consistência é a chave! ${(habit.completionRate * 100).toInt()}% de taxa!';
    } else {
      return 'Cada dia conta! Continue assim!';
    }
  }
  
  /// Verifica se deve re-analisar padrões
  bool _shouldReanalyze() {
    // Re-analisar a cada 7 completions ou domingo
    final completions = _habitService.getTotalCompletionsThisWeek();
    return completions % 7 == 0 || DateTime.now().weekday == DateTime.sunday;
  }
  
  /// Re-analisa padrões e ajusta notificações
  Future<void> _reanalyzePatterns() async {
    final habits = _habitService.habits;
    final analysis = await _behaviorAnalyzer.analyzeUserBehavior(habits);
    
    // Ajustar notificações baseado em nova análise
    for (final habit in habits) {
      if (analysis.successRateByHour.isNotEmpty) {
        final bestHour = _findBestHour(analysis.successRateByHour);
        
        // Re-agendar se horário mudou significativamente
        await _notificationService.rescheduleIfNeeded(
          habit,
          newHour: bestHour,
        );
      }
    }
  }
  
  int _findBestHour(Map<int, double> successRates) {
    var bestHour = 9; // default
    var bestRate = 0.0;
    
    successRates.forEach((hour, rate) {
      if (rate > bestRate) {
        bestRate = rate;
        bestHour = hour;
      }
    });
    
    return bestHour;
  }
  
  void _updateGamificationProfile(Achievement achievement) {
    // Atualizar perfil baseado no tipo de conquista
    if (achievement.category == 'consistency') {
      // Usuário valoriza consistência - ajustar mensagens
      NotificationService.preferredMessageStyle = MessageStyle.supportive;
    } else if (achievement.category == 'speed') {
      // Usuário gosta de desafios - mensagens mais competitivas
      NotificationService.preferredMessageStyle = MessageStyle.challenging;
    }
  }
  
  void _showHabitDetails(Habit habit) {
    Navigator.pushNamed(context, '/habit-details', arguments: habit);
  }
  
  void _showAchievementDetails(Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => AchievementDialog(achievement: achievement),
    );
  }
  
  @override
  void dispose() {
    _habitService.removeListener(_onHabitChanged);
    _achievementService.removeListener(_onAchievementUnlocked);
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema Integrado'),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights),
            onPressed: _showSystemInsights,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card de Status do Sistema
            _buildSystemStatusCard(),
            
            const SizedBox(height: 20),
            
            // Demonstração de Funcionalidades
            _buildFeatureDemos(),
            
            const SizedBox(height: 20),
            
            // Métricas de Integração
            _buildIntegrationMetrics(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSystemStatusCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Sistema Integrado Ativo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatusItem('Notificações', true, Icons.notifications_active),
            _buildStatusItem('Análise de IA', true, Icons.psychology),
            _buildStatusItem('Gamificação', true, Icons.emoji_events),
            _buildStatusItem('Dashboard', true, Icons.dashboard),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusItem(String label, bool active, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: active ? Colors.green : Colors.grey),
          const SizedBox(width: 8),
          Text(label),
          const Spacer(),
          Icon(
            active ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: active ? Colors.green : Colors.grey,
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeatureDemos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Demonstrações',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Botões de demonstração
        ElevatedButton.icon(
          onPressed: _demoHabitCompletion,
          icon: const Icon(Icons.check),
          label: const Text('Simular Conclusão de Hábito'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
        
        const SizedBox(height: 8),
        
        ElevatedButton.icon(
          onPressed: _demoAchievementUnlock,
          icon: const Icon(Icons.emoji_events),
          label: const Text('Simular Conquista'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            backgroundColor: Colors.amber,
          ),
        ),
        
        const SizedBox(height: 8),
        
        ElevatedButton.icon(
          onPressed: _demoSmartNotification,
          icon: const Icon(Icons.notifications),
          label: const Text('Testar Notificação Inteligente'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            backgroundColor: Colors.blue,
          ),
        ),
      ],
    );
  }
  
  Widget _buildIntegrationMetrics() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Métricas de Integração',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildMetricRow('Notificações Enviadas Hoje', '12'),
            _buildMetricRow('Taxa de Interação', '78%'),
            _buildMetricRow('Precisão da IA', '85%'),
            _buildMetricRow('Hábitos Otimizados', '8/10'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
  
  void _showSystemInsights() {
    Navigator.pushNamed(context, '/system-insights');
  }
  
  void _demoHabitCompletion() {
    // Simular conclusão de hábito
    final demoHabit = Habit(
      id: 'demo',
      name: 'Meditação',
      currentStreak: 7,
      completionRate: 0.85,
    );
    
    InAppNotificationManager().showNotification(
      context,
      title: '✅ Meditação Concluída!',
      message: 'Sequência de 7 dias! Continue assim! 🔥',
      icon: Icons.check_circle,
      color: Colors.green,
    );
  }
  
  void _demoAchievementUnlock() {
    final demoAchievement = Achievement(
      id: 'demo',
      name: 'Mestre da Consistência',
      description: 'Complete 30 dias seguidos de qualquer hábito',
      icon: '🏆',
    );
    
    _onAchievementUnlocked(demoAchievement);
  }
  
  void _demoSmartNotification() async {
    // Demonstrar análise de IA
    InAppNotificationManager().showNotification(
      context,
      title: '🤖 Análise Inteligente',
      message: 'Detectamos que você é mais produtivo às 8h da manhã!',
      icon: Icons.psychology,
      color: Colors.purple,
      duration: const Duration(seconds: 5),
    );
    
    // Seguida de sugestão
    await Future.delayed(const Duration(seconds: 6));
    
    if (mounted) {
      InAppNotificationManager().showNotification(
        context,
        title: '💡 Sugestão',
        message: 'Que tal mover seu hábito de leitura para este horário?',
        icon: Icons.lightbulb,
        color: Colors.amber,
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Abrindo configurações...')),
          );
        },
      );
    }
  }
}

/// Dialog para mostrar detalhes de conquista
class AchievementDialog extends StatelessWidget {
  final Achievement achievement;
  
  const AchievementDialog({
    super.key,
    required this.achievement,
  });
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              achievement.icon,
              style: const TextStyle(fontSize: 60),
            ),
            const SizedBox(height: 16),
            Text(
              achievement.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              achievement.description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Incrível!'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Enums auxiliares para o exemplo
enum MessageStyle {
  supportive,
  challenging,
  neutral,
}
