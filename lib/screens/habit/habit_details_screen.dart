import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/services/habit_service.dart';
import 'package:myapp/services/ai_service.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/screens/loading_screen.dart';
import 'package:myapp/screens/habit/widgets/habit_calendar_tab.dart';
import 'package:myapp/screens/habit/widgets/habit_statistics_tab.dart';
import 'package:myapp/screens/habit/widgets/habit_edit_tab.dart';
import 'package:myapp/utils/logger.dart';

/// Screen for viewing and managing a habit's details with tabs.
class HabitDetailsScreen extends StatefulWidget {
  /// The ID of the habit to display.
  final String habitId;
  
  /// The initial tab index to display.
  /// 0: Calendário, 1: Editar, 2: Estatísticas
  final int initialTab;

  /// Constructor for HabitDetailsScreen.
  const HabitDetailsScreen({
    super.key,
    required this.habitId,
    this.initialTab = 0,
  });

  @override
  State<HabitDetailsScreen> createState() => _HabitDetailsScreenState();
}

class _HabitDetailsScreenState extends State<HabitDetailsScreen> 
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  Habit? _habit;
  String? _errorMessage;
  late TabController _tabController;
  bool _didHabitUpdate = false; // Flag para indicar se o hábito foi atualizado

  @override
  void initState() {
    super.initState();
    // Ordem das abas definida na UI: Calendário, Estatísticas, Editar
    // O initialTab vindo da HomeScreen (para "Editar") será 1.
    // No TabBar, "Editar" será o terceiro item, logo índice 2.
    // "Estatísticas" será o segundo item, índice 1.
    // "Calendário" é o primeiro, índice 0.

    int tabControllerInitialIndex = 0; // Padrão para Calendário
    if (widget.initialTab == 1) { // Se a intenção é "Editar" vindo da HomeScreen
      tabControllerInitialIndex = 2; // A aba "Editar" é a terceira (índice 2)
    } else if (widget.initialTab == 2) { // Se a intenção é "Estatísticas"
      tabControllerInitialIndex = 1; // A aba "Estatísticas" é a segunda (índice 1)
    }
    // Se initialTab for 0 (Calendário) ou outro valor, permanece 0.

    _tabController = TabController(
      length: 3, 
      vsync: this,
      initialIndex: tabControllerInitialIndex,
    );
    _loadHabit();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHabit() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final habitService = context.read<HabitService>();
      final habit = await habitService.getHabitById(widget.habitId);
      
      if (!mounted) return;
      if (habit == null) {
        setState(() {
          _errorMessage = 'Hábito não encontrado';
          _isLoading = false;
        });
        return;
      }
      
      setState(() {
        _habit = habit;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Falha ao carregar o hábito. Por favor, tente novamente.';
        _isLoading = false;
      });
      Logger.error('Error loading habit: $e');
    }
  }

  Future<void> _deleteHabit() async {
    if (_habit == null || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Excluir Hábito', style: TextStyle(color: Colors.white)),
        content: Text(
          'Tem certeza que deseja excluir "${_habit!.title}"?',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final notificationService = context.read<NotificationService>();
      final habitService = context.read<HabitService>();

      if (_habit!.notificationsEnabled && _habit!.reminderTime != null) {
        await notificationService.cancelHabitReminder(_habit!);
      }
      
      await habitService.deleteHabit(_habit!.id);
      
      if (mounted) {
        // Pop com true para indicar que a HomeScreen deve atualizar a lista
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to delete habit: $e';
        _isLoading = false;
      });
      Logger.error('Error deleting habit: $e');
    }
  }

  // Callback para ser chamado pelo HabitEditTab quando o hábito for salvo
  Future<void> _onHabitUpdatedFromEditTab() async {
    await _loadHabit(); // Recarrega os dados do hábito
    if (mounted) {
      setState(() {
        _didHabitUpdate = true; // Marca que houve atualização para o pop
      });
      // Opcional: Mover para a aba de calendário ou estatísticas após salvar
      // _tabController.animateTo(0);
    }
  }

  Future<void> _toggleDateCompletion(DateTime date, bool completed) async {
    if (_habit == null || !mounted) return;

    try {
      final habitService = context.read<HabitService>();
      await habitService.markHabitCompletion(widget.habitId, date, completed);
      
      if (mounted) {
        await _loadHabit(); // Recarrega o hábito para atualizar dados como streak, etc.
        setState(() {
          _didHabitUpdate = true; // Marcar que houve uma atualização
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to update habit completion: $e';
      });
      Logger.error('Error updating habit completion for date $date: $e');
    }
  }

  Future<void> _resetHabitProgress() async {
    if (_habit == null || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Reiniciar Progresso', style: TextStyle(color: Colors.white)),
        content: Text(
          'Tem certeza que deseja reiniciar todo o progresso de "${_habit!.title}"? Esta ação não pode ser desfeita.',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final habitService = context.read<HabitService>();
      await habitService.resetHabitProgress(_habit!.id);
      
      if (mounted) {
        await _loadHabit();
        setState(() {
          _didHabitUpdate = true; // Marcar que houve uma atualização
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Progresso do hábito reiniciado com sucesso')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Falha ao reiniciar progresso: $e';
        _isLoading = false;
      });
      Logger.error('Error resetting habit progress: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _habit == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundColor,
          title: const Text('Detalhes do Hábito'),
        ),
        body: const LoadingScreenWithMessage(message: 'Carregando detalhes do hábito...'),
      );
    }

    if (_habit == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundColor,
          title: const Text('Erro'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
                const SizedBox(height: 16),
                Text(
                  _errorMessage ?? 'Hábito não encontrado ou não pôde ser carregado.',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Voltar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          // Ao pressionar o botão voltar, retorna o status da atualização
          onPressed: () => Navigator.pop(context, _didHabitUpdate),
        ),
        title: Text(
          _habit!.title, // O título pode mudar após a edição
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: AppTheme.surfaceColor,
            onSelected: (value) async {
              switch (value) {
                case 'reset':
                  await _resetHabitProgress();
                  break;
                case 'archive':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Funcionalidade de arquivo em desenvolvimento')),
                  );
                  break;
                case 'delete':
                  await _deleteHabit();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: Colors.orange),
                    SizedBox(width: 12),
                    Text('Reiniciar progresso', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'archive',
                child: Row(
                  children: [
                    Icon(Icons.archive_outlined, color: Colors.blue),
                    SizedBox(width: 12),
                    Text('Arquivar', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Excluir hábito', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: _habit!.color, // A cor pode mudar se a categoria for alterada e a cor for dependente dela
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.calendar_today), text: 'Calendário'), // Índice 0
            Tab(icon: Icon(Icons.edit_note), text: 'Editar'),          // Índice 1
            Tab(icon: Icon(Icons.bar_chart), text: 'Estatísticas'),  // Índice 2
          ],
        ),
      ),
      body: WillPopScope( // Para interceptar o botão de voltar do sistema (Android)
        onWillPop: () async {
          Navigator.pop(context, _didHabitUpdate);
          return true; // Permite o pop
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            // Calendar Tab (Índice 0)
            HabitCalendarTab(
              habit: _habit!,
              onToggleCompletion: _toggleDateCompletion,
            ),

            // Edit Tab (Índice 1) - Corrigindo a ordem das abas na view
            HabitEditTab(
              habit: _habit!,
              onHabitUpdated: _onHabitUpdatedFromEditTab, // Usar o novo handler
            ),

            // Statistics Tab (Índice 2)
            HabitStatisticsTab(
              habit: _habit!,
            ),
          ],
        ),
      ),
    );
  }
}
