import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/services/habit_service.dart';
import 'package:myapp/services/task_service.dart';
import 'package:myapp/services/recurring_task_service.dart';
import 'package:myapp/services/ai_service.dart';
import 'package:myapp/services/notification_service.dart';

/// Service provider for accessing all services throughout the app.
class ServiceProvider extends InheritedWidget {
  /// Authentication service.
  final AuthService authService;

  /// Habit service.
  final HabitService habitService;

  /// Task service.
  final TaskService taskService;

  /// Recurring task service.
  final RecurringTaskService recurringTaskService;

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
    required this.taskService,
    required this.recurringTaskService,
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
        ChangeNotifierProvider<HabitService>(
          create: (_) => HabitService(),
        ),
        ChangeNotifierProvider<TaskService>(
          create: (_) => TaskService(),
        ),
        ChangeNotifierProvider<RecurringTaskService>(
          create: (_) => RecurringTaskService(),
        ),
        Provider<AIService>(
          create: (_) => AIService(apiKey: aiApiKey),
        ),
        Provider<NotificationService>(
          create: (_) => NotificationService(),
        ),
      ],
      child: Consumer6<AuthService, HabitService, TaskService, RecurringTaskService, AIService, NotificationService>(
        builder: (context, authService, habitService, taskService, recurringTaskService, aiService, notificationService, _) {
          return ServiceProvider(
            authService: authService,
            habitService: habitService,
            taskService: taskService,
            recurringTaskService: recurringTaskService,
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
        taskService != oldWidget.taskService ||
        recurringTaskService != oldWidget.recurringTaskService ||
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

  /// Gets the TaskService.
  TaskService get taskService => ServiceProvider.of(this).taskService;

  /// Gets the RecurringTaskService.
  RecurringTaskService get recurringTaskService => ServiceProvider.of(this).recurringTaskService;

  /// Gets the AIService.
  AIService get aiService => ServiceProvider.of(this).aiService;

  /// Gets the NotificationService.
  NotificationService get notificationService => ServiceProvider.of(this).notificationService;
}
