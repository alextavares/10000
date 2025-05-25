import 'package:flutter/material.dart';
import 'package:myapp/models/habit.dart'; 
import 'add_habit_schedule_screen.dart'; 
import 'package:table_calendar/table_calendar.dart';

class AddHabitFrequencyScreen extends StatefulWidget {
  final String selectedCategoryName;
  final IconData selectedCategoryIcon;
  final Color selectedCategoryColor;
  final String habitTitle;
  final String? habitDescription;
  final HabitTrackingType selectedTrackingType;

  const AddHabitFrequencyScreen({
    super.key,
    required this.selectedCategoryName,
    required this.selectedCategoryIcon,
    required this.selectedCategoryColor,
    required this.habitTitle,
    this.habitDescription,
    required this.selectedTrackingType,
  });

  @override
  State<AddHabitFrequencyScreen> createState() => _AddHabitFrequencyScreenState();
}

class _AddHabitFrequencyScreenState extends State<AddHabitFrequencyScreen> {
  HabitFrequency _selectedFrequency = HabitFrequency.daily;

  final Map<HabitFrequency, String> _frequencyOptions = {
    HabitFrequency.daily: 'Todos os dias',
    HabitFrequency.weekly: 'Alguns dias da semana',
    HabitFrequency.monthly: 'Dias específicos do mês',
    HabitFrequency.specificDaysOfYear: 'Dias específicos do ano', // Using the new enum value
  };

