import 'package:flutter/material.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/services/service_provider.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/screens/loading_screen.dart';
import 'package:myapp/widgets/habit_card.dart';
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

  /// Loads the habit data.
  Future<void> _loadHabit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final habit = await context.habitService.getHabit(widget.habitId);
      
      if (habit == null) {
        setState(() {
          _errorMessage = 'Habit not found';
          _isLoading = false;
        });
        return;
      }
      
      // Create a local variable to store the completion history entries
      final completionEntries = habit.completionHistory.entries
          .where((entry) => entry.value == true)
          .map((entry) => entry.key)
          .toList();
      
      setState(() {
        _habit = habit;
        _isLoading = false;
      });
      
      // Load AI insights
      _loadAIInsights();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load habit. Please try again.';
        _isLoading = false;
      });
      print('Error loading habit: $e');
    }
  }

  /// Loads AI insights for the habit.
  Future<void> _loadAIInsights() async {
    if (_habit == null) return;

    setState(() {
      _isLoadingInsights = true;
    });

    try {
      final insights = await context.aiService.generateHabitInsights([_habit!]);
      
      setState(() {
        _aiInsights = insights;
        _isLoadingInsights = false;
      });
    } catch (e) {
      setState(() {
        _aiInsights = 'Unable to load insights at this time.';
        _isLoadingInsights = false;
      });
      print('Error loading AI insights: $e');
    }
  }

  /// Deletes the habit.
  Future<void> _deleteHabit() async {
    if (_habit == null) return;

    // Show confirmation dialog
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

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Cancel notifications
      if (_habit!.notificationsEnabled) {
        await context.notificationService.cancelHabitReminder(_habit!);
      }
      
      // Delete the habit
      await context.habitService.deleteHabit(_habit!.id);
      
      // Return to previous screen
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to delete habit: $e';
        _isLoading = false;
      });
      print('Error deleting habit: $e');
    }
  }

  /// Toggles the completion status for a date.
  Future<void> _toggleDateCompletion(DateTime date) async {
    if (_habit == null) return;

    final isCompleted = _habit!.completionHistory[date] ?? false;
    
    setState(() {
      _isLoading = true;
    });

    try {
      if (isCompleted) {
        await context.habitService.markHabitNotCompleted(
          _habit!.id,
          date,
        );
      } else {
        await context.habitService.markHabitCompleted(
          _habit!.id,
          date,
        );
      }
      
      // Reload the habit
      await _loadHabit();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update habit: $e';
        _isLoading = false;
      });
      print('Error updating habit: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingScreenWithMessage(
        message: 'Loading habit details...',
      );
    }

    if (_habit == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Habit Details'),
          backgroundColor: AppTheme.primaryColor,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'Habit not found',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_habit!.title),
        backgroundColor: _habit!.color,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
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
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: AppTheme.errorColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              // Habit card
              HabitCard(
                habit: _habit!,
                onTap: () {}, // No action needed since we're already in the details screen
                onToggleCompletion: (completed) async {
                  try {
                    if (completed) {
                      await context.habitService.markHabitCompleted(
                        _habit!.id,
                        DateTime.now(),
                      );
                    } else {
                      await context.habitService.markHabitNotCompleted(
                        _habit!.id,
                        DateTime.now(),
                      );
                    }
                    _loadHabit();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error updating habit: $e'),
                        backgroundColor: AppTheme.errorColor,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 24),

              // Statistics section
              _buildStatisticsSection(),
              const SizedBox(height: 24),

              // Calendar section
              _buildCalendarSection(),
              const SizedBox(height: 24),

              // AI Insights section
              _buildAIInsightsSection(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the statistics section.
  Widget _buildStatisticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // Current streak card
            _buildStatCard(
              title: 'Current Streak',
              value: '${_habit!.streak} days',
              icon: Icons.local_fire_department,
              color: Colors.orange,
            ),

            // Longest streak card
            _buildStatCard(
              title: 'Longest Streak',
              value: '${_habit!.longestStreak} days',
              icon: Icons.emoji_events,
              color: Colors.amber,
            ),

            // Completion rate card
            _buildStatCard(
              title: 'Completion Rate',
              value: '${(_habit!.getCompletionRate() * 100).toStringAsFixed(1)}%',
              icon: Icons.pie_chart,
              color: Colors.green,
            ),

            // Total completions card
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

  /// Builds a statistics card.
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.subtitleColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Builds the calendar section.
  Widget _buildCalendarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Calendar',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Month navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      setState(() {
                        _currentMonth = DateTime(
                          _currentMonth.year,
                          _currentMonth.month - 1,
                          1,
                        );
                      });
                    },
                  ),
                  Text(
                    DateFormat('MMMM yyyy').format(_currentMonth),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      setState(() {
                        _currentMonth = DateTime(
                          _currentMonth.year,
                          _currentMonth.month + 1,
                          1,
                        );
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Calendar grid
              _buildCalendarGrid(),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the calendar grid.
  Widget _buildCalendarGrid() {
    // Get the first day of the month
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    
    // Get the last day of the month
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    
    // Get the weekday of the first day (0 = Monday, 6 = Sunday)
    final firstWeekday = firstDay.weekday;
    
    // Calculate the number of days to display
    final daysInMonth = lastDay.day;
    
    // Calculate the number of rows needed
    final rowCount = ((firstWeekday - 1 + daysInMonth) / 7).ceil();
    
    // Day names
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      children: [
        // Day names row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: dayNames.map((day) {
            return SizedBox(
              width: 32,
              child: Text(
                day,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.subtitleColor,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),

        // Calendar days
        for (int row = 0; row < rowCount; row++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (col) {
                final dayIndex = row * 7 + col - (firstWeekday - 1);
                
                if (dayIndex < 0 || dayIndex >= daysInMonth) {
                  // Empty cell
                  return const SizedBox(width: 32);
                }
                
                final day = dayIndex + 1;
                final date = DateTime(_currentMonth.year, _currentMonth.month, day);
                final isToday = _isToday(date);
                final isCompleted = _habit!.completionHistory[date] ?? false;
                
                return GestureDetector(
                  onTap: () => _toggleDateCompletion(date),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCompleted ? _habit!.color : Colors.transparent,
                      border: isToday
                          ? Border.all(color: _habit!.color, width: 2)
                          : null,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        day.toString(),
                        style: TextStyle(
                          color: isCompleted ? Colors.white : AppTheme.textColor,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  /// Builds the AI insights section.
  Widget _buildAIInsightsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'AI Insights',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _isLoadingInsights ? null : _loadAIInsights,
              tooltip: 'Refresh Insights',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: _isLoadingInsights
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: AppTheme.aiPrimaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _aiInsights ?? 'No insights available yet.',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textColor,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  /// Checks if a date is today.
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
