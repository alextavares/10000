import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:myapp/models/category.dart' as app_category;
import 'package:myapp/models/habit.dart';
import 'package:myapp/services/category_service.dart';
import 'package:myapp/services/habit_service.dart';
import 'package:myapp/screens/habit/upsert_habit_screen.dart';
import 'package:myapp/screens/categories/add_edit_category_screen.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:intl/date_symbol_data_local.dart';

// Mocks
class MockCategoryService extends Mock implements CategoryService {}
class MockHabitService extends Mock implements HabitService {}
class MockNavigatorObserver extends Mock implements NavigatorObserver {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}


Habit createSampleHabitForEdit() {
  return Habit(
    id: 'edit_habit_id',
    title: 'Yoga Matinal',
    description: 'Praticar yoga por 20 minutos',
    category: 'Saúde', // Nome da categoria
    icon: Icons.spa,
    color: Colors.green,
    frequency: HabitFrequency.daily,
    startDate: DateTime.now().subtract(const Duration(days: 5)),
    reminderTime: const TimeOfDay(hour: 7, minute: 0),
    notificationsEnabled: true,
    priority: 'Alta',
    trackingType: HabitTrackingType.cronometro,
    targetTime: const Duration(minutes: 20),
    createdAt: DateTime.now().subtract(const Duration(days: 10)),
    updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    userId: 'test_user_id',
    completionHistory: {},
    dailyProgress: {},
  );
}