  final List<int> _selectedWeekDays = [];
  final List<int> _selectedMonthDays = []; 
  final List<DateTime> _selectedYearDates = []; 

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedCalendarDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Ensure 'pt_BR' locale is initialized for the calendar
    // This might be better placed in main.dart or a similar global setup location
    // initializeDateFormatting('pt_BR', null);
  }

  Widget _buildMonthDaySelector() {
    List<Widget> dayButtons = [];
    for (int i = 1; i <= 31; i++) {
      final isSelected = _selectedMonthDays.contains(i);
      dayButtons.add(
        ElevatedButton(
          onPressed: () {
            setState(() {
              if (isSelected) {
                _selectedMonthDays.remove(i);
              } else {
                _selectedMonthDays.add(i);
              }
              _selectedMonthDays.sort();
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Colors.pinkAccent : Colors.grey[800],
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(10),
            minimumSize: const Size(40, 40), 
          ),
          child: Text('$i', style: const TextStyle(fontSize: 14)),
        ),
      );
    }
    final isLastDaySelected = _selectedMonthDays.contains(0); // Assuming 0 represents "Last Day"
    dayButtons.add(
       ElevatedButton(
          onPressed: () {
            setState(() {
              if (isLastDaySelected) {
                _selectedMonthDays.remove(0);
              } else {
                _selectedMonthDays.add(0);
              }
               _selectedMonthDays.sort();
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isLastDaySelected ? Colors.pinkAccent : Colors.grey[800],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12 ),
          ),
          child: const Text('Últi...', style: TextStyle(fontSize: 14)), // Abbreviated for "Último dia"
        ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text('Selecione os dias do mês:', style: TextStyle(color: Colors.white70, fontSize: 15)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8.0, 
          runSpacing: 8.0, 
          alignment: WrapAlignment.start, 
          children: dayButtons,
        ),
        if (_selectedMonthDays.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12.0, left: 4.0),
            child: Text(
              'Selecione pelo menos um dia',
              style: TextStyle(color: Colors.redAccent.shade100, fontSize: 13),
            ),
          ),
      ],
    );
  }

  Widget _buildYearDaySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          _selectedYearDates.isEmpty 
            ? 'Selecione pelo menos um dia' 
            : 'Datas selecionadas: ${_selectedYearDates.length}',
          style: TextStyle(
            color: _selectedYearDates.isEmpty ? Colors.redAccent.shade100 : Colors.white,
            fontSize: 13
          )
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(12)
          ),
          child: TableCalendar(
            locale: 'pt_BR',
            firstDay: DateTime.utc(DateTime.now().year - 5), 
            lastDay: DateTime.utc(DateTime.now().year + 5),  
            focusedDay: _focusedCalendarDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return _selectedYearDates.any((selectedDate) => isSameDay(selectedDate, day));
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _focusedCalendarDay = focusedDay; 
                final index = _selectedYearDates.indexWhere((date) => isSameDay(date, selectedDay));
                if (index >= 0) {
                  _selectedYearDates.removeAt(index);
                } else {
                  _selectedYearDates.add(selectedDay);
                }
                _selectedYearDates.sort(); 
              });
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedCalendarDay = focusedDay;
            },
            calendarStyle: CalendarStyle(
              defaultTextStyle: const TextStyle(color: Colors.white),
              weekendTextStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              outsideTextStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
              selectedDecoration: const BoxDecoration(
                color: Colors.pinkAccent,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.pinkAccent.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              titleTextStyle: const TextStyle(color: Colors.white, fontSize: 16.0),
              formatButtonTextStyle: const TextStyle(color: Colors.white),
              formatButtonDecoration: BoxDecoration(
                border: Border.all(color: Colors.white30),
                borderRadius: BorderRadius.circular(12.0),
              ),
              leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white),
              rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.white),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: Colors.white70),
              weekendStyle: TextStyle(color: Colors.pinkAccent),
            ),
          ),
        ),
      ],
    );
  }
  
  bool _canProceed() {
    if (_selectedFrequency == HabitFrequency.weekly) {
      return _selectedWeekDays.isNotEmpty;
    }
    if (_selectedFrequency == HabitFrequency.monthly) {
      return _selectedMonthDays.isNotEmpty;
    }
    if (_selectedFrequency == HabitFrequency.specificDaysOfYear) {
      return _selectedYearDates.isNotEmpty;
    }
    return _selectedFrequency != HabitFrequency.custom; // Allow daily, or custom if it was defined for other uses 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Com que frequência você deseja fazer isso?',
          style: TextStyle(color: Colors.pinkAccent, fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal:16.0, vertical: 8.0),
        child: Column( 
          children: [
            Expanded(
              child: ListView(
                children: [
                  ..._frequencyOptions.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: RadioListTile<HabitFrequency>(
                        title: Text(entry.value, style: const TextStyle(color: Colors.white, fontSize: 16)),
                        value: entry.key,
                        groupValue: _selectedFrequency,
                        onChanged: (HabitFrequency? value) {
                          setState(() {
                            _selectedFrequency = value!;
                            if (_selectedFrequency != HabitFrequency.weekly) {
                              _selectedWeekDays.clear(); 
                            }
                            if (_selectedFrequency != HabitFrequency.monthly) {
                              _selectedMonthDays.clear();
                            }
                            if (_selectedFrequency != HabitFrequency.specificDaysOfYear) {
                               _selectedYearDates.clear();
                            }
                          });
                        },
                        activeColor: Colors.pinkAccent,
                        controlAffinity: ListTileControlAffinity.trailing,
                        tileColor: _selectedFrequency == entry.key ? Colors.grey[800] : Colors.grey[850],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  }),
            
                  if (_selectedFrequency == HabitFrequency.weekly)
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, left: 4.0, right: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Selecione os dias da semana:', style: TextStyle(color: Colors.white70, fontSize: 15)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: List.generate(7, (index) {
                              final dayIndex = index + 1; 
                              final dayName = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'][index];
                              final isSelected = _selectedWeekDays.contains(dayIndex);
                              return ChoiceChip(
                                label: Text(dayName, style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontSize: 14)),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedWeekDays.add(dayIndex);
                                    } else {
                                      _selectedWeekDays.remove(dayIndex);
                                    }
                                    _selectedWeekDays.sort(); 
                                  });
                                },
                                backgroundColor: Colors.grey[800],
                                selectedColor: Colors.pinkAccent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              );
                            }).toList(),
                          ),
                          if (_selectedWeekDays.isEmpty)
                             Padding(
                               padding: const EdgeInsets.only(top:12.0),
                               child: Text('Selecione pelo menos um dia da semana.', style: TextStyle(color: Colors.redAccent.shade100, fontSize: 13)),
                             )
                        ],
                      ),
                    ),
                  
                  if (_selectedFrequency == HabitFrequency.monthly)
                    _buildMonthDaySelector(), 
                  
                  if (_selectedFrequency == HabitFrequency.specificDaysOfYear)
                    _buildYearDaySelector(),

                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0, bottom: 20.0), 
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'ANTERIOR',
                      style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _canProceed() 
                    ? () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => AddHabitScheduleScreen(
                            selectedCategoryName: widget.selectedCategoryName,
                            selectedCategoryIcon: widget.selectedCategoryIcon,
                            selectedCategoryColor: widget.selectedCategoryColor,
                            habitTitle: widget.habitTitle,
                            habitDescription: widget.habitDescription,
                            selectedTrackingType: widget.selectedTrackingType,
                            selectedFrequency: _selectedFrequency, 
                            selectedDaysOfWeek: _selectedFrequency == HabitFrequency.weekly ? _selectedWeekDays : null,
                            selectedDaysOfMonth: _selectedFrequency == HabitFrequency.monthly ? _selectedMonthDays : null, 
                            selectedYearDates: _selectedFrequency == HabitFrequency.specificDaysOfYear ? _selectedYearDates : null, 
                          ),
                        ));
                      } : null, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                       disabledBackgroundColor: Colors.grey[700],
                       disabledForegroundColor: Colors.grey[400],
                    ),
                    child: const Text('PRÓXIMA', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
