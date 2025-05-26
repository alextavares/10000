import 'package:flutter/material.dart';
import 'package:myapp/models/habit.dart';
import 'package:myapp/services/habit_service.dart';

void main() {
  testMonthlyHabitCreation();
}

void testMonthlyHabitCreation() async {
  print('=== TESTE DE CRIAÇÃO DE HÁBITO MENSAL ===');
  
  final habitService = HabitService();
  
  // Teste 1: Criar hábito para dias específicos do mês (ex: dias 5, 15, 25)
  print('\n1. Criando hábito mensal para dias 5, 15, 25...');
  
  try {
    await habitService.addHabit(
      title: 'Hábito Teste Mensal',
      categoryName: 'Teste',
      categoryIcon: Icons.star,
      categoryColor: Colors.blue,
      frequency: HabitFrequency.monthly,
      trackingType: HabitTrackingType.simOuNao,
      startDate: DateTime.now(),
      daysOfMonth: [5, 15, 25], // Dias específicos do mês
      description: 'Hábito de teste para dias específicos do mês',
    );
    print('✅ Hábito criado com sucesso!');
  } catch (e) {
    print('❌ Erro ao criar hábito: $e');
    return;
  }
  
  // Teste 2: Verificar se o hábito foi salvo corretamente
  print('\n2. Verificando hábitos salvos...');
  
  final habits = await habitService.getHabits();
  print('Total de hábitos: ${habits.length}');
  
  if (habits.isNotEmpty) {
    final monthlyHabit = habits.first;
    print('Primeiro hábito:');
    print('  - Título: ${monthlyHabit.title}');
    print('  - Frequência: ${monthlyHabit.frequency}');
    print('  - Dias do mês: ${monthlyHabit.daysOfMonth}');
    print('  - Data de criação: ${monthlyHabit.createdAt}');
    print('  - ID: ${monthlyHabit.id}');
    
    // Teste 3: Verificar se o hábito aparece nos dias corretos
    print('\n3. Testando exibição nos dias corretos...');
    
    // Testa para o dia 5 do mês atual
    DateTime testDate5 = DateTime(DateTime.now().year, DateTime.now().month, 5);
    bool shouldShow5 = monthlyHabit.isDueToday(testDate5);
    print('Dia 5: deve aparecer = true, aparece = $shouldShow5');
    
    // Testa para o dia 15 do mês atual
    DateTime testDate15 = DateTime(DateTime.now().year, DateTime.now().month, 15);
    bool shouldShow15 = monthlyHabit.isDueToday(testDate15);
    print('Dia 15: deve aparecer = true, aparece = $shouldShow15');
    
    // Testa para o dia 25 do mês atual
    DateTime testDate25 = DateTime(DateTime.now().year, DateTime.now().month, 25);
    bool shouldShow25 = monthlyHabit.isDueToday(testDate25);
    print('Dia 25: deve aparecer = true, aparece = $shouldShow25');
    
    // Testa para um dia que não deve aparecer (ex: dia 10)
    DateTime testDate10 = DateTime(DateTime.now().year, DateTime.now().month, 10);
    bool shouldShow10 = monthlyHabit.isDueToday(testDate10);
    print('Dia 10: deve aparecer = false, aparece = $shouldShow10');
    
    // Teste 4: Verificar serialização/deserialização
    print('\n4. Testando serialização/deserialização...');
    
    final habitMap = monthlyHabit.toMap();
    print('Dados serializados:');
    print('  - daysOfMonth no Map: ${habitMap['daysOfMonth']}');
    print('  - frequency no Map: ${habitMap['frequency']}');
    
    final habitFromMap = Habit.fromMap(habitMap);
    print('Dados após deserialização:');
    print('  - daysOfMonth: ${habitFromMap.daysOfMonth}');
    print('  - frequency: ${habitFromMap.frequency}');
    
    // Verifica se são iguais
    bool isEqual = listEquals(monthlyHabit.daysOfMonth, habitFromMap.daysOfMonth);
    print('daysOfMonth mantido após serialização: $isEqual');
    
  } else {
    print('❌ Nenhum hábito encontrado!');
  }
  
  print('\n=== FIM DO TESTE ===');
}

bool listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  for (int index = 0; index < a.length; index += 1) {
    if (a[index] != b[index]) return false;
  }
  return true;
}
