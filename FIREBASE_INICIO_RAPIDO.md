# 🔥 Firebase - Configuração Super Rápida

## 1️⃣ Execute isto no terminal:
```
configurar_firebase.bat
```

## 2️⃣ O que você precisa fazer:

### No Firebase Console ([clique aqui](https://console.firebase.google.com/)):
1. Criar projeto: **android-habitai**
2. Ativar: **Authentication** → Email/Password
3. Ativar: **Firestore Database**
4. Pegar as chaves em: **Configurações do Projeto**

### No arquivo .env:
Adicione estas duas linhas (obtenha os valores no Firebase):
```
FIREBASE_API_KEY=sua_chave_aqui
FIREBASE_APP_ID=seu_app_id_aqui
```

## 3️⃣ Criar usuário de teste:
```
dart run scripts/criar_usuario_teste.dart
```

## 4️⃣ Testar:
```
flutter run
```

Login com:
- Email: `teste@habitai.com`
- Senha: `habitai123`

## ✅ Pronto! 

Agora você pode criar hábitos! 🎉

---

### 🆘 Problemas?
- Leia: `GUIA_CONFIGURAR_FIREBASE_LOGIN.md`
- Execute: `dart run verificar_firebase_config.dart`
