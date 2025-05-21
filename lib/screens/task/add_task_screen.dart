import 'package:flutter/material.dart';
import 'package:myapp/models/task.dart';
import 'package:myapp/services/service_provider.dart';
import 'package:uuid/uuid.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? taskToEdit; // Optional task for editing

  const AddTaskScreen({super.key, this.taskToEdit});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  String? _selectedCategory;
  DateTime? _selectedDueDate;
  TimeOfDay? _selectedReminderTime;
  bool _isLoading = false;
  bool get _isEditing => widget.taskToEdit != null;

  final Uuid uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.taskToEdit?.title ?? '');
    _descriptionController = TextEditingController(text: widget.taskToEdit?.description ?? '');
    _selectedCategory = widget.taskToEdit?.category;
    _selectedDueDate = widget.taskToEdit?.dueDate;
    _selectedReminderTime = widget.taskToEdit?.reminderTime;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)), // Allow past dates for editing
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  Future<void> _selectReminderTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedReminderTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedReminderTime) {
      setState(() {
        _selectedReminderTime = picked;
      });
    }
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final taskService = ServiceProvider.of(context)!.taskService;

      try {
        if (_isEditing) {
          final updatedTask = widget.taskToEdit!.copyWith(
            title: _titleController.text,
            description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
            category: _selectedCategory,
            dueDate: _selectedDueDate,
            reminderTime: _selectedReminderTime,
            updatedAt: DateTime.now(),
          );
          final success = await taskService.updateTask(updatedTask);
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Task updated successfully!')),
            );
            Navigator.of(context).pop(true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to update task.')),
            );
          }
        } else {
          final newTask = Task(
            id: uuid.v4(), 
            title: _titleController.text,
            description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
            category: _selectedCategory,
            type: TaskType.yesNo, 
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            dueDate: _selectedDueDate,
            reminderTime: _selectedReminderTime,
            completionHistory: {},
          );
          final taskId = await taskService.addTask(newTask);
          if (taskId != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Task added successfully!')),
            );
            Navigator.of(context).pop(true); 
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to add task.')),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'Add New Task'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Task Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
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
                      items: <String>['Work', 'Personal', 'Health', 'Learning', 'Other']
                          .map<DropdownMenuItem<String>>((String value) {
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
                    ListTile(
                      title: Text(_selectedDueDate == null
                          ? 'Select Due Date (Optional)'
                          : 'Due Date: ${_selectedDueDate!.toLocal().toString().split(' ')[0]}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDueDate(context),
                    ),
                    ListTile(
                      title: Text(_selectedReminderTime == null
                          ? 'Select Reminder Time (Optional)'
                          : 'Reminder Time: ${_selectedReminderTime!.format(context)}'),
                      trailing: const Icon(Icons.access_time),
                      onTap: () => _selectReminderTime(context),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveTask,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        _isEditing ? 'Update Task' : 'Add Task',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
