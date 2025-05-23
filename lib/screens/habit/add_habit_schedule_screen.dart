import 'package:flutter/material.dart';
import 'package:myapp/models/habit.dart'; // For Enums
import 'package:myapp/services/service_provider.dart'; // To access HabitService
import 'package:intl/intl.dart'; // For date formatting

class AddHabitScheduleScreen extends StatefulWidget {
  final String selectedCategoryName;
  final IconData selectedCategoryIcon;
  final Color selectedCategoryColor;
  final String habitTitle;
  final String? habitDescription;
  final HabitTrackingType selectedTrackingType;
  final HabitFrequency selectedFrequency;
  final List<int>? selectedDaysOfWeek; // For weekly frequency

  const AddHabitScheduleScreen({
    super.key,
    required this.selectedCategoryName,
    required this.selectedCategoryIcon,
    required this.selectedCategoryColor,
    required this.habitTitle,
    this.habitDescription,
    required this.selectedTrackingType,
    required this.selectedFrequency,
    this.selectedDaysOfWeek,
  });

  @override
  State<AddHabitScheduleScreen> createState() => _AddHabitScheduleScreenState();
}

class _AddHabitScheduleScreenState extends State<AddHabitScheduleScreen> {
  DateTime _startDate = DateTime.now();
  DateTime? _targetDate;
  TimeOfDay? _reminderTime;
  bool _notificationsEnabled = false;
  // String _priority = 'Normal'; // TODO: Implement priority selection

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Ensure start date is not in the past if today is picked, or adjust as needed.
    // For simplicity, allow today. If user picks a past date, DatePicker firstDate handles it.
    print("AddHabitScheduleScreen received: title=${widget.habitTitle}, tracking=${widget.selectedTrackingType}, freq=${widget.selectedFrequency}");
  }

  Future<void> _selectDate(BuildContext context, bool isTargetDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isTargetDate 
          ? (_targetDate ?? (_startDate.isBefore(DateTime.now()) ? DateTime.now().add(const Duration(days:1)) : _startDate.add(const Duration(days: 1)))) 
          : _startDate,
      firstDate: isTargetDate 
          ? (_startDate.isBefore(DateTime.now()) ? DateTime.now().add(const Duration(days:1)) : _startDate.add(const Duration(days: 1))) 
          : DateTime(DateTime.now().year - 5), // Allow past start dates up to 5 years
      lastDate: DateTime(DateTime.now().year + 5),
      helpText: isTargetDate ? 'SELECIONE A DATA ALVO' : 'SELECIONE A DATA DE INÍCIO',
      cancelText: 'CANCELAR',
      confirmText: 'OK',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.pinkAccent, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black87, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.pinkAccent, // button text color
              ),
            ),
          ),
          child: child!,
        );
      }
    );
    if (picked != null) {
      setState(() {
        if (isTargetDate) {
          _targetDate = picked;
        } else {
          _startDate = picked;
          if (_targetDate != null && _startDate.isAfter(_targetDate!)) {
            _targetDate = _startDate.add(const Duration(days: 1)); 
          }
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
      helpText: 'SELECIONE O HORÁRIO DO LEMBRETE',
      cancelText: 'CANCELAR',
      confirmText: 'OK',
       builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
             colorScheme: const ColorScheme.light(
              primary: Colors.pinkAccent,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
              surface: Colors.white, // Background of time picker dial
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.grey[900], // Overall background
              hourMinuteTextColor: WidgetStateColor.resolveWith((states) => states.contains(WidgetState.selected) ? Colors.pinkAccent : Colors.white70),
              hourMinuteColor: WidgetStateColor.resolveWith((states) => states.contains(WidgetState.selected) ? Colors.pinkAccent.withOpacity(0.15) : Colors.grey[800]!),
              dayPeriodTextColor: WidgetStateColor.resolveWith((states) => states.contains(WidgetState.selected) ? Colors.pinkAccent : Colors.white70),
              dayPeriodColor: WidgetStateColor.resolveWith((states) => states.contains(WidgetState.selected) ? Colors.pinkAccent.withOpacity(0.15) : Colors.grey[800]!),
              dialHandColor: Colors.pinkAccent,
              dialTextColor: WidgetStateColor.resolveWith((states) => states.contains(WidgetState.selected) ? Colors.white : Colors.pinkAccent.withOpacity(0.7)),
              entryModeIconColor: Colors.pinkAccent,
              dialBackgroundColor: Colors.grey[850], // Corrected
              helpTextStyle: const TextStyle(color: Colors.white70)
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.pinkAccent,
              ),
            ),
          ),
          child: child!,
        );
      }
    );
    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
        _notificationsEnabled = true; 
      });
    }
  }

  Future<void> _saveHabit() async {
    // No form validation needed for this screen as inputs are via pickers or defaults
    // if (!_formKey.currentState!.validate()) {
    //   return;
    // }
    // _formKey.currentState!.save();

    setState(() {
      _isSaving = true;
    });

    try {
      final habitService = ServiceProvider.of(context).habitService;
      await habitService.addHabit(
        title: widget.habitTitle,
        categoryName: widget.selectedCategoryName,
        categoryIcon: widget.selectedCategoryIcon,
        categoryColor: widget.selectedCategoryColor,
        description: widget.habitDescription,
        frequency: widget.selectedFrequency, // Pass the HabitFrequency enum directly
        trackingType: widget.selectedTrackingType, // Pass the HabitTrackingType enum
        daysOfWeek: widget.selectedDaysOfWeek, 
        startDate: _startDate, 
        targetDate: _targetDate,
        reminderTime: _reminderTime,
        notificationsEnabled: _notificationsEnabled,
        // priority: _priority, // TODO: Pass priority when implemented
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hábito "${widget.habitTitle}" adicionado!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      print('Error saving habit: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar o hábito: $e', style: TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent),
      );
    }
    finally {
      if(mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Quando você quer fazer isso?', style: TextStyle(color: Colors.pinkAccent, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isSaving 
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.pinkAccent))) 
          : Form( // Form is not strictly necessary here unless adding text validators later
              key: _formKey, 
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.info_outline, color: Colors.grey, size: 20),
                    title: Text(
                      'Hábito: ${widget.habitTitle}', 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
                    ),
                    subtitle: Text(
                      'Categoria: ${widget.selectedCategoryName} | Acompanhamento: ${widget.selectedTrackingType.toString().split('.').last}', 
                      style: TextStyle(color: Colors.grey[400], fontSize: 12)
                    ),
                    tileColor: Colors.grey[850],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Corrected
                  ),
                  const SizedBox(height: 20),

                  ListTile(
                    leading: const Icon(Icons.calendar_today, color: Colors.pinkAccent),
                    title: Text('Data de Início', style: TextStyle(color: Colors.white)),
                    subtitle: Text(DateFormat('dd/MM/yyyy').format(_startDate), style: TextStyle(color: Colors.grey[400])),
                    onTap: () => _selectDate(context, false),
 ),

                  ListTile(
                    leading: const Icon(Icons.flag_outlined, color: Colors.pinkAccent),
                    title: Text('Data Alvo (Opcional)', style: TextStyle(color: Colors.white)),
                    subtitle: Text(
                      _targetDate == null ? 'Não definida' : DateFormat('dd/MM/yyyy').format(_targetDate!),
                      style: TextStyle(color: Colors.grey[400])
                    ),
                    trailing: _targetDate != null ? IconButton(icon: Icon(Icons.clear, color: Colors.grey[600]), onPressed: () => setState(()=> _targetDate = null)) : null,
                    onTap: () => _selectDate(context, true),
 ),
 const Divider(color: Colors.grey),

                  ListTile(
                    leading: const Icon(Icons.alarm, color: Colors.pinkAccent),
                    title: Text('Lembrete (Opcional)', style: TextStyle(color: Colors.white)),
                    subtitle: Text(
                      _reminderTime == null ? 'Não definido' : _reminderTime!.format(context),
                      style: TextStyle(color: Colors.grey[400])
 ),
                    trailing: _reminderTime != null ? IconButton(icon: Icon(Icons.clear, color: Colors.grey[600]), onPressed: () => setState((){ _reminderTime = null; _notificationsEnabled = false;})) : null, // Corrected
 onTap: () async {
 await _selectTime(context);
 },
 ),
                  
                  if (_reminderTime != null)
                    SwitchListTile(
                      title: Text('Ativar notificações', style: TextStyle(color: Colors.white)),
                      subtitle: Text('Requer permissões do sistema', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                      value: _notificationsEnabled,
                      onChanged: (bool value) {
                        setState(() {
                          _notificationsEnabled = value;
                          // TODO: Potentially request notification permissions here if enabling
                        });
                      },
                      activeColor: Colors.pinkAccent,
                      inactiveThumbColor: Colors.grey[700],
                      inactiveTrackColor: Colors.grey[800],
 tileColor: Colors.grey[850]?.withOpacity(0.5), // Corrected
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  // const Divider(color: Colors.grey_800), // Divider can be optional after SwitchListTile
                  
                  // TODO: Priority Selector placeholder
                  // SizedBox(height: 20),
                  // Center(child: Text('Prioridade (Pendente)', style: TextStyle(color: Colors.grey[600]))),
                  // SizedBox(height: 30),
                ],
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0), // Added more bottom padding
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
              child: Text('ANTERIOR', style: TextStyle(color: _isSaving ? Colors.grey[700] : Colors.white70, fontSize: 16)),
            ),
            ElevatedButton.icon(
              icon: _isSaving 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check_circle_outline, color: Colors.white),
              label: Text(_isSaving ? 'SALVANDO...' : 'FINALIZAR', style: const TextStyle(color: Colors.white)),
              onPressed: _isSaving ? null : _saveHabit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                disabledBackgroundColor: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
