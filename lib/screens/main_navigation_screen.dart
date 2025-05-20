import 'package:flutter/material.dart';
import 'package:myapp/screens/home/home_screen.dart';
import 'package:myapp/screens/habits/habits_screen.dart';
import 'package:myapp/screens/coach_ai/coach_ai_screen.dart';
import 'package:myapp/widgets/app_drawer.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // Lista de telas para a BottomNavigationBar
  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const HabitsScreen(),
    const Placeholder(
      child: Center(child: Text('Tarefas')),
    ), // Placeholder for TasksScreen
    const CoachAiScreen(),
    const Placeholder(
      child: Center(child: Text('Mais')),
    ), // Placeholder for MoreScreen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? const Color(0xFFE91E63) : Colors.grey),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFE91E63) : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  } // Added missing closing brace

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HabitNow'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Hoje'),
          BottomNavigationBarItem(icon: Icon(Icons.repeat), label: 'Hábitos'),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Tarefas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology),
            label: 'Coach AI',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'Mais'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFE91E63),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
