# 🇺🇸 HabitAI - English Configuration Guide

## 🌍 Firebase Server Location

Since HabitAI will be in English, using a US server is perfect!

### Recommended Firebase Location:
```
us-central1 (Iowa)
```

### Benefits:
- ✅ Central US location - best for global users
- ✅ Excellent performance for international audience
- ✅ Most Firebase features available
- ✅ Lower latency for North American users
- ✅ Better suited for English-speaking markets

## 📋 Firebase Configuration Steps

### 1. Create Firestore Database
1. Go to Firebase Console → **Firestore Database**
2. Click **"Create database"**
3. Choose **"Start in production mode"**
4. **Select location:** `us-central1 (Iowa)` ← RECOMMENDED
5. Click **"Enable"**

### 2. Enable Authentication
1. Go to **Authentication** → **Sign-in method**
2. Enable **Email/Password**
3. Save changes

### 3. Add Authorized Domains
1. Go to **Authentication** → **Settings** → **Authorized domains**
2. Add:
   - `localhost`
   - `localhost:5004`

### 4. Update Firestore Rules
Go to **Firestore** → **Rules** and paste:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow users to read/write their own documents
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow create: if request.auth != null;
    }
    
    // Rules for habits
    match /habits/{habitId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && 
        request.auth.uid == request.resource.data.userId;
    }
    
    // Rules for tasks
    match /tasks/{taskId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
      allow create: if request.auth != null && 
        request.auth.uid == request.resource.data.userId;
    }
    
    // General rules for other collections
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 🚀 Testing After Configuration

1. **Hot Reload** the Flutter app (press R in terminal)
2. **Refresh** the browser (F5)
3. **Create a test account:**
   - Email: `test@example.com`
   - Password: `password123`
   - Name: `Test User`

## 🎯 Language Updates Made

### Timer Screen - All texts translated:
- ✅ Cronômetro → Stopwatch
- ✅ Intervalos → Intervals
- ✅ INICIAR → START
- ✅ PAUSAR → PAUSE
- ✅ RETOMAR → RESUME
- ✅ ZERAR → RESET
- ✅ PARAR → STOP
- ✅ horas/minutos/segundos → hours/minutes/seconds
- ✅ Defina o tempo → Set the time
- ✅ Ciclos → Cycles
- ✅ Ilimitado → Unlimited
- ✅ Funcionalidade Premium → Premium Feature
- ✅ Sem registros recentes → No recent records
- ✅ Nenhuma atividade selecionada → No activity selected
- ✅ Timer Concluído → Timer Complete
- ✅ O tempo acabou → Time is up

### Authentication Screens - Already in English:
- ✅ Login screen
- ✅ Register screen
- ✅ Error messages

## 📝 Next Steps

1. Configure Firebase with US server (us-central1)
2. Test account creation
3. Verify all features work correctly
4. Continue testing other app sections

Good luck with your English HabitAI app! 🚀
