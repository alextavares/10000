import 'package:flutter/material.dart';
import 'package:myapp/models/recurring_task.dart';
import 'package:myapp/screens/recurring_task/add_recurring_task_category_screen.dart';

class AddRecurringTaskScreen extends StatefulWidget {
  final RecurringTask? recurringTaskToEdit;

  const AddRecurringTaskScreen({super.key, this.recurringTaskToEdit});

  @override
  State<AddRecurringTaskScreen> createState() => _AddRecurringTaskScreenState();
}

class _AddRecurringTaskScreenState extends State<AddRecurringTaskScreen> {
  @override
  void initState() {
    super.initState();
  }

  void _showTrackingTypeSelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Como você quer avaliar seu progresso?',
                  style: TextStyle(
                    color: Color(0xFFE91E63),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                _buildTrackingOption(
                  title: 'COM SIM OU NÃO',
                  description: 'Se todos os dias você quiser registrar se teve ou não sucesso com seu atividade',
                  trackingType: RecurringTaskTrackingType.simOuNao,
                ),
                const SizedBox(height: 16),
                _buildTrackingOption(
                  title: 'COM UMA LISTA DE ATIVIDADES',
                  description: 'Se você deseja avaliar sua atividade com base em um conjunto de subitens',
                  trackingType: RecurringTaskTrackingType.listaAtividades,
                  isPremium: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrackingOption({
    required String title,
    required String description,
    required RecurringTaskTrackingType trackingType,
    bool isPremium = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE91E63),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            if (isPremium) {
              // Show premium dialog or navigate to premium screen
              _showPremiumDialog();
            } else {
              _navigateToNextStep(trackingType);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isPremium)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
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
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                if (isPremium) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Funcionalidade Premium',
                    style: TextStyle(
                      color: Color(0xFFE91E63),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
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
                backgroundColor: const Color(0xFFE91E63),
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

  void _navigateToNextStep(RecurringTaskTrackingType trackingType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddRecurringTaskCategoryScreen(
          trackingType: trackingType,
          recurringTaskToEdit: widget.recurringTaskToEdit,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Auto-navigate to tracking type selection when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showTrackingTypeSelection();
    });

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nova Tarefa Recorrente',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFE91E63),
        ),
      ),
    );
  }
}