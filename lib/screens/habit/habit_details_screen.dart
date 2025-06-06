import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/services/habit_service.dart';
import 'package:myapp/services/ai_service.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/screens/loading_screen.dart';
import 'package:myapp/widgets/habit_card.dart';
import 'package:myapp/screens/habits/edit_habit_screen.dart';
import 'package:intl/intl.dart';
import 'package:myapp/utils/logger.dart';

/// Screen for viewing and managing a habit's details.
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

class _HabitDetailsScreenState extends State<HabitDetailsScreen> {
  bool _isLoading = true;
  Habit? _habit;
  String? _errorMessage;
  DateTime _currentMonth = DateTime.now();
  String? _aiInsights;
  bool _isLoadingInsights = false;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _statisticsKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadHabit();
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
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
      
      _loadAIInsights();
      
      // Scroll to statistics if requested
      if (widget.focusOnStats && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToStatistics();
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Falha ao carregar o hábito. Por favor, tente novamente.';
        _isLoading = false;
      });
      Logger.error('Error loading habit: $e');
    }
  }

  Future<void> _loadAIInsights() async {
    if (_habit == null || !mounted) return;

    setState(() {
      _isLoadingInsights = true;
    });

    try {
      final aiService = context.read<AIService>();
      final insights = await aiService.generateHabitInsights([_habit!]);
      
      if (!mounted) return;
      setState(() {
        _aiInsights = insights;
        _isLoadingInsights = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _aiInsights = 'Unable to load insights at this time.';
        _isLoadingInsights = false;
      });
      Logger.error('Error loading AI insights: $e');
    }
  }
  
  void _scrollToStatistics() {
    final RenderBox? renderBox = _statisticsKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && _scrollController.hasClients) {
      final position = renderBox.localToGlobal(Offset.zero, ancestor: _scrollController.position.context.storageContext.findRenderObject());
      _scrollController.animateTo(
        position.dy + _scrollController.offset - 100, // -100 for some padding from top
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _deleteHabit() async {
    if (_habit == null || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Hábito'),
        content: Text('Tem certeza que deseja excluir "${_habit!.title}"?'),
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
      _isLoading = true; // Can set a specific loading for delete if preferred
    });

    try {
      final notificationService = context.read<NotificationService>();
      final habitService = context.read<HabitService>();

      if (_habit!.notificationsEnabled && _habit!.reminderTime != null) {
        // It's better to pass the full habit object or at least its ID for cancellation.
        // Assuming cancelHabitReminder takes habit ID.
        await notificationService.cancelHabitReminder(_habit!); // Corrected: Passing the full _habit object
      }
      
      await habitService.deleteHabit(_habit!.id);
      
      if (mounted) {
        Navigator.pop(context, true); // Pop and signal success
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

  Future<void> _toggleDateCompletion(DateTime date) async {
    if (_habit == null || !mounted) return;

    final isCompleted = _habit!.completionHistory[date] ?? false;
    
    // Optimistically update UI or use a loading state for the specific date
    // For simplicity, full reload via _loadHabit() is used after operation.

    try {
      final habitService = context.read<HabitService>();
      // TODO: Verify if markHabitNotCompleted and markHabitCompleted exist and are used correctly.
      // Based on HabitService, it seems like there's a single markHabitCompletion(id, date, bool)
      // For now, assuming these methods exist or will be adapted in HabitService
      if (isCompleted) {
         await habitService.markHabitCompletion(widget.habitId, date, false); // Corrected: markHabitCompletion
      } else {
         await habitService.markHabitCompletion(widget.habitId, date, true); // Corrected: markHabitCompletion
      }
      
      if (mounted) await _loadHabit(); // Reload the habit to reflect changes
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to update habit completion: $e';
      });
      Logger.error('Error updating habit completion for date $date: $e');
    }
  }

  void _navigateToEditScreen() {
    if (_habit == null || !mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditHabitScreen(habit: _habit!))
    ).then((result) {
      if (result == true && mounted) {
        _loadHabit(); // Refresh if changes were made
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _habit == null) { // Show loading only if habit is not yet loaded
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhes do Hábito')), // Basic AppBar during load
        body: const LoadingScreenWithMessage(message: 'Carregando detalhes do hábito...'),
      );
    }

    if (_habit == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Erro'),
          backgroundColor: AppTheme.errorColor,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
                const SizedBox(height: 16),
                Text(_errorMessage ?? 'Hábito não encontrado ou não pôde ser carregado.',
                  style: TextStyle(fontSize: 16, color: AppTheme.textColor), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Voltar')),
              ],
            ),
          )
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_habit!.title, style: TextStyle(color: AppTheme.adaptiveTextColor(_habit!.color))), 
        backgroundColor: _habit!.color,
        iconTheme: IconThemeData(color: AppTheme.adaptiveTextColor(_habit!.color)), // For back button
        actionsIconTheme: IconThemeData(color: AppTheme.adaptiveTextColor(_habit!.color)), // For action icons
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note),
            onPressed: _navigateToEditScreen, // Navigate to edit screen
            tooltip: 'Editar Hábito',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteHabit,
            tooltip: 'Excluir Hábito',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadHabit,
        color: _habit!.color,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMessage != null && !_isLoading) // Show error only if not loading
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(_errorMessage!,
                    style: TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.bold)),
                ),

              HabitCard(
                habit: _habit!,
                onTap: _navigateToEditScreen, // Make the card itself also navigate to edit
                onToggleCompletion: (completed) async {
                  final today = DateTime.now();
                  final dateOnly = DateTime(today.year, today.month, today.day);
                  await _toggleDateCompletion(dateOnly); // Use _toggleDateCompletion for today
                },
                onDelete: _deleteHabit, // Added onDelete callback to card
              ),
              const SizedBox(height: 24),
              _buildStatisticsSection(),
              const SizedBox(height: 24),
              _buildCalendarSection(),
              const SizedBox(height: 24),
              _buildAIInsightsSection(),
              const SizedBox(height: 24),
              _buildActionsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsSection() { /* ... as before ... */ 
    return Column(
      key: _statisticsKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estatísticas',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.textColor),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildStatCard(
              title: 'Sequência Atual',
              value: '${_habit!.streak} dias',
              icon: Icons.local_fire_department,
              color: Colors.orange,
            ),
            _buildStatCard(
              title: 'Maior Sequência',
              value: '${_habit!.longestStreak} dias',
              icon: Icons.emoji_events,
              color: Colors.amber,
            ),
            _buildStatCard(
              title: 'Taxa de Conclusão',
              value: '${(_habit!.getCompletionRate() * 100).toStringAsFixed(1)}%',
              icon: Icons.pie_chart,
              color: Colors.green,
            ),
            _buildStatCard(
              title: 'Total de Conclusões',
              value: '${_habit!.completionHistory.values.where((v) => v).length}',
              icon: Icons.check_circle,
              color: _habit!.color,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [ BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)) ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.textColor, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.subtitleColor), textAlign: TextAlign.center),
        ],
      ),
    );
  }
  
  Widget _buildCalendarSection() { /* ... as before ... */ 
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Calendário de Progresso',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.textColor),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ?? AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [ BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)) ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      if (!mounted) return;
                      setState(() {
                        _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
                      });
                    },
                  ),
                  Text(DateFormat('MMMM yyyy', 'pt_BR').format(_currentMonth),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.textColor, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                       if (!mounted) return;
                      setState(() {
                        _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildCalendarGrid(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday; // Monday is 1, Sunday is 7
    final daysInMonth = lastDayOfMonth.day;
    final dayNames = DateFormat.EEEE('pt_BR').dateSymbols.SHORTWEEKDAYS;
     // Adjust for locale: SHORTWEEKDAYS might be [Sun, Mon, ...]. We want [Mon, Tue, ...]
    final adjustedDayNames = [...dayNames.sublist(1), dayNames[0]];

    List<Widget> dayCells = [];
    // Add day name headers
    for (String dayName in adjustedDayNames) {
      dayCells.add(Center(child: Text(dayName, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.subtitleColor, fontWeight: FontWeight.bold))));
    }

    // Add empty cells for padding before the first day of the month
    for (int i = 0; i < firstWeekday - 1; i++) { // -1 because our week starts on Monday in grid
      dayCells.add(Container());
    }

    // Add day cells for the month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final isTodayFlag = _isToday(date);
      final isCompleted = _habit!.completionHistory[DateTime(date.year, date.month, date.day)] ?? false;

      dayCells.add(
        GestureDetector(
          onTap: () => _toggleDateCompletion(date),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted ? _habit!.color.withValues(alpha: 0.8) : Colors.transparent,
              border: isTodayFlag ? Border.all(color: _habit!.color, width: 2) : Border.all(color: Colors.grey.withValues(alpha: 0.3), width: 0.5),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(day.toString(),
                style: TextStyle(
                  color: isCompleted ? AppTheme.adaptiveTextColor(_habit!.color.withValues(alpha: 0.8)) : AppTheme.textColor,
                  fontWeight: isTodayFlag ? FontWeight.bold : FontWeight.normal,
                )),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: dayCells,
    );
  }
  
  Widget _buildAIInsightsSection() { /* ... as before ... */ 
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Insights da IA', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.textColor)),
            IconButton(icon: const Icon(Icons.refresh), onPressed: _isLoadingInsights ? null : _loadAIInsights, tooltip: 'Atualizar Insights'),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ?? AppTheme.aiBackgroundColor, // Use card color or AI specific
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.aiPrimaryColor.withValues(alpha: 0.3)),
            boxShadow: [ BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)) ],
          ),
          padding: const EdgeInsets.all(16),
          child: _isLoadingInsights
              ? const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline, color: AppTheme.aiPrimaryColor, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(_aiInsights ?? 'Nenhum insight disponível ainda.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textColor, height: 1.5)),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
  
  Widget _buildActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ações',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.textColor),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ?? AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [ BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)) ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.refresh, color: Colors.orange),
                title: Text('Reiniciar o progresso do hábito', style: TextStyle(color: AppTheme.textColor)),
                subtitle: Text('Remove todo o histórico e estatísticas', style: TextStyle(color: AppTheme.subtitleColor, fontSize: 12)),
                trailing: Icon(Icons.chevron_right, color: AppTheme.subtitleColor),
                onTap: _resetHabitProgress,
                contentPadding: EdgeInsets.zero,
              ),
              Divider(color: AppTheme.subtitleColor.withValues(alpha: 0.2)),
              ListTile(
                leading: Icon(Icons.archive_outlined, color: AppTheme.primaryColor),
                title: Text('Arquivar hábito', style: TextStyle(color: AppTheme.textColor)),
                subtitle: Text('Move o hábito para o arquivo', style: TextStyle(color: AppTheme.subtitleColor, fontSize: 12)),
                trailing: Icon(Icons.chevron_right, color: AppTheme.subtitleColor),
                onTap: _archiveHabit,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Future<void> _resetHabitProgress() async {
    if (_habit == null || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reiniciar Progresso'),
        content: Text('Tem certeza que deseja reiniciar todo o progresso de "${_habit!.title}"? Esta ação não pode ser desfeita.'),
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
        await _loadHabit(); // Recarrega o hábito para mostrar as mudanças
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
  
  Future<void> _archiveHabit() async {
    // TODO: Implementar arquivamento de hábito
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade de arquivo em desenvolvimento')),
    );
  }
}

// Helper in AppTheme for adaptive text color on colored backgrounds
// Add this to your AppTheme class or a similar utility location
// static Color adaptiveTextColor(Color backgroundColor) {
//   return backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
// }
