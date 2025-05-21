import 'package:flutter/material.dart';
import 'package:myapp/models/task.dart'; // Ensure Task and TaskType are correctly defined
import 'package:myapp/services/service_provider.dart';
import 'package:myapp/theme/app_theme.dart'; // Ensure AppTheme is available
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart'; // Added import for DateFormat

class AddTaskScreen extends StatefulWidget {
  final Task? taskToEdit;

  const AddTaskScreen({super.key, this.taskToEdit});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  
  String? _selectedCategory;
  TaskType _selectedTaskType = TaskType.yesNo; // Default task type
  DateTime? _selectedDueDate;
  TimeOfDay? _selectedReminderTime;
  bool _notificationsEnabled = false; // Added for consistency with habits

  bool _isLoading = false;
  String? _errorMessage;

  bool get _isEditing => widget.taskToEdit != null;
  final Uuid uuid = const Uuid();

  // Define some default categories
  final List<String> _taskCategories = ['Work', 'Personal', 'Study', 'Health', 'Finance', 'Home', 'Other'];


  @override
  void initState() {
    super.initState();
    if (_isEditing && widget.taskToEdit != null) {
      final task = widget.taskToEdit!;
      _titleController = TextEditingController(text: task.title);
      _descriptionController = TextEditingController(text: task.description ?? '');
      _selectedCategory = task.category;
      _selectedTaskType = task.type;
      _selectedDueDate = task.dueDate;
      _selectedReminderTime = task.reminderTime;
      _notificationsEnabled = task.notificationsEnabled; // Corrected: Assuming Task model will have this
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      // Set default category if needed, e.g., _selectedCategory = _taskCategories[0];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate(BuildContext context) async {
    if (!mounted) return;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDueDate) {
      if (!mounted) return;
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  Future<void> _selectReminderTime(BuildContext context) async {
    if (!mounted) return;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedReminderTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedReminderTime) {
      if (!mounted) return;
      setState(() {
        _selectedReminderTime = picked;
      });
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final taskService = ServiceProvider.of(context).taskService;
      // final notificationService = ServiceProvider.of(context).notificationService; // If tasks have notifications
      final now = DateTime.now();
      String taskIdForNotifications;

      if (_isEditing) {
        final updatedTask = widget.taskToEdit!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
          category: _selectedCategory,
          type: _selectedTaskType,
          dueDate: _selectedDueDate,
          reminderTime: _notificationsEnabled ? _selectedReminderTime : null,
          notificationsEnabled: _notificationsEnabled, // Corrected: Assuming Task model will have this
          updatedAt: now,
        );
        final success = await taskService.updateTask(updatedTask);
        if (!success) {
          throw Exception('Failed to update task.');
        }
        taskIdForNotifications = updatedTask.id;
      } else {
        final newTaskData = Task(
          id: uuid.v4(), // ID for the data payload
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
          category: _selectedCategory,
          type: _selectedTaskType,
          dueDate: _selectedDueDate,
          reminderTime: _notificationsEnabled ? _selectedReminderTime : null,
          notificationsEnabled: _notificationsEnabled, // Corrected: Assuming Task model will have this
          createdAt: now,
          updatedAt: now,
          isCompleted: false, // Default for new tasks
          completionHistory: {}, // Default for new tasks
        );
        final String? firestoreDocId = await taskService.addTask(newTaskData);
        if (firestoreDocId == null) {
          throw Exception("Failed to add task: Firestore did not return an ID.");
        }
        taskIdForNotifications = firestoreDocId;
      }
      
      // Example: If tasks had notifications similar to habits
      // final Task? taskForNotification = await taskService.getTask(taskIdForNotifications);
      // if (taskForNotification != null) {
      //   final taskWithCurrentFormState = taskForNotification.copyWith(
      //       reminderTime: _notificationsEnabled ? _selectedReminderTime : null,
      //       notificationsEnabled: _notificationsEnabled
      //   );
      //   if (taskWithCurrentFormState.notificationsEnabled && taskWithCurrentFormState.reminderTime != null) {
      //     // await notificationService.scheduleTaskReminder(taskWithCurrentFormState);
      //   } else if (!taskWithCurrentFormState.notificationsEnabled &&
      //              (_isEditing && widget.taskToEdit!.notificationsEnabled == true && widget.taskToEdit!.reminderTime != null)) {
      //     // await notificationService.cancelTaskReminder(taskWithCurrentFormState.id);
      //   }
      // } else {
      //   print("Error: Could not fetch task with ID $taskIdForNotifications for notification scheduling.");
      // }


      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditing ? 'Task updated successfully!' : 'Task added successfully!')),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e, s) {
      print('Error saving task: $e');
      print('Stack trace: $s');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to save task: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'Add New Task', style: TextStyle(color: AppTheme.adaptiveTextColor(Theme.of(context).colorScheme.primary))),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(color: AppTheme.adaptiveTextColor(Theme.of(context).colorScheme.primary)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold),
                        ),
                      ),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Task Title',
                        hintText: 'e.g., Buy groceries',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a task title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        hintText: 'e.g., Milk, eggs, bread',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text('Select a category'),
                      isExpanded: true,
                      items: _taskCategories.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                     DropdownButtonFormField<TaskType>(
                      value: _selectedTaskType,
                      decoration: const InputDecoration(
                        labelText: 'Task Type',
                        border: OutlineInputBorder(),
                      ),
                      items: TaskType.values.map((TaskType type) {
                        return DropdownMenuItem<TaskType>(
                          value: type,
                          child: Text(type.toString().split('.').last), // Display enum name
                        );
                      }).toList(),
                      onChanged: (TaskType? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedTaskType = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: Text(_selectedDueDate == null
                          ? 'Select Due Date (Optional)'
                          : 'Due Date: ${DateFormat.yMMMd().format(_selectedDueDate!)}'),
                      onTap: () => _selectDueDate(context),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Theme.of(context).dividerColor),
                      ),
                    ),
                    const SizedBox(height:16),
                    // Reminder Section (Optional, similar to AddHabitScreen)
                    SwitchListTile(
                        title: const Text('Enable Reminder'),
                        value: _notificationsEnabled,
                        activeColor: Theme.of(context).colorScheme.primary,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (value) {
                            setState(() {
                                _notificationsEnabled = value;
                                if(_notificationsEnabled && _selectedReminderTime == null){
                                    _selectReminderTime(context);
                                }
                            });
                        },
                    ),
                    if (_notificationsEnabled)
                        ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.access_time),
                            title: Text(_selectedReminderTime == null
                                ? 'Select Reminder Time'
                                : 'Reminder: ${MaterialLocalizations.of(context).formatTimeOfDay(_selectedReminderTime!)}'),
                            onTap: () => _selectReminderTime(context),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: Theme.of(context).dividerColor),
                            ),
                        ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: _isLoading ? Container() : Icon(_isEditing ? Icons.save_alt : Icons.add_task),
                        label: _isLoading 
                               ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                               : Text(_isEditing ? 'Update Task' : 'Add Task'),
                        onPressed: _isLoading ? null : _saveTask,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: AppTheme.adaptiveTextColor(Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// Ensure AppTheme.adaptiveTextColor is defined in your AppTheme class:
// static Color adaptiveTextColor(Color backgroundColor) {
//   return backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
// }
