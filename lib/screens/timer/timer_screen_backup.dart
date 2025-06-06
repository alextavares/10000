import 'package:flutter/material.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with TickerProviderStateMixin {
  int _selectedTabIndex = 0; // 0: Cronômetro, 1: Timer, 2: Intervalos
  final String _displayedTime = "00:00"; // This should be updated by timer logic

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    // Define colors based on theme, assuming MainNavigationScreen sets the overall Scaffold background
    final Color primaryTextColor = isDarkMode ? Colors.white : Colors.black;
    final Color secondaryTextColor = isDarkMode ? Colors.grey[400]! : Colors.grey[700]!;
    final Color accentColor = const Color(0xFFE91E63);
    final Color inactiveTabColor = isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
    final Color circularProgressBackgroundColor = accentColor.withValues(alpha: 0.3);
    // The main background color is now handled by MainNavigationScreen's Scaffold
    // If this screen needs a different background, wrap its content in a Container with that color.

    // Removed Scaffold and AppBar.
    // The AppBar is now handled by MainNavigationScreen.

    return Container(
      color: isDarkMode ? Colors.black : Colors.grey[100]!, // Set background for this screen content
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 220,
                  height: 220,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: 1, // Static, should be dynamic based on timer progress
                        strokeWidth: 12,
                        backgroundColor: circularProgressBackgroundColor,
                        valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                      ),
                      Center(
                        child: Text(
                          _displayedTime,
                          style: TextStyle(
                            color: primaryTextColor,
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  label: const Text(
                    'INICIAR',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () { /* TODO: Implement start timer logic */ },
                ),
              ],
            ),
          ),
          _buildCustomTabBar(accentColor, primaryTextColor, inactiveTabColor, secondaryTextColor),
          const SizedBox(height: 20),
          Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[850] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12)
              ),
              child: Column(
                  children: [
                      Text('Sem registros recentes', style: TextStyle(color: secondaryTextColor, fontSize: 15)),
                      const Divider(color: Colors.grey, height: 20),
                      Text('Nenhuma atividade selecionada', style: TextStyle(color: secondaryTextColor, fontSize: 15)),
                  ]
              )
          )
        ],
      ),
    );
  }

  Widget _buildCustomTabBar(Color accentColor, Color primaryTextColor, Color inactiveTabColor, Color secondaryTextColor) {
    final List<Map<String, dynamic>> tabs = [
      {'icon': Icons.timer_outlined, 'label': 'Cronômetro'},
      {'icon': Icons.hourglass_empty, 'label': 'Timer'},
      {'icon': Icons.sync_outlined, 'label': 'Intervalos'},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: inactiveTabColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(tabs.length, (index) {
          final bool isSelected = _selectedTabIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? accentColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tabs[index]['icon'] as IconData,
                      color: isSelected ? Colors.white : secondaryTextColor,
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tabs[index]['label'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.white : secondaryTextColor,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
