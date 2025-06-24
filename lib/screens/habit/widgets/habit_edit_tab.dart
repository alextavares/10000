import 'package:flutter/material.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/services/habit_service.dart';
import 'package:provider/provider.dart';
import 'package:myapp/utils/logger.dart';

class HabitEditTab extends StatefulWidget {
  final Habit habit;
  final VoidCallback onHabitUpdated;

  const HabitEditTab({
    super.key,
    required this.habit,
    required this.onHabitUpdated,
  });

  @override
  State<HabitEditTab> createState() => _HabitEditTabState();
}

class _HabitEditTabState extends State<HabitEditTab> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String? _selectedCategoryName; // Armazenará o nome da categoria selecionada
  late app_category.Category? _selectedCategoryObject; // Para obter cor e ícone da categoria selecionada
  late String _selectedPriority;
  late HabitFrequency _selectedFrequency;
  late DateTime _startDate;
  DateTime? _targetDate;
  bool _hasReminder = false;
  TimeOfDay? _reminderTime;
  bool _isLoading = false;

  // Priority options
  final List<String> _priorities = ['Baixa', 'Normal', 'Alta'];
  
  // Lista de categorias carregadas do serviço
  List<app_category.Category> _availableCategories = [];
  bool _categoriesLoading = true;


  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.habit.title);
    _descriptionController = TextEditingController(text: widget.habit.description ?? '');
    
    _loadCategoriesAndInitFields();
    
    // Ensure the priority exists in the list, otherwise use 'Normal'
    // Also handle null or empty priority
    final habitPriority = widget.habit.priority;
    if (habitPriority != null && habitPriority.isNotEmpty && _priorities.contains(habitPriority)) {
      _selectedPriority = habitPriority;
    } else {
      _selectedPriority = 'Normal';
      Logger.debug('Priority "${habitPriority}" not found in list, defaulting to "Normal"');
    }
    
    _selectedFrequency = widget.habit.frequency; // Frequência não é editável diretamente aqui
    _startDate = widget.habit.startDate;
    _targetDate = widget.habit.targetDate; // Pode ser nulo
    _hasReminder = widget.habit.reminderTime != null;
    _reminderTime = widget.habit.reminderTime;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O título não pode estar vazio')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final habitService = context.read<HabitService>();
      
      // Create updated habit
      final updatedHabit = widget.habit.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        category: _selectedCategoryName, // Salvar o nome da categoria
        priority: _selectedPriority,
        // Frequência não é editada aqui, então não precisa ser incluída no copyWith a menos que seja para manter a original
        // frequency: _selectedFrequency,
        icon: _selectedCategoryObject?.icon ?? widget.habit.icon, // Atualiza ícone baseado na categoria
        color: _selectedCategoryObject?.color ?? widget.habit.color, // Atualiza cor baseado na categoria
        startDate: _startDate,
        startDate: _startDate,
        targetDate: _targetDate,
        reminderTime: _hasReminder ? _reminderTime : null,
        notificationsEnabled: _hasReminder,
      );

      await habitService.updateHabit(updatedHabit);
      
      if (mounted) {
        widget.onHabitUpdated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hábito atualizado com sucesso!')),
        );
      }
    } catch (e) {
      Logger.error('Error saving habit changes: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context, bool isTargetDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isTargetDate ? (_targetDate ?? DateTime.now()) : _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: widget.habit.color,
              onPrimary: Colors.white,
              surface: AppTheme.surfaceColor,
              onSurface: AppTheme.textColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        if (isTargetDate) {
          _targetDate = picked;
        } else {
          _startDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: widget.habit.color,
              onPrimary: Colors.white,
              surface: AppTheme.surfaceColor,
              onSurface: AppTheme.textColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  @override
  }

  Future<void> _loadCategoriesAndInitFields() async {
    if (!mounted) return;
    setState(() => _categoriesLoading = true);
    try {
      final categoryService = Provider.of<CategoryService>(context, listen: false);
      _availableCategories = await categoryService.getCategories();

      final habitCategoryName = widget.habit.category;
      if (habitCategoryName.isNotEmpty) {
        _selectedCategoryObject = _availableCategories.firstWhere(
          (cat) => cat.name == habitCategoryName,
          orElse: () {
            Logger.warning('Habit category "$habitCategoryName" not found in available categories. Defaulting to "Outros" or first available.');
            return _availableCategories.firstWhere(
              (cat) => cat.name.toLowerCase() == 'outros',
              orElse: () => _availableCategories.isNotEmpty ? _availableCategories.first : app_category.Category.defaultCategories.firstWhere((c) => c.name == "Outros") // Último recurso
            );
          }
        );
        _selectedCategoryName = _selectedCategoryObject?.name;
      } else if (_availableCategories.isNotEmpty) {
         _selectedCategoryObject = _availableCategories.firstWhere(
              (cat) => cat.name.toLowerCase() == 'outros',
              orElse: () => _availableCategories.first
            );
        _selectedCategoryName = _selectedCategoryObject?.name;
      }

    } catch (e) {
      Logger.error("Error loading categories for HabitEditTab: $e");
       // Fallback para categorias padrão se houver erro
      _availableCategories = app_category.Category.defaultCategories;
      _selectedCategoryObject = _availableCategories.firstWhere(
          (cat) => cat.name.toLowerCase() == (widget.habit.category.isNotEmpty ? widget.habit.category.toLowerCase() : 'outros'),
          orElse: () => _availableCategories.firstWhere((c) => c.name.toLowerCase() == 'outros', orElse: () => _availableCategories.first)
      );
      _selectedCategoryName = _selectedCategoryObject?.name;
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar categorias: $e. Usando padrões.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _categoriesLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_categoriesLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
    }

    // Atualiza _selectedCategoryObject se _selectedCategoryName mudar e a lista estiver carregada
    if (_availableCategories.isNotEmpty && _selectedCategoryName != null) {
        _selectedCategoryObject = _availableCategories.firstWhere(
            (cat) => cat.name == _selectedCategoryName,
            orElse: () => _selectedCategoryObject // Mantém o anterior se não encontrar (improvável)
        );
    }

    // Define uma cor padrão para o ícone da seção caso a categoria não tenha cor (ex: durante o carregamento inicial)
    final Color currentHabitOrCategoryColor = _selectedCategoryObject?.color ?? widget.habit.color;


    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nome do hábito
          _buildEditItem(
            icon: Icons.edit_note_outlined, // Ícone mais específico para nome/título
            iconColor: currentHabitOrCategoryColor,
            label: 'Nome do Hábito',
            child: TextFormField( // Usar TextFormField para validação
              controller: _titleController,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: AppTheme.inputDecoration(
                hintText: 'Ex: Ler 30 minutos',
              ).copyWith(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)), // Ajuste de padding
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'O nome do hábito não pode ser vazio.';
                }
                if (value.trim().length > 100) {
                  return 'O nome do hábito é muito longo.';
                }
                return null;
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Categoria
          _buildEditItem(
            icon: _selectedCategoryObject?.icon ?? Icons.category_outlined,
            iconColor: currentHabitOrCategoryColor,
            label: 'Categoria',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), // Ajuste de padding
              child: DropdownButtonFormField<String>(
                value: _selectedCategoryName,
                isExpanded: true,
                dropdownColor: AppTheme.surfaceColor,
                iconEnabledColor: Colors.white70,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: AppTheme.inputDecoration(hintText: '').copyWith(border: InputBorder.none, contentPadding: EdgeInsets.zero),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCategoryName = newValue;
                      _selectedCategoryObject = _availableCategories.firstWhere((cat) => cat.name == newValue);
                    });
                  }
                },
                items: _availableCategories.map((app_category.Category category) {
                  return DropdownMenuItem<String>(
                    value: category.name,
                    child: Row(
                      children: [
                        Icon(category.icon, color: category.color, size: 20),
                        const SizedBox(width: 12),
                        Text(category.name),
                      ],
                    ),
                  );
                }).toList(),
                validator: (value) => value == null ? 'Selecione uma categoria' : null,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Descrição
          _buildEditItem(
            icon: Icons.notes_outlined,
            iconColor: currentHabitOrCategoryColor,
            label: 'Descrição (Opcional)',
            child: TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Digite o nome do hábito',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Categoria
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              maxLines: 3,
              decoration: AppTheme.inputDecoration(
                hintText: 'Ex: Ler por 30 minutos antes de dormir...',
              ).copyWith(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
            ),
          ),

          const SizedBox(height: 20),

          // Horário e lembretes
          _buildEditItem(
            icon: Icons.notifications_active_outlined,
            iconColor: currentHabitOrCategoryColor,
            label: 'Lembrete',
            trailing: Switch(
              value: _hasReminder,
              onChanged: (value) {
                setState(() {
                  _hasReminder = value;
                  if (value && _reminderTime == null) {
                    // Define um horário padrão ou abre o seletor
                     _selectTime(context);
                  } else if (!value) {
                    _reminderTime = null;
                  }
                });
              },
              activeColor: currentHabitOrCategoryColor,
              inactiveTrackColor: Colors.grey[700],
            ),
            child: _hasReminder
                ? InkWell( // Mudar para InkWell para melhor feedback de toque
                    onTap: () => _selectTime(context),
                    child: Container(
                      width: double.infinity, // Para ocupar toda a largura disponível no child
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Text(
                        _reminderTime?.format(context) ?? 'Definir horário',
                        style: TextStyle(color: _reminderTime != null ? currentHabitOrCategoryColor : Colors.grey[500], fontSize: 16),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          
          const SizedBox(height: 16),
          
          // Prioridade

          const SizedBox(height: 20),

          // Prioridade
          _buildEditItem(
            icon: Icons.flag_circle_outlined,
            iconColor: currentHabitOrCategoryColor,
            label: 'Prioridade',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), // Ajuste de padding
              child: DropdownButtonFormField<String>(
                value: _selectedPriority,
                isExpanded: true,
                dropdownColor: AppTheme.surfaceColor,
                iconEnabledColor: Colors.white70,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: AppTheme.inputDecoration(hintText: '').copyWith(border: InputBorder.none, contentPadding: EdgeInsets.zero),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() => _selectedPriority = newValue);
                  }
                },
                items: _priorities.map((priority) {
                  Color priorityColor = Colors.grey[400]!;
                  if (priority == 'Alta') priorityColor = AppTheme.errorColor;
                  else if (priority == 'Normal') priorityColor = currentHabitOrCategoryColor;
                  else if (priority == 'Baixa') priorityColor = Colors.greenAccent;
                  
                  return DropdownMenuItem<String>(
                    value: priority,
                    child: Text(priority, style: TextStyle(color: priorityColor)),
                  );
                }).toList(),
                validator: (value) => value == null ? 'Selecione uma prioridade' : null,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Frequência (Apenas exibição, edição seria em outra tela)
          _buildEditItem(
            icon: Icons.event_repeat_outlined,
            iconColor: currentHabitOrCategoryColor,
            label: 'Frequência (Não editável aqui)',
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Text(
                _getFrequencyText(widget.habit), // Passar o hábito original para exibir sua frequência
                style: TextStyle(color: Colors.grey[500], fontSize: 16),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Data de início
          _buildEditItem(
            icon: Icons.calendar_today_outlined,
            iconColor: currentHabitOrCategoryColor,
            label: 'Data de Início',
            child: InkWell(
              onTap: () => _selectDate(context, false),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Text(
                  '${_startDate.day.toString().padLeft(2, '0')}/${_startDate.month.toString().padLeft(2, '0')}/${_startDate.year}',
                  style: TextStyle(color: currentHabitOrCategoryColor, fontSize: 16),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Data alvo
          _buildEditItem(
            icon: Icons.flag_outlined, // Ícone mais apropriado
            iconColor: currentHabitOrCategoryColor,
            label: 'Data Alvo (Opcional)',
            trailing: _targetDate != null ?
              IconButton(
                icon: Icon(Icons.clear, color: Colors.grey[500]),
                tooltip: "Remover data alvo",
                onPressed: () => setState(() => _targetDate = null),
              ) : null,
            child: InkWell(
                    onTap: () => _selectDate(context, true),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Text(
                        _targetDate != null
                          ? '${_targetDate!.day.toString().padLeft(2, '0')}/${_targetDate!.month.toString().padLeft(2, '0')}/${_targetDate!.year}'
                          : 'Não definida',
                        style: TextStyle(color: _targetDate != null ? currentHabitOrCategoryColor : Colors.grey[500], fontSize: 16),
                      ),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text(
                      '-',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ),
          ),
          
          const SizedBox(height: 32),
          
          // Botão salvar

          const SizedBox(height: 32),

          // Botão salvar
          ElevatedButton.icon(
            icon: const Icon(Icons.save_alt_outlined),
            label: const Text('Salvar Alterações'),
            style: AppTheme.primaryButton.copyWith(
              backgroundColor: MaterialStateProperty.all(currentHabitOrCategoryColor),
              padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 16)),
            ),
            onPressed: _isLoading ? null : _saveChanges,
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
            )
        ],
      ),
    );
  }
  
  Widget _buildEditItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required Widget child,
    Widget? trailing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Icon(icon, color: iconColor.withOpacity(0.8), size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTheme.textTheme.titleMedium?.copyWith(color: Colors.white70),
              ),
              const Spacer(),
              if (trailing != null) trailing,
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor, // Cor de fundo do campo
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[700]!, width: 0.5)
          ),
          child: child, // O child já deve ter seu próprio padding interno se necessário (como nos Dropdowns)
        ),
      ],
    );
  }
  
  // Este método agora recebe o hábito para exibir a frequência correta
  String _getFrequencyText(Habit habitForFrequencyDisplay) {
    switch (habitForFrequencyDisplay.frequency) {
      case HabitFrequency.daily:
        return 'Todos os dias';
      case HabitFrequency.weekly:
        if (habitForFrequencyDisplay.daysOfWeek != null && habitForFrequencyDisplay.daysOfWeek!.isNotEmpty) {
          // Para uma melhor UI, poderia converter os números dos dias para nomes
          return '${habitForFrequencyDisplay.daysOfWeek!.length}x por semana';
        }
        return 'Semanal';
      case HabitFrequency.monthly:
        if (habitForFrequencyDisplay.daysOfMonth != null && habitForFrequencyDisplay.daysOfMonth!.isNotEmpty) {
          if (habitForFrequencyDisplay.daysOfMonth!.contains(0)) return 'Último dia do mês';
          return 'Dias do mês: ${habitForFrequencyDisplay.daysOfMonth!.join(', ')}';
        }
        return 'Mensal';
      case HabitFrequency.specificDaysOfYear:
        return 'Datas específicas';
      case HabitFrequency.someTimesPerPeriod:
         return '${habitForFrequencyDisplay.timesPerPeriod ?? 'Algumas'} vezes por ${habitForFrequencyDisplay.periodType?.toLowerCase() ?? 'período'}';
      case HabitFrequency.repeat:
        if (habitForFrequencyDisplay.repeatEveryDays != null) {
          return 'A cada ${habitForFrequencyDisplay.repeatEveryDays} dias';
        }
        if (habitForFrequencyDisplay.alternateDays == true) {
          return 'Dias alternados';
        }
        return 'Repetido';
      default:
        return 'Frequência personalizada';
    }
  }
}

// Adicionando import que faltava para app_category.Category
// e para o Provider
import 'package:myapp/models/category.dart' as app_category;
import 'package:provider/provider.dart';
import 'package:myapp/services/category_service.dart';