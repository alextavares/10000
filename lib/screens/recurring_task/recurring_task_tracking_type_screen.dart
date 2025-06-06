import 'package:flutter/material.dart';
import 'package:myapp/models/recurring_task.dart';
import 'package:myapp/theme/app_theme.dart';
import 'add_recurring_task_category_screen.dart';

class RecurringTaskTrackingTypeScreen extends StatefulWidget {
  final RecurringTask? recurringTaskToEdit;

  const RecurringTaskTrackingTypeScreen({
    super.key,
    this.recurringTaskToEdit,
  });

  @override
  State<RecurringTaskTrackingTypeScreen> createState() => _RecurringTaskTrackingTypeScreenState();
}

class _RecurringTaskTrackingTypeScreenState extends State<RecurringTaskTrackingTypeScreen> {
  RecurringTaskTrackingType? _selectedTrackingType;

  @override
  Widget build(BuildContext context) {
    // Obter os insets do sistema
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final EdgeInsets viewPadding = mediaQuery.viewPadding;
    final EdgeInsets viewInsets = mediaQuery.viewInsets;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nova Tarefa Recorrente',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0).copyWith(
                top: 16.0,
                bottom: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Como você quer avaliar seu progresso?',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTrackingOption(
                    type: RecurringTaskTrackingType.simOuNao,
                    title: 'COM SIM OU NÃO',
                    description: 'Se todos os dias você quiser registrar se teve ou não sucesso com sua atividade',
                    isSelected: _selectedTrackingType == RecurringTaskTrackingType.simOuNao,
                  ),
                  const SizedBox(height: 16),
                  _buildTrackingOption(
                    type: RecurringTaskTrackingType.listaAtividades,
                    title: 'COM UMA LISTA DE ATIVIDADES',
                    description: 'Se você deseja avaliar sua atividade com base em um conjunto de subitens',
                    isSelected: _selectedTrackingType == RecurringTaskTrackingType.listaAtividades,
                    isPremium: true,
                  ),
                ],
              ),
            ),
          ),
          // Container dos botões com padding manual considerando os insets
          Container(
            padding: EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
              bottom: 16.0 + viewPadding.bottom, // Adiciona o padding do sistema
            ),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, -1),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    minimumSize: const Size(100, 48),
                  ),
                  child: const Text(
                    'ANTERIOR',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _selectedTrackingType != null ? _onNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    minimumSize: const Size(100, 48),
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
    );
  }

  Widget _buildTrackingOption({
    required RecurringTaskTrackingType type,
    required String title,
    required String description,
    required bool isSelected,
    bool isPremium = false,
  }) {
    return GestureDetector(
      onTap: () {
        if (isPremium) {
          _showPremiumDialog();
        } else {
          setState(() {
            _selectedTrackingType = type;
          });
        }
      },
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(
          minHeight: 80,
          maxHeight: 150,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: isSelected 
              ? Border.all(color: AppTheme.primaryColor.withOpacity(0.5), width: 2)
              : Border.all(color: AppTheme.cardColor.withOpacity(0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isPremium)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor,
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
            Flexible(
              child: Text(
                description,
                style: TextStyle(
                  color: isSelected ? Colors.white.withOpacity(0.9) : AppTheme.subtitleColor,
                  fontSize: 13,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Funcionalidade Premium',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Esta funcionalidade está disponível apenas para usuários Premium. Deseja fazer upgrade?',
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
                // Navigate to premium screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: const Text(
                'Upgrade',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _onNext() {
    if (_selectedTrackingType == null) return;

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AddRecurringTaskCategoryScreen(
        trackingType: _selectedTrackingType!,
        recurringTaskToEdit: widget.recurringTaskToEdit,
      ),
    ));
  }
}
