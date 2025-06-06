# ✅ CHECKLIST DE VERIFICAÇÃO - CORREÇÕES HABITAI

## 🚀 PASSO A PASSO PARA TESTAR AS CORREÇÕES

### ⚡ TESTE RÁPIDO (5 minutos)

#### 1. Executar Script de Verificação
```bash
# Na pasta HabitAI
testar_correcoes.bat
```

**Resultado esperado:** ✅ Build concluído sem erros críticos

#### 2. Verificar Logs Específicos
```bash
# Abrir outro terminal
verificar_logs_especificos.bat
```

**Resultado esperado:** 
- ❌ Não deve aparecer: `libpenguin.so not found`
- ❌ Não deve aparecer: `resource ID 0x6d0b000f`
- ❌ Não deve aparecer: `DNS.*FAIL`
- ✅ Deve aparecer: `Exact alarm permission is granted` (ou similar)

### 🔍 TESTE DETALHADO (15 minutos)

#### 3. Verificar Permissões
- [ ] Abrir app HabitAI
- [ ] Ir para Configurações do dispositivo > Apps > HabitAI > Permissões
- [ ] Verificar se "Alarmes e lembretes" está habilitado
- [ ] **Se não estiver:** O app deve solicitar automaticamente

#### 4. Testar Funcionalidades Principais
- [ ] **Criar um hábito**
  - Abrir HabitAI
  - Adicionar novo hábito
  - Definir lembrete/notificação
  - Verificar se não há crash

- [ ] **Testar Notificações**
  - Criar hábito com lembrete em 1 minuto
  - Aguardar notificação
  - Verificar se chegou corretamente

- [ ] **Navegação do App**
  - Testar todas as telas principais
  - Verificar se não há travamentos
  - Observar velocidade de carregamento

#### 5. Monitorar Performance
```bash
# Monitorar memória
adb shell dumpsys meminfo com.habitai.app

# Monitorar CPU
adb shell top | findstr com.habitai.app
```

**Resultado esperado:**
- Uso de memória < 300MB
- CPU < 30% durante uso normal

### 🔧 TESTE AVANÇADO (30 minutos)

#### 6. Teste de Stress
- [ ] Criar 10+ hábitos
- [ ] Configurar múltiplos lembretes
- [ ] Navegar rapidamente entre telas
- [ ] Minimizar/maximizar app várias vezes
- [ ] **Resultado:** App deve permanecer estável

#### 7. Teste de Conectividade
- [ ] Desconectar WiFi
- [ ] Usar apenas dados móveis
- [ ] Reconectar WiFi
- [ ] **Resultado:** App deve funcionar online/offline conforme esperado

#### 8. Teste de Reinicialização
- [ ] Reiniciar dispositivo
- [ ] Abrir HabitAI
- [ ] Verificar se dados persistiram
- [ ] Verificar se notificações ainda funcionam

## 📊 RESULTADOS ESPERADOS

### ✅ SUCESSOS OBRIGATÓRIOS
1. **Build sem erros:** `flutter build apk --debug` executa sem falhas
2. **App inicia:** Tela inicial carrega em < 5 segundos
3. **Sem crashes:** Uso normal não causa fechamento inesperado
4. **Permissões OK:** Notificações e alarmes funcionando
5. **Logs limpos:** Erros críticos anteriores não aparecem mais

### ⚠️ ALERTAS ACEITÁVEIS
- Warnings de performance (podem ser otimizados depois)
- Logs informativos sobre estado do app
- Avisos de compatibilidade (se funcionamento não for afetado)

### ❌ FALHAS QUE REQUEREM AÇÃO
- Qualquer crash durante uso básico
- Notificações não funcionando
- Erro de permissão de alarme
- Problemas de conectividade graves
- Reincidência dos erros originais

## 🆘 TROUBLESHOOTING

### Problema: Build falha
**Soluções:**
1. `flutter clean && flutter pub get`
2. Verificar versão do Android SDK
3. Atualizar Flutter: `flutter upgrade`

### Problema: Permissão de alarme negada
**Soluções:**
1. Configurações > Apps > HabitAI > Permissões
2. Habilitar "Alarmes e lembretes"
3. Reiniciar app

### Problema: App crash ao abrir
**Soluções:**
1. Verificar logs: `adb logcat | findstr HabitAI`
2. Reinstalar: `flutter install`
3. Limpar dados: Configurações > Apps > HabitAI > Armazenamento > Limpar dados

### Problema: Notificações não chegam
**Soluções:**
1. Verificar configurações de notificação do sistema
2. Desabilitar otimização de bateria para HabitAI
3. Verificar permissões de notificação

## 📝 RELATÓRIO DE TESTE

### Template para Relatório
```
Data do teste: ___________
Dispositivo: _____________
Android versão: __________

TESTES REALIZADOS:
[ ] Build executou sem erro
[ ] App inicializa corretamente
[ ] Permissões funcionando
[ ] Notificações OK
[ ] Performance aceitável
[ ] Sem crashes durante uso

PROBLEMAS ENCONTRADOS:
_________________________
_________________________

LOGS RELEVANTES:
_________________________
_________________________

STATUS FINAL: [ ] ✅ APROVADO [ ] ❌ REQUER CORREÇÃO
```

---

**⚠️ IMPORTANTE:** Se qualquer teste falhar, documente o erro específico e consulte o arquivo `RELATORIO_CORRECOES_IMPLEMENTADAS.md` para próximos passos.
