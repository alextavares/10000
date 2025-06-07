import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/habit.dart' show HabitFrequency, HabitTrackingType; // Importar enums corretos
import 'package:myapp/services/service_provider.dart'; 
import 'package:myapp/utils/logger.dart';

class AddHabitDetailsScreen extends StatefulWidget {
  final String selectedCategoryName;
  final IconData selectedCategoryIcon;
  final Color selectedCategoryColor;
  final HabitFrequency selectedFrequencyEnumFromScreen; // Alterado para HabitFrequency

  const AddHabitDetailsScreen({
    super.key,
    required this.selectedCategoryName,
    required this.selectedCategoryIcon,
    required this.selectedCategoryColor,
    required this.selectedFrequencyEnumFromScreen,
  });

  @override
  State<AddHabitDetailsScreen> createState() => _AddHabitDetailsScreenState();
}

class _AddHabitDetailsScreenState extends State<AddHabitDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _habitNameController;

  DateTime _startDate = DateTime.now();
  DateTime? _targetDate;
  bool _enableTargetDate = false;
  TimeOfDay? _reminderTime;
  // TODO: Implementar UI para selecionar _reminderDays se a frequência for semanal/customizada
  // final List<bool> _reminderDays = List.filled(7, false); 
  String _priority = 'Normal';

  final List<String> _priorityOptions = ['Baixa', 'Normal', 'Alta'];

  @override
  void initState() {
    super.initState();
    _habitNameController = TextEditingController();
  }

  @override
  void dispose() {
    _habitNameController.dispose();
    super.dispose();
  }

  Future<void> _saveHabit() async {
    if (_formKey.currentState!.validate()) {
      final habitName = _habitNameController.text.trim();
      final habitService = ServiceProvider.of(context).habitService;

      List<int>? daysOfWeekForModel;
      // TODO: A UI para selecionar os dias da semana (daysOfWeek) precisa ser implementada 
      // quando selectedFrequencyEnumFromScreen for HabitFrequency.weekly ou HabitFrequency.custom.
      // Por enquanto, se for semanal, será null, o que pode não ser o ideal.
      // Exemplo de como poderia ser (se _reminderDays fosse populado pela UI):
      // if (widget.selectedFrequencyEnumFromScreen == HabitFrequency.weekly || widget.selectedFrequencyEnumFromScreen == HabitFrequency.custom) {
      //   daysOfWeekForModel = [];
      //   for (int i = 0; i < _reminderDays.length; i++) {
      //     if (_reminderDays[i]) {
      //       daysOfWeekForModel.add(i + 1); // Assumindo que 1=Segunda, ..., 7=Domingo
      //     }
      //   }
      //   if (daysOfWeekForModel.isEmpty) daysOfWeekForModel = null; // Evita lista vazia se nenhum dia selecionado
      // }

      // TODO: Implementar UI para selecionar HabitTrackingType
      // Por agora, definindo como simOuNao por padrão.
      HabitTrackingType trackingType = HabitTrackingType.simOuNao;
      // Outros campos como targetQuantity, quantityUnit, targetTime, subtasks
      // precisariam ser coletados da UI com base no trackingType selecionado.

      try {
        await habitService.addHabit(
          title: habitName,
          categoryName: widget.selectedCategoryName,
          categoryIcon: widget.selectedCategoryIcon,
          categoryColor: widget.selectedCategoryColor,
          frequency: widget.selectedFrequencyEnumFromScreen, // CORRIGIDO
          trackingType: trackingType, // ADICIONADO (com valor padrão)
          startDate: _startDate,
          targetDate: _enableTargetDate ? _targetDate : null,
          reminderTime: _reminderTime,
          priority: _priority,
          daysOfWeek: daysOfWeekForModel, // Passando o valor (atualmente null ou a ser implementado)
          // description: null, // Adicionar se houver campo de descrição
          // notificationsEnabled: _reminderTime != null, // Exemplo
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hábito "$habitName" salvo com sucesso!')),
          );
          // Retorna true para indicar sucesso e permitir que a tela anterior atualize se necessário
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } catch (e) {
        if (kDebugMode) {
          Logger.error('Error saving habit: $e');
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao salvar o hábito: $e')),
          );
        }
      }
    }
  }

  Future<void> _selectDate(BuildContext context, {bool isTargetDate = false}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isTargetDate ? (_targetDate ?? _startDate.add(const Duration(days: 1))) : _startDate,
      firstDate: isTargetDate ? _startDate.add(const Duration(days: 1)) : DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.pinkAccent,
              onPrimary: Colors.black,
              surface: Colors.black,
              onSurface: Colors.white,
            ), dialogTheme: DialogThemeData(backgroundColor: Colors.grey[900]),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isTargetDate) {
          _targetDate = picked;
        } else {
          _startDate = picked;
          if (_targetDate != null && _targetDate!.isBefore(_startDate)) {
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
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: Colors.pinkAccent,
                  onPrimary: Colors.black,
                  surface: Colors.black,
                  onSurface: Colors.white,
                ), dialogTheme: DialogThemeData(backgroundColor: Colors.grey[900])),
            child: child!,
          );
        });
    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  void _showPriorityDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Selecionar Prioridade', style: TextStyle(color: Colors.white)),
          content: SizedBox(
            width: double.minPositive,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _priorityOptions.length,
              itemBuilder: (BuildContext context, int index) {
                return RadioListTile<String>(
                  title: Text(_priorityOptions[index], style: const TextStyle(color: Colors.white70)),
                  value: _priorityOptions[index],
                  groupValue: _priority,
                  activeColor: Colors.pinkAccent,
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() {
                        _priority = value;
                      });
                      Navigator.of(context).pop();
                    }
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Detalhes do Hábito',
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            TextFormField(
              controller: _habitNameController,
              style: const TextStyle(color: Colors.white),
              enableSuggestions: true,
              autocorrect: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Nome do Hábito',
                labelStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[700]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.pinkAccent),
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[850],
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor, insira o nome do hábito';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildDetailItem(
              icon: Icons.calendar_today_outlined,
              title: 'Data de início',
              trailingText: DateFormat('dd/MM/yyyy').format(_startDate),
              onTap: () => _selectDate(context),
            ),
            _buildDetailItem(
              icon: Icons.flag_outlined,
              title: 'Data alvo',
              trailingWidget: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_enableTargetDate && _targetDate != null)
                    Text(DateFormat('dd/MM/yyyy').format(_targetDate!), style: const TextStyle(color: Colors.white70, fontSize: 16)),
                  if (_enableTargetDate && _targetDate == null)
                    const Text('Selecionar', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(width: 8),
                  Switch(
                    value: _enableTargetDate,
                    onChanged: (bool value) {
                      setState(() {
                        _enableTargetDate = value;
                        if (!value) {
                          _targetDate = null;
                        } else if (_targetDate == null){
                           _selectDate(context, isTargetDate: true);
                        }
                      });
                    },
                    activeColor: Colors.pinkAccent,
                    inactiveThumbColor: Colors.grey[600],
                    inactiveTrackColor: Colors.grey[700],
                  ),
                ],
              ),
              onTap: _enableTargetDate ? () => _selectDate(context, isTargetDate: true) : null,
            ),
            _buildDetailItem(
              icon: Icons.notifications_none_outlined,
              title: 'Horário e lembretes',
              trailingText: _reminderTime != null ? _reminderTime!.format(context) : 'Nenhum', 
              onTap: () => _selectTime(context), 
            ),
            _buildDetailItem(
              icon: Icons.outlined_flag,
              title: 'Prioridade',
              trailingText: _priority,
              onTap: _showPriorityDialog,
            ),
            // TODO: Adicionar UI para selecionar dias da semana se widget.selectedFrequencyEnumFromScreen for weekly/custom
            // TODO: Adicionar UI para selecionar o HabitTrackingType
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
              onPressed: _saveHabit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('FINALIZAR', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    String? trailingText,
    Widget? trailingWidget,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, color: Colors.pinkAccent[100]),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: trailingWidget ?? (trailingText != null 
            ? Text(trailingText, style: const TextStyle(color: Colors.white70, fontSize: 16))
            : null),
        onTap: onTap,
        tileColor: Colors.grey[850],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
