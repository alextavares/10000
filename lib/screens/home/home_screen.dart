import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime _selectedDate;
  late List<DateTime> _weekDays;
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize with current date and an empty week list first
    _selectedDate = DateTime.now();
    _weekDays = []; // Initialize with an empty list or a default week
    _generateWeekDays(); // Generate initial week days

    // Then, initialize date formatting and update if needed
    initializeDateFormatting('pt_BR', null).then((_) {
      // Potentially update _selectedDate or re-generate week days
      // if the locale significantly changes date interpretation, though unlikely for DateTime.now()
      if (mounted) { // Check if the widget is still in the tree
        setState(() {
          // Re-assign to trigger a rebuild if necessary, for example, if formatting affects display directly
          _selectedDate = DateTime.now(); 
          _generateWeekDays();
        });
      }
    });
  }

  void _generateWeekDays() {
    // Get the current date
    DateTime now = DateTime.now();
    
    // Find the previous Friday (or today if it's Friday)
    DateTime startOfWeek = now.subtract(Duration(days: (now.weekday - 5) % 7));
    
    // Generate 7 days starting from Friday
    _weekDays = List.generate(7, (index) => 
      startOfWeek.add(Duration(days: index))
    );
    
    // Find the index of today in the week days
    _selectedDayIndex = _weekDays.indexWhere((date) => 
      date.day == now.day && date.month == now.month && date.year == now.year
    );
    
    if (_selectedDayIndex == -1) {
      _selectedDayIndex = 0; // Default to the first day in the list if today is not found (should not happen with current logic)
    }
    
    // Update _selectedDate to be the one from the generated list corresponding to _selectedDayIndex
    // This ensures _selectedDate is always a value present in _weekDays
    if (_weekDays.isNotEmpty) {
        _selectedDate = _weekDays[_selectedDayIndex];
    } else {
        // Fallback if _weekDays is empty, though _generateWeekDays should prevent this
        _selectedDate = DateTime.now(); 
    }
  }

  void _selectDay(int index) {
    setState(() {
      _selectedDayIndex = index;
      _selectedDate = _weekDays[index];
    });
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Seg';
      case 2: return 'Ter';
      case 3: return 'Qua';
      case 4: return 'Qui';
      case 5: return 'Sex';
      case 6: return 'Sáb';
      case 7: return 'Dom';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if _weekDays is empty, show a loading indicator or a default view
    if (_weekDays.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          title: const Text(
            'Carregando...', // Loading text
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91E63)))),
      );
    }

    // Format the date for the app bar title
    final DateFormat formatter = DateFormat("d 'de' MMM.", 'pt_BR');
    final String formattedDate = formatter.format(_selectedDate);
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false, // Add this line to prevent default leading widget
        title: Text(
          formattedDate,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        // Removed the leading IconButton with Icons.menu
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Open search
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              // Open filter
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () {
              // Open calendar
            },
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {
              // Open help
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Day selector
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _weekDays.length,
              itemBuilder: (context, index) {
                final day = _weekDays[index];
                final isSelected = index == _selectedDayIndex;
                
                return GestureDetector(
                  onTap: () => _selectDay(index),
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFE91E63) : const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getDayName(day.weekday),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          day.day.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Empty state
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Background pattern (subtle grid)
                  Opacity(
                    opacity: 0.1,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(60),
                      ),
                    ),
                  ),
                  // Calendar icon with plus button
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE91E63).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.calendar_today,
                            size: 60,
                            color: Color(0xFFE91E63),
                          ),
                        ),
                      ),
                      Positioned(
                        right: -10,
                        bottom: -10,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00BFA5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Não há nada programado',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Adicionar novas atividades',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Premium badge
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE91E63), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.star,
                      color: Color(0xFFE91E63),
                      size: 20,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Premium',
                      style: TextStyle(
                        color: Color(0xFFE91E63),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(
          color: Color(0xFFE91E63),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
      // Removed duplicate bottom navigation bar
    );
  }
}
