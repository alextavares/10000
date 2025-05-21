import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Required for initializing locale data

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

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR', null);
    _generateWeekDays(DateTime.now());
    _selectedDate = DateTime.now(); 
    _activelySelectedDayIndexInWeek = _weekDays.indexWhere((day) => day.day == 19); 
    if (_activelySelectedDayIndexInWeek == -1 && _weekDays.isNotEmpty) {
       _activelySelectedDayIndexInWeek = _weekDays.length -2; 
    }
  }

  void _generateWeekDays(DateTime referenceDate) {
    _weekDays = [];
    // Example: Qua=14, Qui=15, Sex=16, Sab=17, Dom=18, Seg=19, Ter=20
    // Hardcoding based on the image for visual replication, adjust if needed for dynamic dates
    _weekDays = [
      DateTime(referenceDate.year, referenceDate.month, 14),
      DateTime(referenceDate.year, referenceDate.month, 15),
      DateTime(referenceDate.year, referenceDate.month, 16),
      DateTime(referenceDate.year, referenceDate.month, 17),
      DateTime(referenceDate.year, referenceDate.month, 18),
      DateTime(referenceDate.year, referenceDate.month, 19),
      DateTime(referenceDate.year, referenceDate.month, 20),
    ];
    _currentDayIndexInWeek = _weekDays.indexWhere((day) => 
        day.year == referenceDate.year && 
        day.month == referenceDate.month && 
        day.day == referenceDate.day);
    if (_currentDayIndexInWeek == -1 && _weekDays.isNotEmpty) {
        _currentDayIndexInWeek = _weekDays.length -1; // Default to last day if not found
    }
    _activelySelectedDayIndexInWeek = _currentDayIndexInWeek; 
  }

  void _selectDay(int index) {
    setState(() {
      _activelySelectedDayIndexInWeek = index;
      _selectedDate = _weekDays[index];
    });
  }

  Widget _buildDayWidget(BuildContext context, int index) {
    final DateTime day = _weekDays[index];
    final String dayAbbreviation = DateFormat('E', 'pt_BR').format(day).substring(0,3);
    final String dateNumber = DateFormat('d', 'pt_BR').format(day);
    
    bool isToday = index == _currentDayIndexInWeek;
    bool isActivelySelected = index == _activelySelectedDayIndexInWeek; 

    Color backgroundColor = const Color(0xFF2C2C2E); 
    Color textColor = Colors.grey[400]!;
    FontWeight fontWeight = FontWeight.normal;
    BoxBorder? border;

    // Styles based on image (Seg 19 amber, Ter 20 white border)
    if (isActivelySelected && day.day == 19 && day.weekday == DateTime.monday) { // Assuming Seg 19 is the amber one
        backgroundColor = Colors.amber;
        textColor = Colors.black;
        fontWeight = FontWeight.bold;
    } else if (isToday) { 
        backgroundColor = const Color(0xFF3A3A3C);
        textColor = Colors.white;
        fontWeight = FontWeight.bold;
        border = Border.all(color: Colors.white, width: 2);
    } else if (isActivelySelected) { 
        backgroundColor = Colors.grey[700]!;
        textColor = Colors.white;
        fontWeight = FontWeight.bold;
    }

    return GestureDetector(
      onTap: () => _selectDay(index),
      child: Container(
        width: 40,
        height: 60, 
        margin: const EdgeInsets.symmetric(horizontal: 2), // Add some spacing between day widgets
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle, 
          border: border,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayAbbreviation,
              style: TextStyle(color: textColor, fontSize: 10, fontWeight: fontWeight),
            ),
            const SizedBox(height: 2),
            Text(
              dateNumber,
              style: TextStyle(color: textColor, fontSize: 14, fontWeight: fontWeight),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Returns only the body content for the Habits screen
    // Scaffold, AppBar, and FloatingActionButton are handled by MainNavigationScreen
    return Container(
      color: Colors.black, 
      child: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hábito',
                                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Todos os dias',
                                style: TextStyle(color: Color(0xFF00BCD4), fontSize: 14),
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF00BCD4).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.star_border, color: Color(0xFF00BCD4)),
                              onPressed: () { /* Star action */ },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_weekDays.isNotEmpty)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(_weekDays.length, (index) {
                              return _buildDayWidget(context, index);
                            }),
                          ),
                        )
                      else 
                        const Center(child: Text("Carregando dias...", style: TextStyle(color: Colors.white))),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.link, color: Colors.grey, size: 20),
                          const SizedBox(width: 4),
                          const Text('0', style: TextStyle(color: Colors.white, fontSize: 14)),
                          const SizedBox(width: 16),
                          const Icon(Icons.check_circle_outline, color: Colors.grey, size: 20),
                          const SizedBox(width: 4),
                          const Text('0%', style: TextStyle(color: Colors.white, fontSize: 14)),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.calendar_today_outlined, color: Colors.grey, size: 20),
                            onPressed: () { /* Calendar action */ },
                          ),
                          IconButton(
                            icon: const Icon(Icons.bar_chart_outlined, color: Colors.grey, size: 20),
                            onPressed: () { /* Stats action */ },
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_vert_outlined, color: Colors.grey, size: 20),
                            onPressed: () { /* More options */ },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Lista de Hábitos - Em construção',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
              ),
              // Adjusted to ensure it doesn't get hidden by bottom nav or FAB from MainNavigationScreen
              const SizedBox(height: 60), 
            ],
          ),
          Align(
            alignment: Alignment.bottomLeft,
            // Pushing it up slightly to account for BottomNavigationBar
            child: Padding(
              padding: const EdgeInsets.only(left:16.0, bottom: 76.0), // Increased bottom padding
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE91E63),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Premium',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
