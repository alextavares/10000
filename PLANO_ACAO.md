# Plano de Ação - HabitAI

## 🎯 Prioridade 1: Fazer o aplicativo funcionar

### 1. Testar execução básica
```bash
# Limpar cache e dependências
cd C:\codigos\HabitAiclaudedesktop\HabitAI
flutter clean
flutter pub get

# Tentar executar novamente
flutter run -d emulator-5554
```

### 2. Verificar logs de erro
- Usar `flutter logs` para ver erros em tempo real
- Verificar se há problemas de inicialização do Firebase
- Confirmar se as permissões estão corretas

## 🎯 Prioridade 2: Corrigir testes

### 1. Gerar mocks faltantes
```bash
# Instalar build_runner e mockito se não estiver instalado
flutter pub add --dev build_runner
flutter pub add --dev mockito

# Gerar mocks
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Arquivos que precisam de mocks:
- `test/screens/main_navigation_screen_test.mocks.dart`
- Atualizar mocks existentes com novos métodos

### 3. Métodos que precisam ser implementados nos mocks:
- `HabitService.getHabitsSync()`
- `TaskService.getTasksSync()`
- `RecurringTaskService.getRecurringTasksSync()`

## 🎯 Prioridade 3: Funcionalidades pendentes

### 1. Sistema de Subitens (já tem placeholder no UI)
- Criar modelo `Subtask`
- Adicionar campo `subtasks` no modelo `Task`
- Criar tela de gerenciamento de subitens
- Atualizar `TaskCard` para mostrar contador de subitens

### 2. Sistema de Notificações
- Configurar `flutter_local_notifications`
- Implementar lógica de lembretes
- Adicionar permissões no AndroidManifest.xml
- Testar notificações em horários específicos

### 3. Funcionalidade Premium
- Definir features premium
- Implementar sistema de assinatura
- Adicionar validação de acesso

## 📋 Checklist de Verificação

### Antes de continuar desenvolvendo:
- [ ] Aplicativo executa sem erros
- [ ] Login/Registro funciona
- [ ] É possível adicionar uma tarefa
- [ ] É possível marcar tarefa como concluída
- [ ] Dados são salvos no Firebase
- [ ] Testes básicos passam

### Funcionalidades core que devem funcionar:
- [ ] Criar/Editar/Deletar tarefas
- [ ] Criar/Editar/Deletar tarefas recorrentes
- [ ] Criar/Editar/Deletar hábitos
- [ ] Visualizar estatísticas
- [ ] Filtrar e buscar itens
- [ ] Navegação entre telas

## 🛠️ Configurações recomendadas

### VS Code extensions:
- Flutter
- Dart
- Firebase Explorer
- GitLens

### Configuração do Firebase:
1. Verificar se todas as APIs estão habilitadas no console
2. Confirmar regras de segurança do Firestore
3. Testar autenticação com email/senha

## 📚 Recursos úteis:
- [Flutter Firebase Setup](https://firebase.flutter.dev/docs/overview)
- [Flutter Testing](https://flutter.dev/docs/testing)
- [Provider Package](https://pub.dev/packages/provider)
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
