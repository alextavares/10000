import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/services/habit_service.dart';
import 'package:myapp/services/task_service.dart';
import 'package:myapp/services/recurring_task_service.dart';
import 'package:myapp/services/ai_service.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:myapp/services/achievement_service.dart'; // Importar AchievementService

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

  /// Achievement service.
  final AchievementService achievementService; // Adicionar AchievementService

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
    required this.achievementService, // Adicionar ao construtor
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
    // Os serviços que não dependem de outros podem ser criados primeiro.
    final authService = AuthService();
    final notificationService = NotificationService();
    // AchievementService depende de Firestore, Auth e HabitService.
    // HabitService depende de Firestore, Auth, NotificationService e AchievementService.
    // Temos uma dependência circular se passarmos instâncias diretamente no construtor
    // E criarmos todos eles aqui.
    // A solução atual do HabitService é buscar do Firestore, o que é bom.
    // O AchievementService precisa do HabitService para buscar todos os hábitos.

    // Para quebrar a dependência circular na instanciação aqui,
    // podemos fazer com que AchievementService receba o HabitService via Provider
    // ou um getter/setter, ou que o HabitService não seja injetado no AchievementService,
    // mas sim que o método checkAndUnlockAchievements receba List<Habit> como parâmetro.
    // O plano atual para AchievementService.checkAndUnlockAchievements já é receber `allUserHabits`.

    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => authService,
        ),
        Provider<NotificationService>(
          create: (_) => notificationService,
        ),
        // HabitService precisa ser um ChangeNotifierProvider se a UI o escuta diretamente.
        // CategoryService e AchievementService também podem ser ChangeNotifiers se necessário.

        // Criar CategoryService (se ainda não estiver sendo provido)
        // Para este exemplo, vamos assumir que ele será usado por AchievementScreen e AddHabitScreen
        // e não precisa ser um ChangeNotifier neste momento se for apenas para leitura de dados.
        // No entanto, se a CategoriesScreen precisa atualizar a lista após uma criação,
        // o CategoryService ou a CategoriesScreen precisa de um mecanismo de atualização.
        // O CategoryService já foi refatorado para usar Firestore.
        Provider<CategoryService>(
          create: (context) => CategoryService(
            // firestore: FirebaseFirestore.instance, // Assumindo que CategoryService usa instâncias globais
            // auth: FirebaseAuth.instance,
          ),
        ),

        // AchievementService precisa do HabitService para buscar todos os hábitos.
        // E HabitService precisa do AchievementService.
        // Esta é uma dependência circular se ambos forem injetados no construtor.
        // A solução é que um deles (ou ambos) obtenha a dependência via context.read
        // ou que o método que precisa da dependência a receba como parâmetro.

        // Opção 1: AchievementService não depende de HabitService no construtor,
        // mas o método checkAndUnlockAchievements recebe List<Habit> (já planejado).
        ChangeNotifierProvider<AchievementService>(
          create: (context) => AchievementService(
            firestore: FirebaseFirestore.instance, // Assumindo que AchievementService usa instâncias globais ou DI
            auth: FirebaseAuth.instance,
            habitService: Provider.of<HabitService>(context, listen: false) // Temporário, idealmente não injetar HabitService aqui
                                                                          // Ou melhor, o checkAchievements recebe List<Habit>
          ),
        ),
        ChangeNotifierProvider<HabitService>(
          create: (context) => HabitService(
            firestore: FirebaseFirestore.instance, // Assumindo que HabitService usa instâncias globais
            auth: FirebaseAuth.instance,
            notificationService: Provider.of<NotificationService>(context, listen: false),
            achievementService: Provider.of<AchievementService>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider<TaskService>(
          create: (_) => TaskService(), // Assumindo que TaskService não tem novas dependências
        ),
        ChangeNotifierProvider<RecurringTaskService>(
          create: (_) => RecurringTaskService(), // Assumindo que não tem novas dependências
        ),
        Provider<AIService>(
          create: (_) => AIService(apiKey: aiApiKey),
        ),
      ],
      // O ConsumerX precisa ser atualizado para incluir AchievementService
      child: Consumer7<AuthService, HabitService, TaskService, RecurringTaskService, AIService, NotificationService, AchievementService>(
        builder: (context, authService, habitService, taskService, recurringTaskService, aiService, notificationService, achievementService, _) {
          return ServiceProvider(
            authService: authService,
            habitService: habitService,
            taskService: taskService,
            recurringTaskService: recurringTaskService,
            aiService: aiService,
            notificationService: notificationService,
            achievementService: achievementService, // Passar para o InheritedWidget
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
        notificationService != oldWidget.notificationService ||
        achievementService != oldWidget.achievementService; // Adicionar verificação
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

  /// Gets the AchievementService.
  AchievementService get achievementService => ServiceProvider.of(this).achievementService; // Adicionar getter
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
