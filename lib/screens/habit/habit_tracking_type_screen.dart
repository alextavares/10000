import 'package:flutter/material.dart';
import 'package:myapp/models/habit.dart'; // For HabitTrackingType enum
import 'package:myapp/theme/app_theme.dart';
import 'add_habit_title_screen.dart'; // To navigate to next step

class HabitTrackingTypeScreen extends StatefulWidget {
  // Updated constructor parameters
  final String categoryName;
  final IconData categoryIcon;
  final Color categoryColor;

  const HabitTrackingTypeScreen({
    super.key,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    // Removed parameters that are not available at this stage:
    // habitTitle, habitDescription, frequency, daysOfWeek
  });

  @override
  State<HabitTrackingTypeScreen> createState() => _HabitTrackingTypeScreenState();
}

class _HabitTrackingTypeScreenState extends State<HabitTrackingTypeScreen> {
  HabitTrackingType? _selectedTrackingType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Como você quer avaliar seu progresso?',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView( // Added SingleChildScrollView for smaller screens
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildTrackingOption(
                      type: HabitTrackingType.simOuNao,
                      title: 'COM SIM OU NÃO',
                      description: 'Se todos os dias você quiser registrar se teve ou não sucesso com sua atividade',
                      isSelected: _selectedTrackingType == HabitTrackingType.simOuNao,
                    ),
                    const SizedBox(height: 16),
                    _buildTrackingOption(
                      type: HabitTrackingType.quantia,
                      title: 'COM UMA QUANTIA',
                      description: 'Se você deseja definir uma meta diária ou valor limite para a atividade',
                      isSelected: _selectedTrackingType == HabitTrackingType.quantia,
                    ),
                    const SizedBox(height: 16),
                    _buildTrackingOption(
                      type: HabitTrackingType.cronometro,
                      title: 'COM UM CRONÔMETRO',
                      description: 'Se você deseja estabelecer um valor de tempo como meta diária ou limite para o hábito',
                      isSelected: _selectedTrackingType == HabitTrackingType.cronometro,
                    ),
                    const SizedBox(height: 16),
                    _buildTrackingOption(
                      type: HabitTrackingType.listaAtividades,
                      title: 'COM UMA LISTA DE ATIVIDADES',
                      description: 'Se você deseja avaliar sua atividade com base em um conjunto de subitens',
                      isSelected: _selectedTrackingType == HabitTrackingType.listaAtividades,
                      isPremium: true, // As per original design
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0), // Added padding for bottom buttons
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'ANTERIOR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // TODO: Implement or update progress indicators if needed
                  ElevatedButton(
                    onPressed: _selectedTrackingType != null ? _onNext : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      disabledBackgroundColor: Colors.grey[600],
                    ),
                    child: const Text(
                      'PRÓXIMA',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingOption({
    required HabitTrackingType type,
    required String title,
    required String description,
    required bool isSelected,
    bool isPremium = false,
  }) {
    return GestureDetector(
      onTap: () {
        // If the tapped option is premium and not yet enabled, we might want to show a message or disable selection.
        // For now, we allow selection but the premium status is just visual.
        // if (isPremium && !isPremiumFeatureEnabled) { 
        //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Funcionalidade Premium!'))); 
        //   return; 
        // }
        setState(() {
          _selectedTrackingType = type;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: isSelected 
              ? Border.all(color: AppTheme.primaryColor.withOpacity(0.5), width: 2) // Softer border for selected
              : Border.all(color: AppTheme.cardColor.withOpacity(0.5)), // Default border
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isPremium)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor, // Or another distinct color for premium tag
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Premium',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                color: isSelected ? Colors.white.withOpacity(0.9) : AppTheme.subtitleColor,
                fontSize: 14,
              ),
            ),
            // Removed redundant premium text, as it's now a tag in the title row
          ],
        ),
      ),
    );
  }

  void _onNext() {
    if (_selectedTrackingType == null) return;

    switch (_selectedTrackingType!) {
      case HabitTrackingType.simOuNao:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddHabitTitleScreen(
            selectedCategoryName: widget.categoryName,
            selectedCategoryIcon: widget.categoryIcon,
            selectedCategoryColor: widget.categoryColor,
            // Pass the selected tracking type to the next screen
            // AddHabitTitleScreen will need to be updated to accept this parameter
            selectedTrackingType: _selectedTrackingType!,
          ),
        ));
        break;
      case HabitTrackingType.quantia:
      case HabitTrackingType.cronometro:
      case HabitTrackingType.listaAtividades:
        // Para outros tipos de rastreamento, navegar diretamente para a tela de título
        // pois as telas específicas de configuração ainda não foram implementadas
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddHabitTitleScreen(
            selectedCategoryName: widget.categoryName,
            selectedCategoryIcon: widget.categoryIcon,
            selectedCategoryColor: widget.categoryColor,
            selectedTrackingType: _selectedTrackingType!,
          ),
        ));
        break;
    }
  }
}
