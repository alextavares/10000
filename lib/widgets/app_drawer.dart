import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.black,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'HabitNow',
                  style: TextStyle(
                    color: Colors.pink,
                    fontSize: 24,
                  ),
                ),
                Text(
                  'Domingo\n11 de maio de 2025',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.white),
            title: const Text('Início', style: TextStyle(color: Colors.white)),
            selected: true,
            selectedColor: Colors.pink,
            onTap: () {
              // Handle 'Início' tap
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.timer, color: Colors.white),
            title: const Text('Timer', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Handle 'Timer' tap
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.category, color: Colors.white),
            title: const Text('Categorias', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Handle 'Categorias' tap
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.white),
            title: const Text('Personalizar', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Handle 'Personalizar' tap
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.white),
            title: const Text('Configurações', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Handle 'Configurações' tap
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.backup, color: Colors.white),
            title: const Text('Backup', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Handle 'Backup' tap
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.star, color: Colors.white),
            title: const Text('Obtenha premium', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Handle 'Obtenha premium' tap
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.star_border, color: Colors.white),
            title: const Text('Avalie o aplicativo', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Handle 'Avalie o aplicativo' tap
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.mail, color: Colors.white),
            title: const Text('Contate-Nos', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Handle 'Contate-Nos' tap
              Navigator.pop(context); // Close the drawer
            },
          ),
        ],
      ),
    );
  }
}
