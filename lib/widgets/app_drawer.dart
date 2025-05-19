import 'package:flutter/material.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/genkit_test_screen.dart';

class AppDrawer extends StatelessWidget {
  final int currentIndex;
  final Function(int) onDestinationSelected;

  const AppDrawer({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String userName = user?.displayName ?? 'Nome do Usuário';
    final String userEmail = user?.email ?? 'usuario@email.com';

    return Drawer(
      backgroundColor: AppTheme.backgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User avatar or placeholder
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.secondaryColor,
                  // TODO: Use actual user avatar if available
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: AppTheme.primaryColor,
                  ),
                ),
                SizedBox(height: 8),
                // User name
                Text(
                  userName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // User email
                Text(
                  userEmail,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Main Navigation Links
          ListTile(
            leading: Icon(Icons.today, color: currentIndex == 0 ? AppTheme.primaryColor : AppTheme.textColor),
            title: Text('Hoje', style: TextStyle(color: currentIndex == 0 ? AppTheme.primaryColor : AppTheme.textColor, fontWeight: currentIndex == 0 ? FontWeight.bold : FontWeight.normal)),
            selected: currentIndex == 0,
            onTap: () {
              onDestinationSelected(0);
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: Icon(Icons.checklist, color: currentIndex == 1 ? AppTheme.primaryColor : AppTheme.textColor),
            title: Text('Hábitos', style: TextStyle(color: currentIndex == 1 ? AppTheme.primaryColor : AppTheme.textColor, fontWeight: currentIndex == 1 ? FontWeight.bold : FontWeight.normal)),
            selected: currentIndex == 1,
            onTap: () {
              onDestinationSelected(1);
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: Icon(Icons.task, color: currentIndex == 2 ? AppTheme.primaryColor : AppTheme.textColor),
            title: Text('Tarefas', style: TextStyle(color: currentIndex == 2 ? AppTheme.primaryColor : AppTheme.textColor, fontWeight: currentIndex == 2 ? FontWeight.bold : FontWeight.normal)),
            selected: currentIndex == 2,
            onTap: () {
              onDestinationSelected(2);
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: Icon(Icons.psychology_alt, color: currentIndex == 3 ? AppTheme.primaryColor : AppTheme.textColor),
            title: Text('Coach AI', style: TextStyle(color: currentIndex == 3 ? AppTheme.primaryColor : AppTheme.textColor, fontWeight: currentIndex == 3 ? FontWeight.bold : FontWeight.normal)),
            selected: currentIndex == 3,
            onTap: () {
              onDestinationSelected(3);
              Navigator.pop(context); // Close the drawer
            },
          ),
          Divider(color: AppTheme.dividerColor), // Divider for secondary features
          // Secondary Features Links
          ListTile(
            leading: Icon(Icons.category, color: AppTheme.primaryColor),
            title: Text('Categorias', style: TextStyle(color: AppTheme.textColor)),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushNamed(context, '/categories');
            },
          ),
          ListTile(
            leading: Icon(Icons.timer, color: AppTheme.primaryColor),
            title: Text('Timer', style: TextStyle(color: AppTheme.textColor)),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushNamed(context, '/timer');
            },
          ),
          Divider(color: AppTheme.dividerColor), // Divider for settings
          // Genkit Test Screen
          ListTile(
            leading: Icon(Icons.science, color: AppTheme.primaryColor),
            title: Text('Genkit Test', style: TextStyle(color: AppTheme.textColor)),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GenkitTestScreen()),
              );
            },
          ),
          // Settings Link
          ListTile(
            leading: Icon(Icons.settings, color: AppTheme.primaryColor),
            title: Text('Configurações', style: TextStyle(color: AppTheme.textColor)),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
    );
  }
}
