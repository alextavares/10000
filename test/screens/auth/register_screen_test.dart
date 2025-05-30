import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/models/task.dart';
import 'package:myapp/models/recurring_task.dart';
import 'package:myapp/screens/auth/login_screen.dart';
import 'package:myapp/screens/auth/register_screen.dart';
import 'package:myapp/services/ai_service.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/services/habit_service.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:myapp/services/service_provider.dart';
import 'package:myapp/services/task_service.dart';
import 'package:myapp/services/recurring_task_service.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;

// Mock Services
class MockAuthService implements AuthService {
  @override
  Stream<User?> get authStateChanges => Stream.value(null);
  @override
  User? get currentUser => FakeUser();
  @override
  String? get currentUserId => 'fake_uid';
  @override
  bool get isSignedIn => false;
  @override
  Future<void> signOut() async {}
  @override
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    return Future.value(FakeUserCredential());
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password, String displayName) async {
    // print('Mock createUserWithEmailAndPassword called'); // Removed print
    return Future.value(FakeUserCredential());
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {}
  @override
  Future<void> deleteAccount() async {}
  @override
  Future<Map<String, dynamic>?> getUserProfile() async =>
      {'displayName': 'Fake User', 'email': 'fake@example.com'};
  @override
  Future<void> updateUserProfile(Map<String, dynamic> profileData) async {}
  
  // Removed @override as it's not in the latest AuthService interface from other files
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
  Future<UserCredential?> signInWithGoogle() async => FakeUserCredential();
}

class FakeUserCredential implements UserCredential {
  @override
  User? get user => FakeUser();
  @override
  AuthCredential? get credential => null;
  @override
  AdditionalUserInfo? get additionalUserInfo => null;
}

class FakeIdTokenResult implements IdTokenResult {
  @override
  final String? token = 'fake-token';
  @override
  final Map<String, dynamic> claims = const {};
  @override
  final DateTime? authTime = DateTime.now();
  @override
  final DateTime? expirationTime = DateTime.now().add(const Duration(hours: 1));
  @override
  final DateTime? issuedAtTime = DateTime.now();
  @override
  final String? signInProvider = null;
  @override
  final String? signInSecondFactor = null;
}

class FakeConfirmationResult implements ConfirmationResult {
  @override
  final String verificationId = 'fake-verification-id';
  @override
  Future<UserCredential> confirm(String verificationCode) async =>
      FakeUserCredential();
}

class FakeUser implements User {
  @override
  final String uid = 'fake_uid';
  @override
  final String? email = 'fake@example.com';
  @override
  final String? displayName = 'Fake User';
  @override
  final bool emailVerified = true;
  @override
  final bool isAnonymous = false;
  @override
  final UserMetadata metadata = UserMetadata(
      DateTime.now().millisecondsSinceEpoch,
      DateTime.now().millisecondsSinceEpoch);
  @override
  final String? phoneNumber = null;
  @override
  final String? photoURL = null;
  @override
  final List<UserInfo> providerData = const [];
  @override
  final String? tenantId = null;
  @override
  final String? refreshToken = 'fake-refresh-token';

  @override
  Future<void> delete() async {}
  @override
  Future<String> getIdToken([bool forceRefresh = false]) async => 'fake-token';
  @override
  Future<IdTokenResult> getIdTokenResult([bool forceRefresh = false]) async =>
      FakeIdTokenResult();
  @override
  Future<UserCredential> linkWithCredential(AuthCredential credential) async =>
      FakeUserCredential();
  @override
  Future<ConfirmationResult> linkWithPhoneNumber(String phoneNumber,
          [RecaptchaVerifier? verifier]) async =>
      FakeConfirmationResult();
  @override
  Future<UserCredential> linkWithPopup(AuthProvider provider) async =>
      FakeUserCredential();
  @override
  Future<UserCredential> linkWithProvider(AuthProvider provider) async =>
      FakeUserCredential();
  @override
  Future<UserCredential> linkWithRedirect(AuthProvider provider) async =>
      FakeUserCredential();
  @override
  MultiFactor get multiFactor =>
      throw UnimplementedError('multiFactor not implemented in mock');
  @override
  Future<void> reload() async {}
  @override
  Future<UserCredential> reauthenticateWithCredential(
          AuthCredential credential) async =>
      FakeUserCredential();
  @override
  Future<UserCredential> reauthenticateWithPopup(AuthProvider provider) async =>
      FakeUserCredential();
  @override
  Future<UserCredential> reauthenticateWithProvider(AuthProvider provider) async =>
      FakeUserCredential();
  @override
  Future<void> reauthenticateWithRedirect(AuthProvider provider) async {}
  @override
  Future<void> sendEmailVerification(
      [ActionCodeSettings? actionCodeSettings]) async {}
  @override
  Future<User> unlink(String providerId) async => FakeUser();
  @override
  Future<void> updateDisplayName(String? displayName) async {}
  
