import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/screens/habits/habits_screen.dart';
import 'package:myapp/services/habit_service.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/services/ai_service.dart';
import 'package:myapp/services/service_provider.dart';
import 'package:myapp/models/habit.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../test_helpers/test_setup.dart';

@GenerateMocks([HabitService, AuthService, AIService, User, FirebaseFirestore])
import 'habits_screen_test.mocks.dart';

void main() {
  group('HabitsScreen Widget Tests', () {
    late MockHabitService mockHabitService;
    late MockAuthService mockAuthService;
    late MockAIService mockAIService;
    late MockUser mockUser;
    late ServiceProvider serviceProvider;

    setUpAll(() async {
      await setupTestEnvironment();
    });

    setUp(() {
      mockHabitService = MockHabitService();
      mockAuthService = MockAuthService();
      mockAIService = MockAIService();
      mockUser = MockUser();
      
      // Configurar comportamento padrão dos mocks
      when(mockUser.uid).thenReturn('test-user-id');
      when(mockAuthService.currentUser).thenReturn(mockUser);
      when(mockHabitService.getHabits()).thenAnswer((_) async => []);
      
      // Criar ServiceProvider com os mocks
      serviceProvider = ServiceProvider(
        habitService: mockHabitService,
        authService: mockAuthService,
        aiService: mockAIService,
      );
    });

    Widget createTestWidget(Widget child) {
      return ServiceProvider(
        habitService: mockHabitService,
        authService: mockAuthService,
        aiService: mockAIService,
        child: MultiProvider(
          providers: [
            Provider<AuthService>.value(value: mockAuthService),
            ChangeNotifierProvider<HabitService>.value(value: mockHabitService),
            Provider<AIService>.value(value: mockAIService),
          ],
          child: MaterialApp(
            home: child,
          ),
        ),
      );
    }

    testWidgets('Deve exibir mensagem quando não há hábitos', (WidgetTester tester) async {
      // Arrange
      when(mockHabitService.getHabits()).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createTestWidget(const HabitsScreen()));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No habits yet.'), findsOneWidget);
      expect(find.text('Tap the + button to add your first habit.'), findsOneWidget);
      expect(find.byIcon(Icons.list_alt_rounded), findsOneWidget);
    });

    testWidgets('Deve exibir lista de hábitos', (WidgetTester tester) async {
      // Arrange
      final testHabits = [
        Habit(
          id: 'habit-1',
          title: 'Beber água',
          description: '8 copos por dia',
          category: 'Saúde',
          icon: Icons.local_drink,
          color: Colors.blue,
          frequency: HabitFrequency.daily,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          completionHistory: {},
          trackingType: HabitTrackingType.simOuNao,
          dailyProgress: {},
          startDate: DateTime.now(),
        ),
        Habit(
          id: 'habit-2',
          title: 'Exercício',
          description: '30 minutos',
          category: 'Fitness',
          icon: Icons.fitness_center,
          color: Colors.orange,
          frequency: HabitFrequency.daily,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          completionHistory: {},
          trackingType: HabitTrackingType.simOuNao,
          dailyProgress: {},
          startDate: DateTime.now(),
        ),
      ];

      when(mockHabitService.getHabits()).thenAnswer((_) async => testHabits);

      // Act
      await tester.pumpWidget(createTestWidget(const HabitsScreen()));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Beber água'), findsOneWidget);
      expect(find.text('Exercício'), findsOneWidget);
      expect(find.text('8 copos por dia'), findsOneWidget);
      expect(find.text('30 minutos'), findsOneWidget);
    });

    testWidgets('Deve mostrar FAB para adicionar hábito', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(const HabitsScreen()));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Deve exibir calendário de dias da semana', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget(const HabitsScreen()));
      await tester.pumpAndSettle();

      // Assert - Verificar se os dias da semana estão visíveis
      expect(find.text('SEG'), findsOneWidget);
      expect(find.text('TER'), findsOneWidget);
      expect(find.text('QUA'), findsOneWidget);
      expect(find.text('QUI'), findsOneWidget);
      expect(find.text('SEX'), findsOneWidget);
      expect(find.text('SÁB'), findsOneWidget);
      expect(find.text('DOM'), findsOneWidget);
    });

    testWidgets('Deve marcar hábito como completo ao tocar no checkbox', (WidgetTester tester) async {
      // Arrange
      final habit = Habit(
        id: 'habit-test',
        title: 'Test Habit',
        category: 'Test',
        icon: Icons.check,
        color: Colors.green,
        frequency: HabitFrequency.daily,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        completionHistory: {},
        trackingType: HabitTrackingType.simOuNao,
        dailyProgress: {},
        startDate: DateTime.now(),
      );

      when(mockHabitService.getHabits()).thenAnswer((_) async => [habit]);
      when(mockHabitService.markHabitCompletion(any, any, any))
          .thenAnswer((_) async => {});

      // Act
      await tester.pumpWidget(createTestWidget(const HabitsScreen()));
      await tester.pumpAndSettle();

      // Encontrar e tocar no checkbox
      final checkbox = find.byType(Checkbox);
      expect(checkbox, findsOneWidget);
      
      await tester.tap(checkbox);
      await tester.pump();

      // Assert
      verify(mockHabitService.markHabitCompletion('habit-test', any, true)).called(1);
    });

    testWidgets('Deve exibir indicador de carregamento', (WidgetTester tester) async {
      // Arrange
      when(mockHabitService.getHabits()).thenAnswer(
        (_) => Future.delayed(const Duration(seconds: 2), () => [])
      );

      // Act
      await tester.pumpWidget(createTestWidget(const HabitsScreen()));
      await tester.pump(); // Não usar pumpAndSettle aqui

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
