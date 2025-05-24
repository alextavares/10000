import 'package:flutter/material.dart';
import 'package:myapp/models/habit.dart'; // For Enums
import 'package:myapp/services/service_provider.dart'; // To access HabitService
import 'package:intl/intl.dart'; // For date formatting
import 'package:flutter/services.dart'; // Required for TextInputFormatter

class AddHabitScheduleScreen extends StatefulWidget {
  final String selectedCategoryName;
  final IconData selectedCategoryIcon;
  final Color selectedCategoryColor;
  final String habitTitle;
  final String? habitDescription; // Corrected: This is passed from the previous screen
  final HabitTrackingType selectedTrackingType;
  final HabitFrequency selectedFrequency;
  final List<int>? selectedDaysOfWeek; // For weekly frequency

  const AddHabitScheduleScreen({
    super.key,
    required this.selectedCategoryName,
    required this.selectedCategoryIcon,
    required this.selectedCategoryColor,
    required this.habitTitle,
    this.habitDescription, // Ensured it's here
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

  // New state variables for Target Date Switch and Duration
  bool _isTargetDateEnabled = false;
  int? _targetDurationDays;
  final TextEditingController _daysController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Ensure start date is not in the past if today is picked, or adjust as needed.
    // For simplicity, allow today. If user picks a past date, DatePicker firstDate handles it.
    // print(
    //     "AddHabitScheduleScreen received: title=${widget.habitTitle}, tracking=${widget.selectedTrackingType}, freq=${widget.selectedFrequency}");
    
    _daysController.addListener(() {
      final days = int.tryParse(_daysController.text);
      if (days != null && days > 0) {
        setState(() {
          _targetDurationDays = days;
          _targetDate = _startDate.add(Duration(days: _targetDurationDays!));
        });
      } else if (_daysController.text.isEmpty) {
        setState(() {
          _targetDurationDays = null;
          // _targetDate = null; // Keep existing target date if days are cleared, user can clear via date picker or switch
        });
      }
    });
  }

  @override
  void dispose() {
    _daysController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isTargetDate) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: isTargetDate
            ? (_targetDate ??
                (_startDate.isBefore(DateTime.now())
                    ? DateTime.now().add(const Duration(days: 1))
                    : _startDate.add(const Duration(days: 1))))
            : _startDate,
        firstDate: isTargetDate
            ? (_startDate.isBefore(DateTime.now())
                ? DateTime.now().add(const Duration(days: 1))
                : _startDate.add(const Duration(days: 1)))
            : DateTime(DateTime.now().year -
                5), // Allow past start dates up to 5 years
        lastDate: DateTime(DateTime.now().year + 5),
        helpText: isTargetDate
            ? 'SELECIONE A DATA ALVO'
            : 'SELECIONE A DATA DE INÍCIO',
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
        });
    if (picked != null) {
      setState(() {
        if (isTargetDate) {
          _targetDate = picked;
          if (_isTargetDateEnabled) { 
            if (_targetDate!.isBefore(_startDate.add(const Duration(days:1)))) {
              _targetDate = _startDate.add(const Duration(days:1)); // Ensure target is after start
            }
            _targetDurationDays = _targetDate!.difference(_startDate).inDays;
            _daysController.text = _targetDurationDays.toString();
          }
        } else {
          _startDate = picked;
          // If target date is enabled and set, and new start date is after or same as target date,
          // or if duration is set, recalculate target date based on duration.
          if (_isTargetDateEnabled) {
            if (_targetDurationDays != null && _targetDurationDays! > 0) {
              _targetDate = _startDate.add(Duration(days: _targetDurationDays!));
            } else if (_targetDate != null && !_startDate.isBefore(_targetDate!)) {
              // If no fixed duration, and start date moved beyond target, set target to day after start
              _targetDate = _startDate.add(const Duration(days: 1));
              _targetDurationDays = _targetDate!.difference(_startDate).inDays;
              _daysController.text = _targetDurationDays.toString();
            } else if (_targetDate != null){
               _targetDurationDays = _targetDate!.difference(_startDate).inDays;
               if(_targetDurationDays! <=0 ) _targetDurationDays =1; // ensure positive
              _daysController.text = _targetDurationDays.toString();
            }
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
                  hourMinuteTextColor: WidgetStateColor.resolveWith((states) =>
                      states.contains(WidgetState.selected)
                          ? Colors.pinkAccent
                          : Colors.white70),
                  hourMinuteColor: WidgetStateColor.resolveWith((states) =>
                      states.contains(WidgetState.selected)
                          ? Colors.pinkAccent.withAlpha(38) // ~0.15 opacity
                          : Colors.grey[800]!),
                  dayPeriodTextColor: WidgetStateColor.resolveWith((states) =>
                      states.contains(WidgetState.selected)
                          ? Colors.pinkAccent
                          : Colors.white70),
                  dayPeriodColor: WidgetStateColor.resolveWith((states) =>
                      states.contains(WidgetState.selected)
                          ? Colors.pinkAccent.withAlpha(38) // ~0.15 opacity
                          : Colors.grey[800]!),
                  dialHandColor: Colors.pinkAccent,
                  dialTextColor: WidgetStateColor.resolveWith((states) =>
                      states.contains(WidgetState.selected)
                          ? Colors.white
                          : Colors.pinkAccent.withAlpha(178)), // ~0.7 opacity
                  entryModeIconColor: Colors.pinkAccent,
                  dialBackgroundColor: Colors.grey[850], 
                  helpTextStyle: const TextStyle(color: Colors.white70)),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.pinkAccent,
                ),
              ),
            ),
            child: child!,
          );
        });
    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
        _notificationsEnabled = true;
      });
    }
  }

  Future<void> _saveHabit() async {
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
        description: widget.habitDescription, // Corrected to use widget.habitDescription
        frequency: widget.selectedFrequency, 
        trackingType: widget.selectedTrackingType, 
        daysOfWeek: widget.selectedDaysOfWeek, 
        startDate: _startDate, 
        targetDate: _isTargetDateEnabled ? _targetDate : null, 
        reminderTime: _reminderTime,
        notificationsEnabled: _notificationsEnabled,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Hábito "${widget.habitTitle}" adicionado!',
                style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.green),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      // print('Error saving habit: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao salvar o hábito: ${e.toString()}',
                style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) {
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
        title: const Text('Quando você quer fazer isso?',
            style: TextStyle(
                color: Colors.pinkAccent,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isSaving
          ? const Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.pinkAccent)))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.info_outline,
                        color: Colors.grey, size: 20),
                    title: Text('Hábito: ${widget.habitTitle}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    subtitle: Text(
                        'Categoria: ${widget.selectedCategoryName} | Acompanhamento: ${widget.selectedTrackingType.toString().split('.').last}',
                        style:
                            TextStyle(color: Colors.grey[400], fontSize: 12)),
                    tileColor: Colors.grey[850],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)), 
                  ),
                  const SizedBox(height: 20),

                  ListTile(
                    leading: const Icon(Icons.calendar_today,
                        color: Colors.pinkAccent),
                    title: const Text('Data de Início',
                        style: TextStyle(color: Colors.white)),
                    subtitle: Text(
                        DateFormat('dd/MM/yyyy').format(_startDate),
                        style: TextStyle(color: Colors.grey[400])),
                    onTap: () => _selectDate(context, false),
                  ),

                  // --- Updated Target Date Section ---
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.flag_outlined, color: Colors.pinkAccent),
                        title: const Text('Data Alvo', style: TextStyle(color: Colors.white)),
                        trailing: Switch(
                          value: _isTargetDateEnabled,
                          onChanged: (value) {
                            setState(() {
                              _isTargetDateEnabled = value;
                              if (_isTargetDateEnabled) {
                                if (_targetDate == null || !_targetDate!.isAfter(_startDate)) {
                                   _targetDurationDays = 30; // Default to 30 days
                                  _targetDate = _startDate.add(Duration(days: _targetDurationDays!));
                                  _daysController.text = _targetDurationDays.toString();
                                } else {
                                   _targetDurationDays = _targetDate!.difference(_startDate).inDays;
                                   if(_targetDurationDays! <= 0) { 
                                       _targetDurationDays = 30;
                                       _targetDate = _startDate.add(Duration(days: _targetDurationDays!));
                                   }
                                   _daysController.text = _targetDurationDays.toString();
                                }
                              } else {
                                // _targetDate = null; // Keep date but not duration, or clear both?
                                // _targetDurationDays = null;
                                // _daysController.clear();
                              }
                            });
                          },
                          activeColor: Colors.pinkAccent,
                           inactiveThumbColor: Colors.grey[700],
                           inactiveTrackColor: Colors.grey[800]?.withAlpha(178), // ~0.7 opacity
                        ),
                      ),
                      if (_isTargetDateEnabled)
                        Padding(
                          padding: const EdgeInsets.only(left: 70.0, right: 16.0, bottom: 16.0, top: 0), // Adjusted left padding to align with ListTile text
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 2,
                                child: InkWell(
                                  onTap: () => _selectDate(context, true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[800],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey[700]!)
                                    ),
                                    child: Text(
                                      _targetDate == null
                                          ? 'Selecionar data'
                                          : DateFormat('dd/MM/yyyy').format(_targetDate!),
                                      style: TextStyle(color: _targetDate == null ? Colors.grey[400] : Colors.white, fontSize: 15),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 70, // Fixed width for the days TextField
                                child: TextField(
                                  controller: _daysController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                  decoration: InputDecoration(
                                    hintText: 'dias',
                                    hintStyle: TextStyle(color: Colors.grey[500]),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey[700]!),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(color: Colors.pinkAccent),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[800],
                                  ),
                                ),
                              ),
                               const Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Text("dias.", style: TextStyle(color: Colors.white, fontSize: 16)),
                              )
                            ],
                          ),
                        ),
                    ],
                  ),
                  // --- End of Updated Target Date Section ---

                  const Divider(color: Colors.grey),

                  ListTile(
                    leading: const Icon(Icons.alarm, color: Colors.pinkAccent),
                    title: const Text('Lembrete (Opcional)',
                        style: TextStyle(color: Colors.white)),
                    subtitle: Text(
                        _reminderTime == null
                            ? 'Não definido'
                            : _reminderTime!.format(context),
                        style: TextStyle(color: Colors.grey[400])),
                    trailing: _reminderTime != null
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey[600]),
                            onPressed: () => setState(() {
                                  _reminderTime = null;
                                  _notificationsEnabled = false;
                                }))
                        : null, 
                    onTap: () async {
                      await _selectTime(context);
                    },
                  ),

                  if (_reminderTime != null)
                    SwitchListTile(
                      title: const Text('Ativar notificações',
                          style: TextStyle(color: Colors.white)),
                      subtitle: Text('Requer permissões do sistema',
                          style:
                              TextStyle(color: Colors.grey[500], fontSize: 12)),
                      value: _notificationsEnabled,
                      onChanged: (bool value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                      },
                      activeColor: Colors.pinkAccent,
                      inactiveThumbColor: Colors.grey[700],
                      inactiveTrackColor: Colors.grey[800],
                      tileColor: Colors.grey[850]?.withAlpha(128), // ~0.5 opacity
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                ],
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(
            16.0, 16.0, 16.0, 24.0), 
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: _isSaving
                  ? null
                  : () => Navigator.of(context).pop(),
              child: Text('ANTERIOR',
                  style: TextStyle(
                      color: _isSaving ? Colors.grey[700] : Colors.white70,
                      fontSize: 16)),
            ),
            ElevatedButton.icon(
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check_circle_outline, color: Colors.white),
              label: Text(_isSaving ? 'SALVANDO...' : 'FINALIZAR',
                  style: const TextStyle(color: Colors.white)),
              onPressed: _isSaving ? null : _saveHabit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
