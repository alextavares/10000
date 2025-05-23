import 'package:flutter/material.dart';
import 'package:myapp/models/habit.dart'; // For HabitTrackingType enum
import 'add_habit_frequency_screen.dart';

class AddHabitTitleScreen extends StatefulWidget {
  final String selectedCategoryName;
  final IconData selectedCategoryIcon;
  final Color selectedCategoryColor;
  final HabitTrackingType selectedTrackingType; // Added this line

  const AddHabitTitleScreen({
    super.key,
    required this.selectedCategoryName,
    required this.selectedCategoryIcon,
    required this.selectedCategoryColor,
    required this.selectedTrackingType, // Added this line
  });

  @override
  State<AddHabitTitleScreen> createState() => _AddHabitTitleScreenState();
}

class _AddHabitTitleScreenState extends State<AddHabitTitleScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_updateButtonState);
    // Print received tracking type for verification
    print("AddHabitTitleScreen received tracking type: ${widget.selectedTrackingType}");
  }

  @override
  void dispose() {
    _titleController.removeListener(_updateButtonState);
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _titleController.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Defina o seu hábito',
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10), // Reduced top space a bit
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: widget.selectedCategoryColor, width: 1.5),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.selectedCategoryIcon,
                    color: widget.selectedCategoryColor,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.selectedCategoryName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              'Hábito',
              style: TextStyle(
                color: Colors.pinkAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              onChanged: (value) => _updateButtonState(), // Already calls _updateButtonState
              decoration: InputDecoration(
                hintText: 'Ex: Meditar',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.pinkAccent, width: 2),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              'Descrição (opcional)',
              style: TextStyle(
                color: Colors.pinkAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Ex: Evite álcool',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                 filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.pinkAccent, width: 2),
                ),
              ),
            ),
            
            const Spacer(),
            
            Row(
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
                  onPressed: _isButtonEnabled ? () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AddHabitFrequencyScreen(
                        selectedCategoryName: widget.selectedCategoryName,
                        selectedCategoryIcon: widget.selectedCategoryIcon,
                        selectedCategoryColor: widget.selectedCategoryColor,
                        habitTitle: _titleController.text.trim(),
                        habitDescription: _descriptionController.text.trim().isNotEmpty 
                            ? _descriptionController.text.trim() 
                            : null,
                        // Pass the tracking type to the next screen
                        selectedTrackingType: widget.selectedTrackingType, 
                      ),
                    ));
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isButtonEnabled ? Colors.pinkAccent : Colors.grey,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('PRÓXIMA', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
