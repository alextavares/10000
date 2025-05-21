import 'package:flutter/material.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final Color primaryTextColor = isDarkMode ? Colors.white : Colors.black;
    final Color secondaryTextColor = isDarkMode ? Colors.grey[400]! : Colors.grey[700]!;
    // Background color is now handled by MainNavigationScreen's Scaffold
    // If this screen needs a different background, wrap its content in a Container.
    final Color cardBackgroundColor = isDarkMode ? Colors.grey[900]! : Colors.grey[100]!;
    final Color accentColor = const Color(0xFFE91E63);

    // Removed Scaffold and AppBar.
    // AppBar is handled by MainNavigationScreen.

    return Container(
      color: isDarkMode ? Colors.black : Colors.white, // Set background for this screen content
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Categorias customizadas',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryTextColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '5 disponíveis', // Dynamic, consider state management if it changes
                    style: TextStyle(fontSize: 14, color: secondaryTextColor),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.apps_outage_outlined, size: 48, color: secondaryTextColor),
                        const SizedBox(height: 8),
                        Text(
                          'Sem categorias personalizadas',
                          style: TextStyle(fontSize: 16, color: secondaryTextColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Categorias padrão',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryTextColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Editável para usuários premium',
                    style: TextStyle(fontSize: 14, color: secondaryTextColor),
                  ),
                  const SizedBox(height: 16),
                  _buildDefaultCategoriesList(cardBackgroundColor, primaryTextColor, secondaryTextColor),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          // This was a BottomNavigationBar in the original, but it's a single button.
          // Placing it at the bottom, similar to a FAB but full width.
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 50), // Make button full width
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // TODO: Implement NOVA CATEGORIA functionality
              },
              child: const Text(
                'NOVA CATEGORIA',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultCategoriesList(Color cardBackgroundColor, Color primaryTextColor, Color secondaryTextColor) {
    final categories = [
      {'icon': Icons.do_not_disturb_alt, 'name': 'Abando...', 'entries': 0, 'color': Colors.red.shade400},
      {'icon': Icons.brush, 'name': 'Arte', 'entries': 0, 'color': Colors.pink.shade300},
      {'icon': Icons.timer_outlined, 'name': 'Tarefa', 'entries': 0, 'color': Colors.purple.shade300},
      {'icon': Icons.self_improvement, 'name': 'Medita...', 'entries': 0, 'color': Colors.deepPurple.shade300},
      {'icon': Icons.school_outlined, 'name': 'Estud...', 'entries': 0, 'color': Colors.indigo.shade300},
    ];

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: category['color'] as Color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(category['icon'] as IconData, color: Colors.white, size: 28),
                const Spacer(),
                Text(
                  category['name'] as String,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${category['entries']} entrad...',
                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
