import 'package:flutter/material.dart';
import 'package:myapp/screens/home/home_screen.dart';
import 'package:myapp/screens/habits/habits_screen.dart';
import 'package:myapp/screens/tasks/tasks_screen.dart';
import 'package:myapp/screens/task/add_task_screen.dart'; 
import 'package:myapp/screens/timer/timer_screen.dart';
import 'package:myapp/screens/categories/categories_screen.dart';
import 'package:myapp/widgets/app_drawer.dart';
import 'package:myapp/widgets/add_item_bottom_sheet.dart';
import 'package:myapp/screens/habit/add_habit_screen.dart'; 
import 'package:myapp/screens/recurring_task/add_recurring_task_screen.dart';
import 'package:myapp/screens/search/search_screen.dart';
import 'package:myapp/screens/filter/filter_screen.dart';
import 'package:myapp/screens/stats/stats_screen.dart';
import 'package:myapp/screens/calendar/calendar_screen.dart';
import 'package:myapp/utils/logger.dart';
import 'package:myapp/utils/responsive/responsive.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _widgetOptions = <Widget>[
      HomeScreen(key: _homeScreenKey),
      const HabitsScreen(),
      TasksScreen(key: _tasksScreenKey, tabController: _tabController),
      const TimerScreen(),
      const CategoriesScreen(),
    ];
    _tabController.addListener(() {
      if (_selectedIndex == 2 && _tabController.indexIsChanging) {
        // setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            Navigator.pop(context); 
            switch (type) {
              case AddItemType.habit:
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (context) => const AddHabitScreen(),
                      ),
                    )
                    .then((result) {
                      if (result == true || result == null) { 
                        if (_selectedIndex == 0) {
                          _homeScreenKey.currentState?.refreshScreenData();
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
