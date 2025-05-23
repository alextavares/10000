import 'package:flutter/material.dart';
import 'package:myapp/models/habit.dart'; // For HabitFrequency and HabitTrackingType
import 'add_habit_schedule_screen.dart'; // The next screen in the flow

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
  HabitFrequency? _selectedFrequency = HabitFrequency.daily; // Default selection

  // Options now use HabitFrequency directly
  final Map<HabitFrequency, String> _frequencyOptions = {
    HabitFrequency.daily: 'Todos os dias',
    HabitFrequency.weekly: 'Alguns dias da semana', // Maps to weekly
    HabitFrequency.monthly: 'Dias específicos do mês', // Maps to monthly
    // For more specific custom cycles like 'specificYearDays', 'sometimesPerPeriod', 'repeat'
    // they would map to HabitFrequency.custom and require further UI for configuration.
    // For simplicity in this step, we will map them to custom or offer a subset.
    // Let's assume 'custom' will cover these for now, and details handled in AddHabitScheduleScreen or a dedicated screen.
    HabitFrequency.custom: 'Outra frequência (personalizada)', 
  };

  // Placeholder for days of the week if weekly is selected. This would typically be handled by a multi-selector UI.
  final List<int> _selectedWeekDays = [];

  @override
  void initState() {
    super.initState();
    // Print received data for verification
    print("AddHabitFrequencyScreen received: category=${widget.selectedCategoryName}, title=${widget.habitTitle}, trackingType=${widget.selectedTrackingType}");
  }

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
        child: ListView( // Changed to ListView to accommodate potential week day selector
          children: [
            ..._frequencyOptions.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: RadioListTile<HabitFrequency>(
                  title: Text(entry.value, style: const TextStyle(color: Colors.white)),
                  value: entry.key,
                  groupValue: _selectedFrequency,
                  onChanged: (HabitFrequency? value) {
                    setState(() {
                      _selectedFrequency = value;
                      if (_selectedFrequency != HabitFrequency.weekly) {
                        _selectedWeekDays.clear(); // Clear weekdays if not weekly
                      }
                    });
                  },
                  activeColor: Colors.pinkAccent,
                  controlAffinity: ListTileControlAffinity.trailing,
                  tileColor: Colors.grey[850],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              );
            }),

            // Simple day selector for weekly frequency (can be improved)
            if (_selectedFrequency == HabitFrequency.weekly)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Selecione os dias da semana:', style: TextStyle(color: Colors.white, fontSize: 16)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: List.generate(7, (index) {
                        final dayIndex = index + 1; // 1 for Monday, 7 for Sunday
                        final dayName = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'][index];
                        final isSelected = _selectedWeekDays.contains(dayIndex);
                        return ChoiceChip(
                          label: Text(dayName),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedWeekDays.add(dayIndex);
                              } else {
                                _selectedWeekDays.remove(dayIndex);
                              }
                              _selectedWeekDays.sort(); // Keep them in order
                            });
                          },
                          backgroundColor: Colors.grey[700],
                          selectedColor: Colors.pinkAccent,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70),
                        );
                      }).toList(),
                    ),
                    if (_selectedWeekDays.isEmpty)
                       Padding(
                         padding: const EdgeInsets.only(top:8.0),
                         child: Text('Por favor, selecione pelo menos um dia.', style: TextStyle(color: Colors.redAccent.shade100, fontSize: 12)),
                       )
                  ],
                ),
              ),
          ],
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
              onPressed: (_selectedFrequency != null && 
                         (_selectedFrequency != HabitFrequency.weekly || _selectedWeekDays.isNotEmpty)) 
              ? () {
                if (_selectedFrequency != null) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AddHabitScheduleScreen(
                      selectedCategoryName: widget.selectedCategoryName,
                      selectedCategoryIcon: widget.selectedCategoryIcon,
                      selectedCategoryColor: widget.selectedCategoryColor,
                      habitTitle: widget.habitTitle,
                      habitDescription: widget.habitDescription,
                      selectedTrackingType: widget.selectedTrackingType,
                      selectedFrequency: _selectedFrequency!,
                      selectedDaysOfWeek: _selectedFrequency == HabitFrequency.weekly ? _selectedWeekDays : null,
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
                 disabledBackgroundColor: Colors.grey[600],
              ),
              child: const Text('PRÓXIMA', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
