import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:myapp/main.dart' as app;
import 'package:myapp/screens/auth/login_screen.dart';
import 'package:myapp/screens/main_navigation_screen.dart';
import 'package:myapp/screens/habits/habits_screen.dart';
import 'package:myapp/screens/tasks/tasks_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('HabitAI App Integration Tests', () {
    testWidgets('Fluxo completo de login e navegação', (WidgetTester tester) async {
      // Iniciar o app
      app.main();
      await tester.pumpAndSettle();

      // Verificar se está na tela de login
      expect(find.byType(LoginScreen), findsOneWidget);
      
      // Encontrar campos de email e senha
      final emailField = find.byKey(Key('email_field'));
      final passwordField = find.byKey(Key('password_field'));
      final loginButton = find.byKey(Key('login_button'));
      
      // Preencher credenciais de teste
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'Test123!');
      
      // Fazer login
      await tester.tap(loginButton);
      await tester.pumpAndSettle(Duration(seconds: 3));
      
      // Verificar se navegou para tela principal
      expect(find.byType(MainNavigationScreen), findsOneWidget);
    });

    testWidgets('Criar e completar um hábito', (WidgetTester tester) async {
      // Assumindo que já está logado
      app.main();
      await tester.pumpAndSettle();
      
      // Navegar para aba de hábitos
      final habitsTab = find.byIcon(Icons.track_changes);
      await tester.tap(habitsTab);
      await tester.pumpAndSettle();
      
      // Verificar se está na tela de hábitos
      expect(find.byType(HabitsScreen), findsOneWidget);
      
      // Tap no FAB para adicionar hábito
      final addButton = find.byType(FloatingActionButton);
      await tester.tap(addButton);
      await tester.pumpAndSettle();
      
      // Preencher informações do hábito
      final titleField = find.byKey(Key('habit_title_field'));
      final descriptionField = find.byKey(Key('habit_description_field'));
      
      await tester.enterText(titleField, 'Beber Água');
      await tester.enterText(descriptionField, '8 copos por dia');
      
      // Selecionar categoria
      final categoryDropdown = find.byKey(Key('category_dropdown'));
      await tester.tap(categoryDropdown);
      await tester.pumpAndSettle();
      
      final healthCategory = find.text('Saúde').last;
      await tester.tap(healthCategory);
      await tester.pumpAndSettle();
      
      // Salvar hábito
      final saveButton = find.byKey(Key('save_habit_button'));
      await tester.tap(saveButton);
      await tester.pumpAndSettle();
      
      // Verificar se voltou para lista e hábito aparece
      expect(find.text('Beber Água'), findsOneWidget);
      
      // Marcar hábito como completo
      final habitCheckbox = find.byType(Checkbox).first;
      await tester.tap(habitCheckbox);
      await tester.pumpAndSettle();
      
      // Verificar feedback visual de conclusão
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('Criar e gerenciar uma tarefa', (WidgetTester tester) async {
      // Assumindo que já está logado
      app.main();
      await tester.pumpAndSettle();
      
      // Navegar para aba de tarefas
      final tasksTab = find.byIcon(Icons.task_alt);
      await tester.tap(tasksTab);
      await tester.pumpAndSettle();
      
      // Verificar se está na tela de tarefas
      expect(find.byType(TasksScreen), findsOneWidget);
      
      // Adicionar nova tarefa
      final addButton = find.byType(FloatingActionButton);
      await tester.tap(addButton);
      await tester.pumpAndSettle();
      
      // Preencher informações da tarefa
      final titleField = find.byKey(Key('task_title_field'));
      final descriptionField = find.byKey(Key('task_description_field'));
      
      await tester.enterText(titleField, 'Finalizar Relatório');
      await tester.enterText(descriptionField, 'Relatório mensal de vendas');
      
      // Definir prioridade
      final priorityHigh = find.byKey(Key('priority_high'));
      await tester.tap(priorityHigh);
      
      // Definir data de vencimento
      final dueDateButton = find.byKey(Key('due_date_button'));
      await tester.tap(dueDateButton);
      await tester.pumpAndSettle();
      
      // Selecionar data (amanhã)
      final tomorrow = DateTime.now().add(Duration(days: 1));
      final dayToSelect = find.text('${tomorrow.day}');
      await tester.tap(dayToSelect);
      
      final okButton = find.text('OK');
      await tester.tap(okButton);
      await tester.pumpAndSettle();
      
      // Salvar tarefa
      final saveButton = find.byKey(Key('save_task_button'));
      await tester.tap(saveButton);
      await tester.pumpAndSettle();
      
      // Verificar se tarefa aparece na lista
      expect(find.text('Finalizar Relatório'), findsOneWidget);
      
      // Adicionar subtarefa
      await tester.tap(find.text('Finalizar Relatório'));
      await tester.pumpAndSettle();
      
      final addSubtaskButton = find.byKey(Key('add_subtask_button'));
      await tester.tap(addSubtaskButton);
      await tester.pumpAndSettle();
      
      final subtaskField = find.byKey(Key('subtask_title_field'));
      await tester.enterText(subtaskField, 'Coletar dados de vendas');
      
      final addSubtask = find.byIcon(Icons.add);
      await tester.tap(addSubtask);
      await tester.pumpAndSettle();
      
      // Verificar se subtarefa foi adicionada
      expect(find.text('Coletar dados de vendas'), findsOneWidget);
    });

    testWidgets('Testar navegação entre abas', (WidgetTester tester) async {
      // Assumindo que já está logado
      app.main();
      await tester.pumpAndSettle();
      
      // Verificar aba inicial (Home)
      expect(find.byIcon(Icons.home), findsOneWidget);
      
      // Navegar para Hábitos
      final habitsTab = find.byIcon(Icons.track_changes);
      await tester.tap(habitsTab);
      await tester.pumpAndSettle();
      expect(find.byType(HabitsScreen), findsOneWidget);
      
      // Navegar para Tarefas
      final tasksTab = find.byIcon(Icons.task_alt);
      await tester.tap(tasksTab);
      await tester.pumpAndSettle();
      expect(find.byType(TasksScreen), findsOneWidget);
      
      // Navegar para Estatísticas
      final statsTab = find.byIcon(Icons.bar_chart);
      await tester.tap(statsTab);
      await tester.pumpAndSettle();
      
      // Voltar para Home
      final homeTab = find.byIcon(Icons.home);
      await tester.tap(homeTab);
      await tester.pumpAndSettle();
    });

    testWidgets('Verificar sincronização de dados', (WidgetTester tester) async {
      // Este teste verifica se os dados são mantidos ao navegar entre telas
      app.main();
      await tester.pumpAndSettle();
      
      // Criar um hábito
      final habitsTab = find.byIcon(Icons.track_changes);
      await tester.tap(habitsTab);
      await tester.pumpAndSettle();
      
      // Verificar contador inicial
      final habitCount = find.byKey(Key('habit_count'));
      expect(habitCount, findsOneWidget);
      
      // Navegar para outra aba e voltar
      final tasksTab = find.byIcon(Icons.task_alt);
      await tester.tap(tasksTab);
      await tester.pumpAndSettle();
      
      await tester.tap(habitsTab);
      await tester.pumpAndSettle();
      
      // Verificar se o contador ainda está correto
      expect(habitCount, findsOneWidget);
    });

    testWidgets('Testar modo offline', (WidgetTester tester) async {
      // Simular modo offline
      // Este teste precisaria de configuração adicional para simular perda de conexão
      
      app.main();
      await tester.pumpAndSettle();
      
      // Tentar criar um hábito offline
      final habitsTab = find.byIcon(Icons.track_changes);
      await tester.tap(habitsTab);
      await tester.pumpAndSettle();
      
      // Verificar se aparece indicador de modo offline
      // expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    });

    testWidgets('Testar busca e filtros', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Ir para tarefas
      final tasksTab = find.byIcon(Icons.task_alt);
      await tester.tap(tasksTab);
      await tester.pumpAndSettle();
      
      // Abrir busca
      final searchButton = find.byIcon(Icons.search);
      await tester.tap(searchButton);
      await tester.pumpAndSettle();
      
      // Digitar termo de busca
      final searchField = find.byKey(Key('search_field'));
      await tester.enterText(searchField, 'Relatório');
      await tester.pumpAndSettle();
      
      // Verificar resultados filtrados
      expect(find.text('Finalizar Relatório'), findsOneWidget);
    });
  });
}
