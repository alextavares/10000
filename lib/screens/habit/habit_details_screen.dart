import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/services/habit_service.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/screens/loading_screen.dart';
import 'package:myapp/screens/habit/widgets/habit_calendar_tab.dart';
import 'package:myapp/screens/habit/widgets/habit_statistics_tab.dart';
// import 'package:myapp/screens/habit/widgets/habit_edit_tab.dart'; // Removido
import 'package:myapp/screens/habit/upsert_habit_screen.dart'; // Adicionado
import 'package:myapp/utils/logger.dart';

/// Screen for viewing and managing a habit's details with tabs.
class HabitDetailsScreen extends StatefulWidget {
  /// The ID of the habit to display.
  final String habitId;
  
  /// The initial tab index to display.
  /// 0: Calendário, 1: Estatísticas (anteriormente Editar era 1, Estatísticas 2)
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
    // Nova ordem das abas: Calendário (0), Estatísticas (1)
    // O initialTab da HomeScreen para "Editar" não é mais usado para setar aba aqui,
    // pois a edição agora é uma navegação separada.
    // Se initialTab for 1, focará em Estatísticas.

    int tabControllerInitialIndex = widget.initialTab == 1 ? 1 : 0;

    _tabController = TabController(
      length: 2, // Apenas duas abas agora: Calendário e Estatísticas
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
  // Este método não é mais necessário aqui, pois a edição é feita em UpsertHabitScreen
  // Future<void> _onHabitUpdatedFromEditTab() async {
  //   await _loadHabit(); // Recarrega os dados do hábito
  //   if (mounted) {
  //     setState(() {
  //       _didHabitUpdate = true; // Marca que houve atualização para o pop
  //     });
  //     // Opcional: Mover para a aba de calendário ou estatísticas após salvar
  //     // _tabController.animateTo(0);
  //   }
  // }

  Future<void> _navigateToEditHabit() async {
    if (_habit == null) return;
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UpsertHabitScreen(habitToEdit: _habit!),
      ),
    );
    if (result == true && mounted) {
      _loadHabit(); // Recarrega os dados do hábito após a edição
      setState(() {
        _didHabitUpdate = true;
      });
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
          _habit!.title,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar Hábito',
            onPressed: _navigateToEditHabit,
          ),
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
                    Icon(Icons.refresh, color: Colors.orangeAccent),
                    SizedBox(width: 12),
                    Text('Reiniciar progresso', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'archive',
                child: Row(
                  children: [
                    Icon(Icons.archive_outlined, color: Colors.blueAccent),
                    SizedBox(width: 12),
                    Text('Arquivar', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: AppTheme.errorColor),
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
          indicatorColor: _habit!.color,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[600],
          tabs: const [
            Tab(icon: Icon(Icons.calendar_today_outlined), text: 'Calendário'), // Índice 0
            // Tab(icon: Icon(Icons.edit_note), text: 'Editar'), // Removida
            Tab(icon: Icon(Icons.bar_chart_outlined), text: 'Estatísticas'),  // Agora Índice 1
          ],
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, _didHabitUpdate);
          return true;
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            // Calendar Tab (Índice 0)
            HabitCalendarTab(
              habit: _habit!,
              onToggleCompletion: _toggleDateCompletion,
            ),

            // Statistics Tab (Índice 1)
            HabitStatisticsTab(),
          ],
        ),
      ),
    );
  }
}
