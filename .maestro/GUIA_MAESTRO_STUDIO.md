# 🎯 Guia Rápido - Maestro Studio

## 🚀 Como usar o Maestro Studio

### 1. Abrir o Studio
```powershell
.\abrir_maestro_studio.ps1
```

### 2. Interface do Studio

O Maestro Studio tem 3 áreas principais:

#### 📱 Área 1: Preview do Dispositivo (Esquerda)
- Mostra a tela do dispositivo em tempo real
- Clique em elementos para obter informações
- Use para ver exatamente o que está na tela

#### 💻 Área 2: Editor de Comandos (Centro)
- Digite comandos Maestro aqui
- Pressione **Ctrl+Enter** para executar
- Veja o resultado imediatamente

#### 📋 Área 3: Inspetor de Elementos (Direita)
- Mostra a hierarquia de elementos
- IDs, textos e propriedades
- Use para encontrar seletores corretos

## 🔍 Comandos Úteis no Studio

### Comandos Básicos:
```yaml
# Iniciar o app
- launchApp

# Tocar em texto
- tapOn: "Login"

# Tocar em elemento por ID
- tapOn:
    id: "button_login"

# Digitar texto
- inputText: "meu texto"

# Capturar tela
- takeScreenshot: "nome"

# Aguardar
- waitForAnimationToEnd

# Voltar
- back

# Verificar se visível
- assertVisible: "Texto"
```

### Exemplos de Uso:

#### 1. Descobrir o que está na tela:
```yaml
- takeScreenshot: "tela_atual"
- assertVisible: ".*"
```

#### 2. Encontrar um botão:
```yaml
# Tente diferentes formas
- tapOn: "Adicionar"
- tapOn: 
    id: ".*add.*"
- tapOn:
    point: "90%, 90%"
```

#### 3. Navegar no app:
```yaml
- tapOn: "Home"
- waitForAnimationToEnd
- tapOn: "Configurações"
```

## 🎨 Workflow Recomendado

### 1. **Explorar o App**
```yaml
- launchApp
- waitForAnimationToEnd
- takeScreenshot: "inicial"
```

### 2. **Identificar Elementos**
- Clique nos elementos no preview
- Veja os IDs e textos no inspetor
- Anote os seletores importantes

### 3. **Testar Comandos**
```yaml
# Teste cada comando individualmente
- tapOn: "seu_texto"
# Ctrl+Enter para executar
```

### 4. **Construir o Teste**
- Copie os comandos que funcionaram
- Cole em um novo arquivo .yaml
- Adicione `optional: true` onde necessário

## 💡 Dicas Pro

### 1. **Use Regex para Textos Flexíveis**
```yaml
- tapOn: ".*[Ll]ogin.*"  # Pega "Login", "login", "Fazer Login", etc
```

### 2. **Multiple Seletores**
```yaml
- tapOn:
    text: ".*[Aa]dicionar.*|.*[Nn]ovo.*|\\+"
    optional: true
```

### 3. **Posição Relativa**
```yaml
- tapOn:
    below:
        text: "Título"
```

### 4. **Coordenadas (último recurso)**
```yaml
- tapOn:
    point: "50%, 80%"  # Centro horizontal, 80% vertical
```

## 🐛 Solução de Problemas

### Elemento não encontrado:
1. Verifique se está visível no preview
2. Tente diferentes seletores
3. Adicione `waitForAnimationToEnd`
4. Use `optional: true`

### App não responde:
1. Reinicie o dispositivo/emulador
2. Reinstale o app
3. Limpe dados do app

### Studio não conecta:
1. Verifique `adb devices`
2. Reconecte o dispositivo
3. Reinicie o ADB: `adb kill-server && adb start-server`

## 📝 Exemplo Completo

```yaml
appId: com.habitai.app
---
# 1. Iniciar e lidar com onboarding
- launchApp
- waitForAnimationToEnd

# 2. Pular onboarding se existir
- tapOn:
    text: "Pular|Começar"
    optional: true

# 3. Fazer login se necessário
- tapOn:
    text: "Entrar com Google"
    optional: true
- waitForAnimationToEnd

# 4. Navegar para adicionar hábito
- tapOn:
    id: ".*fab.*"
    optional: true

# 5. Preencher formulário
- inputText: "Meu Hábito"
- tapOn: "Salvar"

# 6. Verificar sucesso
- assertVisible: "Meu Hábito"
- takeScreenshot: "sucesso"
```

## 🎬 Gravando Testes

No Studio, você também pode:
1. Clicar em **Record** (botão vermelho)
2. Interagir com o app normalmente
3. Parar a gravação
4. Salvar o teste gerado

---

**Lembre-se:** O Maestro Studio é sua melhor ferramenta para entender e testar o app!
