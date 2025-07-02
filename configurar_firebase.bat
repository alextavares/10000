@echo off
cls
echo ========================================
echo   CONFIGURAR FIREBASE NO HABITAI
echo ========================================
echo.

cd /d C:\codigos\habitai2406\10000

echo [1] Verificando arquivo .env...
if exist .env (
    echo [OK] Arquivo .env encontrado
) else (
    echo [!] Arquivo .env NAO encontrado
    echo.
    echo Criando .env a partir do modelo...
    if exist .env.firebase (
        copy .env.firebase .env
        echo [OK] Arquivo .env criado!
        echo.
        echo IMPORTANTE: Edite o arquivo .env e adicione:
        echo - FIREBASE_API_KEY (obtenha no Firebase Console)
        echo - FIREBASE_APP_ID (obtenha no Firebase Console)
        echo.
        echo Pressione qualquer tecla para abrir o arquivo .env...
        pause >nul
        notepad .env
        echo.
        echo Apos preencher o .env, execute este script novamente.
        pause
        exit
    ) else (
        echo [ERRO] Arquivo .env.firebase nao encontrado!
        pause
        exit
    )
)

echo.
echo [2] Verificando dependencias Flutter...
call flutter pub get >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Dependencias instaladas
) else (
    echo [ERRO] Falha ao instalar dependencias
    pause
    exit
)

echo.
echo [3] Verificando configuracao do Firebase...
echo.
dart run verificar_firebase_config.dart

echo.
echo ========================================
echo.
echo Escolha uma opcao:
echo.
echo 1. Criar usuario de teste
echo 2. Executar o app
echo 3. Abrir Firebase Console
echo 4. Ver instrucoes completas
echo 5. Sair
echo.
set /p opcao="Digite o numero da opcao: "

if "%opcao%"=="1" goto criar_usuario
if "%opcao%"=="2" goto executar_app
if "%opcao%"=="3" goto firebase_console
if "%opcao%"=="4" goto instrucoes
if "%opcao%"=="5" goto fim
goto fim

:criar_usuario
echo.
echo Criando usuario de teste...
dart run scripts\criar_usuario_teste.dart
pause
goto fim

:executar_app
echo.
echo Iniciando o app HabitAI...
start cmd /k "flutter run"
goto fim

:firebase_console
echo.
echo Abrindo Firebase Console...
start https://console.firebase.google.com/
goto fim

:instrucoes
echo.
echo Abrindo guia de configuracao...
if exist GUIA_CONFIGURAR_FIREBASE_LOGIN.md (
    start GUIA_CONFIGURAR_FIREBASE_LOGIN.md
) else (
    echo [ERRO] Arquivo de instrucoes nao encontrado!
)
pause
goto fim

:fim
echo.
echo Processo concluido!
pause
