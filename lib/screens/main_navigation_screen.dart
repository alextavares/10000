import 'package:flutter/material.dart';
import 'package:myapp/screens/home/home_screen.dart';
import 'package:myapp/screens/habits/habits_screen.dart';
import 'package:myapp/screens/tasks/tasks_screen.dart';
import 'package:myapp/screens/task/add_task_screen.dart'; // Import the new AddTaskScreen
import 'package:myapp/screens/timer/timer_screen.dart';
import 'package:myapp/screens/categories/categories_screen.dart';
import 'package:myapp/widgets/app_drawer.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

// Add SingleTickerProviderStateMixin for TabController
class _MainNavigationScreenState extends State<MainNavigationScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController _tabController; // Declare TabController
  final GlobalKey<TasksScreenState> _tasksScreenKey = GlobalKey<TasksScreenState>();
  final GlobalKey<HomeScreenState> _homeScreenKey = GlobalKey<HomeScreenState>(); // Add GlobalKey for HomeScreen

  static const List<String> _widgetTitles = <String>[
    'Hoje',
    'Hábitos',
    'Tarefas',
    'Timer',
    'Categorias',
  ];

  // The TasksScreen widget now requires a TabController
  // We will initialize it in initState and pass it down.
  // For other screens, they don't need a TabController.
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    // Initialize TabController for TasksScreen
    _tabController = TabController(length: 2, vsync: this); // Assuming 2 tabs for TasksScreen

    _widgetOptions = <Widget>[
      HomeScreen(key: _homeScreenKey), // Pass key to HomeScreen
      const HabitsScreen(),
      TasksScreen(key: _tasksScreenKey, tabController: _tabController), // Pass TabController to TasksScreen
      const TimerScreen(),
      const CategoriesScreen(),
    ];

    _tabController.addListener(() {
      // If the TabController index changes, and we are on the Tasks screen,
      // we might want to update the state if needed, but usually AppBar updates automatically.
      if (_selectedIndex == 2 && _tabController.indexIsChanging) {
        // setState(() {}); // Usually not needed just for TabBar in AppBar
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose(); // Dispose TabController
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isTasksScreenSelected = _widgetTitles[_selectedIndex] == 'Tarefas';

    return Scaffold(
      appBar: AppBar(
        title: Text(_widgetTitles[_selectedIndex], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          // Common actions based on selected screen
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
          // Specific actions for Timer Screen from image
          if (_widgetTitles[_selectedIndex] == 'Timer') ...[
            IconButton(icon: Icon(Icons.info_outline, color: Colors.white), onPressed: () {}),
            IconButton(icon: Icon(Icons.wifi_tethering_outlined, color: Colors.white), onPressed: () {}),
            IconButton(icon: Icon(Icons.volume_up_outlined, color: Colors.white), onPressed: () {}),
          ],
          // Specific actions for Categories Screen from image
          if (_widgetTitles[_selectedIndex] == 'Categorias') ...[
             IconButton(icon: Icon(Icons.check_circle_outline, color: Colors.white), onPressed: () {}),
             IconButton(icon: Icon(Icons.info_outline, color: Colors.white), onPressed: () {}),
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
            : null, // No TabBar for other screens
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
      floatingActionButton: (_widgetTitles[_selectedIndex] == 'Hoje' || _widgetTitles[_selectedIndex] == 'Tarefas')
          ? FloatingActionButton(
              onPressed: () async {
                if (_widgetTitles[_selectedIndex] == 'Tarefas') {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AddTaskScreen()),
                  );
                  if (result == true) {
                    // If a task was added, refresh the TasksScreen
                    _tasksScreenKey.currentState?.refreshTasks();
                  }
                } else if (_widgetTitles[_selectedIndex] == 'Hoje') {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const AddTaskScreen()),
                  );
                  if (result == true) {
                    // If a task was added, refresh the HomeScreen
                    _homeScreenKey.currentState?.refreshTasks();
                  }
                }
              },
              backgroundColor: const Color(0xFFE91E63),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null, // No FAB for other screens unless specified
    );
  }
}
