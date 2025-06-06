# ⚠️ AVISOS DE SEGURANÇA - LEIA ANTES DE USAR MCPControl

## 🚨 PERIGO: CONTROLE TOTAL DO COMPUTADOR

### O que MCPControl permite:
- ✅ Mover e clicar com o mouse em QUALQUER lugar
- ✅ Digitar QUALQUER texto em QUALQUER aplicação
- ✅ Abrir e fechar QUALQUER programa
- ✅ Acessar TODOS os arquivos permitidos
- ✅ Executar comandos do sistema
- ✅ Capturar screenshots de TUDO

### Riscos Potenciais:
- ❌ Deletar arquivos importantes
- ❌ Enviar emails em seu nome
- ❌ Acessar informações sensíveis
- ❌ Modificar configurações do sistema
- ❌ Instalar software malicioso
- ❌ Comprometer sua privacidade

## 🛡️ MEDIDAS DE SEGURANÇA OBRIGATÓRIAS

### 1. USE MÁQUINA VIRTUAL (Altamente Recomendado)
```
- VMware Workstation
- VirtualBox
- Windows Sandbox
- Hyper-V
```

### 2. Crie Snapshot/Backup ANTES de usar
```
- Snapshot da VM
- Backup dos dados importantes
- Ponto de restauração do Windows
```

### 3. Use conta de usuário LIMITADA
```
- NÃO use conta de administrador
- Crie usuário específico para testes
- Limite permissões de pasta
```

### 4. NUNCA use em:
```
❌ Computador principal de trabalho
❌ Máquina com dados sensíveis
❌ Sistema com acesso a bancos/emails
❌ Computador com informações pessoais
```

## 📋 Checklist de Segurança

Antes de ativar MCPControl, confirme:

- [ ] Estou usando uma máquina virtual isolada
- [ ] Fiz backup/snapshot do sistema
- [ ] Não há dados sensíveis acessíveis
- [ ] Entendo os riscos envolvidos
- [ ] Vou supervisionar todas as ações
- [ ] Tenho como desligar rapidamente se necessário

## 🔴 SINAIS DE ALERTA - PARE IMEDIATAMENTE SE:

1. Claude tentar acessar:
   - Navegador com sessões abertas
   - Aplicativos de email
   - Gerenciadores de senha
   - Aplicativos bancários

2. Comportamento suspeito:
   - Comandos não solicitados
   - Tentativas de download
   - Modificação de arquivos de sistema
   - Acesso a pastas não autorizadas

## ✅ BOAS PRÁTICAS

### 1. Comece pequeno:
```
- Teste comandos simples primeiro
- Verifique cada ação
- Aumente complexidade gradualmente
```

### 2. Defina limites claros:
```
"Claude, apenas trabalhe na pasta C:\teste"
"Não acesse o navegador"
"Não execute comandos do sistema"
```

### 3. Monitore ativamente:
```
- Observe a tela constantemente
- Grave a sessão se possível
- Tenha botão de emergência pronto
```

## 🚀 USO SEGURO PARA DESENVOLVIMENTO

### Cenário Ideal:
1. VM Windows limpa
2. Apenas ferramentas de desenvolvimento
3. Código em repositório Git (com backup)
4. Sem credenciais salvas
5. Sem dados pessoais

### Workflow Seguro:
```
1. Criar VM snapshot
2. Ativar MCPControl
3. Trabalhar no projeto
4. Desativar MCPControl
5. Avaliar mudanças
6. Reverter snapshot se necessário
```

## 📞 EMERGÊNCIA

### Se algo der errado:
1. **DESLIGUE A INTERNET** (cabo ou WiFi)
2. **Force o fechamento** do Claude (Task Manager)
3. **Desligue a VM** imediatamente
4. **Restaure o snapshot** anterior
5. **Analise** o que aconteceu

### Kill Switch:
- Ctrl+Alt+Del → Task Manager → End Claude
- Botão de desligar da VM
- Desconectar cabo de rede

## 💭 LEMBRE-SE SEMPRE:

> "Com grande poder vem grande responsabilidade"
> 
> MCPControl é uma ferramenta PODEROSA mas PERIGOSA.
> Use com EXTREMA CAUTELA e NUNCA em produção.

---

**AO CONTINUAR, VOCÊ CONFIRMA QUE:**
- Entende TODOS os riscos
- Tomou TODAS as precauções
- Assume TOTAL responsabilidade
- Não culpará os desenvolvedores por problemas

**SEGURANÇA EM PRIMEIRO LUGAR! 🛡️**
