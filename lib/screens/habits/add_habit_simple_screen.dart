import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/habit.dart';
import '../../services/habit_service.dart';
import '../../utils/app_colors.dart';

class AddHabitSimpleScreen extends StatefulWidget {
  const AddHabitSimpleScreen({super.key});

  @override
  State<AddHabitSimpleScreen> createState() => _AddHabitSimpleScreenState();
}

class _AddHabitSimpleScreenState extends State<AddHabitSimpleScreen> {
  final _nameController = TextEditingController();
  String _selectedCategory = 'Saúde';
  Color _selectedColor = Colors.red;
  IconData _selectedIcon = Icons.favorite;
  String _selectedFrequency = 'daily';
  final List<int> _selectedDaysOfWeek = [1, 2, 3, 4, 5]; // Segunda a Sexta
  bool _isSaving = false;

  // Categorias simplificadas
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Saúde', 'icon': Icons.favorite, 'color': Colors.red},
    {'name': 'Fitness', 'icon': Icons.fitness_center, 'color': Colors.orange},
    {'name': 'Trabalho', 'icon': Icons.work, 'color': Colors.blue},
    {'name': 'Estudos', 'icon': Icons.school, 'color': Colors.purple},
    {'name': 'Finanças', 'icon': Icons.attach_money, 'color': Colors.green},
    {'name': 'Social', 'icon': Icons.people, 'color': Colors.teal},
    {'name': 'Lazer', 'icon': Icons.sports_esports, 'color': Colors.pink},
    {'name': 'Outros', 'icon': Icons.more_horiz, 'color': Colors.grey},
  ];

  final List<String> _weekDays = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveHabit() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira um nome para o hábito'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final habitService = Provider.of<HabitService>(context, listen: false);
      
      await habitService.addHabit(
        title: _nameController.text.trim(),
        categoryName: _selectedCategory,
        categoryIcon: _selectedIcon,
        categoryColor: _selectedColor,
        frequency: _selectedFrequency == 'daily' ? HabitFrequency.daily : HabitFrequency.weekly,
        trackingType: HabitTrackingType.simOuNao, // Sempre sim/não por enquanto
        startDate: DateTime.now(),
        daysOfWeek: _selectedFrequency == 'weekly' ? _selectedDaysOfWeek : null,
        description: '', // Simplificado - sem descrição
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hábito criado com sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar hábito: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Novo Hábito'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nome do hábito
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Nome do Hábito',
                hintText: 'Ex: Beber água, Fazer exercícios...',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.edit, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 24),

            // Categoria
            Text(
              'Categoria',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category['name'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category['name'];
                        _selectedIcon = category['icon'];
                        _selectedColor = category['color'];
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? category['color'] 
                                : AppColors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected 
                                  ? category['color'] 
                                  : AppColors.textSecondary.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            category['icon'],
                            color: isSelected ? Colors.white : category['color'],
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category['name'],
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected 
                                ? _selectedColor 
                                : AppColors.textSecondary,
                            fontWeight: isSelected 
                                ? FontWeight.bold 
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Frequência
            Text(
              'Frequência',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Todos os dias'),
                    value: 'daily',
                    groupValue: _selectedFrequency,
                    onChanged: (value) {
                      setState(() {
                        _selectedFrequency = value!;
                      });
                    },
                    activeColor: _selectedColor,
                  ),
                  Divider(height: 1, color: AppColors.background),
                  RadioListTile<String>(
                    title: const Text('Dias específicos'),
                    value: 'weekly',
                    groupValue: _selectedFrequency,
                    onChanged: (value) {
                      setState(() {
                        _selectedFrequency = value!;
                      });
                    },
                    activeColor: _selectedColor,
                  ),
                ],
              ),
            ),

            // Dias da semana (se weekly)
            if (_selectedFrequency == 'weekly') ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(7, (index) {
                  final dayNumber = index == 6 ? 7 : index + 1; // Domingo = 7
                  final isSelected = _selectedDaysOfWeek.contains(dayNumber);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedDaysOfWeek.remove(dayNumber);
                        } else {
                          _selectedDaysOfWeek.add(dayNumber);
                        }
                        _selectedDaysOfWeek.sort();
                      });
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isSelected ? _selectedColor : AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected 
                              ? _selectedColor 
                              : AppColors.textSecondary.withOpacity(0.3),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _weekDays[index],
                          style: TextStyle(
                            color: isSelected 
                                ? Colors.white 
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isSaving || _nameController.text.trim().isEmpty 
                  ? null 
                  : _saveHabit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedColor,
                disabledBackgroundColor: AppColors.textSecondary.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Criar Hábito',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}