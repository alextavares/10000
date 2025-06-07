import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:myapp/models/habit.dart' as habit_model;
import 'package:myapp/services/habit_service.dart';
import 'package:myapp/widgets/habit_card_complete.dart';
import 'package:myapp/screens/habit/habit_details_screen.dart';
import 'package:myapp/screens/habits/add_habit_simple_screen.dart';
import 'package:myapp/screens/habits/habit_selection_screen.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/utils/logger.dart';
import 'package:myapp/utils/responsive/responsive.dart';

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
    // Serviço será obtido pelo Consumer
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



  void _selectDay(int index) {
    if (!mounted) return;
    setState(() {
      _activelySelectedDayIndexInWeek = index;
      _selectedDate = _weekDays[index];
      Logger.debug('[HabitsScreen] Day selected: $_selectedDate, weekday: ${_selectedDate.weekday}');
    });
  }
  
  Future<void> _toggleHabitCompletion(habit_model.Habit habit, bool completed, [DateTime? date]) async {
    if (!mounted) return;
    try {
      final dateToMark = date ?? _selectedDate; 
      await _habitService.markHabitCompletion(habit.id, dateToMark, completed);
      // O Consumer vai atualizar automaticamente
    } catch (e) {
      Logger.error("[HabitsScreen] Error toggling habit completion: $e");
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
            // O Consumer vai atualizar automaticamente
            if(mounted){
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Habit deleted successfully.')),
                );
            }
        } catch (e) {
            Logger.error("[HabitsScreen] Error deleting habit: $e");
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
        backgroundColor = AppTheme.primaryColor.withValues(alpha: 0.8);
        textColor = Colors.white;
        fontWeight = FontWeight.bold;
    } else if (isToday) { 
        backgroundColor = AppTheme.primaryColor.withValues(alpha: 0.3);
        textColor = AppTheme.primaryColor;
        fontWeight = FontWeight.bold;
        border = Border.all(color: AppTheme.primaryColor, width: 1.5);
    }

    final daySize = Responsive.value<double>(
      context: context,
      mobile: 50,
      tablet: 60,
      desktop: 70,
    );

    return GestureDetector(
      onTap: () => _selectDay(index),
      child: Container(
        width: daySize, 
        height: daySize * 1.4, 
        margin: EdgeInsets.symmetric(horizontal: Responsive.value<double>(
          context: context,
          mobile: 4,
          tablet: 6,
          desktop: 8,
        )), 
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(daySize / 2), 
          border: border,
          boxShadow: isActivelySelected ? [
            BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
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
              style: TextStyle(
                color: textColor, 
                fontSize: Responsive.value<double>(
                  context: context,
                  mobile: 11,
                  tablet: 13,
                  desktop: 15,
                ), 
                fontWeight: fontWeight
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dateNumber,
              style: TextStyle(
                color: textColor, 
                fontSize: Responsive.value<double>(
                  context: context,
                  mobile: 16,
                  tablet: 18,
                  desktop: 20,
                ), 
                fontWeight: fontWeight
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Logger.debug('[HabitsScreen] Building UI. Selected date: $_selectedDate, weekday: ${_selectedDate.weekday}');
    return Consumer<HabitService>(
      builder: (context, habitService, child) {
        // Atualiza a referência do serviço
        _habitService = habitService;
        
        // Obtém a lista de hábitos diretamente do serviço
        final habits = habitService.getHabitsSync();
        
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: ResponsiveContainer(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: Responsive.value<double>(
                      context: context,
                      mobile: 16.0,
                      tablet: 20.0,
                      desktop: 24.0,
                    )),
                    child: habits.isEmpty
                              ? Center(
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                          Icon(Icons.list_alt_rounded, size: 80, color: AppTheme.subtitleColor.withValues(alpha: 0.5)),
                                          const SizedBox(height:16),
                                          Text(
                                              'No habits yet.', 
                                              style: TextStyle(
                                                color: AppTheme.subtitleColor, 
                                                fontSize: Responsive.value<double>(
                                                  context: context,
                                                  mobile: 18,
                                                  desktop: 22,
                                                )
                                              )
                                          ),
                                          const SizedBox(height:8),
                                          Text(
                                              'Tap the + button to add your first habit.',
                                              style: TextStyle(
                                                color: AppTheme.subtitleColor.withValues(alpha: 0.7), 
                                                fontSize: Responsive.value<double>(
                                                  context: context,
                                                  mobile: 14,
                                                  desktop: 16,
                                                )
                                              ),
                                              textAlign: TextAlign.center,
                                          ),
                                      ],
                                  )
                                )
                              : ResponsiveLayout(
                                  mobile: ListView.builder(
                                    padding: const EdgeInsets.only(bottom: 80), 
                                    itemCount: habits.length,
                                    itemBuilder: (context, index) => _buildHabitItem(habits[index]),
                                  ),
                                  desktop: GridView.builder(
                                    padding: EdgeInsets.only(bottom: 80), 
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: Responsive.gridColumns(context),
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: 3.5,
                                    ),
                                    itemCount: habits.length,
                                    itemBuilder: (context, index) => _buildHabitItem(habits[index]),
                                  ),
                                ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: "suggestions",
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HabitSelectionScreen()),
                  );
                  // O Consumer vai atualizar automaticamente quando os hábitos forem adicionados
                },
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.9),
                mini: true,
                child: const Icon(Icons.lightbulb_outline, color: Colors.white),
              ),
              const SizedBox(height: 10),
              FloatingActionButton(
                heroTag: "add",
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddHabitSimpleScreen()),
                  );
                  // O Consumer vai atualizar automaticamente quando o hábito for adicionado
                },
                backgroundColor: AppTheme.primaryColor,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHabitItem(habit_model.Habit habit) {
    bool showHabit = false;
    Logger.debug('[HabitsScreen] ListView itemBuilder for: ${habit.title}, SelectedDate: $_selectedDate (weekday: ${_selectedDate.weekday})');
    
    if (habit.frequency == habit_model.HabitFrequency.daily) {
      showHabit = true;
      Logger.debug('  - Daily habit. SHOWING: $showHabit');
    } else if (habit.frequency == habit_model.HabitFrequency.weekly || habit.frequency == habit_model.HabitFrequency.custom) {
      Logger.debug('  - Weekly/Custom. Habit days: ${habit.daysOfWeek}, Selected weekday: ${_selectedDate.weekday}');
      if (habit.daysOfWeek != null && habit.daysOfWeek!.contains(_selectedDate.weekday)) {
        showHabit = true;
      }
      Logger.debug('  - SHOWING: $showHabit');
    } else if (habit.frequency == habit_model.HabitFrequency.monthly) {
      Logger.debug('  - Monthly. Habit daysOfMonth: ${habit.daysOfMonth}, Selected day: ${_selectedDate.day}');
      if (habit.daysOfMonth != null && habit.daysOfMonth!.contains(_selectedDate.day)) {
        showHabit = true;
      } else if (habit.daysOfMonth != null && habit.daysOfMonth!.contains(0)) {
        // Check if today is the last day of the month
        final lastDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
        if (_selectedDate.day == lastDayOfMonth) {
          showHabit = true;
        }
      }
      Logger.debug('  - SHOWING: $showHabit');
    } else if (habit.frequency == habit_model.HabitFrequency.specificDaysOfYear) {
      Logger.debug('  - SpecificDaysOfYear. Habit specificYearDates: ${habit.specificYearDates}, Selected date: $_selectedDate');
      if (habit.specificYearDates != null) {
        showHabit = habit.specificYearDates!.any((date) =>
          date.year == _selectedDate.year &&
          date.month == _selectedDate.month &&
          date.day == _selectedDate.day
        );
      }
      Logger.debug('  - SHOWING: $showHabit');
    } else if (habit.frequency == habit_model.HabitFrequency.someTimesPerPeriod) {
      Logger.debug('  - SomeTimesPerPeriod. Always showing for now');
      showHabit = true; // Para "algumas vezes por período", sempre mostra
      Logger.debug('  - SHOWING: $showHabit');
    } else if (habit.frequency == habit_model.HabitFrequency.repeat) {
      Logger.debug('  - Repeat. Always showing for now');
      showHabit = true; // Para "repetir", sempre mostra por enquanto
      Logger.debug('  - SHOWING: $showHabit');
    }

    if (!showHabit) {
      Logger.debug('  - HIDING habit: ${habit.title}');
      return const SizedBox.shrink();
    }
    Logger.debug('  - RENDERING HabitCard for: ${habit.title}');
    return HabitCardComplete(
      habit: habit,
      selectedDate: _selectedDate,
      onToggleCompletion: (bool completed, DateTime date) async {
        await _toggleHabitCompletion(habit, completed, date);
      },
      onDelete: () {
        _deleteHabit(habit.id);
      },
    );
  }
}
