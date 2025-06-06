import 'package:flutter/material.dart';
import 'package:myapp/models/recurring_task.dart';
import 'package:myapp/screens/recurring_task/add_recurring_task_schedule_screen.dart';

class AddRecurringTaskFrequencyScreen extends StatefulWidget {
  final RecurringTaskTrackingType trackingType;
  final String category;
  final String title;
  final String? description;
  final RecurringTask? recurringTaskToEdit;

  const AddRecurringTaskFrequencyScreen({
    super.key,
    required this.trackingType,
    required this.category,
    required this.title,
    this.description,
    this.recurringTaskToEdit,
  });

  @override
  State<AddRecurringTaskFrequencyScreen> createState() => _AddRecurringTaskFrequencyScreenState();
}

class _AddRecurringTaskFrequencyScreenState extends State<AddRecurringTaskFrequencyScreen> {
  RecurringTaskFrequency selectedFrequency = RecurringTaskFrequency.daily;

  final List<Map<String, dynamic>> frequencyOptions = [
    {
      'frequency': RecurringTaskFrequency.daily,
      'title': 'Todos os dias',
      'selected': true,
    },
    {
      'frequency': RecurringTaskFrequency.someDaysOfWeek,
      'title': 'Alguns dias da semana',
      'selected': false,
    },
    {
      'frequency': RecurringTaskFrequency.specificDaysOfMonth,
      'title': 'Dias específicos do mês',
      'selected': false,
    },
    {
      'frequency': RecurringTaskFrequency.specificDaysOfYear,
      'title': 'Dias específicos do ano',
      'selected': false,
    },
    {
      'frequency': RecurringTaskFrequency.someTimesPerPeriod,
      'title': 'Algumas vezes por período',
      'selected': false,
    },
    {
      'frequency': RecurringTaskFrequency.repeat,
      'title': 'Repetir',
      'selected': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.recurringTaskToEdit != null) {
      selectedFrequency = widget.recurringTaskToEdit!.frequency;
      _updateSelection();
    }
  }

  void _updateSelection() {
    for (var option in frequencyOptions) {
      option['selected'] = option['frequency'] == selectedFrequency;
    }
  }

  void _selectFrequency(RecurringTaskFrequency frequency) {
    setState(() {
      selectedFrequency = frequency;
      _updateSelection();
    });
  }

  void _navigateToNextStep() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddRecurringTaskScheduleScreen(
          trackingType: widget.trackingType,
          category: widget.category,
          title: widget.title,
          description: widget.description,
          frequency: selectedFrequency,
          recurringTaskToEdit: widget.recurringTaskToEdit,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Com que frequência você deseja fazer isso?',
          style: TextStyle(
            color: Color(0xFFE91E63),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(24.0),
                itemCount: frequencyOptions.length,
                itemBuilder: (context, index) {
                  final option = frequencyOptions[index];
                  return _buildFrequencyOption(
                    title: option['title'],
                    frequency: option['frequency'],
                    isSelected: option['selected'],
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        child: const Text(
                          'ANTERIOR',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _navigateToNextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE91E63),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'PRÓXIMA',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Indicadores de progresso
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE91E63),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyOption({
    required String title,
    required RecurringTaskFrequency frequency,
    required bool isSelected,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectFrequency(frequency),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? const Color(0xFFE91E63) : Colors.grey,
                      width: 2,
                    ),
                    color: isSelected ? const Color(0xFFE91E63) : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.circle,
                          color: Colors.white,
                          size: 12,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
