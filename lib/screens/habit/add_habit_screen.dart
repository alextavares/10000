import 'package:flutter/material.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/services/service_provider.dart';
import 'package:uuid/uuid.dart'; // Import Uuid package

/// Screen for adding or editing a habit.
class AddHabitScreen extends StatefulWidget {
  final Habit? habitToEdit; // Optional habit for editing

  /// Constructor for AddHabitScreen.
  const AddHabitScreen({super.key, this.habitToEdit});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  String _selectedCategory = 'Health';
  HabitFrequency _selectedFrequency = HabitFrequency.daily;
  List<int> _selectedDays = [];
  TimeOfDay? _reminderTime;
  bool _notificationsEnabled = false;
  bool _isLoading = false;
  String? _errorMessage;

  bool get _isEditing => widget.habitToEdit != null;
  final Uuid uuid = const Uuid(); // UUID generator

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
  void initState() {
    super.initState();
    if (_isEditing && widget.habitToEdit != null) {
      final habit = widget.habitToEdit!;
      _titleController = TextEditingController(text: habit.title);
      _descriptionController = TextEditingController(text: habit.description ?? '');
      _selectedCategory = habit.category;
      _selectedFrequency = habit.frequency;
      _selectedDays = List<int>.from(habit.daysOfWeek ?? []);
      _reminderTime = habit.reminderTime;
      _notificationsEnabled = habit.notificationsEnabled;
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _selectedDays = [1, 2, 3, 4, 5, 6, 7];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final habitService = context.habitService;
      final notificationService = context.notificationService;
      final now = DateTime.now();
      String habitIdForNotifications;

      if (_isEditing) {
        final updatedHabit = widget.habitToEdit!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
          category: _selectedCategory,
          icon: _getCategoryIcon(_selectedCategory),
          color: _getCategoryColor(_selectedCategory),
          frequency: _selectedFrequency,
          daysOfWeek: _selectedFrequency == HabitFrequency.weekly ||
                  _selectedFrequency == HabitFrequency.custom
              ? _selectedDays
              : null,
          reminderTime: _notificationsEnabled ? _reminderTime : null,
          notificationsEnabled: _notificationsEnabled,
          updatedAt: now,
        );
        await habitService.updateHabit(updatedHabit);
        habitIdForNotifications = updatedHabit.id;
      } else {
        final newHabitData = Habit(
          id: uuid.v4(),
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
          createdAt: now,
          updatedAt: now,
          completionHistory: {},
          streak: 0,
          longestStreak: 0,
          totalCompletions: 0,
        );
        final String? firestoreDocId = await habitService.addHabit(newHabitData);
        if (firestoreDocId == null) {
          throw Exception("Failed to add habit: Firestore did not return an ID.");
        }
        habitIdForNotifications = firestoreDocId;
      }

      final Habit? habitForNotification = await habitService.getHabit(habitIdForNotifications);

      if (habitForNotification != null) {
         final habitWithCurrentFormState = habitForNotification.copyWith(
            reminderTime: _notificationsEnabled ? _reminderTime : null,
            notificationsEnabled: _notificationsEnabled
        );

        if (habitWithCurrentFormState.notificationsEnabled && habitWithCurrentFormState.reminderTime != null) {
          await notificationService.scheduleHabitReminder(habitWithCurrentFormState);
        } else if (!habitWithCurrentFormState.notificationsEnabled &&
                   (_isEditing && widget.habitToEdit!.notificationsEnabled && widget.habitToEdit!.reminderTime != null)) {
          await notificationService.cancelHabitReminder(habitWithCurrentFormState);
        }
      } else {
        print("Error: Could not fetch habit with ID $habitIdForNotifications for notification scheduling.");
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e, s) {
      print('Error saving habit: $e');
      print('Stack trace: $s');
      if(mounted){
        setState(() {
          _errorMessage = 'Failed to save habit: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _getAISuggestions() async {
    if (!mounted) return;
    // Consider if title is needed for suggestions or if category is enough
    // if (_titleController.text.trim().isEmpty && !_isEditing) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Please enter a habit title first or select a category for relevant suggestions')),
    //   );
    //   return;
    // }

    setState(() {
      _isLoading = true;
    });

    try {
      final categoryForSuggestions = _selectedCategory; // Using selected category for context
      final suggestions = await context.aiService.generateHabitSuggestions(
        categoryForSuggestions,
        // _titleController.text.trim(), // Optionally pass current title as well
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        showDialog(
          context: context,
          builder: (BuildContext dialogContext) => AlertDialog(
            title: const Text('AI Suggestions'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: suggestions.map((suggestion) {
                  return ListTile(
                    title: Text(suggestion),
                    onTap: () {
                      if (mounted) {
                        setState(() {
                          _titleController.text = suggestion;
                          // Optionally, you could try to parse category or description if your AI provides richer suggestions
                          // For example, if suggestion is "Drink water (Health)", you could parse "Health" for category.
                        });
                        Navigator.pop(dialogContext); // Close the dialog
                      }
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Habit' : 'Add New Habit'),
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

                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description (Optional)',
                          hintText: 'e.g., Drink 8 glasses of water daily',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

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
                            if (_selectedFrequency == HabitFrequency.daily || _selectedFrequency == HabitFrequency.monthly) {
                              _selectedDays = [];
                            } else if (_selectedDays.isEmpty && (_selectedFrequency == HabitFrequency.weekly || _selectedFrequency == HabitFrequency.custom)) {
                               _selectedDays = [1,2,3,4,5,6,7];
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      if (_selectedFrequency == HabitFrequency.weekly ||
                          _selectedFrequency == HabitFrequency.custom)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Days of Week',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
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

                      SwitchListTile(
                        title: const Text('Enable Reminders'),
                        value: _notificationsEnabled,
                        activeColor: AppTheme.primaryColor,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                            if (_notificationsEnabled && _reminderTime == null) {
                              _selectReminderTime();
                            }
                          });
                        },
                      ),

                      if (_notificationsEnabled)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Reminder Time'),
                          subtitle: Text(
                            _reminderTime != null
                                ? _formatTimeOfDay(_reminderTime!)
                                : 'Not set (Tap to select)',
                          ),
                          trailing: const Icon(Icons.access_time),
                          onTap: _selectReminderTime,
                        ),
                      const SizedBox(height: 24),

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

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveHabit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Text(
                               _isEditing ? 'Update Habit' : 'Save Habit',
                                style: const TextStyle(
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

  Future<void> _selectReminderTime() async {
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
    );
    if (time != null && mounted) {
      setState(() {
        _reminderTime = time;
      });
    }
  }

  Widget _buildDayChip(int day, String label) {
    final isSelected = _selectedDays.contains(day);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            if (!_selectedDays.contains(day)) _selectedDays.add(day);
          } else {
            if ((_selectedFrequency == HabitFrequency.weekly || _selectedFrequency == HabitFrequency.custom) && _selectedDays.length == 1 && _selectedDays.contains(day)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('At least one day must be selected for weekly/custom frequency.')),
              );
              return;
            }
            _selectedDays.remove(day);
          }
        });
      },
      backgroundColor: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : AppTheme.surfaceColor.withOpacity(0.5),
      selectedColor: AppTheme.primaryColor.withOpacity(0.3),
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryColor : AppTheme.textColor.withOpacity(0.8),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: StadiumBorder(side: BorderSide(color: isSelected ? AppTheme.primaryColor : Colors.grey.withOpacity(0.5))),
    );
  }

  String _getFrequencyText(HabitFrequency frequency) {
    switch (frequency) {
      case HabitFrequency.daily:
        return 'Daily';
      case HabitFrequency.weekly:
        return 'Weekly';
      case HabitFrequency.monthly:
        return 'Monthly';
      case HabitFrequency.custom:
        return 'Custom (Select Days)';
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    if (!mounted) return "";
    final localizations = MaterialLocalizations.of(context);
    return localizations.formatTimeOfDay(time, alwaysUse24HourFormat: MediaQuery.of(context).alwaysUse24HourFormat);
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'health':
        return Icons.favorite_border;
      case 'fitness':
        return Icons.fitness_center;
      case 'productivity':
        return Icons.work_outline;
      case 'education':
        return Icons.school_outlined;
      case 'finance':
        return Icons.attach_money;
      case 'social':
        return Icons.people_outline;
      case 'mindfulness':
        return Icons.self_improvement_outlined;
      case 'creativity':
        return Icons.brush_outlined;
      default:
        return Icons.star_border;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'health':
        return Colors.redAccent;
      case 'fitness':
        return Colors.lightBlueAccent;
      case 'productivity':
        return Colors.greenAccent;
      case 'education':
        return Colors.purpleAccent;
      case 'finance':
        return Colors.amberAccent;
      case 'social':
        return Colors.pinkAccent;
      case 'mindfulness':
        return Colors.tealAccent;
      case 'creativity':
        return Colors.orangeAccent;
      default:
        return AppTheme.primaryColor;
    }
  }
}
