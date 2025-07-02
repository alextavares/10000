import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/models/category.dart' as app_category;
import 'package:myapp/models/habit.dart';
import 'package:myapp/services/category_service.dart';
import 'package:myapp/services/habit_service.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/utils/logger.dart';
import 'package:myapp/screens/categories/add_edit_category_screen.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart'; // Para DateFormat

// Adicionar flutter_duration_picker se for usar
// import 'package:flutter_duration_picker/flutter_duration_picker.dart';


class UpsertHabitScreen extends StatefulWidget {
  final Habit? habitToEdit;
  static const routeName = '/upsert-habit'; // Adicionando routeName

  const UpsertHabitScreen({super.key, this.habitToEdit});

  @override
  State<UpsertHabitScreen> createState() => _UpsertHabitScreenState();
}

class _UpsertHabitScreenState extends State<UpsertHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  // Controllers para campos de texto
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  // Estado para seletores
  app_category.Category? _selectedCategory;
  String _selectedPriority = 'Normal';
  HabitFrequency _selectedFrequency = HabitFrequency.daily;
  DateTime _startDate = DateTime.now();
  DateTime? _targetDate;
  bool _enableTargetDate = false;
  TimeOfDay? _reminderTime;
  bool _notificationsEnabled = false;

  List<int> _selectedDaysOfWeek = []; // Para frequência semanal
  List<int> _selectedDaysOfMonth = []; // Para frequência mensal
  // TODO: Adicionar campos para outros tipos de frequência (repeatEveryDays, etc.)

  HabitTrackingType _selectedTrackingType = HabitTrackingType.simOuNao;
  final TextEditingController _targetQuantityController = TextEditingController();
  final TextEditingController _quantityUnitController = TextEditingController();
  Duration? _targetTime; // Para tipo cronômetro
  List<HabitSubtask> _subtasks = []; // Para tipo lista de atividades
  final TextEditingController _subtaskController = TextEditingController();


  bool _isLoading = false;
  bool _isEditing = false;

  List<app_category.Category> _availableCategories = [];
  bool _categoriesLoading = true;

  final List<String> _priorityOptions = ['Baixa', 'Normal', 'Alta'];
  final Map<HabitFrequency, String> _frequencyDisplayNames = {
    HabitFrequency.daily: 'Diariamente',
    HabitFrequency.weekly: 'Semanalmente',
    HabitFrequency.monthly: 'Mensalmente',
    // Adicionar outros conforme necessário
  };
   final Map<HabitTrackingType, String> _trackingTypeDisplayNames = {
    HabitTrackingType.simOuNao: 'Sim ou Não',
    HabitTrackingType.quantia: 'Quantidade',
    HabitTrackingType.cronometro: 'Cronômetro',
    HabitTrackingType.listaAtividades: 'Lista de Atividades',
  };


  @override
  void initState() {
    super.initState();
    _isEditing = widget.habitToEdit != null;

    _titleController = TextEditingController(text: widget.habitToEdit?.title ?? '');
    _descriptionController = TextEditingController(text: widget.habitToEdit?.description ?? '');
    _selectedPriority = widget.habitToEdit?.priority ?? 'Normal';
    _selectedFrequency = widget.habitToEdit?.frequency ?? HabitFrequency.daily;
    _startDate = widget.habitToEdit?.startDate ?? DateTime.now();
    _targetDate = widget.habitToEdit?.targetDate;
    _enableTargetDate = _targetDate != null;
    _reminderTime = widget.habitToEdit?.reminderTime;
    _notificationsEnabled = widget.habitToEdit?.notificationsEnabled ?? (_reminderTime != null);

    _selectedDaysOfWeek = List<int>.from(widget.habitToEdit?.daysOfWeek ?? []);
    _selectedDaysOfMonth = List<int>.from(widget.habitToEdit?.daysOfMonth ?? []);

    _selectedTrackingType = widget.habitToEdit?.trackingType ?? HabitTrackingType.simOuNao;
    _targetQuantityController.text = widget.habitToEdit?.targetQuantity?.toString() ?? '';
    _quantityUnitController.text = widget.habitToEdit?.quantityUnit ?? '';
    _targetTime = widget.habitToEdit?.targetTime;
    _subtasks = widget.habitToEdit?.subtasks?.map((s) => s.copyWith()).toList() ?? [];

    // Inicializar categorias disponíveis com as padrões imediatamente
    _availableCategories = app_category.Category.defaultCategories;
    
    // Definir categoria selecionada inicial para evitar null
    if (_isEditing && widget.habitToEdit != null) {
      // Se estiver editando, tenta usar a categoria do hábito
      _selectedCategory = _availableCategories.firstWhere(
        (cat) => cat.name == widget.habitToEdit!.category,
        orElse: () => _availableCategories.first,
      );
    } else {
      // Se criando novo, usa "Outros" ou a primeira disponível
      _selectedCategory = _availableCategories.firstWhere(
        (cat) => cat.name.toLowerCase() == 'outros',
        orElse: () => _availableCategories.first,
      );
    }

    // Carregar categorias
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    // Use addPostFrameCallback para garantir que o contexto esteja pronto
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      setState(() => _categoriesLoading = true);
      try {
        final categoryService = Provider.of<CategoryService>(context, listen: false);
        _availableCategories = await categoryService.getCategories();
        
        // Atualizar a seleção de categoria após carregar
        if (_isEditing && widget.habitToEdit != null) {
          final categoryName = widget.habitToEdit!.category;
          _selectedCategory = _availableCategories.firstWhere(
            (cat) => cat.name == categoryName,
            orElse: () => _availableCategories.isNotEmpty ? _availableCategories.first : app_category.Category.defaultCategories.first,
          );
        } else {
          // Tenta pré-selecionar "Outros" ou a primeira se não estiver editando
          _selectedCategory = _availableCategories.firstWhere(
            (cat) => cat.name.toLowerCase() == 'outros',
            orElse: () => _availableCategories.isNotEmpty ? _availableCategories.first : app_category.Category.defaultCategories.first,
          );
        }
      } catch (e) {
        Logger.error("Error loading categories for UpsertHabitScreen: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao carregar categorias: $e')),
          );
          // Usar categorias padrão como fallback
          _availableCategories = app_category.Category.defaultCategories;
        }
      } finally {
        if (mounted) {
          setState(() => _categoriesLoading = false);
        }
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetQuantityController.dispose();
    _quantityUnitController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  Future<void> _saveHabit() async {
    Logger.debug('=== INICIANDO PROCESSO DE SALVAMENTO DE HÁBITO ===');
    
    if (!_formKey.currentState!.validate()) {
      Logger.warning('Formulário inválido');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, corrija os erros no formulário.')),
      );
      return;
    }
    
    // Verificar se uma categoria foi selecionada
    if (_selectedCategory == null) {
      Logger.warning('Nenhuma categoria selecionada');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione uma categoria.')),
      );
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione uma categoria.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    Logger.debug('Estado de loading ativado');

    // Validações específicas de Tracking Type
    if (_selectedTrackingType == HabitTrackingType.quantia && _targetQuantityController.text.trim().isEmpty) {
      Logger.warning('Meta de quantidade não definida');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, defina uma meta de quantidade.')),
      );
      setState(() => _isLoading = false);
      return;
    }
    if (_selectedTrackingType == HabitTrackingType.cronometro && _targetTime == null) {
       Logger.warning('Meta de tempo não definida');
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, defina uma meta de tempo.')),
      );
      setState(() => _isLoading = false);
      return;
    }
    if (_selectedTrackingType == HabitTrackingType.listaAtividades && _subtasks.isEmpty) {
       Logger.warning('Nenhuma subtarefa adicionada');
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, adicione pelo menos uma subtarefa.')),
      );
      setState(() => _isLoading = false);
      return;
    }
    if (_selectedFrequency == HabitFrequency.weekly && _selectedDaysOfWeek.isEmpty) {
      Logger.warning('Dias da semana não selecionados para frequência semanal');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione os dias da semana para a frequência semanal.')),
      );
      setState(() => _isLoading = false);
      return;
    }
    if (_selectedFrequency == HabitFrequency.monthly && _selectedDaysOfMonth.isEmpty) {
      Logger.warning('Dias do mês não definidos para frequência mensal');
      // Poderia adicionar uma validação mais específica para o formato dos dias do mês se necessário
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, defina os dias do mês para a frequência mensal.')),
      );
      setState(() => _isLoading = false);
      return;
    }


    final habitService = Provider.of<HabitService>(context, listen: false);
    final auth = FirebaseAuth.instance;
    final userId = auth.currentUser?.uid;
    
    Logger.debug('User ID: $userId');

    if (userId == null) {
        Logger.error("User ID is null, cannot save habit.");
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Erro: Usuário não autenticado.')));
            setState(() => _isLoading = false);
        }
        return;
    }

    final String habitId = _isEditing ? widget.habitToEdit!.id : _uuid.v4();
    Logger.debug('Habit ID: $habitId, isEditing: $_isEditing');
    
    if (_selectedCategory == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione uma categoria.')),
      );
      return;
    }

    final now = DateTime.now();
    
    Logger.debug('Construindo objeto Habit...');
    Logger.debug('- Title: ${_titleController.text.trim()}');
    Logger.debug('- Category: ${_selectedCategory!.name}');
    Logger.debug('- TrackingType: $_selectedTrackingType');
    Logger.debug('- Frequency: $_selectedFrequency');

    // Construir o hábito com base nos dados do formulário
    Habit habitData = Habit(
      id: habitId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
      category: _selectedCategory!.name,
      icon: _selectedCategory!.icon, // Pega o ícone da categoria selecionada
      color: _selectedCategory!.color, // Pega a cor da categoria selecionada
      priority: _selectedPriority,
      frequency: _selectedFrequency,
      daysOfWeek: _selectedFrequency == HabitFrequency.weekly ? _selectedDaysOfWeek : null,
      daysOfMonth: _selectedFrequency == HabitFrequency.monthly ? _selectedDaysOfMonth : null,
      startDate: _startDate,
      targetDate: _enableTargetDate ? _targetDate : null,
      reminderTime: _notificationsEnabled ? _reminderTime : null,
      notificationsEnabled: _notificationsEnabled,
      trackingType: _selectedTrackingType,
      targetQuantity: _selectedTrackingType == HabitTrackingType.quantia && _targetQuantityController.text.isNotEmpty
          ? double.tryParse(_targetQuantityController.text)
          : null,
      quantityUnit: _selectedTrackingType == HabitTrackingType.quantia ? _quantityUnitController.text.trim() : null,
      targetTime: _selectedTrackingType == HabitTrackingType.cronometro ? _targetTime : null,
      subtasks: _selectedTrackingType == HabitTrackingType.listaAtividades ? _subtasks : null,
      createdAt: _isEditing ? widget.habitToEdit!.createdAt : now,
      updatedAt: now,
      userId: userId,
      completionHistory: _isEditing ? widget.habitToEdit!.completionHistory : {},
      dailyProgress: _isEditing ? widget.habitToEdit!.dailyProgress : {},
      streak: _isEditing ? widget.habitToEdit!.streak : 0,
      longestStreak: _isEditing ? widget.habitToEdit!.longestStreak : 0,
      totalCompletions: _isEditing ? widget.habitToEdit!.totalCompletions : 0,
      // TODO: Adicionar outros campos como specificYearDates, timesPerPeriod, etc. se forem implementados na UI
    );
    
    Logger.debug('Objeto Habit criado com sucesso');

    try {
      Logger.debug('Iniciando salvamento no HabitService...');
      if (_isEditing) {
        Logger.debug('Atualizando hábito existente...');
        await habitService.updateHabit(habitData);
        Logger.info('Hábito atualizado com sucesso!');
      } else {
        Logger.debug('Criando novo hábito...');
        await habitService.addHabit(habitData);
        Logger.info('Hábito criado com sucesso!');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hábito "${habitData.title}" salvo com sucesso!')),
        );
        Navigator.of(context).pop(true); // Retorna true para indicar que a lista deve ser atualizada
      }
    } catch (e, stackTrace) {
      Logger.error('=== ERRO AO SALVAR HÁBITO ===');
      Logger.error('Erro: $e');
      Logger.error('Tipo do erro: ${e.runtimeType}');
      Logger.error('Stack trace:', e, stackTrace);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar hábito: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      Logger.debug('Finalizando processo de salvamento');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _navigateAndCreateCategory() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddEditCategoryScreen()),
    );
    if (result == true && mounted) {
      // Recarregar categorias e tentar manter a seleção se possível
      final previouslySelectedName = _selectedCategory?.name;
      await _loadCategories();
      if (previouslySelectedName != null) {
        _selectedCategory = _availableCategories.firstWhere(
            (cat) => cat.name == previouslySelectedName,
            orElse: () => _availableCategories.isNotEmpty ? _availableCategories.first : app_category.Category.defaultCategories.first);
      }
      setState(() {});
    }
  }


  @override
  Widget build(BuildContext context) {
    // Verificações de segurança
    if (_categoriesLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: Text(_isEditing ? 'Editar Hábito' : 'Novo Hábito'),
          backgroundColor: AppTheme.backgroundColor,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
      );
    }
    
    // Garantir que sempre há uma categoria selecionada
    if (_selectedCategory == null && _availableCategories.isNotEmpty) {
      _selectedCategory = _availableCategories.first;
    }
    
    // Se não há categorias disponíveis, mostrar erro
    if (_availableCategories.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: Text(_isEditing ? 'Editar Hábito' : 'Novo Hábito'),
          backgroundColor: AppTheme.backgroundColor,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Erro ao carregar categorias',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      );
    }
    
    try {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: Text(_isEditing ? 'Editar Hábito' : 'Novo Hábito', 
            style: AppTheme.textTheme.titleLarge ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
          ),
          backgroundColor: AppTheme.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Salvar Hábito',
            onPressed: _isLoading ? null : _saveHabit,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : Form(
              key: _formKey,
              child: ListView( // Usar ListView em vez de SingleChildScrollView para melhor performance com muitos campos
                padding: const EdgeInsets.all(16.0),
                children: <Widget>[
                  // Seção 1: Informações Básicas
                  _buildSectionTitle('Informações Básicas'),
                  TextFormField(
                    controller: _titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: AppTheme.inputDecoration(
                      labelText: 'Nome do Hábito',
                      hintText: 'Ex: Ler 30 minutos, Correr 5km',
                      prefixIcon: Icons.label_outline,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'O nome do hábito é obrigatório.';
                      }
                      if (value.trim().length > 100) {
                        return 'O nome do hábito não pode exceder 100 caracteres.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    style: const TextStyle(color: Colors.white),
                    decoration: AppTheme.inputDecoration(
                      labelText: 'Descrição (Opcional)',
                      hintText: 'Detalhes adicionais sobre o hábito',
                      prefixIcon: Icons.notes_outlined,
                    ),
                    maxLines: 3,
                    minLines: 1,
                  ),
                  const SizedBox(height: 16),
                  _buildCategorySelector(),
                  const SizedBox(height: 16),
                  _buildPrioritySelector(),

                  const SizedBox(height: 24),
                  _buildSectionTitle('Tipo de Monitoramento'),
                  _buildTrackingTypeSelector(),
                  if (_selectedTrackingType == HabitTrackingType.quantia) ...[
                    const SizedBox(height: 16),
                    _buildQuantityFields(),
                  ],
                  if (_selectedTrackingType == HabitTrackingType.cronometro) ...[
                     const SizedBox(height: 16),
                    _buildTimerFields(),
                  ],
                   if (_selectedTrackingType == HabitTrackingType.listaAtividades) ...[
                    const SizedBox(height: 16),
                    _buildSubtasksField(),
                  ],


                  const SizedBox(height: 24),
                  _buildSectionTitle('Frequência e Agendamento'),
                  _buildFrequencySelector(),

                  // Campos condicionais de frequência (ex: dias da semana)
                  if (_selectedFrequency == HabitFrequency.weekly) ...[
                    const SizedBox(height: 16),
                    _buildDaysOfWeekSelector(),
                  ],
                  if (_selectedFrequency == HabitFrequency.monthly) ...[
                    const SizedBox(height: 16),
                    _buildDaysOfMonthSelector(),
                  ],
                  // TODO: Adicionar UIs para outras frequências (specificDays, repeatEvery, etc.)

                  const SizedBox(height: 16),
                  _buildStartDatePicker(),
                  const SizedBox(height: 16),
                  _buildTargetDatePicker(),
                  const SizedBox(height: 16),
                  _buildReminderSelector(),

                  const SizedBox(height: 30),
                   ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: Text(_isEditing ? 'Salvar Alterações' : 'Criar Hábito'),
                    style: AppTheme.primaryButton.copyWith(
                        minimumSize: WidgetStateProperty.all(const Size(double.infinity, 50))),
                    onPressed: _isLoading ? null : _saveHabit,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
    } catch (e, stackTrace) {
      Logger.error('Error in UpsertHabitScreen build: $e', e, stackTrace);
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text('Erro ao carregar tela: $e', 
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
      child: Text(
        title,
        style: AppTheme.textTheme.titleMedium?.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCategorySelector() {
    if (_categoriesLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor, strokeWidth: 2),
      );
    }
    
    if (_availableCategories.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma categoria disponível',
          style: TextStyle(color: Colors.red),
        ),
      );
    }
    
    // Garantir que _selectedCategory não é null
    if (_selectedCategory == null && _availableCategories.isNotEmpty) {
      _selectedCategory = _availableCategories.first;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<app_category.Category>(
          value: _selectedCategory,
          items: _availableCategories.map((category) {
            return DropdownMenuItem<app_category.Category>(
              value: category,
              child: Row(
                children: [
                  Icon(category.icon, color: category.color, size: 20),
                  const SizedBox(width: 10),
                  Text(category.name, style: const TextStyle(color: Colors.white)),
                ],
              ),
            );
          }).toList(),
          onChanged: (app_category.Category? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedCategory = newValue;
              });
            }
          },
          validator: (value) {
            if (value == null) {
              return 'Por favor, selecione uma categoria';
            }
            return null;
          },
          decoration: AppTheme.inputDecoration(
            labelText: 'Categoria',
            prefixIcon: _selectedCategory?.icon ?? Icons.category_outlined,
            prefixIconColor: _selectedCategory?.color ?? Colors.grey,
          ),
          dropdownColor: AppTheme.surfaceColor,
          style: const TextStyle(color: Colors.white),
        ),
        TextButton.icon(
            icon: const Icon(Icons.add, size: 16, color: AppTheme.primaryColor),
            label: const Text('Criar nova categoria', style: TextStyle(color: AppTheme.primaryColor, fontSize: 13)),
            onPressed: _navigateAndCreateCategory,
        ),
      ],
    );
  }

  Widget _buildPrioritySelector() {
    return DropdownButtonFormField<String>(
      value: _selectedPriority,
      items: _priorityOptions.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedPriority = newValue;
          });
        }
      },
      decoration: AppTheme.inputDecoration(
        labelText: 'Prioridade',
        prefixIcon: Icons.flag_outlined,
      ),
      dropdownColor: AppTheme.surfaceColor,
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildFrequencySelector() {
    return DropdownButtonFormField<HabitFrequency>(
      value: _selectedFrequency,
      items: HabitFrequency.values.where((f) => f != HabitFrequency.custom && f != HabitFrequency.specificDaysOfYear && f != HabitFrequency.someTimesPerPeriod && f != HabitFrequency.repeat) // Simplificando por agora
          .map((HabitFrequency freq) {
        return DropdownMenuItem<HabitFrequency>(
          value: freq,
          child: Text(_frequencyDisplayNames[freq] ?? freq.toString().split('.').last, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
      onChanged: (HabitFrequency? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedFrequency = newValue;
            // Resetar seleções específicas de frequência ao mudar o tipo principal
            _selectedDaysOfWeek.clear();
            _selectedDaysOfMonth.clear();
          });
        }
      },
      decoration: AppTheme.inputDecoration(
        labelText: 'Frequência',
        prefixIcon: Icons.repeat_outlined,
      ),
      dropdownColor: AppTheme.surfaceColor,
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildDaysOfWeekSelector() {
    final List<String> dayNames = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
          child: Text('Selecionar dias da semana:', style: AppTheme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
        ),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: List<Widget>.generate(7, (int index) {
            final dayIndex = index + 1; // 1 for Monday, ..., 7 for Sunday
            final isSelected = _selectedDaysOfWeek.contains(dayIndex);
            return ChoiceChip(
              label: Text(dayNames[index]),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    _selectedDaysOfWeek.add(dayIndex);
                  } else {
                    _selectedDaysOfWeek.remove(dayIndex);
                  }
                  _selectedDaysOfWeek.sort();
                });
              },
              selectedColor: AppTheme.primaryColor,
              backgroundColor: AppTheme.surfaceColor,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70),
            );
          }).toList(),
        ),
         if (_selectedDaysOfWeek.isEmpty && _formKey.currentState?.validate() == false) // Apenas mostra erro se o form já foi submetido/validado
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Selecione pelo menos um dia para frequência semanal.',
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildDaysOfMonthSelector() {
    // Simples placeholder - uma UI mais elaborada seria necessária (ex: grid de números)
    return TextFormField(
      style: const TextStyle(color: Colors.white),
      decoration: AppTheme.inputDecoration(
        labelText: 'Dias do Mês (ex: 1, 15, 0 para último dia)',
        hintText: 'Separados por vírgula',
        prefixIcon: Icons.calendar_view_month_outlined,
      ),
      keyboardType: TextInputType.text,
      onChanged: (value) {
        setState(() {
          _selectedDaysOfMonth = value
              .split(',')
              .map((e) => int.tryParse(e.trim()))
              .where((e) => e != null && e >= 0 && e <= 31)
              .cast<int>()
              .toList();
        });
      },
      initialValue: _selectedDaysOfMonth.join(','),
    );
  }


  Widget _buildStartDatePicker() {
    return ListTile(
      leading: const Icon(Icons.calendar_today_outlined, color: AppTheme.primaryColor),
      title: Text('Data de Início', style: AppTheme.textTheme.bodyLarge?.copyWith(color: Colors.white)),
      subtitle: Text(DateFormat('dd/MM/yyyy').format(_startDate), style: TextStyle(color: Colors.grey[400])),
      tileColor: AppTheme.surfaceColor.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _startDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
          builder: (context, child) => Theme(data: AppTheme.datePickerTheme(context), child: child!),
        );
        if (picked != null && picked != _startDate) {
          setState(() {
            _startDate = picked;
            if (_targetDate != null && _targetDate!.isBefore(_startDate)) {
              _targetDate = _startDate.add(const Duration(days: 1)); // Garante que data alvo é após início
            }
          });
        }
      },
    );
  }

  Widget _buildTargetDatePicker() {
    return Column(
      children: [
        SwitchListTile(
          title: Text('Definir Data Alvo?', style: AppTheme.textTheme.bodyLarge?.copyWith(color: Colors.white)),
          value: _enableTargetDate,
          onChanged: (bool value) {
            setState(() {
              _enableTargetDate = value;
              if (!value) {
                _targetDate = null;
              } else _targetDate ??= _startDate.add(const Duration(days: 30));
            });
          },
          activeColor: AppTheme.primaryColor,
          tileColor: AppTheme.surfaceColor.withOpacity(0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        if (_enableTargetDate) ...[
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.flag_outlined, color: AppTheme.primaryColor),
            title: Text('Data Alvo', style: AppTheme.textTheme.bodyLarge?.copyWith(color: Colors.white)),
            subtitle: Text(
              _targetDate != null ? DateFormat('dd/MM/yyyy').format(_targetDate!) : 'Não definida',
              style: TextStyle(color: Colors.grey[400])
            ),
            tileColor: AppTheme.surfaceColor.withOpacity(0.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _targetDate ?? _startDate.add(const Duration(days: 1)),
                firstDate: _startDate.add(const Duration(days: 1)), // Data alvo deve ser após data de início
                lastDate: DateTime(2101),
                builder: (context, child) => Theme(data: AppTheme.datePickerTheme(context), child: child!),
              );
              if (picked != null && picked != _targetDate) {
                setState(() {
                  _targetDate = picked;
                });
              }
            },
          ),
        ]
      ],
    );
  }

  Widget _buildReminderSelector() {
    return Column(
      children: [
        SwitchListTile(
          title: Text('Ativar Lembrete', style: AppTheme.textTheme.bodyLarge?.copyWith(color: Colors.white)),
          value: _notificationsEnabled,
          onChanged: (bool value) {
            setState(() {
              _notificationsEnabled = value;
              if (value && _reminderTime == null) {
                _reminderTime = TimeOfDay.now(); // Default para agora se ativado e nulo
              } else if (!value) {
                _reminderTime = null;
              }
            });
          },
          activeColor: AppTheme.primaryColor,
          tileColor: AppTheme.surfaceColor.withOpacity(0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        if (_notificationsEnabled) ...[
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.alarm_outlined, color: AppTheme.primaryColor),
            title: Text('Horário do Lembrete', style: AppTheme.textTheme.bodyLarge?.copyWith(color: Colors.white)),
            subtitle: Text(
              _reminderTime?.format(context) ?? 'Não definido',
              style: TextStyle(color: Colors.grey[400])
            ),
            tileColor: AppTheme.surfaceColor.withOpacity(0.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            onTap: () async {
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: _reminderTime ?? TimeOfDay.now(),
                builder: (context, child) => Theme(data: AppTheme.timePickerTheme(context), child: child!),
              );
              if (picked != null && picked != _reminderTime) {
                setState(() {
                  _reminderTime = picked;
                });
              }
            },
          ),
        ]
      ],
    );
  }

  Widget _buildTrackingTypeSelector() {
    return DropdownButtonFormField<HabitTrackingType>(
      value: _selectedTrackingType,
      items: HabitTrackingType.values.map((HabitTrackingType type) {
        return DropdownMenuItem<HabitTrackingType>(
          value: type,
          child: Text(_trackingTypeDisplayNames[type] ?? type.toString().split('.').last, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
      onChanged: (HabitTrackingType? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedTrackingType = newValue;
          });
        }
      },
      decoration: AppTheme.inputDecoration(
        labelText: 'Tipo de Monitoramento',
        prefixIcon: Icons.rule_outlined,
      ),
      dropdownColor: AppTheme.surfaceColor,
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildQuantityFields() {
    return Column(
      children: [
        TextFormField(
          controller: _targetQuantityController,
          style: const TextStyle(color: Colors.white),
          decoration: AppTheme.inputDecoration(
            labelText: 'Meta de Quantidade',
            hintText: 'Ex: 8 (copos), 50 (páginas)',
            prefixIcon: Icons.format_list_numbered_outlined,
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (_selectedTrackingType == HabitTrackingType.quantia && (value == null || value.isEmpty)) {
              return 'Defina a meta.';
            }
            if (value != null && double.tryParse(value) == null) {
              return 'Número inválido.';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _quantityUnitController,
          style: const TextStyle(color: Colors.white),
          decoration: AppTheme.inputDecoration(
            labelText: 'Unidade (Opcional)',
            hintText: 'Ex: copos, km, páginas',
            prefixIcon: Icons.straighten_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildTimerFields() {
    return ListTile(
      leading: const Icon(Icons.timer_outlined, color: AppTheme.primaryColor),
      title: Text('Meta de Tempo', style: AppTheme.textTheme.bodyLarge?.copyWith(color: Colors.white)),
      subtitle: Text(
        _targetTime != null ? '${_targetTime!.inMinutes} minutos' : 'Não definida',
         style: TextStyle(color: Colors.grey[400])
      ),
      tileColor: AppTheme.surfaceColor.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () async {
        // Usar um seletor de duração simples ou campos de texto para horas/minutos
        final Duration? picked = await showDialog<Duration>(
          context: context,
          builder: (BuildContext context) {
            // Um seletor de duração simples
            int hours = _targetTime?.inHours ?? 0;
            int minutes = _targetTime?.inMinutes.remainder(60) ?? 30;
            return AlertDialog(
              backgroundColor: AppTheme.surfaceColor,
              title: const Text('Definir Meta de Tempo', style: TextStyle(color: Colors.white)),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(
                    width: 60,
                    child: TextField(
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      textAlign: TextAlign.center,
                      decoration: AppTheme.inputDecoration(labelText: "Horas"),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      controller: TextEditingController(text: hours.toString()),
                      onChanged: (val) => hours = int.tryParse(val) ?? 0,
                    ),
                  ),
                  const Text(":", style: TextStyle(fontSize: 20, color: Colors.white)),
                   SizedBox(
                    width: 60,
                    child: TextField(
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      textAlign: TextAlign.center,
                      decoration: AppTheme.inputDecoration(labelText: "Min"),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      controller: TextEditingController(text: minutes.toString()),
                      onChanged: (val) => minutes = int.tryParse(val) ?? 0,
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                  onPressed: () => Navigator.of(context).pop(null),
                ),
                ElevatedButton(
                  style: AppTheme.primaryButton,
                  child: const Text('OK'),
                  onPressed: () => Navigator.of(context).pop(Duration(hours: hours, minutes: minutes)),
                ),
              ],
            );
          },
        );
        if (picked != null) {
          setState(() {
            _targetTime = picked;
          });
        }
      },
    );
  }

  Widget _buildSubtasksField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _subtaskController,
          style: const TextStyle(color: Colors.white),
          decoration: AppTheme.inputDecoration(
            labelText: 'Nova Subtarefa',
            hintText: 'Ex: Ler capítulo 1',
            prefixIcon: Icons.playlist_add_outlined,
          ).copyWith(
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryColor),
              onPressed: () {
                if (_subtaskController.text.trim().isNotEmpty) {
                  setState(() {
                    _subtasks.add(HabitSubtask(id: _uuid.v4(), title: _subtaskController.text.trim()));
                    _subtaskController.clear();
                  });
                }
              },
            )
          ),
        ),
        const SizedBox(height: 10),
        if (_subtasks.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8)
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _subtasks.length,
              itemBuilder: (context, index) {
                final subtask = _subtasks[index];
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.check_box_outline_blank, color: Colors.grey[400], size: 20),
                  title: Text(subtask.title, style: TextStyle(color: Colors.white70)),
                  trailing: IconButton(
                    icon: Icon(Icons.remove_circle_outline, color: Colors.red[300], size: 20),
                    onPressed: () {
                      setState(() {
                        _subtasks.removeAt(index);
                      });
                    },
                  ),
                );
              },
            ),
          ),
        if (_selectedTrackingType == HabitTrackingType.listaAtividades && _subtasks.isEmpty && _formKey.currentState?.validate() == false)
           Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Adicione pelo menos uma subtarefa.',
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
            ),
          ),
      ],
    );
  }

}

