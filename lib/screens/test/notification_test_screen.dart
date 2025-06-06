import 'package:flutter/material.dart';
import 'package:myapp/services/notifications/smart_notification_service.dart';
import 'package:myapp/widgets/in_app_notification.dart';

/// Tela de teste para verificar se o sistema de notificações está funcionando
class NotificationTestScreen extends StatelessWidget {
  const NotificationTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste de Notificações'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🔔 Sistema de Notificações Integrado!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            
            // Botão para testar notificação in-app
            ElevatedButton.icon(
              onPressed: () {
                InAppNotificationManager().showNotification(
                  context,
                  title: '✅ Integração Concluída!',
                  message: 'O sistema de notificações está funcionando perfeitamente!',
                  icon: Icons.check_circle,
                  color: Colors.green,
                );
              },
              icon: const Icon(Icons.notifications_active),
              label: const Text('Testar Notificação In-App'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Botão para testar notificação local
            ElevatedButton.icon(
              onPressed: () async {
                final service = SmartNotificationService();
                await service.sendInstantNotification(
                  title: 'HabitAI',
                  body: 'Teste de notificação local funcionando!',
                );
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notificação local enviada! Verifique a barra de notificações.'),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.phone_android),
              label: const Text('Testar Notificação Local'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: Colors.blue,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Botão para ir às configurações
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/notification-settings');
              },
              icon: const Icon(Icons.settings),
              label: const Text('Configurações de Notificações'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
