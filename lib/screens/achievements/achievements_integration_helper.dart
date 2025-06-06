import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:myapp/widgets/achievement_card.dart';
import 'package:myapp/data/achievements/achievement_definitions.dart';

/// Mixin para adicionar funcionalidade de conquistas a qualquer tela
mixin AchievementsMixin<T extends StatefulWidget> on State<T> {
  final List<Achievement> _pendingNotifications = [];
  bool _isShowingNotification = false;
  
  /// Verifica conquistas e mostra notificações se houver novas
  Future<void> checkAndShowAchievements() async {
    final achievementService = context.read<AchievementService>();
    final habitService = context.read<HabitService>(); // Assumindo que existe
    
    // Obter todos os hábitos
    final habits = await habitService.getAllHabits();
    
    // Verificar novas conquistas
    final newAchievements = await achievementService.checkAchievements(habits);
    
    // Adicionar à fila de notificações
    if (newAchievements.isNotEmpty) {
      _pendingNotifications.addAll(newAchievements);
      _showNextNotification();
    }
  }
  
  /// Mostra a próxima notificação da fila
  void _showNextNotification() {
    if (_isShowingNotification || _pendingNotifications.isEmpty) return;
    
    _isShowingNotification = true;
    final achievement = _pendingNotifications.removeAt(0);
    
    // Usar Overlay para mostrar notificação sobre qualquer tela
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: AchievementUnlockedNotification(
            achievement: achievement,
            onDismiss: () {
              overlayEntry.remove();
              _isShowingNotification = false;
              
              // Marcar como vista
              context.read<AchievementService>()
                  .markAchievementsAsSeen([achievement.id]);
              
              // Mostrar próxima se houver
              Future.delayed(const Duration(milliseconds: 300), () {
                _showNextNotification();
              });
            },
          ),
        ),
      ),
    );
    
    overlay.insert(overlayEntry);
    
    // Auto-remover após 4 segundos se não foi dispensada
    Future.delayed(const Duration(seconds: 4), () {
      if (_isShowingNotification) {
        overlayEntry.remove();
        _isShowingNotification = false;
        _showNextNotification();
      }
    });
  }
  
  /// Widget para mostrar badge de conquistas no AppBar
  Widget buildAchievementBadge() {
    return Consumer<AchievementService>(
      builder: (context, service, _) {
        final newCount = service.recentlyUnlocked.length;
        
        if (newCount == 0) {
          return IconButton(
            icon: const Icon(Icons.emoji_events_outlined),
            onPressed: _navigateToAchievements,
          );
        }
        
        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.emoji_events),
              onPressed: _navigateToAchievements,
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  '$newCount',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  /// Navega para tela de conquistas
  void _navigateToAchievements() {
    Navigator.pushNamed(context, '/achievements');
  }
}

/// Exemplo de uso em uma tela de hábitos
class ExampleHabitsScreenWithAchievements extends StatefulWidget {
  const ExampleHabitsScreenWithAchievements({super.key});
  
  @override
  State<ExampleHabitsScreenWithAchievements> createState() =>
      _ExampleHabitsScreenWithAchievementsState();
}

class _ExampleHabitsScreenWithAchievementsState
    extends State<ExampleHabitsScreenWithAchievements>
    with AchievementsMixin {
  
  @override
  void initState() {
    super.initState();
    // Verificar conquistas ao abrir a tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkAndShowAchievements();
    });
  }
  
  Future<void> _toggleHabitCompletion(Habit habit) async {
    // Lógica existente para marcar/desmarcar hábito...
    
    // Após atualizar o hábito, verificar conquistas
    await checkAndShowAchievements();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Hábitos'),
        actions: [
          // Badge de conquistas no AppBar
          buildAchievementBadge(),
        ],
      ),
      body: Consumer<HabitService>(
        builder: (context, habitService, _) {
          // Conteúdo da tela...
          return ListView.builder(
            itemCount: habitService.habits.length,
            itemBuilder: (context, index) {
              final habit = habitService.habits[index];
              return HabitCardAnimated(
                habit: habit,
                onToggle: () => _toggleHabitCompletion(habit),
              );
            },
          );
        },
      ),
    );
  }
}

/// Widget minimalista para mostrar progresso de nível no drawer/perfil
class LevelProgressWidget extends StatelessWidget {
  const LevelProgressWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Consumer<AchievementService>(
      builder: (context, service, _) {
        final profile = service.userProfile;
        if (profile == null) return const SizedBox.shrink();
        
        final pointsToNext = UserAchievementProfile.pointsToNextLevel(
          profile.totalPoints,
        );
        final progress = pointsToNext > 0 
            ? 1 - (pointsToNext / 1000).clamp(0.0, 1.0)
            : 1.0;
        
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nível ${profile.level}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        profile.title,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${profile.totalPoints}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                pointsToNext > 0
                    ? '$pointsToNext pontos para o próximo nível'
                    : 'Nível máximo alcançado!',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