// Helper para temas de DatePicker e TimePicker
extension AppThemePickers on AppTheme {
  static ThemeData datePickerTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      colorScheme: ColorScheme.dark(
        primary: AppTheme.primaryColor, // Cor principal do seletor
        onPrimary: Colors.white,      // Cor do texto sobre a cor principal
        surface: AppTheme.surfaceColor, // Cor de fundo do diálogo
        onSurface: Colors.white,      // Cor do texto no diálogo
      ), dialogTheme: DialogThemeData(backgroundColor: AppTheme.backgroundColor),
    );
  }

  static ThemeData timePickerTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      colorScheme: ColorScheme.dark(
        primary: AppTheme.primaryColor,
        onPrimary: Colors.white,
        surface: AppTheme.surfaceColor,
        onSurface: Colors.white,
        secondary: AppTheme.primaryColor, // Cor do relógio e botões
        onSecondary: Colors.white,
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: AppTheme.surfaceColor,
        hourMinuteTextColor: Colors.white,
        hourMinuteColor: Colors.grey[800],
        dayPeriodTextColor: Colors.white,
        dayPeriodColor: Colors.grey[700],
        dialHandColor: AppTheme.primaryColor,
        dialBackgroundColor: Colors.grey[800],
        entryModeIconColor: AppTheme.primaryColor,
      ), dialogTheme: DialogThemeData(backgroundColor: AppTheme.backgroundColor)
    );
  }
}