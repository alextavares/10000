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
    HabitFrequency.someTimesPerPeriod: 'Algumas vezes por período',
    HabitFrequency.repeat: 'Repetir',
  };

  final List<int> _selectedWeekDays = [];
  final List<int> _selectedMonthDays = [];
  final List<DateTime> _selectedYearDates = [];

  // Variáveis para "algumas vezes por período"
  int _timesPerPeriod = 1;
  String _selectedPeriodType = 'SEMANA';
  final List<String> _periodTypes = ['SEMANA', 'MÊS', 'ANO'];

  // Variáveis para "repetir"
  int _repeatEveryDays = 2;
  bool _isFlexible = false;
  bool _alternateDays = false;

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            const Icon(Icons.calendar_month, color: Colors.pinkAccent, size: 18),
            const SizedBox(width: 8),
            const Text('Selecione os dias do mês:', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Toque nos dias do mês em que você deseja realizar este hábito',
          style: TextStyle(color: Colors.grey[400], fontSize: 13),
        ),
        const SizedBox(height: 16),
        
        // Grade organizada de dias (7 colunas)
        SizedBox(
          height: 200, // Altura fixa para garantir que seja visível
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: 32, // 31 dias + último dia
            itemBuilder: (context, index) {
            if (index < 31) {
              final day = index + 1;
              final isSelected = _selectedMonthDays.contains(day);
              return GestureDetector(
                onTap: () {
                  print('Day $day tapped, currently selected: $isSelected');
                  setState(() {
                    if (isSelected) {
                      _selectedMonthDays.remove(day);
                      print('Removed day $day, now selected: $_selectedMonthDays');
                    } else {
                      _selectedMonthDays.add(day);
                      print('Added day $day, now selected: $_selectedMonthDays');
                    }
                    _selectedMonthDays.sort();
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.pinkAccent : Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.pinkAccent : Colors.grey[600]!,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[300],
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            } else {
              // Último dia do mês
              final isSelected = _selectedMonthDays.contains(0);
              return GestureDetector(
                onTap: () {
                  print('Last day tapped, currently selected: $isSelected');
                  setState(() {
                    if (isSelected) {
                      _selectedMonthDays.remove(0);
                      print('Removed last day, now selected: $_selectedMonthDays');
                    } else {
                      _selectedMonthDays.add(0);
                      print('Added last day, now selected: $_selectedMonthDays');
                    }
                    _selectedMonthDays.sort();
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.pinkAccent : Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.pinkAccent : Colors.grey[600]!,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Últ.',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[300],
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }
          },
        ),
        ),
        
        const SizedBox(height: 16),
        
        if (_selectedMonthDays.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.redAccent.shade100, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Selecione pelo menos um dia do mês para continuar.',
                    style: TextStyle(color: Colors.redAccent.shade100, fontSize: 13),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade300, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Dias selecionados: ${_selectedMonthDays.length}',
                  style: TextStyle(color: Colors.green.shade300, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
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
        Row(
          children: [
            const Icon(Icons.event, color: Colors.pinkAccent, size: 18),
            const SizedBox(width: 8),
            const Text('Selecione datas específicas:', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Toque nas datas do calendário em que você deseja realizar este hábito',
          style: TextStyle(color: Colors.grey[400], fontSize: 13),
        ),
        const SizedBox(height: 12),
        if (_selectedYearDates.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.redAccent.shade100, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Selecione pelo menos uma data para continuar.',
                    style: TextStyle(color: Colors.redAccent.shade100, fontSize: 13),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade300, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Datas selecionadas: ${_selectedYearDates.length}',
                  style: TextStyle(color: Colors.green.shade300, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
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

  Widget _buildSomeTimesPerPeriodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text('Configure a frequência:', style: TextStyle(color: Colors.white70, fontSize: 15)),
        const SizedBox(height: 12),
        Row(
          children: [
            // Campo numérico para quantidade
            SizedBox(
              width: 80,
              child: TextField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: '1',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[700]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.pinkAccent),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[800],
                ),
                onChanged: (value) {
                  final newValue = int.tryParse(value);
                  if (newValue != null && newValue > 0) {
                    setState(() {
                      _timesPerPeriod = newValue;
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            const Text('vezes por', style: TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(width: 12),
            // Dropdown para período
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPeriodType,
                    dropdownColor: Colors.grey[800],
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                    items: _periodTypes.map((String period) {
                      return DropdownMenuItem<String>(
                        value: period,
                        child: Text(period),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedPeriodType = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'O hábito será realizado $_timesPerPeriod ${_timesPerPeriod == 1 ? 'vez' : 'vezes'} por ${_selectedPeriodType.toLowerCase()}',
          style: TextStyle(color: Colors.grey[400], fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildRepeatSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text('Configure a repetição:', style: TextStyle(color: Colors.white70, fontSize: 15)),
        const SizedBox(height: 12),
        
        // A cada X dias
        Row(
          children: [
            const Text('A cada', style: TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(width: 12),
            SizedBox(
              width: 80,
              child: TextField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: '2',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[700]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.pinkAccent),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[800],
                ),
                onChanged: (value) {
                  final newValue = int.tryParse(value);
                  if (newValue != null && newValue > 0) {
                    setState(() {
                      _repeatEveryDays = newValue;
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            const Text('dias', style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Flexível
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Flexível', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Switch(
                    value: _isFlexible,
                    onChanged: (value) {
                      setState(() {
                        _isFlexible = value;
                      });
                    },
                    activeColor: Colors.pinkAccent,
                    inactiveThumbColor: Colors.grey[700],
                    inactiveTrackColor: Colors.grey[800],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Será exibida todos os dias até ser concluída.',
                style: TextStyle(color: Colors.grey[400], fontSize: 13),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Alternar dias
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Alternar dias', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Switch(
                value: _alternateDays,
                onChanged: (value) {
                  setState(() {
                    _alternateDays = value;
                  });
                },
                activeColor: Colors.pinkAccent,
                inactiveThumbColor: Colors.grey[700],
                inactiveTrackColor: Colors.grey[800],
              ),
            ],
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
    if (_selectedFrequency == HabitFrequency.someTimesPerPeriod) {
      return _timesPerPeriod > 0;
    }
    if (_selectedFrequency == HabitFrequency.repeat) {
      return _repeatEveryDays > 0;
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
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: RadioListTile<HabitFrequency>(
                        title: Text(entry.value, style: const TextStyle(color: Colors.white, fontSize: 15)),
                        value: entry.key,
                        groupValue: _selectedFrequency,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
                        dense: true,
                        onChanged: (HabitFrequency? value) {
                          setState(() {
                            _selectedFrequency = value!;
                            if (_selectedFrequency != HabitFrequency.weekly) {
                              _selectedWeekDays.clear();
                            } else if (_selectedFrequency == HabitFrequency.weekly && _selectedWeekDays.isEmpty) {
                              // Auto-select today's weekday when switching to weekly
                              final today = DateTime.now();
                              _selectedWeekDays.add(today.weekday);
                            }
                            if (_selectedFrequency != HabitFrequency.monthly) {
                              _selectedMonthDays.clear();
                            } else if (_selectedFrequency == HabitFrequency.monthly && _selectedMonthDays.isEmpty) {
                              // Auto-select today's day of month when switching to monthly
                              final today = DateTime.now();
                              _selectedMonthDays.add(today.day);
                            }
                            if (_selectedFrequency != HabitFrequency.specificDaysOfYear) {
                               _selectedYearDates.clear();
                            } else if (_selectedFrequency == HabitFrequency.specificDaysOfYear && _selectedYearDates.isEmpty) {
                              // Auto-select today's date when switching to specific days of year
                              final today = DateTime.now();
                              _selectedYearDates.add(DateTime(today.year, today.month, today.day));
                            }
                            if (_selectedFrequency != HabitFrequency.someTimesPerPeriod) {
                              _timesPerPeriod = 1;
                              _selectedPeriodType = 'SEMANA';
                            }
                            if (_selectedFrequency != HabitFrequency.repeat) {
                              _repeatEveryDays = 2;
                              _isFlexible = false;
                              _alternateDays = false;
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
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, color: Colors.pinkAccent, size: 18),
                              const SizedBox(width: 8),
                              const Text('Selecione os dias da semana:', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Toque nos dias em que você deseja realizar este hábito',
                            style: TextStyle(color: Colors.grey[400], fontSize: 13),
                          ),
                          const SizedBox(height: 16),
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
                               child: Container(
                                 padding: const EdgeInsets.all(12),
                                 decoration: BoxDecoration(
                                   color: Colors.redAccent.withOpacity(0.1),
                                   borderRadius: BorderRadius.circular(8),
                                   border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                                 ),
                                 child: Row(
                                   children: [
                                     Icon(Icons.warning_amber_rounded, color: Colors.redAccent.shade100, size: 20),
                                     const SizedBox(width: 8),
                                     Expanded(
                                       child: Text(
                                         'Selecione pelo menos um dia da semana para continuar.',
                                         style: TextStyle(color: Colors.redAccent.shade100, fontSize: 13),
                                       ),
                                     ),
                                   ],
                                 ),
                               ),
                             )
                        ],
                      ),
                    ),
                  
                  if (_selectedFrequency == HabitFrequency.monthly)
                    _buildMonthDaySelector(), 
                  
                  if (_selectedFrequency == HabitFrequency.specificDaysOfYear)
                    _buildYearDaySelector(),

                  if (_selectedFrequency == HabitFrequency.someTimesPerPeriod)
                    _buildSomeTimesPerPeriodSelector(),

                  if (_selectedFrequency == HabitFrequency.repeat)
                    _buildRepeatSelector(),

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
                            timesPerPeriod: _selectedFrequency == HabitFrequency.someTimesPerPeriod ? _timesPerPeriod : null,
                            periodType: _selectedFrequency == HabitFrequency.someTimesPerPeriod ? _selectedPeriodType : null,
                            repeatEveryDays: _selectedFrequency == HabitFrequency.repeat ? _repeatEveryDays : null,
                            isFlexible: _selectedFrequency == HabitFrequency.repeat ? _isFlexible : null,
                            alternateDays: _selectedFrequency == HabitFrequency.repeat ? _alternateDays : null,
                          ),
                        ));
                      } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _canProceed() ? Colors.pinkAccent : Colors.grey[700],
                      foregroundColor: _canProceed() ? Colors.white : Colors.grey[400],
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      disabledBackgroundColor: Colors.grey[700],
                      disabledForegroundColor: Colors.grey[400],
                    ),
                    child: Text(
                      'PRÓXIMA',
                      style: TextStyle(
                        color: _canProceed() ? Colors.white : Colors.grey[400],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
