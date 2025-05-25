import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/screens/main_navigation_screen.dart';
import 'package:myapp/services/service_provider.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/services/habit_service.dart';
import 'package:myapp/services/ai_service.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:myapp/services/task_service.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:myapp/models/habit.dart'; // Necessário para MockHabitService
import 'package:myapp/models/task.dart';

// Mock Services (copiados de onboarding_benefits_screen_test.dart)
class MockAuthService implements AuthService {
  @override
  Stream<User?> get authStateChanges => Stream.value(null);
  @override
  User? get currentUser => null; // Keep as null if that's the intended mock behavior
  @override
  String? get currentUserId => null; // Keep as null
  @override
  bool get isSignedIn => false;
  @override
  Future<void> signOut() async {}
  @override
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    throw UnimplementedError('signInWithEmailAndPassword not mocked');
  }
  @override
  Future<UserCredential> createUserWithEmailAndPassword(String email, String password, String displayName) async {
    throw UnimplementedError('createUserWithEmailAndPassword not mocked');
  }
  @override
  Future<void> sendPasswordResetEmail(String email) async {}
  @override
  Future<void> deleteAccount() async {}
  @override
  Future<Map<String, dynamic>?> getUserProfile() async => null;
  @override
  Future<void> updateUserProfile(Map<String, dynamic> profileData) async {}
  
  // Assuming updateProfile is part of your AuthService interface based on other files
  @override
  Future<void> updateProfile({String? displayName, String? photoURL}) async {}
  
  @override
  Future<void> updateLastLogin() async {}
  @override
  Future<void> reauthenticateWithCredential(AuthCredential credential) async {}
  @override
  Future<void> updateEmail(String newEmail) async {}
  @override
  Future<void> updatePassword(String newPassword) async {}
  @override
  Future<UserCredential?> signInWithGoogle() async => null;
}

class MockHabitService implements HabitService {
  @override
  Future<List<Habit>> getHabits() async => [];

  // Corrected: Renamed getHabit to getHabitById to match interface
  @override
  Future<Habit?> getHabitById(String id) async => null;

  // Corrected: Signature of addHabit to match HabitService interface
  @override
  Future<void> addHabit({
    required String title,
    required String categoryName,
    required IconData categoryIcon,
    required Color categoryColor,
    required HabitFrequency frequency,
    required HabitTrackingType trackingType,
    required DateTime startDate,
    List<int>? daysOfWeek,
    List<int>? daysOfMonth,
    List<DateTime>? specificYearDates,
    int? timesPerPeriod,
    String? periodType,
    int? repeatEveryDays,
    bool? isFlexible,
    bool? alternateDays,
    DateTime? targetDate,
    TimeOfDay? reminderTime,
    bool notificationsEnabled = false,
    String priority = 'Normal',
    String? description,
  }) async {
    // Mock implementation, can be simple or add to a list if needed for testing
  }

  @override
  Future<void> updateHabit(Habit habit) async {} // Return type changed to Future<void>

  @override
  Future<void> deleteHabit(String habitId) async {} // Return type changed to Future<void>

  // Added missing method from HabitService interface
  @override
  Future<void> markHabitCompletion(String habitId, DateTime date, bool completed) async {}

  // Removed methods that are not in HabitService or don't need @override
  // Future<bool> markHabitCompleted(String habitId, DateTime date) async => true;
  // Future<bool> markHabitNotCompleted(String habitId, DateTime date) async => true;
  // Future<List<Habit>> getHabitsDueToday() async => [];
  // Future<List<Habit>> getHabitsByCategory(String category) async => [];
  // Future<List<String>> getCategories() async => [];
  // Future<Map<String, dynamic>> getHabitStatistics() async => {}; 
}

class MockAIService extends AIService {
  MockAIService() : super(apiKey: 'fake_key');
  // Add method overrides if AIService interface requires them and they are missing.
}

// Corrected: MockNotificationService needs to implement all methods from NotificationService
// Assuming NotificationService has methods like initialize, requestPermissions, etc.
// For now, adding a basic implementation. You might need to fill these out based on your interface.
class MockNotificationService implements NotificationService {
  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<void> scheduleHabitReminder(Habit habit) async {}

  @override
  Future<void> cancelHabitReminder(Habit habit) async {}

  // Assuming these are part of your NotificationService based on previous file
  Future<void> scheduleTaskReminder(Task task) async {}
  Future<void> cancelTaskReminder(Task task) async {}
  @override
  Future<void> showTestNotification() async {}

  @override
  Future<void> cancelAllNotifications() async {}
}


