import 'package:flutter/material.dart';
import 'package:myapp/screens/habit/add_habit_frequency_screen.dart'; 

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  // Store the whole selected category map
  Map<String, dynamic>? _selectedCategoryData;

  // Placeholder for categories - these would ideally come from a service or config
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
            childAspectRatio: 2.5,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            // Check if the current category map is the selected one
            final bool isSelected = _selectedCategoryData == category;
            return GestureDetector(
              onTap: () {
                setState(() {
                  // Store the entire map of the selected category
                  _selectedCategoryData = category;
                });
                if (category['isSpecial'] == true) {
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
              onPressed: _selectedCategoryData != null ? () {
                if (_selectedCategoryData != null) {
                  // Pass name, icon, and color to the next screen
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AddHabitFrequencyScreen(
                      selectedCategoryName: _selectedCategoryData!['name'] as String,
                      selectedCategoryIcon: _selectedCategoryData!['icon'] as IconData,
                      selectedCategoryColor: _selectedCategoryData!['color'] as Color,
                    ),
                  ));
                }
              } : null, 
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
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
