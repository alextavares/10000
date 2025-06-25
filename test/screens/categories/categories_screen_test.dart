import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:myapp/models/category.dart' as app_category;
import 'package:myapp/models/habit.dart'; // Necessário para o mock do HabitService
import 'package:myapp/services/category_service.dart';
import 'package:myapp/services/habit_service.dart';
import 'package:myapp/screens/categories/categories_screen.dart';
import 'package:myapp/screens/categories/add_edit_category_screen.dart';
import 'package:provider/provider.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

// Mocks
class MockCategoryService extends Mock implements CategoryService {}
class MockHabitService extends Mock implements HabitService {} // Mock para HabitService
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockCategoryService mockCategoryService;
  late MockHabitService mockHabitService;
  late MockNavigatorObserver mockNavigatorObserver;

  final defaultCategories = app_category.Category.defaultCategories;
  final customCategoriesList = [
    app_category.Category(
        id: 'custom1',
        name: 'Leitura',
        icon: Icons.book,
        color: Colors.blue,
        isDefault: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: 'test_user'),
    app_category.Category(
        id: 'custom2',
        name: 'Exercício',
        icon: Icons.fitness_center,
        color: Colors.green,
        isDefault: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: 'test_user'),
  ];

  setUp(() {
    mockCategoryService = MockCategoryService();
    mockHabitService = MockHabitService(); // Inicializa o mock do HabitService
    mockNavigatorObserver = MockNavigatorObserver();

    // Mock para getCategories retornando padrão e personalizadas
    when(mockCategoryService.getCategories()).thenAnswer((_) async => [...defaultCategories, ...customCategoriesList]);
    // Mock para deleteCategory
    when(mockCategoryService.deleteCategory(any, habitService: anyNamed('habitService'))).thenAnswer((_) async => Future.value());
  });

  Widget createCategoriesScreen() {
    return MultiProvider(
      providers: [
        Provider<CategoryService>.value(value: mockCategoryService),
        Provider<HabitService>.value(value: mockHabitService), // Fornece o MockHabitService
      ],
      child: MaterialApp(
        home: const CategoriesScreen(),
        navigatorObservers: [mockNavigatorObserver],
        // Definir uma rota para AddEditCategoryScreen para que a navegação funcione
        routes: {
          '/addEditCategory': (context) => AddEditCategoryScreen(
                // Passar mocks se AddEditCategoryScreen precisar deles diretamente,
                // ou confiar que ela usará Provider.of(context)
              ),
        },
      ),
    );
  }

  group('CategoriesScreen Widget Tests', () {
    testWidgets('Deve exibir AppBar com título e botão de adicionar', (WidgetTester tester) async {
      await tester.pumpWidget(createCategoriesScreen());
      await tester.pumpAndSettle(); // Aguarda a conclusão do FutureBuilder

      expect(find.text('Gerenciar Categorias'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget); // FAB
    });

    testWidgets('Deve exibir lista de categorias padrão e personalizadas', (WidgetTester tester) async {
      await tester.pumpWidget(createCategoriesScreen());
      await tester.pumpAndSettle();

      expect(find.text('Minhas Categorias'), findsOneWidget);
      expect(find.text('Categorias Padrão'), findsOneWidget);

      // Verifica algumas categorias padrão
      expect(find.text(defaultCategories.first.name), findsOneWidget);
      // Verifica algumas categorias personalizadas
      expect(find.text('Leitura'), findsOneWidget);
      expect(find.text('Exercício'), findsOneWidget);
    });

    testWidgets('Tocar no FAB deve navegar para AddEditCategoryScreen', (WidgetTester tester) async {
      await tester.pumpWidget(createCategoriesScreen());
      await tester.pumpAndSettle();

      // Simular que pode adicionar mais categorias
      final fab = find.widgetWithIcon(FloatingActionButton, Icons.add);
      expect(fab, findsOneWidget);

      // Verificando se o FAB está habilitado (precisaria de uma forma de verificar isso ou assumir que está)
      // Para este teste, vamos assumir que está habilitado.
      await tester.tap(fab);
      await tester.pumpAndSettle(); // Aguarda a navegação

      // Verifica se AddEditCategoryScreen foi empurrada para a pilha de navegação
      verify(mockNavigatorObserver.didPush(any, any)).called(1);
      expect(find.byType(AddEditCategoryScreen), findsOneWidget);
    });

    testWidgets('PopupMenuButton deve aparecer para categorias personalizadas', (WidgetTester tester) async {
      await tester.pumpWidget(createCategoriesScreen());
      await tester.pumpAndSettle();

      // Encontra o PopupMenuButton para a primeira categoria personalizada
      final customCategoryTile = find.widgetWithText(ListTile, 'Leitura');
      expect(customCategoryTile, findsOneWidget);

      final popupMenuButton = find.descendant(
        of: customCategoryTile,
        matching: find.byIcon(Icons.more_vert),
      );
      expect(popupMenuButton, findsOneWidget);

      // Categorias padrão não devem ter o PopupMenuButton
      final defaultCategoryTile = find.widgetWithText(ListTile, defaultCategories.first.name);
      expect(defaultCategoryTile, findsOneWidget);
      final noPopupMenuButton = find.descendant(
        of: defaultCategoryTile,
        matching: find.byIcon(Icons.more_vert),
      );
      expect(noPopupMenuButton, findsNothing);
    });

    testWidgets('Tocar em Editar no PopupMenuButton navega para AddEditCategoryScreen com a categoria', (WidgetTester tester) async {
      await tester.pumpWidget(createCategoriesScreen());
      await tester.pumpAndSettle();

      final customCategoryTile = find.widgetWithText(ListTile, 'Leitura');
      final popupMenuButton = find.descendant(of: customCategoryTile, matching: find.byIcon(Icons.more_vert));

      await tester.tap(popupMenuButton);
      await tester.pumpAndSettle(); // Para o menu aparecer

      await tester.tap(find.text('Editar').last); // .last para garantir que é o do menu
      await tester.pumpAndSettle(); // Aguarda a navegação

      verify(mockNavigatorObserver.didPush(any, any)).called(1);
      expect(find.byType(AddEditCategoryScreen), findsOneWidget);

      // Verificar se AddEditCategoryScreen recebeu a categoria correta
      final AddEditCategoryScreen addEditScreen = tester.widget(find.byType(AddEditCategoryScreen));
      expect(addEditScreen.categoryToEdit, isNotNull);
      expect(addEditScreen.categoryToEdit!.name, 'Leitura');
    });

     testWidgets('Tocar em Excluir no PopupMenuButton mostra diálogo e chama deleteCategory', (WidgetTester tester) async {
      when(mockCategoryService.deleteCategory(customCategoriesList.first.id, habitService: mockHabitService))
          .thenAnswer((_) async => Future.value());
      // Recarregar categorias após a exclusão para simular a atualização da lista
      when(mockCategoryService.getCategories()).thenAnswer((_) async => defaultCategories);


      await tester.pumpWidget(createCategoriesScreen());
      await tester.pumpAndSettle();

      final customCategoryTile = find.widgetWithText(ListTile, 'Leitura');
      final popupMenuButton = find.descendant(of: customCategoryTile, matching: find.byIcon(Icons.more_vert));

      await tester.tap(popupMenuButton);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Excluir').last);
      await tester.pumpAndSettle(); // Para o diálogo aparecer

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Tem certeza que deseja excluir a categoria "Leitura"? Os hábitos associados a esta categoria serão movidos para "Outros". Esta ação não pode ser desfeita.'), findsOneWidget);

      await tester.tap(find.text('Excluir').last); // Botão de confirmação no diálogo
      await tester.pumpAndSettle(); // Aguarda a exclusão e reconstrução

      verify(mockCategoryService.deleteCategory(customCategoriesList.first.id, habitService: mockHabitService)).called(1);
      // Verifica se a categoria foi removida da UI (FutureBuilder deve reconstruir)
      // Este expect pode falhar se a _loadCategories não for chamada e o FutureBuilder não for notificado
      // Para garantir, após a exclusão, o _loadCategories é chamado, o que cria um novo Future.
      expect(find.text('Leitura'), findsNothing);
    });

    testWidgets('FAB é desabilitado se o limite de categorias personalizadas for atingido', (WidgetTester tester) async {
      // Simular que o limite de 10 categorias foi atingido
      final manyCustomCategories = List.generate(
        10,
        (i) => app_category.Category(
          id: 'custom$i',
          name: 'Custom $i',
          icon: Icons.star,
          color: Colors.yellow,
          isDefault: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          userId: 'test_user'
        )
      );
      when(mockCategoryService.getCategories()).thenAnswer((_) async => [...defaultCategories, ...manyCustomCategories]);

      await tester.pumpWidget(createCategoriesScreen());
      await tester.pumpAndSettle();

      final fab = tester.widget<FloatingActionButtonExtended>(find.byType(FloatingActionButtonExtended));
      expect(fab.onPressed, isNull); // onPressed é null quando desabilitado
      expect(find.byTooltip('Limite de categorias atingido'), findsOneWidget);
    });

    testWidgets('Mostra mensagem quando não há categorias personalizadas', (WidgetTester tester) async {
      when(mockCategoryService.getCategories()).thenAnswer((_) async => defaultCategories); // Apenas categorias padrão

      await tester.pumpWidget(createCategoriesScreen());
      await tester.pumpAndSettle();

      expect(find.text('Você ainda não criou nenhuma categoria personalizada.\nToque em "Nova Categoria" para começar!'), findsOneWidget);
    });

  });
}