void main() {
  late MockCategoryService mockCategoryService;
  late MockHabitService mockHabitService;
  late MockNavigatorObserver mockNavigatorObserver;
  late MockFirebaseAuth mockAuth;
  late User mockUser;

  final defaultCategories = app_category.Category.defaultCategories;
  final healthCategory = defaultCategories.firstWhere((c) => c.name == 'Saúde');

  setUpAll(() async {
    // Essencial para formatação de data/hora nos testes
    await initializeDateFormatting('pt_BR', null);
  });

  setUp(() {
    mockCategoryService = MockCategoryService();
    mockHabitService = MockHabitService();
    mockNavigatorObserver = MockNavigatorObserver();
    mockUser = MockUser(uid: 'test_user_id', email: 'test@example.com');
    mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);


    when(mockCategoryService.getCategories()).thenAnswer((_) async => defaultCategories);
    when(mockCategoryService.getCategoryByName(any)).thenAnswer((invocation) async {
        final name = invocation.positionalArguments.first as String;
        return defaultCategories.firstWhere((cat) => cat.name == name, orElse: () => defaultCategories.first);
    });
    when(mockHabitService.addHabit(any)).thenAnswer((_) async => 'new_habit_id');
    when(mockHabitService.updateHabit(any)).thenAnswer((_) async => Future.value());
  });

  Widget createUpsertHabitScreen({Habit? habitToEdit}) {
    return MultiProvider(
      providers: [
        Provider<CategoryService>.value(value: mockCategoryService),
        Provider<HabitService>.value(value: mockHabitService),
        // Fornecendo uma instância mockada do FirebaseAuth para o Provider
        Provider<FirebaseAuth>.value(value: mockAuth),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: UpsertHabitScreen(habitToEdit: habitToEdit),
        navigatorObservers: [mockNavigatorObserver],
        routes: {
          // Rota para AddEditCategoryScreen para testar a navegação
          '/addEditCategory': (context) => const AddEditCategoryScreen(),
        },
      ),
    );
  }

  group('UpsertHabitScreen Widget Tests', () {
    testWidgets('Modo de Criação: exibe título "Novo Hábito" e campos iniciais', (WidgetTester tester) async {
      await tester.pumpWidget(createUpsertHabitScreen());
      await tester.pumpAndSettle(); // Para FutureBuilder do CategoryService

      expect(find.text('Novo Hábito'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, ''), findsNWidgets(2)); // Nome e Descrição (inicialmente vazios)
      expect(find.text('Categoria'), findsOneWidget);
      expect(find.text('Prioridade'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Criar Hábito'), findsOneWidget);
    });

    testWidgets('Modo de Edição: exibe título "Editar Hábito" e preenche campos', (WidgetTester tester) async {
      final habit = createSampleHabitForEdit();
      // Certificar que a categoria do hábito de teste existe nas categorias mockadas
      when(mockCategoryService.getCategories()).thenAnswer((_) async => [
            ...defaultCategories,
            app_category.Category(id: 'cat_saude', name: 'Saúde', icon: Icons.spa, color: Colors.green, isDefault: true, createdAt: DateTime.now(), updatedAt: DateTime.now())
          ]);

      await tester.pumpWidget(createUpsertHabitScreen(habitToEdit: habit));
      await tester.pumpAndSettle(); // Para FutureBuilder e initState async

      expect(find.text('Editar Hábito'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Yoga Matinal'), findsOneWidget); // Nome
      expect(find.widgetWithText(TextFormField, 'Praticar yoga por 20 minutos'), findsOneWidget); // Descrição

      // Verificar categoria selecionada
      expect(find.text(healthCategory.name), findsWidgets); // Pode aparecer no dropdown e no item selecionado

      // Verificar prioridade
      expect(find.text('Alta'), findsWidgets); // No DropdownButtonFormField

      // Verificar tipo de monitoramento
      expect(find.text('Cronômetro'), findsWidgets);
      expect(find.text('Meta de Tempo'), findsOneWidget); // Label do campo de tempo
      // Verificar valor do tempo (mais complexo, depende de como é formatado)
      expect(find.textContaining('20 minutos'), findsOneWidget);


      expect(find.widgetWithText(ElevatedButton, 'Salvar Alterações'), findsOneWidget);
    });

    testWidgets('Validação: Nome do hábito é obrigatório', (WidgetTester tester) async {
      await tester.pumpWidget(createUpsertHabitScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Criar Hábito'));
      await tester.pumpAndSettle();
      expect(find.text('O nome do hábito é obrigatório.'), findsOneWidget);
    });

    testWidgets('Validação: Categoria é obrigatória', (WidgetTester tester) async {
      await tester.pumpWidget(createUpsertHabitScreen());
      await tester.pumpAndSettle();

      // Simula que o _selectedCategory é null. O DropdownButtonFormField deve ter um validator.
      // O teste aqui é mais para a lógica de _saveHabit
      final UpsertHabitScreenState state = tester.state(find.byType(UpsertHabitScreen));
      state.setState(() {
        state.clearSelectedCategory(); // Método hipotético para limpar a categoria
      });
      await tester.pumpAndSettle();

      await tester.enterText(find.byWidgetPredicate((widget) => widget is TextFormField && widget.decoration?.labelText == 'Nome do Hábito'), 'Teste');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Criar Hábito'));
      await tester.pumpAndSettle();

      expect(find.text('Por favor, selecione uma categoria.'), findsOneWidget);
    });

    testWidgets('Navega para AddEditCategoryScreen ao tocar em "Criar nova categoria"', (WidgetTester tester) async {
      await tester.pumpWidget(createUpsertHabitScreen());
      await tester.pumpAndSettle();

      // Encontra o TextButton "Criar nova categoria"
      // O seletor pode precisar ser mais específico se houver outros TextButtons
      final createCategoryButton = find.widgetWithText(TextButton, 'Criar nova categoria');
      expect(createCategoryButton, findsOneWidget);

      await tester.tap(createCategoryButton);
      await tester.pumpAndSettle(); // Aguarda a navegação

      verify(mockNavigatorObserver.didPush(any, any)).called(1);
      expect(find.byType(AddEditCategoryScreen), findsOneWidget);
    });

    testWidgets('Campos de Quantidade aparecem quando tipo "Quantidade" é selecionado', (WidgetTester tester) async {
      await tester.pumpWidget(createUpsertHabitScreen());
      await tester.pumpAndSettle();

      // Encontrar o DropdownButtonFormField para Tipo de Monitoramento
      // O texto inicial é "Sim ou Não"
      await tester.tap(find.text('Sim ou Não'));
      await tester.pumpAndSettle(); // Abrir o dropdown

      // Selecionar "Quantidade"
      await tester.tap(find.text('Quantidade').last);
      await tester.pumpAndSettle(); // Fechar o dropdown e reconstruir a UI

      expect(find.text('Meta de Quantidade'), findsOneWidget);
      expect(find.text('Unidade (Opcional)'), findsOneWidget);
    });

    testWidgets('Validação de Meta de Quantidade', (WidgetTester tester) async {
      await tester.pumpWidget(createUpsertHabitScreen());
      await tester.pumpAndSettle();

      // Selecionar Categoria
      await tester.tap(find.text(_UpsertHabitScreenState()._availableCategories.first.name).first); // Clica no dropdown
      await tester.pumpAndSettle();
      await tester.tap(find.text(_UpsertHabitScreenState()._availableCategories.first.name).last); // Seleciona o item
      await tester.pumpAndSettle();

      // Selecionar Tipo Quantidade
      await tester.tap(find.text('Sim ou Não')); // Abre o dropdown de tipo
      await tester.pumpAndSettle();
      await tester.tap(find.text('Quantidade').last); // Seleciona Quantidade
      await tester.pumpAndSettle();

      await tester.enterText(find.byWidgetPredicate((widget) => widget is TextFormField && widget.decoration?.labelText == 'Nome do Hábito'), 'Hábito Quantidade');
      // Não preenche a meta de quantidade

      await tester.tap(find.widgetWithText(ElevatedButton, 'Criar Hábito'));
      await tester.pumpAndSettle();

      expect(find.text('Por favor, defina uma meta de quantidade.'), findsOneWidget);
    });

    testWidgets('Salvar hábito com sucesso deve chamar habitService.addHabit e fechar', (WidgetTester tester) async {
      when(mockCategoryService.getCategories()).thenAnswer((_) async => [healthCategory]);
      when(mockHabitService.addHabit(any)).thenAnswer((_) async => 'some_id');

      await tester.pumpWidget(createUpsertHabitScreen());
      await tester.pumpAndSettle();

      // Preencher campos obrigatórios
      await tester.enterText(find.byWidgetPredicate((widget) => widget is TextFormField && widget.decoration?.labelText == 'Nome do Hábito'), 'Novo Hábito Teste');

      // Selecionar Categoria (Saúde já deve estar selecionada ou ser a primeira)
      // Se não estiver, simular a seleção
      final UpsertHabitScreenState state = tester.state(find.byType(UpsertHabitScreen));
      if (state.getSelectedCategory() == null && state.getAvailableCategories().isNotEmpty) {
          await tester.tap(find.byWidgetPredicate((widget) => widget is DropdownButtonFormField<app_category.Category> && widget.decoration.labelText == 'Categoria'));
          await tester.pumpAndSettle();
          await tester.tap(find.text(state.getAvailableCategories().first.name).last);
          await tester.pumpAndSettle();
      }

      // Selecionar Tipo de Monitoramento (Sim ou Não já é padrão)
      // Selecionar Frequência (Diariamente já é padrão)

      await tester.tap(find.widgetWithText(ElevatedButton, 'Criar Hábito'));
      await tester.pump(); // Inicia o _isLoading
      // A chamada ao service é async, então precisamos esperar.
      // O pumpAndSettle pode não ser suficiente se o service levar tempo.
      // No mock, ele é rápido.
      await tester.pumpAndSettle(const Duration(milliseconds: 100));


      verify(mockHabitService.addHabit(any)).called(1);
      verify(mockNavigatorObserver.didPop(any, true)).called(1);
      expect(find.byType(UpsertHabitScreen), findsNothing);
    });

  });
}

// Adicionar um método auxiliar no State para testes poderem acessar _selectedCategory
// Isso é um pouco invasivo, mas útil para testes de widget.
// Uma alternativa seria usar keys nos widgets.
extension UpsertHabitScreenStateTestExtension on _UpsertHabitScreenState {
  app_category.Category? getSelectedCategory() => _selectedCategory;
  List<app_category.Category> getAvailableCategories() => _availableCategories;
  void clearSelectedCategory() {
    _selectedCategory = null;
  }
}
