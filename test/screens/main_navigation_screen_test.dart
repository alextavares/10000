import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/screens/main_navigation_screen.dart';
import 'package:myapp/services/service_provider.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/services/habit_service.dart';
import 'package:myapp/services/ai_service.dart';
import 'package:myapp/services/notification_service.dart';
import 'package:myapp/services/task_service.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/models/task.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../test_helpers/test_setup.dart';

@GenerateMocks([AuthService, HabitService, TaskService, NotificationService, User])
import 'main_navigation_screen_test.mocks.dart';

void main() {
  group('MainNavigationScreen Tests', () {
    late MockAuthService mockAuthService;
    late MockHabitService mockHabitService;
    late MockTaskService mockTaskService;
    late MockNotificationService mockNotificationService;
    late MockUser mockUser;

    setUpAll(() async {
      await setupTestEnvironment();
    });

    setUp(() {
      mockAuthService = MockAuthService();
      mockHabitService = MockHabitService();
      mockTaskService = MockTaskService();
      mockNotificationService = MockNotificationService();
      mockUser = MockUser();

      // Setup default mock behaviors
      when(mockUser.uid).thenReturn('test-user-id');
      when(mockAuthService.currentUser).thenReturn(mockUser);
      when(mockAuthService.isSignedIn).thenReturn(true);
      when(mockHabitService.getHabits()).thenAnswer((_) async => []);
      when(mockTaskService.getTasks()).thenAnswer((_) async => []);
    });

    Widget createTestableWidget({required Widget child}) {
      return ServiceProvider(
        authService: mockAuthService,
        habitService: mockHabitService,
        aiService: AIService(apiKey: 'test-key'),
        notificationService: mockNotificationService,
        child: MaterialApp(home: child),
      );
    }

    testWidgets('MainNavigationScreen initial UI and BottomNav test', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(child: const MainNavigationScreen()));
      await tester.pumpAndSettle();

      // Verifica AppBar com título inicial "Hoje"
      expect(find.widgetWithText(AppBar, 'Hoje'), findsOneWidget);

      // Verifica BottomNavigationBar
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      
      // Verifica os itens da BottomNavigationBar
      expect(find.text('Hoje'), findsWidgets); // Pode aparecer em AppBar e BottomNav
      expect(find.text('Hábitos'), findsOneWidget);
      expect(find.text('Tarefas'), findsOneWidget);
      expect(find.text('Timer'), findsOneWidget);
      expect(find.text('Categorias'), findsOneWidget);

      // Verifica FAB
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);

      // Toca no item "Hábitos" da BottomNavigationBar
      await tester.tap(find.descendant(
        of: find.byType(BottomNavigationBar), 
        matching: find.text('Hábitos')
      ));
      await tester.pumpAndSettle();

      // Verifica se o título mudou para "Hábitos"
      expect(find.widgetWithText(AppBar, 'Hábitos'), findsOneWidget);

      // Toca no item "Tarefas"
      await tester.tap(find.descendant(
        of: find.byType(BottomNavigationBar), 
        matching: find.text('Tarefas')
      ));
      await tester.pumpAndSettle();

      // Verifica se o título mudou para "Tarefas" e se tem TabBar
      expect(find.widgetWithText(AppBar, 'Tarefas'), findsOneWidget);
      expect(find.byType(TabBar), findsOneWidget);
      expect(find.text('Tarefas simples'), findsOneWidget);
      expect(find.text('Tarefas recorrentes'), findsOneWidget);

      // Toca no item "Timer"
      await tester.tap(find.descendant(
        of: find.byType(BottomNavigationBar), 
        matching: find.text('Timer')
      ));
      await tester.pumpAndSettle();
      
      expect(find.widgetWithText(AppBar, 'Timer'), findsOneWidget);
      // FAB não deve aparecer na tela Timer
      expect(find.byType(FloatingActionButton), findsNothing);

      // Toca no item "Categorias"
      await tester.tap(find.descendant(
        of: find.byType(BottomNavigationBar), 
        matching: find.text('Categorias')
      ));
      await tester.pumpAndSettle();
      
      expect(find.widgetWithText(AppBar, 'Categorias'), findsOneWidget);
    });

    testWidgets('MainNavigationScreen FAB shows add options', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(child: const MainNavigationScreen()));
      await tester.pumpAndSettle();

      // Toca no FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verifica se o bottom sheet apareceu com as opções
      expect(find.text('Adicionar'), findsOneWidget);
      expect(find.text('Hábito'), findsOneWidget);
      expect(find.text('Tarefa'), findsOneWidget);
      expect(find.text('Tarefa Recorrente'), findsOneWidget);
    });

    testWidgets('MainNavigationScreen AppBar actions', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(child: const MainNavigationScreen()));
      await tester.pumpAndSettle();

      // Na tela inicial "Hoje", deve ter ações de busca, filtro, estatísticas, calendário e ajuda
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
      expect(find.byIcon(Icons.bar_chart), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.byIcon(Icons.help_outline), findsOneWidget);

      // Navega para Hábitos
      await tester.tap(find.descendant(
        of: find.byType(BottomNavigationBar), 
        matching: find.text('Hábitos')
      ));
      await tester.pumpAndSettle();

      // Em Hábitos, deve ter busca, filtro e download
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
      expect(find.byIcon(Icons.file_download_outlined), findsOneWidget);
    });

    testWidgets('MainNavigationScreen Drawer test', (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget(child: const MainNavigationScreen()));
      await tester.pumpAndSettle();

      // Abre o Drawer
      final ScaffoldState scaffold = tester.firstState(find.byType(Scaffold));
      scaffold.openDrawer();
      await tester.pumpAndSettle();

      // Verifica se o Drawer está aberto
      expect(find.byType(Drawer), findsOneWidget);
    });
  });
}
