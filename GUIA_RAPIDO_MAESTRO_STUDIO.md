# 🎯 Guia Rápido - Maestro Studio

## 🌐 Como Acessar
1. Execute `run_maestro_studio_fixed.bat`
2. Acesse **http://localhost:9999** no navegador
3. O Maestro Studio abrirá automaticamente

## 🎮 Interface do Maestro Studio

### 1. **Tela Principal**
- **Visualização do Dispositivo**: Espelho em tempo real da tela do celular
- **Console de Comandos**: Digite comandos Maestro diretamente
- **Histórico**: Veja comandos executados anteriormente

### 2. **Comandos Úteis no Console**

#### Navegação Básica:
```yaml
# Tocar em um elemento
- tapOn: "Nome do Botão"

# Tocar em coordenadas
- tapOn:
    point: "50%,50%"

# Scroll para baixo
- scroll

# Voltar
- pressKey: back
```

#### Entrada de Texto:
```yaml
# Digitar em campo
- tapOn: "Campo de texto"
- inputText: "Meu texto aqui"
```

#### Verificações:
```yaml
# Verificar se algo está visível
- assertVisible: "Texto esperado"

# Capturar screenshot
- takeScreenshot: "nome_da_tela"
```

## 🔍 Como Inspecionar Elementos

1. **Clique no ícone de "Inspector"** (lupa) na interface
2. **Clique em qualquer elemento** na tela do dispositivo
3. O Studio mostrará:
   - Texto do elemento
   - ID do elemento
   - Coordenadas
   - Hierarquia

## 📝 Criar Teste Passo a Passo

### Exemplo: Criar um hábito
```yaml
# 1. Abrir o app (se necessário)
- launchApp

# 2. Aguardar carregamento
- waitForAnimationToEnd

# 3. Tocar no botão de adicionar
- tapOn: "+"
# ou
- tapOn: "Adicionar"

# 4. Preencher nome do hábito
- tapOn: "Nome do hábito"
- inputText: "Beber 2L de água"

# 5. Salvar
- tapOn: "Salvar"

# 6. Verificar se foi criado
- assertVisible: "Beber 2L de água"
```

## 🎬 Gravar Ações

1. Clique no botão **"Record"** 🔴
2. Execute as ações no dispositivo
3. Clique em **"Stop"** ⏹️
4. O Studio gerará o YAML automaticamente

## 💡 Dicas Importantes

### 1. **Esperar Animações**
Sempre adicione após ações:
```yaml
- waitForAnimationToEnd
```

### 2. **Elementos Opcionais**
Para elementos que podem não existir:
```yaml
- tapOn:
    text: "Pular"
    optional: true
```

### 3. **Múltiplas Tentativas**
Para textos que variam:
```yaml
- tapOn:
    text: ".*[Aa]dicionar.*|\\+|[Nn]ovo"
```

### 4. **Debug Visual**
- Use `takeScreenshot` frequentemente
- Verifique o console para erros
- Use o Inspector para encontrar seletores corretos

## 🚀 Comandos Rápidos para Testar

Cole estes comandos no console do Studio:

```yaml
# Ver se o app está aberto
- assertVisible: ".*"

# Tirar screenshot
- takeScreenshot: "teste"

# Navegar pelo app
- scroll
- swipe:
    direction: LEFT

# Testar botões
- tapOn:
    id: ".*fab.*"
    optional: true
```

## ⚠️ Solução de Problemas

### Dispositivo não aparece?
```bash
adb devices
```

### App não abre?
```yaml
- launchApp: com.habitai.app
```

### Elemento não encontrado?
- Use o Inspector para ver o texto exato
- Tente regex: `".*parte_do_texto.*"`
- Use coordenadas: `point: "50%,80%"`

## 📱 Atalhos de Teclado no Studio

- **Ctrl+Enter**: Executar comando
- **↑/↓**: Navegar histórico
- **Ctrl+L**: Limpar console
- **F5**: Atualizar tela do dispositivo

---

**Mantenha o terminal aberto** enquanto usa o Studio!
Para parar: **Ctrl+C** no terminal.