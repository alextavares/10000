import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/habit.dart';
import '../../theme/app_theme.dart';

class HabitQuantityConfigScreen extends StatefulWidget {
  final String habitTitle;
  final String? habitDescription;
  final String category;
  final IconData icon;
  final Color color;
  final HabitFrequency frequency;
  final List<int>? daysOfWeek;
  final HabitTrackingType trackingType;

  const HabitQuantityConfigScreen({
    super.key,
    required this.habitTitle,
    this.habitDescription,
    required this.category,
    required this.icon,
    required this.color,
    required this.frequency,
    this.daysOfWeek,
    required this.trackingType,
  });

  @override
  State<HabitQuantityConfigScreen> createState() => _HabitQuantityConfigScreenState();
}

class _HabitQuantityConfigScreenState extends State<HabitQuantityConfigScreen> {
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  
  @override
  void dispose() {
    _quantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Defina sua meta',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Habit Title Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryColor, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hábito',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.habitTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Quantity Input
            Text(
              'Quantidade diária',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ex: 8',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                filled: true,
                fillColor: AppTheme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Unit Input
            Text(
              'Unidade',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _unitController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ex: copos de água, páginas, km',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                filled: true,
                fillColor: AppTheme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Preview
            if (_quantityController.text.isNotEmpty && _unitController.text.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prévia da meta:',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_quantityController.text} ${_unitController.text} por dia',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            
            const Spacer(),
            
            // Navigation Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'ANTERIOR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                ElevatedButton(
                  onPressed: _canProceed() ? _onNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
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
          ],
        ),
      ),
    );
  }

  bool _canProceed() {
    return _quantityController.text.isNotEmpty && 
           _unitController.text.isNotEmpty &&
           double.tryParse(_quantityController.text) != null;
  }

  void _onNext() {
    final quantity = double.parse(_quantityController.text);
    final unit = _unitController.text.trim();

    Navigator.pushNamed(
      context,
      '/add-habit-details',
      arguments: {
        'title': widget.habitTitle,
        'description': widget.habitDescription,
        'category': widget.category,
        'icon': widget.icon,
        'color': widget.color,
        'frequency': widget.frequency,
        'daysOfWeek': widget.daysOfWeek,
        'trackingType': widget.trackingType,
        'targetQuantity': quantity,
        'quantityUnit': unit,
      },
    );
  }
}
