import 'package:flutter/material.dart';
import 'package:myapp/models/category.dart' as app_category;
import 'package:myapp/models/habit.dart';
import 'package:myapp/screens/categories/add_edit_category_screen.dart';
import 'package:myapp/services/category_service.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/utils/logger.dart';
import 'package:provider/provider.dart';
import 'habit_tracking_type_screen.dart';

class AddHabitScreen extends StatefulWidget {
  // habitToEdit é mantido para o caso de reentrada no fluxo de criação,
  // mas a lógica principal de edição de categoria de um hábito existente
  // será feita na HabitDetailsScreen -> HabitEditTab.
  final Habit? habitToEdit;
  final String? preselectedCategoryId; // Para pré-selecionar após criar uma nova categoria

  const AddHabitScreen({super.key, this.habitToEdit, this.preselectedCategoryId});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  app_category.Category? _selectedCategory;
  late Future<List<app_category.Category>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _loadCategoriesAndPreselect();
  }

  void _loadCategoriesAndPreselect() {
    final categoryService = Provider.of<CategoryService>(context, listen: false);
    if (mounted) {
      setState(() {
        _categoriesFuture = categoryService.getCategories().then((categories) {
          if (widget.preselectedCategoryId != null) {
            _selectedCategory = categories.firstWhere(
              (cat) => cat.id == widget.preselectedCategoryId,
              orElse: () => categories.isNotEmpty ? categories.first : null, // Fallback
            );
          } else if (widget.habitToEdit?.category != null) {
            // Tenta pré-selecionar baseado no nome da categoria do hábito a ser editado
            _selectedCategory = categories.firstWhere(
              (cat) => cat.name == widget.habitToEdit!.category,
              orElse: () => categories.firstWhere(
                (c) => c.name.toLowerCase() == 'outros', // Fallback para "Outros"
                orElse: () => categories.isNotEmpty ? categories.first : null,
              ),
            );
          }
          return categories;
        });
      });
    }
  }

  Future<void> _navigateToCreateCategory() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddEditCategoryScreen()),
    );
    if (result == true && mounted) {
      _loadCategoriesAndPreselect(); // Recarrega as categorias
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.habitToEdit == null
              ? 'Selecione uma Categoria'
              : 'Alterar Categoria do Hábito',
          style: AppTheme.textTheme.titleLarge,
        ),
        backgroundColor: AppTheme.appBarColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            tooltip: 'Criar Nova Categoria',
            onPressed: _navigateToCreateCategory,
          ),
        ],
      ),
      body: FutureBuilder<List<app_category.Category>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
          }
          if (snapshot.hasError) {
            Logger.error("Error loading categories in AddHabitScreen: ${snapshot.error}", snapshot.error, snapshot.stackTrace);
            return Center(
              child: Text(
                'Erro ao carregar categorias: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Nenhuma categoria encontrada.', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Criar Primeira Categoria'),
                    style: AppTheme.primaryButton,
                    onPressed: _navigateToCreateCategory,
                  )
                ],
              ),
            );
          }

          final categories = snapshot.data!;
          // A categoria "Criar categoria" é tratada pelo botão no AppBar agora.

          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Mantendo 2 colunas para melhor visualização com nomes maiores
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
              childAspectRatio: 2.8, // Ajustar para melhor fit do conteúdo
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final bool isSelected = _selectedCategory?.id == category.id;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? category.color.withOpacity(0.8) : AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: isSelected ? category.color : (Colors.grey[700]!),
                      width: 1.5,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: category.color.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0,2)
                      )
                    ] : [],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(category.icon,
                          color: isSelected ? Colors.white : category.color, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          category.name,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'CANCELAR',
                  style: TextStyle(color: Colors.grey[400], fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              ElevatedButton(
                onPressed: _selectedCategory != null
                    ? () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => HabitTrackingTypeScreen(
                            categoryName: _selectedCategory!.name,
                            categoryIcon: _selectedCategory!.icon,
                            categoryColor: _selectedCategory!.color,
                            // Se o fluxo de edição de hábito começar aqui,
                            // precisaremos passar o habitToEdit para as próximas telas.
                            // Por enquanto, o foco é na criação.
                          ),
                           settings: RouteSettings(
                             arguments: widget.habitToEdit != null ? {'habitToEdit': widget.habitToEdit} : null,
                           ),
                        ));
                      }
                    : null,
                style: AppTheme.primaryButton.copyWith(
                  padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 30, vertical: 12)),
                ),
                child: Text(
                   'PRÓXIMA', // Simplificado, pois a edição de categoria de um hábito existente é melhor na HabitEditTab
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Extension Color.withValues é útil, mas já está em habit_card.dart.
// Se não estiver globalmente acessível, pode ser necessário duplicar ou mover para um utils.
// extension ColorValues on Color {
//   Color withValues({int? alpha, int? red, int? green, int? blue}) {
//     return Color.fromARGB(
//       alpha ?? this.alpha,
//       red ?? this.red,
//       green ?? this.green,
//       blue ?? this.blue,
//     );
//   }
// }
