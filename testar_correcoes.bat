@echo off
echo ========================================
echo  SCRIPT DE VERIFICACAO - HABITAI
echo  Testando correcoes implementadas
echo ========================================
echo.

echo [1/6] Verificando estrutura do projeto...
if not exist "android\app\build.gradle.kts" (
    echo ERRO: build.gradle.kts nao encontrado
    pause
    exit /b 1
)
if not exist "android\app\src\main\AndroidManifest.xml" (
    echo ERRO: AndroidManifest.xml nao encontrado
    pause
    exit /b 1
)
echo ✅ Estrutura do projeto OK

echo.
echo [2/6] Verificando arquivos de configuracao criados...
if not exist "android\app\src\main\res\xml\network_security_config.xml" (
    echo ERRO: network_security_config.xml nao encontrado
    pause
    exit /b 1
)
if not exist "android\app\proguard-rules.pro" (
    echo ERRO: proguard-rules.pro nao encontrado
    pause
    exit /b 1
)
echo ✅ Arquivos de configuracao OK

echo.
echo [3/6] Limpando build anterior...
call flutter clean
if %errorlevel% neq 0 (
    echo ERRO: flutter clean falhou
    pause
    exit /b 1
)
echo ✅ Build limpo

echo.
echo [4/6] Baixando dependencias...
call flutter pub get
if %errorlevel% neq 0 (
    echo ERRO: flutter pub get falhou
    pause
    exit /b 1
)
echo ✅ Dependencias atualizadas

echo.
echo [5/6] Verificando dispositivos conectados...
call adb devices
echo.
echo Se nenhum dispositivo apareceu acima, conecte um dispositivo Android ou inicie um emulador
echo.

echo [6/6] Construindo APK de debug...
echo Isso pode levar alguns minutos...
call flutter build apk --debug
if %errorlevel% neq 0 (
    echo ❌ ERRO: Build falhou
    echo Verifique os logs acima para detalhes
    pause
    exit /b 1
)

echo.
echo ========================================
echo ✅ BUILD CONCLUIDO COM SUCESSO!
echo ========================================
echo.
echo Proximos passos:
echo 1. Instalar APK: flutter install
echo 2. Monitorar logs: adb logcat ^| findstr HabitAI
echo 3. Testar funcionalidades principais
echo.
echo APK localizado em: build\app\outputs\flutter-apk\app-debug.apk
echo.

echo Deseja instalar o APK agora? (S/N)
set /p resposta=
if /i "%resposta%"=="S" (
    echo Instalando APK...
    call flutter install
    if %errorlevel% equ 0 (
        echo ✅ APK instalado com sucesso!
    ) else (
        echo ❌ Erro na instalacao do APK
    )
)

echo.
echo Deseja iniciar monitoramento de logs? (S/N)
set /p resposta2=
if /i "%resposta2%"=="S" (
    echo Iniciando monitoramento de logs...
    echo Pressione Ctrl+C para parar
    echo.
    adb logcat | findstr "HabitAI\|com.habitai.app\|MainActivity"
)

pause
