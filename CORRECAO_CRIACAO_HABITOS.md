# Correção: Usar Tela Completa de Criação de Hábitos

## Problema
O app estava usando a tela simplificada `AddHabitSimpleScreen` ao invés da tela completa `UpsertHabitScreen` ao criar novos hábitos.

## Solução
Alterado o arquivo `lib/screens/main_navigation_screen.dart` para navegar para a tela completa quando o usuário seleciona "Hábito" no menu de adição.

## Arquivos Modificados
- `lib/screens/main_navigation_screen.dart` - Linha ~131, mudança de AddHabitSimpleScreen para UpsertHabitScreen

## Resultado
Agora os usuários têm acesso a todas as opções de configuração ao criar um hábito:
- Categorias personalizadas com ícones
- 4 tipos de rastreamento (Sim/Não, Quantidade, Cronômetro, Lista)
- Frequências flexíveis (Diária, Semanal, Mensal)
- Configuração de lembretes
- Data alvo e prioridades

## Como Testar
1. Abrir o app
2. Clicar no botão "+" rosa
3. Selecionar "Hábito"
4. A tela completa de criação será exibida