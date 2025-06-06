# 🧪 GUIA DE TESTE - Sistema de Notificações Inteligentes

## 🚀 Como Testar Agora:

### 1. **Executar o App**
```bash
cd C:\codigos\HabitAiclaudedesktop\HabitAI
flutter run
```

### 2. **Acessar a Tela de Teste**
- Após fazer login, você verá um **ícone de sino amarelo** 🔔 no canto superior direito
- Clique nele para abrir a tela de teste de notificações

### 3. **Testes Disponíveis na Tela**

#### 🔔 **Teste 1: Notificação In-App**
- Clique em "Testar Notificação In-App"
- Uma notificação animada aparecerá no topo da tela
- Ela desaparecerá automaticamente após 4 segundos
- Você pode clicar nela ou arrastá-la para o lado

#### 📱 **Teste 2: Notificação Local**
- Clique em "Testar Notificação Local"
- O app pedirá permissão para enviar notificações (apenas na primeira vez)
- Uma notificação aparecerá na barra de notificações do Android
- Puxe a barra de notificações para vê-la

#### ⚙️ **Teste 3: Configurações**
- Clique em "Configurações de Notificações"
- Explore as opções:
  - Ativar/desativar notificações globais
  - Configurar horário silencioso
  - Ver análise de comportamento (após 7 dias de uso)

### 4. **Teste Completo com Hábitos**

#### Criar um Hábito com Notificações:
1. Volte à tela principal
2. Clique no botão "+" para adicionar hábito
3. Preencha os dados do hábito
4. **IMPORTANTE**: Ative "Notificações" nas configurações
5. Defina um horário de lembrete
6. Salve o hábito

#### Verificar Agendamento:
- As notificações serão agendadas automaticamente
- Você pode testar mudando o horário do dispositivo
- Ou aguarde o horário definido

### 5. **Teste de Análise de Comportamento**

#### Simular Conclusões:
1. Complete alguns hábitos em horários diferentes
2. Faça isso por alguns dias
3. O sistema começará a aprender seus padrões
4. Após 7 conclusões, verá insights na tela de configurações

### 6. **Teste de Integração**

#### Verificar Logs:
No terminal onde está rodando o app, você verá:
- "Sistema de notificações inicializado!" - ao iniciar
- "Smart notifications scheduled for: [nome do hábito]" - ao criar hábito
- Logs de análise quando completar hábitos

## 🔍 O que Verificar:

### ✅ **Checklist de Testes**
- [ ] Ícone amarelo de notificação aparece no app bar
- [ ] Tela de teste abre corretamente
- [ ] Notificação in-app aparece com animação
- [ ] Notificação local aparece na barra do Android
- [ ] Permissões são solicitadas corretamente
- [ ] Configurações abrem sem erros
- [ ] Hábitos com notificações salvam corretamente
- [ ] Logs aparecem no console

### ⚠️ **Problemas Comuns**

1. **Notificações não aparecem no Android:**
   - Verifique se concedeu permissão
   - Teste em dispositivo físico (emulador pode falhar)
   - Verifique configurações do Android > Apps > HabitAI > Notificações

2. **Erro ao abrir configurações:**
   - Execute `flutter clean` e `flutter pub get`
   - Reinicie o app

3. **Ícone não aparece:**
   - Faça hot restart (R maiúsculo no terminal)
   - Ou pare e rode o app novamente

## 📊 Teste Avançado (Opcional):

### Modificar Horário do Sistema:
1. Crie um hábito com notificação para 5 minutos no futuro
2. Vá em Configurações do Android > Data e Hora
3. Desative "Data e hora automáticas"
4. Avance o horário 5 minutos
5. A notificação deve aparecer!

### Testar Diferentes Tipos:
Na tela de teste, você pode modificar o código temporariamente para testar diferentes tipos de notificação:
- Motivação
- Alerta de Streak
- Insight
- Celebração

## 🎯 Resultado Esperado:

Após os testes, você terá verificado:
- ✅ Notificações in-app funcionando com animações
- ✅ Notificações locais do Android funcionando
- ✅ Sistema de permissões funcionando
- ✅ Integração com criação de hábitos
- ✅ Tela de configurações acessível
- ✅ Logs confirmando inicialização

**Pronto! O sistema está funcionando! 🎉**

## 🔄 Remover Teste Depois:

Quando terminar os testes, remova:
1. O import de `notification_test_screen.dart` do main.dart
2. A rota `/test-notifications`
3. O botão amarelo temporário em `main_navigation_screen.dart`

Mas mantenha a rota `/notification-settings` para uso em produção!
