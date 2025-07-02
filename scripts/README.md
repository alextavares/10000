# 🚀 Scripts de Automação para Criar Hábitos no HabitAI

Este diretório contém scripts automatizados para criar diferentes tipos de hábitos no aplicativo HabitAI.

## 📋 Pré-requisitos

1. **Flutter** instalado e configurado
2. **Dart** disponível no PATH
3. **Firebase** configurado no projeto
4. **Usuário autenticado** no app HabitAI

## 🎯 Hábitos Disponíveis

### 1. Gratidão Diária
- **Tipo**: Lista de Atividades
- **Frequência**: Diária
- **Meta**: 3 itens de gratidão por dia
- **Lembrete**: 21:00
- **Script**: `criar_habito_gratidao.dart`

### 2. Beber Água
- **Tipo**: Quantidade
- **Frequência**: Diária  
- **Meta**: 8 copos por dia
- **Lembrete**: 8:00
- **Script**: `criar_habito_agua.dart`

### 3. Meditação
- **Tipo**: Cronômetro
- **Frequência**: Diária
- **Meta**: 10 minutos por dia
- **Lembrete**: 6:30
- **Script**: `criar_habito_meditacao.dart`

### 4. Exercícios Físicos
- **Tipo**: Sim ou Não
- **Frequência**: Segunda, Quarta e Sexta
- **Meta**: 3 meses de consistência
- **Lembrete**: 18:00
- **Script**: `criar_habito_exercicio.dart`

## 💻 Como Usar

### Método 1: Usar o Menu Interativo (Recomendado)

1. Abra o terminal na pasta do projeto
2. Execute o comando:
   ```bash
   criar_novo_habito.bat
   ```
3. Escolha o hábito desejado no menu
4. O hábito será criado automaticamente

### Método 2: Executar Script Diretamente

Para criar um hábito específico, execute:

```bash
# Para Gratidão
dart run scripts/criar_habito_gratidao.dart

# Para Beber Água
dart run scripts/criar_habito_agua.dart

# Para Meditação
dart run scripts/criar_habito_meditacao.dart

# Para Exercícios
dart run scripts/criar_habito_exercicio.dart
```

### Método 3: Script Personalizado

1. Edite o arquivo `criar_habito_automatizado.js`
2. Modifique os dados do hábito conforme desejado
3. Execute:
   ```bash
   node scripts/criar_habito_automatizado.js
   ```

## 🔧 Personalização

Para criar um hábito personalizado, você pode:

1. **Copiar um script existente** e modificá-lo
2. **Editar os campos** do hábito:
   - `title`: Nome do hábito
   - `description`: Descrição detalhada
   - `category`: Categoria (Saúde, Fitness, Estudos, etc.)
   - `trackingType`: Tipo de rastreamento
   - `frequency`: Frequência do hábito
   - `reminderTime`: Horário do lembrete

## 📝 Estrutura dos Scripts

Cada script Dart segue esta estrutura:

```dart
1. Inicializar Firebase
2. Verificar autenticação do usuário
3. Configurar serviços necessários
4. Criar objeto Habit com os dados
5. Salvar no Firebase usando HabitService
6. Exibir confirmação e dicas
```

## 🐛 Solução de Problemas

### Erro: "Usuário não está autenticado"
- **Solução**: Abra o app HabitAI e faça login primeiro

### Erro: "Flutter não está instalado"
- **Solução**: Instale o Flutter seguindo [flutter.dev](https://flutter.dev/docs/get-started/install)

### Erro: "Firebase não inicializou"
- **Solução**: Verifique se o arquivo `firebase_options.dart` está configurado corretamente

### Erro: "Permissão negada no Firestore"
- **Solução**: Verifique as regras de segurança do Firestore no console do Firebase

## 🎨 Tipos de Rastreamento

O HabitAI suporta 4 tipos de rastreamento:

1. **simOuNao**: Marcar se foi feito ou não
2. **quantia**: Rastrear quantidade (ex: copos, páginas)
3. **cronometro**: Rastrear tempo gasto
4. **listaAtividades**: Lista de subtarefas

## 📅 Frequências Suportadas

- **daily**: Todos os dias
- **weekly**: Dias específicos da semana
- **monthly**: Dias específicos do mês
- **specificDaysOfYear**: Datas específicas
- **someTimesPerPeriod**: X vezes por período
- **repeat**: Repetir a cada X dias
- **custom**: Personalizado

## 🚀 Próximos Passos

Após criar seus hábitos:

1. Abra o app HabitAI
2. Navegue até a aba "Hábitos"
3. Seus novos hábitos estarão listados
4. Configure lembretes adicionais se necessário
5. Comece a rastrear seu progresso!

## 📞 Suporte

Se encontrar problemas:
1. Verifique os logs no terminal
2. Confirme que está autenticado no app
3. Verifique a conexão com a internet
4. Consulte a documentação do projeto

---

💡 **Dica**: Use estes scripts para criar rapidamente múltiplos hábitos e começar sua jornada de desenvolvimento pessoal!
