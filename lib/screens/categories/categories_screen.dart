import 'package:flutter/material.dart';
import 'package:myapp/models/category.dart';
import 'package:myapp/services/category_service.dart';
import 'package:myapp/services/habit_service.dart'; // Import HabitService
import 'package:myapp/screens/categories/add_edit_category_screen.dart'; // Renomeado para o nome planejado
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/utils/logger.dart';
import 'package:provider/provider.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late Future<List<Category>> _categoriesFuture;
  bool _isLoading = false;
  final int _maxCustomCategories = 10; // Definindo um limite para categorias personalizadas

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    // Use listen:false aqui porque estamos apenas disparando a carga de dados.
    // O FutureBuilder cuidará de ouvir as mudanças no future.
    final categoryService = Provider.of<CategoryService>(context, listen: false);
    if (mounted) {
      setState(() {
        _categoriesFuture = categoryService.getCategories();
      });
    }
  }

  Future<void> _navigateToAddEditCategory([Category? category]) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditCategoryScreen(categoryToEdit: category),
      ),
    );
    // Se a tela de edição/adição retornar true, significa que algo mudou.
    if (result == true && mounted) {
      _loadCategories();
    }
  }

  Future<void> _deleteCategory(Category category) async {
    if (category.isDefault) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Categorias padrão não podem ser excluídas.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          title: const Text('Excluir Categoria', style: TextStyle(color: Colors.white)),
          content: Text(
            'Tem certeza que deseja excluir a categoria "${category.name}"? Os hábitos associados a esta categoria serão movidos para "Outros". Esta ação não pode ser desfeita.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar', style: TextStyle(color: AppTheme.primaryColor.withOpacity(0.7))),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
              child: const Text('Excluir'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      try {
        final categoryService = Provider.of<CategoryService>(context, listen: false);
        // Passar o HabitService para o método deleteCategory
        final habitService = Provider.of<HabitService>(context, listen: false);
        await categoryService.deleteCategory(category.id, habitService: habitService);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Categoria "${category.name}" excluída com sucesso.')),
          );
          _loadCategories(); // Recarrega a lista
        }
      } catch (e) {
        Logger.error("Error deleting category: $e", e, StackTrace.current);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir categoria: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Gerenciar Categorias', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.backgroundColor, // Consistência com o tema
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadCategories();
        },
        color: AppTheme.primaryColor,
        backgroundColor: AppTheme.surfaceColor,
        child: FutureBuilder<List<Category>>(
          future: _categoriesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
            }
            if (snapshot.hasError) {
              Logger.error("Error in FutureBuilder for categories: ${snapshot.error}", snapshot.error, snapshot.stackTrace);
              return Center(child: Text('Erro ao carregar categorias: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Nenhuma categoria encontrada.', style: TextStyle(color: Colors.white70)));
            }

            final allCategories = snapshot.data!;
            final customCategories = allCategories.where((cat) => !cat.isDefault).toList();
            final defaultCategories = allCategories.where((cat) => cat.isDefault).toList();

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Text(
                  'Minhas Categorias',
                  style: AppTheme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${customCategories.length} de $_maxCustomCategories criadas',
                  style: AppTheme.textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                ),
                const SizedBox(height: 16),
                if (customCategories.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(
                      child: Text(
                        'Você ainda não criou nenhuma categoria personalizada.\nToque em "Nova Categoria" para começar!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ),
                  )
                else
                  _buildCategoryList(customCategories, context),

                const SizedBox(height: 32),

                Text(
                  'Categorias Padrão',
                  style: AppTheme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildCategoryList(defaultCategories, context),
                const SizedBox(height: 80), // Espaço para o FAB não cobrir o último item
              ],
            );
          },
        ),
      ),
      floatingActionButton: FutureBuilder<List<Category>>(
        future: _categoriesFuture, // Reutiliza o future para não piscar
        builder: (context, snapshot) {
          int customCount = 0;
          if(snapshot.hasData && snapshot.data != null) {
            customCount = snapshot.data!.where((c) => !c.isDefault).length;
          }
          bool canAddMore = customCount < _maxCustomCategories;

          return FloatingActionButton.extended(
            onPressed: canAddMore ? () => _navigateToAddEditCategory() : null,
            label: const Text('Nova Categoria'),
            icon: const Icon(Icons.add),
            backgroundColor: canAddMore ? AppTheme.primaryColor : Colors.grey,
            foregroundColor: Colors.white,
            tooltip: canAddMore ? 'Criar nova categoria' : 'Limite de categorias atingido',
          );
        }
      ),
    );
  }

  Widget _buildCategoryList(List<Category> categories, BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          color: AppTheme.surfaceColor,
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: category.color.withOpacity(0.2),
              child: Icon(category.icon, color: category.color, size: 24),
            ),
            title: Text(category.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
            subtitle: Text(
              category.isDefault ? 'Padrão' : 'Personalizada',
              style: TextStyle(color: Colors.grey[400], fontSize: 12)
            ),
            trailing: category.isDefault
                ? null // Não mostrar opções para categorias padrão
                : PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.grey[400]),
                    color: AppTheme.surfaceColor.withValues(blue: AppTheme.surfaceColor.blue + 10), // Slightly different for popup
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: const Row(children: [Icon(Icons.edit_outlined, color: Colors.blueAccent), SizedBox(width: 10), Text('Editar')]),
                        onTap: () => Future.delayed(Duration.zero, () => _navigateToAddEditCategory(category)),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(children: [Icon(Icons.delete_outline, color: AppTheme.errorColor), const SizedBox(width: 10), Text('Excluir', style: TextStyle(color: AppTheme.errorColor))]),
                        onTap: () => Future.delayed(Duration.zero, () => _deleteCategory(category)),
                      ),
                    ],
                  ),
            onTap: category.isDefault
              ? null // Não faz nada ao tocar em padrão
              : () => _navigateToAddEditCategory(category), // Editar ao tocar se não for padrão
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 8),
    );
  }
}

// Extension for Color to easily modify alpha or other channels
extension ColorValues on Color {
  Color withValues({int? alpha, int? red, int? green, int? blue}) {
    return Color.fromARGB(
      alpha ?? this.alpha,
      red ?? this.red,
      green ?? this.green,
      blue ?? this.blue,
    );
  }
}
