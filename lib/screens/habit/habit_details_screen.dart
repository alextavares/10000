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
  
  /// Whether to focus on statistics section
  final bool focusOnStats;

  /// Constructor for HabitDetailsScreen.
  const HabitDetailsScreen({
    super.key,
    required this.habitId,
    this.focusOnStats = false,
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3, 
      vsync: this,
      initialIndex: widget.focusOnStats ? 1 : 0, // Start on stats tab if requested
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

  Future<void> _toggleDateCompletion(DateTime date, bool completed) async {
    if (_habit == null || !mounted) return;

    try {
      final habitService = context.read<HabitService>();
      await habitService.markHabitCompletion(widget.habitId, date, completed);
      
      if (mounted) await _loadHabit();
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _habit!.title,
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
          indicatorColor: _habit!.color,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Calendário'),
            Tab(text: 'Estatísticas'),
            Tab(text: 'Editar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Calendar Tab
          HabitCalendarTab(
            habit: _habit!,
            onToggleCompletion: _toggleDateCompletion,
          ),
          
          // Statistics Tab
          HabitStatisticsTab(
            habit: _habit!,
          ),
          
          // Edit Tab
          HabitEditTab(
            habit: _habit!,
            onHabitUpdated: _loadHabit,
          ),
        ],
      ),
    );
  }
}
