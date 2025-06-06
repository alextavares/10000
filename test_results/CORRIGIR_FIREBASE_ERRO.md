# 🔥 Correção do Erro de Criação de Conta - Firebase

## ❌ Problemas Identificados:

1. **Erro 400** - Falha na comunicação com o Firebase
2. **Avisos de campos de senha** - Não estão em formulário adequado (mas isso é só um aviso)
3. **Possível problema de configuração** no Firebase Console

## ✅ Soluções:

### 1. Verificar Configuração do Firebase Console

Acesse: https://console.firebase.google.com/project/android-habitai

#### A. Habilitar Autenticação por Email/Senha
1. No menu lateral, clique em **"Authentication"**
2. Clique na aba **"Sign-in method"**
3. Verifique se **"Email/Password"** está HABILITADO
4. Se não estiver, clique e ative

#### B. Verificar Configurações do Firestore
1. No menu lateral, clique em **"Firestore Database"**
2. Se não existir banco, crie um novo:
   - Clique em **"Create database"**
   - Escolha **"Start in production mode"**
   - Selecione a localização mais próxima

#### C. Atualizar Regras do Firestore
1. Em Firestore, clique na aba **"Rules"**
2. Substitua as regras por estas temporariamente (para teste):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Permite que usuários autenticados criem e leiam seus próprios documentos
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      // Permite criação durante o registro
      allow create: if request.auth != null;
    }
    
    // Regras para outras coleções (se existirem)
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

3. Clique em **"Publish"**

### 2. Verificar Web API Key

1. Vá para **Project Settings** (engrenagem no menu)
2. Na aba **"General"**, role até **"Your apps"**
3. Verifique se a **Web API Key** está correta no arquivo `.env`

### 3. Adicionar Domínio Autorizado

1. Em **Authentication** → **Settings** → **Authorized domains**
2. Adicione:
   - `localhost`
   - `localhost:5004`
   - `127.0.0.1:5004`

### 4. Correção Temporária no Código

Enquanto configura o Firebase, vou criar uma versão com melhor tratamento de erros:
