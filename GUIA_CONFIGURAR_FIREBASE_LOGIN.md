# 🔥 Guia Completo: Configurando Login Firebase no HabitAI

## 📋 Pré-requisitos

1. **Conta Google** (para acessar o Firebase Console)
2. **Flutter instalado** e configurado
3. **Git** para controle de versão

## 🚀 Passo a Passo

### Passo 1: Acessar o Console do Firebase

1. Acesse [https://console.firebase.google.com/](https://console.firebase.google.com/)
2. Faça login com sua conta Google

### Passo 2: Verificar/Criar Projeto Firebase

O projeto parece já estar configurado como `android-habitai`. Vamos verificar:

1. No console do Firebase, procure por um projeto chamado **android-habitai**
2. Se não existir, clique em **"Criar projeto"**:
   - Nome do projeto: `android-habitai`
   - Aceite os termos
   - Desative o Google Analytics (opcional)
   - Clique em "Criar projeto"

### Passo 3: Configurar Autenticação

1. No painel lateral, clique em **"Authentication"**
2. Clique em **"Começar"**
3. Na aba **"Sign-in method"**, habilite:
   - **Email/Senha** (clique, ative e salve)
   - **Google** (opcional, para login social)

### Passo 4: Configurar Firestore Database

1. No painel lateral, clique em **"Firestore Database"**
2. Clique em **"Criar banco de dados"**
3. Escolha o modo:
   - **Modo de produção** (mais seguro)
   - Ou **Modo de teste** (para desenvolvimento)
4. Selecione a localização mais próxima
5. Clique em "Ativar"

### Passo 5: Obter Configurações do Firebase

1. No Firebase Console, clique na **engrenagem** ⚙️ ao lado de "Visão geral do projeto"
2. Selecione **"Configurações do projeto"**
3. Role até **"Seus aplicativos"**
4. Se não houver apps registrados:
   - Clique no ícone **Web** (</>) 
   - Nome do app: `HabitAI Web`
   - Marque "Firebase Hosting" se quiser
   - Clique em "Registrar app"
   - Para Android, clique no ícone **Android**
   - Nome do pacote: `com.example.myapp` (ou o que estiver no AndroidManifest.xml)
   - Apelido: `HabitAI Android`
   - Clique em "Registrar app"

5. Copie as configurações que aparecerem

### Passo 6: Configurar o arquivo .env

Crie/edite o arquivo `.env` na raiz do projeto com as configurações do Firebase:

```env
# Firebase Configuration
FIREBASE_API_KEY=AIzaSy... (sua API key do Firebase)
FIREBASE_PROJECT_ID=android-habitai
FIREBASE_MESSAGING_SENDER_ID=258006613617
FIREBASE_APP_ID=1:258006613617:web:... (seu app ID)
FIREBASE_AUTH_DOMAIN=android-habitai.firebaseapp.com
FIREBASE_STORAGE_BUCKET=android-habitai.firebasestorage.app

# Google API Key (já existe)
GOOGLE_API_KEY=AIzaSyASadxCEaNgwMmSgoflToWtcu0sKXvXqHU
```

### Passo 7: Configurar Regras do Firestore

No Firebase Console > Firestore Database > Regras, cole:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Usuários só podem acessar seus próprios dados
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Subcoleções do usuário
      match /{subcollection}/{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

### Passo 8: Instalar Dependências

No terminal, na pasta do projeto:

```bash
flutter pub get
```

### Passo 9: Configurar para Android (se necessário)

1. Baixe o arquivo `google-services.json` do Firebase Console
2. Coloque em `android/app/google-services.json`

### Passo 10: Configurar para Web (se necessário)

No arquivo `web/index.html`, adicione antes de `</body>`:

```html
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-auth-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore-compat.js"></script>
```

## 🧪 Testando o Login

### 1. Executar o app:
```bash
flutter run
```

### 2. Criar uma conta de teste:
- Clique em "Sign Up"
- Preencha os campos:
  - Nome: Test User
  - Email: test@example.com
  - Senha: 123456
- Aceite os termos
- Clique em "Sign Up"

### 3. Fazer login:
- Use o email e senha criados
- Clique em "Log In"

## 🔧 Solução de Problemas

### Erro: "Firebase API Key não configurada"
- Verifique se o arquivo `.env` existe e tem FIREBASE_API_KEY

### Erro: "Network error"
- Verifique sua conexão com internet
- Verifique se o Firebase está ativo no console

### Erro: "Permission denied"
- Verifique as regras do Firestore
- Certifique-se que o usuário está autenticado

### Erro: "Email already in use"
- O email já foi cadastrado
- Use outro email ou faça login

## 📱 Usuários de Teste

Você pode criar usuários de teste manualmente no Firebase Console:

1. Authentication > Users
2. Clique em "Adicionar usuário"
3. Preencha email e senha
4. Clique em "Adicionar usuário"

## 🔐 Segurança

1. **Não commite o arquivo .env** - já está no .gitignore
2. **Use senhas fortes** em produção
3. **Configure regras adequadas** no Firestore
4. **Habilite verificação de email** se necessário

## 📊 Monitoramento

No Firebase Console você pode:
- Ver usuários cadastrados (Authentication)
- Ver dados salvos (Firestore Database)
- Monitorar uso (Usage and billing)
- Ver logs de erro (Crashlytics - se configurado)

## ✅ Checklist Final

- [ ] Firebase Console acessível
- [ ] Projeto `android-habitai` existe
- [ ] Authentication habilitado
- [ ] Firestore Database criado
- [ ] Arquivo `.env` configurado
- [ ] App consegue criar conta
- [ ] App consegue fazer login
- [ ] Dados são salvos no Firestore

## 🎉 Pronto!

Agora você pode:
1. Criar contas no app
2. Fazer login
3. Os hábitos serão salvos no Firebase
4. Executar os scripts de criação de hábitos

---

💡 **Dica**: Mantenha o Firebase Console aberto para monitorar em tempo real!
