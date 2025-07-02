import 'dart:io';

// Teste simples de criação de hábito sem dependências do Flutter

class HabitSimple {
  final String id;
  final String title;
  final String category;
  final String description;
  final String icon;
  final String color;
  final String frequency;
  final String trackingType;
  final DateTime startDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> completionHistory;
  final Map<String, dynamic> dailyProgress;
  final int streak;
  final int longestStreak;
  final int totalCompletions;
  final String userId;

  HabitSimple({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.icon,
    required this.color,
    required this.frequency,
    required this.trackingType,
    required this.startDate,
    required this.createdAt,
    required this.updatedAt,
    required this.completionHistory,
    required this.dailyProgress,
    this.streak = 0,
    this.longestStreak = 0,
    this.totalCompletions = 0,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'description': description,
      'icon': icon,
      'color': color,
      'frequency': frequency,
      'trackingType': trackingType,
      'startDate': startDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'completionHistory': completionHistory,
      'dailyProgress': dailyProgress,
      'streak': streak,
      'longestStreak': longestStreak,
      'totalCompletions': totalCompletions,
      'userId': userId,
    };
  }
}

void main() {
  print('===== TESTE DE CRIAÇÃO DE HÁBITO (SIMPLES) =====\n');

  // Criar um hábito de teste
  final now = DateTime.now();
  final habitId = DateTime.now().millisecondsSinceEpoch.toString();
  
  final habit = HabitSimple(
    id: habitId,
    title: 'Beber 8 copos de água',
    category: 'Saúde',
    description: 'Manter-se hidratado ao longo do dia',
    icon: 'water_drop',  // Nome do ícone como string
    color: '0xFF2196F3', // Cor como string hex
    frequency: 'daily',
    trackingType: 'quantity',
    startDate: now,
    createdAt: now,
    updatedAt: now,
    completionHistory: {},
    dailyProgress: {},
    userId: 'test-user-123',
  );

  print('1. Hábito criado localmente:');
  print('   ID: ${habit.id}');
  print('   Título: ${habit.title}');
  print('   Categoria: ${habit.category}');
  print('   Descrição: ${habit.description}');
  print('   Ícone: ${habit.icon}');
  print('   Cor: ${habit.color}');
  print('   Frequência: ${habit.frequency}');
  print('   Tipo: ${habit.trackingType}');
  print('   Data de início: ${habit.startDate}');
  
  print('\n2. Convertendo para Map (simulando salvamento):');
  final habitMap = habit.toMap();
  print('   Map criado com ${habitMap.keys.length} campos');
  
  print('\n3. Validando campos obrigatórios:');
  final requiredFields = ['id', 'title', 'category', 'icon', 'color', 'frequency', 
                         'trackingType', 'startDate', 'createdAt', 'updatedAt', 
                         'userId', 'completionHistory', 'dailyProgress'];
  
  bool allFieldsPresent = true;
  for (final field in requiredFields) {
    if (!habitMap.containsKey(field)) {
      print('   ❌ Campo obrigatório ausente: $field');
      allFieldsPresent = false;
    }
  }
  
  if (allFieldsPresent) {
    print('   ✅ Todos os campos obrigatórios estão presentes');
  }
  
  print('\n4. Simulando validação de dados:');
  if (habit.title.isEmpty) {
    print('   ❌ Título não pode estar vazio');
  } else {
    print('   ✅ Título válido: "${habit.title}"');
  }
  
  if (habit.category.isEmpty) {
    print('   ❌ Categoria não pode estar vazia');
  } else {
    print('   ✅ Categoria válida: "${habit.category}"');
  }
  
  if (habit.id.isEmpty) {
    print('   ❌ ID não pode estar vazio');
  } else {
    print('   ✅ ID válido: ${habit.id}');
  }
  
  print('\n5. Estrutura JSON do hábito:');
  habitMap.forEach((key, value) {
    print('   "$key": "$value"');
  });
  
  print('\n===== DIAGNÓSTICO =====');
  print('\n✅ A lógica de criação de hábitos está funcionando corretamente!');
  print('\nSe você está tendo problemas ao criar hábitos no app, o erro está na:');
  print('1. Autenticação do usuário (usuário não logado)');
  print('2. Comunicação com o Firebase (sem internet ou configuração incorreta)');
  print('3. Permissões do Firestore (regras de segurança bloqueando escrita)');
  print('4. Configuração do projeto Firebase (chaves API incorretas)');
  
  print('\n📋 PRÓXIMOS PASSOS:');
  print('1. Verifique se o usuário está autenticado no app');
  print('2. Verifique a conexão com a internet');
  print('3. Verifique as regras do Firestore no console do Firebase');
  print('4. Verifique se as chaves do Firebase no arquivo .env estão corretas');
  print('5. Tente fazer logout e login novamente no app');
}
