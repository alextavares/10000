# PLANO DE IMPLEMENTAÇÃO - MELHORIAS NA TELA DE HÁBITOS

## 1. ANÁLISE DAS DIFERENÇAS

### App Concorrente tem:
- Cards de hábitos com visual mais detalhado
- Dias da semana em formato circular/destacado
- Percentual de conclusão visível
- Contadores de sequência (streak)
- Swipe para esquerda mostra opções (editar, arquivar, etc)
- Detalhes do hábito em tela separada com múltiplas abas
- Frequência personalizada (dias específicos do mês)
- Ícones coloridos para categorias

### Nosso App precisa:
- Redesenhar cards de hábitos
- Implementar swipe actions
- Criar tela de detalhes/edição de hábito
- Corrigir navegação para edição
- Adicionar indicadores visuais de progresso

## 2. PASSOS DE IMPLEMENTAÇÃO

### FASE 1: Corrigir Erro de Navegação
1. Verificar arquivo `habits_screen.dart`
2. Identificar onde está tentando navegar para edição
3. Criar rota para `HabitDetailsScreen`
4. Implementar navegação correta

### FASE 2: Redesenhar Card de Hábito
1. Modificar `habit_card.dart` ou criar novo widget
2. Adicionar:
   - Dias da semana em círculos
   - Indicador de progresso/percentual
   - Contador de sequência
   - Ícone da categoria colorido
   - Visual mais moderno

### FASE 3: Implementar Swipe Actions
1. Usar `Dismissible` ou `flutter_slidable`
2. Adicionar ações:
   - Editar
   - Arquivar
   - Excluir
   - Estatísticas
3. Implementar animações suaves

### FASE 4: Criar Tela de Detalhes do Hábito
1. Criar `habit_details_screen.dart`
2. Implementar tabs:
   - Calendário
   - Estatísticas
   - Editar
3. Adicionar campos:
   - Nome do hábito
   - Categoria
   - Descrição
   - Horário e lembretes
   - Prioridade
   - Frequência
   - Data de início
   - Data alvo
   - Opção de arquivar
   - Reiniciar progresso

### FASE 5: Melhorias Visuais
1. Adicionar animações
2. Melhorar cores e espaçamentos
3. Adicionar feedback visual ao interagir

## 3. ARQUIVOS A MODIFICAR/CRIAR

1. `lib/screens/habits/habits_screen.dart` - Corrigir navegação
2. `lib/widgets/habit_card.dart` - Redesenhar card
3. `lib/screens/habit/habit_details_screen.dart` - Nova tela
4. `lib/screens/habit/edit_habit_screen.dart` - Tela de edição
5. `pubspec.yaml` - Adicionar flutter_slidable

## 4. ORDEM DE EXECUÇÃO

1. Primeiro corrigir o erro de navegação
2. Implementar a tela de detalhes básica
3. Adicionar swipe actions
4. Melhorar visual dos cards
5. Adicionar funcionalidades avançadas
