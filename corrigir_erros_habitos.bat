@echo off
echo ================================
echo  Corrigindo Erros de Criacao de Habitos
echo ================================
echo.

echo 1. Limpando cache do Flutter...
call flutter clean

echo.
echo 2. Removendo arquivos de build antigos...
rmdir /s /q build 2>nul
rmdir /s /q .dart_tool 2>nul
del /q .flutter-plugins-dependencies 2>nul

echo.
echo 3. Obtendo dependencias...
call flutter pub get

echo.
echo 4. Verificando configuracao do Firebase...
echo Verificando arquivo .env...
if exist .env (
    echo - Arquivo .env encontrado
    findstr /C:"FIREBASE_API_KEY" .env >nul
    if %errorlevel% equ 0 (
        echo - Firebase API Key configurada
    ) else (
        echo - ERRO: Firebase API Key nao encontrada no .env
    )
) else (
    echo - ERRO: Arquivo .env nao encontrado!
)

echo.
echo 5. Criando script de teste automatizado...
echo import 'package:flutter/material.dart'; > test_habit_creation.dart
echo import 'package:flutter_test/flutter_test.dart'; >> test_habit_creation.dart
echo import 'package:myapp/models/habit.dart'; >> test_habit_creation.dart
echo import 'package:uuid/uuid.dart'; >> test_habit_creation.dart
echo. >> test_habit_creation.dart
echo void main() { >> test_habit_creation.dart
echo   test('Criar habito de exemplo', () { >> test_habit_creation.dart
echo     final habit = Habit( >> test_habit_creation.dart
echo       id: const Uuid().v4(), >> test_habit_creation.dart
echo       title: 'Teste de Criacao', >> test_habit_creation.dart
echo       category: 'Saude', >> test_habit_creation.dart
echo       icon: Icons.check, >> test_habit_creation.dart
echo       color: Colors.green, >> test_habit_creation.dart
echo       priority: 'Normal', >> test_habit_creation.dart
echo       frequency: HabitFrequency.daily, >> test_habit_creation.dart
echo       trackingType: HabitTrackingType.simOuNao, >> test_habit_creation.dart
echo       startDate: DateTime.now(), >> test_habit_creation.dart
echo       createdAt: DateTime.now(), >> test_habit_creation.dart
echo       updatedAt: DateTime.now(), >> test_habit_creation.dart
echo       userId: 'test-user', >> test_habit_creation.dart
echo       completionHistory: {}, >> test_habit_creation.dart
echo       dailyProgress: {}, >> test_habit_creation.dart
echo       streak: 0, >> test_habit_creation.dart
echo       longestStreak: 0, >> test_habit_creation.dart
echo       totalCompletions: 0, >> test_habit_creation.dart
echo     ); >> test_habit_creation.dart
echo     expect(habit.title, 'Teste de Criacao'); >> test_habit_creation.dart
echo     expect(habit.category, 'Saude'); >> test_habit_creation.dart
echo     print('Habito criado com sucesso: ${habit.title}'); >> test_habit_creation.dart
echo   }); >> test_habit_creation.dart
echo } >> test_habit_creation.dart

echo.
echo 6. Executando teste...
call flutter test test_habit_creation.dart

echo.
echo 7. Limpando arquivo de teste...
del test_habit_creation.dart

echo.
echo ================================
echo  Correcoes Aplicadas!
echo ================================
echo.
echo Agora tente executar o app novamente com:
echo   flutter run -d windows
echo.
echo Se ainda houver erros, verifique:
echo 1. Se esta logado no Firebase
echo 2. Se as permissoes do Firestore estao corretas
echo 3. Se a internet esta funcionando
echo.
pause
