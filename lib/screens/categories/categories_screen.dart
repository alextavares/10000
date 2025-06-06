import 'package:flutter/material.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    
    // Forçar cores escuras para corresponder ao design
    final Color backgroundColor = const Color(0xFF121212);
    final Color primaryTextColor = Colors.white;
    final Color secondaryTextColor = Colors.grey[500]!;
    final Color accentColor = const Color(0xFFE91E63);

    return Container(
      color: backgroundColor,
      child: Column(
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
                    '3 disponíveis',
                    style: TextStyle(
                      fontSize: 16, 
                      color: secondaryTextColor
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildCustomCategories(primaryTextColor, secondaryTextColor),
                  
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
                  _buildDefaultCategories(primaryTextColor, secondaryTextColor),
                  
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
                onPressed: () {
                  // TODO: Implementar funcionalidade NOVA CATEGORIA
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Criar nova categoria'),
                      backgroundColor: Color(0xFFE91E63),
                    ),
                  );
                },
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
      ),
    );
  }

  Widget _buildCustomCategories(Color primaryTextColor, Color secondaryTextColor) {
    final customCategories = [
      {
        'icon': Icons.dashboard_rounded, 
        'name': 'Nova c...', 
        'entries': 0, 
        'color': const Color(0xFFE91E63)
      },
      {
        'icon': Icons.hub_rounded, 
        'name': 'Person...', 
        'entries': 1, 
        'color': const Color(0xFF9CCC65)
      },
      // Espaço vazio para 3 disponíveis
    ];

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
        itemCount: customCategories.length,
        itemBuilder: (context, index) {
          final category = customCategories[index];
          return _buildCategoryItem(category, primaryTextColor, secondaryTextColor);
        },
      ),
    );
  }

  Widget _buildDefaultCategories(Color primaryTextColor, Color secondaryTextColor) {
    final defaultCategories = [
      // Primeira linha
      {
        'icon': Icons.do_disturb_rounded, 
        'name': 'Abando...', 
        'entries': 1, 
        'color': const Color(0xFFE53935)
      },
      {
        'icon': Icons.brush_rounded, 
        'name': 'Arte', 
        'entries': 1, 
        'color': const Color(0xFFEC407A)
      },
      {
        'icon': Icons.access_time_rounded, 
        'name': 'Tarefa', 
        'entries': 1, 
        'color': const Color(0xFFAD1457)
      },
      {
        'icon': Icons.self_improvement_rounded, 
        'name': 'Medita...', 
        'entries': 0, 
        'color': const Color(0xFFAB47BC)
      },
      {
        'icon': Icons.school_rounded, 
        'name': 'Estudos', 
        'entries': 0, 
        'color': const Color(0xFF7E57C2)
      },
      // Segunda linha
      {
        'icon': Icons.directions_bike_rounded, 
        'name': 'Esportes', 
        'entries': 0, 
        'color': const Color(0xFF5C6BC0)
      },
      {
        'icon': Icons.star_rounded, 
        'name': 'Entret...', 
        'entries': 0, 
        'color': const Color(0xFF00ACC1)
      },
      {
        'icon': Icons.forum_rounded, 
        'name': 'Social', 
        'entries': 2, 
        'color': const Color(0xFF00897B)
      },
      {
        'icon': Icons.attach_money_rounded, 
        'name': 'Finança', 
        'entries': 0, 
        'color': const Color(0xFF66BB6A)
      },
      {
        'icon': Icons.add_rounded, 
        'name': 'Saúde', 
        'entries': 0, 
        'color': const Color(0xFF9CCC65)
      },
      // Terceira linha
      {
        'icon': Icons.work_rounded, 
        'name': 'Trabalho', 
        'entries': 0, 
        'color': const Color(0xFF8D6E63)
      },
      {
        'icon': Icons.restaurant_rounded, 
        'name': 'Nutrição', 
        'entries': 0, 
        'color': const Color(0xFFFF8A65)
      },
      {
        'icon': Icons.home_rounded, 
        'name': 'Casa', 
        'entries': 0, 
        'color': const Color(0xFFFF7043)
      },
      {
        'icon': Icons.terrain_rounded, 
        'name': 'Ar livre', 
        'entries': 0, 
        'color': const Color(0xFFFF6E40)
      },
      {
        'icon': Icons.dashboard_rounded, 
        'name': 'Outros', 
        'entries': 0, 
        'color': const Color(0xFFEF5350)
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: defaultCategories.length,
      itemBuilder: (context, index) {
        final category = defaultCategories[index];
        return _buildCategoryItem(category, primaryTextColor, secondaryTextColor);
      },
    );
  }

  Widget _buildCategoryItem(Map<String, dynamic> category, Color primaryTextColor, Color secondaryTextColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            color: category['color'] as Color,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: (category['color'] as Color).withValues(alpha: 0.3),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            category['icon'] as IconData, 
            color: Colors.white, 
            size: 35
          ),
        ),
        const SizedBox(height: 6),
        Text(
          category['name'] as String,
          style: TextStyle(
            fontSize: 13, 
            fontWeight: FontWeight.w600, 
            color: primaryTextColor
          ),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        Text(
          '${category['entries']} entrad${category['entries'] == 1 ? 'a' : '...'}',
          style: TextStyle(
            fontSize: 11, 
            color: secondaryTextColor
          ),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
