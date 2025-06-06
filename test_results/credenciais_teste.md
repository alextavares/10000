# Credenciais de Teste - HabitAI

## 🔐 Contas de Teste

### Conta Válida (se existir no sistema):
- **Email:** teste@exemplo.com
- **Senha:** senha123

### Conta Inválida (para testar erros):
- **Email:** invalido@teste.com
- **Senha:** senhaerrada

### Testes de Validação:
1. **Email vazio:** Deixar campo em branco
2. **Email inválido:** "emailsemarroba.com"
3. **Senha curta:** "123"
4. **Senha vazia:** Deixar campo em branco

## 📝 Checklist de Testes de Login

### Campos e Validação:
- [ ] Campo de email aceita texto
- [ ] Campo de senha oculta caracteres
- [ ] Botão de mostrar/ocultar senha funciona
- [ ] Validação de email formato correto
- [ ] Validação de senha (mínimo de caracteres)

### Tentativas de Login:
- [ ] Login com email e senha vazios
- [ ] Login com email inválido
- [ ] Login com senha incorreta
- [ ] Login com credenciais válidas
- [ ] Mensagens de erro são claras

### Login Social:
- [ ] Botão do Google aparece
- [ ] Botão do Google é clicável
- [ ] Redirecionamento para Google funciona

### Outros Elementos:
- [ ] Link "Esqueceu a senha?" funciona
- [ ] Link "Criar conta" funciona
- [ ] Opção "Manter conectado" (se existir)

## 🎯 Script de Teste Rápido

Cole no console após a tela de login carregar:

```javascript
// Verificar elementos de login
console.log('Verificando tela de login...');
const elementos = {
    emailField: document.querySelector('input[type="email"]') || document.querySelector('input[placeholder*="mail"]'),
    passwordField: document.querySelector('input[type="password"]'),
    loginButton: document.querySelector('button[type="submit"]') || Array.from(document.querySelectorAll('button')).find(b => b.textContent.includes('Entrar') || b.textContent.includes('Login')),
    googleButton: Array.from(document.querySelectorAll('button')).find(b => b.textContent.includes('Google')),
    forgotPassword: Array.from(document.querySelectorAll('a')).find(a => a.textContent.includes('Esqueceu') || a.textContent.includes('Forgot')),
    createAccount: Array.from(document.querySelectorAll('a')).find(a => a.textContent.includes('Criar') || a.textContent.includes('Sign up'))
};

Object.entries(elementos).forEach(([key, element]) => {
    console.log(`${key}: ${element ? '✅ Encontrado' : '❌ Não encontrado'}`);
});
```
