# Como Criar Novos Hábitos no HabitAI usando MCP

Este guia explica como criar novos hábitos no aplicativo HabitAI usando os Model Context Protocols (MCPs).

## 📱 Estrutura do App

O HabitAI possui duas telas principais para criação de hábitos:

1. **AddHabitSimpleScreen** (`/lib/screens/habits/add_habit_simple_screen.dart`)
   - Interface simplificada
   - Apenas campos básicos: nome, categoria, frequência
   - Ideal para criação rápida de hábitos

2. **UpsertHabitScreen** (`/lib/screens/habit/upsert_habit_screen.dart`)
   - Interface completa
   - Todos os recursos: tipos de rastreamento, lembretes, metas, etc.
   - Ideal para hábitos mais detalhados

## 🚀 Navegação para Criar Hábitos

### Via Interface do App

Na tela principal de hábitos (`HabitsScreen`), existem dois botões flutuantes:

```dart
// Botão principal (canto inferior direito)
FloatingActionButton(
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const AddHabitSimpleScreen()),
  ),
  child: const Icon(Icons.add),
)

// Botão de sugestões (acima do botão principal)
FloatingActionButton(
  onPressed: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const HabitSelectionScreen()),
  ),
  child: const Icon(Icons.lightbulb_outline),
)
```

### Via Rotas Nomeadas

```dart
// Navegar para a tela completa de criação
Navigator.pushNamed(context, '/add-habit');

// Ou com argumentos para edição
Navigator.pushNamed(
  context,
  UpsertHabitScreen.routeName,
  arguments: habitToEdit, // Objeto Habit existente
);
```

## 📝 Estrutura do Modelo Habit

O modelo `Habit` possui os seguintes campos principais:

```dart
class Habit {
  // Identificação
  final String id;
  final String title;
  final String? description;
  final String? userId;
  
  // Categoria e Visual
  final String category;
  final IconData icon;
  final Color color;
  
  // Frequência
  final HabitFrequency frequency;
  final List<int>? daysOfWeek;      // Para frequência semanal
  final List<int>? daysOfMonth;     // Para frequência mensal
  
  // Tipo de Rastreamento
  final HabitTrackingType trackingType;
  final double? targetQuantity;     // Para tipo "quantia"
  final String? quantityUnit;       // Unidade (copos, km, etc.)
  final Duration? targetTime;       // Para tipo "cronômetro"
  final List<HabitSubtask>? subtasks; // Para tipo "lista"
  
  // Datas e Lembretes
  final DateTime startDate;
  final DateTime? targetDate;
  final TimeOfDay? reminderTime;
  final bool notificationsEnabled;
  
  // Prioridade
  final String priority; // 'Baixa', 'Normal', 'Alta'
  
  // Progresso
  int streak;
  int longestStreak;
  int totalCompletions;
  final Map<DateTime, bool> completionHistory;
  final Map<DateTime, HabitDailyProgress> dailyProgress;
}
```

## 🛠️ Criando Hábitos Programaticamente

### Exemplo 1: Hábito Simples (Sim/Não)

```dart
final habitService = context.read<HabitService>();
final userId = FirebaseAuth.instance.currentUser!.uid;

final habit = Habit(
  id: const Uuid().v4(),
  title: 'Tomar vitaminas',
  category: 'Saúde',
  icon: Icons.medication,
  color: Colors.red,
  frequency: HabitFrequency.daily,
  trackingType: HabitTrackingType.simOuNao,
  startDate: DateTime.now(),
  reminderTime: const TimeOfDay(hour: 8, minute: 0),
  notificationsEnabled: true,
  priority: 'Normal',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  userId: userId,
  completionHistory: {},
  dailyProgress: {},
  streak: 0,
  longestStreak: 0,
  totalCompletions: 0,
);

await habitService.addHabit(habit);
```

### Exemplo 2: Hábito com Quantidade

```dart
final habit = Habit(
  id: const Uuid().v4(),
  title: 'Beber água',
  description: 'Manter-se hidratado ao longo do dia',
  category: 'Saúde',
  icon: Icons.water_drop,
  color: Colors.blue,
  frequency: HabitFrequency.daily,
  trackingType: HabitTrackingType.quantia,
  targetQuantity: 8,
  quantityUnit: 'copos',
  // ... outros campos
);
```

### Exemplo 3: Hábito com Cronômetro

```dart
final habit = Habit(
  id: const Uuid().v4(),
  title: 'Estudar programação',
  category: 'Estudos',
  icon: Icons.code,
  color: Colors.purple,
  frequency: HabitFrequency.daily,
  trackingType: HabitTrackingType.cronometro,
  targetTime: const Duration(hours: 2),
  // ... outros campos
);
```

### Exemplo 4: Hábito com Lista de Tarefas

```dart
final subtasks = [
  HabitSubtask(id: uuid.v4(), title: 'Fazer alongamento'),
  HabitSubtask(id: uuid.v4(), title: 'Cardio 20 min'),
  HabitSubtask(id: uuid.v4(), title: 'Musculação'),
  HabitSubtask(id: uuid.v4(), title: 'Relaxamento'),
];

final habit = Habit(
  id: const Uuid().v4(),
  title: 'Rotina de exercícios',
  category: 'Fitness',
  icon: Icons.fitness_center,
  color: Colors.orange,
  frequency: HabitFrequency.weekly,
  daysOfWeek: [1, 3, 5], // Segunda, Quarta, Sexta
  trackingType: HabitTrackingType.listaAtividades,
  subtasks: subtasks,
  // ... outros campos
);
```

