# 📱 HabitAI - Plano de Desenvolvimento MVP

## 🎯 Objetivo
Transformar o HabitAI em um app simples e funcional de rastreamento de hábitos, similar ao concorrente analisado.

## 📍 Estado Atual
- ✅ App Flutter básico funcionando
- ❌ Erro ao editar hábitos
- ❌ Interface muito complexa
- ❌ Dois fluxos de criação confusos

## 🚀 Plano de Implementação

### **FASE 1: Correções Essenciais** ⚡
**Objetivo:** Deixar o app funcional

**Tarefas:**
1. Corrigir erro "Failed to load habit" na edição
2. Simplificar modelo Habit (remover campos complexos)
3. Remover temporariamente fluxo de sugestões
4. Testar CRUD completo (Create, Read, Update, Delete)

**Arquivos principais:**
- `/lib/screens/habits/edit_habit_screen.dart`
- `/lib/models/habit.dart`
- `/lib/services/habit_service.dart`

---

### **FASE 2: Simplificar Criação** 🎨
**Objetivo:** Fluxo único e intuitivo

**Tarefas:**
1. Criar tela única de adicionar hábito
2. Campos básicos: Nome, Categoria, Ícone, Cor, Frequência
3. Remover tipos de rastreamento (manter só sim/não)
4. Simplificar navegação

**Novo fluxo:**
```
Botão "+" → Tela simples → Campos básicos → Salvar
```

---

### **FASE 3: Melhorar UI/UX** 💅
**Objetivo:** Interface limpa e moderna

**Tarefas:**
1. Redesenhar tela Today (lista de hábitos do dia)
2. Cards de hábitos mais visuais
3. Animação ao marcar como completo
4. Consistência visual (cores, fontes, espaçamentos)

---

### **FASE 4: Estatísticas Básicas** 📊
**Objetivo:** Visualizar progresso

**Tarefas:**
1. Implementar streak (sequência de dias)
2. Porcentagem de conclusão
3. Calendário com dias marcados
4. Gráfico simples de progresso

---

### **FASE 5: Features Futuras** 🔮
(Após MVP funcional)
- Sugestões de hábitos
- Tipos avançados (quantidade, tempo)
- Notificações
- Sincronização Firebase
- Modo Premium

## 🛠️ Como continuar o desenvolvimento

### Para retomar em nova conversa:
```
"Continuando desenvolvimento HabitAI - Fase X
Pasta do projeto: C:\codigos\HabitAiclaudedesktop\HabitAI
Último status: [descrever o que foi feito]"
```

### Estrutura simplificada do Habit:
```dart
class Habit {
  String id;
  String name;
  String category;
  IconData icon;
  Color color;
  String frequency; // 'daily' ou 'weekly'
  List<int>? daysOfWeek; // se weekly
  DateTime createdAt;
  List<DateTime> completedDates;
  bool isActive;
}
```

## 📝 Notas Importantes
- Foco em simplicidade primeiro
- Cada fase deve resultar em app funcional
- Testar após cada mudança
- Commitar no Git após cada fase completa

## 🎬 Próximo Passo Imediato
**Iniciar FASE 1:** Corrigir erro de edição de hábitos

---
Documento criado em: 03/06/2025
Flutter SDK: Já configurado
Projeto: C:\codigos\HabitAiclaudedesktop\HabitAI