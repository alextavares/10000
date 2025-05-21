import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; 
import 'package:myapp/models/habit.dart';
import 'package:myapp/services/service_provider.dart';
import 'package:myapp/services/habit_service.dart'; 
import 'package:myapp/widgets/habit_card.dart';
import 'package:myapp/screens/habit/add_habit_screen.dart';
import 'package:myapp/theme/app_theme.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  DateTime _selectedDate = DateTime.now(); 
  late List<DateTime> _weekDays;
  late int _currentDayIndexInWeek;
  late int _activelySelectedDayIndexInWeek;

  List<Habit> _habits = [];
  bool _isLoading = true;
  String? _errorMessage;

  late HabitService _habitService;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR', null);
    _generateWeekDays(DateTime.now());
    _selectedDate = DateTime.now(); 
    _activelySelectedDayIndexInWeek = _weekDays.indexWhere((day) => day.day == _selectedDate.day); 
    if (_activelySelectedDayIndexInWeek == -1 && _weekDays.isNotEmpty) {
      int todayIndex = _weekDays.indexWhere((d) => d.year == _selectedDate.year && d.month == _selectedDate.month && d.day == _selectedDate.day);
      if (todayIndex != -1) {
        _activelySelectedDayIndexInWeek = todayIndex;
      } else {
        _activelySelectedDayIndexInWeek = _weekDays.length > 2 ? _weekDays.length - 3 : 0; 
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) { 
        _habitService = ServiceProvider.of(context).habitService;
        _fetchHabits();
      }
    });
  }

  void _generateWeekDays(DateTime referenceDate) {
    _weekDays = [];
    DateTime startOfWeek = referenceDate.subtract(Duration(days: referenceDate.weekday - 1));
    for (int i = 0; i < 7; i++) {
      _weekDays.add(startOfWeek.add(Duration(days: i)));
    }
    _currentDayIndexInWeek = _weekDays.indexWhere((day) => 
        day.year == referenceDate.year && 
        day.month == referenceDate.month && 
        day.day == referenceDate.day);
    if (_currentDayIndexInWeek == -1 && _weekDays.isNotEmpty) {
        _currentDayIndexInWeek = 0; 
    }
    _activelySelectedDayIndexInWeek = _currentDayIndexInWeek;
  }

  Future<void> _fetchHabits() async {
    if (!mounted) return; 
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final habits = await _habitService.getHabits();
      if (mounted) { 
        setState(() {
          _habits = habits;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching habits: $e');
      if (mounted) { 
        setState(() {
          _errorMessage = "Failed to load habits: $e";
          _isLoading = false;
        });
      }
    }
  }

  void _selectDay(int index) {
    if (!mounted) return;
    setState(() {
      _activelySelectedDayIndexInWeek = index;
      _selectedDate = _weekDays[index];
      // Here you might want to re-fetch or filter habits based on the new _selectedDate
      // For now, it just updates the selected date UI
    });
  }
  
  Future<void> _toggleHabitCompletion(Habit habit, bool completed) async {
    if (!mounted) return;
    try {
      // Use the _selectedDate for marking completion, not DateTime.now()
      // This ensures completion is marked for the date visible in the calendar strip
      final dateToMark = _selectedDate; 
      bool success;
      if (completed) {
        success = await _habitService.markHabitCompleted(habit.id, dateToMark);
      } else {
        success = await _habitService.markHabitNotCompleted(habit.id, dateToMark);
      }
      if (success) {
        _fetchHabits(); // Refresh the habits list to show the updated state
      } else {
        if(mounted){
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update habit completion.')),
          );
        }
      }
    } catch (e) {
      print("Error toggling habit completion: $e");
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteHabit(String habitId) async {
    if (!mounted) return;
    final confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
            return AlertDialog(
                title: const Text('Confirm Delete'),
                content: const Text('Are you sure you want to delete this habit?'),
                actions: <Widget>[
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(false), 
                        child: const Text('Cancel'),
                    ),
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(true), 
                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                ],
            );
        },
    );

    if (confirm == true) {
        try {
            final success = await _habitService.deleteHabit(habitId);
            if (success) {
                _fetchHabits(); 
                 if(mounted){
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Habit deleted successfully.')),
                    );
                }
            } else {
                 if(mounted){
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to delete habit.')),
                    );
                }
            }
        } catch (e) {
            print("Error deleting habit: $e");
            if(mounted){
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                );
            }
        }
    }
  }

  Widget _buildDayWidget(BuildContext context, int index) {
    final DateTime day = _weekDays[index];
    final String dayAbbreviation = DateFormat('E', 'pt_BR').format(day).substring(0,3);
    final String dateNumber = DateFormat('d', 'pt_BR').format(day);
    
    bool isToday = day.year == DateTime.now().year && day.month == DateTime.now().month && day.day == DateTime.now().day;
    bool isActivelySelected = index == _activelySelectedDayIndexInWeek; 

    Color backgroundColor = Theme.of(context).cardColor; 
    Color textColor = AppTheme.subtitleColor;
    FontWeight fontWeight = FontWeight.normal;
    BoxBorder? border;

    if (isActivelySelected) {
        backgroundColor = AppTheme.primaryColor.withOpacity(0.8);
        textColor = Colors.white;
        fontWeight = FontWeight.bold;
    } else if (isToday) { 
        backgroundColor = AppTheme.primaryColor.withOpacity(0.3);
        textColor = AppTheme.primaryColor;
        fontWeight = FontWeight.bold;
        border = Border.all(color: AppTheme.primaryColor, width: 1.5);
    }

    return GestureDetector(
      onTap: () => _selectDay(index),
      child: Container(
        width: 50, 
        height: 70, 
        margin: const EdgeInsets.symmetric(horizontal: 4), 
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(25), 
          border: border,
          boxShadow: isActivelySelected ? [
            BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 5,
                spreadRadius: 1,
            )
          ] : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayAbbreviation.toUpperCase(),
              style: TextStyle(color: textColor, fontSize: 11, fontWeight: fontWeight),
            ),
            const SizedBox(height: 4),
            Text(
              dateNumber,
              style: TextStyle(color: textColor, fontSize: 16, fontWeight: fontWeight),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Changed Container to Scaffold
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical:8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor, 
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color:Colors.black.withOpacity(0.1), blurRadius: 5)]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_weekDays.isNotEmpty)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: List.generate(_weekDays.length, (index) {
                          return _buildDayWidget(context, index);
                        }),
                      ),
                    )
                  else 
                    const Center(child: Text("Carregando dias...", style: TextStyle(color: AppTheme.textColor))),
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(_errorMessage!, style: TextStyle(color: AppTheme.errorColor, fontSize: 16), textAlign: TextAlign.center,),
                        ),
                      )
                    : _habits.isEmpty
                        ? Center(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    Icon(Icons.list_alt_rounded, size: 80, color: AppTheme.subtitleColor.withOpacity(0.5)),
                                    const SizedBox(height:16),
                                    Text(
                                        'No habits yet.', 
                                        style: TextStyle(color: AppTheme.subtitleColor, fontSize: 18)
                                    ),
                                    const SizedBox(height:8),
                                    Text(
                                        'Tap the + button to add your first habit.',
                                        style: TextStyle(color: AppTheme.subtitleColor.withOpacity(0.7), fontSize: 14),
                                        textAlign: TextAlign.center,
                                    ),
                                ],
                            )
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80), 
                            itemCount: _habits.length,
                            itemBuilder: (context, index) {
                              final habit = _habits[index];
                              // Filter habits to show only those relevant for the _selectedDate
                              bool showHabit = false;
                              if (habit.frequency == HabitFrequency.daily) {
                                showHabit = true;
                              } else if (habit.frequency == HabitFrequency.weekly || habit.frequency == HabitFrequency.custom) {
                                if (habit.daysOfWeek != null && habit.daysOfWeek!.contains(_selectedDate.weekday)) {
                                  showHabit = true;
                                }
                              } else if (habit.frequency == HabitFrequency.monthly) {
                                if (habit.createdAt.day == _selectedDate.day) { // Simple monthly check by day of month
                                  showHabit = true;
                                }
                              }
                              // Add more complex logic if needed, e.g. for specific dates, etc.

                              if (!showHabit) {
                                return const SizedBox.shrink(); // Don't show the habit if it's not for today
                              }
                              return HabitCard(
                                habit: habit,
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddHabitScreen(habitToEdit: habit),
                                    ),
                                  );
                                  if (result == true && mounted) {
                                    _fetchHabits(); 
                                  }
                                },
                                onToggleCompletion: (completed) {
                                  _toggleHabitCompletion(habit, completed);
                                },
                                onDelete: () {
                                  _deleteHabit(habit.id);
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddHabitScreen()),
          );
          if (result == true && mounted) { // Check if a habit was added/updated
            _fetchHabits(); // Refresh the list
          }
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
