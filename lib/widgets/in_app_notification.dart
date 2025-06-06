import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

/// Widget para exibir notificações in-app com animações suaves
class InAppNotification extends StatefulWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final Duration duration;
  
  const InAppNotification({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.notifications,
    this.color = Colors.blue,
    this.onTap,
    this.duration = const Duration(seconds: 4),
  });
  
  /// Mostra a notificação no contexto atual
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    IconData icon = Icons.notifications,
    Color color = Colors.blue,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 4),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: InAppNotification(
            title: title,
            message: message,
            icon: icon,
            color: color,
            duration: duration,
            onTap: () {
              overlayEntry.remove();
              onTap?.call();
            },
          ),
        ),
      ),
    );
    
    overlay.insert(overlayEntry);
    
    // Auto-remover após duração
    Timer(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
  
  @override
  State<InAppNotification> createState() => _InAppNotificationState();
}

class _InAppNotificationState extends State<InAppNotification>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  Timer? _dismissTimer;
  
  @override
  void initState() {
    super.initState();
    
    // Controladores de animação
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    // Animações
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    // Iniciar animações
    _slideController.forward();
    _fadeController.forward();
    _scaleController.forward();
    
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    // Timer para auto-dismiss
    _dismissTimer = Timer(widget.duration - const Duration(milliseconds: 300), () {
      if (mounted) {
        _dismiss();
      }
    });
  }
  
  void _dismiss() {
    _fadeController.reverse();
    _slideController.reverse();
  }
  
  @override
  void dispose() {
    _dismissTimer?.cancel();
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onTap?.call();
            },
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity!.abs() > 100) {
                _dismiss();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Ícone animado
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 600),
                    builder: (context, value, child) {
                      return Transform.rotate(
                        angle: value * 0.1,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                widget.color,
                                widget.color.withValues(alpha: 0.7),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.icon,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Conteúdo
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.message,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Indicador de progresso
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 1, end: 0),
                      duration: widget.duration,
                      builder: (context, value, child) {
                        return CircularProgressIndicator(
                          value: value,
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.color.withValues(alpha: 0.3),
                          ),
                          backgroundColor: Colors.grey[300],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Manager para controlar notificações in-app
class InAppNotificationManager {
  static final InAppNotificationManager _instance = InAppNotificationManager._internal();
  factory InAppNotificationManager() => _instance;
  InAppNotificationManager._internal();
  
  final List<_NotificationData> _queue = [];
  bool _isShowing = false;
  
  /// Adiciona uma notificação à fila
  void showNotification(
    BuildContext context, {
    required String title,
    required String message,
    IconData icon = Icons.notifications,
    Color color = Colors.blue,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 4),
  }) {
    _queue.add(_NotificationData(
      context: context,
      title: title,
      message: message,
      icon: icon,
      color: color,
      onTap: onTap,
      duration: duration,
    ));
    
    _processQueue();
  }
  
  /// Processa a fila de notificações
  void _processQueue() {
    if (_isShowing || _queue.isEmpty) return;
    
    _isShowing = true;
    final data = _queue.removeAt(0);
    
    InAppNotification.show(
      context: data.context,
      title: data.title,
      message: data.message,
      icon: data.icon,
      color: data.color,
      duration: data.duration,
      onTap: data.onTap,
    );
    
    // Aguardar antes de mostrar a próxima
    Future.delayed(data.duration + const Duration(milliseconds: 500), () {
      _isShowing = false;
      _processQueue();
    });
  }
  
  /// Limpa a fila de notificações
  void clearQueue() {
    _queue.clear();
  }
}

class _NotificationData {
  final BuildContext context;
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final Duration duration;
  
  _NotificationData({
    required this.context,
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    this.onTap,
    required this.duration,
  });
}

/// Widget de exemplo de uso
class NotificationExampleScreen extends StatelessWidget {
  const NotificationExampleScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações In-App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                InAppNotificationManager().showNotification(
                  context,
                  title: '🎯 Hora do Hábito!',
                  message: 'Não esqueça de meditar por 5 minutos',
                  icon: Icons.self_improvement,
                  color: Colors.purple,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Abrindo hábito...')),
                    );
                  },
                );
              },
              icon: const Icon(Icons.notifications),
              label: const Text('Lembrete de Hábito'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                InAppNotificationManager().showNotification(
                  context,
                  title: '🔥 Sequência de 7 dias!',
                  message: 'Continue assim! Você está arrasando!',
                  icon: Icons.local_fire_department,
                  color: Colors.orange,
                );
              },
              icon: const Icon(Icons.celebration),
              label: const Text('Conquista Desbloqueada'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                InAppNotificationManager().showNotification(
                  context,
                  title: '💡 Dica do Dia',
                  message: 'Tente completar hábitos pela manhã para melhor consistência',
                  icon: Icons.lightbulb,
                  color: Colors.amber,
                );
              },
              icon: const Icon(Icons.tips_and_updates),
              label: const Text('Insight'),
            ),
          ],
        ),
      ),
    );
  }
}
