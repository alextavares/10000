import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:myapp/main.dart';
import 'package:integration_test/integration_test.dart';
import 'package:myapp/screens/habits/habits_screen.dart';
import 'package:myapp/screens/habit/add_habit_screen.dart';
import '../test_helpers/test_setup.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  setUpAll(() async {
    await setupTestEnvironment();
  });

  group('Testes de Integração - Hábitos', () {
    testWidgets('Deve adicionar um novo hábito com sucesso', (WidgetTester tester) async {
      // Arrange - Iniciar o app
      await tester.pumpWidget(MyApp(onboardingCompleted: true));
      await tester.pumpAndSettle();

      // Navegar para a tela de hábitos
      await tester.tap(find.text('Hábitos'));
      await tester.pumpAndSettle();

      // Verificar que estamos na tela de hábitos
      expect(find.byType(HabitsScreen), findsOneWidget);

      // Act - Clicar no FAB para adicionar hábito
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verificar que estamos na tela de adicionar hábito
      expect(find.byType(AddHabitScreen), findsOneWidget);

      // Preencher o formulário
      await tester.enterText(
        find.byKey(const Key('habit_title_field')), 
        'Beber água'
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('habit_description_field')), 
        'Beber 2 litros por dia'
      );
      await tester.pumpAndSettle();

      // Selecionar categoria
      await tester.tap(find.byKey(const Key('category_selector')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Saúde'));
      await tester.pumpAndSettle();

      // Salvar o hábito
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      // Assert - Verificar que voltamos para a tela de hábitos
      expect(find.byType(HabitsScreen), findsOneWidget);
      
      // Verificar que o hábito aparece na lista
      expect(find.text('Beber água'), findsOneWidget);
      expect(find.text('Beber 2 litros por dia'), findsOneWidget);
    });

    testWidgets('Deve marcar hábito como completo', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(MyApp(onboardingCompleted: true));
      await tester.pumpAndSettle();

      // Navegar para hábitos
      await tester.tap(find.text('Hábitos'));
      await tester.pumpAndSettle();

      // Assumindo que já existe um hábito "Beber água"
      expect(find.text('Beber água'), findsOneWidget);

      // Act - Marcar como completo
      final checkbox = find.byType(Checkbox).first;
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      // Assert - Verificar que foi marcado
      final Checkbox checkboxWidget = tester.widget(checkbox);
      expect(checkboxWidget.value, true);
    });

    testWidgets('Deve deletar um hábito', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(MyApp(onboardingCompleted: true));
      await tester.pumpAndSettle();

      // Navegar para hábitos
      await tester.tap(find.text('Hábitos'));
      await tester.pumpAndSettle();

      // Clicar no hábito para ver detalhes
      await tester.tap(find.text('Beber água'));
      await tester.pumpAndSettle();

      // Act - Clicar no botão de deletar
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Confirmar deleção no diálogo
      await tester.tap(find.text('Deletar'));
      await tester.pumpAndSettle();

      // Assert - Verificar que voltamos para a lista e o hábito não existe mais
      expect(find.byType(HabitsScreen), findsOneWidget);
      expect(find.text('Beber água'), findsNothing);
    });

    testWidgets('Deve editar um hábito existente', (WidgetTester tester) async {
      // Arrange - Criar um hábito primeiro
      await tester.pumpWidget(MyApp(onboardingCompleted: true));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hábitos'));
      await tester.pumpAndSettle();

      // Adicionar um hábito
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('habit_title_field')), 
        'Exercício'
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      // Act - Editar o hábito
      await tester.tap(find.text('Exercício'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Limpar e digitar novo título
      await tester.enterText(
        find.byKey(const Key('habit_title_field')), 
        'Exercício matinal'
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Exercício matinal'), findsOneWidget);
      expect(find.text('Exercício'), findsNothing);
    });

    testWidgets('Deve filtrar hábitos por dia da semana', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(MyApp(onboardingCompleted: true));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hábitos'));
      await tester.pumpAndSettle();

      // Act - Clicar em um dia diferente no calendário
      final dayWidgets = find.byKey(const Key('day_selector'));
      if (dayWidgets.evaluate().isNotEmpty) {
        await tester.tap(dayWidgets.at(2)); // Terceiro dia
        await tester.pumpAndSettle();
      }

      // Assert - A lista deve ser atualizada (específico para hábitos daquele dia)
      // Este teste dependeria dos hábitos configurados para dias específicos
      expect(find.byType(HabitsScreen), findsOneWidget);
    });
  });
}