  // Removed @override based on errors (likely not in User interface or mismatch)
  @override
  Future<void> updateProfile({String? displayName, String? photoURL}) async {}
  
  @override
  Future<void> updateEmail(String newEmail) async {}
  @override
  Future<void> updatePassword(String newPassword) async {}
  @override
  Future<void> updatePhoneNumber(PhoneAuthCredential credential) async {}
  @override
  Future<void> updatePhotoURL(String? photoURL) async {}
  @override
  Future<void> verifyBeforeUpdateEmail(String newEmail,
      [ActionCodeSettings? actionCodeSettings]) async {}
  
  // This method is not part of the User interface from firebase_auth, removing @override
  // Future<User?> userChanges() async => null; 
  // The User class from firebase_auth does not have a userChanges method.
  // It is typically available on FirebaseAuth.instance.

  // This method is not part of the User interface. Removed.
  // Future<void> sendPasswordResetEmailFromUser({String? email, ActionCodeSettings? actionCodeSettings}) async {}
  
  // Removed _isMultiFactorSession as it was unused and not an override 
  
  // Removed @override as it's not in the latest User interface
  Future<MultiFactorSession> getMultiFactorSession() async => throw UnimplementedError();
  
  // Removed @override as it's not in the latest User interface
  List<MultiFactorInfo> get providerSettings => [];
}

class MockHabitService extends ChangeNotifier implements HabitService {
  @override
  Future<List<Habit>> getHabits() async => [];

  @override
  Future<Habit?> getHabitById(String id) async => null; // Added missing method

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
    // Corrected signature to match HabitService interface
  }

  @override
  Future<void> updateHabit(Habit habit) async {} // Changed return type to Future<void>

  @override
  Future<void> deleteHabit(String habitId) async {} // Changed return type to Future<void>

  @override
  Future<void> markHabitCompletion(String habitId, DateTime date, bool completed) async {}

  // Methods below were not in the original error list but are common for a habit service.
  // Kept them and changed return types to Future<void> or appropriate mock value if they were mocks.
  // If they are not part of your actual HabitService interface, they should be removed or not have @override.

  // Assuming these are not part of the interface as they were not in errors and have unusual return types for a service.
  // Future<bool> markHabitCompleted(String habitId, DateTime date) async => true;
  // Future<bool> markHabitNotCompleted(String habitId, DateTime date) async => true;
  // Future<List<Habit>> getHabitsDueToday() async => [];
  // Future<List<Habit>> getHabitsByCategory(String category) async => [];
  // Future<List<String>> getCategories() async => [];
  // Future<Map<String, dynamic>> getHabitStatistics() async => {};
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
  
  // Removed @override as it might not be in the TaskService interface or signature mismatch
  @override
  Future<List<Task>> getTasksDueToday() async => [];
  
  @override
  Future<bool> markTaskCompletion(String taskId, DateTime date, bool completed) async => true;
  @override
  Future<bool> updateTask(Task task) async => true;
}

class MockAIService extends AIService {
  MockAIService() : super(apiKey: 'fake_key');
  // Add method overrides if AIService interface requires them and they are missing.
  // For example, from previous file:
  // @override
  // Future<String> generateHabitInsights(List<Habit> habits, {String? customPrompt}) async {
  //   return "Mocked AI Insights";
  // }
}

class MockNotificationService implements NotificationService {
  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermissions() async {
    return true;
  }

  @override
  Future<void> scheduleHabitReminder(Habit habit) async {}

  @override
  Future<void> cancelHabitReminder(Habit habit) async {}

  @override
  Future<void> scheduleTaskReminder(Task task) async {} // This line was missing

