import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:myapp/models/habit.dart' as habit_model;
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

  List<habit_model.Habit> _habits = [];
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
    print('[HabitsScreen] Fetching habits...');
    try {
      final habits = await _habitService.getHabits();
      if (mounted) { 
        print('[HabitsScreen] Habits fetched. Count: ${habits.length}');
        if (habits.isNotEmpty) {
          for (int i = 0; i < (habits.length > 2 ? 2 : habits.length); i++) { // Print details of first 2 habits
            print('[HabitsScreen] Habit ${i+1}: ${habits[i].title}, Freq: ${habits[i].frequency}, DaysOfWeek: ${habits[i].daysOfWeek}, DaysOfMonth: ${habits[i].daysOfMonth}, CreatedAt: ${habits[i].createdAt.toIso8601String()}, Tracking: ${habits[i].trackingType}');
          }
        }
        setState(() {
          _habits = habits;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('[HabitsScreen] Error fetching habits: $e');
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
      print('[HabitsScreen] Day selected: $_selectedDate, weekday: ${_selectedDate.weekday}');
      // _fetchHabits(); // Temporarily commented out for debugging - let ListView rebuild handle filtering
    });
  }
  
  Future<void> _toggleHabitCompletion(habit_model.Habit habit, bool completed) async {
    if (!mounted) return;
    try {
      final dateToMark = _selectedDate; 
      await _habitService.markHabitCompletion(habit.id, dateToMark, completed);
      _fetchHabits(); 
    } catch (e) {
      print("[HabitsScreen] Error toggling habit completion: $e");
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
            await _habitService.deleteHabit(habitId);
            _fetchHabits(); 
            if(mounted){
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Habit deleted successfully.')),
                );
            }
        } catch (e) {
            print("[HabitsScreen] Error deleting habit: $e");
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
    print('[HabitsScreen] Building UI. Selected date: $_selectedDate, weekday: ${_selectedDate.weekday}');
    return Consumer<HabitService>(
      builder: (context, habitService, child) {
        // Atualiza a referência do serviço
        _habitService = habitService;
        
        return Scaffold(
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
                              bool showHabit = false;
                              print('[HabitsScreen] ListView itemBuilder for: ${habit.title}, SelectedDate: $_selectedDate (weekday: ${_selectedDate.weekday})');
                              
                              if (habit.frequency == habit_model.HabitFrequency.daily) {
                                showHabit = true;
                                print('  - Daily habit. SHOWING: $showHabit');
                              } else if (habit.frequency == habit_model.HabitFrequency.weekly || habit.frequency == habit_model.HabitFrequency.custom) {
                                print('  - Weekly/Custom. Habit days: ${habit.daysOfWeek}, Selected weekday: ${_selectedDate.weekday}');
                                if (habit.daysOfWeek != null && habit.daysOfWeek!.contains(_selectedDate.weekday)) {
                                  showHabit = true;
                                }
                                print('  - SHOWING: $showHabit');
                              } else if (habit.frequency == habit_model.HabitFrequency.monthly) {
                                print('  - Monthly. Habit daysOfMonth: ${habit.daysOfMonth}, Selected day: ${_selectedDate.day}');
                                if (habit.daysOfMonth != null && habit.daysOfMonth!.contains(_selectedDate.day)) {
                                  showHabit = true;
                                } else if (habit.daysOfMonth != null && habit.daysOfMonth!.contains(0)) {
                                  // Check if today is the last day of the month
                                  final lastDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
                                  if (_selectedDate.day == lastDayOfMonth) {
                                    showHabit = true;
                                  }
                                }
                                print('  - SHOWING: $showHabit');
                              } else if (habit.frequency == habit_model.HabitFrequency.specificDaysOfYear) {
                                print('  - SpecificDaysOfYear. Habit specificYearDates: ${habit.specificYearDates}, Selected date: $_selectedDate');
                                if (habit.specificYearDates != null) {
                                  showHabit = habit.specificYearDates!.any((date) =>
                                    date.year == _selectedDate.year &&
                                    date.month == _selectedDate.month &&
                                    date.day == _selectedDate.day
                                  );
                                }
                                print('  - SHOWING: $showHabit');
                              } else if (habit.frequency == habit_model.HabitFrequency.someTimesPerPeriod) {
                                print('  - SomeTimesPerPeriod. Always showing for now');
                                showHabit = true; // Para "algumas vezes por período", sempre mostra
                                print('  - SHOWING: $showHabit');
                              } else if (habit.frequency == habit_model.HabitFrequency.repeat) {
                                print('  - Repeat. Always showing for now');
                                showHabit = true; // Para "repetir", sempre mostra por enquanto
                                print('  - SHOWING: $showHabit');
                              }

                              if (!showHabit) {
                                print('  - HIDING habit: ${habit.title}');
                                return const SizedBox.shrink();
                              }
                              print('  - RENDERING HabitCard for: ${habit.title}');
                              return HabitCard(
                                habit: habit,
                                onTap: () async {
                                  print("Edit habit tapped: ${habit.title}"); 
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
          if (result == true || result == null) { 
            _fetchHabits(); 
          }
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
      },
    );
  }
}
