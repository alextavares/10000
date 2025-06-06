# 🎭 Testes Automatizados com Maestro para HabitAI

Este diretório contém os testes automatizados de UI do HabitAI usando o Maestro.

## 📋 Pré-requisitos

1. **Java 17+** instalado e JAVA_HOME configurado
2. **Maestro** instalado (já está em C:\maestro\bin\)
3. **Emulador Android** ou dispositivo físico conectado
4. **App HabitAI** instalado no dispositivo

## 🚀 Como executar os testes

### 1. Verificar instalação do Maestro
```bash
maestro --version
```

### 2. Listar dispositivos disponíveis
```bash
maestro device list
```

### 3. Executar um teste específico
```bash
cd C:\codigos\HabitAiclaudedesktop\HabitAI
maestro test .maestro\test_app_launch.yaml
```

### 4. Executar todos os testes
```bash
cd C:\codigos\HabitAiclaudedesktop\HabitAI
maestro test .maestro\
```

### 5. Executar com gravação de vídeo
```bash
maestro record .maestro\test_criar_habito.yaml
```

## 📁 Estrutura dos testes

- `config.yaml` - Configuração global do Maestro
- `test_app_launch.yaml` - Teste básico de inicialização
- `test_criar_habito.yaml` - Teste de criação de novo hábito
- `test_marcar_habito.yaml` - Teste para marcar hábito como concluído
- `test_navegacao.yaml` - Teste de navegação entre telas

## 🎯 Comandos úteis do Maestro

### Modo interativo (Studio)
```bash
maestro studio
```
Abre uma interface visual para criar e testar comandos interativamente.

### Executar com logs detalhados
```bash
maestro test --debug .maestro\test_app_launch.yaml
```

### Executar em dispositivo específico
```bash
maestro test --device <DEVICE_ID> .maestro\test_app_launch.yaml
```

## 📝 Criando novos testes

1. Crie um novo arquivo `.yaml` em `.maestro\`
2. Comece com o appId:
```yaml
appId: com.habitai.app
---
```
3. Adicione comandos de teste
4. Execute com `maestro test`

## 🔍 Comandos principais do Maestro

- `launchApp` - Inicia o app
- `tapOn` - Toca em elemento (texto, id, coordenadas)
- `inputText` - Digita texto
- `swipe` - Desliza (Up, Down, Left, Right)
- `scroll` - Rola a tela
- `assertVisible` - Verifica se elemento está visível
- `assertNotVisible` - Verifica se elemento NÃO está visível
- `takeScreenshot` - Captura tela
- `waitForAnimationToEnd` - Aguarda animações
- `wait` - Aguarda X milissegundos
- `back` - Botão voltar
- `hideKeyboard` - Esconde teclado

## 🐛 Solução de problemas

### App não encontrado
- Verifique se o app está instalado: `adb shell pm list packages | findstr habitai`
- Reinstale o app se necessário

### Elemento não encontrado
- Use `maestro studio` para inspecionar elementos
- Adicione `optional: true` para elementos que podem não existir
- Use `waitForAnimationToEnd` antes de interagir

### Testes muito rápidos
- Adicione `wait: 1000` (milissegundos) entre ações
- Use `waitForAnimationToEnd` após navegações

## 📊 Relatórios

Screenshots são salvas automaticamente em:
```
C:\Users\[usuario]\.maestro\tests\[timestamp]\
```

## 🔗 Links úteis

- [Documentação Maestro](https://maestro.mobile.dev/)
- [Exemplos de testes](https://github.com/mobile-dev-inc/maestro/tree/main/examples)
- [Referência de comandos](https://maestro.mobile.dev/reference)
