import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Required for locale-specific date formatting

class AppDrawer extends StatefulWidget {
  final int currentSelectedIndex;
  final Function(int) onItemSelected;

  const AppDrawer({
    super.key,
    required this.currentSelectedIndex,
    required this.onItemSelected,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String _currentDayName = '';
  String _currentFullDate = '';

  @override
  void initState() {
    super.initState();
    _updateDateTime();
  }

  void _updateDateTime() {
    initializeDateFormatting('pt_BR', null).then((_) {
      final now = DateTime.now();
      if(mounted){
        setState(() {
          _currentDayName = DateFormat('EEEE', 'pt_BR').format(now); 
          _currentDayName = _currentDayName[0].toUpperCase() + _currentDayName.substring(1); 
          _currentFullDate = DateFormat('d ''de'' MMMM ''de'' yyyy', 'pt_BR').format(now); 
        });
      }
    });
  }

  Widget _buildMenuHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0, bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HabitNow',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currentDayName,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
          ),
          Text(
            _currentFullDate,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: isSelected ? Colors.pinkAccent.withValues(alpha: 0.8) : Colors.transparent,
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Colors.white : Colors.grey[400]),
        title: Text(
          title,
          style: TextStyle(color: isSelected ? Colors.white : Colors.grey[300], fontSize: 16),
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mapping drawer item titles to their corresponding screen indices in MainNavigationScreen
    // Ensure these indices match the order in MainNavigationScreen's _widgetOptions
    const int inicioIndex = 0;
    const int habitosIndex = 1; // Not explicitly in drawer image, but common
    const int tarefasIndex = 2; // Not explicitly in drawer image, but common
    const int timerIndex = 3;
    const int categoriasIndex = 4;
    // Indices for new screens (these will need to be added to MainNavigationScreen if they become actual screens)
    // For now, they won't visually select.

    return Drawer(
      backgroundColor: const Color(0xFF121212),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _buildMenuHeader(context),
          _buildMenuItem(
            context: context,
            icon: Icons.home_outlined,
            title: 'Início',
            isSelected: widget.currentSelectedIndex == inicioIndex,
            onTap: () {
              Navigator.pop(context); 
              widget.onItemSelected(inicioIndex);
            },
          ),
          _buildMenuItem(
            context: context,
            icon: Icons.timer_outlined,
            title: 'Timer',
            isSelected: widget.currentSelectedIndex == timerIndex,
            onTap: () {
              Navigator.pop(context);
              widget.onItemSelected(timerIndex);
            },
          ),
          _buildMenuItem(
            context: context,
            icon: Icons.apps_outlined, 
            title: 'Categorias',
            isSelected: widget.currentSelectedIndex == categoriasIndex,
            onTap: () {
              Navigator.pop(context);
              widget.onItemSelected(categoriasIndex);
            },
          ),
          _buildMenuItem(
            context: context,
            icon: Icons.palette_outlined, 
            title: 'Personalizar',
            isSelected: false, // No corresponding index yet
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to Personalizar screen (e.g., Navigator.pushNamed(context, '/personalizar');)
            },
          ),
          _buildMenuItem(
            context: context,
            icon: Icons.settings_outlined,
            title: 'Configurações',
            isSelected: false, // No corresponding index yet
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to Configurações screen
            },
          ),
          _buildMenuItem(
            context: context,
            icon: Icons.backup_outlined,
            title: 'Backup',
            isSelected: false, // No corresponding index yet
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to Backup screen
            },
          ),
          Divider(color: Colors.grey[700], height: 30, indent: 16, endIndent: 16),
          _buildMenuItem(
            context: context,
            icon: Icons.workspace_premium_outlined, 
            title: 'Obtenha premium',
            isSelected: false,
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to Premium screen/flow
            },
          ),
          _buildMenuItem(
            context: context,
            icon: Icons.star_outline,
            title: 'Avalie o aplicativo',
            isSelected: false,
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement app rating functionality
            },
          ),
          _buildMenuItem(
            context: context,
            icon: Icons.contact_support_outlined, 
            title: 'Contate-Nos',
            isSelected: false,
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement contact functionality
            },
          ),
        ],
      ),
    );
  }
}
