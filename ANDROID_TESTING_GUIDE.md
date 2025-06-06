# 🧪 Guia de Testes Android - HabitAI

## 📱 Como Testar o App

### Opção 1: Emulador Android

```powershell
# Listar emuladores disponíveis
flutter emulators

# Iniciar emulador
flutter emulators --launch Medium_Phone

# Aguardar o emulador iniciar completamente, então:
flutter run
```

### Opção 2: Dispositivo Físico

1. **Ativar Modo Desenvolvedor no Android:**
   - Configurações → Sobre o telefone
   - Tocar 7x em "Número da versão"
   
2. **Ativar Depuração USB:**
   - Configurações → Opções do desenvolvedor
   - Ativar "Depuração USB"
   
3. **Conectar via USB e executar:**
   ```powershell
   flutter devices  # Verificar se aparece
   flutter run
   ```

## 🔍 Testes Essenciais

### 1. **Teste de Funcionalidades Core**

- [ ] **Autenticação**
  - [ ] Registro de novo usuário
  - [ ] Login com email/senha
  - [ ] Logout
  - [ ] Recuperação de senha

- [ ] **Hábitos**
  - [ ] Criar novo hábito
  - [ ] Editar hábito existente
  - [ ] Deletar hábito
  - [ ] Marcar como completo
  - [ ] Desmarcar como completo
  - [ ] Visualizar detalhes

- [ ] **Frequências**
  - [ ] Hábito diário
  - [ ] Hábito semanal
  - [ ] Hábito mensal
  - [ ] Dias específicos

- [ ] **Tipos de Tracking**
  - [ ] Sim/Não
  - [ ] Quantidade
  - [ ] Cronômetro
  - [ ] Lista de atividades

### 2. **Teste de UI/UX**

- [ ] **Navegação**
  - [ ] Bottom navigation funciona
  - [ ] Drawer menu abre/fecha
  - [ ] Back button funciona corretamente
  
- [ ] **Responsividade**
  - [ ] Rotação de tela
  - [ ] Diferentes tamanhos de texto (acessibilidade)
  - [ ] Teclado não cobre inputs

- [ ] **Performance**
  - [ ] Scroll suave nas listas
  - [ ] Animações fluidas
  - [ ] Tempo de carregamento aceitável

### 3. **Teste de Conectividade**

- [ ] **Online**
  - [ ] Sincronização com Firebase
  - [ ] Atualização em tempo real
  
- [ ] **Offline**
  - [ ] App não crasha
  - [ ] Mensagens de erro apropriadas
  - [ ] Funcionalidades offline (se houver)

### 4. **Teste de Edge Cases**

- [ ] Lista vazia de hábitos
- [ ] Muitos hábitos (50+)
- [ ] Texto muito longo em títulos
- [ ] Datas no final/início do mês
- [ ] Mudança de fuso horário

## 📊 Métricas de Performance

### Verificar com Flutter DevTools:
```powershell
flutter run --profile
# Pressionar 'd' para abrir DevTools
```

### Métricas importantes:
- FPS (deve ficar em 60)
- Jank (frames perdidos)
- Uso de memória
- Tempo de inicialização

## 🐛 Relatório de Bugs

### Template para reportar bugs:

```markdown
**Descrição:**
[O que aconteceu]

**Passos para reproduzir:**
1. 
2. 
3. 

**Resultado esperado:**
[O que deveria acontecer]

**Resultado atual:**
[O que realmente aconteceu]

**Device:**
- Modelo: 
- Android: 
- Versão do app: 

**Screenshots/Logs:**
[Se aplicável]
```

## 🚀 Build para Teste

### Debug APK (rápido, com debugging):
```powershell
flutter build apk --debug
```

### Release APK (otimizado, sem debugging):
```powershell
flutter build apk --release
```

### App Bundle (recomendado para Play Store):
```powershell
flutter build appbundle --release
```

## 📱 Dispositivos Recomendados para Teste

1. **Mínimo**: Pixel 3a (Android 9)
2. **Médio**: Pixel 5 (Android 11)
3. **Alto**: Pixel 7 (Android 13)
4. **Tablet**: Nexus 9

## ⚠️ Problemas Comuns

### "INSTALL_FAILED_INSUFFICIENT_STORAGE"
- Limpar espaço no dispositivo
- Ou usar: `flutter run --no-fast-start`

### "Module was compiled with an incompatible version of Kotlin"
- Atualizar Kotlin version em `android/build.gradle`

### Firebase não conecta
- Verificar `google-services.json`
- Verificar SHA-1 no console Firebase

### App crasha ao abrir
- Verificar logs: `adb logcat | grep -i flutter`
- Verificar ProGuard rules
