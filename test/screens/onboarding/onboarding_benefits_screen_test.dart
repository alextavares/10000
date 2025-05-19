import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/models/habit.dart'; // Importar o modelo Habit
import 'package:myapp/screens/onboarding/onboarding_benefits_screen.dart';
import 'package:myapp/services/service_provider.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/services/habit_service.dart';
import 'package:myapp/services/ai_service.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:shared_preferences/shared_preferences.dart'; // Importar para mock

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
  Future<Map<String, dynamic>> getHabitStatistics() async => {
        'totalHabits': 0,
        'completedToday': 0,
        'averageCompletionRate': 0.0,
        'longestStreak': 0,
        'totalCompletions': 0,
      };
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
      aiService: MockAIService(),
      notificationService: MockNotificationService(),
      child: MaterialApp(
        home: child,
        routes: {
          // Rotas
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

    expect(find.text('Personalização com IA'), findsOneWidget); 
    expect(find.text('Descubra Seu Potencial Máximo!'), findsNothing);
  });

  testWidgets('OnboardingBenefitsScreen "Pular" button navigation test', (WidgetTester tester) async {
    // Mock SharedPreferences para este teste específico
    SharedPreferences.setMockInitialValues({'onboardingCompleted': false}); // Garante que começamos com onboarding não concluído

    await tester.pumpWidget(createTestableWidget(child: const OnboardingBenefitsScreen()));
    
    await tester.tap(find.widgetWithText(TextButton, 'Pular'));
    await tester.pumpAndSettle(); 

    expect(find.text('Hoje'), findsOneWidget); 
    expect(find.text('Descubra Seu Potencial Máximo!'), findsNothing);

    // Opcional: Verificar se SharedPreferences foi atualizado (requer mais setup ou acesso direto se possível)
    // final prefs = await SharedPreferences.getInstance();
    // expect(prefs.getBool('onboardingCompleted'), isTrue);
  });
}
