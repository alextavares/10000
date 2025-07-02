# 🚀 Configuração Rápida do Firebase para HabitAI

## O que foi criado:

### 📁 Arquivos de Configuração
- `.env.firebase` - Modelo do arquivo de configuração
- `configurar_firebase.bat` - Script automatizado de configuração
- `verificar_firebase_config.dart` - Verifica se tudo está configurado
- `scripts/criar_usuario_teste.dart` - Cria usuário de teste automaticamente

### 📚 Documentação
- `GUIA_CONFIGURAR_FIREBASE_LOGIN.md` - Guia completo passo a passo

## 🎯 Passos Rápidos:

### 1️⃣ Executar o Configurador Automático
```bash
configurar_firebase.bat
```

Este script vai:
- Verificar se o arquivo .env existe
- Criar o .env se necessário
- Verificar a configuração do Firebase
- Oferecer opções para criar usuário de teste

### 2️⃣ Configurar Firebase Console

Se ainda não tem um projeto Firebase:

1. Acesse [Firebase Console](https://console.firebase.google.com/)
2. Crie um projeto chamado `android-habitai`
3. Ative **Authentication** (Email/Senha)
4. Ative **Firestore Database**
5. Copie as configurações para o arquivo `.env`

### 3️⃣ Preencher o arquivo .env

O arquivo precisa ter no mínimo:
```env
FIREBASE_API_KEY=sua_chave_aqui
FIREBASE_APP_ID=seu_app_id_aqui
```

As outras configurações já estão pré-preenchidas.

### 4️⃣ Criar Usuário de Teste

Execute:
```bash
dart run scripts/criar_usuario_teste.dart
```

Isso criará:
- Email: `teste@habitai.com`
- Senha: `habitai123`

### 5️⃣ Testar o App

```bash
flutter run
```

Use as credenciais do usuário de teste para fazer login.

## ⚡ Comandos Úteis:

```bash
# Verificar configuração
dart run verificar_firebase_config.dart

# Criar usuário de teste
dart run scripts/criar_usuario_teste.dart

# Executar o app
flutter run

# Criar hábitos (após login)
criar_novo_habito.bat
```

## 🔍 Solução Rápida de Problemas:

### "FIREBASE_API_KEY não configurada"
1. Abra o Firebase Console
2. Vá em Configurações do Projeto
3. Copie a "Chave de API da Web"
4. Cole no arquivo .env

### "Permission denied" no Firestore
No Firebase Console > Firestore > Regras, use:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### "Network error"
- Verifique sua conexão com internet
- Verifique se não há firewall bloqueando

## ✅ Checklist:

- [ ] Firebase Console acessado
- [ ] Projeto criado/configurado
- [ ] Authentication ativado
- [ ] Firestore ativado
- [ ] Arquivo .env configurado
- [ ] Teste de configuração passou
- [ ] Usuário de teste criado
- [ ] Login funcionando no app

## 🎉 Pronto!

Após configurar, você pode:
1. Fazer login no app
2. Criar hábitos manualmente
3. Usar os scripts automatizados
4. Ver os dados no Firebase Console

---

💡 **Dica**: Execute `configurar_firebase.bat` - ele guiará você por todo o processo!
