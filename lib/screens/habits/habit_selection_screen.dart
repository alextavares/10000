import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/habit.dart';
import '../../services/habit_service.dart';
import '../../data/habit_suggestions.dart';
import '../../utils/app_colors.dart';

class HabitSelectionScreen extends StatefulWidget {
  const HabitSelectionScreen({super.key});

  @override
  State<HabitSelectionScreen> createState() => _HabitSelectionScreenState();
}

class _HabitSelectionScreenState extends State<HabitSelectionScreen> 
    with TickerProviderStateMixin {
  String selectedCategory = 'Todos';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final Set<HabitSuggestion> _selectedHabits = {};
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<HabitSuggestion> get filteredSuggestions {
    var suggestions = HabitSuggestions.getAllSuggestions();
    
    // Filtrar por categoria
    if (selectedCategory != 'Todos') {
      suggestions = suggestions
          .where((s) => s.category == selectedCategory)
          .toList();
    }
    
    // Filtrar por busca
    if (searchQuery.isNotEmpty) {
      suggestions = suggestions
          .where((s) => 
              s.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              s.description.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }
    
    return suggestions;
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = selectedCategory == category;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: FilterChip(
        label: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.primaryDark,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedCategory = category;
          });
          HapticFeedback.lightImpact();
        },
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary,
        showCheckmark: false,
        elevation: isSelected ? 4 : 1,
        shadowColor: AppColors.primary.withOpacity(0.3),
      ),
    );
  }

  Widget _buildHabitSuggestionCard(HabitSuggestion suggestion, int index) {
    final isSelected = _selectedHabits.contains(suggestion);
    
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, 0.1 + (index * 0.02)),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                index * 0.05,
                1.0,
                curve: Curves.easeOutCubic,
              ),
            )),
            child: child!,
          ),
        );
      },
      child: Card(
        elevation: isSelected ? 8 : 2,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedHabits.remove(suggestion);
              } else {
                _selectedHabits.add(suggestion);
              }
            });
            HapticFeedback.lightImpact();
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: suggestion.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        suggestion.icon,
                        color: suggestion.color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            suggestion.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            suggestion.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? AppColors.primary : Colors.grey[300],
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            )
                          : null,
                    ),
                  ],
                ),
                if (suggestion.defaultFrequency != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.repeat,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getFrequencyText(suggestion.defaultFrequency!),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getFrequencyText(Map<String, dynamic> frequency) {
    switch (frequency['type']) {
      case 'daily':
        return 'Diário';
      case 'weekly':
        final days = frequency['daysOfWeek'] as List<int>?;
        if (days != null) {
          return 'Semanal (${days.length} dias)';
        }
        return 'Semanal';
      case 'monthly':
        return 'Mensal';
      default:
        return 'Personalizado';
    }
  }

  void _addSelectedHabits() async {
    if (_selectedHabits.isEmpty) return;
    
    setState(() {
      _isAdding = true;
    });

    try {
      final habitService = Provider.of<HabitService>(context, listen: false);
      
      for (final suggestion in _selectedHabits) {
        // Converter defaultFrequency para HabitFrequency enum
        HabitFrequency frequency = HabitFrequency.daily;
        List<int>? daysOfWeek;
        
        if (suggestion.defaultFrequency != null) {
          switch (suggestion.defaultFrequency!['type']) {
            case 'daily':
              frequency = HabitFrequency.daily;
              break;
            case 'weekly':
              frequency = HabitFrequency.weekly;
              daysOfWeek = suggestion.defaultFrequency!['daysOfWeek'] as List<int>?;
              break;
            case 'monthly':
              frequency = HabitFrequency.monthly;
              break;
            default:
              frequency = HabitFrequency.daily;
          }
        }
        
        // Determinar o tipo de rastreamento baseado na unidade
        HabitTrackingType trackingType = HabitTrackingType.simOuNao;
        if (suggestion.unit != null) {
          if (suggestion.unit!.toLowerCase().contains('minuto') || 
              suggestion.unit!.toLowerCase().contains('hora')) {
            trackingType = HabitTrackingType.cronometro;
          } else if (suggestion.targetValue != null && suggestion.targetValue! > 1) {
            trackingType = HabitTrackingType.quantia;
          }
        }
        
        await habitService.addHabit(
          title: suggestion.name,
          categoryName: suggestion.category,
          categoryIcon: suggestion.icon,
          categoryColor: suggestion.color,
          frequency: frequency,
          trackingType: trackingType,
          startDate: DateTime.now(),
          daysOfWeek: daysOfWeek,
          targetDate: null,
          reminderTime: suggestion.defaultReminder,
          notificationsEnabled: suggestion.defaultReminder != null,
          description: suggestion.description,
        );
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedHabits.length} hábitos adicionados com sucesso!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao adicionar hábitos: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAdding = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['Todos', ...HabitSuggestions.getCategories()];
    final suggestions = filteredSuggestions;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sugestões de Hábitos'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          if (_selectedHabits.isNotEmpty)
            TextButton.icon(
              onPressed: _isAdding ? null : _addSelectedHabits,
              icon: _isAdding
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.add, color: Colors.white),
              label: Text(
                'Adicionar (${_selectedHabits.length})',
                style: const TextStyle(color: Colors.white),
              ),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Barra de busca
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar hábitos...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          
          // Chips de categorias
          Container(
            height: 50,
            color: AppColors.surface,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildCategoryChip(categories[index]),
                );
              },
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
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum hábito encontrado',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: suggestions.length,
                    itemBuilder: (context, index) {
                      return _buildHabitSuggestionCard(
                        suggestions[index],
                        index,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}