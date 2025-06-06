# Comandos Prontos para Maestro Studio - HabitAI

## 🚀 Cole estes comandos no console do Maestro Studio

### 1. Verificar se o app está rodando
```
- assertVisible: ".*"
```

### 2. Capturar screenshot atual
```
- takeScreenshot: "tela_atual"
```

### 3. Tentar encontrar botão de adicionar
```
- tapOn:
    text: ".*[Aa]dicionar.*|.*[Nn]ovo.*|.*[Cc]riar.*|\\+|.*[Ff]ab.*"
    optional: true
```

### 4. Procurar por botão FAB (Floating Action Button)
```
- tapOn:
    id: ".*fab.*|.*add.*|.*plus.*"
    optional: true
```

### 5. Tocar no centro inferior da tela (posição comum do FAB)
```
- tapOn:
    point: "50%,90%"
```

### 6. Navegar pelo app
```
- scroll
```

### 7. Abrir menu lateral (se existir)
```
- tapOn:
    point: "10%,10%"
```

### 8. Verificar se há tela de login
```
- assertVisible:
    text: ".*[Ee]ntrar.*|.*[Ll]ogin.*|.*[Ee]-?mail.*"
    optional: true
```

### 9. Teste completo de criar hábito (ajuste conforme necessário)
```
- waitForAnimationToEnd
- tapOn: "+"
- waitForAnimationToEnd
- tapOn: "Nome"
- inputText: "Teste Maestro"
- tapOn: "Salvar"
```

### 10. Voltar para tela anterior
```
- pressKey: back
```

### 11. Scroll para cima/baixo
```
- scroll
- swipe:
    direction: UP
- swipe:
    direction: DOWN
```

### 12. Verificar elementos em português
```
- assertVisible:
    text: ".*[Hh]ábito.*|.*[Tt]arefa.*|.*[Mm]eta.*"
    optional: true
```

### 13. Testar navegação por abas (se existir)
```
- tapOn: "Hoje"
- waitForAnimationToEnd
- tapOn: "Estatísticas"
- waitForAnimationToEnd
- tapOn: "Perfil"
```

### 14. Procurar campo de busca
```
- tapOn:
    id: ".*search.*|.*busca.*|.*pesquisa.*"
    optional: true
```

### 15. Reiniciar o app
```
- stopApp
- launchApp
- waitForAnimationToEnd
```

## 💡 Dicas:
- Execute um comando por vez
- Use `takeScreenshot` após cada ação importante
- Se um comando falhar, tente variações do texto
- Use o Inspector (lupa) para ver os IDs exatos dos elementos
