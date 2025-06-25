# Sincronização com Jules - Estado do Projeto

## Branch Base
- **Branch**: `feature/core-improvements`
- **Último commit**: `26cf7b4 Feat: Aprimora sistema de notificações e adiciona snooze`

## Alterações Locais Necessárias

### 1. pubspec.yaml
- **Problema**: Conflitos de merge e versão do intl incompatível
- **Solução**: 
  - Remover marcadores de conflito (<<<<<<, ======, >>>>>>)
  - Atualizar `intl: ^0.18.1` para `intl: ^0.20.2`
  - Remover referências a assets inexistentes

### 2. Arquivos com Conflitos de Merge
- `lib/services/category_service.dart`
- `lib/services/achievement_service.dart`
- `lib/widgets/habit_card.dart`
- `lib/widgets/task_card.dart`

**Ação**: Restaurar do git ou resolver conflitos manualmente

### 3. Erro do Android Gradle
- **Problema**: `flutter_native_timezone` precisa de namespace
- **Contexto**: Android Gradle Plugin atualizado requer namespace

## Como Rodar o Projeto

### Opção 1: Web (Recomendado para testes rápidos)
```bash
flutter clean
flutter pub get
flutter run -d web-server --web-port=5004
```

### Opção 2: Android
```bash
flutter clean
cd android && ./gradlew clean && cd ..
flutter pub get
flutter run
```

## Para Jules Enviar Atualizações

1. Fazer commit das alterações no branch dele
2. Push para o GitHub
3. Nos avisar o commit hash
4. Nós fazemos:
   ```bash
   git fetch origin
   git cherry-pick <commit-hash>
   # ou
   git pull origin feature/core-improvements
   ```

## Para Enviar Nossas Correções para Jules

1. Criamos um patch:
   ```bash
   git diff > fixes.patch
   ```
2. Jules aplica:
   ```bash
   git apply fixes.patch
   ```