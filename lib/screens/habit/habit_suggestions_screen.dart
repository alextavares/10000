import 'package:flutter/material.dart';
import 'package:myapp/data/habit_suggestions.dart';
import 'package:myapp/screens/habit/habit_tracking_type_screen.dart';
import 'package:myapp/screens/habit/add_habit_screen.dart';

class HabitSuggestionsScreen extends StatefulWidget {
  const HabitSuggestionsScreen({super.key});

  @override
  State<HabitSuggestionsScreen> createState() => _HabitSuggestionsScreenState();
}

class _HabitSuggestionsScreenState extends State<HabitSuggestionsScreen> 
    with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  List<HabitSuggestion> _getFilteredSuggestions() {
    if (_selectedCategory != null) {
      return HabitSuggestions.suggestions[_selectedCategory] ?? [];
    }
    
    if (_searchQuery.isNotEmpty) {
      return HabitSuggestions.searchSuggestions(_searchQuery);
    }
    
    return HabitSuggestions.allSuggestions;
  }

  void _createHabitFromSuggestion(HabitSuggestion suggestion) {
    // Navegar para a tela de tipo de rastreamento com os dados da sugestão
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HabitTrackingTypeScreen(
          categoryName: _getCategoryForSuggestion(suggestion),
          categoryIcon: suggestion.icon,
          categoryColor: suggestion.color,
          // Passar dados adicionais da sugestão
          suggestedTitle: suggestion.title,
          suggestedDescription: suggestion.description,
          suggestedTargetValue: suggestion.targetValue,
          suggestedUnit: suggestion.unit,
        ),
      ),
    );
  }
  String _getCategoryForSuggestion(HabitSuggestion suggestion) {
    // Encontrar a categoria da sugestão
    for (var entry in HabitSuggestions.suggestions.entries) {
      if (entry.value.contains(suggestion)) {
        // Mapear para as categorias existentes no app
        switch (entry.key) {
          case 'Saúde e Fitness':
            return 'Saúde';
          case 'Produtividade':
            return 'Trabalho';
          case 'Alimentação':
            return 'Nutrição';
          case 'Bem-estar':
            return 'Meditação';
          case 'Social':
            return 'Social';
          default:
            return 'Outros';
        }
      }
    }
    return 'Outros';
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = _getFilteredSuggestions();
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Escolher Hábito',
          style: TextStyle(
            color: Colors.pinkAccent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              // Ir direto para criação personalizada
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const AddHabitScreen(),
                ),
              );
            },
            icon: const Icon(Icons.edit, color: Colors.pinkAccent, size: 18),
            label: const Text(
              'Criar do zero',
              style: TextStyle(color: Colors.pinkAccent),
            ),
          ),
        ],
      ),      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Barra de busca
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    if (value.isNotEmpty) {
                      _selectedCategory = null; // Limpar categoria ao buscar
                    }
                  });
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Buscar hábitos...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: const Icon(Icons.search, color: Colors.pinkAccent),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),            // Chips de categorias
            if (_searchQuery.isEmpty) ...[
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // Chip "Todos"
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: const Text('Todos'),
                        selected: _selectedCategory == null,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = null;
                          });
                        },
                        selectedColor: Colors.pinkAccent,
                        backgroundColor: Colors.grey[850],
                        labelStyle: TextStyle(
                          color: _selectedCategory == null
                              ? Colors.white
                              : Colors.grey[400],
                          fontWeight: _selectedCategory == null
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    // Chips das categorias
                    ...HabitSuggestions.suggestions.keys.map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: _selectedCategory == category,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = selected ? category : null;
                            });
                          },
                          selectedColor: Colors.pinkAccent,
                          backgroundColor: Colors.grey[850],
                          labelStyle: TextStyle(
                            color: _selectedCategory == category
                                ? Colors.white
                                : Colors.grey[400],
                            fontWeight: _selectedCategory == category
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],            const SizedBox(height: 16),
            // Contador de resultados
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    '${suggestions.length} sugestões encontradas',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Lista de sugestões
            Expanded(
              child: suggestions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[800],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhuma sugestão encontrada',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: suggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = suggestions[index];
                        return _buildSuggestionCard(suggestion);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildSuggestionCard(HabitSuggestion suggestion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: suggestion.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _createHabitFromSuggestion(suggestion),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Ícone
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: suggestion.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    suggestion.icon,
                    color: suggestion.color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // Informações
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        suggestion.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        suggestion.description,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                      if (suggestion.targetValue != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.flag_outlined,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Meta: ${suggestion.targetValue?.toInt()} ${suggestion.unit ?? ''}',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // Seta
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[600],
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
