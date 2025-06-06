# Testes do HabitAI

Este documento descreve a estrutura de testes do aplicativo HabitAI e como executá-los.

## Estrutura de Testes

### 1. Testes Unitários (`test/services/`)
- **habit_service_test.dart**: Testa as operações do HabitService
  - Criação, edição e remoção de hábitos
  - Marcação de hábitos como completos
  - Cálculo de streaks
  - Filtragem por frequência
  
- **task_service_test.dart**: Testa as operações do TaskService
  - CRUD de tarefas
  - Ordenação por prioridade
  - Gerenciamento de subtarefas
  - Filtragem por categoria e tarefas vencidas
  
- **auth_service_test.dart**: Testa autenticação
  - Login com email/senha
  - Login com Google
  - Criação de conta
  - Reset de senha
  - Validações

### 2. Testes de Widget (`test/screens/`)
- **habits_screen_test.dart**: Testa a interface de hábitos
  - Exibição de lista vazia
  - Renderização de hábitos
  - Interação com checkboxes
  - Navegação
  
- **tasks_screen_test.dart**: Testa a interface de tarefas
  - Exibição de tarefas
  - Indicadores de prioridade
  - Datas de vencimento
  - Swipe para deletar

### 3. Testes de Integração (`integration_test/`)
- **app_test.dart**: Testa fluxos completos
  - Login e navegação
  - Criação e conclusão de hábitos
  - Gerenciamento de tarefas
  - Sincronização de dados

## Como Executar os Testes

### Pré-requisitos
```bash
# Instalar dependências
flutter pub get

# Instalar dependências de teste
flutter pub add --dev flutter_test
flutter pub add --dev mockito
flutter pub add --dev build_runner
flutter pub add --dev fake_cloud_firestore
flutter pub add --dev integration_test
```

### Executar Todos os Testes
```bash
# Windows
run_tests.bat

# macOS/Linux
./run_tests.sh
```

### Executar Testes Específicos

#### Testes Unitários
```bash
# Todos os testes de serviços
flutter test test/services/

# Teste específico
flutter test test/services/habit_service_test.dart
```

#### Testes de Widget
```bash
# Todos os testes de telas
flutter test test/screens/

# Teste específico
flutter test test/screens/habits/habits_screen_test.dart
```

#### Testes de Integração
```bash
# Executar testes de integração
flutter test integration_test/app_test.dart
```

### Gerar Relatório de Cobertura
```bash
# Gerar dados de cobertura
flutter test --coverage

# Gerar relatório HTML (requer lcov)
genhtml coverage/lcov.info -o coverage/html

# Visualizar relatório
start coverage/html/index.html  # Windows
open coverage/html/index.html   # macOS
xdg-open coverage/html/index.html  # Linux
```

## Melhores Práticas

### 1. Estrutura dos Testes
- Use `group()` para organizar testes relacionados
- Use `setUp()` e `tearDown()` para configuração
- Mantenha testes independentes uns dos outros

### 2. Nomenclatura
- Use descrições claras em português
- Comece com "Deve" para descrever o comportamento esperado
- Seja específico sobre o que está sendo testado

### 3. Mocks
- Use Mockito para criar mocks de dependências
- Configure comportamentos padrão no `setUp()`
- Verifique interações importantes com `verify()`

### 4. Assertions
- Use `expect()` com matchers apropriados
- Teste casos de sucesso e falha
- Verifique estados intermediários quando relevante

## Troubleshooting

### Erro: "Cannot find mocks"
Execute o build_runner para gerar os mocks:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Erro: "Widget not found"
- Verifique se está usando `pumpAndSettle()` após animações
- Use `Key` para identificar widgets específicos
- Adicione `await tester.pumpAndSettle()` após navegações

### Testes lentos
- Use `FakeFirebaseFirestore` em vez de emuladores
- Minimize delays em testes
- Execute testes em paralelo quando possível

## Cobertura de Código

### Meta de Cobertura
- Mínimo: 70% de cobertura geral
- Ideal: 80%+ para código crítico
- Services: 90%+ de cobertura
- Widgets: 70%+ de cobertura

### Áreas Prioritárias
1. Lógica de negócios (services)
2. Validações e cálculos
3. Manipulação de estado
4. Interações do usuário críticas

## CI/CD

Para integração contínua, adicione ao seu workflow:

```yaml
# .github/workflows/test.yml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
      - run: flutter test --coverage
```