## 🔧 Usando HabitService

O `HabitService` fornece métodos para gerenciar hábitos:

```dart
// Adicionar novo hábito
await habitService.addHabit(habit);

// Buscar hábito por ID
final habit = await habitService.getHabitById(habitId);

// Atualizar hábito existente
await habitService.updateHabit(updatedHabit);

// Deletar hábito
await habitService.deleteHabit(habitId);

// Marcar conclusão
await habitService.markHabitCompletion(habitId, DateTime.now(), true);

// Stream de hábitos
habitService.getHabits().listen((habits) {
  // Lista atualizada de hábitos
});
```

## 📱 Integrando com UI

### Botão Customizado para Criar Hábito

```dart
ElevatedButton.icon(
  icon: const Icon(Icons.add),
  label: const Text('Novo Hábito'),
  onPressed: () async {
    // Navegar para tela de criação
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UpsertHabitScreen(),
      ),
    );
    
    if (result == true) {
      // Hábito foi criado com sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hábito criado!')),
      );
    }
  },
)
```

### Criar Hábito com Valores Pré-definidos

```dart
// Criar um hábito parcialmente preenchido
final prefilledHabit = Habit(
  id: '',
  title: 'Exercício matinal',
  category: 'Fitness',
  icon: Icons.fitness_center,
  color: Colors.orange,
  frequency: HabitFrequency.daily,
  reminderTime: const TimeOfDay(hour: 6, minute: 30),
  // ... deixar outros campos para o usuário completar
);

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => UpsertHabitScreen(
      habitToEdit: prefilledHabit,
    ),
  ),
);
```

## 🎯 Frequências Disponíveis

```dart
enum HabitFrequency {
  daily,                  // Todos os dias
  weekly,                 // Dias específicos da semana
  monthly,                // Dias específicos do mês
  specificDaysOfYear,     // Datas específicas do ano
  someTimesPerPeriod,     // X vezes por período
  repeat,                 // Repetir a cada X dias
  custom,                 // Personalizado
}
```

## 📊 Tipos de Rastreamento

```dart
enum HabitTrackingType {
  simOuNao,        // Marcar como feito ou não
  quantia,         // Rastrear quantidade (ex: 8 copos)
  cronometro,      // Rastrear tempo (ex: 30 minutos)
  listaAtividades, // Lista de subtarefas
}
```

## 🔔 Notificações

Para hábitos com lembretes:

```dart
final habit = Habit(
  // ... outros campos
  reminderTime: const TimeOfDay(hour: 8, minute: 0),
  notificationsEnabled: true,
);

// O HabitService automaticamente agenda as notificações
await habitService.addHabit(habit);
```

## 📱 Exemplo Completo: Widget de Criação Rápida

```dart
class QuickHabitCreator extends StatelessWidget {
  final List<Map<String, dynamic>> quickHabits = [
    {
      'title': 'Beber água',
      'icon': Icons.water_drop,
      'color': Colors.blue,
      'category': 'Saúde',
    },
    {
      'title': 'Meditar',
      'icon': Icons.self_improvement,
      'color': Colors.purple,
      'category': 'Saúde',
    },
    {
      'title': 'Ler 30 min',
      'icon': Icons.book,
      'color': Colors.green,
      'category': 'Estudos',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: quickHabits.map((habitData) {
        return ListTile(
          leading: Icon(habitData['icon'], color: habitData['color']),
          title: Text(habitData['title']),
          trailing: IconButton(
            icon: const Icon(Icons.add_circle),
            onPressed: () async {
              final habitService = context.read<HabitService>();
              final userId = FirebaseAuth.instance.currentUser!.uid;
              
              final habit = Habit(
                id: const Uuid().v4(),
                title: habitData['title'],
                category: habitData['category'],
                icon: habitData['icon'],
                color: habitData['color'],
                frequency: HabitFrequency.daily,
                trackingType: HabitTrackingType.simOuNao,
                startDate: DateTime.now(),
                priority: 'Normal',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                userId: userId,
                completionHistory: {},
                dailyProgress: {},
                streak: 0,
                longestStreak: 0,
                totalCompletions: 0,
              );
              
              await habitService.addHabit(habit);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${habit.title} adicionado!'),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }
}
```

## 🚀 Próximos Passos

1. **Explorar as telas existentes**: Navegue pelo app para entender o fluxo completo
2. **Personalizar categorias**: Use o `CategoryService` para criar categorias customizadas
3. **Implementar sugestões de IA**: Integrar com o serviço de IA para sugerir hábitos
4. **Adicionar templates**: Criar hábitos pré-configurados para diferentes objetivos

## 📚 Arquivos Importantes

- `/lib/models/habit.dart` - Modelo de dados
- `/lib/services/habit_service.dart` - Lógica de negócios
- `/lib/screens/habit/upsert_habit_screen.dart` - UI completa
- `/lib/screens/habits/add_habit_simple_screen.dart` - UI simplificada
- `/lib/widgets/habit_card_complete.dart` - Widget de exibição

