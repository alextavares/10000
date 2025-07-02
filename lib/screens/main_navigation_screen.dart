import 'package:flutter/material.dart';
import 'package:myapp/screens/home/home_screen.dart';
import 'package:myapp/screens/habits/habits_screen.dart';
import 'package:myapp/screens/habits/add_habit_simple_screen.dart'; // Adicionar importação
import 'package:myapp/screens/tasks/tasks_screen.dart';
import 'package:myapp/screens/task/add_task_screen.dart'; 
import 'package:myapp/screens/timer/timer_screen.dart';
import 'package:myapp/screens/categories/categories_screen.dart';
import 'package:myapp/widgets/app_drawer.dart';
import 'package:myapp/widgets/add_item_bottom_sheet.dart';
// import 'package:myapp/screens/habit/add_habit_screen.dart'; // Antiga tela de adicionar hábito
import 'package:myapp/screens/habit/upsert_habit_screen.dart'; // Nova tela unificada
import 'package:myapp/screens/recurring_task/add_recurring_task_screen.dart';
import 'package:myapp/screens/search/search_screen.dart';
import 'package:myapp/screens/filter/filter_screen.dart';
import 'package:myapp/screens/stats/stats_screen.dart';
import 'package:myapp/screens/achievements/achievements_screen.dart';
import 'package:myapp/screens/calendar/calendar_screen.dart';
import 'package:myapp/utils/logger.dart';
import 'package:myapp/utils/responsive/responsive.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/services/habit_service.dart';
import 'package:myapp/services/achievement_service.dart';
import 'package:myapp/data/achievements/achievement_definitions.dart';
import 'package:myapp/theme/app_theme.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController _tabController;
  final GlobalKey<TasksScreenState> _tasksScreenKey =
      GlobalKey<TasksScreenState>();
  final GlobalKey<HomeScreenState> _homeScreenKey =
      GlobalKey<HomeScreenState>();

  static const List<String> _widgetTitles = <String>[
    'Hoje',
    'Hábitos',
    'Tarefas',
    'Timer',
    'Categorias',
  ];

  late final List<Widget> _widgetOptions;
  AchievementService? _achievementService; // Para remover o listener

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Para a aba Tarefas
    _widgetOptions = <Widget>[
      HomeScreen(key: _homeScreenKey), // Índice 0
      const HabitsScreen(),            // Índice 1
      TasksScreen(key: _tasksScreenKey, tabController: _tabController), // Índice 2
      const TimerScreen(),             // Índice 3
      const CategoriesScreen(),        // Índice 4
      // A tela de Conquistas é navegada via rota, não é uma aba principal aqui.
    ];
    _tabController.addListener(() {
      if (_selectedIndex == 2 && _tabController.indexIsChanging) {
        // setState(() {}); // Não parece necessário
      }
    });

    // Adicionar listener para AchievementService
    // Usar WidgetsBinding.instance.addPostFrameCallback para garantir que o context está pronto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _achievementService = Provider.of<AchievementService>(context, listen: false);
        _achievementService?.addListener(_showAchievementUnlockedSnackbar);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _achievementService?.removeListener(_showAchievementUnlockedSnackbar);
    super.dispose();
  }

  void _showAchievementUnlockedSnackbar() {
    if (!mounted) return;
    final service = _achievementService; //Provider.of<AchievementService>(context, listen: false);
    if (service != null && service.recentlyUnlocked.isNotEmpty) {
      final achievementId = service.recentlyUnlocked.first; // Pega a primeira recém-desbloqueada
      final achievementDef = AchievementDefinitions.getById(achievementId);

      if (achievementDef != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(achievementDef.icon, color: achievementDef.color, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Conquista Desbloqueada!',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        achievementDef.title,
                        style: TextStyle(color: Colors.white.withOpacity(0.9)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.surfaceColor.withBlue(AppTheme.surfaceColor.blue + 20), // Um pouco mais claro ou diferente
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(10),
            action: SnackBarAction(
              label: 'VER',
              textColor: AppTheme.primaryColor,
              onPressed: () {
                Navigator.of(context).pushNamed(AchievementsScreen.routeName);
              },
            ),
          ),
        );
      }
      // Limpa a lista de recém desbloqueadas no serviço após mostrar
      // para não mostrar novamente na próxima notificação de mudança.
      // Isso deve ser feito com cuidado para não limpar antes de todas as UIs reagirem se necessário.
      // Para um SnackBar, limpar após mostrar a primeira é geralmente ok.
      service.clearRecentlyUnlocked();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onDrawerItemSelected(int index) {
    if (index >= 0 && index < _widgetOptions.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _showAddItemBottomSheet(BuildContext context) {
    Logger.debug("=== BOTÃO + CLICADO ===");
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      builder: (BuildContext bc) {
        return AddItemBottomSheet(
          onItemSelected: (AddItemType type) {
            Logger.debug("=== TIPO SELECIONADO: $type ===");
            Navigator.pop(context); 
            switch (type) {
              case AddItemType.habit:
                Logger.debug("=== NAVEGANDO PARA UPSERT HABIT SCREEN ===");
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (context) => const UpsertHabitScreen(), // Usar a tela completa
                      ),
                    )
                    .then((result) {
                      // A UpsertHabitScreen retorna true se um hábito foi salvo/criado
                      if (result == true) {
                        if (_selectedIndex == 0) { // HomeScreen
                          _homeScreenKey.currentState?.refreshScreenData();
                        }
                        // Adicionar lógica para atualizar HabitsScreen se estiver visível
                        if (_selectedIndex == 1) { // HabitsScreen
                          // TODO: Adicionar GlobalKey para HabitsScreen e chamar um método de refresh
                          // Ex: _habitsScreenKey.currentState?.refreshHabits();
                          Logger.info("Retornou de UpsertHabitScreen, deveria atualizar HabitsScreen se ativa.");
                        }
                      }
                    });
                break;
              case AddItemType.recurringTask:
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (context) => const AddRecurringTaskScreen(),
                      ),
                    )
                    .then((result) {
                      if (result == true) {
                        if (_selectedIndex == 2) {
                          _tasksScreenKey.currentState?.refreshScreenData();
                        } else if (_selectedIndex == 0) {
                          _homeScreenKey.currentState?.refreshScreenData();
                        }
                      }
                    });
                break;
              case AddItemType.task:
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (context) => const AddTaskScreen(),
                      ),
                    )
                    .then((result) {
                      if (result == true) {
                        if (_selectedIndex == 2) {
                          _tasksScreenKey.currentState?.refreshScreenData();
                        } else if (_selectedIndex == 0) {
                          _homeScreenKey.currentState?.refreshScreenData(); 
                        }
                      }
                    });
                break;
            }
          },
        );
      },
    );
  }

  Widget _buildDesktopLayout() {
    bool isTasksScreenSelected = _selectedIndex == 2;
    bool showFab = _selectedIndex == 0 || _selectedIndex == 1 || _selectedIndex == 2;
    
    return Scaffold(
      body: Row(
        children: [
          // Navigation Rail
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            backgroundColor: Colors.black,
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: showFab
                  ? FloatingActionButton(
                      onPressed: () => _showAddItemBottomSheet(context),
                      backgroundColor: const Color(0xFFE91E63),
                      heroTag: 'mainFab',
                      child: const Icon(Icons.add, color: Colors.white),
                    )
                  : const SizedBox(height: 56),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('Hoje'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.star_border_outlined),
                selectedIcon: Icon(Icons.star),
                label: Text('Hábitos'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.check_circle_outline),
                selectedIcon: Icon(Icons.check_circle),
                label: Text('Tarefas'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.timer_outlined),
                selectedIcon: Icon(Icons.timer),
                label: Text('Timer'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.apps),
                selectedIcon: Icon(Icons.apps),
                label: Text('Categorias'),
              ),
            ],
            selectedIconTheme: const IconThemeData(color: Color(0xFFE91E63)),
            selectedLabelTextStyle: const TextStyle(color: Color(0xFFE91E63)),
            unselectedIconTheme: const IconThemeData(color: Colors.grey),
            unselectedLabelTextStyle: const TextStyle(color: Colors.grey),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Content
          Expanded(
            child: Column(
              children: [
                AppBar(
                  title: Text(
                    _widgetTitles[_selectedIndex],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  backgroundColor: Colors.black,
                  elevation: 0,
                  iconTheme: const IconThemeData(color: Colors.white),
                  actions: _buildAppBarActions(),
                  bottom: isTasksScreenSelected
                      ? TabBar(
                          controller: _tabController,
                          tabs: const [
                            Tab(text: 'Tarefas simples'),
                            Tab(text: 'Tarefas recorrentes'),
                          ],
                          indicatorColor: const Color(0xFFE91E63),
                          labelColor: const Color(0xFFE91E63),
                          unselectedLabelColor: Colors.grey,
                        )
                      : null,
                ),
                Expanded(
                  child: _widgetOptions.elementAt(_selectedIndex),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    bool isTasksScreenSelected = _selectedIndex == 2;
    bool showFab = _selectedIndex == 0 || _selectedIndex == 1 || _selectedIndex == 2;
    
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
        title: Text(
          _widgetTitles[_selectedIndex],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: _buildAppBarActions(),
        bottom: isTasksScreenSelected
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Tarefas simples'),
                  Tab(text: 'Tarefas recorrentes'),
                ],
                indicatorColor: const Color(0xFFE91E63),
                labelColor: const Color(0xFFE91E63),
                unselectedLabelColor: Colors.grey,
              )
            : null,
      ),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Hoje',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_border_outlined),
            label: 'Hábitos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Tarefas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_outlined),
            label: 'Timer',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.apps), label: 'Categorias'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFE91E63),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          color: Color(0xFFE91E63),
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      drawer: AppDrawer(
        currentSelectedIndex: _selectedIndex,
        onItemSelected: _onDrawerItemSelected, 
      ),
      floatingActionButton: showFab
          ? FloatingActionButton(
              onPressed: () => _showAddItemBottomSheet(context),
              backgroundColor: const Color(0xFFE91E63),
              heroTag: 'mainFab', 
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    List<Widget> actions = [];
    
    // BOTÃO TEMPORÁRIO PARA TESTE DE NOTIFICAÇÕES
    actions.add(
      IconButton(
        icon: const Icon(Icons.notifications_active, color: Colors.amber),
        tooltip: 'Testar Notificações',
        onPressed: () {
          Navigator.pushNamed(context, '/test-notifications');
        },
      ),
    );
    
    // BOTÃO TEMPORÁRIO PARA TESTE DE CRIAÇÃO DE HÁBITO
    actions.add(
      IconButton(
        icon: const Icon(Icons.bug_report, color: Colors.red),
        tooltip: 'Testar Criação de Hábito',
        onPressed: () async {
          try {
            final habitService = Provider.of<HabitService>(context, listen: false);
            final auth = FirebaseAuth.instance;
            final user = auth.currentUser;
            
            if (user == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('❌ Usuário não autenticado!')),
              );
              return;
            }
            
            // Criar hábito de teste
            final testHabit = Habit(
              id: 'test-${DateTime.now().millisecondsSinceEpoch}',
              title: 'Hábito de Teste ${DateTime.now().second}',
              description: 'Criado automaticamente para teste',
              category: 'Saúde',
              icon: Icons.directions_run,
              color: const Color(0xFF4CAF50),
              priority: 'Normal',
              frequency: HabitFrequency.daily,
              startDate: DateTime.now(),
              trackingType: HabitTrackingType.simOuNao,
              userId: user.uid,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              completionHistory: {},
              dailyProgress: {},
              streak: 0,
              longestStreak: 0,
              totalCompletions: 0,
              notificationsEnabled: false,
            );
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('📝 Criando hábito de teste...')),
            );
            
            await habitService.addHabit(testHabit);
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ Hábito "${testHabit.title}" criado com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
            
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Erro: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
    
    if (_selectedIndex == 0 || _selectedIndex == 1 || _selectedIndex == 2) {
      actions.addAll([
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.white),
          onPressed: () {
            Navigator.of(context)
                .push(
                  MaterialPageRoute(
                    builder: (context) => FilterScreen(
                      initialOptions: FilterOptions(),
                    ),
                  ),
                )
                .then((filterOptions) {
                  if (filterOptions != null) {
                    Logger.debug('Filter options applied: $filterOptions');
                  }
                });
          },
        ),
      ]);
      
      if (_selectedIndex == 1 || _selectedIndex == 2) {
        actions.add(
          IconButton(
            icon: const Icon(
              Icons.file_download_outlined,
              color: Colors.white,
            ),
            onPressed: () {
              /* Archive/Download action */
            },
          ),
        );
      }
      
      if (_selectedIndex == 0) {
        actions.addAll([
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const StatsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CalendarScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {
              /* Open help */
            },
          ),
        ]);
      }
    }
    
    if (_selectedIndex == 3) {
      actions.addAll([
        IconButton(
          icon: const Icon(Icons.vibration_outlined, color: Colors.white),
          onPressed: () {
            // Vibration toggle will be handled by timer screen
          },
        ),
        IconButton(
          icon: const Icon(Icons.volume_up_outlined, color: Colors.white),
          onPressed: () {
            // Sound toggle will be handled by timer screen
          },
        ),
      ]);
    }
    
    if (_selectedIndex == 4) {
      actions.addAll([
        IconButton(
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.info_outline, color: Colors.white),
          onPressed: () {},
        ),
      ]);
    }
    
    return actions;
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      desktop: _buildDesktopLayout(),
    );
  }
}
