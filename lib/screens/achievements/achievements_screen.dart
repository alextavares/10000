import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:myapp/data/achievements/achievement_definitions.dart';
import 'package:myapp/data/achievements/user_achievement_profile.dart';
import 'package:myapp/widgets/achievement_card.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});
  
  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with TickerProviderStateMixin {
  AchievementCategory? _selectedCategory;
  late TabController _tabController;
  late AnimationController _headerAnimationController;
  late Animation<double> _headerAnimation;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _headerAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeInOut,
    );
    _headerAnimationController.forward();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final achievementService = context.watch<AchievementService>();
    final profile = achievementService.userProfile;
    
    if (profile == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header com informações do perfil
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildProfileHeader(profile),
            ),
            title: const Text('Conquistas'),
          ),
          
          // Tabs de categorias
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Theme.of(context).primaryColor,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.local_fire_department),
                    text: 'Sequência',
                  ),
                  Tab(
                    icon: Icon(Icons.check_circle),
                    text: 'Conclusões',
                  ),
                  Tab(
                    icon: Icon(Icons.palette),
                    text: 'Variedade',
                  ),
                  Tab(
                    icon: Icon(Icons.star),
                    text: 'Consistência',
                  ),
                  Tab(
                    icon: Icon(Icons.celebration),
                    text: 'Especiais',
                  ),
                ],
              ),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
          
          // Grid de conquistas
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAchievementGrid(
                  achievementService,
                  AchievementCategory.streak,
                ),
                _buildAchievementGrid(
                  achievementService,
                  AchievementCategory.completion,
                ),
                _buildAchievementGrid(
                  achievementService,
                  AchievementCategory.variety,
                ),
                _buildAchievementGrid(
                  achievementService,
                  AchievementCategory.consistency,
                ),
                _buildAchievementGrid(
                  achievementService,
                  AchievementCategory.special,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProfileHeader(UserAchievementProfile profile) {
    final pointsToNext = UserAchievementProfile.pointsToNextLevel(profile.totalPoints);
    final completionPercentage = profile.getCompletionPercentage();
    
    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        return Container(
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
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar com nível
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Círculo de progresso do nível
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          value: _headerAnimation.value * 
                              (1 - (pointsToNext / 1000).clamp(0.0, 1.0)),
                          strokeWidth: 6,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      // Avatar
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'LVL',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '${profile.level}',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Título e pontos
                  FadeTransition(
                    opacity: _headerAnimation,
                    child: Column(
                      children: [
                        Text(
                          profile.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${profile.totalPoints} pontos',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        if (pointsToNext > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            '$pointsToNext pontos para o próximo nível',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Estatísticas
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(_headerAnimation),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStat(
                          '${(completionPercentage * 100).toInt()}%',
                          'Completo',
                          Icons.pie_chart,
                        ),
                        _buildStat(
                          '${profile.getUnlockedAchievementIds().length}',
                          'Desbloqueadas',
                          Icons.lock_open,
                        ),
                        _buildStat(
                          '${AchievementDefinitions.getAllAchievements().length}',
                          'Total',
                          Icons.emoji_events,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.8),
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
  
  Widget _buildAchievementGrid(
    AchievementService service,
    AchievementCategory category,
  ) {
    final achievements = service.getAchievementsByCategory(category);
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final (achievement, progress) = achievements[index];
        
        return AnimatedScale(
          scale: 1.0,
          duration: Duration(milliseconds: 300 + (index * 50)),
          child: AchievementCard(
            achievement: achievement,
            progress: progress,
            onTap: () => _showAchievementDetails(achievement, progress),
          ),
        );
      },
    );
  }
  
  void _showAchievementDetails(
    Achievement achievement,
    AchievementProgress progress,
  ) {
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
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: progress.isUnlocked
                    ? achievement.color.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.2),
              ),
              child: Icon(
                achievement.icon,
                size: 40,
                color: progress.isUnlocked
                    ? achievement.color
                    : Colors.grey,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Title
            Text(
              achievement.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Description
            Text(
              achievement.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Progress or unlocked date
            if (progress.isUnlocked) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Desbloqueada em ${_formatDate(progress.unlockedAt!)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Progress bar
              LinearProgressIndicator(
                value: achievement.requirement > 0
                    ? (progress.currentProgress / achievement.requirement)
                        .clamp(0.0, 1.0)
                    : 0.0,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(achievement.color),
              ),
              const SizedBox(height: 8),
              Text(
                '${progress.currentProgress} / ${achievement.requirement}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Points
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: achievement.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    color: achievement.color,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${achievement.points} pontos',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: achievement.color,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color color;
  
  _SliverTabBarDelegate({
    required this.tabBar,
    required this.color,
  });
  
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
      color: color,
      child: tabBar,
    );
  }
  
  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
