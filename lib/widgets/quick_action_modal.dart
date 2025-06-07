import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/models/category.dart';
import 'package:myapp/theme/category_colors.dart';
import 'package:myapp/services/category_service.dart';
import 'package:myapp/services/service_provider.dart';

class QuickActionModal extends StatelessWidget {
  final Habit habit;
  final VoidCallback? onSuccess;
  final VoidCallback? onFail;
  final VoidCallback? onSkip;
  final VoidCallback? onAddReminder;
  final VoidCallback? onAddNote;
  final VoidCallback? onResetValue;

  const QuickActionModal({
    super.key,
    required this.habit,
    this.onSuccess,
    this.onFail,
    this.onSkip,
    this.onAddReminder,
    this.onAddNote,
    this.onResetValue,
  });

  static void show(
    BuildContext context, {
    required Habit habit,
    VoidCallback? onSuccess,
    VoidCallback? onFail,
    VoidCallback? onSkip,
    VoidCallback? onAddReminder,
    VoidCallback? onAddNote,
    VoidCallback? onResetValue,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => QuickActionModal(
        habit: habit,
        onSuccess: onSuccess,
        onFail: onFail,
        onSkip: onSkip,
        onAddReminder: onAddReminder,
        onAddNote: onAddNote,
        onResetValue: onResetValue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // O Habit já tem a cor e ícone diretamente
    final categoryColor = habit.color;
        
        return Container(
          padding: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[900] : Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Header com info do hábito
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: categoryColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              habit.icon,
                              color: categoryColor,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  habit.title,
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white : Colors.black87,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDate(DateTime.now()),
                                  style: TextStyle(
                                    color: categoryColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Opções de status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatusOption(
                            icon: Icons.radio_button_unchecked,
                            label: 'Pendente',
                            color: Colors.grey,
                            isSelected: !habit.isCompletedToday(),
                            onTap: null,
                          ),
                          _StatusOption(
                            icon: Icons.check_circle,
                            label: 'Sucesso',
                            color: Colors.green,
                            isSelected: habit.isCompletedToday(),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              onSuccess?.call();
                              Navigator.pop(context);
                            },
                          ),
                          _StatusOption(
                            icon: Icons.cancel,
                            label: 'Falhou',
                            color: Colors.red,
                            isSelected: false,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              onFail?.call();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                const Divider(height: 1),
                
                // Ações adicionais
                _ActionTile(
                  icon: Icons.notifications_outlined,
                  title: 'Adicionar lembrete...',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                    onAddReminder?.call();
                  },
                ),
                _ActionTile(
                  icon: Icons.note_add_outlined,
                  title: 'Adicionar anotação...',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                    onAddNote?.call();
                  },
                ),
                _ActionTile(
                  icon: Icons.skip_next_outlined,
                  title: 'Pular',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                    onSkip?.call();
                  },
                ),
                _ActionTile(
                  icon: Icons.refresh_outlined,
                  title: 'Redefinir valor',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                    onResetValue?.call();
                  },
                ),
                
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
  }

  String _formatDate(DateTime date) {
    final months = [
      'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'
    ];
    return '${date.day.toString().padLeft(2, '0')}/${months[date.month - 1]}/${date.year}';
  }
}

class _StatusOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  const _StatusOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: color.withOpacity(0.3), width: 1)
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black87,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isDarkMode ? Colors.white70 : Colors.black87,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }
}