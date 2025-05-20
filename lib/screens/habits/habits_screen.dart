import 'package:flutter/material.dart';
import 'package:myapp/widgets/app_drawer.dart';
import 'package:intl/intl.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get current date for the header
    final now = DateTime.now();
    final formattedDate = DateFormat('d \'de\' MMMM \'de\' yyyy', 'pt_BR').format(now);
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Habit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: 'Now',
                    style: TextStyle(
                      color: Color(0xFFE91E63), // Pink color
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              formattedDate,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.download, color: Colors.white),
            onPressed: () {
              // Download action
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          // Date selector (replace with actual implementation)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  child: Text('Qua\n14', style: TextStyle(color: Colors.white)),
                  onPressed: () {},
                ),
                TextButton(
                  child: Text('Qui\n15', style: TextStyle(color: Colors.white)),
                  onPressed: () {},
                ),
                TextButton(
                  child: Text('Sex\n16', style: TextStyle(color: Colors.white)),
                  onPressed: () {},
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.amber, // Highlighted day
                  ),
                  child: Text('Sáb\n17', style: TextStyle(color: Colors.black)),
                  onPressed: () {},
                ),
                TextButton(
                  child: Text('Dom\n18', style: TextStyle(color: Colors.white)),
                  onPressed: () {},
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.amber, // Highlighted day
                  ),
                  child: Text('Seg\n19', style: TextStyle(color: Colors.black)),
                  onPressed: () {},
                ),
                TextButton(
                  child: Text('Ter\n20', style: TextStyle(color: Colors.white)),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          // Habit list (replace with actual implementation)
          Expanded(
            child: Center(
              child: Text(
                'Lista de Hábitos - Em construção',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFE91E63),
        child: Icon(Icons.add),
        onPressed: () {
          // Add habit action
          Navigator.pushNamed(context, '/add-habit');
        },
      ),
    );
  }
}
