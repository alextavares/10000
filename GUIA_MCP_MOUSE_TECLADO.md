# 🖱️ Guia Completo: Ferramentas MCP para Controle de Mouse e Teclado

## 📋 Visão Geral

O MCP (Model Context Protocol) permite que o Claude interaja diretamente com seu computador através de ferramentas especializadas.

## 🛠️ Principais Ferramentas

### 1. **MCPControl** ⭐ (Mais Completo)
- **Controle Total:** Mouse, teclado, janelas, screenshots
- **Melhor para:** Automação completa de desktop
- **Resolução ideal:** 1280x720
- **GitHub:** `intelligence-assist/MCPControl`

### 2. **MCP Desktop Automation** 
- **Baseado em:** RobotJS
- **Funcionalidades:** Mouse, teclado, screenshots
- **Limitação:** Screenshots < 1MB
- **GitHub:** `tanob/mcp-desktop-automation`

### 3. **Desktop Commander MCP**
- **Foco:** Terminal e arquivos
- **Extra:** Pode controlar alguns aspectos do sistema
- **GitHub:** `wonderwhy-er/DesktopCommanderMCP`

## 🚀 Instalação Rápida

### Opção 1: Script Automático
```powershell
.\instalar_mcpcontrol.ps1
```

### Opção 2: Manual

1. **Abrir configuração do Claude:**
   ```
   %APPDATA%\Claude\claude_desktop_config.json
   ```

2. **Adicionar configuração:**
   ```json
   {
     "mcpServers": {
       "MCPControl": {
         "command": "npx",
         "args": ["-y", "mcp-control"]
       },
       "desktop-automation": {
         "command": "npx",
         "args": ["-y", "mcp-desktop-automation"]
       }
     }
   }
   ```

3. **Reiniciar Claude Desktop**

## 💻 Exemplo de Uso (Após Instalação)

### Com MCPControl instalado, o Claude poderá:

1. **Capturar tela:**
   ```
   "Tire um screenshot da tela atual"
   ```

2. **Mover mouse:**
   ```
   "Mova o mouse para o centro da tela"
   ```

3. **Clicar em elementos:**
   ```
   "Clique no botão Iniciar do Windows"
   ```

4. **Digitar texto:**
   ```
   "Digite 'Olá mundo' no notepad"
   ```

5. **Automatizar tarefas:**
   ```
   "Abra o Chrome e navegue para github.com"
   ```

## ⚠️ Avisos de Segurança

### 🔴 EXTREMAMENTE IMPORTANTE:

1. **Risco Alto:** Você está dando controle TOTAL do computador
2. **Use em VM:** Recomenda-se fortemente usar em máquina virtual
3. **Supervisione:** Sempre acompanhe o que está sendo executado
4. **Backup:** Faça backup de dados importantes antes

### 🛡️ Medidas de Segurança Recomendadas:

1. **Máquina Virtual:**
   - Use VMware ou VirtualBox
   - Resolução 1280x720
   - Snapshot antes de usar

2. **Permissões:**
   - Crie usuário específico
   - Limite acesso a pastas importantes
   - Desative após uso

3. **Monitoramento:**
   - Grave a tela durante uso
   - Mantenha log de ações
   - Tenha kill switch pronto

## 🔧 Configuração Avançada

### Para MCPControl com AutoHotkey:
```bash
# Instalar AutoHotkey v2
winget install AutoHotkey.AutoHotkey

# Configurar variáveis
set AUTOMATION_PROVIDER=autohotkey
set AUTOHOTKEY_PATH="C:\Program Files\AutoHotkey\v2\AutoHotkey.exe"
```

### Para uso remoto/VM:
```json
{
  "mcpServers": {
    "MCPControl": {
      "transport": "sse",
      "url": "http://192.168.1.100:3232/mcp"
    }
  }
}
```

## 📊 Comparação das Ferramentas

| Recurso | MCPControl | Desktop Automation | Desktop Commander |
|---------|------------|-------------------|-------------------|
| Mouse | ✅ Completo | ✅ Básico | ❌ |
| Teclado | ✅ Completo | ✅ Básico | ✅ Terminal |
| Screenshots | ✅ Alta res | ⚠️ < 1MB | ✅ |
| Janelas | ✅ | ❌ | ❌ |
| Arquivos | ❌ | ❌ | ✅ |
| Terminal | ❌ | ❌ | ✅ |

## 🎯 Casos de Uso

### 1. **Desenvolvimento Acelerado:**
- Automatizar testes de UI
- Gerar código enquanto testa
- Debug visual em tempo real

### 2. **Automação de Tarefas:**
- Preencher formulários
- Extrair dados de aplicativos
- Automatizar workflows repetitivos

### 3. **Testes de Software:**
- Testes end-to-end automatizados
- Validação de UI
- Testes de regressão visual

## 🚨 Troubleshooting

### Erro: "Node not found"
```bash
# Instalar Node.js
winget install OpenJS.NodeJS
```

### Erro: "Build tools required"
```bash
# Instalar como Admin
winget install Microsoft.VisualStudio.2022.BuildTools --override "--wait --passive --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"
```

### Claude não mostra ferramentas:
1. Verificar arquivo de config
2. Reiniciar Claude completamente
3. Verificar logs em: `%APPDATA%\Claude\logs\`

## 📚 Recursos Adicionais

- **Documentação MCP:** https://modelcontextprotocol.io/
- **Lista de Servidores MCP:** https://github.com/modelcontextprotocol/servers
- **Comunidade:** https://discord.gg/mcp-community

## 🎬 Próximos Passos

1. **Instale em VM primeiro** para testar
2. **Configure permissões** adequadas
3. **Teste comandos simples** antes de automações complexas
4. **Documente seus workflows** para reutilização

---

**Lembre-se:** Com grande poder vem grande responsabilidade! 🕷️