class MockTaskService implements TaskService {
  @override
  Future<String?> addTask(Task task) async => 'mock_task_id';
  @override
  Future<bool> deleteTask(String taskId) async => true;
  @override
  Future<Task?> getTask(String taskId) async => null;
  @override
  Future<List<Task>> getTasks() async => [];
  
  // Assuming getTasksDueToday is part of your TaskService interface
  @override
  Future<List<Task>> getTasksDueToday() async => []; 
  
  @override
  Future<bool> markTaskCompletion(String taskId, DateTime date, bool completed) async => true;
  @override
  Future<bool> updateTask(Task task) async => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createTestableWidget({required Widget child}) {
    return ServiceProvider(
      authService: MockAuthService(),
      habitService: MockHabitService(),
      taskService: MockTaskService(),
      aiService: MockAIService(),
      notificationService: MockNotificationService(),
      child: MaterialApp(home: child),
    );
  }

  testWidgets('MainNavigationScreen initial UI and BottomNav test', (WidgetTester tester) async {
    await tester.pumpWidget(createTestableWidget(child: const MainNavigationScreen()));

    // Verifica AppBar
    expect(find.widgetWithText(AppBar, 'HabitAI'), findsOneWidget);

    // Verifica BottomNavigationBar
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    // Inicialmente, apenas o label da BottomNavigationBar para "Hoje" e "Hábitos" deve ser encontrado.
    // O Drawer está fechado.
    expect(find.widgetWithText(BottomNavigationBar, 'Hoje'), findsOneWidget);
    expect(find.widgetWithText(BottomNavigationBar, 'Hábitos'), findsOneWidget);
    
    // Verifica se a tela "Hoje" (HomeScreen) é exibida inicialmente
    expect(find.text('Tela Principal (Hoje) - Em construção'), findsOneWidget);

    // Toca no item "Hábitos" da BottomNavigationBar
    // Encontra o Text widget "Hábitos" que é descendente de BottomNavigationBar
    await tester.tap(find.descendant(of: find.byType(BottomNavigationBar), matching: find.text('Hábitos')));
    await tester.pumpAndSettle(); // Aguarda a transição

    // Verifica se a tela "Hábitos" é exibida
    expect(find.text('Tela de Hábitos - Em construção'), findsOneWidget);
    expect(find.text('Tela Principal (Hoje) - Em construção'), findsNothing);

    // Toca no item "Tarefas"
    await tester.tap(find.descendant(of: find.byType(BottomNavigationBar), matching: find.text('Tarefas')));
    await tester.pumpAndSettle();
    expect(find.text('Tela de Tarefas - Em construção'), findsOneWidget);

    // Toca no item "Coach AI"
    await tester.tap(find.descendant(of: find.byType(BottomNavigationBar), matching: find.text('Coach AI')));
    await tester.pumpAndSettle();
    expect(find.text('Tela do Coach AI - Em construção'), findsOneWidget);
    
    // Toca no item "Mais"
    await tester.tap(find.descendant(of: find.byType(BottomNavigationBar), matching: find.text('Mais')));
    await tester.pumpAndSettle();
    expect(find.text('Tela Mais (Configurações, etc.) - Em construção'), findsOneWidget);
  });

  testWidgets('MainNavigationScreen Drawer navigation test', (WidgetTester tester) async {
    await tester.pumpWidget(createTestableWidget(child: const MainNavigationScreen()));

    // Abre o Drawer
    await tester.tap(find.byTooltip('Open navigation menu')); // Tooltip padrão do ícone do AppBar para Drawer
    await tester.pumpAndSettle();

    // Verifica se o Drawer está aberto (procurando por um item do Drawer)
    expect(find.text('Menu HabitAI'), findsOneWidget);

    // Toca no item "Hábitos" do Drawer
    await tester.tap(find.widgetWithText(ListTile, 'Hábitos'));
    await tester.pumpAndSettle(); // Aguarda a navegação e o fechamento do Drawer

    // Verifica se a tela "Hábitos" é exibida
    expect(find.text('Tela de Hábitos - Em construção'), findsOneWidget);
    expect(find.text('Tela Principal (Hoje) - Em construção'), findsNothing);
    
    // Abre o Drawer novamente
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    
    // Toca no item "Hoje" do Drawer
    await tester.tap(find.widgetWithText(ListTile, 'Hoje'));
    await tester.pumpAndSettle();
    
    // Verifica se a tela "Hoje" é exibida
    expect(find.text('Tela Principal (Hoje) - Em construção'), findsOneWidget);
  });
}
