import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/models/recurring_task.dart';
import 'package:myapp/models/category.dart';
import 'package:myapp/theme/category_colors.dart';
import 'package:myapp/services/category_service.dart';
import 'package:myapp/services/service_provider.dart';
import 'package:myapp/widgets/category_tag.dart';

class RecurringTaskCardRedesigned extends StatelessWidget {
  final RecurringTask recurringTask;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const RecurringTaskCardRedesigned({
    super.key,
    required this.recurringTask,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final categoryService = ServiceProvider.of<CategoryService>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return FutureBuilder<Category?>(
      future: recurringTask.categoryId != null && recurringTask.categoryId!.isNotEmpty
          ? categoryService.getCategoryById(recurringTask.categoryId!)
          : Future.value(null),
      builder: (context, snapshot) {
        final category = snapshot.data;
        final categoryColor = category != null
            ? CategoryColors.getCategoryColor(category.name, isDarkMode)
            : CategoryColors.getCategoryColor('Tarefa', isDarkMode);
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode 
                      ? Colors.black.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  _showOptionsModal(context, categoryColor);
                },
                onLongPress: () {
                  HapticFeedback.mediumImpact();
                  _showOptionsModal(context, categoryColor);
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Ícone colorido com background
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          category?.icon ?? Icons.repeat,
                          color: categoryColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Conteúdo principal
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Título
                            Text(
                              recurringTask.title,
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            
                            // Categoria e frequência
                            Row(
                              children: [
                                // Tag de categoria
                                if (category != null) ...[
                                  CategoryTag(
                                    label: category.name,
                                    color: categoryColor,
                                    fontSize: 12,
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                
                                // Frequência
                                Icon(
                                  Icons.repeat,
                                  size: 14,
                                  color: isDarkMode 
                                      ? Colors.grey[500] 
                                      : Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _getFrequencyText(),
                                  style: TextStyle(
                                    color: isDarkMode 
                                        ? Colors.grey[500] 
                                        : Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Ícone de mais opções
                      Icon(
                        Icons.chevron_right,
                        color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showOptionsModal(BuildContext context, Color categoryColor) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[900] : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
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
                  
                  // Título
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      recurringTask.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  
                  const Divider(height: 20),
                  
                  // Opções
                  ListTile(
                    leading: Icon(
                      Icons.edit_outlined,
                      color: categoryColor,
                    ),
                    title: Text(
                      'Editar',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      onEdit?.call();
                    },
                  ),
                  
                  ListTile(
                    leading: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                    ),
                    title: const Text(
                      'Excluir',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      onDelete?.call();
                    },
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getFrequencyText() {
    switch (recurringTask.frequency) {
      case RecurringTaskFrequency.daily:
        return 'Diária';
      case RecurringTaskFrequency.weekly:
        if (recurringTask.daysOfWeek != null && recurringTask.daysOfWeek!.isNotEmpty) {
          return '${recurringTask.daysOfWeek!.length}x por semana';
        }
        return 'Semanal';
      case RecurringTaskFrequency.monthly:
        if (recurringTask.daysOfMonth != null && recurringTask.daysOfMonth!.isNotEmpty) {
          return '${recurringTask.daysOfMonth!.length}x por mês';
        }
        return 'Mensal';
      case RecurringTaskFrequency.custom:
        return 'Personalizada';
      default:
        return 'Personalizada';
    }
  }
}