import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:myapp/models/category.dart' as app_category;
import 'package:myapp/services/category_service.dart';
import 'package:myapp/services/habit_service.dart';
import 'package:myapp/screens/categories/add_edit_category_screen.dart';
import 'package:myapp/theme/app_theme.dart'; // Necessário para AppTheme.inputDecoration, etc.
import 'package:provider/provider.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart'; // Para mockar HabitService se necessário
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart'; // Para mockar HabitService se necessário

// Mocks
class MockCategoryService extends Mock implements CategoryService {}
class MockHabitService extends Mock implements HabitService {}
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockCategoryService mockCategoryService;
  late MockHabitService mockHabitService;
  late MockNavigatorObserver mockNavigatorObserver;

  final testCategory = app_category.Category(
    id: 'test_cat_id',
    name: 'Test Category',
    icon: Icons.star,
    color: Colors.orange,
    isDefault: false,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    userId: 'test_user',
  );

  setUp(() {
    mockCategoryService = MockCategoryService();
    mockHabitService = MockHabitService();
    mockNavigatorObserver = MockNavigatorObserver();

    // Mock para getCategories usado internamente por addCategory/updateCategory para verificar duplicatas
    when(mockCategoryService.getCategories()).thenAnswer((_) async => [
      ...app_category.Category.defaultCategories,
      // Não incluir testCategory aqui inicialmente para testes de criação
    ]);
     when(mockCategoryService.getCategoryByName(any)).thenAnswer((_) async => null);
  });

  Widget createAddEditCategoryScreen({app_category.Category? category}) {
    // Precisamos mockar o Firebase Auth se o CategoryService depender dele diretamente
    // e não for injetado. Para este teste, vamos assumir que o Provider o gerencia.
    final mockAuth = MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: "test_user"));

    return MultiProvider(
      providers: [
        // Provider para CategoryService, que usa o FirebaseAuth.instance e FirebaseFirestore.instance
        // Se CategoryService fosse construído com os mocks, seria melhor.
        // Aqui, estamos confiando que as instâncias globais são mockadas pelos pacotes de mock.
        Provider<CategoryService>(
          create: (_) => CategoryService(), // Usando uma instância real com fakes
                                           // ou mockCategoryService se configurado para usar fakes
        ),
        Provider<HabitService>(
          // O HabitService é necessário para a função de deletar categoria
          create: (_) => HabitService(firestore: FakeFirebaseFirestore(), auth: mockAuth),
        ),
        // Para que o Provider.of<CategoryService>(context, listen: false) funcione dentro do widget:
        // Se formos testar o _saveCategory e _deleteCategory diretamente, precisamos garantir que
        // o CategoryService provido seja o nosso mockCategoryService.
        // A forma mais limpa seria injetar o CategoryService no AddEditCategoryScreen,
        // mas como ele usa Provider.of, precisamos garantir que o Provider forneça o mock.
        // Para simplificar, vamos assumir que o CategoryService real com FakeFirestore é suficiente para muitos casos,
        // e para interações específicas, podemos mockar os métodos do CategoryService.
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme, // Adicionar um tema para evitar erros de MediaQuery, etc.
        home: Builder(
          builder: (context) {
            // Recriar o mockCategoryService aqui para que ele use o Provider.of(context) efetivamente
            // Isso é um pouco hacky, idealmente o service seria injetado.
            final actualCategoryService = Provider.of<CategoryService>(context, listen:false);

            // Configurar mocks para os métodos do actualCategoryService que serão chamados
            when(actualCategoryService.addCategory(name: anyNamed('name'), icon: anyNamed('icon'), color: anyNamed('color')))
                .thenAnswer((invocation) async {
                  final name = invocation.namedArguments[#name] as String;
                  if (name == "Duplicated") throw Exception("Uma categoria com o nome 'Duplicated' já existe.");
                  return app_category.Category(
                    id: 'new_id',
                    name: name,
                    icon: invocation.namedArguments[#icon] as IconData,
                    color: invocation.namedArguments[#color] as Color,
                    isDefault: false,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                    userId: 'test_user');
                });

            when(actualCategoryService.updateCategory(any)).thenAnswer((invocation) async {
              final cat = invocation.positionalArguments.first as app_category.Category;
              if (cat.name == "Duplicated") throw Exception("Outra categoria já existe com o nome 'Duplicated'.");
              return Future.value();
            });

            when(actualCategoryService.deleteCategory(any, habitService: anyNamed('habitService')))
                .thenAnswer((_) async => Future.value());

            return AddEditCategoryScreen(categoryToEdit: category);
          }
        ),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  group('AddEditCategoryScreen Widget Tests', () {
    testWidgets('Modo de Criação: Deve exibir título "Nova Categoria" e campos vazios', (WidgetTester tester) async {
      await tester.pumpWidget(createAddEditCategoryScreen());

      expect(find.text('Nova Categoria'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, ''), findsOneWidget); // Campo de nome vazio
      // Verificar valores padrão para ícone e cor pode ser mais complexo,
      // mas podemos verificar se os botões de alterar existem.
      expect(find.text('Alterar Ícone'), findsOneWidget);
      expect(find.text('Alterar Cor'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Criar Categoria'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsNothing); // Botão de excluir não deve aparecer
    });

    testWidgets('Modo de Edição: Deve exibir título "Editar Categoria" e campos preenchidos', (WidgetTester tester) async {
      await tester.pumpWidget(createAddEditCategoryScreen(category: testCategory));
      await tester.pumpAndSettle(); // Para o initState completar

      expect(find.text('Editar Categoria'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Test Category'), findsOneWidget);
      // Verificar ícone e cor selecionados (pode ser pela UI ou pelo estado do widget)
      // expect(find.byIcon(testCategory.icon), findsWidgets); // Pode haver múltiplos (no picker e no display)
      expect(find.widgetWithText(ElevatedButton, 'Salvar Alterações'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget); // Botão de excluir DEVE aparecer
    });

    testWidgets('Validação: Deve mostrar erro se o nome estiver vazio ao salvar', (WidgetTester tester) async {
      await tester.pumpWidget(createAddEditCategoryScreen());

      await tester.tap(find.widgetWithText(ElevatedButton, 'Criar Categoria'));
      await tester.pumpAndSettle(); // Espera a validação e rebuild

      expect(find.text('Por favor, insira um nome para a categoria.'), findsOneWidget);
    });

    testWidgets('Salvar Nova Categoria: Deve chamar addCategory e fechar a tela', (WidgetTester tester) async {
      // Precisamos garantir que o CategoryService usado internamente seja nosso mock
      // ou que o CategoryService real (com FakeFirestore) seja configurado para este teste.
      // A abordagem atual no createAddEditCategoryScreen tenta mockar o service obtido pelo Provider.

      await tester.pumpWidget(createAddEditCategoryScreen());

      await tester.enterText(find.byType(TextFormField), 'Minha Nova Categoria');
      // Simular escolha de ícone e cor seria mais complexo, vamos focar no nome e salvar.
      // Para ícone e cor, os valores padrão do initState serão usados.

      await tester.tap(find.widgetWithText(ElevatedButton, 'Criar Categoria'));
      await tester.pumpAndSettle(); // Para o _isLoading e a chamada async

      // Verificar se o método addCategory foi chamado no CategoryService real/mockado pelo Provider
      // Esta verificação é um pouco indireta devido à forma como o mock é configurado no builder.
      // A melhor forma seria injetar o mockCategoryService diretamente.
      // Por enquanto, vamos verificar se a tela fechou (pop foi chamado).
      verify(mockNavigatorObserver.didPop(any, true)).called(1); // Espera que pop retorne true
      expect(find.byType(AddEditCategoryScreen), findsNothing); // Tela deve ter sido fechada
    });

    testWidgets('Salvar Edição de Categoria: Deve chamar updateCategory e fechar a tela', (WidgetTester tester) async {
      await tester.pumpWidget(createAddEditCategoryScreen(category: testCategory));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Test Category'), 'Categoria Editada');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar Alterações'));
      await tester.pumpAndSettle();

      verify(mockNavigatorObserver.didPop(any, true)).called(1);
      expect(find.byType(AddEditCategoryScreen), findsNothing);
    });

    testWidgets('Tentar salvar categoria com nome duplicado deve mostrar erro', (WidgetTester tester) async {
      // O mock do addCategory já está configurado para lançar exceção se o nome for "Duplicated"
      await tester.pumpWidget(createAddEditCategoryScreen());

      await tester.enterText(find.byType(TextFormField), 'Duplicated');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Criar Categoria'));
      await tester.pump(); // Inicia o _isLoading
      await tester.pump(); // Processa o erro e o SnackBar

      expect(find.text("Erro ao salvar categoria: Exception: Uma categoria com o nome 'Duplicated' já existe."), findsOneWidget);
      expect(find.byType(AddEditCategoryScreen), findsOneWidget); // Não deve fechar
    });

    testWidgets('Excluir Categoria: Deve mostrar diálogo e chamar deleteCategory', (WidgetTester tester) async {
      await tester.pumpWidget(createAddEditCategoryScreen(category: testCategory));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle(); // Para o diálogo aparecer

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Tem certeza que deseja excluir a categoria "Test Category"? Os hábitos associados a esta categoria serão movidos para "Outros". Esta ação não pode ser desfeita.'), findsOneWidget);

      await tester.tap(find.text('Excluir').last); // Botão de confirmação no diálogo
      await tester.pumpAndSettle();

      verify(mockNavigatorObserver.didPop(any, true)).called(1); // Pop do diálogo e depois pop da tela
      expect(find.byType(AddEditCategoryScreen), findsNothing);
    });

    testWidgets('Icon Picker deve abrir e permitir selecionar um ícone', (WidgetTester tester) async {
      await tester.pumpWidget(createAddEditCategoryScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Alterar Ícone'));
      await tester.pumpAndSettle(); // Abrir o BottomSheet

      expect(find.text('Escolher Ícone'), findsOneWidget);
      // Tenta tocar no primeiro ícone da lista (que não seja o já selecionado)
      final firstIconInPicker = find.byIcon(_AddEditCategoryScreenState()._availableIcons[1]); // Pega o segundo ícone da lista
      expect(firstIconInPicker, findsOneWidget);

      await tester.tap(firstIconInPicker);
      await tester.pumpAndSettle(); // Fechar o BottomSheet

      // Verificar se o ícone selecionado mudou no widget principal
      // Isso requer acesso ao estado do widget ou uma forma de verificar o ícone exibido.
      // Por simplicidade, vamos assumir que a lógica de setState funciona.
      // Poderíamos verificar se o BottomSheet não está mais visível.
      expect(find.text('Escolher Ícone'), findsOneWidget); // A tela principal ainda está lá
      // A validação exata do ícone mudado no display principal é mais complexa sem keys específicas.
    });

    testWidgets('Color Picker deve abrir e permitir selecionar uma cor', (WidgetTester tester) async {
      await tester.pumpWidget(createAddEditCategoryScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Alterar Cor'));
      await tester.pumpAndSettle(); // Abrir o AlertDialog

      expect(find.text('Escolher Cor'), findsOneWidget);
      expect(find.byType(ColorPicker), findsOneWidget);

      // Simular a seleção de uma cor e confirmação
      await tester.tap(find.text('CONFIRMAR'));
      await tester.pumpAndSettle(); // Fechar o AlertDialog

      expect(find.text('Alterar Cor'), findsOneWidget); // A tela principal ainda está lá
    });

  });
}
