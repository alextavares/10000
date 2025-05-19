import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/screens/main_navigation_screen.dart';
import 'package:myapp/services/service_provider.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/services/habit_service.dart';
import 'package:myapp/services/ai_service.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:myapp/models/habit.dart'; // Necessário para MockHabitService

// Mock Services (copiados de onboarding_benefits_screen_test.dart)
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
