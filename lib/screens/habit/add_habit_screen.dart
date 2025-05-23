import 'package:flutter/material.dart';
// Will be replaced by HabitTrackingTypeScreen soon
import 'habit_tracking_type_screen.dart'; // Import the target screen
// For HabitTrackingType if needed here, though likely passed on

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  Map<String, dynamic>? _selectedCategoryData;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Abandone um...', 'icon': Icons.do_not_disturb_on_outlined, 'color': Colors.red[400]!},
    {'name': 'Arte', 'icon': Icons.palette_outlined, 'color': Colors.pink[300]!},
    {'name': 'Meditação', 'icon': Icons.self_improvement_outlined, 'color': Colors.purple[300]!},
    {'name': 'Estudos', 'icon': Icons.school_outlined, 'color': Colors.deepPurple[300]!},
    {'name': 'Esportes', 'icon': Icons.directions_bike_outlined, 'color': Colors.blue[300]!},
    {'name': 'Entretenimen...', 'icon': Icons.star_border_outlined, 'color': Colors.lightBlue[300]!},
    {'name': 'Social', 'icon': Icons.people_outline, 'color': Colors.cyan[300]!},
    {'name': 'Finança', 'icon': Icons.attach_money_outlined, 'color': Colors.teal[300]!},
    {'name': 'Saúde', 'icon': Icons.favorite_border_outlined, 'color': Colors.green[300]!},
    {'name': 'Trabalho', 'icon': Icons.work_outline_outlined, 'color': Colors.lightGreen[300]!},
    {'name': 'Personalizado', 'icon': Icons.extension_outlined, 'color': Colors.lime[300]!},
    {'name': 'Nutrição', 'icon': Icons.restaurant_menu_outlined, 'color': Colors.amber[300]!},
    {'name': 'Casa', 'icon': Icons.home_outlined, 'color': Colors.orange[300]!},
    {'name': 'Ar livre', 'icon': Icons.landscape_outlined, 'color': Colors.deepOrange[300]!},
    {'name': 'Outros', 'icon': Icons.apps_outlined, 'color': Colors.brown[300]!},
    {'name': 'Criar categoria', 'icon': Icons.add_circle_outline, 'color': Colors.grey[600]!, 'isSpecial': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Selecione uma categoria para o seu hábito',
          style: TextStyle(color: Colors.pinkAccent, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.0,
            mainAxisSpacing: 12.0,
            childAspectRatio: 2.5, // Adjusted for better text visibility if needed
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            final bool isSelected = _selectedCategoryData == category;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategoryData = category;
                });
                if (category['isSpecial'] == true) {
                  // Revert selection if 'Criar categoria' is tapped, as it's not a selectable category for habit creation flow yet
                  setState(() {
                    _selectedCategoryData = null; 
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Funcionalidade "Criar categoria" pendente.')),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? (category['color'] as Color).withOpacity(0.8) : Colors.grey[850],
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: isSelected ? (category['color'] as Color) : (Colors.grey[700]!),
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(category['icon'] as IconData? ?? Icons.help_outline, 
                         color: isSelected ? Colors.white : (category['color'] as Color?) ?? Colors.white70, 
                         size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        category['name'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'CANCELAR',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: (_selectedCategoryData != null && _selectedCategoryData!['isSpecial'] != true) ? () {
                if (_selectedCategoryData != null) {
                  // Navigate to HabitTrackingTypeScreen instead of AddHabitTitleScreen
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => HabitTrackingTypeScreen(
                      // Pass necessary data to HabitTrackingTypeScreen
                      // Note: HabitTrackingTypeScreen's constructor needs to be updated to accept these
                      categoryName: _selectedCategoryData!['name'] as String,
                      categoryIcon: _selectedCategoryData!['icon'] as IconData,
                      categoryColor: _selectedCategoryData!['color'] as Color,
                      // We are initiating the flow, so some data might not be available yet
                      // Example: habitTitle, description, frequency are not yet defined here
                      // HabitTrackingTypeScreen might need a simplified constructor for this part of the flow
                      // For now, let's assume it can handle these params or we will adjust it next.
                    ),
                  ));
                }
              } : null, 
              style: ElevatedButton.styleFrom(
                backgroundColor: (_selectedCategoryData != null && _selectedCategoryData!['isSpecial'] != true) 
                                 ? Colors.pinkAccent 
                                 : Colors.grey, // Disabled if no valid category selected
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('PRÓXIMA', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
