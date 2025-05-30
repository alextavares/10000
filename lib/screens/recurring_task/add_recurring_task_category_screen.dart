import 'package:flutter/material.dart';
import 'package:myapp/models/recurring_task.dart';
import 'package:myapp/screens/recurring_task/add_recurring_task_title_screen.dart';

class AddRecurringTaskCategoryScreen extends StatefulWidget {
  final RecurringTaskTrackingType trackingType;
  final RecurringTask? recurringTaskToEdit;

  const AddRecurringTaskCategoryScreen({
    super.key,
    required this.trackingType,
    this.recurringTaskToEdit,
  });

  @override
  State<AddRecurringTaskCategoryScreen> createState() => _AddRecurringTaskCategoryScreenState();
}

class _AddRecurringTaskCategoryScreenState extends State<AddRecurringTaskCategoryScreen> {
  String? selectedCategory;

  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Abandone um...',
      'icon': Icons.block,
      'color': const Color(0xFFE53E3E),
    },
    {
      'name': 'Arte',
      'icon': Icons.brush,
      'color': const Color(0xFFE91E63),
    },
    {
      'name': 'Tarefa',
      'icon': Icons.access_time,
      'color': const Color(0xFFE91E63),
    },
    {
      'name': 'Nova categoria',
      'icon': Icons.apps,
      'color': const Color(0xFFE91E63),
    },
    {
      'name': 'Meditação',
      'icon': Icons.self_improvement,
      'color': const Color(0xFF9C27B0),
    },
    {
      'name': 'Estudos',
      'icon': Icons.school,
      'color': const Color(0xFF673AB7),
    },
    {
      'name': 'Esportes',
      'icon': Icons.directions_bike,
      'color': const Color(0xFF2196F3),
    },
    {
      'name': 'Entretenimento',
      'icon': Icons.star,
      'color': const Color(0xFF00BCD4),
    },
    {
      'name': 'Social',
      'icon': Icons.chat,
      'color': const Color(0xFF4CAF50),
    },
    {
      'name': 'Finança',
      'icon': Icons.attach_money,
      'color': const Color(0xFF8BC34A),
    },
    {
      'name': 'Saúde',
      'icon': Icons.local_hospital,
      'color': const Color(0xFF8BC34A),
    },
    {
      'name': 'Trabalho',
      'icon': Icons.work,
      'color': const Color(0xFFCDDC39),
    },
    {
      'name': 'Personalizado',
      'icon': Icons.tune,
      'color': const Color(0xFF8BC34A),
    },
    {
      'name': 'Nutrição',
      'icon': Icons.restaurant,
      'color': const Color(0xFFFF9800),
    },
    {
      'name': 'Casa',
      'icon': Icons.home,
      'color': const Color(0xFFFF5722),
    },
    {
      'name': 'Ar livre',
      'icon': Icons.terrain,
      'color': const Color(0xFFFF5722),
    },
    {
      'name': 'Outros',
      'icon': Icons.apps,
      'color': const Color(0xFFE53E3E),
    },
  ];

  void _selectCategory(String categoryName) {
    if (categoryName == 'Nova categoria') {
      _showCreateCategoryDialog();
    } else {
      setState(() {
        selectedCategory = categoryName;
      });
      _navigateToNextStep();
    }
  }

  void _showCreateCategoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Criar categoria',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            '3 disponíveis',
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to create category screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
              ),
              child: const Text(
                'Criar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToNextStep() {
    if (selectedCategory != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddRecurringTaskTitleScreen(
            trackingType: widget.trackingType,
            category: selectedCategory!,
            recurringTaskToEdit: widget.recurringTaskToEdit,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Selecione uma categoria',
          style: TextStyle(
            color: Color(0xFFE91E63),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return _buildCategoryItem(
                    name: category['name'],
                    icon: category['icon'],
                    color: category['color'],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'CANCELAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE91E63),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem({
    required String name,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = selectedCategory == name;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: isSelected 
          ? Border.all(color: const Color(0xFFE91E63), width: 2)
          : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectCategory(name),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}