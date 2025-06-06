# 📋 Plano de Implementação - Tela de Edição de Hábitos

## 🎯 Objetivo
Implementar uma tela de edição de hábitos completa com três abas: Calendário, Estatísticas e Editar, mantendo a consistência com o design atual do app.

## 📱 Estrutura das Telas

### 1. **Navegação por Abas**
- [ ] Implementar TabBar com 3 abas no topo
- [ ] Calendário | Estatísticas | Editar
- [ ] Indicador visual da aba ativa (linha rosa abaixo)

### 2. **Aba Editar** ✅ (Prioritária)
- [ ] **Campos editáveis:**
  - Nome do hábito
  - Categoria (com ícone colorido)
  - Descrição (campo opcional)
  - Horário e lembretes
  - Prioridade (Normal/Alta/Baixa)
  - Frequência (Diária/Semanal/Mensal/Personalizada)
  - Data de início
  - Data alvo (opcional)
  - Arquivo (para anexos futuros)

- [ ] **Ações:**
  - Reiniciar progresso do hábito
  - Excluir hábito
  - Salvar alterações

### 3. **Aba Calendário** 📅
- [ ] Calendário mensal navegável
- [ ] Dias marcados com círculo colorido (completos)
- [ ] Contador de série atual
- [ ] Seção de anotações (futura)

### 4. **Aba Estatísticas** 📊
- [ ] **Widgets de estatísticas:**
  - Pontuação do hábito (circular)
  - Série atual vs melhor série
  - Contador de conclusões (semana/mês/ano/total)
  
- [ ] **Visualizações:**
  - Gráfico de barras anual
  - Gráfico de pizza (Sucesso/Pendente)
  - Período selecionável (Semana/Mês/Ano)
  
- [ ] **Gamificação:**
  - Desafio de série com badges
  - Conquistas desbloqueadas

## 🛠️ Implementação Sugerida

### Fase 1: Estrutura Base (Recomendado começar aqui)
1. Refatorar `HabitDetailsScreen` para usar `DefaultTabController`
2. Criar três widgets separados:
   - `HabitEditTab`
   - `HabitCalendarTab`
   - `HabitStatisticsTab`
3. Implementar navegação entre abas

### Fase 2: Aba Editar
1. Criar formulário com todos os campos
2. Implementar validações
3. Conectar com `HabitService` para salvar alterações
4. Adicionar diálogos de confirmação para ações destrutivas

### Fase 3: Aba Calendário
1. Usar package `table_calendar` ou similar
2. Integrar com `completionHistory` do hábito
3. Calcular e exibir série

### Fase 4: Aba Estatísticas
1. Implementar cálculos de estatísticas
2. Usar `fl_chart` para gráficos
3. Criar sistema de badges/conquistas

## ⚠️ Considerações Importantes

### O que pode ser implementado agora:
- ✅ Estrutura de abas
- ✅ Formulário de edição básico
- ✅ Integração com serviços existentes

### O que deve ser adiado:
- ⏳ Sistema completo de gamificação (requer novo modelo de dados)
- ⏳ Gráficos complexos (podem impactar performance)
- ⏳ Sistema de anexos/arquivos

## 🔧 Modificações Necessárias

### 1. **Models** (`habit.dart`)
```dart
// Adicionar campos se necessário:
- priority: String (low/normal/high)
- attachments: List<String> (futuro)
- notes: Map<DateTime, String> (para anotações)
```

### 2. **Screens**
- Refatorar `habit_details_screen.dart`
- Mover tela de edição atual para nova estrutura

### 3. **Services**
- Métodos já existem em `HabitService`
- Pode precisar adicionar métodos para estatísticas

## 📊 Estimativa de Complexidade

| Componente | Complexidade | Risco |
|------------|--------------|-------|
| Estrutura de Abas | Baixa | Baixo |
| Formulário de Edição | Média | Baixo |
| Calendário | Média | Médio |
| Estatísticas Básicas | Média | Baixo |
| Gráficos | Alta | Médio |
| Gamificação Completa | Alta | Alto |

## 🚀 Próximos Passos Recomendados

1. **Implementar estrutura de abas** (1-2 horas)
2. **Criar formulário de edição melhorado** (2-3 horas)
3. **Adicionar estatísticas básicas** (2 horas)
4. **Deixar calendário e gráficos para segunda fase**

## 💡 Alternativa Simplificada

Se quiser evitar complexidade inicial, podemos:
1. Manter a tela atual de detalhes
2. Adicionar apenas um botão "Editar" que abre um modal/bottom sheet
3. Implementar estatísticas básicas sem gráficos
4. Usar o calendário existente melhorado

---

**Nota**: Este plano visa manter a estabilidade do código atual enquanto adiciona funcionalidades gradualmente.