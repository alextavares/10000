import 'package:flutter/material.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/services/service_provider.dart';

/// Screen for adding a new habit.
class AddHabitScreen extends StatefulWidget {
  /// Constructor for AddHabitScreen.
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'Health';
  HabitFrequency _selectedFrequency = HabitFrequency.daily;
  final List<int> _selectedDays = [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
  ]; // All days selected by default
  TimeOfDay? _reminderTime;
  bool _notificationsEnabled = false;
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _categories = [
    'Health',
    'Fitness',
    'Productivity',
    'Education',
    'Finance',
    'Social',
    'Mindfulness',
    'Creativity',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Saves the new habit.
  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create a new habit
      final habit = Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description:
            _descriptionController.text.trim().isNotEmpty
                ? _descriptionController.text.trim()
                : null,
        category: _selectedCategory,
        icon: _getCategoryIcon(_selectedCategory),
        color: _getCategoryColor(_selectedCategory),
        frequency: _selectedFrequency,
        daysOfWeek:
            _selectedFrequency == HabitFrequency.weekly ||
                    _selectedFrequency == HabitFrequency.custom
                ? _selectedDays
                : null,
        reminderTime: _notificationsEnabled ? _reminderTime : null,
        notificationsEnabled: _notificationsEnabled,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        completionHistory: {},
      );

      // Save the habit
      await context.habitService.addHabit(habit);

      // Schedule notification if enabled
      if (_notificationsEnabled && _reminderTime != null) {
        await context.notificationService.scheduleHabitReminder(habit);
      }

      // Return to previous screen
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save habit: $e';
        _isLoading = false;
      });
      print('Error saving habit: $e');
    }
  }

  /// Gets AI suggestions for the habit.
  Future<void> _getAISuggestions() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a habit title first')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final suggestions = await context.aiService.generateHabitSuggestions(
        _selectedCategory,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show suggestions dialog
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('AI Suggestions'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final suggestion in suggestions)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text('• $suggestion'),
                        ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Close'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get AI suggestions: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Habit'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: AppTheme.errorColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      // Title
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Habit Title',
                          hintText: 'e.g., Drink water',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description (Optional)',
                          hintText: 'e.g., Drink 8 glasses of water daily',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Category
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                        items:
                            _categories.map((category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Frequency
                      DropdownButtonFormField<HabitFrequency>(
                        value: _selectedFrequency,
                        decoration: const InputDecoration(
                          labelText: 'Frequency',
                        ),
                        items:
                            HabitFrequency.values.map((frequency) {
                              return DropdownMenuItem<HabitFrequency>(
                                value: frequency,
                                child: Text(_getFrequencyText(frequency)),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedFrequency = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Days of week (for weekly frequency)
                      if (_selectedFrequency == HabitFrequency.weekly ||
                          _selectedFrequency == HabitFrequency.custom)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Days of Week',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: [
                                _buildDayChip(1, 'Mon'),
                                _buildDayChip(2, 'Tue'),
                                _buildDayChip(3, 'Wed'),
                                _buildDayChip(4, 'Thu'),
                                _buildDayChip(5, 'Fri'),
                                _buildDayChip(6, 'Sat'),
                                _buildDayChip(7, 'Sun'),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),

                      // Reminder
                      SwitchListTile(
                        title: const Text('Enable Reminders'),
                        value: _notificationsEnabled,
                        activeColor: AppTheme.primaryColor,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                        },
                      ),

                      // Reminder time
                      if (_notificationsEnabled)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Reminder Time'),
                          subtitle: Text(
                            _reminderTime != null
                                ? _formatTimeOfDay(_reminderTime!)
                                : 'Not set',
                          ),
                          trailing: const Icon(Icons.access_time),
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: _reminderTime ?? TimeOfDay.now(),
                            );
                            if (time != null) {
                              setState(() {
                                _reminderTime = time;
                              });
                            }
                          },
                        ),
                      const SizedBox(height: 24),

                      // AI Suggestions button
                      Center(
                        child: OutlinedButton.icon(
                          onPressed: _getAISuggestions,
                          icon: Icon(
                            Icons.lightbulb_outline,
                            color: AppTheme.aiPrimaryColor,
                          ),
                          label: Text(
                            'Get AI Suggestions',
                            style: TextStyle(color: AppTheme.aiPrimaryColor),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppTheme.aiPrimaryColor),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveHabit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Save Habit',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  /// Builds a day of week chip.
  Widget _buildDayChip(int day, String label) {
    final isSelected = _selectedDays.contains(day);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedDays.add(day);
          } else {
            _selectedDays.remove(day);
          }
          // Ensure at least one day is selected
          if (_selectedDays.isEmpty) {
            _selectedDays.add(day);
          }
        });
      },
      backgroundColor: AppTheme.surfaceColor,
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryColor : AppTheme.textColor,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  /// Gets the text representation of a frequency.
  String _getFrequencyText(HabitFrequency frequency) {
    switch (frequency) {
      case HabitFrequency.daily:
        return 'Daily';
      case HabitFrequency.weekly:
        return 'Weekly';
      case HabitFrequency.monthly:
        return 'Monthly';
      case HabitFrequency.custom:
        return 'Custom';
    }
  }

  /// Formats a TimeOfDay to a string.
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  /// Gets the icon for a habit category.
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'health':
        return Icons.favorite;
      case 'fitness':
        return Icons.fitness_center;
      case 'productivity':
        return Icons.work;
      case 'education':
        return Icons.school;
      case 'finance':
        return Icons.attach_money;
      case 'social':
        return Icons.people;
      case 'mindfulness':
        return Icons.self_improvement;
      case 'creativity':
        return Icons.brush;
      default:
        return Icons.star;
    }
  }

  /// Gets the color for a habit category.
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'health':
        return Colors.red;
      case 'fitness':
        return Colors.blue;
      case 'productivity':
        return Colors.green;
      case 'education':
        return Colors.purple;
      case 'finance':
        return Colors.amber;
      case 'social':
        return Colors.pink;
      case 'mindfulness':
        return Colors.teal;
      case 'creativity':
        return Colors.orange;
      default:
        return AppTheme.primaryColor;
    }
  }
}
