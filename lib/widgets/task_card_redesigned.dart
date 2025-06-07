import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/models/task.dart';
import 'package:myapp/models/category.dart';
import 'package:myapp/theme/category_colors.dart';
import 'package:myapp/services/category_service.dart';
import 'package:myapp/services/service_provider.dart';
import 'package:myapp/widgets/category_tag.dart';
import 'package:intl/intl.dart';

class TaskCardRedesigned extends StatefulWidget {
  final Task task;
  final Function(String taskId, bool completed)? onToggleCompletion;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TaskCardRedesigned({
    super.key,
    required this.task,
    this.onToggleCompletion,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<TaskCardRedesigned> createState() => _TaskCardRedesignedState();
}

class _TaskCardRedesignedState extends State<TaskCardRedesigned> {
  bool _showActions = false;

  @override
  Widget build(BuildContext context) {
    final categoryService = ServiceProvider.of<CategoryService>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return FutureBuilder<Category?>(
      future: widget.task.categoryId != null && widget.task.categoryId!.isNotEmpty
          ? categoryService.getCategoryById(widget.task.categoryId!)
          : Future.value(null),
      builder: (context, snapshot) {
        final category = snapshot.data;
        final categoryColor = category != null
            ? CategoryColors.getCategoryColor(category.name, isDarkMode)
            : CategoryColors.getCategoryColor('Tarefa', isDarkMode);
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Stack(
              children: [
                // Main card
                Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[900] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode 
                            ? Colors.black.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Task info
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Category icon
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                category?.icon ?? Icons.task_alt,
                                color: categoryColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            
                            // Task details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.task.title,
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white : Colors.black87,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      if (category != null)
                                        CategoryTag(
                                          label: category.name,
                                          color: categoryColor,
                                          fontSize: 11,
                                        ),
                                      if (widget.task.dueDate != null) ...[
                                        if (category != null) const SizedBox(width: 8),
                                        Text(
                                          'Vence: ${DateFormat('dd/MM').format(widget.task.dueDate!)}',
                                          style: TextStyle(
                                            color: isDarkMode 
                                                ? Colors.grey[500] 
                                                : Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            // Action button
                            if (!_showActions)
                              IconButton(
                                icon: Icon(
                                  Icons.more_vert,
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                ),
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  setState(() {
                                    _showActions = !_showActions;
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                      
                      // Complete button or actions
                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 200),
                        crossFadeState: _showActions 
                            ? CrossFadeState.showSecond 
                            : CrossFadeState.showFirst,
                        firstChild: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                widget.onToggleCompletion?.call(widget.task.id, true);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: categoryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Marcar Concluído',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        secondChild: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    setState(() {
                                      _showActions = false;
                                    });
                                    widget.onEdit?.call();
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: isDarkMode ? Colors.white : Colors.black87,
                                    side: BorderSide(
                                      color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Editar'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    setState(() {
                                      _showActions = false;
                                    });
                                    widget.onDelete?.call();
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Excluir'),
                                ),
                              ),
                            ],
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
      },
    );
  }
}