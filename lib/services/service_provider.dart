import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/services/habit_service.dart';
import 'package:myapp/services/ai_service.dart';
import 'package:myapp/services/notification_service.dart';

/// Service provider for accessing all services throughout the app.
class ServiceProvider extends InheritedWidget {
  /// Authentication service.
  final AuthService authService;

  /// Habit service.
  final HabitService habitService;

  /// AI service.
  final AIService aiService;

  /// Notification service.
  final NotificationService notificationService;

  /// Constructor for ServiceProvider.
  const ServiceProvider({
    super.key,
    required super.child,
    required this.authService,
    required this.habitService,
    required this.aiService,
    required this.notificationService,
  });

  /// Gets the ServiceProvider from the given context.
  static ServiceProvider of(BuildContext context) {
    final ServiceProvider? result =
        context.dependOnInheritedWidgetOfExactType<ServiceProvider>();
    assert(result != null, 'No ServiceProvider found in context');
    return result!;
  }

  /// Creates a MultiProvider with all the services.
  static Widget create({
    required Widget child,
    required String aiApiKey,
  }) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<HabitService>(
          create: (_) => HabitService(),
        ),
        Provider<AIService>(
          create: (_) => AIService(apiKey: aiApiKey),
        ),
        Provider<NotificationService>(
          create: (_) => NotificationService(),
        ),
      ],
      child: Consumer4<AuthService, HabitService, AIService, NotificationService>(
        builder: (context, authService, habitService, aiService, notificationService, _) {
          return ServiceProvider(
            authService: authService,
            habitService: habitService,
            aiService: aiService,
            notificationService: notificationService,
            child: child,
          );
        },
      ),
    );
  }

  @override
  bool updateShouldNotify(ServiceProvider oldWidget) {
    return authService != oldWidget.authService ||
        habitService != oldWidget.habitService ||
        aiService != oldWidget.aiService ||
        notificationService != oldWidget.notificationService;
  }
}

/// Extension methods for BuildContext to easily access services.
extension ServiceProviderExtension on BuildContext {
  /// Gets the AuthService.
  AuthService get authService => ServiceProvider.of(this).authService;

  /// Gets the HabitService.
  HabitService get habitService => ServiceProvider.of(this).habitService;

  /// Gets the AIService.
  AIService get aiService => ServiceProvider.of(this).aiService;

  /// Gets the NotificationService.
  NotificationService get notificationService => ServiceProvider.of(this).notificationService;
}
