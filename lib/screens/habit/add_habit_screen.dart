import 'package:flutter/material.dart';
import 'package:myapp/models/habit.dart'; // Import Habit model
// Will be replaced by HabitTrackingTypeScreen soon
import 'habit_tracking_type_screen.dart'; // Import the target screen
// For HabitTrackingType if needed here, though likely passed on

class AddHabitScreen extends StatefulWidget {
  final Habit? habitToEdit; // Add this parameter

  const AddHabitScreen({super.key, this.habitToEdit}); // Modify constructor

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  Map<String, dynamic>? _selectedCategoryData;

  // TODO: Consider moving categories to a central place or making them more dynamic if needed.
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
  void initState() {
    super.initState();
    if (widget.habitToEdit != null) {
      // Attempt to pre-select the category based on the habit being edited.
      // This assumes that habitToEdit.category corresponds to one of the 'name' fields in _categories.
      // You might need a more robust way to map habitToEdit.category to _selectedCategoryData,
      // especially if category information is stored differently or needs to be fetched.
      final existingCategory = _categories.firstWhere(
        (cat) => cat['name'] == widget.habitToEdit!.category, // Assuming Habit has category
        orElse: () => _categories.firstWhere((cat) => cat['name'] == 'Outros'), // Fallback to 'Outros' or null
      );
      // Ensure the found category is not the special 'Criar categoria' one.
      if (existingCategory['isSpecial'] != true) {
         _selectedCategoryData = existingCategory;
      }

      // If you have other fields in AddHabitScreen that need to be pre-filled from habitToEdit,
      // initialize them here. For example, if this screen also handled title, description, etc.
      // _titleController.text = widget.habitToEdit!.title;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.habitToEdit == null 
              ? 'Selecione uma categoria para o seu hábito' 
              : 'Editar categoria do hábito', // Change title if editing
          style: const TextStyle(color: Colors.pinkAccent, fontSize: 18, fontWeight: FontWeight.bold),
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
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 3.2, 
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            final bool isSelected = _selectedCategoryData?['name'] == category['name']; // Compare by name for safety
            return GestureDetector(
              onTap: () {
                setState(() {
                  // Prevent selecting 'Criar categoria' as a valid selection for next step
                  if (category['isSpecial'] == true) {
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('Funcionalidade "Criar categoria" pendente.')),
                     );
                    _selectedCategoryData = null; // Or keep previous valid selection
                  } else {
                    _selectedCategoryData = category;
                  }
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? (category['color'] as Color).withValues(alpha: 0.8) : Colors.grey[850],
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: isSelected ? (category['color'] as Color) : (Colors.grey[700]!),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(category['icon'] as IconData? ?? Icons.help_outline, 
                         color: isSelected ? Colors.white : (category['color'] as Color?) ?? Colors.white70, 
                         size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        category['name'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
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
      bottomNavigationBar: SafeArea(
        child: Padding(
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
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => HabitTrackingTypeScreen(
                        categoryName: _selectedCategoryData!['name'] as String,
                        categoryIcon: _selectedCategoryData!['icon'] as IconData,
                        categoryColor: _selectedCategoryData!['color'] as Color,
                        // habitToEdit: widget.habitToEdit, // Removed as it's not a parameter of HabitTrackingTypeScreen
                      ),
                    ));
                  }
                } : null, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: (_selectedCategoryData != null && _selectedCategoryData!['isSpecial'] != true) 
                                   ? Colors.pinkAccent 
                                   : Colors.grey, 
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(widget.habitToEdit == null ? 'PRÓXIMA' : 'SALVAR', style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
