import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/main.dart';
import 'test_helpers/test_setup.dart';

void main() {
  setUpAll(() async {
    await setupTestEnvironment();
  });

  testWidgets('App deve inicializar corretamente', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(onboardingCompleted: true));
    await tester.pumpAndSettle();

    // Verify that the app starts correctly
    // Should show the main navigation
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    
    // Should have navigation items
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.fitness_center), findsOneWidget);
    expect(find.byIcon(Icons.task_alt), findsOneWidget);
    expect(find.byIcon(Icons.insights), findsOneWidget);
  });

  testWidgets('App deve mostrar onboarding quando não completado', (WidgetTester tester) async {
    // Build our app with onboarding not completed
    await tester.pumpWidget(MyApp(onboardingCompleted: false));
    await tester.pumpAndSettle();

    // Should show onboarding screen
    expect(find.text('Welcome to HabitAI'), findsOneWidget);
  });

  testWidgets('Navegação entre telas deve funcionar', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(MyApp(onboardingCompleted: true));
    await tester.pumpAndSettle();

    // Navigate to habits
    await tester.tap(find.byIcon(Icons.fitness_center));
    await tester.pumpAndSettle();

    // Navigate to tasks
    await tester.tap(find.byIcon(Icons.task_alt));
    await tester.pumpAndSettle();

    // Navigate to insights
    await tester.tap(find.byIcon(Icons.insights));
    await tester.pumpAndSettle();

    // Navigate back to home
    await tester.tap(find.byIcon(Icons.home));
    await tester.pumpAndSettle();

    // Should be back at home
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}
