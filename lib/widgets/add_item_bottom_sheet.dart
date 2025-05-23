import 'package:flutter/material.dart';
import 'package:myapp/theme/app_theme.dart'; // Assuming AppTheme defines colors like primaryColor

// Enum to represent the type of item to add
enum AddItemType { habit, recurringTask, task }

class AddItemBottomSheet extends StatelessWidget {
  final Function(AddItemType) onItemSelected;

  const AddItemBottomSheet({super.key, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDarkMode ? Colors.grey[850]! : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color subTextColor = isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
    // Use a consistent accent color, perhaps from AppTheme if available
    final Color accentColor = AppTheme.primaryColor; // Example, adjust as per your AppTheme

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[500],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const Text(
            'O que você gostaria de adicionar?', // Title for the bottom sheet
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildOptionCard(
            context: context,
            icon: Icons.emoji_events_outlined, // Placeholder for trophy icon
            iconColor: accentColor,
            title: 'Hábito',
            description: 'Atividade que se repete ao longo do tempo. Possui rastreamento detalhado e estatísticas.',
            cardColor: cardColor,
            textColor: textColor,
            subTextColor: subTextColor,
            onTap: () => onItemSelected(AddItemType.habit),
          ),
          const SizedBox(height: 12),
          _buildOptionCard(
            context: context,
            icon: Icons.sync_outlined, // Placeholder for loop icon
            iconColor: accentColor,
            title: 'Tarefa recorrente',
            description: 'Atividade que se repete ao longo do tempo, sem rastreamento ou estatísticas.',
            cardColor: cardColor,
            textColor: textColor,
            subTextColor: subTextColor,
            onTap: () => onItemSelected(AddItemType.recurringTask),
          ),
          const SizedBox(height: 12),
          _buildOptionCard(
            context: context,
            icon: Icons.check_circle_outline_outlined, // Placeholder for checkmark icon
            iconColor: accentColor,
            title: 'Tarefa',
            description: 'Atividade de instância única sem rastreamento ao longo do tempo.',
            cardColor: cardColor,
            textColor: textColor,
            subTextColor: subTextColor,
            onTap: () => onItemSelected(AddItemType.task),
          ),
          const SizedBox(height: 16), // For bottom padding
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required Color cardColor,
    required Color textColor,
    required Color subTextColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1.0,
      margin: EdgeInsets.zero, // Reset margin as we use SizedBox for spacing
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              Icon(icon, color: iconColor, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
