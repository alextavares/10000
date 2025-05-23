import 'package:flutter/material.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/services/service_provider.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/screens/loading_screen.dart';
import 'package:myapp/widgets/habit_card.dart';
import 'package:myapp/screens/habit/add_habit_screen.dart'; // Import AddHabitScreen
import 'package:intl/intl.dart';

/// Screen for viewing and managing a habit's details.
class HabitDetailsScreen extends StatefulWidget {
  /// The ID of the habit to display.
  final String habitId;

  /// Constructor for HabitDetailsScreen.
  const HabitDetailsScreen({
    super.key,
    required this.habitId,
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

  @override
  void initState() {
    super.initState();
    _loadHabit();
  }

  Future<void> _loadHabit() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final habitService = ServiceProvider.of(context).habitService; // Use ServiceProvider
      final habit = await habitService.getHabitById(widget.habitId);
      
      if (!mounted) return;
      if (habit == null) {
        setState(() {
          _errorMessage = 'Habit not found';
          _isLoading = false;
        });
        return;
      }
      
      setState(() {
        _habit = habit;
        _isLoading = false;
      });
      
      _loadAIInsights();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load habit. Please try again.';
        _isLoading = false;
      });
      print('Error loading habit: $e');
    }
  }

  Future<void> _loadAIInsights() async {
    if (_habit == null || !mounted) return;

    setState(() {
      _isLoadingInsights = true;
    });

    try {
      final aiService = ServiceProvider.of(context).aiService; // Use ServiceProvider
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
      print('Error loading AI insights: $e');
    }
  }

  Future<void> _deleteHabit() async {
    if (_habit == null || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text('Are you sure you want to delete "${_habit!.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isLoading = true; // Can set a specific loading for delete if preferred
    });

    try {
      final notificationService = ServiceProvider.of(context).notificationService;
      final habitService = ServiceProvider.of(context).habitService;

      if (_habit!.notificationsEnabled && _habit!.reminderTime != null) {
        // It's better to pass the full habit object or at least its ID for cancellation.
        // Assuming cancelHabitReminder takes habit ID.
        await notificationService.cancelHabitReminder(_habit!.id);
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
      print('Error deleting habit: $e');
    }
  }

  Future<void> _toggleDateCompletion(DateTime date) async {
    if (_habit == null || !mounted) return;

    final isCompleted = _habit!.completionHistory[date] ?? false;
    
    // Optimistically update UI or use a loading state for the specific date
    // For simplicity, full reload via _loadHabit() is used after operation.

    try {
      final habitService = ServiceProvider.of(context).habitService;
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
      print('Error updating habit completion for date $date: $e');
    }
  }

  void _navigateToEditScreen() {
    if (_habit == null || !mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddHabitScreen(habitToEdit: _habit!))
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
        appBar: AppBar(title: const Text('Habit Details')), // Basic AppBar during load
        body: const LoadingScreenWithMessage(message: 'Loading habit details...'),
      );
    }

    if (_habit == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
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
                Text(_errorMessage ?? 'Habit not found or could not be loaded.',
                  style: TextStyle(fontSize: 16, color: AppTheme.textColor), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Go Back')),
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
            tooltip: 'Edit Habit',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteHabit,
            tooltip: 'Delete Habit',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadHabit,
        color: _habit!.color,
        child: SingleChildScrollView(
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsSection() { /* ... as before ... */ 
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistics',
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
              title: 'Current Streak',
              value: '${_habit!.streak} days',
              icon: Icons.local_fire_department,
              color: Colors.orange,
            ),
            _buildStatCard(
              title: 'Longest Streak',
              value: '${_habit!.longestStreak} days',
              icon: Icons.emoji_events,
              color: Colors.amber,
            ),
            _buildStatCard(
              title: 'Completion Rate',
              value: '${(_habit!.getCompletionRate() * 100).toStringAsFixed(1)}%',
              icon: Icons.pie_chart,
              color: Colors.green,
            ),
            _buildStatCard(
              title: 'Total Completions',
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
        boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)) ],
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
          'Progress Calendar',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.textColor),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ?? AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)) ],
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
              color: isCompleted ? _habit!.color.withOpacity(0.8) : Colors.transparent,
              border: isTodayFlag ? Border.all(color: _habit!.color, width: 2) : Border.all(color: Colors.grey.withOpacity(0.3), width: 0.5),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(day.toString(),
                style: TextStyle(
                  color: isCompleted ? AppTheme.adaptiveTextColor(_habit!.color.withOpacity(0.8)) : AppTheme.textColor,
                  fontWeight: isTodayFlag ? FontWeight.bold : FontWeight.normal,
                )),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
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
            Text('AI Insights', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.textColor)),
            IconButton(icon: const Icon(Icons.refresh), onPressed: _isLoadingInsights ? null : _loadAIInsights, tooltip: 'Refresh Insights'),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ?? AppTheme.aiBackgroundColor, // Use card color or AI specific
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.aiPrimaryColor.withOpacity(0.3)),
            boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)) ],
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
                      child: Text(_aiInsights ?? 'No insights available yet.',
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
}

// Helper in AppTheme for adaptive text color on colored backgrounds
// Add this to your AppTheme class or a similar utility location
// static Color adaptiveTextColor(Color backgroundColor) {
//   return backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
// }
