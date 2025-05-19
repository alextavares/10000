import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/screens/auth/forgot_password_screen.dart';
import 'package:myapp/services/service_provider.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/services/habit_service.dart';
import 'package:myapp/services/ai_service.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:myapp/models/habit.dart';

// Mock Services (similares aos outros arquivos de teste)
class MockAuthService implements AuthService {
  bool sendPasswordResetEmailCalled = false;
  String? lastEmailSentTo;

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
    throw UnimplementedError();
  }
  @override
  Future<UserCredential> createUserWithEmailAndPassword(String email, String password, String displayName) async {
    throw UnimplementedError();
  }
  @override
  Future<void> sendPasswordResetEmail(String email) async {
    sendPasswordResetEmailCalled = true;
    lastEmailSentTo = email;
    // Simula um delay de rede para permitir que o estado de loading seja renderizado
    await Future.delayed(const Duration(milliseconds: 50)); 
  }
  @override
  Future<void> deleteAccount() async {}
  @override
  Future<Map<String, dynamic>?> getUserProfile() async => null;
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
  Future<UserCredential?> signInWithGoogle() async => null;
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

class MockAIService extends AIService {
  MockAIService() : super(apiKey: 'fake_key');
}
class MockNotificationService extends NotificationService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  Widget createTestableWidget({required Widget child}) {
    return ServiceProvider(
      authService: mockAuthService, // Usa a instância mockada
      habitService: MockHabitService(),
      aiService: MockAIService(),
      notificationService: MockNotificationService(),
      child: MaterialApp(home: child),
    );
  }

  group('ForgotPasswordScreen Tests', () {
    testWidgets('UI elements are present initially', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(child: const ForgotPasswordScreen()));

      expect(find.text('Forgot Password'), findsOneWidget);
      expect(find.textContaining('Enter your email address'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Reset Password'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget); // Botão de voltar no AppBar
    });

    testWidgets('Form validation for empty email', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(child: const ForgotPasswordScreen()));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Reset Password'));
      await tester.pump();
      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('Form validation for invalid email', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(child: const ForgotPasswordScreen()));
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'invalidemail');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Reset Password'));
      await tester.pump();
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('Shows loading indicator and then success message on valid submission', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(child: const ForgotPasswordScreen()));
      
      const testEmail = 'test@example.com';
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), testEmail);
      
      await tester.tap(find.widgetWithText(ElevatedButton, 'Reset Password'));
      await tester.pump(); // Inicia o _isLoading e mostra LoadingScreenWithMessage

      expect(find.text('Sending password reset email...'), findsOneWidget);
      
      // Aguarda a conclusão do Future em _resetPassword e a reconstrução da UI
      await tester.pumpAndSettle(); 

      expect(find.text('Email Sent'), findsOneWidget);
      expect(find.textContaining(testEmail), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Back to Login'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Didn\'t receive the email? Send again'), findsOneWidget);
      
      // Verifica se o método do serviço foi chamado
      expect(mockAuthService.sendPasswordResetEmailCalled, isTrue);
      expect(mockAuthService.lastEmailSentTo, testEmail);
    });

     testWidgets('Pressing "Send again" calls _resetPassword again', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(child: const ForgotPasswordScreen()));
      
      const testEmail = 'test@example.com';
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), testEmail);
      
      // Primeira submissão
      await tester.tap(find.widgetWithText(ElevatedButton, 'Reset Password'));
      await tester.pumpAndSettle(); 

      expect(find.text('Email Sent'), findsOneWidget);
      mockAuthService.sendPasswordResetEmailCalled = false; // Reseta para o próximo teste

      // Toca em "Send again"
      await tester.tap(find.widgetWithText(TextButton, 'Didn\'t receive the email? Send again'));
      await tester.pump(); // Mostra loading
      expect(find.text('Sending password reset email...'), findsOneWidget);
      await tester.pumpAndSettle(); // Mostra sucesso novamente

      expect(find.text('Email Sent'), findsOneWidget); // Verifica se a tela de sucesso é mostrada novamente
      expect(mockAuthService.sendPasswordResetEmailCalled, isTrue);
    });

  });
}
