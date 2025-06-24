import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/screens/habit/widgets/habit_statistics_tab.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart'; // Para verificar o BarChart
import 'package:intl/date_symbol_data_local.dart';


// Mock Habit para testes
Habit createMockHabit({
  String id = 'test_habit',
  String title = 'Test Habit',
  String category = 'Saúde',
  IconData icon = Icons.fitness_center,
  Color color = Colors.blue,
  HabitFrequency frequency = HabitFrequency.daily,
  List<int>? daysOfWeek,
  DateTime? startDate,
  Map<DateTime, bool>? completionHistory,
  int streak = 0,
  int longestStreak = 0,
  int totalCompletions = 0,
}) {
  final now = DateTime.now();
  return Habit(
    id: id,
    title: title,
    category: category,
    icon: icon,
    color: color,
    frequency: frequency,
    daysOfWeek: daysOfWeek,
    startDate: startDate ?? now.subtract(const Duration(days: 30)),
    createdAt: now.subtract(const Duration(days: 30)),
    updatedAt: now,
    completionHistory: completionHistory ?? {},
    dailyProgress: {}, // Adicionado para satisfazer o construtor
    streak: streak,
    longestStreak: longestStreak,
    totalCompletions: totalCompletions,
  );
}

void main() {
  // Certificar que a formatação de data para pt_BR está disponível para os testes
  setUpAll(() async {
    await initializeDateFormatting('pt_BR', null);
  });

  testWidgets('HabitStatisticsTab exibe informações básicas corretamente', (WidgetTester tester) async {
    final habit = createMockHabit(
      streak: 5,
      longestStreak: 10,
      totalCompletions: 20,
      completionHistory: {
        DateTime(2023, 1, 1): true,
        DateTime(2023, 1, 2): true,
        DateTime(2023, 1, 3): false,
      }
    );

    // Simular getCompletionRate para retornar um valor fixo para o teste de UI
    // Isso é um pouco complicado porque getCompletionRate é um método do modelo.
    // Idealmente, o modelo seria mais testável ou teríamos uma forma de mockar isso.
    // Por agora, vamos assumir que o cálculo está correto e focar na UI.
    // Para o teste do CircularProgressIndicator, podemos criar um hábito que resulte em 50%.
    // Ex: 1 dia devido, 1 dia completo no histórico relevante.
    final today = DateTime.now();
    final startDateForRate = DateTime(today.year, today.month, today.day).subtract(const Duration(days:1));
    final habitForRateTest = createMockHabit(
        startDate: startDateForRate,
        completionHistory: {
            startDateForRate: true, // Concluído no dia que era devido
            DateTime(today.year, today.month, today.day): false // Não concluído hoje (se devido)
        },
        frequency: HabitFrequency.daily
    );


    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: HabitStatisticsTab(habit: habitForRateTest)),
    ));
    await tester.pumpAndSettle(); // Para FutureBuilder e animações do gráfico

    // Verificar Pontuação do Hábito (o valor exato depende do getCompletionRate)
    expect(find.text('Pontuação de hábito'), findsOneWidget);
    // O valor do CircularProgressIndicator e o texto dentro dele são baseados em getCompletionRate.
    // Para o habitForRateTest, se apenas 1 dia foi devido e completado, a taxa deve ser 100%.
    // Se 2 dias foram devidos e 1 completado, 50%.
    // O `getCompletionRate` agora considera `isDueToday`.
    // Se startDateForRate foi ontem e era devido, e hoje é devido e não completo:
    // dueDaysCount = 2, completedOnDueDays = 1. Taxa = 0.5. Pontuação = 50.
    expect(find.text('50'), findsOneWidget); // Assumindo que getCompletionRate retorna 0.5 para este cenário

    // Verificar Séries
    final specificStreakHabit = createMockHabit(streak: 5, longestStreak: 10);
     await tester.pumpWidget(MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: HabitStatisticsTab(habit: specificStreakHabit)),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Série'), findsOneWidget);
    expect(find.text('5 DIAS'), findsOneWidget); // Streak Atual
    expect(find.text('10 DIAS'), findsOneWidget); // Melhor Série

    // Verificar Vezes Concluída
     final completionCountHabit = createMockHabit(
        totalCompletions: 25,
        completionHistory: {
            // Para _getCompletionsThisWeek, _getCompletionsThisMonth, _getCompletionsThisYear
            // Vamos adicionar algumas datas relevantes
            DateTime(now.year, now.month, now.day): true, // Hoje
            now.subtract(const Duration(days: 1)): true, // Ontem
            now.subtract(const Duration(days: 8)): true, // Semana passada
            DateTime(now.year, now.month, 1): true, // Início do mês
            DateTime(now.year, 1, 1): true, // Início do ano
        },
        frequency: HabitFrequency.daily // Para simplificar o isDueToday
    );
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: HabitStatisticsTab(habit: completionCountHabit)),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Vezes concluída'), findsOneWidget);
    expect(find.widgetWithText(Row, 'Esta semana'), findsOneWidget);
    expect(find.widgetWithText(Row, 'Este mês'), findsOneWidget);
    expect(find.widgetWithText(Row, 'Este ano'), findsOneWidget);
    expect(find.widgetWithText(Row, 'Total'), findsOneWidget);
    // Os valores exatos dependerão da lógica de _getCompletions... e do dia atual.
    // Mas o importante é que os widgets estejam lá.
    // Para o total:
    final totalRow = find.ancestor(of: find.text('Total'), matching: find.byType(Row));
    expect(find.descendant(of: totalRow, matching: find.text('25')), findsOneWidget);


    // Verificar Desafios de Série
    expect(find.text('Desafios de Sequência'), findsOneWidget); // Título da seção
    expect(find.text('7 dias'), findsOneWidget); // Um dos desafios
  });

  testWidgets('HabitStatisticsTab exibe gráfico de barras', (WidgetTester tester) async {
    final now = DateTime.now();
    final habit = createMockHabit(
      completionHistory: {
        // Mês atual
        DateTime(now.year, now.month, 1): true,
        DateTime(now.year, now.month, 2): true,
        // Mês anterior
        DateTime(now.year, now.month -1, 15): true,
      },
      frequency: HabitFrequency.daily,
      startDate: DateTime(now.year, now.month - 2, 1) // Garante que o hábito já começou
    );

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: HabitStatisticsTab(habit: habit)),
    ));
    await tester.pumpAndSettle(const Duration(seconds: 1)); // Dar tempo para o gráfico carregar

    expect(find.text('Progresso ao Longo do Tempo'), findsOneWidget);
    expect(find.byType(BarChart), findsOneWidget);

    // Verifica se os botões de período existem
    expect(find.text('Semana'), findsOneWidget);
    expect(find.text('Mês'), findsOneWidget);
    expect(find.text('Ano'), findsOneWidget);

    // Verifica se o título do eixo X para 'Mês' (padrão) aparece
    // A lógica exata dos títulos do eixo X pode ser complexa de testar sem IDs específicos
    // ou chaves, mas podemos procurar por um padrão esperado.
    // Ex: para o período 'Mês', esperamos algo como 'JAN', 'FEV', etc.
    // O _bottomTitlesCache[x] = DateFormat('MMM', 'pt_BR').format(DateFormat('yyyy-MM', 'pt_BR').parse(monthKey)).toUpperCase();
    // Vamos procurar por um mês que sabemos que terá dados
    String currentMonthShort = DateFormat('MMM', 'pt_BR').format(DateTime(now.year, now.month)).toUpperCase();
    expect(find.text(currentMonthShort), findsWidgets); // Pode encontrar múltiplos se o nome for curto
  });

  testWidgets('HabitStatisticsTab alterna períodos do gráfico', (WidgetTester tester) async {
    final now = DateTime.now();
    final habit = createMockHabit(
      completionHistory: {
        DateTime(now.year, now.month, 1): true,
        DateTime(now.year, now.month, 2): true,
        now.subtract(const Duration(days: 8)): true, // Semana passada
      },
      frequency: HabitFrequency.daily,
      startDate: DateTime(now.year, now.month - 2, 1)
    );

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: HabitStatisticsTab(habit: habit)),
    ));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Padrão é Mês
    expect(find.text(DateFormat('MMM', 'pt_BR').format(now).toUpperCase()), findsWidgets);

    // Mudar para Semana
    await tester.tap(find.text('Semana'));
    await tester.pumpAndSettle(const Duration(seconds: 1)); // Espera o gráfico atualizar
    expect(find.textContaining(RegExp(r'S\d{1,2}')), findsWidgets); // Procura por SXX

    // Mudar para Ano
    await tester.tap(find.text('Ano'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('JAN'), findsWidgets); // Procura por JAN (ou outro mês)

  });

   testWidgets('HabitStatisticsTab lida com histórico de conclusão vazio para gráficos', (WidgetTester tester) async {
    final habit = createMockHabit(completionHistory: {});

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: HabitStatisticsTab(habit: habit)),
    ));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('Progresso ao Longo do Tempo'), findsOneWidget);
    expect(find.byType(BarChart), findsOneWidget); // O BarChart ainda é construído
    expect(find.text('Sem dados de conclusão para este período.'), findsOneWidget);
  });

}) // End of group
;
