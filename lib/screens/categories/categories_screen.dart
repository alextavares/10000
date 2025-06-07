import 'package:flutter/material.dart';
import 'edit_category_screen.dart';
import '../../models/category.dart';
import '../../services/category_service.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final CategoryService _categoryService = CategoryService();

  void _navigateToEditCategory(Category category) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCategoryScreen(
          category: category,
        ),
      ),
    );

    if (result != null) {
      // Force rebuild to refresh categories
      setState(() {});
    }
  }

  void _createNewCategory() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditCategoryScreen(),
      ),
    );

    if (result != null) {
      // Force rebuild to refresh categories
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFF121212);
    const Color primaryTextColor = Colors.white;
    final Color secondaryTextColor = Colors.grey[500]!;
    const Color accentColor = Color(0xFFE91E63);

    return Container(
      color: backgroundColor,
      child: StreamBuilder<List<Category>>(
        stream: _categoryService.getCustomCategories(),
        builder: (context, customSnapshot) {
          if (customSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: accentColor),
            );
          }

          final customCategories = customSnapshot.data ?? [];
          final defaultCategories = Category.defaultCategories;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Categorias customizadas
                      Text(
                        'Categorias customizadas',
                        style: TextStyle(
                          fontSize: 24, 
                          fontWeight: FontWeight.bold, 
                          color: primaryTextColor
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${customCategories.length} criada${customCategories.length == 1 ? '' : 's'}, 3 disponíveis',
                        style: TextStyle(
                          fontSize: 16, 
                          color: secondaryTextColor
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildCustomCategories(
                        customCategories, 
                        primaryTextColor, 
                        secondaryTextColor
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Categorias padrão
                      Text(
                        'Categorias padrão',
                        style: TextStyle(
                          fontSize: 24, 
                          fontWeight: FontWeight.bold, 
                          color: primaryTextColor
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Editável para usuários premium',
                        style: TextStyle(
                          fontSize: 16, 
                          color: secondaryTextColor
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildDefaultCategories(
                        defaultCategories,
                        primaryTextColor, 
                        secondaryTextColor
                      ),
                      
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
              // Botão Nova Categoria
              Padding(
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
                    onPressed: customCategories.length < 3 
                        ? _createNewCategory 
                        : null,
                    child: const Text(
                      'NOVA CATEGORIA',
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
          );
        },
      ),
    );
  }

  Widget _buildCustomCategories(
    List<Category> categories,
    Color primaryTextColor, 
    Color secondaryTextColor
  ) {
    // Add empty slots if less than 3 categories
    final displayCategories = List<Category?>.from(categories);
    while (displayCategories.length < 3) {
      displayCategories.add(null);
    }

    return SizedBox(
      height: 110,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 8,
          mainAxisSpacing: 0,
          childAspectRatio: 0.8,
        ),
        itemCount: displayCategories.length,
        itemBuilder: (context, index) {
          final category = displayCategories[index];
          
          if (category == null) {
            // Show empty slot
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.grey[800]!,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Icon(
                    Icons.add,
                    color: Colors.grey[700],
                    size: 35,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Vazio',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            );
          }
          
          return _buildCategoryItem(
            category,
            primaryTextColor, 
            secondaryTextColor,
            onTap: () => _navigateToEditCategory(category),
          );
        },
      ),
    );
  }

  Widget _buildDefaultCategories(
    List<Category> categories,
    Color primaryTextColor, 
    Color secondaryTextColor
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryItem(
          category,
          primaryTextColor, 
          secondaryTextColor,
          onTap: () => _navigateToEditCategory(category),
        );
      },
    );
  }

  Widget _buildCategoryItem(
    Category category,
    Color primaryTextColor, 
    Color secondaryTextColor,
    {VoidCallback? onTap}
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: category.color,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: category.color.withValues(alpha: 0.3),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              category.icon,
              color: Colors.white, 
              size: 35
            ),
          ),
          const SizedBox(height: 6),
          Text(
            category.name.length > 7 
                ? '${category.name.substring(0, 6)}...' 
                : category.name,
            style: TextStyle(
              fontSize: 13, 
              fontWeight: FontWeight.w600, 
              color: primaryTextColor
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          Text(
            '${category.taskIds.length} tarefa${category.taskIds.length == 1 ? '' : 's'}',
            style: TextStyle(
              fontSize: 11, 
              color: secondaryTextColor
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
