import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/models/habit.dart'; // Importar o modelo Habit
import 'package:myapp/screens/onboarding/onboarding_benefits_screen.dart';
import 'package:myapp/services/service_provider.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/services/habit_service.dart';
import 'package:myapp/services/ai_service.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:myapp/services/task_service.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:shared_preferences/shared_preferences.dart'; // Importar para mock
import 'package:myapp/models/task.dart';

// Mock Services
class MockAuthService implements AuthService {
  @override
  Stream<User?> get authStateChanges => Stream.value(null);
  @override
  User? get currentUser => null;
  @override
  String? get currentUserId => null;
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

  // Assuming updateProfile is part of your AuthService interface
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
    DateTime? targetDate,
    TimeOfDay? reminderTime,
    bool notificationsEnabled = false,
    String priority = 'Normal',
    String? description,
  }) async {
    // Mock implementation
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
  // Add method overrides if AIService interface requires them
}

// Corrected: MockNotificationService needs to implement all methods from NotificationService
class MockNotificationService implements NotificationService {
  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<void> scheduleHabitReminder(Habit habit) async {}

  @override
  Future<void> cancelHabitReminder(Habit habit) async {}

  // Assuming these are part of your NotificationService based on other files
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

  // Setup for SharedPreferences mock before tests run
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createTestableWidget({required Widget child}) {
    return ServiceProvider(
      authService: MockAuthService(),
      habitService: MockHabitService(),
      taskService: MockTaskService(),
      aiService: MockAIService(),
      notificationService: MockNotificationService(),
      child: MaterialApp(
        home: child,
        routes: {
          // Define routes if your screen navigates to them by name
          // For example, if 'Pular' navigates to '/home':
          // '/home': (context) => const MainNavigationScreen(), // Placeholder
          // '/onboarding_personalization': (context) => const OnboardingAIPersonalizationScreen(), // Placeholder
        },
      ),
    );
  }

  testWidgets('OnboardingBenefitsScreen UI elements test', (WidgetTester tester) async {
    await tester.pumpWidget(createTestableWidget(child: const OnboardingBenefitsScreen()));

    expect(find.text('Etapa 1 de 3'), findsOneWidget);
    expect(find.text('Descubra Seu Potencial Máximo!'), findsOneWidget);
    expect(find.textContaining('Nosso app ajuda você a construir hábitos saudáveis'), findsOneWidget);
    expect(find.byIcon(Icons.emoji_events), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Próximo'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Pular'), findsOneWidget);
  });

  testWidgets('OnboardingBenefitsScreen "Próximo" button navigation test', (WidgetTester tester) async {
    await tester.pumpWidget(createTestableWidget(child: const OnboardingBenefitsScreen()));

    await tester.tap(find.widgetWithText(ElevatedButton, 'Próximo'));
    await tester.pumpAndSettle();

    // This assertion depends on the actual screen navigated to.
    // If it navigates to OnboardingAIPersonalizationScreen, you'd check for its content.
    // expect(find.text('Personalização com IA'), findsOneWidget); 
    // For now, let's assume it navigates and the current screen is no longer visible.
    expect(find.text('Descubra Seu Potencial Máximo!'), findsNothing);
  });

  testWidgets('OnboardingBenefitsScreen "Pular" button navigation test', (WidgetTester tester) async {
    // Ensure SharedPreferences is clean for this specific test if needed, or rely on setUpAll
    // SharedPreferences.setMockInitialValues({'onboardingCompleted': false}); 

    await tester.pumpWidget(createTestableWidget(child: const OnboardingBenefitsScreen()));
    
    await tester.tap(find.widgetWithText(TextButton, 'Pular'));
    await tester.pumpAndSettle();

    // This assertion depends on the actual screen navigated to after skipping.
    // If it navigates to MainNavigationScreen (which shows 'Hoje'), this is correct.
    // expect(find.text('Hoje'), findsOneWidget); 
    // For now, let's assume it navigates and the current screen is no longer visible.
    expect(find.text('Descubra Seu Potencial Máximo!'), findsNothing);

    // Verify SharedPreferences was updated
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('onboardingCompleted'), isTrue);
  });
}
