import 'package:flutter/material.dart';
import 'package:myapp/screens/home/home_screen.dart';
import 'package:myapp/screens/habits/habits_screen.dart';
import 'package:myapp/screens/tasks/tasks_screen.dart';
import 'package:myapp/screens/task/add_task_screen.dart'; 
import 'package:myapp/screens/timer/timer_screen.dart';
import 'package:myapp/screens/categories/categories_screen.dart';
import 'package:myapp/widgets/app_drawer.dart';
import 'package:myapp/widgets/add_item_bottom_sheet.dart'; // Import the bottom sheet
import 'package:myapp/screens/habit/add_habit_screen.dart'; // Import AddHabitScreen for navigation
import 'package:myapp/screens/recurring_task/add_recurring_task_screen.dart'; // Import AddRecurringTaskScreen for navigation

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController _tabController;
  final GlobalKey<TasksScreenState> _tasksScreenKey = GlobalKey<TasksScreenState>();
  final GlobalKey<HomeScreenState> _homeScreenKey = GlobalKey<HomeScreenState>();

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
            Navigator.pop(context); // Close the bottom sheet first
            switch (type) {
              case AddItemType.habit:
                print('Habit selected. Navigating to AddHabitScreen (Category Selection).');
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AddHabitScreen()),
                ).then((result) { // Adicionado .then para atualizar a tela Hoje se um hábito for adicionado
                  if (result == true || result == null) { // result == null se apenas voltou
                    if (_widgetTitles[_selectedIndex] == 'Hoje') {
                      _homeScreenKey.currentState?.refreshScreenData(); 
                    }
                    // A tela de hábitos já se atualiza ao retornar do AddHabitScreen
                  }
                });
                break;
              case AddItemType.recurringTask:
                print('Recurring Task selected. Navigating to AddRecurringTaskScreen.');
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AddRecurringTaskScreen()),
                ).then((result) {
                  if (result == true) {
                    if (_widgetTitles[_selectedIndex] == 'Tarefas') {
                      _tasksScreenKey.currentState?.refreshTasks();
                    } else if (_widgetTitles[_selectedIndex] == 'Hoje') {
                      _homeScreenKey.currentState?.refreshScreenData();
                    }
                  }
                });
                break;
              case AddItemType.task:
                print('Task selected. Navigating to AddTaskScreen.');
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AddTaskScreen()),
                ).then((result) {
                  if (result == true) {
                    if (_widgetTitles[_selectedIndex] == 'Tarefas') {
                      _tasksScreenKey.currentState?.refreshTasks();
                    } else if (_widgetTitles[_selectedIndex] == 'Hoje') {
                      _homeScreenKey.currentState?.refreshScreenData(); // CORRIGIDO AQUI
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

  @override
  Widget build(BuildContext context) {
    bool isTasksScreenSelected = _widgetTitles[_selectedIndex] == 'Tarefas';
    bool showFab = _widgetTitles[_selectedIndex] == 'Hoje' || 
                   _widgetTitles[_selectedIndex] == 'Hábitos' || 
                   _widgetTitles[_selectedIndex] == 'Tarefas';

    return Scaffold(
      appBar: AppBar(
        title: Text(_widgetTitles[_selectedIndex], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_widgetTitles[_selectedIndex] == 'Hoje' || 
              _widgetTitles[_selectedIndex] == 'Hábitos' || 
              _widgetTitles[_selectedIndex] == 'Tarefas') ...[
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () { /* Search action */ },
            ),
            IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.white),
              onPressed: () { /* Filter action */ },
            ),
            if (_widgetTitles[_selectedIndex] == 'Hábitos' || _widgetTitles[_selectedIndex] == 'Tarefas')
              IconButton(
                icon: const Icon(Icons.file_download_outlined, color: Colors.white),
                onPressed: () { /* Archive/Download action */ },
              ),
            if (_widgetTitles[_selectedIndex] == 'Hoje') ...[
              IconButton(
                icon: const Icon(Icons.calendar_today, color: Colors.white),
                onPressed: () { /* Open calendar */ },
              ),
              IconButton(
                icon: const Icon(Icons.help_outline, color: Colors.white),
                onPressed: () { /* Open help */ },
              ),
            ]
          ],
          if (_widgetTitles[_selectedIndex] == 'Timer') ...[
            IconButton(icon: const Icon(Icons.info_outline, color: Colors.white), onPressed: () {}),
            IconButton(icon: const Icon(Icons.wifi_tethering_outlined, color: Colors.white), onPressed: () {}),
            IconButton(icon: const Icon(Icons.volume_up_outlined, color: Colors.white), onPressed: () {}),
          ],
          if (_widgetTitles[_selectedIndex] == 'Categorias') ...[
             IconButton(icon: const Icon(Icons.check_circle_outline, color: Colors.white), onPressed: () {}),
             IconButton(icon: const Icon(Icons.info_outline, color: Colors.white), onPressed: () {}),
          ]
        ],
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
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Hoje'),
          BottomNavigationBarItem(icon: Icon(Icons.star_border_outlined), label: 'Hábitos'),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: 'Tarefas'),
          BottomNavigationBarItem(icon: Icon(Icons.timer_outlined), label: 'Timer'),
          BottomNavigationBarItem(icon: Icon(Icons.apps), label: 'Categorias'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFE91E63),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 12, color: Color(0xFFE91E63)),
        unselectedLabelStyle: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      drawer: const AppDrawer(),
      floatingActionButton: showFab
          ? FloatingActionButton(
              onPressed: () => _showAddItemBottomSheet(context),
              backgroundColor: const Color(0xFFE91E63),
              heroTag: 'mainFab', // <--- Added unique heroTag here
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
