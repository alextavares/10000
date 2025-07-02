# Instruções para Jules - Branch local-fixes-20250625-090004

## Como acessar o branch com as correções

```bash
# Buscar o branch do repositório
git fetch origin

# Mudar para o branch com as correções
git checkout local-fixes-20250625-090004
```

## O que já foi corrigido neste branch

### ✅ Correções Aplicadas:
1. **pubspec.yaml**
   - Atualizado `intl: ^0.18.1` → `intl: ^0.20.2`
   - Removidas referências a assets inexistentes (fontes Roboto e .env)

2. **Arquivos gerados automaticamente**
   - pubspec.lock atualizado
   - Arquivos de plataforma (ios, linux, windows) regenerados

### ❌ Ainda precisa resolver:

Estes 4 arquivos ainda têm conflitos de merge (marcadores <<<<<<, ======, >>>>>>):
- `lib/services/category_service.dart`
- `lib/services/achievement_service.dart`
- `lib/widgets/habit_card.dart`
- `lib/widgets/task_card.dart`

## Como resolver os conflitos

### Opção 1: Usar o VS Code ou Android Studio
1. Abrir cada arquivo com conflito
2. Procurar por `<<<<<<<`
3. Escolher qual versão manter ou combinar ambas
4. Remover os marcadores de conflito

### Opção 2: Aceitar uma versão específica
```bash
# Para aceitar a versão do branch anterior (descartar mudanças com conflito)
git checkout origin/feature/core-improvements -- lib/services/category_service.dart
git checkout origin/feature/core-improvements -- lib/services/achievement_service.dart
git checkout origin/feature/core-improvements -- lib/widgets/habit_card.dart
git checkout origin/feature/core-improvements -- lib/widgets/task_card.dart
```

## Como testar após resolver conflitos

### 1. Instalar dependências
```bash
flutter clean
flutter pub get
```

### 2. Rodar o app

**Opção Web (mais fácil):**
```bash
flutter run -d web-server --web-port=5004
```

**Opção Android:**
```bash
flutter run
```

## Próximos passos

1. **Você (Jules):**
   - Resolver os 4 conflitos
   - Fazer commit das correções
   - Push para o branch
   - Nos avisar quando estiver pronto

2. **Nós:**
   - Testaremos suas correções
   - Faremos merge se tudo estiver OK

## Estrutura do commit no branch

```
commit 9fa1953 (HEAD -> local-fixes-20250625-090004)
Author: Claude Code
Date:   Tue Jun 25 09:00:04 2024

    fix: Correções locais para compatibilidade Flutter e resolução de conflitos
    
    - Atualizado intl de ^0.18.1 para ^0.20.2 (compatibilidade com flutter_localizations)
    - Corrigido android/build.gradle.kts para namespace issues
    - Removido referências a assets inexistentes no pubspec.yaml
    - Arquivos gerados pelo Flutter atualizados automaticamente
```

## Dica importante

Se encontrar mais erros ao compilar, verifique:
1. Se está usando Flutter 3.x (`flutter --version`)
2. Se o Android SDK está atualizado
3. Se há outros arquivos com conflitos: `grep -r "<<<<<<" lib/`

## Comunicação

- Qualquer dúvida, pode perguntar
- Se encontrar novos erros, compartilhe o log completo
- Quando resolver os conflitos, avise para testarmos