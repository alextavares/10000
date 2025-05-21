import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/screens/auth/register_screen.dart';
import 'package:myapp/screens/auth/login_screen.dart';
import 'package:myapp/services/service_provider.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/services/habit_service.dart';
import 'package:myapp/services/ai_service.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:myapp/services/task_service.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:myapp/models/habit.dart';
import 'package:myapp/models/task.dart';

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
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    return Future.value(FakeUserCredential());
  }
  @override
  Future<UserCredential> createUserWithEmailAndPassword(String email, String password, String displayName) async {
    print('Mock createUserWithEmailAndPassword called');
    return Future.value(FakeUserCredential());
  }
  @override
  Future<void> sendPasswordResetEmail(String email) async {}
  @override
  Future<void> deleteAccount() async {}
  @override
  Future<Map<String, dynamic>?> getUserProfile() async => {'displayName': 'Fake User', 'email': 'fake@example.com'};
  @override
  Future<void> updateUserProfile(Map<String, dynamic> profileData) async {}
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
  Future<UserCredential> confirm(String verificationCode) async => FakeUserCredential();
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
  final UserMetadata metadata = UserMetadata(DateTime.now().millisecondsSinceEpoch, DateTime.now().millisecondsSinceEpoch);
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
  Future<IdTokenResult> getIdTokenResult([bool forceRefresh = false]) async => FakeIdTokenResult();
  @override
  Future<UserCredential> linkWithCredential(AuthCredential credential) async => FakeUserCredential();
  @override
  Future<ConfirmationResult> linkWithPhoneNumber(String phoneNumber, [RecaptchaVerifier? verifier]) async => FakeConfirmationResult();
  @override
  Future<UserCredential> linkWithPopup(AuthProvider provider) async => FakeUserCredential();
  @override
  Future<UserCredential> linkWithProvider(AuthProvider provider) async => FakeUserCredential();
  @override
  Future<UserCredential> linkWithRedirect(AuthProvider provider) async => FakeUserCredential();
  @override
  MultiFactor get multiFactor => throw UnimplementedError('multiFactor not implemented in mock');
  @override
  Future<void> reload() async {}
  @override
  Future<UserCredential> reauthenticateWithCredential(AuthCredential credential) async => FakeUserCredential();
  @override
  Future<UserCredential> reauthenticateWithPopup(AuthProvider provider) async => FakeUserCredential(); 
  @override
  Future<UserCredential> reauthenticateWithProvider(AuthProvider provider) async => FakeUserCredential();
  @override
  Future<void> reauthenticateWithRedirect(AuthProvider provider) async {}
  @override
  Future<void> sendEmailVerification([ActionCodeSettings? actionCodeSettings]) async {}
  @override
  Future<User> unlink(String providerId) async => FakeUser();
  @override
  Future<void> updateDisplayName(String? displayName) async {}
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
  Future<void> verifyBeforeUpdateEmail(String newEmail, [ActionCodeSettings? actionCodeSettings]) async {}
  @override
  Future<User?> userChanges() async => null;
  Future<void> sendPasswordResetEmailFromUser({String? email, ActionCodeSettings? actionCodeSettings}) async {}
  @override
  bool get _isMultiFactorSession => false;
  @override
  Future<MultiFactorSession> getMultiFactorSession() async => throw UnimplementedError();
  @override
  List<MultiFactorInfo> get providerSettings => [];
}

class MockHabitService implements HabitService {
  @override
  Future<List<Habit>> getHabits() async => [];
  @override
  Future<Habit?> getHabit(String habitId) async => null;
  @override
  Future<String?> addHabit(Habit habit) async => 'mock_habit_id';
  @override
  Future<bool> updateHabit(Habit habit) async => true;
  @override
  Future<bool> deleteHabit(String habitId) async => true;
  @override
  Future<bool> markHabitCompleted(String habitId, DateTime date) async => true;
  @override
  Future<bool> markHabitNotCompleted(String habitId, DateTime date) async => true;
  @override
  Future<List<Habit>> getHabitsDueToday() async => [];
  @override
  Future<List<Habit>> getHabitsByCategory(String category) async => [];
  @override
  Future<List<String>> getCategories() async => [];
  @override
  Future<Map<String, dynamic>> getHabitStatistics() async => {};
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
  @override
  Future<List<Task>> getTasksDueToday() async => [];
  @override
  Future<bool> markTaskCompletion(String taskId, DateTime date, bool completed) async => true;
  @override
  Future<bool> updateTask(Task task) async => true;
}

class MockAIService extends AIService {
  MockAIService() : super(apiKey: 'fake_key');
}
class MockNotificationService extends NotificationService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
      await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), 'password321');
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pump();
      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('Sign Up button is disabled if terms not agreed', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(child: const RegisterScreen()));
      final signUpButton = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Sign Up'));
      expect(signUpButton.enabled, isFalse); 
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();
      final signUpButtonEnabled = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Sign Up'));
      expect(signUpButtonEnabled.enabled, isTrue); 
    });
    
    testWidgets('Navigate to LoginScreen when "Log In" is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(child: const RegisterScreen()));

      final logInButtonFinder = find.widgetWithText(TextButton, 'Log In');
      await tester.ensureVisible(logInButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(logInButtonFinder);
      await tester.pumpAndSettle();

      // A LoginScreen tem um título "Log In" e um botão "Log In".
      expect(find.text('Log In'), findsNWidgets(2)); 
    });

    testWidgets('Shows loading indicator on valid submission', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(child: const RegisterScreen()));
      await tester.enterText(find.widgetWithText(TextFormField, 'Full Name'), 'Test User');
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
      await tester.enterText(find.widgetWithText(TextFormField, 'Confirm Password'), 'password123');
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pump(); 
      expect(find.byType(CircularProgressIndicator), findsOneWidget); 
      expect(find.text('Creating your account...'), findsOneWidget);
    });
  });
}
