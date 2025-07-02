# Automação para Criar Hábito no HabitAI

Este script demonstra como usar o MCP de automação do Windows para criar um novo hábito no aplicativo HabitAI.

## Pré-requisitos

1. O app HabitAI deve estar rodando (`flutter run`)
2. O usuário deve estar logado
3. O app deve estar na tela principal

## Script de Automação

```python
import time

# Função auxiliar para aguardar
def wait(seconds=1):
    time.sleep(seconds)

# 1. Verificar se o app está aberto
print("🔍 Verificando se o HabitAI está aberto...")
# windows-automation:winExists com title "HabitAI"

# 2. Ativar a janela do app
print("📱 Ativando janela do HabitAI...")
# windows-automation:winActivate com title "HabitAI"
wait(2)

# 3. Navegar para a aba de Hábitos (se necessário)
print("📍 Navegando para a aba de Hábitos...")
# Clicar no ícone de hábitos na barra inferior
# windows-automation:mouseClick nas coordenadas do ícone de hábitos
wait(1)

# 4. Clicar no botão de adicionar hábito (+)
print("➕ Clicando no botão de adicionar hábito...")
# O botão flutuante geralmente fica no canto inferior direito
# windows-automation:mouseClick nas coordenadas do FAB
wait(2)

# 5. Preencher o formulário de novo hábito
print("📝 Preenchendo informações do hábito...")

# 5.1 Nome do hábito
print("  - Digite o nome do hábito...")
# windows-automation:send com text "Beber 8 copos de água"
wait(1)

# 5.2 Clicar no campo de descrição (Tab para próximo campo)
# windows-automation:send com text "{TAB}"
wait(0.5)

# 5.3 Descrição
print("  - Digite a descrição...")
# windows-automation:send com text "Manter-se hidratado bebendo água ao longo do dia"
wait(1)

# 5.4 Selecionar categoria (Saúde)
print("  - Selecionando categoria...")
# Usar Tab para navegar até o dropdown de categoria
# windows-automation:send com text "{TAB}"
wait(0.5)
# Abrir dropdown
# windows-automation:send com text "{SPACE}"
wait(0.5)
# Selecionar "Saúde" (primeira opção geralmente)
# windows-automation:send com text "{ENTER}"
wait(1)

# 5.5 Selecionar tipo de rastreamento (Quantidade)
print("  - Selecionando tipo de rastreamento...")
# Navegar até o dropdown de tipo
# windows-automation:send com text "{TAB}{TAB}"
wait(0.5)
# Abrir dropdown
# windows-automation:send com text "{SPACE}"
wait(0.5)
# Navegar para "Quantidade" (segunda opção)
# windows-automation:send com text "{DOWN}{ENTER}"
wait(1)

# 5.6 Definir meta de quantidade
print("  - Definindo meta...")
# Campo de quantidade aparece
# windows-automation:send com text "8"
wait(0.5)
# Tab para unidade
# windows-automation:send com text "{TAB}"
wait(0.5)
# windows-automation:send com text "copos"
wait(1)

# 5.7 Ativar lembrete
print("  - Configurando lembrete...")
# Navegar até o switch de lembrete
# windows-automation:send com text "{TAB}{TAB}{TAB}"
wait(0.5)
# Ativar
# windows-automation:send com text "{SPACE}"
wait(1)

# 6. Salvar o hábito
print("💾 Salvando hábito...")
# Scroll até o final da tela
# windows-automation:mouseWheel com direction "down" e clicks 5
wait(1)
# Clicar no botão "Criar Hábito"
# windows-automation:mouseClick nas coordenadas do botão
wait(2)

print("✅ Hábito criado com sucesso!")
```

## Comandos MCP Utilizados

### 1. Verificar Janela
```javascript
windows-automation:winExists
- title: "HabitAI"
```

### 2. Ativar Janela
```javascript
windows-automation:winActivate
- title: "HabitAI"
```

### 3. Cliques do Mouse
```javascript
windows-automation:mouseClick
- x: [coordenada X]
- y: [coordenada Y]
- button: "left"
```

### 4. Enviar Texto
```javascript
windows-automation:send
- text: "Texto a ser digitado"
- mode: 0
```

### 5. Scroll do Mouse
```javascript
windows-automation:mouseWheel
- direction: "down"
- clicks: 5
```

## Exemplo de Sequência Completa

```javascript
// 1. Ativar app
await mcp.call('windows-automation:winActivate', {
  title: 'HabitAI'
});

// 2. Aguardar
await new Promise(resolve => setTimeout(resolve, 2000));

// 3. Clicar no botão de adicionar (exemplo de coordenadas)
await mcp.call('windows-automation:mouseClick', {
  x: 1850,
  y: 980,
  button: 'left'
});

// 4. Preencher nome
await mcp.call('windows-automation:send', {
  text: 'Fazer 30 minutos de exercício',
  mode: 0
});

// 5. Navegar para próximo campo
await mcp.call('windows-automation:send', {
  text: '{TAB}',
  mode: 0
});

// ... continuar com os outros campos
```

## Dicas de Automação

1. **Coordenadas**: Use `windows-automation:mouseGetPos` para descobrir as coordenadas exatas dos elementos
2. **Tempos de Espera**: Ajuste os delays conforme a velocidade do seu sistema
3. **Navegação por Teclado**: Use Tab/Shift+Tab para navegar entre campos
4. **Validação**: Adicione verificações para confirmar que cada ação foi executada

## Alternativa: Automação via Código

Em vez de automação de UI, você pode criar hábitos diretamente via código:

```dart
// Em um arquivo de teste ou script
final habit = Habit(
  id: Uuid().v4(),
  title: 'Novo hábito via automação',
  category: 'Saúde',
  // ... outros campos
);

await habitService.addHabit(habit);
```

Isso é mais confiável e rápido que automação de UI.

