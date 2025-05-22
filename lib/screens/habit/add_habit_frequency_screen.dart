import 'package:flutter/material.dart';
import 'package:myapp/screens/habit/add_habit_details_screen.dart';

class AddHabitFrequencyScreen extends StatefulWidget {
  final String selectedCategoryName;
  final IconData selectedCategoryIcon;
  final Color selectedCategoryColor;

  const AddHabitFrequencyScreen({
    super.key,
    required this.selectedCategoryName,
    required this.selectedCategoryIcon,
    required this.selectedCategoryColor,
  });

  @override
  State<AddHabitFrequencyScreen> createState() => _AddHabitFrequencyScreenState();
}

// Renaming to avoid conflict with HabitFrequency in habit.dart model if it's different
// Consider centralizing this enum if it's meant to be the same.
enum AddHabitCycle {
  daily,
  specificWeekDays,
  specificMonthDays,
  specificYearDays,
  sometimesPerPeriod,
  repeat
}

class _AddHabitFrequencyScreenState extends State<AddHabitFrequencyScreen> {
  AddHabitCycle? _selectedCycle = AddHabitCycle.daily; // Default selection

  final Map<AddHabitCycle, String> _cycleOptions = {
    AddHabitCycle.daily: 'Todos os dias',
    AddHabitCycle.specificWeekDays: 'Alguns dias da semana',
    AddHabitCycle.specificMonthDays: 'Dias específicos do mês',
    AddHabitCycle.specificYearDays: 'Dias específicos do ano',
    AddHabitCycle.sometimesPerPeriod: 'Algumas vezes por período',
    AddHabitCycle.repeat: 'Repetir',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Com que frequência você deseja fazer isso?',
          style: TextStyle(color: Colors.pinkAccent, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: _cycleOptions.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: RadioListTile<AddHabitCycle>(
                title: Text(entry.value, style: const TextStyle(color: Colors.white)),
                value: entry.key,
                groupValue: _selectedCycle,
                onChanged: (AddHabitCycle? value) {
                  setState(() {
                    _selectedCycle = value;
                  });
                },
                activeColor: Colors.pinkAccent,
                controlAffinity: ListTileControlAffinity.trailing,
                tileColor: Colors.grey[850],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            );
          }).toList(),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'ANTERIOR',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: _selectedCycle != null ? () {
                if (_selectedCycle != null) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AddHabitDetailsScreen(
                      selectedCategoryName: widget.selectedCategoryName,
                      selectedCategoryIcon: widget.selectedCategoryIcon, // Pass icon
                      selectedCategoryColor: widget.selectedCategoryColor, // Pass color
                      selectedFrequencyEnumFromScreen: _selectedCycle!, // Pass the enum from this screen
                    ),
                  ));
                }
              } : null, 
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('PRÓXIMA', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
