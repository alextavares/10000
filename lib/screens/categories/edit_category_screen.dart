import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'select_tasks_screen.dart';
import '../../models/category.dart';
import '../../services/category_service.dart';

class EditCategoryScreen extends StatefulWidget {
  final Category? category;

  const EditCategoryScreen({
    super.key,
    this.category,
  });

  @override
  State<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  late TextEditingController _nameController;
  late IconData _selectedIcon;
  late Color _selectedColor;
  late List<String> _taskIds;
  final CategoryService _categoryService = CategoryService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.category?.name ?? '',
    );
    _selectedIcon = widget.category?.icon ?? Icons.dashboard_rounded;
    _selectedColor = widget.category?.color ?? const Color(0xFFE91E63);
    _taskIds = List.from(widget.category?.taskIds ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFF121212);
    const Color cardColor = Color(0xFF1E1E1E);
    const Color primaryTextColor = Colors.white;
    final Color secondaryTextColor = Colors.grey[500]!;
    const Color accentColor = Color(0xFFE91E63);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.category == null ? 'Nova Categoria' : 'Editar Categoria',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome da categoria
                  _buildSectionCard(
                    title: 'Nome',
                    child: TextField(
                      controller: _nameController,
                      style: const TextStyle(color: primaryTextColor, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Digite o nome da categoria',
                        hintStyle: TextStyle(color: secondaryTextColor),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    cardColor: cardColor,
                    primaryTextColor: primaryTextColor,
                  ),
                  const SizedBox(height: 16),

                  // Ícone da categoria
                  _buildSectionCard(
                    title: 'Ícone',
                    child: InkWell(
                      onTap: _showIconPicker,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: _selectedColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _selectedIcon,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'Escolher ícone',
                                style: TextStyle(
                                  color: primaryTextColor,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: secondaryTextColor,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                    cardColor: cardColor,
                    primaryTextColor: primaryTextColor,
                  ),
                  const SizedBox(height: 16),

                  // Cor da categoria
                  _buildSectionCard(
                    title: 'Cor',
                    child: InkWell(
                      onTap: _showColorPicker,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: _selectedColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'Escolher cor',
                                style: TextStyle(
                                  color: primaryTextColor,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: secondaryTextColor,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                    cardColor: cardColor,
                    primaryTextColor: primaryTextColor,
                  ),
                  const SizedBox(height: 16),

                  // Tarefas associadas
                  _buildSectionCard(
                    title: 'Tarefas',
                    subtitle: '${_taskIds.length} tarefa${_taskIds.length == 1 ? '' : 's'} associada${_taskIds.length == 1 ? '' : 's'}',
                    child: InkWell(
                      onTap: () async {
                        final selectedIds = await Navigator.push<List<String>>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SelectTasksScreen(
                              selectedTaskIds: _taskIds,
                              currentCategoryId: widget.category?.id,
                            ),
                          ),
                        );
                        
                        if (selectedIds != null) {
                          setState(() {
                            _taskIds = selectedIds;
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Gerenciar tarefas',
                              style: TextStyle(
                                color: primaryTextColor,
                                fontSize: 16,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: secondaryTextColor,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    cardColor: cardColor,
                    primaryTextColor: primaryTextColor,
                  ),

                  // Opção de excluir (apenas para categorias não padrão)
                  if (widget.category != null && !widget.category!.isDefault) ...[
                    const SizedBox(height: 32),
                    InkWell(
                      onTap: _deleteCategory,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color: Colors.red[400],
                              size: 24,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Excluir categoria',
                              style: TextStyle(
                                color: Colors.red[400],
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Botão Salvar
          Container(
            color: backgroundColor,
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.4),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                onPressed: _isLoading ? null : _saveCategory,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'SALVAR',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    String? subtitle,
    required Widget child,
    required Color cardColor,
    required Color primaryTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: primaryTextColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(width: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  void _showIconPicker() {
    final List<IconData> icons = [
      Icons.dashboard_rounded,
      Icons.home_rounded,
      Icons.work_rounded,
      Icons.school_rounded,
      Icons.fitness_center_rounded,
      Icons.restaurant_rounded,
      Icons.shopping_cart_rounded,
      Icons.favorite_rounded,
      Icons.star_rounded,
      Icons.access_time_rounded,
      Icons.calendar_today_rounded,
      Icons.book_rounded,
      Icons.music_note_rounded,
      Icons.movie_rounded,
      Icons.games_rounded,
      Icons.sports_rounded,
      Icons.directions_car_rounded,
      Icons.flight_rounded,
      Icons.hotel_rounded,
      Icons.beach_access_rounded,
      Icons.terrain_rounded,
      Icons.pets_rounded,
      Icons.child_care_rounded,
      Icons.elderly_rounded,
      Icons.groups_rounded,
      Icons.person_rounded,
      Icons.attach_money_rounded,
      Icons.savings_rounded,
      Icons.credit_card_rounded,
      Icons.account_balance_rounded,
      Icons.brush_rounded,
      Icons.palette_rounded,
      Icons.camera_alt_rounded,
      Icons.mic_rounded,
      Icons.headphones_rounded,
      Icons.computer_rounded,
      Icons.phone_android_rounded,
      Icons.watch_rounded,
      Icons.tv_rounded,
      Icons.kitchen_rounded,
      Icons.bathtub_rounded,
      Icons.bed_rounded,
      Icons.chair_rounded,
      Icons.weekend_rounded,
      Icons.cleaning_services_rounded,
      Icons.build_rounded,
      Icons.handyman_rounded,
      Icons.yard_rounded,
      Icons.local_florist_rounded,
      Icons.spa_rounded,
      Icons.self_improvement_rounded,
      Icons.psychology_rounded,
      Icons.medication_rounded,
      Icons.medical_services_rounded,
      Icons.health_and_safety_rounded,
      Icons.vaccines_rounded,
      Icons.monitor_heart_rounded,
      Icons.directions_bike_rounded,
      Icons.directions_run_rounded,
      Icons.directions_walk_rounded,
      Icons.pool_rounded,
      Icons.sports_basketball_rounded,
      Icons.sports_soccer_rounded,
      Icons.sports_tennis_rounded,
      Icons.sports_golf_rounded,
      Icons.hiking_rounded,
      Icons.surfing_rounded,
      Icons.skateboarding_rounded,
      Icons.snowboarding_rounded,
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Escolher ícone',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: icons.length,
                  itemBuilder: (context, index) {
                    final icon = icons[index];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedIcon = icon;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedIcon == icon
                              ? _selectedColor
                              : const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showColorPicker() {
    Color pickerColor = _selectedColor;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'Escolher cor',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (color) {
                pickerColor = color;
              },
              labelTypes: const [],
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'CANCELAR',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedColor = pickerColor;
                });
                Navigator.pop(context);
              },
              child: const Text(
                'CONFIRMAR',
                style: TextStyle(color: Color(0xFFE91E63)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteCategory() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'Excluir categoria',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Tem certeza que deseja excluir esta categoria? As tarefas associadas não serão excluídas.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'CANCELAR',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                setState(() {
                  _isLoading = true;
                });
                
                try {
                  await _categoryService.deleteCategory(widget.category!.id);
                  if (mounted) {
                    Navigator.pop(context, {'action': 'delete'});
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro ao excluir categoria: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    setState(() {
                      _isLoading = false;
                    });
                  }
                }
              },
              child: Text(
                'EXCLUIR',
                style: TextStyle(color: Colors.red[400]),
              ),
            ),
          ],
        );
      },
    );
  }

  void _saveCategory() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, insira um nome para a categoria'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.category == null) {
        // Create new category
        final newCategory = await _categoryService.createCategory(
          name: _nameController.text.trim(),
          iconCodePoint: _selectedIcon.codePoint,
          color: _selectedColor.value,
        );
        
        // Add tasks to the new category
        for (final taskId in _taskIds) {
          await _categoryService.addTaskToCategory(newCategory.id, taskId);
        }
        
        if (mounted) {
          Navigator.pop(context, {'action': 'save', 'category': newCategory});
        }
      } else {
        // Update existing category
        final updatedCategory = widget.category!.copyWith(
          name: _nameController.text.trim(),
          icon: _selectedIcon,
          color: _selectedColor,
          taskIds: _taskIds,
          updatedAt: DateTime.now(),
        );
        
        await _categoryService.updateCategory(updatedCategory);
        
        if (mounted) {
          Navigator.pop(context, {'action': 'save', 'category': updatedCategory});
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar categoria: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