  @override
  Future<void> cancelTaskReminder(Task task) async {} // This line was missing

  @override
  Future<void> cancelAllNotifications() async {}
  
  @override
  Future<void> showTestNotification() async {} // Added missing method implementation

  // This was present in the other file's mock, if it's not part of the actual
  // NotificationService interface, it should not have @override or be removed.
  // Future<void> scheduleDailyHabitReminder(Habit habit) async {}
}

class MockRecurringTaskService implements RecurringTaskService {
  @override
  Future<bool> createRecurringTask(RecurringTask recurringTask) async => true;
  @override
  Future<bool> updateRecurringTask(RecurringTask recurringTask) async => true;
  @override
  Future<bool> deleteRecurringTask(String recurringTaskId) async => true;
  @override
  Future<List<RecurringTask>> getRecurringTasks() async => [];
  @override
  Future<RecurringTask?> getRecurringTask(String recurringTaskId) async => null;
  @override
  Future<List<RecurringTask>> getRecurringTasksDueToday() async => [];
  @override
  Future<List<RecurringTask>> getRecurringTasksByCategory(String category) async => [];
  @override
  Future<bool> markRecurringTaskCompletion(String recurringTaskId, DateTime date, bool completed) async => true;
  @override
  Future<bool> recordRecurringTaskProgress(String recurringTaskId, DateTime date, {bool? isCompleted, List<RecurringTaskSubtask>? subtasks}) async => true;
  @override
  Future<Map<String, dynamic>> getRecurringTaskStats(String recurringTaskId) async => {};
  @override
  Future<Map<String, List<RecurringTask>>> getRecurringTasksForDateRange(DateTime startDate, DateTime endDate) async => {};
  @override
  Stream<List<RecurringTask>> getRecurringTasksStream() => Stream.value([]);
  @override
  Stream<List<RecurringTask>> getRecurringTasksDueTodayStream() => Stream.value([]);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createTestableWidget({required Widget child}) {
    return ServiceProvider(
      authService: MockAuthService(),
      habitService: MockHabitService(),
      taskService: MockTaskService(),
      recurringTaskService: MockRecurringTaskService(),
      aiService: MockAIService(), // AIService might need a constructor argument if not default
      notificationService: MockNotificationService(),
      child: MaterialApp(
        home: child,
        routes: {
          '/login': (context) => const LoginScreen(),
        },
      ),
    );
  }

  group('RegisterScreen Tests', () {
    testWidgets('UI elements are present', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(child: const RegisterScreen()));
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Full Name'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Confirm Password'), findsOneWidget);
      expect(find.byType(CheckboxListTile), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Sign Up'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Log In'), findsOneWidget);
    });

    testWidgets('Form validation for empty fields', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(child: const RegisterScreen()));
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pump();
      expect(find.text('Please enter your name'), findsOneWidget);
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter a password'), findsOneWidget);
      expect(find.text('Please confirm your password'), findsOneWidget);
    });

    testWidgets('Form validation for invalid email', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(child: const RegisterScreen()));
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'invalidemail');
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pump();
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('Form validation for password too short', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(child: const RegisterScreen()));
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), '123');
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pump();
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('Form validation for password mismatch', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(child: const RegisterScreen()));
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Confirm Password'), 'password321');
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pump();
      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('Sign Up button is disabled if terms not agreed', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(child: const RegisterScreen()));
      final signUpButton =
          tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Sign Up'));
      expect(signUpButton.enabled, isFalse);
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();
      final signUpButtonEnabled =
          tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Sign Up'));
      expect(signUpButtonEnabled.enabled, isTrue);
    });

    testWidgets('Navigate to LoginScreen when "Log In" is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(child: const RegisterScreen()));

      final logInButtonFinder = find.widgetWithText(TextButton, 'Log In');
      await tester.ensureVisible(logInButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(logInButtonFinder);
      await tester.pumpAndSettle();

      // A LoginScreen tem um título "Log In" e um botão "Log In".
      expect(find.text('Log In'), findsNWidgets(2));
    });

    testWidgets('Shows loading indicator on valid submission',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(child: const RegisterScreen()));
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Full Name'), 'Test User');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'), 'password123');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Confirm Password'), 'password123');
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Creating your account...'), findsOneWidget);
    });
  });
}
